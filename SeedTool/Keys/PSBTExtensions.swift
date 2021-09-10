//
//  PSBTExtensions.swift
//  SeedTool
//
//  Created by Wolf McNally on 8/24/21.
//

import Foundation
import URKit
import LibWally

extension PSBT {
    init(ur: UR) throws {
        guard ur.type == "crypto-psbt" else {
            throw GeneralError("Unexpected UR type: \(ur.type). Expected crypto-psbt.")
        }
        guard let cbor = try CBOR.decode(ur.cbor.bytes) else {
            throw GeneralError("Invalid crypto-psbt.")
        }
        try self.init(cbor: cbor)
    }
    
    init(urString: String) throws {
        try self.init(ur: URDecoder.decode(urString))
    }
    
    init(parse string: String) throws {
        if let a = PSBT(base64: string) {
            self = a
            return
        }
        
        if let a = PSBT(hex: string) {
            self = a
            return
        }

        do {
            try self.init(urString: string)
        } catch { }

        throw GeneralError("Invalid PSBT.")
    }
    
    var ur: UR {
        try! UR(type: "crypto-psbt", cbor: cbor)
    }
    
    var urString: String {
        ur.string
    }
    
    var cbor: CBOR {
        CBOR.byteString(data.bytes)
    }

    var taggedCBOR: CBOR {
        return CBOR.tagged(.psbt, cbor)
    }
    
    init(cbor: CBOR) throws {
        guard
            case let CBOR.byteString(bytes) = cbor,
            let a = PSBT(Data(bytes))
        else {
            throw GeneralError("Invalid PSBT.")
        }
        self = a
    }
    
    init(taggedCBOR: CBOR) throws {
        guard case let CBOR.tagged(.psbt, cbor) = taggedCBOR else {
            throw GeneralError("Invalid PSBT.")
        }
        try self.init(cbor: cbor)
    }
}
