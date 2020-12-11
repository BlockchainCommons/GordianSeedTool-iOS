//
//  FieldRandomTitleButton.swift
//  Fehu
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI
import WolfLorem

struct FieldRandomTitleButton: View {
    @Binding var text: String

    var body: some View {
        Button {
            self.text = Lorem.shortTitle()
        } label: {
            Image(systemName: "die.face.3.fill")
                .foregroundColor(.secondary)
        }
    }
}
