//
//  Keypad.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import Foundation
import SwiftUI

protocol Keypad {
    associatedtype DisplayValue: Roll

    init(model: EntryViewModel<Self>)
    static var name: String { get }
    static var entropyBitsPerValue: Double { get }
    static func random() -> DisplayValue
}

extension Keypad {
    static func random() -> DisplayValue {
        DisplayValue.random(using: &secureRandomNumberGenerator)
    }
}
