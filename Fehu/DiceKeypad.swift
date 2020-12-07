//
//  DiceKeypad.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI

struct DiceKeypad: View, Keypad {
    @Binding var isEmpty: Bool
    var append: (DieRoll) -> Void
    var removeLast: () -> Void

    @State var selectedValues: [Int] = []

    static let name: String = "Die Rolls"

    init(isEmpty: Binding<Bool>, append: @escaping (DieRoll) -> Void, removeLast: @escaping () -> Void) {
        self._isEmpty = isEmpty
        self.append = append
        self.removeLast = removeLast
    }

    private func sync() {
        guard !selectedValues.isEmpty else { return }
        append(DieRoll(value: selectedValues.first!))
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
        .onChange(of: selectedValues) { _ in
            self.sync()
        }
    }
}

struct DiceKeypad_Previews: PreviewProvider {
    static var previews: some View {
        DiceKeypad(isEmpty: Binding<Bool>.constant(false)) { _ in } removeLast: { }
        .preferredColorScheme(.dark)
        .padding(20)
        .previewLayout(.sizeThatFits)
    }
}
