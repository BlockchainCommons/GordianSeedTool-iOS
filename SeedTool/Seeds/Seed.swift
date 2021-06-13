//
//  Seed.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/9/20.
//

import Foundation
import LifeHash
import SwiftUI
import URKit
import Combine
import BIP39
import SSKR

final class Seed: ModelObject, Orderable {
    let id: UUID
    @Published var ordinal: Ordinal {
        didSet { if oldValue != ordinal { isDirty = true }}
    }
    @Published var name: String {
        didSet { if oldValue != name { isDirty = true } }
    }
    let data: Data
    @Published var note: String {
        didSet { if oldValue != note { isDirty = true } }
    }
    @Published var creationDate: Date? {
        didSet { if oldValue != creationDate { isDirty = true } }
    }
    var isDirty: Bool = true

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
    
    lazy var creationDateValidator: ValidationPublisher = {
        $creationDate
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
        Publishers.CombineLatest3(nameValidator, noteValidator, creationDateValidator)
            .map { nameValidation, noteValidation, creationDateValidation in
                [nameValidation, noteValidation, creationDateValidation].allSatisfy {
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

    var modelObjectType: ModelObjectType { return .seed }
    
    var hasName: Bool {
        !name.isEmpty && name != "Untitled"
    }

    init(id: UUID, ordinal: Ordinal, name: String, data: Data, note: String = "", creationDate: Date? = nil) {
        self.id = id
        self.ordinal = ordinal
        self.name = name
        self.data = data
        self.note = note
        self.creationDate = creationDate
    }

    convenience init(ordinal: Ordinal = Ordinal(), name: String = "Untitled", data: Data, note: String = "") {
        self.init(id: UUID(), ordinal: ordinal, name: name, data: data, note: note, creationDate: Date())
    }

    convenience init() {
        self.init(data: SecureRandomNumberGenerator.shared.data(count: 16))
    }
}

extension Seed {
    var hex: String {
        data.hex
    }
}

extension Seed {
    func cbor(nameLimit: Int? = nil, noteLimit: Int? = nil) -> CBOR {
        var a: [OrderedMapEntry] = [
            .init(key: 1, value: CBOR.byteString(data.bytes))
        ]
        
        if let creationDate = creationDate {
            a.append(.init(key: 2, value: CBOR.date(creationDate)))
        }

        if !name.isEmpty {
            a.append(.init(key: 3, value: CBOR.utf8String(name.limited(to: nameLimit))))
        }

        if !note.isEmpty {
            a.append(.init(key: 4, value: CBOR.utf8String(note.limited(to: noteLimit))))
        }

        return CBOR.orderedMap(a)
    }

    var taggedCBOR: CBOR {
        CBOR.tagged(.seed, cbor())
    }

    var ur: UR {
        try! UR(type: "crypto-seed", cbor: cbor())
    }
    
    var sizeLimitedUR: UR {
        try! UR(type: "crypto-seed", cbor: cbor(nameLimit: 100, noteLimit: 500))
    }
    
    convenience init(id: UUID = UUID(), ordinal: Ordinal = Ordinal(), ur: UR) throws {
        guard ur.type == "crypto-seed" else {
            throw GeneralError("Unexpected UR type.")
        }
        try self.init(id: id, ordinal: ordinal, cborData: ur.cbor)
    }

    convenience init(id: UUID = UUID(), ordinal: Ordinal = Ordinal(), urString: String) throws {
        let ur = try URDecoder.decode(urString)
        try self.init(id: id, ordinal: ordinal, ur: ur)
    }

    convenience init(id: UUID, ordinal: Ordinal, cborData: Data) throws {
        guard let cbor = try CBOR.decode(cborData.bytes) else {
            throw GeneralError("ur:crypto-seed: Invalid CBOR.")
        }
        try self.init(id: id, ordinal: ordinal, cbor: cbor)
    }

    convenience init(id: UUID, ordinal: Ordinal, cbor: CBOR) throws {
        guard case let CBOR.map(pairs) = cbor else {
            throw GeneralError("ur:crypto-seed: CBOR doesn't contain a map.")
        }
        guard let dataItem = pairs[1], case let CBOR.byteString(bytes) = dataItem else {
            throw GeneralError("ur:crypto-seed: CBOR doesn't contain data field.")
        }
        let data = Data(bytes)
        
        let creationDate: Date?
        if let dateItem = pairs[2] {
            guard case let CBOR.date(d) = dateItem else {
                throw GeneralError("ur:crypto-seed: CreationDate field doesn't contain a date.")
            }
            creationDate = d
        } else {
            creationDate = nil
        }

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
        self.init(id: id, ordinal: ordinal, name: name, data: data, note: note, creationDate: creationDate)
    }

    convenience init(id: UUID, ordinal: Ordinal, taggedCBOR: Data) throws {
        guard let cbor = try CBOR.decode(taggedCBOR.bytes) else {
            throw GeneralError("ur:crypto-seed: Invalid CBOR.")
        }
        guard case let CBOR.tagged(tag, content) = cbor, tag == .seed else {
            throw GeneralError("ur:crypto-seed: CBOR tag not seed (300).")
        }
        try self.init(id: id, ordinal: ordinal, cbor: content)
    }
}

extension Seed: Saveable {
    static var saveType: String = "seed"

    func saveInKeychain() {
        guard isDirty else { return }
        try! Keychain.update(seed: self)
        isDirty = false
        print("✅ Saved in keychain \(Date()) \(name) \(id)")
    }

    func deleteFromKeychain() {
        try! Keychain.delete(id: id)
        print("🟥 Deleted from keychain \(Date()) \(name) \(id)")
    }

    static func loadFromKeychain(id: UUID) throws -> Seed {
        let seed = try Keychain.seed(for: id)
        seed.isDirty = false
        print("🔵 Loaded from keychain \(Date()) \(seed.name) \(id)")
        return seed
    }
    
    static func load(id: UUID) throws -> Self {
        let seed = try defaultLoad(id: id)
        seed.isDirty = false
        print("🔵 Loaded \(Date()) \(seed.name) \(id)")
        return seed
    }
    
    func save() {
        if isDirty {
            defaultSave()
            isDirty = false
            print("✅ Saved \(Date()) \(name) \(id)")
        }
    }
    
    func delete() {
        defaultDelete()
        print("🟥 Deleted \(Date()) \(name) \(id)")
    }

    static var ids: [UUID] {
        return filenames.compactMap { filename in
            return UUID(uuidString: filename)
        }
    }
}

extension Seed {
    var bip39: String {
        try! BIP39.encode(data)
    }
    
    convenience init(bip39: String) throws {
        try self.init(data: BIP39.decode(bip39))
    }
}

extension Seed {
    var sskr: String {
        SSKRGenerator(seed: self, model: SSKRModel()).bytewordsShares.trim()
    }

    convenience init(sskr: String) throws {
        try self.init(data: SSKRDecoder.decode(sskr))
    }
}

extension Seed {
    var byteWords: String {
        Bytewords.encode(data, style: .standard)
    }
    
    convenience init(byteWords: String) throws {
        try self.init(data: Bytewords.decode(byteWords))
    }
}

extension Seed: Codable {
    private enum CodingKeys: CodingKey {
        case id
        case ordinal
        case ur
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(ordinal, forKey: .ordinal)
        try container.encode(ur.string, forKey: .ur)
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let ordinal = try container.decode(Ordinal.self, forKey: .ordinal)
        let urString = try container.decode(String.self, forKey: .ur)
        try self.init(id: id, ordinal: ordinal, urString: urString)
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
        "Seed(ordinal: \"\(ordinal)\", data: \(data.hex) name: \"\(name)\", note: \"\(note)\""
    }
}

extension Seed {
    var pages: [AnyView] {
        [
            SeedBackupPage(seed: self)
                .eraseToAnyView()
        ]
    }
}

#if DEBUG

import WolfLorem

extension Lorem {
    static func seed(count: Int = 16) -> Seed {
        let s = Seed(name: Lorem.shortTitle(), data: Lorem.data(count), note: Lorem.sentence())
//        s.creationDate = nil
        return s
    }

    static func seeds(_ count: Int) -> [Seed] {
        (0..<count).map { _ in seed() }
    }
}

#endif
