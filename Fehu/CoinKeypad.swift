//
//  CoinKeypad.swift
//  Fehu
//
//  Created by Wolf McNally on 12/6/20.
//

import SwiftUI

struct CoinKeypad: View, Keypad {
    @Binding var isEmpty: Bool
    var append: (CoinFlip) -> Void
    var removeLast: () -> Void

    @State var selectedValues: [Bool] = []

    static let name: String = "Coin Flips"

    init(isEmpty: Binding<Bool>, append: @escaping (CoinFlip) -> Void, removeLast: @escaping () -> Void) {
        self._isEmpty = isEmpty
        self.append = append
        self.removeLast = removeLast
    }

    private func sync() {
        guard !selectedValues.isEmpty else { return }
        append(CoinFlip(value: selectedValues.first!))
        selectedValues.removeAll()
    }

    private func buttonFor(_ value: Bool, key: KeyEquivalent) -> KeypadButton<Bool> {
        KeypadButton(value: value, selectedValues: $selectedValues, string: CoinFlip.symbol(for: value), key: key)
    }

    var body: some View {
        VStack {
            HStack {
                buttonFor(true, key: "h")
                buttonFor(false, key: "t")
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

struct CoinKeypad_Previews: PreviewProvider {
    static var previews: some View {
        CoinKeypad(isEmpty: Binding<Bool>.constant(false)) { _ in } removeLast: { }
        .preferredColorScheme(.dark)
        .padding(20)
        .previewLayout(.sizeThatFits)
    }
}
