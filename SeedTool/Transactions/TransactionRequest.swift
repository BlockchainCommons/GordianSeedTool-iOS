//
//  TransactionRequest.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/17/21.
//

import Foundation
import URKit
import LifeHash
import CryptoKit

struct TransactionRequest {
    let id: UUID
    let body: Body
    let description: String?

    enum Body {
        case seed(SeedRequestBody)
        case key(KeyRequestBody)
        case psbtSignature(PSBTSignatureRequestBody)
    }
    
    var cbor: CBOR {
        var a: [OrderedMapEntry] = []
        
        a.append(.init(key: 1, value: id.taggedCBOR))
        
        switch body {
        case .seed(let body):
            a.append(.init(key: 2, value: body.taggedCBOR))
        case .key(let body):
            a.append(.init(key: 2, value: body.taggedCBOR))
        case .psbtSignature(let body):
            a.append(.init(key: 2, value: body.taggedCBOR))
        }
        
        if let description = description {
            a.append(.init(key: 3, value: CBOR.utf8String(description)))
        }
        
        return CBOR.orderedMap(a)
    }

    var taggedCBOR: CBOR {
        CBOR.tagged(.transactionRequest, cbor)
    }
    
    init(ur: UR) throws {
        guard ur.type == "crypto-request" else {
            throw GeneralError("Unexpected UR type.")
        }
        try self.init(cborData: ur.cbor)
    }

    init(id: UUID = UUID(), body: TransactionRequest.Body, description: String? = nil) {
        self.id = id
        self.body = body
        self.description = description
    }
    
    init(cborData: Data) throws {
        guard let cbor = try CBOR.decode(cborData.bytes) else {
            throw GeneralError("ur:crypto-request: Invalid CBOR.")
        }
        try self.init(cbor: cbor)
    }
    
    init(cbor: CBOR) throws {
        guard case let CBOR.map(pairs) = cbor else {
            throw GeneralError("ur:crypto-request: CBOR doesn't contain a map.")
        }
        
        guard let idItem = pairs[1] else {
            throw GeneralError("ur:crypto-request: CBOR doesn't contain a transaction ID.")
        }
        let id = try UUID(taggedCBOR: idItem)
        
        guard let bodyItem = pairs[2] else {
            throw GeneralError("ur:crypto-request: CBOR doesn't contain a body.")
        }
        
        let body: Body
        
        if let seedRequestBody = try SeedRequestBody(taggedCBOR: bodyItem) {
            body = Body.seed(seedRequestBody)
        } else if let keyRequestBody = try KeyRequestBody(taggedCBOR: bodyItem) {
            body = Body.key(keyRequestBody)
        } else if let psbtSignatureRequestBody = try PSBTSignatureRequestBody(taggedCBOR: bodyItem) {
            body = Body.psbtSignature(psbtSignatureRequestBody)
        } else {
            throw GeneralError("ur:crypto-request: Unrecognized request.")
        }
        
        let description: String?
        
        if let descriptionItem = pairs[3] {
            guard case let CBOR.utf8String(d) = descriptionItem else {
                throw GeneralError("ur:crypto-request: Invalid description.")
            }
            description = d
        } else {
            description = nil
        }
        
        self.init(id: id, body: body, description: description)
    }

    var ur: UR {
        try! UR(type: "crypto-request", cbor: cbor)
    }
}

struct SeedRequestBody {
    let fingerprint: Fingerprint
    
    var cbor: CBOR {
        CBOR.byteString(fingerprint.digest.bytes)
    }
    
    var taggedCBOR: CBOR {
        return CBOR.tagged(.seedRequestBody, cbor)
    }
    
    init(fingerprint: Fingerprint) {
        self.fingerprint = fingerprint
    }
    
    init(cbor: CBOR) throws {
        guard
            case let CBOR.byteString(bytes) = cbor,
              bytes.count == SHA256.byteCount
        else {
            throw GeneralError("Invalid seed request.")
        }
        self.init(fingerprint: Fingerprint(digest: Data(bytes)))
    }
    
    init?(taggedCBOR: CBOR) throws {
        guard case let CBOR.tagged(.seedRequestBody, cbor) = taggedCBOR else {
            return nil
        }
        try self.init(cbor: cbor)
    }
}

struct KeyRequestBody {
    let keyType: KeyType
    let path: DerivationPath
    let useInfo: UseInfo
    let isDerivable: Bool
    
    var cbor: CBOR {
        var a: [OrderedMapEntry] = []
        a.append(.init(key: 1, value: CBOR.boolean(keyType.isPrivate)))
        a.append(.init(key: 2, value: path.taggedCBOR))
        
        if !useInfo.isDefault {
            a.append(.init(key: 3, value: useInfo.taggedCBOR))
        }
        
        if !isDerivable {
            a.append(.init(key: 4, value: CBOR.boolean(isDerivable)))
        }
        
        return CBOR.orderedMap(a)
    }
    
    var taggedCBOR: CBOR {
        return CBOR.tagged(.keyRequestBody, cbor)
    }

    init(keyType: KeyType, path: DerivationPath, useInfo: UseInfo, isDerivable: Bool) {
        self.keyType = keyType
        self.path = path
        self.useInfo = useInfo
        self.isDerivable = isDerivable
    }

    init(cbor: CBOR) throws {
        guard case let CBOR.map(pairs) = cbor else {
            throw GeneralError("Invalid key request.")
        }
        guard let boolItem = pairs[1], case let CBOR.boolean(isPrivate) = boolItem else {
            throw GeneralError("Key request doesn't contain isPrivate.")
        }
        guard let pathItem = pairs[2] else {
            throw GeneralError("Key request doesn't contain derivation.")
        }
        let path = try DerivationPath(taggedCBOR: pathItem)
        
        let useInfo: UseInfo
        if let pathItem = pairs[3] {
            useInfo = try UseInfo(taggedCBOR: pathItem)
        } else {
            useInfo = UseInfo()
        }
        
        let isDerivable: Bool
        if let isDerivableItem = pairs[4] {
            guard case let CBOR.boolean(d) = isDerivableItem else {
                throw GeneralError("Invalid isDerivable field in key request.")
            }
            isDerivable = d
        } else {
            isDerivable = true
        }
        
        self.init(keyType: KeyType(isPrivate: isPrivate), path: path, useInfo: useInfo, isDerivable: isDerivable)
    }

    init?(taggedCBOR: CBOR) throws {
        guard case let CBOR.tagged(.keyRequestBody, cbor) = taggedCBOR else {
            return nil
        }
        try self.init(cbor: cbor)
    }
}

struct PSBTSignatureRequestBody {
    let psbt: Data
    
    var cbor: CBOR {
        // not supported yet
        fatalError()
    }

    var taggedCBOR: CBOR {
        return CBOR.tagged(.psbtSignatureRequestBody, cbor)
    }
    
    init(cbor: CBOR) throws {
        throw GeneralError("Signing PSBTs isn't supported yet.")
    }
    
    init?(taggedCBOR: CBOR) throws {
        guard case let CBOR.tagged(.psbtSignatureRequestBody, cbor) = taggedCBOR else {
            return nil
        }
        try self.init(cbor: cbor)
    }
}
