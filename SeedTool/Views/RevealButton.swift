//
//  RevealButton.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/17/20.
//

import SwiftUI

struct RevealButton<RevealedContent, HiddenContent>: View where RevealedContent: View, HiddenContent: View {
    let revealed: () -> RevealedContent
    let hidden: () -> HiddenContent
    @State var isRevealed: Bool = false

    init(@ViewBuilder revealed: @escaping () -> RevealedContent, @ViewBuilder hidden: @escaping () -> HiddenContent) {
        self.revealed = revealed
        self.hidden = hidden
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Button {
                withAnimation {
                    isRevealed.toggle()
                }
            } label: {
                Image(systemName: isRevealed ? "eye.slash" : "eye")
            }
            isRevealed ? revealed().eraseToAnyView() : hidden().eraseToAnyView()
        }
    }
}

struct RevealButton2<RevealedContent, HiddenContent>: View where RevealedContent: View, HiddenContent: View {
    let iconSystemName: String
    let isSensitive: Bool
    let revealed: () -> RevealedContent
    let hidden: () -> HiddenContent
    @State var isRevealed: Bool = false

    init(iconSystemName: String = "lock.fill", isSensitive: Bool = false, @ViewBuilder revealed: @escaping () -> RevealedContent, @ViewBuilder hidden: @escaping () -> HiddenContent) {
        self.iconSystemName = iconSystemName
        self.isSensitive = isSensitive
        self.revealed = revealed
        self.hidden = hidden
    }

    var body: some View {
        HStack {
            Button {
                withAnimation {
                    isRevealed.toggle()
                }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: isRevealed ? "eye.slash" : iconSystemName)
//                        .padding([.all], 8)
                        .accentColor(isSensitive ? .yellowLightSafe : .accentColor)
                        .accessibility(label: Text(isRevealed ? "Hide" : "Reveal"))
                    if !isRevealed {
                        hidden()
                            .padding([.trailing], 10)
                    }
                }
            }
            if isRevealed {
                revealed()
            }
        }
        .formSectionStyle()
    }
}

#if DEBUG

import WolfLorem

struct RevealButton_Previews: PreviewProvider {
    static var previews: some View {
        RevealButton {
            Text(Lorem.sentence())
        } hidden: {
            Text("Hidden")
        }
        .formSectionStyle()
        .darkMode()
    }
}

#endif
