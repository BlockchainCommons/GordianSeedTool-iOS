//
//  Token.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/8/20.
//

import Foundation

protocol Token: Equatable, Identifiable, CustomStringConvertible {
    associatedtype Value: Equatable & CustomStringConvertible

    var id: UUID { get }
    var value: Value { get }
    static func == (lhs: Self, rhs: Self) -> Bool
}

extension Token {
    var description: String {
        value.description
    }
}

extension Token {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}

protocol Randomizable {
    static func random<T>(using generator: inout T) -> Self where T : RandomNumberGenerator
}
