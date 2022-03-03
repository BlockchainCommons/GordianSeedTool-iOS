//
//  SSKRSummaryPage.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/8/22.
//

import SwiftUI
import WolfBase

struct SSKRSummaryPage: View, Printable {
    let sskr: SSKRGenerator
    let includeNotes: Bool
    let margins: CGFloat = pointsPerInch * 0.25
    
    struct GroupElement: Hashable {
        let index: Int
        let shares: [String]
        let threshold: Int
        
        var count: Int {
            shares.count
        }
        
        var shareIDs: [String] {
            shares.map { share in
                share.split(separator: " ").suffix(4).joined(separator: " ")
            }
        }
    }
    
    var model: SSKRModel {
        sskr.sskrModel
    }
    
    var groups: [GroupElement] {
        (0..<model.groupsCount).map {
            GroupElement(index: $0, shares: sskr.bytewordsGroupShares[$0], threshold: model.groups[$0].threshold)
        }
    }
        
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 0.25 * pointsPerInch) {
                identity
                Spacer()
            }
            .frame(height: pointsPerInch * 2.0)
            
            sskr.generatedDate
            
            Info("The following verification words may be used to establish that printed shares are part of this SSKR share collection. Check them against the last four ByteWords of each share. Only shares that were created at the same time can be used together.")
                .font(.caption)
            
            if model.groups.count > 1 {
                Text(model.note)
            }

            Spacer().frame(height: 1)

            let columns = Array(
                repeating: GridItem(.adaptive(minimum: 100, maximum: 1000), spacing: nil, alignment: .top),
                count: 3
            )
            LazyVGrid(columns: columns, alignment: .leading, spacing: 20) {
                ForEach(groups, id: \.self) { group in
                    groupInfo(group)
                }
            }
            
            if includeNotes {
                BackupPageNoteSection(note: sskr.seed.note)
            }

            Spacer()
        }
        .padding(margins)
    }
    
    func groupInfo(_ group: GroupElement) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            if groups.count > 1 {
                Text("Group \(group.index + 1)")
                    .font(.system(size: 14, weight: .bold))
            }
            if group.count > 1 {
                Text(model.groups[group.index].note)
                    .font(.system(size: 9))
            }
            ForEach(group.shareIDs, id: \.self) { share in
                Text(share)
                    .bold()
                    .monospaced(size: 9)
                    .padding([.top, .bottom], 3)
                    .padding([.leading, .trailing], 20)
                    .background(Color.secondary.opacity(0.2))
            }
        }
    }

    var name: String {
        "SSKR Summary"
    }
    
    var identity: some View {
        ObjectIdentityBlock(model: .constant(sskr.seed), allowLongPressCopy: false, generateVisualHashAsync: false, visualHashWeight: 0.5)
    }

    var printPages: [Self] {
        [self]
    }
    
    var printExportFields: ExportFields {
        sskr.printExportFields
    }
}

#if DEBUG

import WolfLorem

struct SSKRSummaryPage_Previews: PreviewProvider {
    static let model = Lorem.model()
    static let seed = model.seeds.first!
//    static let sskrModel = SSKRPreset.modelTwoOfThreeOfTwoOfThree
    static let sskrModel = SSKRPreset.modelTwoOfThreeOfTwoOfThree
    static let sskr = SSKRGenerator(seed: seed, sskrModel: sskrModel)
    static var previews: some View {
        VStack {
            SSKRSummaryPage(sskr: sskr, includeNotes: true)
//            .environmentObject(model)
        }
        .previewLayout(.fixed(width: 72*8.5, height: 72*11))
//        .darkMode()
    }
}

#endif
