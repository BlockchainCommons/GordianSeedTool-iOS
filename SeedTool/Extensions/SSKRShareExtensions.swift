//
//  SSKRShareExtensions.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 4/10/21.
//

import SSKR
import BCFoundation

extension SSKRShare: Hashable {
    var identifier: UInt16 {
        (UInt16(data[0]) << 8) | UInt16(data[1])
    }
    
    var identifierHex: String {
        Data(data[0...1]).hex
    }

    var groupThreshold: Int {
        Int(data[2] >> 4) + 1
    }
    
    var groupCount: Int {
        Int(data[2] & 0xf) + 1
    }
    
    var groupIndex: Int {
        Int(data[3]) >> 4
    }
    
    var memberThreshold: Int {
        Int(data[3] & 0xf) + 1
    }
    
    var memberIndex: Int {
        Int(data[4] & 0xf)
    }
    
    public static func ==(lhs: SSKRShare, rhs: SSKRShare) -> Bool {
        lhs.data == rhs.data
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }
    
    init?(bytewords: String) throws {
        guard let share = try? Bytewords.decode(bytewords) else {
            return nil
        }
        self = try SSKRShare(data: share.decodeCBOR(isTagged: true).bytes)
    }
    
    init?(urString: String) throws {
        guard let ur = try? URDecoder.decode(urString) else {
            return nil
        }
        try self.init(ur: ur)
    }
    
    init(ur: UR) throws {
        guard ur.type == "crypto-sskr" else {
            throw GeneralError("SSKR: UR type is not crypto-sskr.")
        }

        self = try SSKRShare(data: ur.cbor.decodeCBOR(isTagged: false).bytes)
    }

    var ur: UR {
        let cbor = CBOR.encode(Data(data))
        return try! UR(type: "crypto-sskr", cbor: cbor)
    }
    
    var urString: String {
        return UREncoder.encode(ur)
    }

    var bytewords: String {
        let cbor = CBOR.encodeTagged(tag: .sskrShare, value: Data(data))
        return Bytewords.encode(Data(cbor), style: .standard)
    }
}

extension SSKRShare: CustomStringConvertible {
    public var description: String {
        "SSKRShare(\(identifierHex) \(groupIndex + 1)-\(memberIndex + 1))"
    }
}

extension Data {
    fileprivate func decodeCBOR(isTagged: Bool) throws -> Data {
        guard let cbor = try CBOR.decode(self.bytes) else {
            throw GeneralError("SSKR: Invalid CBOR.")
        }
        let content: CBOR
        if isTagged {
            guard case let CBOR.tagged(tag, _content) = cbor, tag == .sskrShare else {
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
