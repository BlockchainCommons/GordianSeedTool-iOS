//
//  HexKeypad.swift
//  Fehu
//
//  Created by Wolf McNally on 12/6/20.
//

import SwiftUI

struct HexKeypad: View, Keypad {
    @Binding var isEmpty: Bool
    var append: (HexRoll) -> Void
    var removeLast: () -> Void

    @State var selectedValues: [Int] = []

    static let name: String = "Hex Bytes"

    init(isEmpty: Binding<Bool>, append: @escaping (HexRoll) -> Void, removeLast: @escaping () -> Void) {
        self._isEmpty = isEmpty
        self.append = append
        self.removeLast = removeLast
    }

    private func sync() {
        guard selectedValues.count == 2 else { return }
        append(HexRoll(highDigit: selectedValues[0], lowDigit: selectedValues[1]))
        selectedValues.removeAll()
    }

    private func formatHexDigit(value: Int) -> String {
        return String(format: "%X", value)
    }

    private func buttonFor(value: Int, key: KeyEquivalent) -> KeypadButton<Int> {
        KeypadButton(value: value, selectedValues: $selectedValues, string: formatHexDigit(value: value), key: key)
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
            .padding(.bottom, 10)
            HStack {
                KeypadDeleteButton(isEmpty: $isEmpty) {
                    removeLast()
                    selectedValues.removeAll()
                }
            }
        }
        .onChange(of: selectedValues) { _ in
            self.sync()
        }
    }
}
