//
//  Model.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/9/20.
//

import Foundation
import LifeHash

final class Model: ObservableObject {
    @Published private(set) var seeds: [Seed] = []
    @Published var hasSeeds: Bool = false
    let settings: Settings
    
    var cloud: Cloud?
    
    func setSeeds(_ newSeeds: [Seed], replicateToCloud: Bool) {
        let oldSeeds = seeds
        let changes = newSeeds.difference(from: oldSeeds).inferringMoves()
        //print(changes)
//        for change in changes {
//            print(change)
//        }
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
        
//        for seed in new {
//            print(seed)
//        }

        seeds = newSeeds
        hasSeeds = !seeds.isEmpty
    }
    
    init(settings: Settings) {
        self.settings = settings
        
        // Migrate from keychain to file system if necessary
        if let keychainSeedIDs = [UUID].load(name: "seeds") {
            let seeds = keychainSeedIDs.compactMap { id -> Seed? in
                guard let seed = try? Seed.keychainLoad(id: id) else {
                    print("⛔️ Could not load seed from keychain \(id).")
                    return nil
                }
                return seed
            }
            for (index, seed) in seeds.enumerated() {
                seed.isDirty = true
                seed.ordinal = Ordinal(index)
                seed.save(model: self, replicateToCloud: false)
                seed.keychainDelete()
            }
            
            [UUID].delete(name: "seeds")
        }

        // Load from file system
        let seedIDs = Seed.ids
        var seeds = seedIDs.compactMap { id -> Seed? in
            let seed = try? Seed.load(id: id)
            if seed == nil {
                print("⛔️ Could not load seed \(id).")
            }
            return seed
        }
        seeds.sortByOrdinal()
        self.seeds = seeds
        cloud = Cloud(model: self, settings: settings)
   }

    init(seeds: [Seed], settings: Settings) {
        self.seeds = seeds
        self.settings = settings
    }
    
    func moveSeed(fromOffsets source: IndexSet, toOffset destination: Int) {
        var newSeeds = seeds
        newSeeds.move(fromOffsets: source, toOffset: destination)
        setSeeds(newSeeds, replicateToCloud: true)
    }
    
    func removeSeed(_ seed: Seed) {
        guard let index = seeds.firstIndex(of: seed) else {
            return
        }
        seed.isDirty = true
        
        var newSeeds = seeds
        newSeeds.remove(at: index)
        setSeeds(newSeeds, replicateToCloud: true)
    }
    
    func insertSeed(_ seed: Seed, at index: Int) {
        seed.isDirty = true
        // Keep the array insertion and the updating of the new seed's
        // ordinal atomic with respect to the `seeds` attribute.
        var newSeeds = seeds
        newSeeds.insert(seed, at: index)
        orderSeed(seed, in: newSeeds, at: index)
        setSeeds(newSeeds, replicateToCloud: true)
    }
    
    func seed(withID id: UUID) -> Seed? {
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

    func upsertSeed(_ seed: Seed, replicateToCloud: Bool) {
        var newSeeds = seeds
        if let index = newSeeds.firstIndex(of: seed) {
            newSeeds[index] = seed
        } else {
            newSeeds.append(seed)
        }
        newSeeds.sortByOrdinal()
        setSeeds(newSeeds, replicateToCloud: replicateToCloud)
    }
    
    func orderSeed(_ seed: Seed, in seeds: [Seed], at index: Int) {
        let afterIndex = index - 1
        let beforeIndex = index + 1
        let after = afterIndex >= 0 ? seeds[afterIndex] : nil
        let before = beforeIndex < seeds.count ? seeds[beforeIndex] : nil
        //print("after: \(String(describing: after))")
        //print("before: \(String(describing: before))")
        let newOrdinal = Ordinal(after: after?.ordinal, before: before?.ordinal)
        seed.ordinal = newOrdinal
        //print("updated: \(seed)")
    }
    
    func eraseAllData() {
        seeds.forEach { $0.isDirty = true }
        setSeeds([], replicateToCloud: true)
        settings.needsMergeWithCloud = true
    }
    
    func findSeed(with fingerprint: Fingerprint) -> Seed? {
        seeds.first { seed in
            seed.fingerprint == fingerprint
        }
    }
    
    func findSeed(with id: UUID) -> Seed? {
        seeds.first { seed in
            seed.id == id
        }
    }
    
    func hasSeed(with id: UUID) -> Bool {
        findSeed(with: id) != nil
    }
    
    func findParentSeed(of key: HDKey) -> Seed? {
        let derivationPath = key.origin ?? []
        return seeds.first { seed in
            let masterKey = HDKey(seed: seed)
            do {
                let derivedKey = try HDKey(parent: masterKey, derivedKeyType: key.keyType, childDerivationPath: derivationPath, isDerivable: key.isDerivable)
                return derivedKey.keyData == key.keyData && derivedKey.chainCode == key.chainCode
            } catch {
                print(error)
                return false
            }
        }
    }
    
    func derive(keyType: KeyType, path: DerivationPath, useInfo: UseInfo, isDerivable: Bool = true) -> HDKey? {
        guard let sourceFingerprint = path.sourceFingerprint else { return nil }
        for seed in seeds {
            let masterKey = HDKey(seed: seed, useInfo: useInfo)
            guard masterKey.keyFingerprint == sourceFingerprint else {
                continue
            }
            do {
                return try HDKey(parent: masterKey, derivedKeyType: keyType, childDerivationPath: path, isDerivable: isDerivable)
            } catch {
                print(error)
                return nil
            }
        }
        return nil
    }
    
    func fetchChanges(completion: @escaping (Result<Void, Error>) -> Void) {
        cloud?.fetchChanges(completion: completion)
    }
    
    func mergeWithCloud(completion: @escaping (Result<Void, Error>) -> Void) {
        cloud?.fetchAll(type: "Seed") { (result: Result<[Seed], Error>) in
            switch result {
            case .failure(let error):
                print("⛔️ Couldn't fetch seeds: \(error)")
                completion(.failure(error))
            case .success(let cloudSeeds):
                //print("cloudSeeds: \(cloudSeeds)")
                let cloudSeedsSet = Set(cloudSeeds)
                var localSeedsSet = Set(self.seeds)

                // Upload all the seeds we have that the cloud doesn't.
                let localNotCloudSeeds = localSeedsSet.subtracting(cloudSeedsSet)
                for seed in localNotCloudSeeds {
                    self.cloud?.save(type: "Seed", id: seed.id, object: seed) {
                        print("save result: \($0)")
                    }
                }

                // Override all the local seeds with the ones the cloud has.
                for cloudSeed in cloudSeedsSet {
                    localSeedsSet.update(with: cloudSeed)
                }
                
                var newSeeds = Array(localSeedsSet)
                newSeeds.sortByOrdinal()
                
                DispatchQueue.main.async {
                    self.seeds = newSeeds
                    completion(.success(()))
                }
            }
        }
    }
}

#if DEBUG

import WolfLorem

extension Lorem {
    static let settings = Settings(storage: MockSettingsStorage())
    
    static func model() -> Model {
        Model(seeds: Lorem.seeds(4), settings: settings)
    }
}

#endif
