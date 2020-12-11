//
//  Seed.swift
//  Fehu
//
//  Created by Wolf McNally on 12/9/20.
//

import Foundation
import LifeHash
import SwiftUI

final class Seed: Identifiable, ObservableObject {
    let id: UUID
    @Published var name: String { didSet { save() } }
    let data: Data
    @Published var note: String { didSet { save() } }

    init(id: UUID, name: String, data: Data, note: String = "") {
        self.id = id
        self.name = name
        self.data = data
        self.note = note
    }

    convenience init(name: String, data: Data, note: String = "") {
        self.init(id: UUID(), name: name, data: data, note: note)
    }

    convenience init() {
        let data = Data((0..<16).map { _ in UInt8.random(in: 0...255, using: &secureRandomNumberGenerator) })
        self.init(name: "Untitled", data: data)
    }
}

extension Seed: Saveable {
    static var saveType: String = "seed"
}

extension Seed: Codable {
    private enum CodingKeys: CodingKey {
        case id
        case name
        case data
        case note
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(data, forKey: .data)
        try container.encode(note, forKey: .note)
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let data = try container.decode(Data.self, forKey: .data)
        let note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
        self.init(id: id, name: name, data: data, note: note)
    }
}

extension Seed: Fingerprintable {
    var fingerprintData: Data { data }
}

extension Seed: Equatable {
    static func == (lhs: Seed, rhs: Seed) -> Bool {
        lhs.id == rhs.id
    }
}

extension Seed: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Seed: CustomStringConvertible {
    var description: String {
        "Seed(\(name))"
    }
}

import WolfLorem

extension Lorem {
    static func seed() -> Seed {
        Seed(name: Lorem.shortTitle(), data: Lorem.data(16))
    }

    static func seeds(_ count: Int) -> [Seed] {
        (0..<count).map { _ in seed() }
    }
}
