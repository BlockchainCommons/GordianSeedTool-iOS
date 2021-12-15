//
//  ContextMenuItem.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/6/20.
//

import SwiftUI

struct ContextMenuItem: View {
    let title: Text
    let image: Image
    let action: () -> Void
    let key: KeyEquivalent?

    init(title: Text, image: Image, key: KeyEquivalent? = nil, action: @escaping () -> Void) {
        self.title = title
        self.image = image
        self.key = key
        self.action = action
    }

    init(title: String, image: Image, key: KeyEquivalent? = nil, action: @escaping () -> Void) {
        self.init(title: Text(title), image: image, action: action)
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

struct ShareMenuItem: View {
    let action: () -> Void

    var body: some View {
        ContextMenuItem(title: "Share", image: Image(systemName: "square.and.arrow.up"), key: "s", action: action)
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
