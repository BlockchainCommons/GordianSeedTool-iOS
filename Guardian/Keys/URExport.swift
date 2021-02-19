//
//  URExport.swift
//  Guardian
//
//  Created by Wolf McNally on 2/18/21.
//

import SwiftUI
import URKit
import URUI
import WolfSwiftUI

struct URExport: View {
    @Binding var isPresented: Bool
    let isSensitive: Bool
    let ur: UR
    @StateObject private var displayState: URDisplayState

    init(isPresented: Binding<Bool>, isSensitive: Bool, ur: UR) {
        self._isPresented = isPresented
        self.isSensitive = isSensitive
        self.ur = ur
        self._displayState = StateObject(wrappedValue: URDisplayState(ur: ur, maxFragmentLen: 800))
    }
    
    var body: some View {
        VStack {
            URQRCode(data: .constant(displayState.part))
                .frame(maxWidth: 600)
                .conditionalLongPressAction(actionEnabled: displayState.isSinglePart) {
                    PasteboardCoordinator.shared.copyToPasteboard(
                        makeQRCodeImage(displayState.part, backgroundColor: .white)
                            .scaled(by: 8)
                    )
                }
            
            ExportDataButton("Copy as ur:\(ur.type)", icon: Image("ur.bar"), isSensitive: isSensitive) {
                PasteboardCoordinator.shared.copyToPasteboard(ur)
            }
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

struct URQRView_Previews: PreviewProvider {
    static let seed = Lorem.seed()
    
    static var previews: some View {
        URExport(isPresented: .constant(true), isSensitive: true, ur: TransactionRequest(body: .seed(SeedRequestBody(fingerprint: seed.fingerprint))).ur)
    }
}

#endif
