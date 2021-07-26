//
//  SSKRDisplay.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/17/20.
//

import SwiftUI
import WolfSwiftUI

struct SSKRDisplay: View {
    let seed: Seed
    let sskrModel: SSKRModel
    @Binding var isSetupPresented: Bool
    @Binding var isPresented: Bool
    let sskr: SSKRGenerator
    @State var isPrintSetupPresented: Bool = false
    @State private var activityParams: ActivityParams?

    init(seed: Seed, sskrModel: SSKRModel, isSetupPresented: Binding<Bool>, isPresented: Binding<Bool>) {
        self.seed = seed
        self.sskrModel = sskrModel
        self._isSetupPresented = isSetupPresented
        self._isPresented = isPresented

        self.sskr = SSKRGenerator(seed: seed, sskrModel: sskrModel)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                ModelObjectIdentity(model: .constant(seed))
                    .frame(minHeight: 100)

                Caution("For security, SSKR generation uses random numbers. Because of this, if you leave this screen and then return, the shares shown will be different from and not compatible with the shares shown below. Be sure to copy all the shares shown to a safe place.")

                ExportDataButton("Print All Shares", icon: Image(systemName: "printer"), isSensitive: true) {
                    isPrintSetupPresented = true
                }
                
                ExportDataButton("Share All as ByteWords", icon: Image("bytewords.bar"), isSensitive: true) {
                    activityParams = ActivityParams(sskr.bytewordsShares)
                }
                
                ExportDataButton("Share All as ur:crypto-sskr", icon: Image("ur.bar"), isSensitive: true) {
                    activityParams = ActivityParams(sskr.urShares)
                }

                ConditionalGroupBox(isVisible: sskrModel.groups.count > 1) {
                    Text(sskrModel.note)
                        .font(.caption)
                } content: {
                    ForEach(sskr.bytewordsGroupShares.indices, id: \.self) { groupIndex in
                        groupView(groupIndex: groupIndex, groupsCount: sskr.bytewordsGroupShares.count, note: sskrModel.groups[groupIndex].note, shares: sskr.bytewordsGroupShares[groupIndex])
                    }
                }
            }
            .padding()
        }
        .background(ActivityView(params: $activityParams))
        .sheet(isPresented: $isPrintSetupPresented) {
            PrintSetup(subject: sskr, isPresented: $isPrintSetupPresented)
        }
        .navigationTitle("SSKR Export")
        .navigationBarItems(trailing: DoneButton($isSetupPresented))
    }

    func groupView(groupIndex: Int, groupsCount: Int, note: String, shares: [String]) -> some View {
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
    }

    func shareView(groupIndex: Int, shareIndex: Int, sharesCount: Int, share: String) -> some View {
        ConditionalGroupBox(isVisible: sharesCount > 1) {
            Text("Share \(shareIndex + 1)")
                .groupTitleFont()
        } content: {
            HStack(alignment: .firstTextBaseline) {
                RevealButton {
                    Text(share)
                        .monospaced()
                        .fixedVertical()
                        .longPressAction {
                            activityParams = ActivityParams(share)
                        }
                } hidden: {
                    Text("Hidden")
                        .foregroundColor(.secondary)
                }
                .accentColor(.yellowLightSafe)
                .accessibility(label: Text("Toggle Visibility Group \(groupIndex + 1) Share \(shareIndex + 1)"))

                Spacer()

                //Button {
                //    copyToPasteboard(share, isConfirmationPresented: $isCopyConfirmationPresented)
                //} label: {
                //    Image(systemName: "doc.on.doc")
                //}
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
    static let seed = Lorem.seed()
    static var previews: some View {
        NavigationView {
            SSKRDisplay(seed: seed, sskrModel: SSKRPreset.modelTwoOfThreeOfTwoOfThree, isSetupPresented: .constant(true), isPresented: .constant(true))
        }
        .darkMode()
    }
}

#endif
