//
//  ContextMenuItem.swift
//  Fehu
//
//  Created by Wolf McNally on 12/6/20.
//

import SwiftUI

struct ContextMenuItem: View {
    let title: String
    let imageName: String
    let action: () -> Void
    let key: KeyEquivalent?

    init(title: String, imageName: String, key: KeyEquivalent? = nil, action: @escaping () -> Void) {
        self.title = title
        self.imageName = imageName
        self.key = key
        self.action = action
    }

    var body: some View {
        let button = Button(action: action) {
            Label(title, systemImage: imageName)
        }

        if let key = key {
            return AnyView(
                button.keyboardShortcut(KeyboardShortcut(key, modifiers: [.command]))
            )
        } else {
            return AnyView(button)
        }
    }
}

struct CopyMenuItem: View {
    let action: () -> Void

    var body: some View {
        ContextMenuItem(title: "Copy", imageName: "doc.on.doc", key: "c", action: action)
    }
}

struct PasteMenuItem: View {
    let action: () -> Void

    var body: some View {
        ContextMenuItem(title: "Paste", imageName: "doc.on.clipboard", key: "v", action: action)
    }
}

struct ClearMenuItem: View {
    let action: () -> Void

    var body: some View {
        ContextMenuItem(title: "Clear", imageName: "clear", action: action)
    }
}
