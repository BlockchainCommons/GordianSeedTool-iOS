//
//  URExport.swift
//  Gordian Seed Tool
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
    let title: String
    @State private var activityParams: ActivityParams?

    init(isPresented: Binding<Bool>, isSensitive: Bool, ur: UR, title: String) {
        self._isPresented = isPresented
        self.isSensitive = isSensitive
        self.ur = ur
        self.title = title
    }
    
    var body: some View {
        VStack {
            URDisplay(ur: ur, title: title)
            ExportDataButton("Share as ur:\(ur.type)", icon: Image("ur.bar"), isSensitive: isSensitive) {
                activityParams = ActivityParams(ur)
            }
        }
        .topBar(leading: DoneButton($isPresented))
        .padding()
        .background(ActivityView(params: $activityParams))
        .copyConfirmation()
    }
}

#if DEBUG

import WolfLorem

struct URExport_Previews: PreviewProvider {
    static let seed = Lorem.seed()
    
    static var previews: some View {
        URExport(isPresented: .constant(true), isSensitive: true, ur: TransactionRequest(body: .seed(SeedRequestBody(fingerprint: seed.fingerprint))).ur, title: "UR for Lorem")
    }
}

#endif
