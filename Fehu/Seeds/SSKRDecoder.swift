//
//  SSKRDecoder.swift
//  Fehu
//
//  Created by Wolf McNally on 12/23/20.
//

import Foundation
import SSKR
import URKit

enum SSKRDecoder {
    static func decode(_ sskrString: String) throws -> Data {
//        let lines = bytewordsShares.split(separator: "\n").map { String($0) }
//        let trimmedLines = lines.map { $0.trim() }
//        let bytewordsLines = trimmedLines.compactMap { line in
//            try? Bytewords.decode(line)
//        }
//        let sskrShares = bytewordsLines.map { SSKRShare(data: $0.bytes) }
//        let result = try SSKRCombine(shares: sskrShares)
//        return result
        try sskrString
            .split(separator: "\n")
            .map { String($0) }
            .map { $0.trim() }
            .filter { !$0.isEmpty }
            .map { $0.removeWhitespaceRuns() }
            .compactMap { try? Bytewords.decode($0) }
            .map { try $0.decodeCBOR() }
            .map { SSKRShare(data: $0.bytes) }
            .combineSSKRShares()
    }
}

extension Array where Element == SSKRShare {
    fileprivate func combineSSKRShares() throws -> Data {
        try SSKRCombine(shares: self)
    }
}

extension Data {
    fileprivate func decodeCBOR() throws -> Data {
        guard let cbor = try CBOR.decode(self.bytes) else {
            throw GeneralError("SSKR: Invalid CBOR.")
        }
        guard case let CBOR.tagged(tag, content) = cbor, tag.rawValue == 309 else {
            throw GeneralError("SSKR: CBOR tag not found (309).")
        }
        guard case let CBOR.byteString(bytes) = content else {
            throw GeneralError("SSKR: CBOR byte string not found.")
        }
        return Data(bytes)
    }
}
