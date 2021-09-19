//
//  HDKey.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/21/21.
//

import SwiftUI
import URKit
import LibWally
import LifeHash
import Base58Swift
import WolfBase

final class HDKey: ModelObject {
    let id: UUID
    @Published var name: String
    let isMaster: Bool
    let keyType: KeyType
    let keyData: Data
    let chainCode: Data?
    let useInfo: UseInfo
    let origin: DerivationPath?
    let children: DerivationPath?
    let parentFingerprint: UInt32?

    var modelObjectType: ModelObjectType {
        switch keyType {
        case .private:
            return .privateHDKey
        case .public:
            return .publicHDKey
        }
    }

    private init(id: UUID = UUID(), name: String, isMaster: Bool, keyType: KeyType, keyData: Data, chainCode: Data? = nil, useInfo: UseInfo, origin: DerivationPath? = nil, children: DerivationPath? = nil, parentFingerprint: UInt32? = nil)
    {
        self.id = id
        self.name = name
        self.isMaster = isMaster
        self.keyType = keyType
        self.keyData = keyData
        if let chainCode = chainCode {
            if chainCode.isAllZero {
                self.chainCode = nil
            } else {
                self.chainCode = chainCode
            }
        } else {
            self.chainCode = nil
        }
        self.useInfo = useInfo
        self.origin = origin
        self.children = children
        self.parentFingerprint = parentFingerprint
    }
    
    var isDerivable: Bool {
        chainCode != nil
    }
    
    convenience init(parent: HDKey, derivedKeyType: KeyType, isDerivable: Bool = true) throws {
        guard parent.keyType == .private || derivedKeyType == .public else {
            // public -> private
            throw GeneralError("Cannot derive private key from public key.")
        }
        
        let chainCode = isDerivable ? parent.chainCode : nil
        if parent.keyType == derivedKeyType {
            // private -> private
            // public -> public
            self.init(name: parent.name, isMaster: parent.isMaster, keyType: derivedKeyType, keyData: parent.keyData, chainCode: chainCode, useInfo: parent.useInfo, origin: parent.origin, children: parent.children, parentFingerprint: parent.parentFingerprint)
        } else {
            // private -> public
            let pubKey = Data(of: parent.wallyExtKey.pub_key)
            
            self.init(name: parent.name, isMaster: parent.isMaster, keyType: derivedKeyType, keyData: pubKey, chainCode: chainCode, useInfo: parent.useInfo, origin: parent.origin, children: parent.children, parentFingerprint: parent.parentFingerprint)
        }
    }
    
    convenience init(seed: ModelSeed, useInfo: UseInfo = .init(), origin: DerivationPath? = nil, children: DerivationPath? = nil) {
        let name = "HDKey from \(seed.name)"
        let bip39Seed = BIP39.Seed(bip39: seed.bip39)
        let key = LibWally.HDKey(bip39Seed: bip39Seed, network: useInfo.network)!
        
        let isMaster = true
        let keyType = KeyType.private
        let keyData = Data(of: key.wallyExtKey.priv_key)
        let chainCode = Data(of: key.wallyExtKey.chain_code)
        let useInfo = UseInfo(asset: useInfo.asset, network: useInfo.network)
        let parentFingerprint = origin?.sourceFingerprint
        
        self.init(name: name, isMaster: isMaster, keyType: keyType, keyData: keyData, chainCode: chainCode, useInfo: useInfo, origin: origin, children: children, parentFingerprint: parentFingerprint)
    }
    
    convenience init(parent: HDKey, derivedKeyType: KeyType, childDerivation: DerivationStep) throws {
        guard parent.keyType == .private || derivedKeyType == .public else {
            throw GeneralError("Cannot derive private key from public key.")
        }
        guard parent.isDerivable else {
            throw GeneralError("Cannot derive from a non-derivable key.")
        }
        
        let isMaster = false
        let name = parent.name

        let childNum = try childDerivation.childNum()
        guard let derivedKey = Wally.key(from: parent.wallyExtKey, childNum: childNum, isPrivate: derivedKeyType.isPrivate) else {
            throw GeneralError("Cannot derive key.")
        }

        let keyData = derivedKeyType == .private ? Data(of: derivedKey.priv_key) : Data(of: derivedKey.pub_key)
        let chainCode = Data(of: derivedKey.chain_code)
        let useInfo = parent.useInfo

        let parentFingerprint = parent.keyFingerprint
        let origin: DerivationPath
        if let parentOrigin = parent.origin {
            var steps = parentOrigin.steps
            steps.append(childDerivation)
            let sourceFingerprint = parentOrigin.sourceFingerprint ?? parentFingerprint
            let depth: UInt8
            if let parentDepth = parentOrigin.depth {
                depth = parentDepth + 1
            } else {
                depth = 1
            }
            origin = DerivationPath(steps: steps, sourceFingerprint: sourceFingerprint, depth: depth)
        } else {
            origin = DerivationPath(steps: [childDerivation], sourceFingerprint: parentFingerprint, depth: 1)
        }
        
        let children: DerivationPath? = nil

        self.init(name: name, isMaster: isMaster, keyType: derivedKeyType, keyData: keyData, chainCode: chainCode, useInfo: useInfo, origin: origin, children: children, parentFingerprint: parentFingerprint)
    }
    
    convenience init(parent: HDKey, derivedKeyType: KeyType, childDerivationPath: DerivationPath, isDerivable: Bool = true) throws {
        var key = parent
        for step in childDerivationPath.steps {
            key = try HDKey(parent: key, derivedKeyType: parent.keyType, childDerivation: step)
        }
        try self.init(parent: key, derivedKeyType: derivedKeyType, isDerivable: isDerivable)
    }
    
    var keyFingerprintData: Data {
        Wally.fingerprintData(for: wallyExtKey)
    }

    var keyFingerprint: UInt32 {
        Wally.fingerprint(for: wallyExtKey)
    }
    
    var wallyHDKey: LibWally.HDKey {
        LibWally.HDKey(key: wallyExtKey, parent: origin?.wallyDerivationPath ?? .init(), children: children?.wallyDerivationPath ?? .init())
//        .init(key: wallyExtKey)
    }
    
    private func base58(from key: ext_key) -> String? {
        let base58 = Wally.base58(from: key, isPrivate: keyType.isPrivate)
        return transformVersion(of: base58)
    }
    
    var base58: String? {
        base58(from: wallyExtKey)
    }
    
    private func transformVersion(of base58: String?) -> String? {
        guard let base58 = base58 else {
            return nil
        }
        guard
            useInfo.asset == .btc,
            let origin = origin,
            let derivation = KeyExportDerivationPreset(origin: origin, useInfo: useInfo),
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
    var base58WithOrigin: String? {
        guard let base58 = base58 else {
            return nil
        }
        var result: [String] = []
        if let originDescription = origin?.description {
            result.append("[\(originDescription)]")
        }
        result.append(base58)
        return result.joined()
    }

    var wallyExtKey: ext_key {
        var k = ext_key()
        
        if let origin = origin {
            k.depth = origin.effectiveDepth

            if let lastStep = origin.steps.last,
               case let ChildIndexSpec.index(childIndex) = lastStep.childIndexSpec {
                let value = childIndex.value
                let isHardened = lastStep.isHardened
                let childNum = value | (isHardened ? 0x80000000 : 0)
                k.child_num = childNum
            }
        }
        
        switch keyType {
        case .private:
            keyData.store(into: &k.priv_key)
            Wally.updatePublicKey(in: &k)
            switch useInfo.network {
            case .mainnet:
                k.version = UInt32(BIP32_VER_MAIN_PRIVATE)
            case .testnet:
                k.version = UInt32(BIP32_VER_TEST_PRIVATE)
            @unknown default:
                fatalError()
            }
        case .public:
            k.priv_key.0 = 0x01;
            keyData.store(into: &k.pub_key)
            switch useInfo.network {
            case .mainnet:
                k.version = UInt32(BIP32_VER_MAIN_PUBLIC)
            case .testnet:
                k.version = UInt32(BIP32_VER_TEST_PUBLIC)
            @unknown default:
                fatalError()
            }
        }
        
        Wally.updateHash160(in: &k)
        
        if let chainCode = chainCode {
            chainCode.store(into: &k.chain_code)
        }
        
        if let parentFingerprint = parentFingerprint {
            parentFingerprint.serialized.store(into: &k.parent160)
        }
        
        k.checkValid()
        return k
    }
}

extension HDKey {
    var subtypes: [ModelSubtype] {
        [ useInfo.asset.subtype, useInfo.network.subtype ]
    }
    
    var instanceDetail: String? {
        var result: [String] = []
        
        if let origin = origin {
            result.append("[\(origin.description)]")
            result.append("➜")
        }

        result.append(keyFingerprintData.hex)

        return result.joined(separator: " ")
    }
}

extension HDKey: Equatable {
    static func == (lhs: HDKey, rhs: HDKey) -> Bool {
        lhs.id == rhs.id
    }
}

extension HDKey {
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
        
        if let origin = origin {
            a.append(.init(key: 6, value: origin.taggedCBOR))
        }
        
        if let children = children {
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
        
        self.init(name: "", isMaster: isMaster, keyType: keyType, keyData: keyData, chainCode: chainCode, useInfo: useInfo, origin: origin, children: children, parentFingerprint: parentFingerprint)
    }
    
    convenience init(taggedCBOR: CBOR) throws {
        guard case let CBOR.tagged(.hdKey, cbor) = taggedCBOR else {
            throw GeneralError("HDKey tag (303) not found.")
        }
        try self.init(cbor: cbor)
    }
}

extension HDKey: Fingerprintable {
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

extension HDKey {
    func printPages(model: Model) -> [AnyView] {
        [
            KeyBackupPage(key: self, parentSeed: model.findParentSeed(of: self))
                .eraseToAnyView()
        ]
    }
}
