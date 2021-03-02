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
        case debugKeyRequest
        case debugDerivationRequest
        case debugResponse

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
                    #if DEBUG
                    debugRequestAndResponse
                    #endif
                }
                .onAppear {
                    model.updateKey()
                }
                .navigationBarTitle("Key Export")
                .navigationBarItems(leading: DoneButton($isPresented))
            }
        }
        .sheet(item: $presentedSheet) { item -> AnyView in
            let isSheetPresented = Binding<Bool>(
                get: { presentedSheet != nil },
                set: { if !$0 { presentedSheet = nil } }
            )
            switch item {
            case .ur:
                return ModelObjectExport(isPresented: isSheetPresented, isSensitive: model.key!.keyType == .private, subject: model.key!).eraseToAnyView()
            case .debugKeyRequest:
                let key = model.key!
                let path: DerivationPath
                if let origin = key.origin {
                    path = origin
                } else if key.isMaster {
                    path = DerivationPath(sourceFingerprint: key.keyFingerprint)
                } else {
                    // We can't derive from this key
                    // Currently never happens
                    fatalError()
                }
                return URExport(
                    isPresented: isSheetPresented,
                    isSensitive: false,
                    ur: TransactionRequest(
                        body: .key(.init(keyType: key.keyType, path: path, useInfo: key.useInfo))
                    )
                    .ur
                )
                .eraseToAnyView()
            case .debugDerivationRequest:
                let key = model.key!
                var path: DerivationPath
                if let origin = key.origin {
                    path = origin
                    path.sourceFingerprint = nil
                } else {
                    // We can't derive from this key
                    // Currently never happens
                    fatalError()
                }
                return URExport(
                    isPresented: isSheetPresented,
                    isSensitive: false,
                    ur: TransactionRequest(
                        body: .key(.init(keyType: key.keyType, path: path, useInfo: key.useInfo))
                    )
                    .ur
                )
                .eraseToAnyView()
            case .debugResponse:
                let key = model.key!
                return URExport(
                    isPresented: isSheetPresented,
                    isSensitive: true,
                    ur: TransactionResponse(
                        id: UUID(),
                        body: .key(key)
                    )
                    .ur
                )
                .eraseToAnyView()
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
            .accessibilityHidden(true)
    }

    var inputSeedSection: some View {
        GroupBox(label: Text("Input Seed")) {
            ModelObjectIdentity(model: .constant(model.seed))
                .frame(height: 100)
        }
        .formGroupBoxStyle()
        .accessibility(label: Text("Input Seed"))
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

                SegmentPicker(selection: Binding($model.keyType), segments: [KeyType.public, KeyType.private])
            }
        }
        .formGroupBoxStyle()
        .accessibility(label: Text("Parameters"))
    }

    var outputKeySection: some View {
        VStack {
            GroupBox {
                VStack(alignment: .leading, spacing: -10) {
                    HStack(alignment: .top) {
                        Text("Derived Key")
                            .formGroupBoxTitleFont()
                        Spacer()
                        shareMenu
                    }
                    ModelObjectIdentity(model: $model.key, lifeHashWeight: 0.5)
                        .frame(height: 100)
                        .fixedVertical()
                }
            }
            .formGroupBoxStyle()
        }
        .accessibility(label: Text("Derived Key"))
    }

    var debugRequestAndResponse: some View {
        Bug {
            VStack(alignment: .leading) {
                Button {
                    presentedSheet = .debugKeyRequest
                } label: {
                    Text("Show Request for This Key")
                        .bold()
                }

                Button {
                    presentedSheet = .debugResponse
                } label: {
                    Text("Show Response for This Key")
                        .bold()
                }

                Button {
                    presentedSheet = .debugDerivationRequest
                } label: {
                    Text("Show Request for This Derivation")
                        .bold()
                }
            }
        }
    }

    var shareMenu: some View {
        Menu {
            ContextMenuItem(title: "Copy as Base58", image: Image("58.bar")) {
                //
                // Copies in the form:
                // [4dc13e01/48'/1'/0'/2']tpubDFNgyGvb9fXoB4yw4RcVjpuNvcrfbW5mgTewNvgcyyxyp7unnJpsBXnNorJUiSMyCTYriPXrsV8HEEE8CyyvUmA5g42fmJ8KNYC5hSXGQqG
                //
                let key = model.key!
                let base58 = key.base58!
                
                var result: [String] = []
                if let originDescription = key.origin?.description {
                    result.append("[\(originDescription)]")
                }
                result.append(base58)
                let content = result.joined();
                PasteboardCoordinator.shared.copyToPasteboard(content)
            }
            .disabled(model.key?.base58 == nil)
            ContextMenuItem(title: "Export as ur:crypto-hdkey…", image: Image("ur.bar")) {
                presentedSheet = .ur
            }
        } label: {
            Image(systemName: "square.and.arrow.up.on.square")
                .accentColor(.yellowLightSafe)
                .padding(10)
                .accessibility(label: Text("Share Key Menu"))
                .accessibilityRemoveTraits(.isImage)
        }
        .menuStyle(BorderlessButtonMenuStyle())
    }
}

#if DEBUG

import WolfLorem

struct KeyExport_Previews: PreviewProvider {
    static let seed = Lorem.seed();
    
    static var previews: some View {
        KeyExport(seed: seed, isPresented: .constant(true))
            .darkMode()
    }
}

#endif
