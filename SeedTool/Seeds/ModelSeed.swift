//
//  Seed.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/9/20.
//

import Foundation
import LifeHash
import SwiftUI
import Combine
import WolfOrdinal
import BCFoundation

final class ModelSeed: SeedProtocol, ModelObject, CustomStringConvertible {
    
    init?(data: Data, name: String, note: String, creationDate: Date?) {
        guard data.count <= 32 else {
            return nil
        }
        self.id = UUID()
        self.ordinal = Ordinal()
        self.data = data
        self.name = name
        self.note = note
        self.creationDate = creationDate
    }

    convenience init(_ seed: SeedProtocol) {
        self.init(data: seed.data, name: seed.name, note: seed.note, creationDate: seed.creationDate)!
    }
    
    convenience init?(data: Data) {
        self.init(data: data, name: "", note: "", creationDate: nil)
    }

    private(set) var id: UUID
    let data: Data
    @Published var ordinal: Ordinal {
        didSet { if oldValue != ordinal { isDirty = true } }
    }
    @Published var name: String {
        didSet { if oldValue != name { isDirty = true } }
    }
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
            .dropFirst()
            .eraseToAnyPublisher()
    }()

    var modelObjectType: ModelObjectType { return .seed }
    
    var hasName: Bool {
        !name.isEmpty && name != "Untitled"
    }

    convenience init(id: UUID, ordinal: Ordinal, name: String, data: Data, note: String = "", creationDate: Date? = nil) {
        self.init(Seed(data: data, name: name, note: note, creationDate: creationDate)!)
        self.id = id
        self.ordinal = ordinal
    }

    convenience init(ordinal: Ordinal = Ordinal(), name: String = "Untitled", data: Data, note: String = "") {
        self.init(Seed(data: data, name: name, note: note, creationDate: Date())!)
        self.id = UUID()
        self.ordinal = ordinal
    }
    
    convenience init(mnemonic: String) throws {
        guard let seed = Seed(mnemonic: mnemonic) else {
            throw GeneralError("Invalid BIP39 words.")
        }
        self.init(seed)
    }

    convenience init() {
        self.init(data: SecureRandomNumberGenerator.shared.data(count: 16))!
    }

    var description: String {
        "ModelSeed(id: \(id), ordinal: \"\(ordinal)\", name: \"\(name)\", note: \"\(note)\", creationDate: \(String(describing: creationDate))"
    }
}

extension ModelSeed {
    convenience init(id: UUID, ordinal: Ordinal = Ordinal(), urString: String) throws {
        try self.init(urString: urString)
        self.id = id
        self.ordinal = ordinal
    }
}

extension ModelSeed: Saveable {
    static var saveType: String = "seed"

    func keychainSave() {
        guard isDirty else { return }
        try! Keychain.update(seed: self)
        isDirty = false
        print("✅ Saved in keychain \(name) \(id)")
    }

    func keychainDelete() {
        try! Keychain.delete(id: id)
        print("🟥 Deleted from keychain \(name) \(id)")
    }

    static func keychainLoad(id: UUID) throws -> ModelSeed {
        let seed = try Keychain.seed(for: id)
        seed.isDirty = false
        //print("🔵 Loaded from keychain \(seed.name) \(id)")
        return seed
    }
    
    static func load(id: UUID) throws -> Self {
        let seed = try localLoad(id: id)
        seed.isDirty = false
        //print("🔵 Loaded \(seed.name) \(id)")
        return seed
    }
    
    func cloudSave(model: Model) {
        model.cloud?.save(type: "Seed", id: id, object: self) { _ in
        }
    }
    
    func cloudDelete(model: Model) {
        model.cloud?.delete(id: id)
    }
    
    func save(model: Model, replicateToCloud: Bool) {
        guard isDirty else { return }
        localSave()
        print("✅ Saved \(name) \(id)")
        if replicateToCloud {
            cloudSave(model: model)
            print("✅☁️ Saved \(name) \(id)")
        }
        isDirty = false
    }
    
    func delete(model: Model, replicateToCloud: Bool) {
        localDelete()
        print("🟥 Deleted \(name) \(id)")
        if replicateToCloud {
            cloudDelete(model: model)
            print("🟥☁️ Deleted \(name) \(id)")
        }
        isDirty = false
    }

    static var ids: [UUID] {
        return filenames.compactMap { filename in
            return UUID(uuidString: filename)
        }
    }
}

extension ModelSeed {
    var sskr: String {
        SSKRGenerator(seed: self, sskrModel: SSKRModel()).bytewordsShares.trim()
    }

    convenience init(sskr: String) throws {
        try self.init(data: SSKRDecoder.decode(sskr))!
    }
}

extension ModelSeed {
    var byteWords: String {
        Bytewords.encode(data, style: .standard)
    }
    
    convenience init(byteWords: String) throws {
        try self.init(data: Bytewords.decode(byteWords))!
    }
}

extension ModelSeed: Codable {
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

extension ModelSeed: Fingerprintable {
    var fingerprintData: Data {
        identityDigestSource
    }
}

extension ModelSeed: Equatable {
    static func == (lhs: ModelSeed, rhs: ModelSeed) -> Bool {
        lhs.id == rhs.id
    }
}

extension ModelSeed: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ModelSeed {
    func printPages(model: Model) -> [AnyView] {
        [
            SeedBackupPage(seed: self)
                .eraseToAnyView()
        ]
    }
}

extension ModelSeed: PSBTSigner {
    var masterKey: HDKey {
        try! HDKey(bip39Seed: BIP39.Seed(bip39: bip39))
    }
}

extension Array where Element: ModelSeed {
    mutating func sortByOrdinal() {
        sort { a, b in
            if a.ordinal == b.ordinal {
                return a.id.uuidString < b.id.uuidString
            } else {
                return a.ordinal < b.ordinal
            }
        }
    }
}

#if DEBUG

import WolfLorem

extension Lorem {
    static func seed(count: Int = 16) -> ModelSeed {
        let s = ModelSeed(name: Lorem.shortTitle(), data: Lorem.data(count), note: Lorem.sentence())
//        s.creationDate = nil
        return s
    }

    static func seeds(_ count: Int) -> [ModelSeed] {
        (0..<count).map { _ in seed() }
    }
}

#endif
