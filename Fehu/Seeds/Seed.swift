//
//  Seed.swift
//  Fehu
//
//  Created by Wolf McNally on 12/9/20.
//

import Foundation
import LifeHash
import SwiftUI
import URKit
import Combine

final class Seed: Identifiable, ObservableObject, ModelObject {
    let id: UUID
    @Published var name: String {
        didSet { if oldValue != note { isDirty = true } }
    }
    let data: Data
    @Published var note: String {
        didSet { if oldValue != note { isDirty = true } }
    }
    var isDirty: Bool = false

    private var bag: Set<AnyCancellable> = []

    lazy var nameValidator: ValidationPublisher = {
        $name
            .debounceField()
            .validateNotEmpty("Name may not be empty.")
    }()

    lazy var noteValidator: ValidationPublisher = {
        $note
            .debounceField()
            .validateAlways()
    }()

    lazy var isValidPublisher: AnyPublisher<Bool, Never> = {
        nameValidator.map { validation in
            switch validation {
            case .valid:
                return true
            case .invalid:
                return false
            }
        }
        .eraseToAnyPublisher()
    }()

    lazy var needsSavePublisher: AnyPublisher<Void, Never> = {
        Publishers.CombineLatest(nameValidator, noteValidator)
            .map { nameValidation, noteValidation in
                [nameValidation, noteValidation].allSatisfy {
                    switch $0 {
                    case .valid:
                        return true
                    case .invalid:
                        return false
                    }
                }
            }
            .filter { $0 }
            .map { _ in return () }
            .eraseToAnyPublisher()
    }()

    static var modelObjectType: ModelObjectType { return .seed }
    
    var hasName: Bool {
        !name.isEmpty && name != "Untitled"
    }

    init(id: UUID, name: String, data: Data, note: String = "") {
        self.id = id
        self.name = name
        self.data = data
        self.note = note
    }

    convenience init(name: String = "Untitled", data: Data, note: String = "") {
        self.init(id: UUID(), name: name, data: data, note: note)
    }

    convenience init() {
        self.init(data: SecureRandomNumberGenerator.shared.data(count: 16))
    }
}

extension Seed {
    var hex: String {
        data.hex
    }

    var cbor: CBOR {
        var a: [(CBOR, CBOR)] = [
            (1, CBOR.byteString(data.bytes))
        ]

        if !name.isEmpty {
            a.append((3, CBOR.utf8String(name)))
        }

        if !note.isEmpty {
            a.append((4, CBOR.utf8String(note)))
        }

        return CBOR.orderedMap(a)
    }

    var taggedCBOR: CBOR {
        CBOR.tagged(.init(rawValue: 300), cbor)
    }

    var ur: UR {
        return try! UR(type: "crypto-seed", cbor: cbor)
    }

    var urString: String {
        UREncoder.encode(ur)
    }

    convenience init(id: UUID = UUID(), urString: String) throws {
        let ur = try URDecoder.decode(urString)
        guard ur.type == "crypto-seed" else {
            throw GeneralError("Unexpected UR type.")
        }
        try self.init(id: id, cborData: ur.cbor)
    }

    convenience init(id: UUID, cborData: Data) throws {
        guard let cbor = try CBOR.decode(cborData.bytes) else {
            throw GeneralError("ur:crypto-seed: Invalid CBOR.")
        }
        try self.init(id: id, cbor: cbor)
    }

    convenience init(id: UUID, cbor: CBOR) throws {
        guard case let CBOR.map(pairs) = cbor else {
            throw GeneralError("ur:crypto-seed: CBOR doesn't contain a map.")
        }
        guard let dataItem = pairs[1], case let CBOR.byteString(bytes) = dataItem else {
            throw GeneralError("ur:crypto-seed: CBOR doesn't contain data field.")
        }
        let data = Data(bytes)

        let name: String
        if let nameItem = pairs[3] {
            guard case let CBOR.utf8String(s) = nameItem else {
                throw GeneralError("ur:crypto-seed: Name field doesn't contain string.")
            }
            name = s
        } else {
            name = "Untitled"
        }

        let note: String
        if let noteItem = pairs[4] {
            guard case let CBOR.utf8String(s) = noteItem else {
                throw GeneralError("ur:crypto-seed: Note field doesn't contain string.")
            }
            note = s
        } else {
            note = ""
        }
        self.init(id: id, name: name, data: data, note: note)
    }

    convenience init(id: UUID, taggedCBOR: Data) throws {
        guard let cbor = try CBOR.decode(taggedCBOR.bytes) else {
            throw GeneralError("ur:crypto-seed: Invalid CBOR.")
        }
        guard case let CBOR.tagged(tag, content) = cbor, tag.rawValue == 300 else {
            throw GeneralError("ur:crypto-seed: CBOR tag not seed (300).")
        }
        try self.init(id: id, cbor: content)
    }
}

extension Seed: Saveable {
    static var saveType: String = "seed"

    func save() {
        guard isDirty else { return }
        try! Keychain.update(seed: self)
        isDirty = false
        print("✅ Saved \(Date()) \(name) \(id)")
    }

    func delete() {
        try! Keychain.delete(id: id)
        print("🟥 Delete \(Date()) \(name) \(id)")
    }

    static func load(id: UUID) throws -> Seed {
        let seed = try Keychain.seed(for: id)
        print("🔵 Load \(Date()) \(seed.name) \(id)")
        return seed
    }
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
        "Seed(data: \(data.hex) name: \"\(name)\", note: \"\(note)\""
    }
}

import WolfLorem

extension Lorem {
    static func seed(count: Int = 16) -> Seed {
        Seed(name: Lorem.shortTitle(), data: Lorem.data(count))
    }

    static func seeds(_ count: Int) -> [Seed] {
        (0..<count).map { _ in seed() }
    }
}
