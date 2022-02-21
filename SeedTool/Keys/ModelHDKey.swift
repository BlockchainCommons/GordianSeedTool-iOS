//
//  ModelHDKey.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/21/21.
//

import SwiftUI
import BCFoundation
import LifeHash
import Base58Swift
import WolfBase

final class ModelHDKey: HDKeyProtocol, ModelObject {
    public let isMaster: Bool
    public let keyType: KeyType
    public let keyData: Data
    public let chainCode: Data?
    public let useInfo: UseInfo
    public let parent: DerivationPath
    public let children: DerivationPath
    public let parentFingerprint: UInt32?
    private(set) var id: UUID
    @Published var name: String
    @Published var note: String

    public init(isMaster: Bool, keyType: KeyType, keyData: Data, chainCode: Data?, useInfo: UseInfo, parent: DerivationPath?, children: DerivationPath?, parentFingerprint: UInt32?, name: String, note: String) {
        self.isMaster = isMaster
        self.keyType = keyType
        self.keyData = keyData
        self.chainCode = chainCode
        self.useInfo = useInfo
        self.parent = parent ?? .init()
        self.children = children ?? .init()
        self.parentFingerprint = parentFingerprint
        self.name = "Untitled"
        self.note = ""

        self.id = UUID()
    }
    
    var pathString: String {
        self.parent.toString(format: .letter).flanked("[", "]")
    }
    
    var subtypeString: String {
        [
            pathString,
            parentFingerprint?.hex
        ]
            .compactMap { $0 }
            .joined(separator: "-")
    }

    convenience init(_ key: HDKeyProtocol) {
        self.init(isMaster: key.isMaster, keyType: key.keyType, keyData: key.keyData, chainCode: key.chainCode, useInfo: key.useInfo, parent: key.parent, children: key.children, parentFingerprint: key.parentFingerprint, name: key.name, note: key.note)
    }
    
    var modelObjectType: ModelObjectType {
        switch keyType {
        case .private:
            return .privateHDKey
        case .public:
            return .publicHDKey
        }
    }

    convenience init(key: ModelHDKey, derivedKeyType: KeyType? = nil, isDerivable: Bool = true, parent: DerivationPath? = nil, children: DerivationPath? = nil) throws {
        try self.init(HDKey(key: key, derivedKeyType: derivedKeyType, isDerivable: isDerivable, parent: parent, children: children))
        self.name = key.name
    }
    
    convenience init(seed: ModelSeed, useInfo: UseInfo = .init(), origin: DerivationPath? = nil, children: DerivationPath? = nil) throws {
        try self.init(HDKey(seed: seed, useInfo: useInfo, parent: origin, children: children))
        self.name = "HDKey from \(seed.name)"
    }

    convenience init(parent: ModelHDKey, derivedKeyType: KeyType, childDerivationPath: DerivationPath, isDerivable: Bool = true) throws {
        try self.init(HDKey(parent: parent, derivedKeyType: derivedKeyType, childDerivationPath: childDerivationPath, isDerivable: isDerivable))
        self.name = parent.name
    }
}

extension ModelHDKey: Fingerprintable {
    var fingerprintData: Data {
        identityDigestSource
    }
}

extension ModelHDKey {
    public var transformedBase58: String? {
        transformedBase58(from: wallyExtKey)
    }

    private func transformedBase58(from key: ext_key) -> String? {
        let base58 = Wally.base58(from: key, isPrivate: keyType.isPrivate)
        return transformedVersion(of: base58)
    }

    private func transformedVersion(of base58: String?) -> String? {
        guard let base58 = base58 else {
            return nil
        }
        guard
            useInfo.asset == .btc,
            let derivation = KeyExportDerivationPreset(origin: parent, useInfo: useInfo),
            let prefix = derivation.base58Prefix(network: useInfo.network, keyType: keyType)?.serialized
        else {
            return base58
        }

        var bytes = Base58.base58CheckDecode(base58)!
        bytes[0..<prefix.count] = ArraySlice(prefix)
        return Base58.base58CheckEncode(bytes)
    }

    //
    // Produces the form:
    // [4dc13e01/48'/1'/0'/2']tpubDFNgyGvb9fXoB4yw4RcVjpuNvcrfbW5mgTewNvgcyyxyp7unnJpsBXnNorJUiSMyCTYriPXrsV8HEEE8CyyvUmA5g42fmJ8KNYC5hSXGQqG
    //
    public var transformedBase58WithOrigin: String? {
        guard let base58 = transformedBase58 else {
            return nil
        }
        var result: [String] = []
        if !parent.isEmpty {
            result.append("[\(parent.description)]")
        }
        result.append(base58)
        return result.joined()
    }
}

extension ModelHDKey {
    var subtypes: [ModelSubtype] {
        [ useInfo.asset.subtype, useInfo.network.subtype ]
    }

    var instanceDetail: String? {
        var result: [String] = []

        if !parent.isEmpty {
            result.append("[\(parent.description)]")
            result.append("➜")
        }

        result.append(keyFingerprintData.hex)

        return result.joined(separator: " ")
    }
}

extension ModelHDKey: Equatable {
    static func == (lhs: ModelHDKey, rhs: ModelHDKey) -> Bool {
        lhs.id == rhs.id
    }
}

extension ModelHDKey {
    func printPages(model: Model) -> [AnyView] {
        [
            KeyBackupPage(key: self, parentSeed: model.findParentSeed(of: self))
                .eraseToAnyView()
        ]
    }
}
