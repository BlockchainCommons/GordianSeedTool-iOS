//
//  Model.swift
//  Gordian Seed Tool
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
        // Migrate from keychain to file system if necessary
        if let keychainSeedIDs = [UUID].load(name: "seeds") {
            let seeds = keychainSeedIDs.compactMap { id -> Seed? in
                guard let seed = try? Seed.loadFromKeychain(id: id) else {
                    print("⛔️ Could not load seed from keychain \(id).")
                    return nil
                }
                return seed
            }
            for (index, seed) in seeds.enumerated() {
                seed.isDirty = true
                seed.ordinal = Ordinal(index)
                seed.save()
                seed.deleteFromKeychain()
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
        seeds.sort { a, b in
            if a.ordinal == b.ordinal {
                return a.id.uuidString < b.id.uuidString
            } else {
                return a.ordinal < b.ordinal
            }
        }
        return Model(seeds: seeds)
    }

    init(seeds: [Seed]) {
        self.seeds = seeds
    }
    
    func removeSeed(_ seed: Seed) {
        guard let index = seeds.firstIndex(of: seed) else {
            return
        }
        
        seeds.remove(at: index)
    }
    
    func insertSeed(_ seed: Seed, at index: Int) {
        // Keep the array insertion and the updating of the new seed's
        // ordinal atomic with respect to the `seeds` attribute.
        var newSeeds = seeds
        newSeeds.insert(seed, at: index)
        orderSeed(seed, in: newSeeds, at: index)
        seeds = newSeeds
    }
    
    func orderSeed(_ seed: Seed, in seeds: [Seed], at index: Int) {
        var seed = seed
        let afterIndex = index - 1
        let beforeIndex = index + 1
        let after = afterIndex >= 0 ? seeds[afterIndex] : nil
        let before = beforeIndex < seeds.count ? seeds[beforeIndex] : nil
        //print("after: \(String(describing: after))")
        //print("before: \(String(describing: before))")
        seed.order(after: after, before: before)
        seed.isDirty = true
        //print("updated: \(seed)")
    }

    func updateSeeds(old: [Seed], new: [Seed]) {
        let changes = new.difference(from: old).inferringMoves()
        //print(changes)
        for change in changes {
            print(change)
        }
        for change in changes {
            switch change {
            case .insert(let offset, let seed, let associatedWith):
                if associatedWith != nil {
                    orderSeed(seed, in: new, at: offset)
                }
                seed.save()
            case .remove(_, let seed, let associatedWith):
                guard associatedWith == nil else { continue }
                seed.delete()
            }
        }
        
        for seed in new {
            print(seed)
        }

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
