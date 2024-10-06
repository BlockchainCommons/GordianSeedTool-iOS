//
//  Keypad.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/5/20.
//

import Foundation
import SwiftUI
import BCFoundation

protocol Keypad {
    associatedtype TokenType: Token & Randomizable & TokenViewable & StringTransformable & SeedProducer

    init(model: EntropyViewModel<Self>)
    static var name: String { get }
    static var entropyBitsPerValue: Double { get }
    static var setsCreationDate: Bool { get }
    static func random() -> TokenType
    static func seed(values: [TokenType]) -> Data
}

extension Keypad {
    static func random() -> TokenType {
        var rng = SecureRandomNumberGenerator.shared
        return TokenType.random(using: &rng)
    }
}

extension Keypad {
    static func seed(values: [TokenType]) -> Data {
        TokenType.seed(values: values)
    }
}
