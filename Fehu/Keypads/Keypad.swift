//
//  Keypad.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import Foundation
import SwiftUI

protocol Keypad {
    associatedtype TokenType: Token

    init(model: KeypadViewModel<Self>)
    static var name: String { get }
    static var entropyBitsPerValue: Double { get }
    static func random() -> TokenType
}

extension Keypad {
    static func random() -> TokenType {
        TokenType.random(using: &secureRandomNumberGenerator)
    }
}
