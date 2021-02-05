//
//  FieldClearButton.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI

struct ClearButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "multiply.circle.fill")
                .foregroundColor(.secondary)
        }
    }
}

struct FieldClearButton: View {
    @Binding var text: String

    var body: some View {
        ClearButton {
            self.text = ""
        }
    }
}
