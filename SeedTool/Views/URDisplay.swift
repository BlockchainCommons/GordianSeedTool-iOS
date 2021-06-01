//
//  URDisplay.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/19/21.
//

import SwiftUI
import URKit
import URUI

struct URDisplay: View {
    @StateObject private var displayState: URDisplayState
    
    init(ur: UR) {
        self._displayState = StateObject(wrappedValue: URDisplayState(ur: ur, maxFragmentLen: 800))
    }
    
    var body: some View {
        URQRCode(data: .constant(displayState.part))
            .frame(maxWidth: 600)
            .conditionalLongPressAction(actionEnabled: displayState.isSinglePart) {
                PasteboardCoordinator.shared.copyToPasteboard(
                    makeQRCodeImage(displayState.part, backgroundColor: .white)
                        .scaled(by: 8)
                )
            }
            .onAppear {
                displayState.framesPerSecond = 3
                displayState.run()
            }
            .onDisappear() {
                displayState.stop()
            }
            .accessibility(label: Text("QR Code"))
    }
}

#if DEBUG

import WolfLorem

struct URDisplay_Previews: PreviewProvider {
    static let ur = Lorem.seed().ur

    static var previews: some View {
        Group {
            URDisplay(ur: ur)
        }
        .darkMode()
    }
}

#endif
