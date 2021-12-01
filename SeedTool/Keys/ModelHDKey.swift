//
//  ModelHDKey.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/21/21.
//

import SwiftUI
import URKit
import BCFoundation
import LifeHash
import Base58Swift
import WolfBase

final class ModelHDKey: HDKey, ModelObject {
    private(set) var id: UUID
    @Published var name: String

    private override init(_ key: HDKey) {
        id = UUID()
        name = "Untitled"
        super.init(key)
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
    var cbor: CBOR {
        var a: [OrderedMapEntry] = []

        if isMaster {
            a.append(.init(key: 1, value: true))
        }

        if keyType == .private {
            a.append(.init(key: 2, value: true))
        }

        a.append(.init(key: 3, value: CBOR.byteString(keyData.bytes)))

        if let chainCode = chainCode {
            a.append(.init(key: 4, value: CBOR.byteString(chainCode.bytes)))
        }

        if !useInfo.isDefault {
            a.append(.init(key: 5, value: useInfo.taggedCBOR))
        }

        if !parent.isEmpty {
            a.append(.init(key: 6, value: parent.taggedCBOR))
        }

        if !children.isEmpty {
            a.append(.init(key: 7, value: children.taggedCBOR))
        }

        if let parentFingerprint = parentFingerprint {
            a.append(.init(key: 8, value: CBOR.unsignedInt(UInt64(parentFingerprint))))
        }

        return CBOR.orderedMap(a)
    }

    var taggedCBOR: CBOR {
        CBOR.tagged(.hdKey, cbor)
    }

    var ur: UR {
        return try! UR(type: "crypto-hdkey", cbor: cbor)
    }

    var sizeLimitedUR: UR {
        return ur
    }

    convenience init(cbor: CBOR) throws {
        guard case let CBOR.map(pairs) = cbor
        else {
            throw GeneralError("HDKey: Doesn't contain a map.")
        }

        guard case let CBOR.boolean(isMaster) = pairs[1] ?? CBOR.boolean(false)
        else {
            throw GeneralError("HDKey: Invalid `isMaster` field.")
        }

        guard case let CBOR.boolean(isPrivate) = pairs[2] ?? CBOR.boolean(isMaster)
        else {
            throw GeneralError("HDKey: Invalid `isPrivate` field.")
        }
        if isMaster && !isPrivate {
            throw GeneralError("HDKey: Master key cannot be public.")
        }

        guard
            case let CBOR.byteString(keyDataValue) = pairs[3] ?? CBOR.null,
            keyDataValue.count == 33
        else {
            throw GeneralError("HDKey: Invalid key data.")
        }
        let keyData = Data(keyDataValue)

        let chainCode: Data?
        if let chainCodeItem = pairs[4] {
            guard
                case let CBOR.byteString(chainCodeValue) = chainCodeItem,
                chainCodeValue.count == 32
            else {
                throw GeneralError("HDKey: Invalid key chain code.")
            }
            chainCode = Data(chainCodeValue)
        } else {
            chainCode = nil
        }

        let useInfo: UseInfo
        if let useInfoItem = pairs[5] {
            useInfo = try UseInfo(taggedCBOR: useInfoItem)
        } else {
            useInfo = UseInfo()
        }

        let origin: DerivationPath?
        if let originItem = pairs[6] {
            origin = try DerivationPath(taggedCBOR: originItem)
        } else {
            origin = nil
        }

        let children: DerivationPath?
        if let childrenItem = pairs[7] {
            children = try DerivationPath(taggedCBOR: childrenItem)
        } else {
            children = nil
        }

        let parentFingerprint: UInt32?
        if let parentFingerprintItem = pairs[8] {
            guard
                case let CBOR.unsignedInt(parentFingerprintValue) = parentFingerprintItem,
                parentFingerprintValue > 0,
                parentFingerprintValue <= UInt32.max
            else {
                throw GeneralError("HDKey: Invalid parent fingerprint.")
            }
            parentFingerprint = UInt32(parentFingerprintValue)
        } else {
            parentFingerprint = nil
        }

        let keyType: KeyType = isPrivate ? .private : .public

        self.init(HDKey(isMaster: isMaster, keyType: keyType, keyData: keyData, chainCode: chainCode, useInfo: useInfo, parent: origin, children: children, parentFingerprint: parentFingerprint))
    }

    convenience init(taggedCBOR: CBOR) throws {
        guard case let CBOR.tagged(.hdKey, cbor) = taggedCBOR else {
            throw GeneralError("HDKey tag (303) not found.")
        }
        try self.init(cbor: cbor)
    }
}

extension ModelHDKey: Fingerprintable {
    var fingerprintData: Data {
        var result: [CBOR] = []

        result.append(CBOR.byteString(keyData.bytes))

        if let chainCode = chainCode {
            result.append(CBOR.byteString(chainCode.bytes))
        } else {
            result.append(CBOR.null)
        }

        result.append(CBOR.unsignedInt(UInt64(useInfo.asset.rawValue)))
        result.append(CBOR.unsignedInt(UInt64(useInfo.network.rawValue)))

        return Data(result.encode())
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
