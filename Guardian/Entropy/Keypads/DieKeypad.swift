//
//  DieKeypad.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI

struct DieKeypad: View, Keypad {
    typealias TokenType = DieToken

    @ObservedObject var model: EntropyViewModel<DieKeypad>

    static let name: String = "Die Rolls"
    static let entropyBitsPerValue: Double = log2(6)
    @State var selectedValues: [Int] = []

    init(model: EntropyViewModel<DieKeypad>) {
        self.model = model
    }

    private func sync() {
        guard !selectedValues.isEmpty else { return }
        model.values.append(DieToken(value: selectedValues.first!))
        selectedValues.removeAll()
    }

    private func buttonFor(_ value: Int, key: KeyEquivalent) -> KeypadButton<Int> {
        KeypadButton(value: value, selectedValues: $selectedValues, imageName: "die.face.\(value).fill", color: .primary, key: key)
    }

    var body: some View {
        VStack {
            HStack {
                buttonFor(1, key: "1")
                buttonFor(2, key: "2")
                buttonFor(3, key: "3")
            }
            HStack {
                buttonFor(4, key: "4")
                buttonFor(5, key: "5")
                buttonFor(6, key: "6")
            }
            KeypadFunctionButtons(model: model) {
                selectedValues.removeAll()
            }
        }
        .onChange(of: selectedValues) { _ in
            self.sync()
        }
        .onChange(of: selectedValues) { _ in
            self.sync()
        }
    }
}
