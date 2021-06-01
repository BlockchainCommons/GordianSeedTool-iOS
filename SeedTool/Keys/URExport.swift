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

    init(isPresented: Binding<Bool>, isSensitive: Bool, ur: UR) {
        self._isPresented = isPresented
        self.isSensitive = isSensitive
        self.ur = ur
    }
    
    var body: some View {
        VStack {
            URDisplay(ur: ur)
            
            ExportDataButton("Copy as ur:\(ur.type)", icon: Image("ur.bar"), isSensitive: isSensitive) {
                PasteboardCoordinator.shared.copyToPasteboard(ur)
            }
        }
        .topBar(leading: DoneButton($isPresented))
        .padding()
        .copyConfirmation()
    }
}

#if DEBUG

import WolfLorem

struct URExport_Previews: PreviewProvider {
    static let seed = Lorem.seed()
    
    static var previews: some View {
        URExport(isPresented: .constant(true), isSensitive: true, ur: TransactionRequest(body: .seed(SeedRequestBody(fingerprint: seed.fingerprint))).ur)
    }
}

#endif
