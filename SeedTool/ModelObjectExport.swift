//
//  ModelObjectExport.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/15/20.
//

import SwiftUI
import URKit
import URUI
import WolfSwiftUI
import LibWally

struct ModelObjectExport<Subject, Footer>: View where Subject: ObjectIdentifiable, Footer: View {
    @Binding var isPresented: Bool
    let isSensitive: Bool
    let subject: Subject
    let footer: Footer
    @State var isPrintSetupPresented: Bool = false
    @State private var activityParams: ActivityParams?
    @EnvironmentObject var model: Model

    init(isPresented: Binding<Bool>, isSensitive: Bool, subject: Subject, @ViewBuilder footer: @escaping () -> Footer) {
        self._isPresented = isPresented
        self.isSensitive = isSensitive
        self.subject = subject
        self.footer = footer()
    }

    var body: some View {
        VStack {
            ObjectIdentityBlock(model: .constant(subject))
            
            if let ur = (subject as? HasUR)?.ur {
                URDisplay(ur: ur, title: "UR for \(subject.name)")
                
                ExportDataButton("Share as ur:\(ur.type)", icon: Image("ur.bar"), isSensitive: isSensitive) {
                    activityParams = ActivityParams(ur)
                }
            } else {
                URQRCode(data: .constant(subject.sizeLimitedQRString.utf8Data))

                ExportDataButton("Share", icon: Image(systemName: "square.and.arrow.up.on.square"), isSensitive: isSensitive) {
                    activityParams = ActivityParams(subject.sizeLimitedQRString)
                }
            }

            ExportDataButton("Print", icon: Image(systemName: "printer"), isSensitive: isSensitive) {
                isPrintSetupPresented = true
            }

            footer
        }
        .sheet(isPresented: $isPrintSetupPresented) {
            PrintSetup(subject: subject, isPresented: $isPrintSetupPresented)
        }
        .topBar(trailing: DoneButton($isPresented))
        .padding()
        .copyConfirmation()
        .background(ActivityView(params: $activityParams))
    }
}

extension ModelObjectExport where Footer == EmptyView {
    init(isPresented: Binding<Bool>, isSensitive: Bool, subject: Subject) {
        self.init(isPresented: isPresented, isSensitive: isSensitive, subject: subject, footer: { EmptyView() })
    }
}

#if DEBUG

import WolfLorem

struct URView_Previews: PreviewProvider {
    static let model = Lorem.model()
    static let seed = model.seeds.first!
    static let privateHDKey = KeyExportModel.deriveCosignerKey(seed: Lorem.seed(), network: .testnet, keyType: .public)
    static var previews: some View {
        ModelObjectExport(isPresented: .constant(true), isSensitive: true, subject: seed)
            .environmentObject(model)
            .darkMode()
        ModelObjectExport(isPresented: .constant(true), isSensitive: true, subject: privateHDKey)
            .environmentObject(model)
            .darkMode()
    }
}

#endif
