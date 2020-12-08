//
//  KeypadButtonStyle.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI
import WolfSwiftUI

let maxButtonSize: CGFloat = 60
let minButtonSize: CGFloat = 40

struct KeypadButtonStyle: ButtonStyle {
    let fillColor: Color

    init(fillColor: Color = .secondary) {
        self.fillColor = fillColor
    }

    func makeBody(configuration: Configuration) -> some View {
        InternalButton(configuration: configuration, fillColor: fillColor)
    }

    struct InternalButton: View {
        let configuration: ButtonStyle.Configuration
        let fillColor: Color
        @Environment(\.isEnabled) private var isEnabled: Bool
        @State private var measuredButtonSize: CGFloat = maxButtonSize
        var body: some View {
            configuration.label
                .padding(5)
                .frame(minWidth: minButtonSize, maxWidth: maxButtonSize, minHeight: minButtonSize, maxHeight: maxButtonSize)
                .aspectRatio(1, contentMode: .fit)
                .background(Rectangle().fill(fillColor).cornerRadius(10).opacity(0.8))
                .foregroundColor(.primary)
                .colorMultiply(configuration.isPressed ? .gray : .white)
                .opacity(isEnabled ? 1.0 : 0.5)
        }
    }
}
