//
//  ModelObjectExport.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/15/20.
//

import SwiftUI
import WolfSwiftUI
import SwiftUIFlowLayout
import BCApp

struct ModelObjectExport<Subject, Footer>: View where Subject: ObjectIdentifiable & Printable, Footer: View {
    @Binding var isPresented: Bool
    let isSensitive: Bool
    let subject: Subject
    let additionalFlowItems: [AnyView]
    let footer: Footer
    @State var isPrintSetupPresented: Bool = false
    @State private var activityParams: ActivityParams?
    @Environment(Model.self) var model

    init(isPresented: Binding<Bool>, isSensitive: Bool, subject: Subject, items: [AnyView] = [], @ViewBuilder footer: @escaping () -> Footer) {
        self._isPresented = isPresented
        self.isSensitive = isSensitive
        self.subject = subject
        self.additionalFlowItems = items
        self.footer = footer()
    }

    var body: some View {
        var flowItems: [AnyView] = []
        
        if let envelope = subject as? Envelope {
            flowItems.append(ExportDataButton("Share as Gordian Envelope", icon: Image.envelope, isSensitive: isSensitive) {
                activityParams = ActivityParams(
                    envelope.ur,
                    name: subject.name,
                    fields: subject.exportFields
                )
            }.eraseToAnyView())
        } else if let seed = subject as? ModelSeed {
            flowItems.append(
                WriteNFCButton(ur: seed.envelope.ur, isSensitive: true, alertMessage: "Write seed “\(seed.name)”.")
                    .eraseToAnyView()
            )
        } else if let hdKey = subject as? ModelHDKey {
            flowItems.append(
                WriteNFCButton(ur: hdKey.envelope.ur, isSensitive: hdKey.isPrivate, alertMessage: "Write HD Key “\(hdKey.name)”.").eraseToAnyView()
            )
        }
        flowItems.append(ExportDataButton("Share", icon: Image.export, isSensitive: isSensitive) {
            let string: String
            if let subj = subject as? EnvelopeEncodable {
                string = subj.envelope.urString
            } else {
                let (str, _) = subject.sizeLimitedQRString
                string = str
            }
            activityParams = ActivityParams(
                string,
                name: subject.name,
                fields: subject.exportFields
            )
        }.eraseToAnyView())

        flowItems.append(ExportDataButton("Print", icon: Image.print, isSensitive: isSensitive) {
            isPrintSetupPresented = true
        }.eraseToAnyView())
        
        flowItems.append(contentsOf: additionalFlowItems)
        
        return NavigationView {
            VStack {
                ObjectIdentityBlock(model: .constant(subject))
                    .frame(height: 100)
                
                if let envelope = subject as? Envelope {
                    URDisplay(
                        ur: envelope.ur,
                        name: subject.name,
                        fields: subject.exportFields
                    )
                } else if let envelope = (subject as? EnvelopeEncodable)?.envelope {
                    URDisplay(
                        ur: envelope.ur,
                        name: subject.name,
                        fields: subject.exportFields
                    )
                } else {
                    let (string, _) = subject.sizeLimitedQRString
                    URQRCode(data: .constant(string.utf8Data), foregroundColor: .black, backgroundColor: .white)
                        .longPressAction {
                            activityParams = ActivityParams(
                                makeQRCodeImage(string.utf8Data, backgroundColor: .white).scaled(by: 8),
                                name: subject.name,
                                fields: subject.exportFields
                            )
                        }
                }
                
                ScrollView {
                    VStack(alignment: .center) {
                        FlowLayout(mode: .scrollable, items: flowItems) { $0 }
                        footer
                    }
                    .background(ActivityView(params: $activityParams))
                    //                    .padding(20)
                }
            }
            .padding()
            .sheet(isPresented: $isPrintSetupPresented) {
                PrintSetup(subject: .constant(subject), isPresented: $isPrintSetupPresented)
                    .environment(model)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    DoneButton($isPresented)
                }
            }
            .navigationTitle("Export")
            .copyConfirmation()
        }
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
            .environment(model)
            .darkMode()
        ModelObjectExport(isPresented: .constant(true), isSensitive: true, subject: privateHDKey)
            .environment(model)
            .darkMode()
    }
}

#endif
