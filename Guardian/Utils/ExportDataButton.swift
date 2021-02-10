//
//  ExportDataButton.swift
//  Guardian
//
//  Created by Wolf McNally on 1/26/21.
//

import SwiftUI

struct ExportDataButton: View {
    let text: Text
    let icon: Image
    let isSensitive: Bool
    let action: () -> Void
    
    init(_ text: Text, icon: Image, isSensitive: Bool, action: @escaping () -> Void) {
        self.text = text
        self.icon = icon
        self.isSensitive = isSensitive
        self.action = action
    }
    
    init(_ string: String, icon: Image, isSensitive: Bool, action: @escaping () -> Void) {
        self.init(Text(string), icon: icon, isSensitive: isSensitive, action: action)
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            MenuLabel(text, icon: icon)
                .font(Font.system(.body).bold())
                .foregroundColor(isSensitive ? .yellowLightSafe : .accentColor)
        }
        .formSectionStyle()
    }
}
