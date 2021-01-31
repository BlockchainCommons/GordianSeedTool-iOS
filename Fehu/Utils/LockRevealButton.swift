//
//  LockRevealButton.swift
//  Fehu
//
//  Created by Wolf McNally on 1/16/21.
//

import SwiftUI

struct LockRevealButton<RevealedContent, HiddenContent>: View where RevealedContent: View, HiddenContent: View {
    let revealed: () -> RevealedContent
    let hidden: () -> HiddenContent
    @State var isRevealed: Bool = false
    @StateObject var authentication: Authentication = Authentication()

    init(@ViewBuilder revealed: @escaping () -> RevealedContent, @ViewBuilder hidden: @escaping () -> HiddenContent) {
        self.revealed = revealed
        self.hidden = hidden
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Button {
                if authentication.isUnlocked {
                    authentication.lock()
                } else {
                    authentication.attemptUnlock(reason: "Required to view or export the seed data.")
                }
            } label: {
                Image(systemName: isRevealed ? "lock.open.fill" : "lock.fill")
                    .padding([.all], 8)
                    .accentColor(.yellowLightSafe)
            }
            isRevealed ? revealed().eraseToAnyView() : hidden().eraseToAnyView()
        }
        .onReceive(authentication.$isUnlocked) { isUnlocked in
            guard isRevealed != isUnlocked else { return }
            withAnimation {
                isRevealed = isUnlocked
            }
            if isRevealed {
                Feedback.unlock.play()
            } else {
                Feedback.lock.play()
            }
        }
    }
}

#if DEBUG

import WolfLorem

struct LockRevealButton_Previews: PreviewProvider {
    static var previews: some View {
        LockRevealButton {
            Text(Lorem.sentence())
        } hidden: {
            Text("Hidden")
        }
        .formSectionStyle()
        .darkMode()
    }
}

#endif
