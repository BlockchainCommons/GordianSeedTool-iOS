//
//  KeypadDeleteButton.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/6/20.
//

import SwiftUI

struct KeypadDeleteButton<KeypadType: Keypad>: View {
    let model: EntropyViewModel<KeypadType>
    let deleteAction: () -> Void

    var body: some View {
        makeKeypadFunctionButton(imageName: "delete.left", key: .delete, accessibilityLabel: "Delete") {
            model.values.removeLast()
            deleteAction()
        }
    }
}
