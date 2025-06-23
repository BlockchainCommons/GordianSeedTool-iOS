//
//  ByteKeypad.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/6/20.
//

import SwiftUI
import Foundation

struct ByteKeypad: View, Keypad {
    typealias TokenType = ByteToken

    @ObservedObject var model: EntropyViewModel<ByteKeypad>

    static let name: String = "Hex Bytes"
    static let entropyBitsPerValue: Double = log2(256)
    static let setsCreationDate = false
    @State var selectedValues: [Int] = []

    init(model: EntropyViewModel<ByteKeypad>) {
        self.model = model
    }

    private func sync() {
        guard selectedValues.count == 2 else { return }
        model.appendValue(ByteToken(highDigit: selectedValues[0], lowDigit: selectedValues[1]))
        selectedValues.removeAll()
    }

    private func formatHexDigit(value: Int) -> String {
        return String(format: "%X", value)
    }

    private func buttonFor(value: Int, key: KeyEquivalent, accessibilityLabel: String) -> KeypadButton<Int> {
        KeypadButton(value: value, selectedValues: $selectedValues, maxSelectedValues: 2, string: formatHexDigit(value: value), key: key, accessibilityLabel: accessibilityLabel)
    }

    static func validate(values: [TokenType]) -> Text? {
        let validLengths = [16, 20, 24, 28, 32]
        guard !values.isEmpty, !validLengths.contains(values.count) else { return nil }

        // One formatter, configured once
        let fmt = MeasurementFormatter()
        fmt.unitStyle   = .long          // “byte” / “bytes”
        fmt.unitOptions = .providedUnit  // never scale to kB, MB, …

        // Helper converts an Int to “1 byte”, “12 bytes”, etc.
        func bytesString(_ n: Int) -> String {
            fmt.string(from: Measurement(
                value: Double(n),
                unit: UnitInformationStorage.bytes))
        }

        let current = bytesString(values.count)
        let allowed = ListFormatter.localizedString(byJoining: validLengths.map { String($0) })

        return Text("Invalid length: **\(current)**. Valid lengths: \(allowed).")
    }
    
    var body: some View {
        VStack {
            HStack {
                buttonFor(value: 0, key: "0", accessibilityLabel: "0")
                buttonFor(value: 1, key: "1", accessibilityLabel: "1")
                buttonFor(value: 2, key: "2", accessibilityLabel: "2")
                buttonFor(value: 3, key: "3", accessibilityLabel: "3")
            }
            HStack {
                buttonFor(value: 4, key: "4", accessibilityLabel: "4")
                buttonFor(value: 5, key: "5", accessibilityLabel: "5")
                buttonFor(value: 6, key: "6", accessibilityLabel: "6")
                buttonFor(value: 7, key: "7", accessibilityLabel: "7")
            }
            HStack {
                buttonFor(value: 8, key: "8", accessibilityLabel: "8")
                buttonFor(value: 9, key: "9", accessibilityLabel: "9")
                buttonFor(value: 10, key: "a", accessibilityLabel: "A")
                buttonFor(value: 11, key: "b", accessibilityLabel: "B")
            }
            HStack {
                buttonFor(value: 12, key: "c", accessibilityLabel: "C")
                buttonFor(value: 13, key: "d", accessibilityLabel: "D")
                buttonFor(value: 14, key: "e", accessibilityLabel: "E")
                buttonFor(value: 15, key: "f", accessibilityLabel: "F")
            }
            KeypadFunctionButtons(model: model) {
                selectedValues.removeAll()
            }
        }
        .onChange(of: selectedValues) {
            self.sync()
        }
    }
}
