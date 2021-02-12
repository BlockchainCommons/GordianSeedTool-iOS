//
//  ExportDataButton.swift
//  Guardian
//
//  Created by Wolf McNally on 1/26/21.
//

import SwiftUI

struct ExportDataButton<Content>: View where Content: View {
    let content: Content
    let isSensitive: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            content
                .font(Font.system(.body).bold())
                .foregroundColor(isSensitive ? .yellowLightSafe : .accentColor)
        }
        .formSectionStyle()
    }
}

extension ExportDataButton where Content == MenuLabel<Label<Text, Image>> {
    init(_ text: Text, icon: Image, isSensitive: Bool, action: @escaping () -> Void) {
        self.init(content: MenuLabel(text, icon: icon), isSensitive: isSensitive, action: action)
    }

    init(_ string: String, icon: Image, isSensitive: Bool, action: @escaping () -> Void) {
        self.init(Text(string), icon: icon, isSensitive: isSensitive, action: action)
    }
}
