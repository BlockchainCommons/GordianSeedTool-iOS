//
//  ExportButton.swift
//  Guardian
//
//  Created by Wolf McNally on 1/26/21.
//

import SwiftUI

struct ExportSafeDataButton: View {
    let text: Text
    let icon: Image
    let action: () -> Void
    
    init(_ text: Text, icon: Image, action: @escaping () -> Void) {
        self.text = text
        self.icon = icon
        self.action = action
    }
    
    init(_ string: String, icon: Image, action: @escaping () -> Void) {
        self.init(Text(string), icon: icon, action: action)
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            MenuLabel(text, icon: icon)
                .font(Font.system(.body).bold())
        }
        .formSectionStyle()
    }
}

struct ExportSensitiveDataButton: View {
    let text: Text
    let icon: Image
    let action: () -> Void
    
    init(_ text: Text, icon: Image, action: @escaping () -> Void) {
        self.text = text
        self.icon = icon
        self.action = action
    }
    
    init(_ string: String, icon: Image, action: @escaping () -> Void) {
        self.init(Text(string), icon: icon, action: action)
    }

    var body: some View {
        ExportSafeDataButton(text, icon: icon, action: action)
    }
}
