//
//  LockRevealButton.swift
//  Gordian Guardian
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
        HStack {
            Button {
                if authentication.isUnlocked {
                    authentication.lock()
                } else {
                    authentication.attemptUnlock(reason: "Required to view or export the seed data.")
                }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: isRevealed ? "lock.open.fill" : "lock.fill")
                        .padding([.all], 8)
                        .accentColor(.yellowLightSafe)
                        .accessibility(label: Text(isRevealed ? "Lock" : "Unlock"))
                    if !isRevealed {
                        hidden()
                            .padding([.trailing], 10)
                    }
                }
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
            if isRevealed {
                revealed()
            }
        }
        .formSectionStyle()
    }
}

#if DEBUG

import WolfLorem

struct LockRevealButton_Previews: PreviewProvider {
    static var previews: some View {
        LockRevealButton {
            HStack {
                Text(Lorem.sentence())
                    .foregroundColor(Color.primary)
                Button {
                } label: {
                    Label("Foo", systemImage: "printer")
                }
                .padding(5)
            }
        } hidden: {
            Text("Hidden")
                .foregroundColor(Color.secondary)
        }
        .formSectionStyle()
        .darkMode()
    }
}

#endif
