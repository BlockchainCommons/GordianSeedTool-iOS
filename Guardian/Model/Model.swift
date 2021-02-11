//
//  Model.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/9/20.
//

import Foundation

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
}

import WolfLorem

extension Lorem {
    static func model() -> Model {
        Model(seeds: seeds(4))
    }
}