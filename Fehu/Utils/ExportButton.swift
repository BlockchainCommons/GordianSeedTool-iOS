//
//  ExportButton.swift
//  Guardian
//
//  Created by Wolf McNally on 1/26/21.
//

import SwiftUI

struct ExportButton: View {
    let title: String
    let icon: Image
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            MenuLabel(title: title, icon: icon)
                .accentColor(.yellowLightSafe)
                .font(Font.system(.body).bold())
        }
        .formSectionStyle()
    }
}
