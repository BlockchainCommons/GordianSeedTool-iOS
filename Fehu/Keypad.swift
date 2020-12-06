//
//  Keypad.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import Foundation
import SwiftUI

protocol Keypad {
    associatedtype Value: ValueViewable & Identifiable & Equatable
    var append: (Value) -> Void { get }
    var removeLast: () -> Void { get }
}
