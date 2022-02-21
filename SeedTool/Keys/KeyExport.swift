//
//  KeyExport.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/23/21.
//

import SwiftUI
import WolfSwiftUI
import BCFoundation
import SwiftUIFlowLayout
import WolfBase

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
        case outputDescriptor
        case outputBundle

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
                        secondaryDerivationSection
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
                return exportSheet(isPresented: isSheetPresented, exportModel: exportModel, key: exportModel.privateHDKey!).eraseToAnyView()
            case .publicHDKey:
                return exportSheet(isPresented: isSheetPresented, exportModel: exportModel, key: exportModel.publicHDKey!).eraseToAnyView()
            case .address:
                return exportSheet(isPresented: isSheetPresented, address: exportModel.address!).eraseToAnyView()
            case .privateECKey:
                return exportSheet(isPresented: isSheetPresented, key: exportModel.privateECKey!).eraseToAnyView()
            case .outputDescriptor:
                return URExport(
                    isPresented: isSheetPresented,
                    isSensitive: false,
                    ur: exportModel.outputDescriptor!.ur,
                    filename: "Output Descriptor from \(masterKeyName)",
                    items: [
                        ShareOutputDescriptorAsTextButton(
                            descriptor: exportModel.outputDescriptor!,
                            filename: "Output Descriptor from \(masterKeyName)"
                        ).eraseToAnyView()
                    ]
                )
                    .eraseToAnyView()
            case .outputBundle:
                return URExport(
                    isPresented: isSheetPresented,
                    isSensitive: false,
                    ur: exportModel.outputBundle!.ur,
                    filename: "Account Descriptor from \(masterKeyName)"
                ).eraseToAnyView()
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
    
    func exportSheet(isPresented: Binding<Bool>, exportModel: KeyExportModel, key: ModelHDKey) -> some View {
        let isSensitive = key.keyType.isPrivate
        var items: [AnyView] = []
        items.append(
            ShareButton(
                "Share as Base58", icon: Image("58.bar"), isSensitive: isSensitive,
                params: ActivityParams(key.transformedBase58WithOrigin!, export: Export(
                    name: key.name,
                    fields: [
                        .placeholder: key.transformedBase58WithOrigin!,
                        .rootID: exportModel.seed.digestIdentifier,
                        .id: key.digestIdentifier,
                        .type: key.typeString,
                        .subType: key.subtypeString,
                        .format: "Base58"
                    ]
                ))
            ).eraseToAnyView()
        )
        if settings.showDeveloperFunctions {
            items.append(DeveloperKeyRequestButton(key: key).eraseToAnyView())
            if !key.isMaster {
                items.append(DeveloperDerivationRequestButton(key: key).eraseToAnyView())
            }
            items.append(DeveloperKeyResponseButton(key: key).eraseToAnyView())
        }
        return ModelObjectExport(isPresented: isPresented, isSensitive: isSensitive, subject: key, items: items)
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

    var addressSection: some View {
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
    
    @ViewBuilder func shareButtonLabel(isSensitive: Bool, accessibilityLabel: Text) -> some View {
        Image(systemName: "square.and.arrow.up.on.square")
            .accentColor(isSensitive ? .yellowLightSafe : .green)
            .padding(10)
            .accessibility(label: accessibilityLabel)
            .accessibilityRemoveTraits(.isImage)
    }

    @ViewBuilder func shareButton(for address: ModelAddress?) -> some View {
        if address == nil {
            EmptyView()
        } else {
            Button {
                presentedSheet = .address
            } label: {
                shareButtonLabel(isSensitive: false, accessibilityLabel: Text("Share Address"))
            }
        }
    }

    @ViewBuilder func shareButton(for address: ModelPrivateKey?) -> some View {
        if address == nil {
            EmptyView()
        } else {
            Button {
                presentedSheet = .privateECKey
            } label: {
                shareButtonLabel(isSensitive: true, accessibilityLabel: Text("Share Private Key"))
            }
        }
    }

    @ViewBuilder func shareButton(for key: ModelHDKey?) -> some View {
        if let key = key {
            Button {
                presentedSheet = key.keyType.isPrivate ? .privateHDKey : .publicHDKey
            } label: {
                shareButtonLabel(isSensitive: key.keyType.isPrivate, accessibilityLabel: Text("Share \(key.keyType.isPrivate ? "Private" : "Public")"))
            }
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder func shareButton(for outputDescriptor: OutputDescriptor?) -> some View {
        if outputDescriptor != nil {
            Button {
                presentedSheet = .outputDescriptor
            } label: {
                shareButtonLabel(isSensitive: false, accessibilityLabel: Text("Output Descriptor"))
            }
        }
    }
    
    @ViewBuilder func shareButton(for outputBundle: OutputDescriptorBundle?) -> some View {
        if outputBundle != nil {
            Button {
                presentedSheet = .outputBundle
            } label: {
                shareButtonLabel(isSensitive: false, accessibilityLabel: Text("Account Descriptor"))
            }
        }
    }
}

extension KeyExport {
    @ViewBuilder var secondaryDerivationSection: some View {
        if(exportModel.allowSecondaryDerivation) {
            VStack {
                AppGroupBox("Secondary Derivation") {
                    VStack(alignment: .leading) {
                        Text("A Bitcoin Master Key can be used several ways.")
                            .font(.caption)
                        ListPicker(selection: $exportModel.secondaryDerivationType, segments: .constant(SecondaryDerivationType.allCases))
                            .formSectionStyle()
                        if exportModel.secondaryDerivationType.requiresAccountNumber {
                            Text("Account Number")
                                .formGroupBoxTitleFont()
                            TextField("Account Number", text: $exportModel.accountNumberText)
                                .keyboardType(.numberPad)
                                .disableAutocorrection(true)
                                .labelsHidden()
                                .formSectionStyle()
                            if exportModel.accountNumber == nil {
                                Text("Invalid account number.")
                                    .font(.footnote)
                                    .foregroundColor(.red)
                            }
                        }
                        if exportModel.accountNumber != nil {
                            if exportModel.secondaryDerivationType == .outputDescriptor {
                                Text("Output Type")
                                    .formGroupBoxTitleFont()
                                ListPicker(selection: $exportModel.outputType, segments: .constant(AccountOutputType.allCases))
                                    .formSectionStyle()
                                    .environmentObject(exportModel)
                            }
                        }
                    }
                }
                switch exportModel.secondaryDerivationType {
                case .publicKey:
                    connectionArrow()
                    publicKeySection
                case .outputDescriptor:
                    if exportModel.accountNumber != nil {
                        connectionArrow()
                        outputDescriptorSection
                    }
                case .outputBundle:
                    if exportModel.accountNumber != nil {
                        connectionArrow()
                        outputDescriptorBundleSection
                    }
                }
            }
        } else {
            publicKeySection
        }
    }
    
    @ViewBuilder var publicKeySection: some View {
        VStack {
            outputKeySection(keyType: .public)
            connectionArrow()
            addressSection
        }
    }
    
    var outputDescriptorSection: some View {
        AppGroupBox {
            VStack(alignment: .leading, spacing: -10) {
                HStack(alignment: .top) {
                    Text("Output Descriptor")
                        .formGroupBoxTitleFont()
                    Spacer()
                    shareButton(for: exportModel.outputDescriptor)
                }
                if let outputDescriptor = exportModel.outputDescriptor {
                    Text(outputDescriptor†)
                        .font(.caption)
                        .monospaced()
                        .longPressAction {
                            activityParams = ActivityParams(outputDescriptor†, export: Export(
                                name: masterKeyName,
                                fields: [
                                    .placeholder: "Output Descriptor for \(masterKeyName) account \(exportModel.accountNumberText)",
                                    .rootID: seedDigestIdentifier,
                                    .id: masterKeyDigestIdentifier,
                                    .subType: exportModel.accountNumberText,
                                    .format: "Output"
                                ]))
                        }
                }
            }
        }
    }
    
    var seedDigestIdentifier: String {
        exportModel.seed.digestIdentifier
    }
    
    var masterKeyName: String {
        exportModel.privateHDKey!.name
    }
    
    var masterKeyDigestIdentifier: String {
        exportModel.privateHDKey!.digestIdentifier
    }
    
    var outputDescriptorBundleSection: some View {
        AppGroupBox {
            VStack(alignment: .leading, spacing: -10) {
                HStack(alignment: .top) {
                    Text("Account Descriptor")
                        .formGroupBoxTitleFont()
                    Spacer()
                    shareButton(for: exportModel.outputBundle)
                }
                if let outputBundle = exportModel.outputBundle {
                    Text(outputBundle.ur.string.truncated(count: 100))
                        .font(.caption)
                        .monospaced()
                        .longPressAction {
                            activityParams = ActivityParams(outputBundle.ur.string, export: Export(name: "Account Descriptor from \(exportModel.seed.name)"))
                        }
                }
            }
        }
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
                    body: .key(.init(keyType: key.keyType, path: key.parent, useInfo: key.useInfo, isDerivable: key.isDerivable))
                )
                .ur, filename: "UR for key request"
            )
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
                .ur, filename: "UR for derivation request"
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
                .ur, filename: "UR for key response"
            )
        }
    }
}

struct ShareOutputDescriptorAsTextButton: View {
    let descriptor: OutputDescriptor
    let filename: String
    @State private var activityParams: ActivityParams?
    
    var body: some View {
        ExportDataButton("Share as text", icon: Image(systemName: "rhombus"), isSensitive: false) {
            activityParams = ActivityParams(descriptor†, export: Export(name: filename))
        }
        .background(ActivityView(params: $activityParams))
    }
}

#if DEBUG

import WolfLorem

struct KeyExport_Previews: PreviewProvider {
    static let settings = Settings(storage: MockSettingsStorage())
    static let model = Lorem.model()
    static let seed = model.seeds.first!

    static var previews: some View {
        KeyExport(seed: seed, isPresented: .constant(true), network: .testnet)
            .environmentObject(model)
            .environmentObject(settings)
            .darkMode()
    }
}

#endif
