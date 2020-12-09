//
//  KeypadDeleteButton.swift
//  Fehu
//
//  Created by Wolf McNally on 12/6/20.
//

import SwiftUI

struct KeypadDeleteButton<KeypadType: Keypad>: View {
    let model: KeypadViewModel<KeypadType>
    let deleteAction: () -> Void

    var body: some View {
        makeKeypadFunctionButton(imageName: "delete.left", key: .delete) {
            model.values.removeLast()
            deleteAction()
        }
    }
}
