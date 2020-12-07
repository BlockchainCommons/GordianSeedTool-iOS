//
//  KeypadButton.swift
//  Fehu
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
    let label: AnyView
    let key: KeyEquivalent

    var fillColor: Color {
        selectedValues.contains(value) ? Color.blue : Color.secondary
    }

    var body: some View {
        Button {
            selectedValues.append(value)
        } label: {
            label
        }
        .buttonStyle(KeypadButtonStyle(fillColor: fillColor))
        .keyboardShortcut(key, modifiers: [])
    }

    private static var fontSize: CGFloat { 48 }

    static func font(for string: String) -> Font {
        string.count > 1 ? condensedFont(size: Self.fontSize) : regularFont(size: Self.fontSize)
    }

    init(value: T, selectedValues: Binding<[T]>, string: String, key: KeyEquivalent) {
        self.value = value
        self._selectedValues = selectedValues
        self.label = AnyView(
            Text(string)
                .font(Self.font(for: string))
                .minimumScaleFactor(0.5)
        )
        self.key = key
    }

    init(value: T, selectedValues: Binding<[T]>, imageName: String, color: Color, key: KeyEquivalent) {
        self.value = value
        self._selectedValues = selectedValues
        self.label = AnyView(
            Image(systemName: imageName)
                .resizable()
                .foregroundColor(color)
                .aspectRatio(1, contentMode: .fit)
                .padding(5)
        )
        self.key = key
    }
}
