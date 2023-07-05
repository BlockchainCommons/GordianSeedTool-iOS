//
//  SSKRPrintSetup.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/7/22.
//

import SwiftUI
import BCApp

struct SSKRPrintSetup: View {
    @EnvironmentObject var model: Model
    @Binding var isPresented: Bool
    @State var summaryPage: Bool
    @State var notesOnSummaryPage: Bool
    @State var multipleSharesPerPage: Bool
    @State var pages: PrintablePages
    @State var singleShare: SSKRShareCoupon?

    let sskr: SSKRGenerator

    init(isPresented: Binding<Bool>, sskr: SSKRGenerator, singleShare: SSKRShareCoupon? = nil) {
        let summaryPage = true
        let notesOnSummaryPage = false
        let multipleSharesPerPage = false
        
        self._summaryPage = State(initialValue: summaryPage)
        self._notesOnSummaryPage = State(initialValue: notesOnSummaryPage)
        self._multipleSharesPerPage = State(initialValue: multipleSharesPerPage)
        self._singleShare = State(initialValue: singleShare)

        self._isPresented = isPresented
        self.sskr = sskr
        self._pages = State(initialValue: Self.updatedPages(sskr: sskr, multipleSharesPerPage: multipleSharesPerPage, summaryPage: summaryPage, notesOnSummaryPage: notesOnSummaryPage, singleShare: singleShare))
    }
    
    var allowsMultipleSharesPerPage: Bool {
        switch sskr.sskrModel.format {
        case .envelope:
            return false
        case .legacy:
            return true
        }
    }
    
    var body: some View {
        PrintSetup(
            subject: $pages,
            isPresented: $isPresented
        ) {
            if singleShare == nil {
                VStack(alignment: .leading) {
                    Toggle("Summary Page", isOn: $summaryPage)
                    Text("Include a first page that can be used to identify each share.")
                        .font(.caption)
                    Toggle("Seed Notes", isOn: $notesOnSummaryPage)
                        .disabled(!summaryPage)
                    Text("Include the Seed Notes field on the first page.")
                        .font(.caption)
                    if allowsMultipleSharesPerPage {
                        Toggle("Multiple Shares Per Page", isOn: $multipleSharesPerPage)
                        Text("Print multiple “share coupons” on each page that need to be cut apart.")
                            .font(.caption)
                    }
                }
            }
        }
        .environmentObject(model)
        .onChange(of: multipleSharesPerPage) { newValue in
            pages = Self.updatedPages(
                sskr: sskr,
                multipleSharesPerPage: newValue,
                summaryPage: summaryPage,
                notesOnSummaryPage: notesOnSummaryPage,
                singleShare: singleShare
            );
        }
        .onChange(of: summaryPage) { newValue in
            pages = Self.updatedPages(
                sskr: sskr,
                multipleSharesPerPage: multipleSharesPerPage,
                summaryPage: newValue,
                notesOnSummaryPage: notesOnSummaryPage,
                singleShare: singleShare
            );
        }
        .onChange(of: notesOnSummaryPage) { newValue in
            pages = Self.updatedPages(
                sskr: sskr,
                multipleSharesPerPage: multipleSharesPerPage,
                summaryPage: summaryPage,
                notesOnSummaryPage: newValue,
                singleShare: singleShare
            );
        }
    }

    static func updatedPages(sskr: SSKRGenerator, multipleSharesPerPage: Bool, summaryPage: Bool, notesOnSummaryPage: Bool, singleShare: SSKRShareCoupon?) -> PrintablePages {
        if let singleShare = singleShare {
            return PrintablePages(name: singleShare.name, printExportFields: singleShare.exportFields(placeholder: singleShare.name), printables: [
                SSKRSharePage(multipleSharesPerPage: false, seed: sskr.seed, coupons: [singleShare]).eraseToAnyPrintable()
            ])
        } else {
            sskr.multipleSharesPerPage = multipleSharesPerPage
            return PrintablePages(name: sskr.name, printExportFields: sskr.printExportFields, printables: [
                summaryPage ? SSKRSummaryPage(sskr: sskr, includeNotes: notesOnSummaryPage).eraseToAnyPrintable() : nil,
                sskr.eraseToAnyPrintable()
            ].compactMap { $0 })
        }
    }
}

#if DEBUG

import WolfLorem

struct SSKRPrintSetup_Previews: PreviewProvider {
    static let model = Lorem.model()
    static let seed = model.seeds.first!
    static let sskrModel = SSKRPreset.modelTwoOfThreeOfTwoOfThree
//    static let sskrModel = SSKRPreset.modelOneOfOne
    static let sskr = SSKRGenerator(seed: seed, sskrModel: sskrModel)
    static var previews: some View {
        VStack {
            SSKRPrintSetup(isPresented: .constant(true), sskr: sskr)
            .environmentObject(model)
        }
        .darkMode()
    }
}

#endif
