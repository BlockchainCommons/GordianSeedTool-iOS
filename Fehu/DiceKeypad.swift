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

    @State var selectedValue: Int?

    private func sync() {
        guard let value = selectedValue else { return }
        append(DieRoll(value: value))
        selectedValue = nil
    }

    private func buttonFor(_ value: Int, key: KeyEquivalent) -> KeypadButton<Int> {
        KeypadButton(value: value, selectedValue: $selectedValue, imageName: "die.face.\(value).fill", color: .primary, key: key)
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
                KeypadDeleteButton(isEmpty: $isEmpty) { removeLast() }
            }
        }
        .onChange(of: selectedValue) { _ in
            self.sync()
        }
        .onChange(of: selectedValue) { _ in
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
