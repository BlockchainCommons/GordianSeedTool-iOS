//
//  KeypadFunctionButton.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI

struct KeypadFunctionButton<Content: View>: View {
    let label: Content
    let key: KeyEquivalent?
    let action: () -> Void

    init(key: KeyEquivalent? = nil, @ViewBuilder content: () -> Content, action: @escaping () -> Void) {
        self.label = content()
        self.key = key
        self.action = action
    }

    var body: some View {
        let button = Button {
            action()
        } label: {
            label
        }
        .buttonStyle(KeypadButtonStyle())

        if let key = key {
            return AnyView(
                button
                    .keyboardShortcut(key, modifiers: [])
            )
        } else {
            return AnyView(button)
        }
    }
}

func makeKeypadFunctionButton(imageName: String, key: KeyEquivalent? = nil, action: @escaping () -> Void) -> KeypadFunctionButton<AnyView> {
    KeypadFunctionButton(
        key: key,
        content: {
            AnyView(
                Image(systemName: imageName)
                    .resizable()
                    .foregroundColor(.primary)
                    .aspectRatio(1, contentMode: .fit)
                    .padding(5)
            )                                    },
        action: action)
}
