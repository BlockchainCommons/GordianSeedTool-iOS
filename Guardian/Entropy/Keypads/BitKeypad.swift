//
//  BitKeypad.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/6/20.
//

import SwiftUI

struct BitKeypad: View, Keypad {
    typealias TokenType = BitToken

    @ObservedObject var model: EntropyViewModel<BitKeypad>

    static let name: String = "Coin Flips"
    static let entropyBitsPerValue: Double = 1
    @State var selectedValues: [Bool] = []

    init(model: EntropyViewModel<BitKeypad>) {
        self.model = model
    }

    private func sync() {
        guard !selectedValues.isEmpty else { return }
        model.values.append(BitToken(value: selectedValues.first!))
        selectedValues.removeAll()
    }

    private func buttonFor(_ value: Bool, key: KeyEquivalent, accessibilityLabel: String) -> KeypadButton<Bool> {
        KeypadButton(value: value, selectedValues: $selectedValues, string: BitToken.symbol(for: value), key: key, accessibilityLabel: accessibilityLabel)
    }

    var body: some View {
        VStack {
            HStack {
                buttonFor(true, key: "h", accessibilityLabel: "Heads")
                buttonFor(false, key: "t", accessibilityLabel: "Tails")
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
