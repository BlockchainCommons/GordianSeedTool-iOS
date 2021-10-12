//
//  KeyExport.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/23/21.
//

import SwiftUI
import WolfSwiftUI
import LibWally

struct KeyExport: View {
    @Binding var isPresented: Bool
    @StateObject private var exportModel: KeyExportModel
    @EnvironmentObject private var model: Model
    @EnvironmentObject private var settings: Settings
    @State private var presentedSheet: Sheet? = nil
    @State private var activityParams: ActivityParams?

    init(seed: ModelSeed, isPresented: Binding<Bool>, network: Network) {
        self._isPresented = isPresented
        self._exportModel = StateObject(wrappedValue: KeyExportModel(seed: seed, network: network))
    }
    
    enum Sheet: Int, Identifiable {
        case privateHDKey
        case publicHDKey
        case address
        case privateECKey

        var id: Int { rawValue }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack() {
                    inputSeedSection
                    connectionArrow()
                    parametersSection
                    if exportModel.isValid {
                        connectionArrow()
                        outputKeySection(keyType: .private)
                        if exportModel.asset == .eth {
                            privateKeySection()
                        }
                        connectionArrow()
                        outputKeySection(keyType: .public)
                        addressSection()
                    }
                }
                .onAppear {
                    exportModel.updateKeys()
                }
                .navigationBarTitle("Key Export")
                .navigationBarItems(trailing: DoneButton($isPresented).accessibilityLabel(Text("Export Done")))
            }
        }
        .sheet(item: $presentedSheet) { item -> AnyView in
            let isSheetPresented = Binding<Bool>(
                get: { presentedSheet != nil },
                set: { if !$0 { presentedSheet = nil } }
            )
            switch item {
            case .privateHDKey:
                return exportSheet(isPresented: isSheetPresented, key: exportModel.privateHDKey!).eraseToAnyView()
            case .publicHDKey:
                return exportSheet(isPresented: isSheetPresented, key: exportModel.publicHDKey!).eraseToAnyView()
            case .address:
                return exportSheet(isPresented: isSheetPresented, address: exportModel.address!).eraseToAnyView()
            case .privateECKey:
                return exportSheet(isPresented: isSheetPresented, key: exportModel.privateECKey!).eraseToAnyView()
            }
        }
        .frame(maxWidth: 500)
        .padding()
        .background(ActivityView(params: $activityParams))
        .copyConfirmation()
        .onAppear {
            exportModel.asset = settings.primaryAsset
            exportModel.derivationPathText = exportModel.asset.defaultDerivation.path(useInfo: exportModel.useInfo).description
        }
    }
    
    func exportSheet(isPresented: Binding<Bool>, key: ModelHDKey) -> some View {
        let isSensitive = key.keyType.isPrivate
        return ModelObjectExport(isPresented: isPresented, isSensitive: isSensitive, subject: key) {
            ShareButton("Share as Base58", icon: Image("58.bar"), isSensitive: isSensitive, params: ActivityParams(key.transformedBase58WithOrigin!))
            if settings.showDeveloperFunctions {
                DeveloperKeyRequestButton(key: key)
                if !key.isMaster {
                    DeveloperDerivationRequestButton(key: key)
                }
                DeveloperKeyResponseButton(key: key)
            }
        }
    }
    
    func exportSheet(isPresented: Binding<Bool>, address: ModelAddress) -> some View {
        return ModelObjectExport(isPresented: isPresented, isSensitive: false, subject: address)
    }
    
    func exportSheet(isPresented: Binding<Bool>, key: ModelPrivateKey) -> some View {
        return ModelObjectExport(isPresented: isPresented, isSensitive: false, subject: key)
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
        AppGroupBox("Input Seed") {
            ObjectIdentityBlock(model: .constant(exportModel.seed))
                .frame(height: 100)
        }
        .accessibility(label: Text("Input Seed"))
    }

    var parametersSection: some View {
        let derivationPresetSegments = Binding<[KeyExportDerivationPresetSegment]>(
            get: {
                exportModel.derivations.map { derivation in
                    KeyExportDerivationPresetSegment(preset: derivation, useInfo: exportModel.useInfo)
                }
            },
            set: { _ in
                fatalError()
            }
        )
        
        let derivationPresetSegment = Binding<KeyExportDerivationPresetSegment>(
            get: {
                let preset: KeyExportDerivationPreset
                if exportModel.derivationPathText.trim().isEmpty {
                    preset = .master
                } else if let derivationPath = exportModel.derivationPath {
                    preset = KeyExportDerivationPreset.preset(asset: exportModel.asset, path: derivationPath)
                } else {
                    preset = exportModel.asset.defaultDerivation
                }
                return KeyExportDerivationPresetSegment(preset: preset, useInfo: exportModel.useInfo)
            },
            set: {
                exportModel.derivationPathText = $0.pathString ?? ""
            }
        )
        
        let network = Binding<Network>(
            get: {
                exportModel.network
            },
            
            set: {
                exportModel.network = $0
                if let derivationPath = exportModel.derivationPath {
                    let preset = KeyExportDerivationPreset.preset(asset: exportModel.asset, path: derivationPath)
                    let segment = KeyExportDerivationPresetSegment(preset: preset, useInfo: exportModel.useInfo)
                    exportModel.derivationPathText = segment.pathString ?? ""
                }
            }
        )
        
        let asset = Binding<Asset>(
            get: {
                exportModel.asset
            },
            set: {
                exportModel.asset = $0
                let preset = KeyExportDerivationPresetSegment(preset: exportModel.asset.defaultDerivation, useInfo: exportModel.useInfo)
                exportModel.derivationPathText = preset.pathString ?? ""
            }
        )
        
        return AppGroupBox("Parameters") {
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

                VStack(alignment: .leading) {
                    Text("Derivation Presets")
                        .formGroupBoxTitleFont()
                    ListPicker(selection: derivationPresetSegment, segments: derivationPresetSegments)
                        .formSectionStyle()
                    HStack {
                        Text("Derivation Path")
                        Spacer()
                        UserGuideButton(openToChapter: .whatIsKeyDerivation)
                    }
                    .formGroupBoxTitleFont()
                    TextField("Derivation Path", text: $exportModel.derivationPathText)
                        .keyboardType(.asciiCapable)
                        .disableAutocorrection(true)
                        .labelsHidden()
                        .formSectionStyle()
                    if !exportModel.isValid {
                        Text("Invalid derivation path.")
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .accessibility(label: Text("Parameters"))
    }

    func outputKeySection(keyType: KeyType) -> some View {
        VStack {
            AppGroupBox {
                VStack(alignment: .leading, spacing: -10) {
                    HStack(alignment: .top) {
                        Text(keyType.isPrivate ? "Private HD Key" : "Public HD Key")
                            .formGroupBoxTitleFont()
                        Spacer()
                        shareButton(for: keyType.isPrivate ? exportModel.privateHDKey : exportModel.publicHDKey)
                    }
                    ObjectIdentityBlock(model: keyType.isPrivate ? $exportModel.privateHDKey : $exportModel.publicHDKey, visualHashWeight: 0.5)
                        .frame(height: 100)
                        .fixedVertical()
                }
            }
        }
        .accessibility(label: Text("Derived Key"))
    }
    
    func privateKeySection() -> some View {
        AppGroupBox {
            VStack(alignment: .leading, spacing: -10) {
                HStack(alignment: .top) {
                    Text("Private Key")
                        .formGroupBoxTitleFont()
                    Spacer()
                    shareButton(for: exportModel.privateECKey)
                }
                ObjectIdentityBlock(model: $exportModel.privateECKey, visualHashWeight: 0.5)
                    .frame(height: 100)
                    .fixedVertical()
            }
        }
    }

    func addressSection() -> some View {
        AppGroupBox {
            VStack(alignment: .leading, spacing: -10) {
                HStack(alignment: .top) {
                    Text("Address")
                        .formGroupBoxTitleFont()
                    Spacer()
                    shareButton(for: exportModel.address)
                }
                ObjectIdentityBlock(model: $exportModel.address, visualHashWeight: 0.5)
                    .frame(height: 100)
                    .fixedVertical()
            }
        }
    }

    func shareButton(for address: ModelAddress?) -> some View {
        guard address != nil else {
            return EmptyView()
                .eraseToAnyView()
        }

        return Button {
            presentedSheet = .address
        } label: {
            Image(systemName: "square.and.arrow.up.on.square")
                .accentColor(.green)
                .padding(10)
                .accessibility(label: Text("Share Address"))
                .accessibilityRemoveTraits(.isImage)
        }
        .eraseToAnyView()
    }

    func shareButton(for address: ModelPrivateKey?) -> some View {
        guard address != nil else {
            return EmptyView()
                .eraseToAnyView()
        }

        return Button {
            presentedSheet = .privateECKey
        } label: {
            Image(systemName: "square.and.arrow.up.on.square")
                .accentColor(.yellowLightSafe)
                .padding(10)
                .accessibility(label: Text("Share Private Key"))
                .accessibilityRemoveTraits(.isImage)
        }
        .eraseToAnyView()
    }

    func shareButton(for key: ModelHDKey?) -> some View {
        guard let key = key else {
            return EmptyView()
                .eraseToAnyView()
        }

        return Button {
            presentedSheet = key.keyType.isPrivate ? .privateHDKey : .publicHDKey
        } label: {
            Image(systemName: "square.and.arrow.up.on.square")
                .accentColor(key.keyType.isPrivate ? .yellowLightSafe : .green)
                .padding(10)
                .accessibility(label: Text("Share \(key.keyType.isPrivate ? "Private" : "Public")"))
                .accessibilityRemoveTraits(.isImage)
        }
        .eraseToAnyView()
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
    let key: ModelHDKey
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
        if !key.parent.isEmpty {
            return key.parent
        } else if key.isMaster {
            return DerivationPath(origin: .fingerprint(key.keyFingerprint))
        } else {
            // We can't derive from this key
            // Currently never happens
            fatalError()
        }
    }
}

struct DeveloperDerivationRequestButton: View {
    let key: ModelHDKey
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
        var result = key.parent
        result.origin = nil
        return result
    }
}

struct DeveloperKeyResponseButton: View {
    let key: ModelHDKey
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
