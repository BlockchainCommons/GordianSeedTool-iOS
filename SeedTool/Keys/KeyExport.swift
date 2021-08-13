//
//  KeyExport.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/23/21.
//

import SwiftUI
import WolfSwiftUI

struct KeyExport: View {
    @Binding var isPresented: Bool
    @StateObject private var model: KeyExportModel
    @EnvironmentObject private var settings: Settings
    @State private var presentedSheet: Sheet? = nil
    @State private var activityParams: ActivityParams?

    init(seed: Seed, isPresented: Binding<Bool>, network: Network) {
        self._isPresented = isPresented
        self._model = StateObject(wrappedValue: KeyExportModel(seed: seed, network: network))
    }
    
    enum Sheet: Int, Identifiable {
        case privateKey
        case publicKey

        var id: Int { rawValue }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack() {
                    inputSeedSection
                    connectionArrow()
                    parametersSection
                    if model.isValid {
                        connectionArrow()
                        outputKeySection(keyType: .private)
                        connectionArrow()
                        outputKeySection(keyType: .public)
                    }
                }
                .onAppear {
                    model.updateKeys()
                }
                .navigationBarTitle("Key Export")
                .navigationBarItems(trailing: DoneButton($isPresented))
            }
        }
        .sheet(item: $presentedSheet) { item -> AnyView in
            let isSheetPresented = Binding<Bool>(
                get: { presentedSheet != nil },
                set: { if !$0 { presentedSheet = nil } }
            )
            switch item {
            case .privateKey:
                return exportSheet(isPresented: isSheetPresented, key: model.privateKey!).eraseToAnyView()
            case .publicKey:
                return exportSheet(isPresented: isSheetPresented, key: model.publicKey!).eraseToAnyView()
            }
        }
        .frame(maxWidth: 500)
        .padding()
        .background(ActivityView(params: $activityParams))
        .copyConfirmation()
    }
    
    func exportSheet(isPresented: Binding<Bool>, key: HDKey) -> some View {
        let isSensitive = key.keyType.isPrivate
        return ModelObjectExport(isPresented: isPresented, isSensitive: isSensitive, subject: key) {
            ShareButton("Share as Base58", icon: Image("58.bar"), isSensitive: isSensitive, params: ActivityParams(key.base58WithOrigin!))
            if settings.showDeveloperFunctions {
                DeveloperKeyRequestButton(key: key)
                if !key.isMaster {
                    DeveloperDerivationRequestButton(key: key)
                }
                DeveloperKeyResponseButton(key: key)
            }
        }
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
        let derivationPresetSegments = model.derivations.map { derivation in
            KeyExportDerivationPresetSegment(preset: derivation, useInfo: UseInfo(asset: model.asset, network: model.network))
        }
        
        let derivationPresetSegment = Binding<KeyExportDerivationPresetSegment>(
            get: {
                let useInfo = UseInfo(asset: model.asset, network: model.network)
                let preset: KeyExportDerivationPreset
                if model.derivationPathText.trim().isEmpty {
                    preset = .master
                } else if let derivationPath = model.derivationPath {
                    preset = KeyExportDerivationPreset.preset(for: derivationPath)
                } else {
                    preset = .custom
                }
                return KeyExportDerivationPresetSegment(preset: preset, useInfo: useInfo)
            },
            set: {
                model.derivationPathText = $0.pathString ?? ""
            }
        )
        
        let network = Binding<Network>(
            get: {
                model.network
            },
            
            set: {
                model.network = $0
                if let derivationPath = model.derivationPath {
                    let useInfo = UseInfo(asset: model.asset, network: model.network)
                    let preset = KeyExportDerivationPreset.preset(for: derivationPath)
                    let segment = KeyExportDerivationPresetSegment(preset: preset, useInfo: useInfo)
                    model.derivationPathText = segment.pathString ?? ""
                }
            }
        )
        
        let asset = Binding<Asset>(
            get: {
                model.asset
            },
            set: {
                model.asset = $0
                model.derivationPathText = ""
            }
        )
        
        return GroupBox(label: Text("Parameters")) {
            VStack(alignment: .leading) {
                LabeledContent {
                    Text("Asset")
                        .formGroupBoxTitleFont()
                } content: {
                    SegmentPicker(selection: Binding(asset), segments: .constant(Asset.allCases))
                }

                LabeledContent {
                    Text("Network")
                        .formGroupBoxTitleFont()
                } content: {
                    SegmentPicker(selection: Binding(network), segments: .constant(Network.allCases))
                }

                if model.derivations.count > 1 {
                    VStack(alignment: .leading) {
                        Text("Derivation Presets")
                            .formGroupBoxTitleFont()
                        ListPicker(selection: derivationPresetSegment, segments: .constant(derivationPresetSegments))
                            .formSectionStyle()
                        Text("Derivation Path")
                            .formGroupBoxTitleFont()
                        TextField("Derivation Path", text: $model.derivationPathText)
                            .keyboardType(.asciiCapable)
                            .disableAutocorrection(true)
                            .labelsHidden()
                            .formSectionStyle()
                        if !model.isValid {
                            Text("Invalid derivation path.")
                                .font(.footnote)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .formGroupBoxStyle()
        .accessibility(label: Text("Parameters"))
    }

    func outputKeySection(keyType: KeyType) -> some View {
        VStack {
            GroupBox {
                VStack(alignment: .leading, spacing: -10) {
                    HStack(alignment: .top) {
                        Text(keyType.isPrivate ? "Private Key" : "Public Key")
                            .formGroupBoxTitleFont()
                        Spacer()
                        shareButton(for: keyType.isPrivate ? model.privateKey : model.publicKey)
                    }
                    ModelObjectIdentity(model: keyType.isPrivate ? $model.privateKey : $model.publicKey, lifeHashWeight: 0.5)
                        .frame(height: 100)
                        .fixedVertical()
                }
            }
            .formGroupBoxStyle()
        }
        .accessibility(label: Text("Derived Key"))
    }

    func shareButton(for key: HDKey?) -> some View {
        if key != nil {
            return Button {
                presentedSheet = key!.keyType.isPrivate ? .privateKey : .publicKey
            } label: {
                Image(systemName: "square.and.arrow.up.on.square")
                    .accentColor(.yellowLightSafe)
                    .padding(10)
                    .accessibility(label: Text("Share Key Menu"))
                    .accessibilityRemoveTraits(.isImage)
            }
            .eraseToAnyView()
        } else {
            return EmptyView()
                .eraseToAnyView()
        }
    }
}

struct ShareButton<Content>: View where Content: View {
    let content: Content
    let isSensitive: Bool
    let params: ActivityParams
    @State private var activityParams: ActivityParams?
    
    var body: some View {
        ExportDataButton(content: content, isSensitive: isSensitive) {
            activityParams = params
        }
        .background(ActivityView(params: $activityParams))
    }
}

extension ShareButton where Content == MenuLabel<Label<Text, AnyView>> {
    init(_ text: Text, icon: Image, isSensitive: Bool, params: ActivityParams) {
        self.init(content: MenuLabel(text, icon: icon), isSensitive: isSensitive, params: params)
    }

    init(_ string: String, icon: Image, isSensitive: Bool, params: ActivityParams) {
        self.init(Text(string), icon: icon, isSensitive: isSensitive, params: params)
    }
}

struct DeveloperKeyRequestButton: View {
    let key: HDKey
    @State private var isPresented: Bool = false
    
    var body: some View {
        ExportDataButton("Show Request for This Key", icon: Image(systemName: "ladybug.fill"), isSensitive: false) {
            isPresented = true
        }
        .sheet(isPresented: $isPresented) {
            URExport(
                isPresented: $isPresented,
                isSensitive: false,
                ur: TransactionRequest(
                    body: .key(.init(keyType: key.keyType, path: path, useInfo: key.useInfo, isDerivable: key.isDerivable))
                )
                .ur, title: "UR for key request"
            )
        }
    }
    
    var path: DerivationPath {
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
        return path
    }
}

struct DeveloperDerivationRequestButton: View {
    let key: HDKey
    @State private var isPresented: Bool = false
    
    var body: some View {
        ExportDataButton("Show Request for This Derivation", icon: Image(systemName: "ladybug.fill"), isSensitive: false) {
            isPresented = true
        }
        .sheet(isPresented: $isPresented) {
            URExport(
                isPresented: $isPresented,
                isSensitive: false,
                ur: TransactionRequest(
                    body: .key(.init(keyType: key.keyType, path: path, useInfo: key.useInfo))
                )
                .ur, title: "UR for derivation request"
            )
        }
    }

    var path: DerivationPath {
        var path: DerivationPath
        if let origin = key.origin {
            path = origin
            path.sourceFingerprint = nil
        } else {
            // We can't derive from this key
            // Currently never happens
            fatalError()
        }
        return path
    }
}

struct DeveloperKeyResponseButton: View {
    let key: HDKey
    @State private var isPresented: Bool = false
    
    var body: some View {
        ExportDataButton("Show Response for This Key", icon: Image(systemName: "ladybug.fill"), isSensitive: key.keyType.isPrivate) {
            isPresented = true
        }
        .sheet(isPresented: $isPresented) {
            URExport(
                isPresented: $isPresented,
                isSensitive: key.keyType.isPrivate,
                ur: TransactionResponse(
                    id: UUID(),
                    body: .key(key)
                )
                .ur, title: "UR for key response"
            )
        }
    }
}

#if DEBUG

import WolfLorem

struct KeyExport_Previews: PreviewProvider {
    static let seed = Lorem.seed();
    static let settings = Settings(storage: MockSettingsStorage())
    
    static var previews: some View {
        KeyExport(seed: seed, isPresented: .constant(true), network: .testnet)
            .environmentObject(settings)
            .darkMode()
    }
}

#endif
