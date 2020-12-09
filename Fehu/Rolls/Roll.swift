//
//  Roll.swift
//  Fehu
//
//  Created by Wolf McNally on 12/8/20.
//

import Foundation

protocol Roll: Equatable, Identifiable, ValueViewable {
    associatedtype Value: Equatable

    var id: UUID { get }
    var value: Value { get }
    static func == (lhs: Self, rhs: Self) -> Bool
    static func random<T>(using generator: inout T) -> Self where T : RandomNumberGenerator
}

extension Roll {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.value == rhs.value
    }
}
