//
//  ContextMenuItem.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/6/20.
//

import SwiftUI

struct ContextMenuItem: View {
    let title: String
    let image: Image
    let action: () -> Void
    let key: KeyEquivalent?

    init(title: String, image: Image, key: KeyEquivalent? = nil, action: @escaping () -> Void) {
        self.title = title
        self.image = image
        self.key = key
        self.action = action
    }

    var body: some View {
        let button = Button(action: action) {
            MenuLabel(title, icon: image)
        }

        if let key = key {
            return button
                .keyboardShortcut(KeyboardShortcut(key, modifiers: [.command]))
                .eraseToAnyView()
        } else {
            return button.eraseToAnyView()
        }
    }
}

struct CopyMenuItem: View {
    let action: () -> Void

    var body: some View {
        ContextMenuItem(title: "Copy", image: Image(systemName: "doc.on.doc"), key: "c", action: action)
    }
}

struct PasteMenuItem: View {
    let action: () -> Void

    var body: some View {
        ContextMenuItem(title: "Paste", image: Image(systemName: "doc.on.clipboard"), key: "v", action: action)
    }
}

struct ClearMenuItem: View {
    let action: () -> Void

    var body: some View {
        ContextMenuItem(title: "Clear", image: Image(systemName: "clear"), action: action)
    }
}
