//
//  KeypadButton.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI

func regularFont(size: CGFloat) -> Font {
    Font.custom("HelveticaNeue-Bold", fixedSize: size)
}

func condensedFont(size: CGFloat) -> Font {
    Font.custom("HelveticaNeue-CondensedBold", fixedSize: size)
}

struct KeypadButton<T: Equatable>: View {
    let value: T
    @Binding var selectedValues: [T]
    let maxSelectedValues: Int
    let label: AnyView
    let key: KeyEquivalent
    let accessibilityLabel: String

    var fillColor: Color {
        selectedValues.contains(value) ? Color.blue : Color.secondary
    }

    var body: some View {
        Button {
            if selectedValues.count == maxSelectedValues {
                selectedValues.remove(at: 0)
            }
            selectedValues.append(value)
        } label: {
            label
        }
        .buttonStyle(KeypadButtonStyle(fillColor: fillColor))
        .keyboardShortcut(key, modifiers: [])
        .accessibility(label: Text(accessibilityLabel))
    }

    private static var fontSize: CGFloat { 48 }

    static func font(for string: String) -> Font {
        string.count > 1 ? condensedFont(size: Self.fontSize) : regularFont(size: Self.fontSize)
    }

    init(value: T, selectedValues: Binding<[T]>, maxSelectedValues: Int = 1, string: String, key: KeyEquivalent, accessibilityLabel: String) {
        self.value = value
        self._selectedValues = selectedValues
        self.maxSelectedValues = maxSelectedValues
        self.label = Text(string)
            .font(Self.font(for: string))
            .minimumScaleFactor(0.5)
            .eraseToAnyView()
        self.key = key
        self.accessibilityLabel = accessibilityLabel
    }

    init(value: T, selectedValues: Binding<[T]>, maxSelectedValues: Int = 1, label: Image, color: Color, key: KeyEquivalent, accessibilityLabel: String) {
        self.value = value
        self._selectedValues = selectedValues
        self.maxSelectedValues = maxSelectedValues
        self.label = label
            .resizable()
            .foregroundColor(color)
            .aspectRatio(1, contentMode: .fit)
            .padding(5)
            .eraseToAnyView()
        self.key = key
        self.accessibilityLabel = accessibilityLabel
    }
}
