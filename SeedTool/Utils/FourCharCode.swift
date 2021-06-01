//
//  FourCharCode.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/21/20.
//

import Foundation

/**
 Set FourCharCode/OSType using a String.

 Examples:
 let test: FourCharCode = "420v"
 let test2 = FourCharCode("420f")
 print(test.string, test2.string)
*/
extension FourCharCode: ExpressibleByStringLiteral {

    public init(stringLiteral value: StringLiteralType) {
        var code: FourCharCode = 0
        // Value has to consist of 4 printable ASCII characters, e.g. '420v'.
        // Note: This implementation does not enforce printable range (32-126)
        precondition( value.count == 4 && value.utf8.count == 4)
        for byte in value.utf8 {
            code = code << 8 + FourCharCode(byte)
        }
        self = code
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self = FourCharCode(stringLiteral: value)
    }

    public init(unicodeScalarLiteral value: String) {
        self = FourCharCode(stringLiteral: value)
    }

    public init(_ value: String) {
        self = FourCharCode(stringLiteral: value)
    }

    public var string: String? {
        let cString: [CChar] = [
            CChar(self >> 24 & 0xFF),
            CChar(self >> 16 & 0xFF),
            CChar(self >> 8 & 0xFF),
            CChar(self & 0xFF),
            0
        ]
        return String(cString: cString)
    }
}
