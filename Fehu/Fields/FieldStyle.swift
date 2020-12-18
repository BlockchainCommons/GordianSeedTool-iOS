//
//  FieldStyle.swift
//  Fehu
//
//  Created by Wolf McNally on 12/11/20.
//

import SwiftUI

struct FieldStyle: ViewModifier {
    let isVisible: Bool

    func body(content: Content) -> some View {
        content
            .padding(isVisible ? 10 : 0)
            .background(isVisible ? Color(UIColor.quaternaryLabel) : Color.clear)
            .cornerRadius(isVisible ? 10 : 0)
    }
}

extension View {
    func fieldStyle(isVisible: Bool = true) -> some View {
        modifier(FieldStyle(isVisible: isVisible))
    }
}

struct ConditionalGroupBox<Label, Content>: View where Label : View, Content : View {
    let isVisible: Bool
    let label: () -> Label
    let content: () -> Content

    init(isVisible: Bool = true, @ViewBuilder label: @escaping () -> Label, @ViewBuilder content: @escaping () -> Content) {
        self.isVisible = isVisible
        self.label = label
        self.content = content
    }

    var body: some View {
        if isVisible {
            return GroupBox(label: label(), content: content).eraseToAnyView()
        } else {
            return content().eraseToAnyView()
        }
    }
}
