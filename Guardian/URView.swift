//
//  URView.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/15/20.
//

import SwiftUI
import URKit
import URUI
import WolfSwiftUI

struct URView<Subject, Footer>: View where Subject: ModelObject, Footer: View {
    @Binding var isPresented: Bool
    let isSensitive: Bool
    let subject: Subject
    let footer: Footer
    @StateObject private var displayState: URDisplayState

    init(isPresented: Binding<Bool>, isSensitive: Bool, subject: Subject, @ViewBuilder footer: @escaping () -> Footer) {
        self._isPresented = isPresented
        self.isSensitive = isSensitive
        self.subject = subject
        self.footer = footer()
        self._displayState = StateObject(wrappedValue: URDisplayState(ur: subject.ur, maxFragmentLen: 800))
    }

    var body: some View {
        VStack {
            ModelObjectIdentity(model: .constant(subject))
            URQRCode(data: .constant(displayState.part))
                .frame(maxWidth: 600)
                .conditionalLongPressAction(actionEnabled: displayState.isSinglePart) {
                    PasteboardCoordinator.shared.copyToPasteboard(
                        makeQRCodeImage(displayState.part, backgroundColor: .white)
                            .scaled(by: 8)
                    )
                }
            
            ExportDataButton("Copy as ur:\(subject.ur.type)", icon: Image("ur.bar"), isSensitive: isSensitive) {
                PasteboardCoordinator.shared.copyToPasteboard(subject.ur)
            }

            footer
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

extension URView where Footer == EmptyView {
    init(isPresented: Binding<Bool>, isSensitive: Bool, subject: Subject) {
        self.init(isPresented: isPresented, isSensitive: isSensitive, subject: subject, footer: { EmptyView() })
    }
}

#if DEBUG

import WolfLorem

struct URView_Previews: PreviewProvider {
    static let seed = Lorem.seed(count: 4000)
    static var previews: some View {
        URView(isPresented: .constant(true), isSensitive: true, subject: seed)
            .darkMode()
    }
}

#endif
