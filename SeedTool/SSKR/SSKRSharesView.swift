//
//  SSKRSharesView.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/10/22.
//

import SwiftUI
import URUI
import WolfSwiftUI
import NFC
import os

fileprivate let logger = Logger(subsystem: bundleIdentifier, category: "SSKRSharesView")

enum SSKRShareFormat: String, CaseIterable, Identifiable {
    case ur = "UR"
    case bytewords = "ByteWords"
    case qrCode = "QR Code"
    case nfc = "NFC Tag"
    
    var id: String { self.rawValue }
}

struct SSKRSharesView: View {
    let sskr: SSKRGenerator
    let sskrModel: SSKRModel
    @Binding var isPresented: Bool
    @State private var activityParams: ActivityParams?
    @State private var shareFormat: SSKRShareFormat = .ur
    @State private var shareToWrite: SSKRShareCoupon?

    var validFormats: [SSKRShareFormat] {
        var formats: [SSKRShareFormat] = [.ur, .bytewords, .qrCode]
        if NFCReader.isReadingAvailable {
            formats.append(.nfc)
        }
        return formats
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 10) {
                sskr.generatedDate

                HStack {
                    Text("Export Shares As:")
                    Spacer()
                }
                Picker("Share As", selection: $shareFormat) {
                    ForEach(SSKRShareFormat.allCases) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(.segmented)
//                    .frame(width: 250)

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
                .animation(.easeInOut, value: shareFormat)
                .navigationViewStyle(.stack)
                .navigationBarItems(trailing: DoneButton($isPresented))
                .background(ActivityView(params: $activityParams))
            }
            .padding()
            .copyConfirmation()
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
                    if shareFormat == .nfc {
                        HStack {
                            Spacer()
                            WriteNFCButton(ur: share.ur, isSensitive: true, alertMessage: "Write UR for \(share.name).")
                            Spacer()
                        }
                    } else {
                        RevealButton(alignment: .top) {
                            SSKRShareExportView(share: share, shareType: $shareFormat)
                        } hidden: {
                            HStack {
                                Text("\(shareFormat.rawValue) Hidden")
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                        }
                        .accentColor(.yellowLightSafe)
                        .accessibility(label: Text("Toggle Visibility Group \(groupIndex + 1) Share \(shareIndex + 1)"))
                        
                        Spacer()
                        
                        Button {
                            switch shareFormat {
                            case .bytewords:
                                activityParams = share.bytewordsActivityParams
                            case .ur:
                                activityParams = share.urActivityParams
                            case .qrCode:
                                activityParams = share.qrCodeActivityParams
                            default:
                                break
                            }
                        } label: {
                            Image.share
                                .font(Font.system(.body).bold())
                                .foregroundColor(.yellowLightSafe)
                        }
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
                        activityParams = share.nameActivityParams
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
