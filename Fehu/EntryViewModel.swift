//
//  EntryViewModel.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import Foundation

final class EntryViewModel<KeypadType>: ObservableObject where KeypadType: Keypad {
    typealias Value = KeypadType.Value
    @Published var values: [Value] = []
    @Published var isEmpty: Bool = true

    func append(value: Value) {
        values.append(value)
        isEmpty = false
    }

    func removeLast() {
        values.removeLast()
        isEmpty = values.isEmpty
    }
}
