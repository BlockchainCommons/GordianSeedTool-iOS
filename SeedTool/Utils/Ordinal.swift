//
//  Ordinal.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 10/31/17.
//

import Foundation

public struct Ordinal {
    public let a: [Int]
    
    public init(_ a: Int) {
        self.init([a])
    }
    
    public init(after: Ordinal? = nil, before: Ordinal? = nil) {
        if let after = after {
            if let before = before {
                self.init(after: after, before: before)
            } else {
                self.init(after: after)
            }
        } else if let before = before {
            self.init(before: before)
        } else {
            self.init()
        }
    }

    private init(_ a: [Int]) {
        self.a = a
    }

    private init() {
        self.init([0])
    }

    private init(before o: Ordinal) {
        a = [o.a[0] - 1]
    }

    private init(after o: Ordinal) {
        a = [o.a[0] + 1]
    }

    private init(after ord1: Ordinal, before ord2: Ordinal) {
        let len1 = ord1.a.count
        let len2 = ord2.a.count
        if len1 > len2 {
            a = Array(ord1.a.dropLast()) + [ord1.a.last! + 1]
        } else if len1 < len2 {
            a = Array(ord2.a.dropLast()) + [ord2.a.last! - 1]
        } else if ord2.a.last! - ord1.a.last! > 1 {
            a = Array(ord1.a.dropLast()) + [ord1.a.last! + 1]
        } else {
            a = ord1.a + [1]
        }
    }
}

extension Ordinal: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(value)
    }
}

extension Ordinal: Comparable {
    public static func == (lhs: Ordinal, rhs: Ordinal) -> Bool {
        return lhs.a == rhs.a
    }

    public static func < (lhs: Ordinal, rhs: Ordinal) -> Bool {
        return lhs.a.lexicographicallyPrecedes(rhs.a)
    }
}

extension Ordinal: CustomStringConvertible {
    public var description: String {
        return "[" + (a.map { String(describing: $0) }).joined(separator: ", ") + "]"
    }
}

extension Ordinal: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        a = try container.decode([Int].self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(a)
    }
}

extension Ordinal {
    public struct DecodeError: Error { }

    public var encoded: String {
        return try! String(data: JSONEncoder().encode(self), encoding: .utf8)!
    }

    public init(encoded: String) throws {
        guard let data = encoded.data(using: .utf8) else {
            throw DecodeError()
        }

        self = try JSONDecoder().decode(Ordinal.self, from: data)
    }
}
