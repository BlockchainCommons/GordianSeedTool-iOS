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
    init(isEmpty: Binding<Bool>, append: @escaping (Value) -> Void, removeLast: @escaping () -> Void)
    var append: (Value) -> Void { get }
    var removeLast: () -> Void { get }
    static var name: String { get }
}
