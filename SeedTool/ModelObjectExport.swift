//
//  ModelObjectExport.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/15/20.
//

import SwiftUI
import URUI
import WolfSwiftUI
import BCFoundation
import SwiftUIFlowLayout

struct ModelObjectExport<Subject, Footer>: View where Subject: ObjectIdentifiable, Footer: View {
    @Binding var isPresented: Bool
    let isSensitive: Bool
    let subject: Subject
    let additionalFlowItems: [AnyView]
    let footer: Footer
    @State var isPrintSetupPresented: Bool = false
    @State private var activityParams: ActivityParams?
    @EnvironmentObject var model: Model

    init(isPresented: Binding<Bool>, isSensitive: Bool, subject: Subject, items: [AnyView] = [], @ViewBuilder footer: @escaping () -> Footer) {
        self._isPresented = isPresented
        self.isSensitive = isSensitive
        self.subject = subject
        self.additionalFlowItems = items
        self.footer = footer()
    }

    var body: some View {
        var flowItems: [AnyView] = []

        if let ur = (subject as? HasUR)?.ur {
            flowItems.append(ExportDataButton("Share as ur:\(ur.type)", icon: Image("ur.bar"), isSensitive: isSensitive) {
                activityParams = ActivityParams(ur, name: subject.name, fields: subject.exportFields)
            }.eraseToAnyView())
        } else {
            flowItems.append(ExportDataButton("Share", icon: Image(systemName: "square.and.arrow.up.on.square"), isSensitive: isSensitive) {
                let (string, _) = subject.sizeLimitedQRString
                activityParams = ActivityParams(string, name: subject.name, fields: subject.exportFields)
            }.eraseToAnyView())
        }

        flowItems.append(ExportDataButton("Print", icon: Image(systemName: "printer"), isSensitive: isSensitive) {
            isPrintSetupPresented = true
        }.eraseToAnyView())
        
        flowItems.append(contentsOf: additionalFlowItems)

        return VStack {
            ObjectIdentityBlock(model: .constant(subject))
            
            if let ur = (subject as? HasUR)?.ur {
                URDisplay(ur: ur, name: "UR for \(subject.name)")
            } else {
                let (string, _) = subject.sizeLimitedQRString
                URQRCode(data: .constant(string.utf8Data))
            }

            ScrollView {
                VStack(alignment: .center) {
                    FlowLayout(mode: .scrollable, items: flowItems) { $0 }
                    footer
                }
            }
        }
        .sheet(isPresented: $isPrintSetupPresented) {
            PrintSetup(subject: .constant(subject), isPresented: $isPrintSetupPresented)
                .environmentObject(model)
        }
        .topBar(
            trailing:
                DoneButton($isPresented)
        )
        .padding()
        .copyConfirmation()
        .background(ActivityView(params: $activityParams))
    }
}

extension ModelObjectExport where Footer == EmptyView {
    init(isPresented: Binding<Bool>, isSensitive: Bool, subject: Subject, items: [AnyView] = []) {
        self.init(isPresented: isPresented, isSensitive: isSensitive, subject: subject, items: items, footer: { EmptyView() })
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
