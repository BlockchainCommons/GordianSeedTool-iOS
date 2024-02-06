//
//  KeypadDeleteButton.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/6/20.
//

import SwiftUI

struct KeypadDeleteButton<KeypadType: Keypad>: View {
    let model: EntropyViewModel<KeypadType>
    let deleteAction: () -> Void

    var body: some View {
        makeKeypadFunctionButton(image: Image.deletePrevious, key: .delete, accessibilityLabel: "Delete") {
            model.removeLastValue()
            deleteAction()
        }
    }
}
