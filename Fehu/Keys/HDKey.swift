//
//  HDKey.swift
//  Guardian
//
//  Created by Wolf McNally on 1/21/21.
//

import SwiftUI
import URKit
import LibWally
import LifeHash

final class HDKey: ModelObject {
    let id: UUID
    @Published var name: String
    let isMaster: Bool
    let keyType: KeyType
    let keyData: Data
    let chainCode: Data?
    let useInfo: UseInfo?
    let origin: DerivationPath?
    let children: DerivationPath?
    let parentFingerprint: UInt32?

    var modelObjectType: ModelObjectType {
        switch keyType {
        case .private:
            return .privateKey
        case .public:
            return .publicKey
        }
    }

    private init(id: UUID = UUID(), name: String = "Untitled", isMaster: Bool, keyType: KeyType, keyData: Data, chainCode: Data? = nil, useInfo: UseInfo? = nil, origin: DerivationPath? = nil, children: DerivationPath? = nil, parentFingerprint: UInt32? = nil)
    {
        self.id = id
        self.name = name
        self.isMaster = isMaster
        self.keyType = keyType
        self.keyData = keyData
        self.chainCode = chainCode
        self.useInfo = useInfo
        self.origin = origin
        self.children = children
        self.parentFingerprint = parentFingerprint
    }
    
    convenience init(parent: HDKey, derivedKeyType: KeyType) throws {
        guard parent.keyType == .private || derivedKeyType == .public else {
            // public -> private
            throw GeneralError("Cannot derive private key from public key.")
        }
        
        if parent.keyType == derivedKeyType {
            // private -> private
            // public -> public
            self.init(name: parent.name, isMaster: parent.isMaster, keyType: derivedKeyType, keyData: parent.keyData, chainCode: parent.chainCode, useInfo: parent.useInfo, origin: parent.origin, children: parent.children, parentFingerprint: parent.parentFingerprint)
        } else {
            // private -> public
            let pubKey = Data(of: parent.wallyExtKey.pub_key)
            
            self.init(name: parent.name, isMaster: parent.isMaster, keyType: derivedKeyType, keyData: pubKey, chainCode: parent.chainCode, useInfo: parent.useInfo, origin: parent.origin, children: parent.children, parentFingerprint: parent.parentFingerprint)
        }
    }
    
    convenience init(seed: Seed, asset: Asset = .btc, network: Network = .mainnet) {
        let bip39 = seed.bip39
        let mnemonic = try! BIP39Mnemonic(words: bip39)
        let bip32Seed = mnemonic.seedHex()
        let key = try! LibWally.HDKey(seed: bip32Seed, network: network.wallyNetwork)
        
        let isMaster = true
        let keyType = KeyType.private
        let keyData = Data(of: key.wally_ext_key.priv_key)
        let chainCode = Data(of: key.wally_ext_key.chain_code)
        let useInfo = UseInfo(asset: asset, network: network)
        let origin: DerivationPath? = nil
        let children: DerivationPath? = nil
        let parentFingerprint: UInt32? = nil
        
        self.init(isMaster: isMaster, keyType: keyType, keyData: keyData, chainCode: chainCode, useInfo: useInfo, origin: origin, children: children, parentFingerprint: parentFingerprint)
    }
    
    convenience init(parent: HDKey, derivedKeyType: KeyType, childDerivation: PathComponent) throws {
        guard parent.keyType == .private || derivedKeyType == .public else {
            throw GeneralError("Cannot derive private key from public key.")
        }
        
        let isMaster = false

        var key = parent.wallyExtKey
        let childNum = try childDerivation.childNum()
        let flags: UInt32 = UInt32(derivedKeyType == .private ? BIP32_FLAG_KEY_PRIVATE : BIP32_FLAG_KEY_PUBLIC)
        var output = ext_key()
        guard bip32_key_from_parent(&key, childNum, flags, &output) == WALLY_OK else {
            throw GeneralError("Unknown problem deriving HDKey.")
        }

        let keyData = derivedKeyType == .private ? Data(of: output.priv_key) : Data(of: output.pub_key)
        let chainCode = Data(of: output.chain_code)
        let useInfo = parent.useInfo

        let parentFingerprint = parent.keyFingerprint

        let origin: DerivationPath
        if let parentOrigin = parent.origin {
            var components = parentOrigin.components
            components.append(childDerivation)
            let sourceFingerprint = parentOrigin.sourceFingerprint ?? parentFingerprint
            let depth: UInt8
            if let parentDepth = parentOrigin.depth {
                depth = parentDepth + 1
            } else {
                depth = 0
            }
            origin = DerivationPath(components: components, sourceFingerprint: sourceFingerprint, depth: depth)
        } else {
            origin = DerivationPath(components: [childDerivation], sourceFingerprint: parentFingerprint, depth: 0)
        }
        
        let children: DerivationPath? = nil

        self.init(isMaster: isMaster, keyType: derivedKeyType, keyData: keyData, chainCode: chainCode, useInfo: useInfo, origin: origin, children: children, parentFingerprint: parentFingerprint)
    }
    
    convenience init(parent: HDKey, derivedKeyType: KeyType, childDerivationPath: DerivationPath) throws {
        var key = parent
        for component in childDerivationPath.components {
            key = try HDKey(parent: key, derivedKeyType: derivedKeyType, childDerivation: component)
        }
        try self.init(parent: key, derivedKeyType: derivedKeyType)
    }
    
    private var keyFingerprint: UInt32 {
        var hdkey = wallyExtKey
        var fingerprint_bytes = [UInt8](repeating: 0, count: Int(BIP32_KEY_FINGERPRINT_LEN))
        precondition(bip32_key_get_fingerprint(&hdkey, &fingerprint_bytes, fingerprint_bytes.count) == WALLY_OK)
        return withUnsafeBytes(of: fingerprint_bytes) {
            $0.bindMemory(to: UInt32.self).baseAddress!.pointee.bigEndian
        }
    }

    private var wallyExtKey: ext_key {
        var k = ext_key()
        
        switch keyType {
        case .private:
            keyData.store(into: &k.priv_key)
            withUnsafeByteBuffer(of: k.priv_key) { priv_key in
                withUnsafeMutableByteBuffer(of: &k.pub_key) { pub_key in
                    assert(wally_ec_public_key_from_private_key(priv_key.baseAddress! + 1, Int(EC_PRIVATE_KEY_LEN), pub_key.baseAddress!, Int(EC_PUBLIC_KEY_LEN)) == WALLY_OK)
                }
            }
        case .public:
            k.priv_key.0 = 0x01;
            keyData.store(into: &k.pub_key)
        }
        
        if let chainCode = chainCode {
            chainCode.store(into: &k.chain_code)
        }
        
        return k
    }
}

extension HDKey {
    var subtypes: [ModelSubtype] {
        [
            useInfo?.asset?.subtype,
            useInfo?.network?.subtype
        ].compactMap { $0 }
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
        
        if let useInfo = useInfo {
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
        CBOR.tagged(.init(rawValue: 303), cbor)
    }

    var ur: UR {
        return try! UR(type: "crypto-hdkey", cbor: cbor)
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

        let useInfo: UseInfo?
        if let useInfoItem = pairs[5] {
            useInfo = try UseInfo(taggedCBOR: useInfoItem)
        } else {
            useInfo = nil
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
        
        self.init(isMaster: isMaster, keyType: keyType, keyData: keyData, chainCode: chainCode, useInfo: useInfo, origin: origin, children: children, parentFingerprint: parentFingerprint)
    }
    
    convenience init(taggedCBOR: CBOR) throws {
        guard case let CBOR.tagged(.init(rawValue: 303), cbor) = taggedCBOR else {
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

        if let asset = useInfo?.asset {
            result.append(CBOR.unsignedInt(UInt64(asset.rawValue)))
        } else {
            result.append(CBOR.null)
        }
        
        if let network = useInfo?.network {
            result.append(CBOR.unsignedInt(UInt64(network.rawValue)))
        } else {
            result.append(CBOR.null)
        }
        
        return Data(result.encode())
    }
}
