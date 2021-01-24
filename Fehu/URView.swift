//
//  URView.swift
//  Fehu
//
//  Created by Wolf McNally on 12/15/20.
//

import SwiftUI
import URKit
import URUI
import WolfSwiftUI

struct URView<T: ModelObject>: View {
    let subject: T
    @Binding var isPresented: Bool
    @StateObject private var displayState: URDisplayState
    @EnvironmentObject var pasteboardCoordinator: PasteboardCoordinator

    init(subject: T, isPresented: Binding<Bool>) {
        self.subject = subject
        self._isPresented = isPresented
        self._displayState = StateObject(wrappedValue: URDisplayState(ur: subject.ur, maxFragmentLen: 800))
    }

    var body: some View {
        VStack {
            ModelObjectIdentity(modelObject: subject)
            URQRCode(data: .constant(displayState.part))
                .frame(maxWidth: 600)
                .conditionalLongPressAction(actionEnabled: displayState.isSinglePart) {
                    pasteboardCoordinator.copyToPasteboard(
                        makeQRCodeImage(displayState.part, backgroundColor: .white)
                            .scaled(by: 8)
                    )
                }
            Button {
                pasteboardCoordinator.copyToPasteboard(subject.ur)
            } label: {
                MenuLabel(title: "Copy as ur:\(subject.ur.type)", icon: Image("ur.bar"))
                    .accentColor(.yellow)
                    .font(Font.system(.body).bold())
            }
            .fieldStyle()
        }
        .onAppear {
            displayState.framesPerSecond = 3
            displayState.run()
        }
        .onDisappear() {
            displayState.stop()
        }
        .topBar(leading: doneButton)
        .padding()
        .copyConfirmation()
    }

    var doneButton: some View {
        DoneButton() {
            isPresented = false
        }
    }
}

#if DEBUG

import WolfLorem

struct URView_Previews: PreviewProvider {
    static let seed = Lorem.seed(count: 4000)
    static var previews: some View {
        URView(subject: seed, isPresented: .constant(true))
            .preferredColorScheme(.dark)
    }
}

#endif
