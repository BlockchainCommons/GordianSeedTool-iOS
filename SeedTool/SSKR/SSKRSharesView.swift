//
//  SSKRSharesView.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/10/22.
//

import SwiftUI
import WolfSwiftUI
import os
import BCApp

fileprivate let logger = Logger(subsystem: Application.bundleIdentifier, category: "SSKRSharesView")

enum SSKRShareFormat: String, CaseIterable, Identifiable {
    case envelope = "Envelope"
    case legacy = "UR"
    case bytewords = "ByteWords"
    case qrCode = "QR Code"
    case nfc = "NFC Tag"
    case print = "Print"
    
    var id: String { self.rawValue }
    
    var title: String {
        rawValue
    }
    
    var icon: Image {
        switch self {
        case .envelope:
            return .envelope
        case .legacy:
            return .ur
        case .bytewords:
            return .byteWords
        case .qrCode:
            return .displayQRCode
        case .nfc:
            return .nfc
        case .print:
            return .print
        }
    }
    
    var label: some View {
        Label(title: { Text(title) }, icon: { icon })
    }
}

struct SSKRSharesView: View {
    let sskr: SSKRGenerator
    let sskrModel: SSKRModel
    @Binding var isPresented: Bool
    @State private var activityParams: ActivityParams?
    @State private var shareFormat: SSKRShareFormat = .legacy
    @State private var exportShare: SSKRShareCoupon?
    @State var isPrintSetupPresented: Bool = false
    @State var revealedShare: (groupIndex: Int, shareIndex: Int)? = nil

    internal init(sskr: SSKRGenerator, sskrModel: SSKRModel, isPresented: Binding<Bool>) {
        self.sskr = sskr
        self.sskrModel = sskrModel
        self._isPresented = isPresented
        self._shareFormat = State(initialValue: validFormats.first!)
    }

    var validFormats: [SSKRShareFormat] {
        var formats: [SSKRShareFormat] = []
        
        switch sskrModel.format {
        case .envelope:
            formats.append(.envelope)
        case .legacy:
            formats.append(contentsOf: [.legacy, .bytewords])
        }
        
        formats.append(.qrCode)
        
        if NFCReader.isReadingAvailable || Application.isSimulator {
            formats.append(.nfc)
        }
        
        formats.append(.print)
        
        return formats
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 10) {
                sskr.generatedDate

                HStack {
                    Text("Export Shares As:")
                    shareFormat.label
                    Spacer()
                }
                Picker("Share As", selection: $shareFormat) {
                    ForEach(validFormats) { type in
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
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        DoneButton($isPresented)
                    }
                }
                .background(ActivityView(params: $activityParams))
                .sheet(isPresented: $isPrintSetupPresented) {
                    SSKRPrintSetup(isPresented: $isPrintSetupPresented, sskr: sskr, singleShare: exportShare!)
                }
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
        let isRevealed = Binding<Bool>(
            get: {
                if
                    let revealedShare,
                    revealedShare == (groupIndex: groupIndex, shareIndex: shareIndex)
                {
                    return true
                } else {
                    return false
                }
            },
            set: {
                if $0 {
                    return revealedShare = (groupIndex: groupIndex, shareIndex: shareIndex)
                } else {
                    return revealedShare = nil
                }
            }
        )
        return GroupBox {
            VStack {
                HStack(alignment: .top) {
                    if shareFormat == .nfc {
                        HStack {
                            Spacer()
                            WriteNFCButton(ur: share.ur, isSensitive: true, alertMessage: "Write UR for \(share.name).")
                            Spacer()
                        }
                    } else if shareFormat == .print {
                        HStack {
                            Spacer()
                            ExportDataButton("Print", icon: Image.print, isSensitive: true) {
                                exportShare = share
                                isPrintSetupPresented = true
                            }
                            Spacer()
                        }
                    } else {
                        RevealButton(isRevealed: isRevealed, alignment: .top) {
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
                            case .envelope:
                                activityParams = share.envelopeActivityParams
                            case .legacy:
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
