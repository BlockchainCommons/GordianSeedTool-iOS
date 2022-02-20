//
//  URDisplay.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/19/21.
//

import SwiftUI
import BCFoundation
import URUI

struct URDisplay: View {
    @StateObject private var displayState: URDisplayState
    @State private var activityParams: ActivityParams?
    let filename: String

    init(ur: UR, filename: String) {
        self._displayState = StateObject(wrappedValue: URDisplayState(ur: ur, maxFragmentLen: 600))
        self.filename = filename
    }
    
    var body: some View {
        URQRCode(data: .constant(displayState.part), foregroundColor: .black, backgroundColor: .white)
            .frame(maxWidth: 600)
            .conditionalLongPressAction(actionEnabled: displayState.isSinglePart) {
                activityParams = ActivityParams(makeQRCodeImage(displayState.part, backgroundColor: .white).scaled(by: 8), export: Export(name: filename))
            }
            .onAppear {
                displayState.framesPerSecond = 3
                displayState.run()
            }
            .onDisappear() {
                displayState.stop()
            }
            .background(ActivityView(params: $activityParams))
            .accessibility(label: Text("QR Code"))
    }
}

#if DEBUG

import WolfLorem

struct URDisplay_Previews: PreviewProvider {
    static let ur = Lorem.seed().ur

    static var previews: some View {
        Group {
            URDisplay(ur: ur, filename: "Lorem")
        }
        .darkMode()
    }
}

#endif
