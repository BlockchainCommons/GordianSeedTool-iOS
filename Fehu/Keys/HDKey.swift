//
//  HDKey.swift
//  Guardian
//
//  Created by Wolf McNally on 1/21/21.
//

import Foundation
import URKit
import LibWally

struct HDKey {
    let isMaster: Bool
    let isPrivate: Bool
    let keyData: Data
    let chainCode: Data?
    let useInfo: CoinInfo?
    let origin: DerivationPath?
    let children: DerivationPath?
    let parentFingerprint: UInt32?
    
    init(isMaster: Bool, isPrivate: Bool, keyData: Data, chainCode: Data? = nil, useInfo: CoinInfo? = nil, origin: DerivationPath? = nil, children: DerivationPath? = nil, parentFingerprint: UInt32? = nil) {
        self.isMaster = isMaster
        self.isPrivate = isPrivate
        self.keyData = keyData
        self.chainCode = chainCode
        self.useInfo = useInfo
        self.origin = origin
        self.children = children
        self.parentFingerprint = parentFingerprint
    }
    
    init(other: HDKey) {
        self.init(isMaster: other.isMaster, isPrivate: other.isPrivate, keyData: other.keyData, chainCode: other.chainCode, useInfo: other.useInfo, origin: other.origin, children: other.children, parentFingerprint: other.parentFingerprint)
    }
    
    init(seed: Seed, coinType: CoinType = .btc, network: Network = .mainnet) {
        let bip39 = seed.bip39
        let mnemonic = try! BIP39Mnemonic(words: bip39)
        let bip32Seed = mnemonic.seedHex()
        let key = try! LibWally.HDKey(seed: bip32Seed, network: network.wallyNetwork)
        
        let isMaster = true
        let isPrivate = true
        let keyData = withUnsafePointer(to: key.wally_ext_key.priv_key) { Data(bytes: $0, count: 33) }
        let chainCode = withUnsafePointer(to: key.wally_ext_key.chain_code) { Data(bytes: $0, count: 32) }
        let useInfo = CoinInfo(type: coinType, network: network)
        let origin: DerivationPath? = nil
        let children: DerivationPath? = nil
        let parentFingerprint: UInt32? = nil
        
        self.init(isMaster: isMaster, isPrivate: isPrivate, keyData: keyData, chainCode: chainCode, useInfo: useInfo, origin: origin, children: children, parentFingerprint: parentFingerprint)
    }
    
    init(parent: HDKey, isChildPrivate: Bool, childDerivation: PathComponent) throws {
        guard parent.isPrivate || isChildPrivate == false else {
            throw GeneralError("Cannot derive private key from public key.")
        }
        
        var key = parent.wallyExtKey
        let childNum = try childDerivation.childNum()
        let flags = UInt32(isChildPrivate ? BIP32_FLAG_KEY_PRIVATE : BIP32_FLAG_KEY_PUBLIC)
        var output = ext_key()
        guard bip32_key_from_parent(&key, childNum, flags, &output) == WALLY_OK else {
            throw GeneralError("Unknown problem deriving HDKey.")
        }

        let isMaster = false
        let isPrivate = isChildPrivate
        let keyData = withUnsafePointer(to: isChildPrivate ? output.priv_key : output.pub_key) { Data(bytes: $0, count: 33) }
        let chainCode = withUnsafePointer(to: output.chain_code) { Data(bytes: $0, count: 32) }
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

        self.init(isMaster: isMaster, isPrivate: isPrivate, keyData: keyData, chainCode: chainCode, useInfo: useInfo, origin: origin, children: children, parentFingerprint: parentFingerprint)
    }
    
    init(parent: HDKey, isChildPrivate: Bool, childDerivationPath: DerivationPath) throws {
        var key = parent
        for component in childDerivationPath.components {
            key = try HDKey(parent: key, isChildPrivate: isChildPrivate, childDerivation: component)
        }
        self.init(other: key)
    }
    
    public var keyFingerprint: UInt32 {
        var hdkey = wallyExtKey
        var fingerprint_bytes = [UInt8](repeating: 0, count: Int(BIP32_KEY_FINGERPRINT_LEN))
        precondition(bip32_key_get_fingerprint(&hdkey, &fingerprint_bytes, fingerprint_bytes.count) == WALLY_OK)
        return withUnsafeBytes(of: fingerprint_bytes) {
            $0.bindMemory(to: UInt32.self).baseAddress!.pointee.bigEndian
        }
    }

    private var wallyExtKey: ext_key {
        var k = ext_key()
        
        if isPrivate {
            withUnsafeMutableBytes(of: &k.priv_key) {
                _ = keyData.copyBytes(to: $0.bindMemory(to: UInt8.self), count: keyData.count)
            }
        } else {
            withUnsafeMutableBytes(of: &k.pub_key) {
                _ = keyData.copyBytes(to: $0.bindMemory(to: UInt8.self), count: keyData.count)
            }
        }
        
        if let chainCode = chainCode {
            withUnsafeMutableBytes(of: &k.chain_code) {
                _ = chainCode.copyBytes(to: $0.bindMemory(to: UInt8.self), count: chainCode.count)
            }
        }
        
        return k
    }
    
    var cbor: CBOR {
        var a: [OrderedMapEntry] = []
        
        if isMaster {
            a.append(.init(key: 1, value: true))
        }
        
        if isPrivate {
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

    init(cbor: CBOR) throws {
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

        let useInfo: CoinInfo?
        if let useInfoItem = pairs[5] {
            useInfo = try CoinInfo(taggedCBOR: useInfoItem)
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
        
        self.init(isMaster: isMaster, isPrivate: isPrivate, keyData: keyData, chainCode: chainCode, useInfo: useInfo, origin: origin, children: children, parentFingerprint: parentFingerprint)
    }
    
    init(taggedCBOR: CBOR) throws {
        guard case let CBOR.tagged(.init(rawValue: 303), cbor) = taggedCBOR else {
            throw GeneralError("HDKey tag (303) not found.")
        }
        try self.init(cbor: cbor)
    }
}
