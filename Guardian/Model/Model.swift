//
//  Model.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/9/20.
//

import Foundation
import LifeHash

final class Model: ObservableObject {
    @Published var seeds: [Seed] = [] {
        didSet { updateSeeds(old: oldValue, new: seeds) }
    }
    @Published var hasSeeds: Bool = false

    static func load() -> Model {
        let seedIDs = [UUID].load(name: "seeds") ?? []
        let seeds = seedIDs.compactMap { id -> Seed? in
            let seed = try? Seed.load(id: id)
            if seed == nil {
                print("⛔️ Could not load seed \(id).")
            }
            return seed
        }
        return Model(seeds: seeds)
    }

    init(seeds: [Seed]) {
        self.seeds = seeds
        updateSeeds(old: seeds, new: seeds)
    }
    
    func removeSeed(_ seed: Seed) {
        guard let index = seeds.firstIndex(of: seed) else {
            return
        }
        
        seeds.remove(at: index)
    }
    
    func insertSeed(_ seed: Seed, at index: Int) {
        seed.isDirty = true
        seeds.insert(seed, at: index)
    }

    func updateSeeds(old: [Seed], new: [Seed]) {
        let changes = new.difference(from: old).inferringMoves()
        //print(changes)
        for change in changes {
            switch change {
            case .insert(_, let seed, let associatedWith):
                guard associatedWith == nil else { continue }
                seed.save()
            case .remove(_, let seed, let associatedWith):
                guard associatedWith == nil else { continue }
                seed.delete()
            }
        }

        (new.map { $0.id }).save(name: "seeds")

        hasSeeds = !seeds.isEmpty
    }
    
    func eraseAllData() {
        seeds.removeAll()
    }
    
    func findSeed(with fingerprint: Fingerprint) -> Seed? {
        seeds.first { seed in
            seed.fingerprint == fingerprint
        }
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
    
    func derive(keyType: KeyType, path: DerivationPath, useInfo: UseInfo, isDerivable: Bool) -> HDKey? {
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
}

#if DEBUG

import WolfLorem

extension Lorem {
    static func model() -> Model {
        Model(seeds: Lorem.seeds(4))
    }
}

#endif
