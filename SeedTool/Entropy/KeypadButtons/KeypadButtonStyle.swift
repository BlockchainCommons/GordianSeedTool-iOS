//
//  KeypadButtonStyle.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI
import WolfSwiftUI

let maxButtonSize: CGFloat = 60
let minButtonSize: CGFloat = 35

struct KeypadButtonSize: EnvironmentKey {
    static let defaultValue: CGFloat = maxButtonSize
}

extension EnvironmentValues {
    var keypadButtonSize: CGFloat {
        get { self[KeypadButtonSize.self] }
        set { self[KeypadButtonSize.self] = newValue }
    }
}

extension View {
    func keypadButtonSize(_ size: CGFloat) -> some View {
        environment(\.keypadButtonSize, size)
    }
}

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
        @Environment(\.keypadButtonSize) private var keypadButtonSize: CGFloat
        @State private var measuredButtonSize: CGFloat = maxButtonSize
        var body: some View {
            configuration.label
                .padding(5)
                .frame(width: keypadButtonSize, height: keypadButtonSize)
                .background(Rectangle().fill(fillColor).cornerRadius(10).opacity(0.8))
                .foregroundColor(.primary)
                .colorMultiply(configuration.isPressed ? .gray : .white)
                .opacity(isEnabled ? 1.0 : 0.5)
        }
    }
}
