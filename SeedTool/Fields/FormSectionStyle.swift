//
//  FormSectionStyle.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/11/20.
//

import SwiftUI

struct FormSectionStyle: ViewModifier {
    let isVisible: Bool

    func body(content: Content) -> some View {
        content
            .padding(isVisible ? 10 : 0)
            .background(isVisible ? Color(UIColor.formGroupBackground) : Color.clear)
            .cornerRadius(isVisible ? 10 : 0)
    }
}

extension View {
    func formSectionStyle(isVisible: Bool = true) -> some View {
        modifier(FormSectionStyle(isVisible: isVisible))
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

struct FormGroupBoxTitleFont: ViewModifier {
    func body(content: Content) -> some View {
        content.font(Font.system(.headline).smallCaps())
    }
}

extension View {
    func formGroupBoxTitleFont() -> some View {
        modifier(FormGroupBoxTitleFont())
    }
}

struct FormGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label.formGroupBoxTitleFont()
            configuration.content
                .formSectionStyle()
        }
    }
}

extension View {
    func formGroupBoxStyle() -> some View {
        groupBoxStyle(FormGroupBoxStyle())
    }
}
