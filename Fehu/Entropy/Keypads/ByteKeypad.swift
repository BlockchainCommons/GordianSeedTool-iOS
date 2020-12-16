//
//  ByteKeypad.swift
//  Fehu
//
//  Created by Wolf McNally on 12/6/20.
//

import SwiftUI

struct ByteKeypad: View, Keypad {
    typealias TokenType = ByteToken

    @ObservedObject var model: EntropyViewModel<ByteKeypad>

    static let name: String = "Hex Bytes"
    static let entropyBitsPerValue: Double = log2(256)
    @State var selectedValues: [Int] = []

    init(model: EntropyViewModel<ByteKeypad>) {
        self.model = model
    }

    private func sync() {
        guard selectedValues.count == 2 else { return }
        model.values.append(ByteToken(highDigit: selectedValues[0], lowDigit: selectedValues[1]))
        selectedValues.removeAll()
    }

    private func formatHexDigit(value: Int) -> String {
        return String(format: "%X", value)
    }

    private func buttonFor(value: Int, key: KeyEquivalent) -> KeypadButton<Int> {
        KeypadButton(value: value, selectedValues: $selectedValues, maxSelectedValues: 2, string: formatHexDigit(value: value), key: key)
    }

    var body: some View {
        VStack {
            HStack {
                buttonFor(value: 0, key: "0")
                buttonFor(value: 1, key: "1")
                buttonFor(value: 2, key: "2")
                buttonFor(value: 3, key: "3")
            }
            HStack {
                buttonFor(value: 4, key: "4")
                buttonFor(value: 5, key: "5")
                buttonFor(value: 6, key: "6")
                buttonFor(value: 7, key: "7")
            }
            HStack {
                buttonFor(value: 8, key: "8")
                buttonFor(value: 9, key: "9")
                buttonFor(value: 10, key: "a")
                buttonFor(value: 11, key: "b")
            }
            HStack {
                buttonFor(value: 12, key: "c")
                buttonFor(value: 13, key: "d")
                buttonFor(value: 14, key: "e")
                buttonFor(value: 15, key: "f")
            }
            KeypadFunctionButtons(model: model) {
                selectedValues.removeAll()
            }
        }
        .onChange(of: selectedValues) { _ in
            self.sync()
        }
    }
}
