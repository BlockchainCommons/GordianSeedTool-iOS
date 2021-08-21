//
//  Keypad.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/5/20.
//

import Foundation
import SwiftUI

protocol Keypad {
    associatedtype TokenType: Token & Randomizable & TokenViewable & StringTransformable & SeedProducer

    init(model: EntropyViewModel<Self>)
    static var name: String { get }
    static var entropyBitsPerValue: Double { get }
    static func random() -> TokenType
    static func seed(values: [TokenType]) -> Data
}

extension Keypad {
    static func random() -> TokenType {
        TokenType.random(using: &SecureRandomNumberGenerator.shared)
    }
}

extension Keypad {
    static func seed(values: [TokenType]) -> Data {
        TokenType.seed(values: values)
    }
}
