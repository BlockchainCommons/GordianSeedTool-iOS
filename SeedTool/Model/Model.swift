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
                guard let seed = try? Seed.keychainLoad(id: id) else {
                    print("⛔️ Could not load seed from keychain \(id).")
                    return nil
                }
                return seed
            }
            for (index, seed) in seeds.enumerated() {
                seed.isDirty = true
                seed.ordinal = Ordinal(index)
                seed.save()
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
        return Model(seeds: seeds)
    }

    init(seeds: [Seed]) {
        self.seeds = seeds
    }
    
    func moveSeed(fromOffsets source: IndexSet, toOffset destination: Int) {
        seeds.move(fromOffsets: source, toOffset: destination)
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
    
    func seed(withID id: UUID) -> Seed? {
        guard let index = seeds.firstIndex(where: { seed in
            seed.id == id
        }) else {
            return nil
        }
        
        return seeds[index]
    }
    
    func removeSeed(withID id: UUID) {
        guard let index = seeds.firstIndex(where: { seed in
            seed.id == id
        }) else {
            return
        }
        
        seeds.remove(at: index)
    }

    func upsertSeed(_ seed: Seed) {
        var newSeeds = seeds
        if let index = newSeeds.firstIndex(of: seed) {
            newSeeds[index] = seed
        } else {
            newSeeds.append(seed)
        }
        newSeeds.sortByOrdinal()
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
//        for change in changes {
//            print(change)
//        }
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
        
//        for seed in new {
//            print(seed)
//        }

        hasSeeds = !seeds.isEmpty
    }
    
    func eraseAllData() {
        seeds.forEach { $0.isDirty = true }
        seeds.removeAll()
        settings.needsMergeWithCloud = true
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
    
    func mergeWithCloud(completion: @escaping (Result<Void, Error>) -> Void) {
        cloud.fetchAll(type: "Seed") { (result: Result<[Seed], Error>) in
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
                    cloud.save(type: "Seed", id: seed.id, object: seed) {
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
    static func model() -> Model {
        Model(seeds: Lorem.seeds(4))
    }
}

#endif
