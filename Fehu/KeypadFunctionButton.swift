//
//  KeypadFunctionButton.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI

struct KeypadFunctionButton: View {
    let label: AnyView
    let key: KeyEquivalent?
    let action: () -> Void

    init(label: AnyView, key: KeyEquivalent? = nil, action: @escaping () -> Void) {
        self.label = label
        self.key = key
        self.action = action
    }

    init(imageName: String, key: KeyEquivalent? = nil, action: @escaping () -> Void) {
        self.key = key
        self.action = action
        self.label = AnyView(
            Image(systemName: imageName)
                .resizable()
                .foregroundColor(.primary)
                .aspectRatio(1, contentMode: .fit)
                .padding(5)
        )
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
