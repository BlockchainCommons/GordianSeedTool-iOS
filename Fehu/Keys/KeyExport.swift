//
//  KeyExport.swift
//  Guardian
//
//  Created by Wolf McNally on 1/23/21.
//

import SwiftUI
import WolfSwiftUI

struct KeyExport: View {
    @Binding var isPresented: Bool
    @StateObject private var model: KeyExportModel
    @State private var presentedSheet: Sheet? = nil

    init(seed: Seed, isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._model = StateObject(wrappedValue: KeyExportModel(seed: seed))
    }
    
    enum Sheet: Int, Identifiable {
        case ur

        var id: Int { rawValue }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack() {
                    inputSeedSection
                    connectionArrow()
                    parametersSection
                    connectionArrow()
                    outputKeySection
                }
                .onAppear {
                    model.updateKey()
                }
                .navigationBarTitle("Key Export")
                .navigationBarItems(leading: DoneButton { isPresented = false })
            }
        }
        .sheet(item: $presentedSheet) { item -> AnyView in
            let isSheetPresented = Binding<Bool>(
                get: { presentedSheet != nil },
                set: { if !$0 { presentedSheet = nil } }
            )
            switch item {
            case .ur:
                return URView(subject: model.key!, isPresented: isSheetPresented).eraseToAnyView()
            }
        }
        .frame(maxWidth: 500)
        .padding()
        .copyConfirmation()
    }
    
    func connectionArrow() -> some View {
        Image(systemName: "arrowtriangle.down.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.formGroupBackground)
            .frame(height: 30)
    }

    var inputSeedSection: some View {
        GroupBox(label: Text("Input Seed")) {
            ModelObjectIdentity(model: .constant(model.seed))
                .frame(maxHeight: 100)
        }
        .formGroupBoxStyle()
    }

    var parametersSection: some View {
        GroupBox(label: Text("Parameters")) {
            VStack(alignment: .leading) {
                LabeledContent {
                    Text("Asset")
                } content: {
                    SegmentPicker(selection: Binding($model.asset), segments: Asset.allCases)
                }

                LabeledContent {
                    Text("Network")
                } content: {
                    SegmentPicker(selection: Binding($model.network), segments: Network.allCases)
                }

                LabeledContent {
                    Text("Derivation")
                } content: {
                    SegmentPicker(selection: Binding($model.derivation), segments: KeyExportDerivation.allCases)
                }

                SegmentPicker(selection: Binding($model.keyType), segments: KeyType.allCases)
            }
        }
        .formGroupBoxStyle()
    }

    var outputKeySection: some View {
        VStack {
            GroupBox {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Derived Key")
                            .formGroupBoxTitleFont()
                        Spacer()
                        shareMenu
                    }
                    ModelObjectIdentity(model: $model.key)
                        .frame(height: 100)
                }
            }
            .formGroupBoxStyle()
        }
    }

    var shareMenu: some View {
        Menu {
            ContextMenuItem(title: "Copy as Base58", image: Image("58.bar")) {
                PasteboardCoordinator.shared.copyToPasteboard(model.key!.base58!)
            }
            .disabled(model.key?.base58 == nil)
            ContextMenuItem(title: "Export as ur:crypto-hdkey…", image: Image("ur.bar")) {
                presentedSheet = .ur
            }
        } label: {
            Image(systemName: "square.and.arrow.up.on.square")
                .accentColor(.yellowLightSafe)
        }
        .menuStyle(BorderlessButtonMenuStyle())
//        .disabled(!isValid)}
    }
}

#if DEBUG

import WolfLorem

struct KeyExport_Previews: PreviewProvider {
    static let seed = Lorem.seed();
    
    static var previews: some View {
        KeyExport(seed: seed, isPresented: .constant(true))
            .preferredColorScheme(.dark)
    }
}

#endif
