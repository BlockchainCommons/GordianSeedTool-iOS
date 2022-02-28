//
//  URExport.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/18/21.
//

import SwiftUI
import URUI
import WolfSwiftUI
import BCFoundation
import SwiftUIFlowLayout

struct URExport: View {
    @Binding var isPresented: Bool
    let isSensitive: Bool
    let ur: UR
    let additionalFlowItems: [AnyView]
    let name: String
    let title: String
    let fields: ExportFields?
    @State private var activityParams: ActivityParams?

    init(isPresented: Binding<Bool>, isSensitive: Bool, ur: UR, name: String, fields: ExportFields? = nil, items: [AnyView] = []) {
        self._isPresented = isPresented
        self.isSensitive = isSensitive
        self.ur = ur
        self.name = name
        var fields = fields ?? [:]
        fields[.format] = "UR"
        self.fields = fields
        self.title = fields[.placeholder] ?? name
        self.additionalFlowItems = items
    }
    
    var body: some View {
        var flowItems: [AnyView] = []
        flowItems.append(
            ExportDataButton("Share as ur:\(ur.type)", icon: Image.ur, isSensitive: isSensitive) {
                activityParams = ActivityParams(
                    ur,
                    name: name,
                    fields: fields
                )
            }.eraseToAnyView()
        )
        flowItems.append(contentsOf: additionalFlowItems)

        return VStack {
            Text(title)
                .font(.largeTitle)
                .bold()
                .minimumScaleFactor(0.5)
#if targetEnvironment(macCatalyst)
            URDisplay(
                ur: ur,
                name: name,
                fields: fields
            )
                .layoutPriority(1)
                .frame(maxHeight: 300)
            FlowLayout(mode: .vstack, items: flowItems, viewMapping: { $0 })
                .fixedVertical()
                .layoutPriority(0.9)
            Spacer()
#else
            URDisplay(
                ur: ur,
                name: name,
                fields: fields
            )
                .layoutPriority(1)
            ScrollView {
                VStack(alignment: .center) {
                    FlowLayout(mode: .scrollable, items: flowItems) { $0 }
                }
            }
            .layoutPriority(0.9)
#endif
        }
        .topBar(trailing: DoneButton($isPresented))
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
        try! URExport(
            isPresented: .constant(true),
            isSensitive: true,
            ur: TransactionRequest(
                body: .seed(
                    SeedRequestBody(digest: seed.fingerprint.digest)
                )
            ).ur,
            name: seed.name,
            fields: [:]
        )
            .darkMode()
    }
}

#endif
