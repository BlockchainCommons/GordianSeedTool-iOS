//
//  Keypad.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import Foundation
import SwiftUI

protocol Keypad {
    associatedtype TokenType: Token & Randomizable & ValueViewable & StringTransformable & SeedProducer

    init(model: EntropyViewModel<Self>)
    static var name: String { get }
    static var entropyBitsPerValue: Double { get }
    static func random() -> TokenType
    static func seed(values: [TokenType]) -> Data
}

extension Keypad {
    static func random() -> TokenType {
        TokenType.random(using: &secureRandomNumberGenerator)
    }
}

extension Keypad {
    static func seed(values: [TokenType]) -> Data {
        TokenType.seed(values: values)
    }
}
