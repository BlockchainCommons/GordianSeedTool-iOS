//
//  SSKRDecoder.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/23/20.
//

import Foundation
import SSKR
import URKit

enum SSKRDecoder {
    static func decode(_ sskrString: String) throws -> Data {
        try sskrString
            .split(separator: "\n")
            .map { String($0) }
            .map { $0.trim() }
            .filter { !$0.isEmpty }
            .map { $0.removeWhitespaceRuns() }
            .compactMap { try decodeShare($0) }
            .map { SSKRShare(data: $0.bytes) }
            .combineSSKRShares()
    }
    
    private static func decodeShare(_ string: String) throws -> Data? {
        if let share = try? Bytewords.decode(string) {
            return try share.decodeCBOR(isTagged: true)
        }
        
        guard let ur = try? URDecoder.decode(string) else {
            return nil
        }
        guard ur.type == "crypto-sskr" else {
            throw GeneralError("SSKR: UR type is not crypto-sskr.")
        }

        return try ur.cbor.decodeCBOR(isTagged: false)
    }
}

extension Array where Element == SSKRShare {
    fileprivate func combineSSKRShares() throws -> Data {
        do {
            return try SSKRCombine(shares: self)
        } catch {
            throw GeneralError("Invalid SSKR shares.")
        }
    }
}

extension Data {
    fileprivate func decodeCBOR(isTagged: Bool) throws -> Data {
        guard let cbor = try CBOR.decode(self.bytes) else {
            throw GeneralError("SSKR: Invalid CBOR.")
        }
        let content: CBOR
        if isTagged {
            guard case let CBOR.tagged(tag, _content) = cbor, tag.rawValue == 309 else {
                throw GeneralError("SSKR: CBOR tag not found (309).")
            }
            content = _content
        } else {
            content = cbor
        }
        guard case let CBOR.byteString(bytes) = content else {
            throw GeneralError("SSKR: CBOR byte string not found.")
        }
        return Data(bytes)
    }
}
