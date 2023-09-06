//
//  Seed.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/9/20.
//

import Foundation
import SwiftUI
import Combine
import WolfOrdinal
import os
import WolfBase
import QRCodeGenerator
import URKit
import BCApp

fileprivate let logger = Logger(subsystem: Application.bundleIdentifier, category: "ModelSeed")

let appNameLimit = 200
let appNoteLimit = 1000

final class ModelSeed: SeedProtocol, ModelObject, Printable, CustomStringConvertible {
    static var cborTag: Tag = .seed
    
    init?(data: DataProvider, name: String, note: String, creationDate: Date?, attachments: [Envelope], outputDescriptor: OutputDescriptor?) {
        let data = data.providedData
        guard data.count <= 32 else {
            return nil
        }
        self.id = UUID()
        self.ordinal = Ordinal()
        self.data = data
        self.name = name
        self.note = note
        self.creationDate = creationDate
        self.attachments = attachments
        self.outputDescriptor = outputDescriptor
    }
    
    var exportFields: ExportFields {
        exportFields(placeholder: envelope.urString, format: "Envelope")
    }
    
    var printExportFields: ExportFields {
        exportFields()
    }
    
    func exportFields(placeholder: String? = nil, format: String? = nil) -> ExportFields {
        var fields: ExportFields = [
            .id: digestIdentifier,
            .type: typeString
        ]
        if let placeholder = placeholder {
            fields[.placeholder] = placeholder
            fields[.format] = format
        }
        return fields
    }
    
    var envelopeActivityParams: ActivityParams {
        ActivityParams(
            envelope.urString,
            name: name,
            fields: exportFields
        )
    }
    
    var envelopeFormatActivityParams: ActivityParams {
        ActivityParams(envelope.format(context: globalFormatContext), name: name)
    }
    
    private var outputDescriptorName: String {
        guard let outputDescriptor else {
            fatalError()
        }
        if outputDescriptor.name.isEmpty {
            return "Output Descriptor for \(self.name)"
        } else {
            return outputDescriptor.name
        }
    }
    
    var envelopeOutputDescriptorActivityParams: ActivityParams {
        guard let outputDescriptor else {
            fatalError()
        }
        return ActivityParams(
            outputDescriptor.envelope.urString,
            name: outputDescriptorName
        )
    }
    
    var textOutputDescriptorActivityParams: ActivityParams {
        guard let outputDescriptor else {
            fatalError()
        }
        return ActivityParams(
            outputDescriptor.sourceWithChecksum,
            name: outputDescriptorName
        )
    }
    
    var byteWordsActivityParams: ActivityParams {
        ActivityParams(
            byteWords,
            name: name,
            fields: exportFields(placeholder: byteWords, format: "ByteWords")
        )
    }
    
    var bip39ActivityParams: ActivityParams {
        ActivityParams(
            bip39.mnemonic,
            name: name,
            fields: exportFields(placeholder: bip39.mnemonic, format: "BIP39")
        )
    }
    
    var hexActivityParams: ActivityParams {
        ActivityParams(
            hex,
            name: name,
            fields: exportFields(placeholder: hex, format: "Hex")
        )
    }
    
    var sizeLimitedEnvelope: (Envelope, Bool) {
        sizeLimitedEnvelope(nameLimit: appNameLimit, noteLimit: appNoteLimit)
    }

    convenience init(_ seed: any SeedProtocol) {
        self.init(data: seed.data, name: seed.name, note: seed.note, creationDate: seed.creationDate, attachments: seed.attachments, outputDescriptor: seed.outputDescriptor)!
    }
    
    convenience init?(data: DataProvider) {
        self.init(data: data, name: "", note: "", creationDate: nil, attachments: [], outputDescriptor: nil)
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
    @Published var attachments: [Envelope] {
        didSet {
            let oldDigests = oldValue.map { $0.digest }
            let newDigests = attachments.map { $0.digest }
            if oldDigests != newDigests { isDirty = true }
        }
    }
    @Published var outputDescriptor: OutputDescriptor? {
        didSet {
            if oldValue != outputDescriptor {
                isDirty = true
            }
        }
    }
    var isDirty: Bool = true {
        didSet {
            _staticQRInfo = nil
            _dynamicQRInfo = nil
        }
    }
    
    enum StaticQRInfo {
        case fits((info: QRCode.Info, didLimit: Bool))
        case doesntFit((usedBits: Int, capacityBits: Int))
    }
    
    enum DynamicQRInfo {
        case singlePart((info: QRCode.Info, messageLen: Int, maxFragmentLen: Int))
        case multiPart((info: QRCode.Info, seqLen: Int))
    }
    
    private var _staticQRInfo: StaticQRInfo?
    private var _dynamicQRInfo: DynamicQRInfo?
    
    var staticQRInfo: StaticQRInfo {
        if _staticQRInfo == nil {
            do {
                let (qrString, didLimit) = sizeLimitedQRString
                _staticQRInfo = try .fits((QRCode.getInfo(text: qrString), didLimit))
            } catch QRError.dataTooLong(let usedBits, let capacityBits) {
                _staticQRInfo = .doesntFit((usedBits, capacityBits))
            } catch {
                // Should never happen
                fatalError()
            }
        }
        return _staticQRInfo!
    }
    
    var dynamicQRInfo: DynamicQRInfo {
        if _dynamicQRInfo == nil {
            let encoder = UREncoder(ur, maxFragmentLen: Application.maxFragmentLen)
            if encoder.isSinglePart {
                let info = try! QRCode.getInfo(text: urString.uppercased())
                _dynamicQRInfo = .singlePart((info, encoder.messageLen, encoder.maxFragmentLen))
            } else {
                let part = encoder.nextPart()
                let info = try! QRCode.getInfo(text: part)
                _dynamicQRInfo = .multiPart((info, encoder.seqLen))
            }
        }
        return _dynamicQRInfo!
    }

    private var bag: Set<AnyCancellable> = []

    lazy var nameValidator: ValidationPublisher = {
        $name
            .debounceField()
            .validateNotEmpty("Name may not be empty.")
    }()

    lazy var noteValidator: ValidationPublisher = {
        $note
            .debounceField()
            .validate()
    }()
    
    lazy var creationDateValidator: ValidationPublisher = {
        $creationDate
            .debounceField()
            .validate()
    }()
    
    lazy var outputDescriptorValidator: ValidationPublisher = {
        $outputDescriptor
            .debounceField()
            .validate()
    }()

    lazy var isValidPublisher: some Publisher<Bool, Never> = {
        nameValidator.map { validation in
            switch validation {
            case .valid:
                return true
            case .invalid:
                return false
            }
        }
    }()

    lazy var needsSavePublisher: AnyPublisher<Void, Never> = {
        Publishers.CombineLatest4(nameValidator, noteValidator, creationDateValidator, outputDescriptorValidator)
            .map { nameValidation, noteValidation, creationDateValidation, outputDescriptorValidation in
                [nameValidation, noteValidation, creationDateValidation, outputDescriptorValidation].allSatisfy {
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
    
    var instanceDetail: String? {
        masterKey.public.keyFingerprintData.hex.flanked("[", "]")
    }
    
    var instanceDetailFingerprintable: Fingerprintable? {
        masterKey.public.keyFingerprintData
    }

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
    
    static func load(id: UUID) throws -> Self {
        let seed = try localLoad(id: id)
        seed.isDirty = false
        //logger.debug("🔵 Loaded \(seed.name) \(id)")
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
        logger.debug("✅ Saved \(self.name) \(self.id)")
        if replicateToCloud {
            cloudSave(model: model)
            logger.debug("✅☁️ Saved \(self.name) \(self.id)")
        }
        isDirty = false
    }
    
    func delete(model: Model, replicateToCloud: Bool) {
        localDelete()
        logger.debug("🟥 Deleted \(self.name) \(self.id)")
        if replicateToCloud {
            cloudDelete(model: model)
            logger.debug("🟥☁️ Deleted \(self.name) \(self.id)")
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
        let secret = try SSKRDecoder.decode(sskr)

        let envelopeShares = sskr
            .split(separator: "\n")
            .map { String($0) }
            .map { $0.trim() }
            .filter { !$0.isEmpty }
            .compactMap { try? Envelope(urString: $0) }
        
        if !envelopeShares.isEmpty {
            let result = try Envelope(shares: envelopeShares).unwrap()
            try self.init(envelope: result)
        } else {
            self.init(data: secret)!
        }
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
        try container.encode(envelope.urString, forKey: .ur)
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let ordinal = try container.decode(Ordinal.self, forKey: .ordinal)
        let urString = try container.decode(String.self, forKey: .ur)
        let ur = try UR(urString: urString)

        let seed: Seed
        switch ur.type {
        case "crypto-seed":
            seed = try Seed(ur: ur)
        case "envelope":
            let envelope = try Envelope(ur: ur)
            seed = try Seed(envelope: envelope)
        default:
            throw URError.unexpectedType
        }
        self.init(seed)
        self.id = id
        self.ordinal = ordinal
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
    var printPages: [AnyView] {
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
        let s = ModelSeed(name: Lorem.shortTitle(), data: Lorem.data(count), note: Lorem.sentences(2))
//        s.creationDate = nil
        return s
    }

    static func seeds(_ count: Int) -> [ModelSeed] {
        (0..<count).map { _ in seed() }
    }
}

#endif
