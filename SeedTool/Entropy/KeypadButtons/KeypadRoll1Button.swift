//
//  KeypadRoll1Button.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/8/20.
//

import SwiftUI

struct KeypadRollButton<KeypadType: Keypad>: View {
    let model: EntropyViewModel<KeypadType>
    let text: String
    let accessibilityLabel: String
    let action: () -> Void

    var body: some View {
        KeypadFunctionButton(accessibilityLabel: accessibilityLabel, content: {
            VStack(spacing: 1) {
                Image.dieRolls
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(minWidth: 10, minHeight: 10)
                Text(text)
            }
            .font(Font.system(.title).bold())
            .minimumScaleFactor(0.5)
        }, action: action)
    }
}

struct KeypadRoll1Button<KeypadType: Keypad>: View {
    let model: EntropyViewModel<KeypadType>

    var body: some View {
        KeypadRollButton(model: model, text: "1", accessibilityLabel: "Random 1") {
            model.appendValue(KeypadType.random())
        }
    }
}

struct KeypadRollAllButton<KeypadType: Keypad>: View {
    let model: EntropyViewModel<KeypadType>

    var body: some View {
        KeypadRollButton(model: model, text: "All", accessibilityLabel: "Random All") {
            while(model.entropyStrength != .veryStrong) {
                model.appendValue(KeypadType.random())
            }
        }
    }
}
