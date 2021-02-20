//
//  RevealButton.swift
//  Gordian Guardian
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
