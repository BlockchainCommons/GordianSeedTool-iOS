//
//  FieldClearButton.swift
//  Fehu
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI

struct FieldClearButton: View {
    @Binding var text: String

    var body: some View {
        Button {
            self.text = ""
        } label: {
            Image(systemName: "multiply.circle.fill")
                .foregroundColor(.secondary)
        }
    }
}
