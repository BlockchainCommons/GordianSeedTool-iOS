//
//  KeypadFunctionButtons.swift
//  Fehu
//
//  Created by Wolf McNally on 12/9/20.
//

import SwiftUI

struct KeypadFunctionButtons<KeypadType: Keypad>: View {
    let model: KeypadViewModel<KeypadType>
    let deleteAction: () -> Void

    var body: some View {
        HStack {
            KeypadDeleteButton(model: model, deleteAction: deleteAction)
                .disabled(model.values.isEmpty)
            KeypadRoll1Button(model: model)
            KeypadRollAllButton(model: model)
                .disabled(model.entropyStrength == .veryStrong)
        }
        .padding(.top, 10)
    }
}
