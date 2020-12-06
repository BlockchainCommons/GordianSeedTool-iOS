//
//  KeypadDeleteButton.swift
//  Fehu
//
//  Created by Wolf McNally on 12/6/20.
//

import SwiftUI

struct KeypadDeleteButton: View {
    @Binding var isEmpty: Bool
    let action: () -> Void

    var body: some View {
        KeypadFunctionButton(imageName: "delete.left", key: .delete) {
            action()
        }.disabled(isEmpty)
    }
}
