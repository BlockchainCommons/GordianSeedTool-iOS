//
//  SeedDetail.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI
import Combine
import SwiftUIFlowLayout
import BCFoundation

struct SeedDetail: View {
    @ObservedObject var seed: ModelSeed
    @Binding var isValid: Bool
    @Binding var selectionID: UUID?
    let saveWhenChanged: Bool
    let provideSuggestedName: Bool
    @State private var isEditingNameField: Bool = false
    @State private var presentedSheet: Sheet? = nil
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var model: Model
    @State private var activityParams: ActivityParams?
    @State private var isResponseRevealed: Bool = false
    @FocusState private var nameIsFocused: Bool
    @FocusState private var notesIsFocused: Bool

    private var seedCreationDate: Binding<Date> {
        Binding<Date>(get: {
            return seed.creationDate ?? Date()
        }, set: {
            seed.creationDate = $0
        })
    }

    init(seed: ModelSeed, saveWhenChanged: Bool, provideSuggestedName: Bool = false, isValid: Binding<Bool>, selectionID: Binding<UUID?>) {
        self.seed = seed
        self.saveWhenChanged = saveWhenChanged
        self.provideSuggestedName = provideSuggestedName
        _isValid = isValid
        _selectionID = selectionID
    }

    enum Sheet: Int, Identifiable {
        case seedUR
        case cosignerPublicKey
        case cosignerPrivateKey
        case ethereumAddress
        case ethereumPrivateKey
        case sskr
        case key
        case debugRequest
        case debugResponse

        var id: Int { rawValue }
    }
    
    var body: some View {
        if selectionID == seed.id {
            main
        } else {
            EmptyView()
        }
    }
    
    var main: some View {
        ScrollView {
            VStack(spacing: 20) {
                identity
                details
                publicKey
                encryptedData
                nameView
                creationDate
                notes
            }
            .frame(maxWidth: 600)
            .padding()
        }
        .onReceive(seed.needsSavePublisher) { _ in
            if saveWhenChanged {
                seed.save(model: model, replicateToCloud: true)
            }
        }
        .onReceive(seed.isValidPublisher) {
            isValid = $0
        }
        .navigationBarBackButtonHidden(!isValid)
        .navigationBarTitleDisplayMode(.inline)
        .background(ActivityView(params: $activityParams))
        .sheet(item: $presentedSheet) { item -> AnyView in
            let isSheetPresented = Binding<Bool>(
                get: { presentedSheet != nil },
                set: { if !$0 { presentedSheet = nil } }
            )
            switch item {
            case .seedUR:
                return ModelObjectExport(isPresented: isSheetPresented, isSensitive: true, subject: seed)
                    .environmentObject(model)
                    .eraseToAnyView()
            case .cosignerPublicKey:
                return ModelObjectExport(isPresented: isSheetPresented, isSensitive: false, subject: KeyExportModel.deriveCosignerKey(seed: seed, network: settings.defaultNetwork, keyType: .public))
                    .environmentObject(model)
                    .eraseToAnyView()
            case .cosignerPrivateKey:
                return ModelObjectExport(isPresented: isSheetPresented, isSensitive: true, subject: KeyExportModel.deriveCosignerKey(seed: seed, network: settings.defaultNetwork, keyType: .private))
                    .environmentObject(model)
                    .eraseToAnyView()
            case .ethereumAddress:
                return ModelObjectExport(isPresented: isSheetPresented, isSensitive: false, subject: KeyExportModel.deriveAddress(seed: seed, useInfo: UseInfo(asset: .eth, network: settings.defaultNetwork)))
                    .environmentObject(model)
                    .eraseToAnyView()
            case .ethereumPrivateKey:
                return ModelObjectExport(isPresented: isSheetPresented, isSensitive: false, subject: KeyExportModel.derivePrivateECKey(seed: seed, useInfo: UseInfo(asset: .eth, network: settings.defaultNetwork)))
                    .environmentObject(model)
                    .eraseToAnyView()
            case .sskr:
                return SSKRSetup(seed: seed, isPresented: isSheetPresented)
                    .environmentObject(model)
                    .eraseToAnyView()
            case .key:
                return KeyExport(seed: seed, isPresented: isSheetPresented, network: settings.defaultNetwork)
                    .environmentObject(model)
                    .environmentObject(settings)
                    .eraseToAnyView()
            case .debugRequest:
                return try! URExport(
                    isPresented: isSheetPresented,
                    isSensitive: false,
                    ur: TransactionRequest(
                        body: .seed(SeedRequestBody(digest: seed.fingerprint.digest))
                    )
                    .ur, filename: "UR for seed request"
                )
                .eraseToAnyView()
            case .debugResponse:
                return URExport(
                    isPresented: isSheetPresented,
                    isSensitive: true,
                    ur: TransactionResponse(
                        id: UUID(),
                        body: .seed(seed)
                    )
                    .ur, filename: "UR for seed response"
                )
                .eraseToAnyView()
            }
        }
        .frame(maxWidth: 600)
    }

    var identity: some View {
        ObjectIdentityBlock(model: .constant(seed), provideSuggestedName: provideSuggestedName)
            .frame(height: 128)
    }

    var details: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Size: ").bold() + Text("\(seedBits) bits")
                Text("Strength: ").bold() + Text("\(entropyStrength.description)")
                    .foregroundColor(entropyStrengthColor)
//                Text("Creation Date: ").bold() + Text("unknown").foregroundColor(.secondary)
            }
            Spacer()
        }
    }
    
    static var encryptedDataLabel: some View {
        VStack(alignment: .leading, spacing: 5) {
            Label(
                title: { Text("Encrypted Data").bold() },
                icon: { Image(systemName: "shield.lefthalf.fill") }
            )
            Text("Authenticate to export your seed, back it up, or use it to derive keys.")
                .font(.caption)
                .fixedVertical()
        }
    }

    var encryptedData: some View {
        HStack {
            VStack(alignment: .leading) {
                Self.encryptedDataLabel
                LockRevealButton(isRevealed: $isResponseRevealed) {
                    HStack {
                        VStack(alignment: .leading) {
                            backupMenu
                            shareMenu
                            deriveKeyMenu
                            if settings.showDeveloperFunctions {
                                ExportDataButton("Show Example Response for This Seed", icon: Image(systemName: "ladybug.fill"), isSensitive: true) {
                                    presentedSheet = .debugResponse
                                }
                            }
                        }
                        Spacer()
                    }
                } hidden: {
                    Text("Authenticate")
                        .foregroundColor(.yellowLightSafe)
                }
            }
            Spacer()
        }
    }
    
    var publicKey: some View {
        HStack {
            VStack(alignment: .leading) {
                switch settings.primaryAsset {
                case .eth:
                    ethereumAddressButton
                default:
                    cosignerButton
                }
                if settings.showDeveloperFunctions {
                    ExportDataButton("Show Example Request for This Seed", icon: Image(systemName: "ladybug.fill"), isSensitive: false) {
                        presentedSheet = .debugRequest
                    }
                }
            }
            Spacer()
        }
    }
    
    var cosignerButton: some View {
        HStack {
            ExportDataButton(Text("Cosigner Public Key") + settings.defaultNetwork.textSuffix, icon: Image("bc-logo"), isSensitive: false) {
                presentedSheet = .cosignerPublicKey
            }
            UserGuideButton(openToChapter: .whatIsACosigner)
        }
    }
    
    var ethereumAddressButton: some View {
        ExportDataButton(Text("Ethereum Address") + settings.defaultNetwork.textSuffix, icon: Image("asset.eth"), isSensitive: false) {
            presentedSheet = .ethereumAddress
        }
    }
    
    static var creationDateLabel: some View {
        Label(
            title: { Text("Creation Date").bold() },
            icon: { Image(systemName: "calendar") }
        )
    }
    
    var creationDate: some View {
        VStack(alignment: .leading) {
            Self.creationDateLabel
            HStack {
                if seed.creationDate != nil {
                    DatePicker(selection: seedCreationDate, displayedComponents: .date) {
                        Text("Creation Date")
                    }
                    .labelsHidden()
                    Spacer()
                    ClearButton {
                        seed.creationDate = nil
                    }
                    .font(.title3)
                    .accessibility(label: Text("Clear Date"))
                } else {
                    Button {
                        seed.creationDate = Date()
                    } label: {
                        Text("unknown")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
            }
            .formSectionStyle()
        }
    }
    
    static var nameLabel: some View {
        Label(
            title: { Text("Name").bold() },
            icon: { Image(systemName: "quote.bubble") }
        )
    }

    var nameView: some View {
        VStack(alignment: .leading) {
            Self.nameLabel

            HStack {
                TextField("Name", text: $seed.name) { isEditing in
                    withAnimation {
                        isEditingNameField = isEditing
                    }
                }
                .focused($nameIsFocused)
                .accessibility(label: Text("Name Field"))
                if isEditingNameField {
                    HStack(spacing: 20) {
                        FieldRandomTitleButton(seed: seed, text: $seed.name)
                        FieldClearButton(text: $seed.name)
                            .accessibility(label: Text("Clear Name"))
                    }
                    .font(.title3)
                }
            }
            .validation(seed.nameValidator)
            .formSectionStyle()
            .font(.body)
        }
    }
    
    static var notesLabel: some View {
        Label(
            title: { Text("Notes").bold() },
            icon: { Image(systemName: "note.text") }
        )
    }

    var notes: some View {
        VStack(alignment: .leading) {
            Self.notesLabel

            TextEditor(text: $seed.note)
                .id("notes")
                .frame(minHeight: 300)
                .fixedVertical()
                .formSectionStyle()
                .focused($notesIsFocused)
                .accessibility(label: Text("Notes Field"))
        }
    }
    
    var shareMenu: some View {
        HStack {
            Menu {
                ContextMenuItem(title: "ur:crypto-seed", image: Image("ur.bar")) {
                    activityParams = ActivityParams(seed.urString,
                        name: seed.name,
                        fields: [
                            .placeholder: seed.urString,
                            .id: seed.digestIdentifier,
                            .type: seed.typeString,
                            .format: "UR"
                        ]
                    )
                }
                ContextMenuItem(title: "ByteWords", image: Image("bytewords.bar")) {
                    activityParams = ActivityParams(seed.byteWords,
                        name: seed.name,
                        fields: [
                            .placeholder: seed.byteWords,
                            .id: seed.digestIdentifier, .
                            type: seed.typeString, .
                            format: "ByteWords"
                        ]
                    )
                }
                ContextMenuItem(title: "BIP39 Words", image: Image("39.bar")) {
                    activityParams = ActivityParams(seed.bip39.mnemonic,
                        name: seed.name,
                        fields: [
                            .placeholder: seed.bip39.mnemonic,
                            .id: seed.digestIdentifier,
                            .type: seed.typeString,
                            .format: "BIP39"
                        ]
                    )
                }
                ContextMenuItem(title: "Hex", image: Image("hex.bar")) {
                    activityParams = ActivityParams(seed.hex,
                        name: seed.name,
                        fields: [
                            .placeholder: seed.hex,
                            .id: seed.digestIdentifier,
                            .type: seed.typeString,
                            .format: "Hex"
                        ]
                    )
                }
            } label: {
                ExportDataButton("Share", icon: Image(systemName: "square.and.arrow.up"), isSensitive: true) {}
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .disabled(!isValid)
            .accessibility(label: Text("Share Menu"))
            .accessibilityRemoveTraits(.isImage)
            .fixedSize()

            userGuideButtons([.whatAreBytewords, .whatIsBIP39])
        }
    }
    
    func userGuideButtons(_ chapters: [Chapter]) -> some View {
        FlowLayout(mode: .scrollable, binding: .constant(5), items: chapters) {
            UserGuideButton(openToChapter: $0, showShortTitle: true)
        }
    }
    
    var deriveKeyMenu: some View {
        HStack {
            Menu {
                switch settings.primaryAsset {
                case .eth:
                    ContextMenuItem(title: Text("Ethereum Private Key"), image: Image("asset.eth")) {
                        presentedSheet = .ethereumPrivateKey
                    }
                default:
                    ContextMenuItem(title: Text("Cosigner Private Key"), image: Image("bc-logo")) {
                        presentedSheet = .cosignerPrivateKey
                    }
                }
                ContextMenuItem(title: "Other Key Derivations", image: Image("key.fill.circle")) {
                    presentedSheet = .key
                }
            } label: {
                ExportDataButton("Derive Key", icon: Image("key.fill.circle"), isSensitive: true) {}
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .disabled(!isValid)
            .accessibility(label: Text("Derive Key Menu"))
            .accessibilityRemoveTraits(.isImage)

            userGuideButtons([.whatIsKeyDerivation])
        }
    }

    var backupMenu: some View {
        HStack {
            Menu {
                ContextMenuItem(title: "Backup as ur:crypto-seed", image: Image("ur.bar")) {
                    presentedSheet = .seedUR
                }
                ContextMenuItem(title: "Backup as SSKR Multi-Share", image: Image("sskr.bar")) {
                    presentedSheet = .sskr
                }
            } label: {
                ExportDataButton("Backup", icon: Image(systemName: "archivebox"), isSensitive: true) {}
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .disabled(!isValid)
            .accessibility(label: Text("Share Seed Menu"))
            .accessibilityRemoveTraits(.isImage)
            .fixedSize()
            
            userGuideButtons([.whatIsSSKR, .whatIsAUR])
        }
    }

    var seedBytes: Int {
        seed.data.count
    }

    var seedBits: Int {
        seedBytes * 8
    }

    var entropyStrength: EntropyStrength {
        EntropyStrength.categorize(Double(seedBits))
    }

    var entropyStrengthColor: Color {
        entropyStrength.color
    }
}

#if DEBUG

import WolfLorem

struct SeedDetail_Previews: PreviewProvider {
    static let seed = Lorem.seed()

    init() {
        UITextView.appearance().backgroundColor = .clear
    }

    static var previews: some View {
        NavigationView {
            SeedDetail(seed: seed, saveWhenChanged: true, isValid: .constant(true), selectionID: .constant(seed.id))
                .environmentObject(Settings(storage: MockSettingsStorage()))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .darkMode()
    }
}

#endif
