//
//  UUIDExtensions.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/21/20.
//

import Foundation
import URKit

extension UUID {
    var data: Data {
        withUnsafeBytes(of: uuid) { p in
            Data(p.bindMemory(to: UInt8.self))
        }
    }
}

extension UUID {
    var cbor: CBOR {
        CBOR.byteString(data.bytes)
    }
    
    var taggedCBOR: CBOR {
        CBOR.tagged(CBOR.Tag.uuid, cbor)
    }
    
    init(cbor: CBOR) throws {
        guard
            case let CBOR.byteString(bytes) = cbor,
            bytes.count == MemoryLayout<uuid_t>.size
        else {
            throw GeneralError("UUID: Invalid data.")
        }
        self = bytes.withUnsafeBytes {
            UUID(uuid: $0.bindMemory(to: uuid_t.self).baseAddress!.pointee)
        }
    }
    
    init(taggedCBOR: CBOR) throws {
        guard case let CBOR.tagged(CBOR.Tag.uuid, cbor) = taggedCBOR else {
            throw GeneralError("UUID tag (37) not found.")
        }
        try self.init(cbor: cbor)
    }
}
