//
//  KeypadFunctionButton.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI

struct KeypadFunctionButton<Content: View>: View {
    let content: () -> Content
    let key: KeyEquivalent?
    let accessibilityLabel: String
    let action: () -> Void

    init(key: KeyEquivalent? = nil, accessibilityLabel: String, @ViewBuilder content: @escaping () -> Content, action: @escaping () -> Void) {
        self.content = content
        self.key = key
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    var body: some View {
        let button = Button {
            action()
        } label: {
            content()
        }
        .buttonStyle(KeypadButtonStyle())
        .accessibilityLabel(Text(accessibilityLabel))

        if let key = key {
            return button
                .keyboardShortcut(key, modifiers: [])
                .eraseToAnyView()
        } else {
            return button
                .eraseToAnyView()
        }
    }
}

func makeKeypadFunctionButton(imageName: String, key: KeyEquivalent? = nil, accessibilityLabel: String, action: @escaping () -> Void) -> KeypadFunctionButton<AnyView> {
    KeypadFunctionButton(
        key: key,
        accessibilityLabel: accessibilityLabel,
        content: {
            Image(systemName: imageName)
                .resizable()
                .foregroundColor(.primary)
                .aspectRatio(1, contentMode: .fit)
                .padding(5)
                .eraseToAnyView()
        },
        action: action)
}
