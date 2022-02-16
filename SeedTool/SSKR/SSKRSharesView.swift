//
//  SSKRSharesView.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/10/22.
//

import SwiftUI
import URUI
import WolfSwiftUI

enum SSKRShareType: String, CaseIterable, Identifiable {
    case bytewords = "ByteWords"
    case ur = "UR"
    case qrCode = "QR Code"
    
    var id: String { self.rawValue }
}

struct SSKRSharesView: View {
    let sskr: SSKRGenerator
    let sskrModel: SSKRModel
    @Binding var isPresented: Bool
    @State private var activityParams: ActivityParams?
    @State private var shareType: SSKRShareType = .bytewords
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                sskr.generatedDate

                HStack {
                    Text("Export Shares As")
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                    Picker("Share As", selection: $shareType) {
                        ForEach(SSKRShareType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 250)
                }

                ScrollView {
                    ConditionalGroupBox(isVisible: sskrModel.groups.count > 1) {
                        Text(sskrModel.note)
                            .font(.caption)
                    } content: {
                        VStack(spacing: 20) {
                            ForEach(sskr.groupedShareCoupons.indices, id: \.self) { groupIndex in
                                groupView(groupIndex: groupIndex, groupsCount: sskr.groupedShareCoupons.count, note: sskrModel.groups[groupIndex].note, shares: sskr.groupedShareCoupons[groupIndex])
                            }
                        }
                    }
                    .groupBoxStyle(AppGroupBoxStyle())
                }
                .navigationTitle("SSKR \(sskr.seed.name)")
                .animation(.easeInOut, value: shareType)
                .navigationViewStyle(.stack)
                .navigationBarItems(trailing: DoneButton($isPresented))
                .background(ActivityView(params: $activityParams))
            }
            .padding()
        }
    }
    
    func groupView(groupIndex: Int, groupsCount: Int, note: String, shares: [SSKRShareCoupon]) -> some View {
        ConditionalGroupBox(isVisible: groupsCount > 1) {
            if groupsCount > 1 {
                Text("Group \(groupIndex + 1)")
                    .groupTitleFont()
            }
        } content: {
            VStack(alignment: .leading) {
                if shares.count > 1 {
                    Text(note)
                        .font(.caption)
                }
                ForEach(shares.indices, id: \.self) { shareIndex in
                    shareView(groupIndex: groupIndex, shareIndex: shareIndex, sharesCount: shares.count, share: shares[shareIndex])
                }
            }
        }
        .groupBoxStyle(AppGroupBoxStyle())
    }
    
    func shareView(groupIndex: Int, shareIndex: Int, sharesCount: Int, share: SSKRShareCoupon) -> some View {
        GroupBox {
            VStack {
                HStack(alignment: .top) {
                    RevealButton(alignment: .top) {
                        SSKRShareExportView(share: share, shareType: $shareType)
                    } hidden: {
                        HStack {
                            Text("Hidden")
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }
                    .accentColor(.yellowLightSafe)
                    .accessibility(label: Text("Toggle Visibility Group \(groupIndex + 1) Share \(shareIndex + 1)"))
                    
                    Spacer()
                    
                    Button {
                        switch shareType {
                        case .bytewords:
                            activityParams = share.bytewordsActivityParams
                        case .ur:
                            activityParams = share.urActivityParams
                        case .qrCode:
                            activityParams = share.qrCodeActivityParams
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(Font.system(.body).bold())
                            .foregroundColor(.yellowLightSafe)
                    }
                }
            }
        } label: {
            HStack(alignment: .firstTextBaseline) {
                if sharesCount > 1 {
                    Text("Share \(shareIndex + 1)")
                        .groupTitleFont()
                    Spacer().frame(maxWidth: 20)
                }
                Spacer()
                Text(share.bytewordsChecksum)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .font(Font.system(.body).bold().smallCaps().monospaced())
                    .longPressAction {
                        activityParams = ActivityParams(share.title, title: share.title)
                    }
            }
        }
        .groupBoxStyle(AppGroupBoxStyle())
    }
}

struct AppGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading) {
            configuration.label
            configuration.content
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.secondary.opacity(0.1)))
    }
}

#if DEBUG

import WolfLorem

struct SSKRSharesView_Previews: PreviewProvider {
    static let model = Lorem.model()
    static let seed = model.seeds.first!
    static let sskrModel = SSKRPreset.modelTwoOfThreeOfTwoOfThree
    static let sskr = SSKRGenerator(seed: seed, sskrModel: sskrModel)
    static var previews: some View {
        SSKRSharesView(sskr: sskr, sskrModel: sskrModel, isPresented: .constant(true))
            .environmentObject(model)
            .darkMode()
    }
}

#endif
