//
//  SSKRDisplay.swift
//  Fehu
//
//  Created by Wolf McNally on 12/17/20.
//

import SwiftUI
import WolfSwiftUI

struct SSKRDisplay: View {
    let seed: Seed
    @ObservedObject var model: SSKRModel
    @Binding var isPresented: Bool
    let sskr: SSKRGenerator

    init(seed: Seed, model: SSKRModel, isPresented: Binding<Bool>) {
        self.seed = seed
        self.model = model
        self._isPresented = isPresented

        self.sskr = SSKRGenerator(seed: seed, model: model)
    }

    var body: some View {
        ScrollView {
            VStack {
                VStack(spacing: 20) {
                    ModelObjectIdentity(model: .constant(seed))
                        .frame(minHeight: 100)
                    GroupBox {
                        RevealButton {
                            Text("⚠️ For security, SSKR generation uses random numbers. Because of this, if you leave this screen and then return, the shares shown will be different from and not compatible with the shares shown below. Be sure to copy all the shares shown to a safe place.")
                                .fixedVertical()
                        } hidden: {
                            Text("⚠️ Be sure to copy all the shares shown to a safe place.")
                                .fixedVertical()
                        }
                    }
                }

                VStack {
                    ExportButton(title: "Copy all shares as Bytewords", icon: Image("bytewords.bar")) {
                        PasteboardCoordinator.shared.copyToPasteboard(sskr.bytewordsShares)
                    }
                    
                    ExportButton(title: "Copy all shares as ur:crypto-sskr", icon: Image("ur.bar")) {
                        PasteboardCoordinator.shared.copyToPasteboard(sskr.urShares)
                    }
                }

                ConditionalGroupBox(isVisible: model.groups.count > 1) {
                    Text(model.note)
                        .font(.caption)
                } content: {
                    ForEach(sskr.bytewordsGroupShares.indices, id: \.self) { groupIndex in
                        groupView(groupIndex: groupIndex, groupsCount: sskr.bytewordsGroupShares.count, note: model.groups[groupIndex].note, shares: sskr.bytewordsGroupShares[groupIndex])
                    }
                }
            }
            .padding()
        }
        .navigationTitle("SSKR Export")
        .navigationBarItems(trailing: DoneButton() { isPresented = false } )
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
                    shareView(shareIndex: shareIndex, sharesCount: shares.count, share: shares[shareIndex])
                }
            }
        }
    }

    func shareView(shareIndex: Int, sharesCount: Int, share: String) -> some View {
        ConditionalGroupBox(isVisible: sharesCount > 1) {
            Text("Share \(shareIndex + 1)")
                .groupTitleFont()
        } content: {
            HStack(alignment: .firstTextBaseline) {
                RevealButton {
                    Text(share)
                        .font(.system(.body, design: .monospaced))
                        .fixedVertical()
                        .longPressAction {
                            PasteboardCoordinator.shared.copyToPasteboard(share)
                        }
                } hidden: {
                    Text("Hidden")
                        .foregroundColor(.secondary)
                }
                .accentColor(.yellowLightSafe)

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
//    static let model = SSKRModel(groupThreshold: 1, groups: [SSKRModelGroup(threshold: 1, count: 1)])
//    static let model = SSKRModel(groupThreshold: 1, groups: [SSKRModelGroup(threshold: 2, count: 3)])
    static let model = SSKRModel(groupThreshold: 2, groups: [SSKRModelGroup(threshold: 2, count: 3), SSKRModelGroup(threshold: 2, count: 3), SSKRModelGroup(threshold: 3, count: 5)])
    static var previews: some View {
        NavigationView {
            SSKRDisplay(seed: seed, model: model, isPresented: .constant(true))
        }
        .preferredColorScheme(.dark)
    }
}

#endif
