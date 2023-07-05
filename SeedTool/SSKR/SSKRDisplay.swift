//
//  SSKRDisplay.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/17/20.
//

import SwiftUI
import WolfSwiftUI
import BCApp

struct SSKRDisplay: View {
    @Binding var isSetupPresented: Bool
    @Binding var isPresented: Bool
    @State private var presentedSheet: Sheet? = nil
    @State private var activityParams: ActivityParams?
    @StateObject private var sskr: SSKRGenerator
    @EnvironmentObject private var model: Model

    init(sskr sskrClosure: @autoclosure @escaping () -> SSKRGenerator, isSetupPresented: Binding<Bool>, isPresented: Binding<Bool>) {
        self._sskr = StateObject(wrappedValue: sskrClosure())
        self._isSetupPresented = isSetupPresented
        self._isPresented = isPresented
    }
    
    enum Sheet: Int, Identifiable {
        case printSetup
        case exportShares
        
        var id: Int { rawValue }
    }
    
    var format: SSKRFormat {
        sskr.sskrModel.format
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ObjectIdentityBlock(model: .constant(sskr.seed))
                    .frame(minHeight: 100)

                HStack {
                    sskr.generatedDate
                    Spacer()
                }
                
                Caution("For security, SSKR generation uses random numbers. Because of this, if you leave this screen and then return, the shares shown will be different from and not compatible with the shares available below. Shares created at different times cannot be used together. Be sure to copy all the shares to a safe place.")
                    .font(.callout)

                ExportDataButton("Export Shares Individually", icon: Image.export, isSensitive: true) {
                    presentedSheet = .exportShares
                }

                ExportDataButton("Print All Shares", icon: Image.print, isSensitive: true) {
                    presentedSheet = .printSetup
                }
                
                ExportDataButton("All Shares as ByteWords", icon: Image.byteWords, isSensitive: true) {
                    activityParams = ActivityParams(
                        sskr.bytewordsShares,
                        name: sskr.seed.name,
                        fields: [
                            .placeholder: "SSKR Bytewords \(sskr.seed.name)",
                            .id: sskr.seed.digestIdentifier,
                            .type: "SSKR",
                            .format: "ByteWords"
                        ]
                    )
                }
                
                ExportDataButton("All Shares as \(format.title)", icon: format.icon, isSensitive: true) {
                    activityParams = ActivityParams(
                        sskr.urShares,
                        name: sskr.seed.name,
                        fields: [
                            .placeholder: "SSKR \(format.shortName) \(sskr.seed.name)",
                            .id: sskr.seed.digestIdentifier,
                            .type: "SSKR",
                            .format: format.shortName
                        ]
                    )
                }
            }
            .padding()
        }
        .background(ActivityView(params: $activityParams))
        .sheet(item: $presentedSheet) { item in
            let isSheetPresented = Binding<Bool>(
                get: { presentedSheet != nil },
                set: { if !$0 { presentedSheet = nil } }
            )
            switch item {
            case .printSetup:
                SSKRPrintSetup(isPresented: isSheetPresented, sskr: sskr)
                    .environmentObject(model)
            case .exportShares:
                SSKRSharesView(sskr: sskr, sskrModel: sskr.sskrModel, isPresented: isSheetPresented)
            }
        }
        .navigationTitle("SSKR Export")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                DoneButton($isSetupPresented)
            }
        }
    }
}

struct GroupTitleFont: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.system(.body).smallCaps())
            .foregroundColor(.secondary)
    }
}

extension View {
    func groupTitleFont() -> some View {
        modifier(GroupTitleFont())
    }
}

#if DEBUG

import WolfLorem

struct SSKRDisplay_Previews: PreviewProvider {
    static let model = Lorem.model()
    static let seed = model.seeds.first!
    static let sskr = SSKRGenerator(seed: seed, sskrModel: SSKRPreset.modelTwoOfThreeOfTwoOfThree)
    static var previews: some View {
        NavigationView {
            SSKRDisplay(sskr: sskr, isSetupPresented: .constant(true), isPresented: .constant(true))
                .environmentObject(model)
        }
        .darkMode()
    }
}

#endif
