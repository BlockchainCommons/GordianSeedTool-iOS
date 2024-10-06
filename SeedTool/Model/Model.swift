//
//  Model.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/9/20.
//

import Foundation
import WolfOrdinal
import WolfBase
import os
import BCApp
import Observation

fileprivate let logger = Logger(subsystem: Application.bundleIdentifier, category: "Model")

@Observable
final class Model {
    private(set) var seeds: [ModelSeed] = []
    var hasSeeds: Bool = false
    let settings: Settings
    
    var cloud: Cloud?
    
    func setSeeds(_ newSeeds: [ModelSeed], replicateToCloud: Bool) {
        let oldSeeds = seeds
        let changes = newSeeds.difference(from: oldSeeds).inferringMoves()
        for change in changes {
            switch change {
            case .insert(let offset, let seed, let associatedWith):
                if associatedWith != nil {
                    orderSeed(seed, in: newSeeds, at: offset)
                }
                seed.save(model: self, replicateToCloud: replicateToCloud)
            case .remove(_, let seed, let associatedWith):
                guard associatedWith == nil else { continue }
                seed.delete(model: self, replicateToCloud: replicateToCloud)
            }
        }

        seeds = newSeeds
        hasSeeds = !seeds.isEmpty
    }
    
    init(settings: Settings) {
        self.settings = settings
        
        // Load from file system
        let seedIDs = ModelSeed.ids
        var seeds = seedIDs.compactMap { id -> ModelSeed? in
            let seed = try? ModelSeed.load(id: id)
            if seed == nil {
                logger.error("⛔️ Could not load seed \(id).")
            }
            return seed
        }
        seeds.sortByOrdinal()
        self.seeds = seeds
        cloud = Cloud(model: self, settings: settings)
   }

    init(seeds: [ModelSeed], settings: Settings) {
        self.seeds = seeds
        self.settings = settings
    }
    
    func moveSeed(fromOffsets source: IndexSet, toOffset destination: Int) {
        var newSeeds = seeds
        newSeeds.move(fromOffsets: source, toOffset: destination)
        setSeeds(newSeeds, replicateToCloud: true)
    }
    
    func removeSeed(_ seed: ModelSeed) {
        guard let index = seeds.firstIndex(of: seed) else {
            return
        }
        seed.isDirty = true
        
        var newSeeds = seeds
        newSeeds.remove(at: index)
        setSeeds(newSeeds, replicateToCloud: true)
    }
    
    func insertSeed(_ seed: ModelSeed, at index: Int) {
        seed.isDirty = true
        // Keep the array insertion and the updating of the new seed's
        // ordinal atomic with respect to the `seeds` attribute.
        var newSeeds = seeds
        newSeeds.insert(seed, at: index)
        orderSeed(seed, in: newSeeds, at: index)
        setSeeds(newSeeds, replicateToCloud: true)
    }
    
    func seed(withID id: UUID) -> ModelSeed? {
        guard let index = seeds.firstIndex(where: { seed in
            seed.id == id
        }) else {
            return nil
        }
        
        return seeds[index]
    }
    
    func removeSeed(withID id: UUID, replicateToCloud: Bool) {
        guard let index = seeds.firstIndex(where: { seed in
            seed.id == id
        }) else {
            return
        }
        
        var newSeeds = seeds
        newSeeds.remove(at: index)
        setSeeds(newSeeds, replicateToCloud: replicateToCloud)
    }

    func upsertSeed(_ seed: ModelSeed, replicateToCloud: Bool) {
        var newSeeds = seeds
        if let index = newSeeds.firstIndex(of: seed) {
            newSeeds[index] = seed
        } else {
            newSeeds.append(seed)
        }
        newSeeds.sortByOrdinal()
        setSeeds(newSeeds, replicateToCloud: replicateToCloud)
    }
    
    func orderSeed(_ seed: ModelSeed, in seeds: [ModelSeed], at index: Int) {
        let afterIndex = index - 1
        let beforeIndex = index + 1
        let after = afterIndex >= 0 ? seeds[afterIndex] : nil
        let before = beforeIndex < seeds.count ? seeds[beforeIndex] : nil
        let newOrdinal = Ordinal(after: after?.ordinal, before: before?.ordinal)
        seed.ordinal = newOrdinal
    }
    
    func eraseAllData() {
        seeds.forEach { $0.isDirty = true }
        setSeeds([], replicateToCloud: true)
        settings.needsMergeWithCloud = true
    }
    
    func findSeed(with fingerprint: Fingerprint) -> ModelSeed? {
        seeds.first { seed in
            seed.fingerprint == fingerprint
        }
    }
    
    func findSeed(with id: UUID) -> ModelSeed? {
        seeds.first { seed in
            seed.id == id
        }
    }
    
    func hasSeed(with id: UUID) -> Bool {
        findSeed(with: id) != nil
    }
    
    func findParentSeed(of key: ModelHDKey) -> ModelSeed? {
        let derivationPath = key.parent
        return seeds.first { seed in
            let masterKey = try! ModelHDKey(seed: seed)
            do {
                let derivedKey = try ModelHDKey(parent: masterKey, derivedKeyType: key.keyType, childDerivationPath: derivationPath, isDerivable: key.isDerivable)
                return derivedKey.keyData == key.keyData && derivedKey.chainCode == key.chainCode
            } catch {
                logger.error("⛔️ Couldn't derive key: \(error.localizedDescription)")
                return false
            }
        }
    }
    
    func derive(keyType: KeyType, path: DerivationPath, useInfo: UseInfo, isDerivable: Bool = true) -> ModelHDKey? {
        guard case let .fingerprint(sourceFingerprint) = path.origin else { return nil }
        for seed in seeds {
            let masterKey = try! ModelHDKey(seed: seed, useInfo: useInfo)
            guard masterKey.keyFingerprint == sourceFingerprint else {
                continue
            }
            do {
                return try ModelHDKey(parent: masterKey, derivedKeyType: keyType, childDerivationPath: path, isDerivable: isDerivable)
            } catch {
                logger.error("⛔️ Couldn't derive key: \(error.localizedDescription)")
                return nil
            }
        }
        return nil
    }
    
    func fetchChanges() async throws {
        try await cloud?.fetchChanges()
    }
    
    func mergeWithCloud() async throws {
        guard let cloud else {
            return
        }
        do {
            let cloudSeeds: [ModelSeed] = try await cloud.fetchAll(type: "Seed")
            let cloudSeedsSet = Set(cloudSeeds)
            var localSeedsSet = Set(self.seeds)

            // Upload all the seeds we have that the cloud doesn't.
            let localNotCloudSeeds = localSeedsSet.subtracting(cloudSeedsSet)
            for seed in localNotCloudSeeds {
                try await cloud.save(type: "Seed", id: seed.id, object: seed)
            }

            // Override all the local seeds with the ones the cloud has.
            for cloudSeed in cloudSeedsSet {
                localSeedsSet.update(with: cloudSeed)
            }
            
            var newSeeds = Array(localSeedsSet)
            newSeeds.sortByOrdinal()
            
            self.seeds = newSeeds
        } catch {
            logger.error("⛔️ Couldn't fetch seeds: \(error.localizedDescription)")
            throw error
        }
    }
}

#if DEBUG

import WolfLorem

extension Lorem {
    static let settings = Settings(storage: MockSettingsStorage())
    
    @MainActor
    static func model(count: Int = 4) -> Model {
        Model(seeds: Lorem.seeds(count), settings: settings)
    }
}

#endif
