//
//  SeedDetail.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI
import Combine
import SwiftUIFlowLayout
import WolfLorem
import BCApp

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
        case seedEnvelope
        case cosignerPublicKey
        case cosignerPrivateKey
        case ethereumAddress
        case tezosAddress
        case ethereumPrivateKey
        case tezosPrivateKey
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
            NoSeedSelected()
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
                outputDescriptor
                if settings.showDeveloperFunctions {
                    envelope
                }
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
        .navigationBarTitle("Seed")
        .background(ActivityView(params: $activityParams))
        .sheet(item: $presentedSheet) { item in
            let isSheetPresented = Binding<Bool>(
                get: { presentedSheet != nil },
                set: { if !$0 { presentedSheet = nil } }
            )
            switch item {
            case .seedEnvelope:
                ModelObjectExport(isPresented: isSheetPresented, isSensitive: true, subject: seed)
                    .environmentObject(model)
            case .cosignerPublicKey:
                KeyExport(isPresented: isSheetPresented, key: KeyExportModel.deriveCosignerKey(seed: seed, network: settings.defaultNetwork, keyType: .public))
                    .environmentObject(settings)
            case .cosignerPrivateKey:
                KeyExport(isPresented: isSheetPresented, key: KeyExportModel.deriveCosignerKey(seed: seed, network: settings.defaultNetwork, keyType: .private))
                    .environmentObject(settings)
            case .ethereumAddress:
                ModelObjectExport(isPresented: isSheetPresented, isSensitive: false, subject: KeyExportModel.deriveAddress(seed: seed, useInfo: UseInfo(asset: .eth, network: settings.defaultNetwork)))
                    .environmentObject(model)
            case .tezosAddress:
                ModelObjectExport(isPresented: isSheetPresented, isSensitive: false, subject: KeyExportModel.deriveAddress(seed: seed, useInfo: UseInfo(asset: .xtz)))
                    .environmentObject(model)
            case .ethereumPrivateKey:
                ModelObjectExport(isPresented: isSheetPresented, isSensitive: true, subject: KeyExportModel.derivePrivateECKey(seed: seed, useInfo: UseInfo(asset: .eth, network: settings.defaultNetwork)))
                    .environmentObject(model)
            case .tezosPrivateKey:
                ModelObjectExport(isPresented: isSheetPresented, isSensitive: true, subject: KeyExportModel.derivePrivateECKey(seed: seed, useInfo: UseInfo(asset: .xtz, network: settings.defaultNetwork)))
                    .environmentObject(model)
            case .sskr:
                SSKRSetup(seed: seed, isPresented: isSheetPresented)
                    .environmentObject(model)
            case .key:
                KeyDerivation(seed: seed, isPresented: isSheetPresented, network: settings.defaultNetwork)
                    .environmentObject(model)
                    .environmentObject(settings)
            case .debugRequest:
                try! DisplayTransaction(
                    isPresented: isSheetPresented,
                    isSensitive: false,
                    ur: TransactionRequest(
                        body: SeedRequestBody(seedDigest: seed.fingerprint.digest),
                        note: Lorem.sentences(2)
                    ).ur,
                    title: seed.name,
                    fields: [
                        .placeholder: "Request for \(seed.name)",
                        .id: seed.digestIdentifier,
                        .type: "Request-Seed"
                    ]
                ) {
                    Rebus {
                        Image.seed
                        Text(seed.fingerprint.identifier())
                            .futureMonospaced()
                        Image.questionmark
                    }
                }
            case .debugResponse:
                DisplayTransaction(
                    isPresented: isSheetPresented,
                    isSensitive: true,
                    ur: TransactionResponse(
                        id: ARID(),
                        result: Seed(seed)
                    ).ur,
                    title: seed.name,
                    fields: [
                        .placeholder: "Response for \(seed.name)",
                        .id: seed.digestIdentifier,
                        .type: "Response-Seed"
                    ]
                ) {
                    Rebus {
                        Image.seed
                        Text(seed.fingerprint.identifier())
                            .futureMonospaced()
                        Symbol.sentItem
                    }
                }
            }
        }
        .onNavigationEvent { _ in
            presentedSheet = nil
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
                icon: { Image.secure }
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
                LockRevealButton(isRevealed: $isResponseRevealed, isSensitive: true, isChatBubble: false) {
                    HStack {
                        VStack(alignment: .leading) {
                            backupMenu
                            shareMenu
                            deriveKeyMenu
                            if settings.showDeveloperFunctions {
                                ExportDataButton("Show Example Response for This Seed", icon: Image.developer, isSensitive: true) {
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
                case .btc:
                    cosignerButton
                case .eth:
                    ethereumAddressButton
                case .xtz:
                    tezosAddressButton
                }
                if settings.showDeveloperFunctions {
                    ExportDataButton("Show Example Request for This Seed", icon: Image.developer, isSensitive: false) {
                        presentedSheet = .debugRequest
                    }
                }
            }
            Spacer()
        }
    }
    
    var cosignerButton: some View {
        HStack {
            ExportDataButton(Text("Cosigner Public Key") + settings.defaultNetwork.textSuffix, icon: Image.bcLogo, isSensitive: false) {
                presentedSheet = .cosignerPublicKey
            }
            UserGuideButton(openToChapter: AppChapter.whatIsACosigner)
        }
    }
    
    var ethereumAddressButton: some View {
        ExportDataButton(Text("Ethereum Address") + settings.defaultNetwork.textSuffix, icon: Image.ethereum, isSensitive: false) {
            presentedSheet = .ethereumAddress
        }
    }
    
    var tezosAddressButton: some View {
        ExportDataButton(Text("Tezos Address"), icon: Image.tezos, isSensitive: false) {
            presentedSheet = .tezosAddress
        }
    }

    static var creationDateLabel: some View {
        Label(
            title: { Text("Creation Date").bold() },
            icon: { Image.date }
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
                    ClearButton(title: "Remove Creation Date?", message: "This is not undoable.", actionName: "Remove") {
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
            icon: { Image.name }
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
                if !isEditingNameField {
                    nameFieldMenu
                }
            }
            .validation(seed.nameValidator)
            .formSectionStyle()
            .font(.body)
        }
    }
    
    var nameFieldMenu: some View {
        Menu {
            RandomizeMenuItem() {
                seed.name = LifeHashNameGenerator.generate(from: seed)
            }
            ClearMenuItem() {
                seed.name = ""
            }
        } label: {
            Image.menu
                .foregroundColor(.secondary)
                .font(.title3)
        }
        .accessibility(label: Text("Name Menu"))
    }
    
    @ViewBuilder
    static var notesLabel: some View {
        Label(
            title: { Text("Notes").bold() },
            icon: { Image.note }
        )
    }

    @ViewBuilder
    var notes: some View {
        VStack(alignment: .leading, spacing: 10) {
            Self.notesLabel
            capacityInfo
            TextEditor(text: $seed.note)
                .id("notes")
                .frame(minHeight: 300)
                .fixedVertical()
                .formSectionStyle()
                .focused($notesIsFocused)
                .accessibility(label: Text("Notes Field"))
        }
    }
    
    var capacityInfo: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("Length: `\(seed.note.count)` characters")

            switch seed.staticQRInfo {
            case .fits((let info, let didLimit)):
                Text("Printed QR code size: \(info.size)x\(info.size)")
                if didLimit {
                    Caution("When printed, some metadata will be elided to fit into the QR code. Try making your notes smaller.")
                }
            case .doesntFit:
                Caution("Data will not fit in a printed QR code.")
            }
            
            if case .multiPart = seed.dynamicQRInfo {
                Info("The on-screen QR code will animate.")
            }
        }
            .font(.caption)
    }
    
    @ViewBuilder
    var shareMenu: some View {
        HStack {
            Menu {
                ContextMenuItem(title: "Gordian Envelope", image: Image.envelope) {
                    activityParams = seed.envelopeActivityParams
                }
                ContextMenuItem(title: "ByteWords", image: Image.byteWords) {
                    activityParams = seed.byteWordsActivityParams
                }
                ContextMenuItem(title: "BIP39 Words", image: Image.bip39) {
                    activityParams = seed.bip39ActivityParams
                }
                ContextMenuItem(title: "Hex", image: Image.hex) {
                    activityParams = seed.hexActivityParams
                }
            } label: {
                ExportDataButton("Share", icon: Image.share, isSensitive: true) {}
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .disabled(!isValid)
            .accessibility(label: Text("Share Menu"))
            .accessibilityRemoveTraits(.isImage)
            .fixedSize()

            userGuideButtons([.whatAreBytewords, .whatIsBIP39])
        }
    }
    
    func userGuideButtons(_ chapters: [AppChapter]) -> some View {
        FlowLayout(mode: .scrollable, binding: .constant(5), items: chapters, itemSpacing: 0) {
            UserGuideButton(openToChapter: $0, showShortTitle: true)
        }
    }
    
    var deriveKeyMenu: some View {
        HStack {
            Menu {
                switch settings.primaryAsset {
                case .btc:
                    ContextMenuItem(title: Text("Cosigner Private Key"), image: Image.bcLogo) {
                        presentedSheet = .cosignerPrivateKey
                    }
                case .eth:
                    ContextMenuItem(title: Text("Ethereum Private Key"), image: Image.ethereum) {
                        presentedSheet = .ethereumPrivateKey
                    }
                case .xtz:
                    ContextMenuItem(title: Text("Tezos Private Key"), image: Image.tezos) {
                        presentedSheet = .tezosPrivateKey
                    }
                }
                ContextMenuItem(title: "Other Key Derivations", image: Image.key) {
                    presentedSheet = .key
                }
            } label: {
                ExportDataButton("Derive Key", icon: Image.key, isSensitive: true) {}
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
                ContextMenuItem(title: "Backup as Gordian Envelope", image: Image.envelope) {
                    presentedSheet = .seedEnvelope
                }
                ContextMenuItem(title: "Backup as SSKR Multi-Share", image: Image.sskr) {
                    presentedSheet = .sskr
                }
            } label: {
                ExportDataButton("Backup", icon: Image.backup, isSensitive: true) {}
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .disabled(!isValid)
            .accessibility(label: Text("Share Seed Menu"))
            .accessibilityRemoveTraits(.isImage)
            .fixedSize()
            
            userGuideButtons([.whatIsSSKR, .whatIsGordianEnvelope])
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
    
    var hasOutputDescriptor: Bool {
        seed.outputDescriptor != nil
    }
    
    @State var outputDescriptorMessageInfo: ErrorAlert.Info?
    
    @ViewBuilder
    var outputDescriptor: some View {
        VStack(alignment: .leading, spacing: 10) {
            Self.outputDescriptorLabel
            if let outputDescriptor = seed.outputDescriptor {
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Group {
                                if !outputDescriptor.name.isEmpty {
                                    HStack {
                                        Text("Name:")
                                            .bold()
                                        Text(outputDescriptor.name)
                                    }
                                }
                                if !outputDescriptor.note.isEmpty {
                                    HStack {
                                        Text("Note:")
                                            .bold()
                                        Text(outputDescriptor.note)
                                    }
                                }
                            }
                            .font(.footnote)
                            Text(outputDescriptor.sourceWithChecksum)
                                .futureMonospaced()
                                .font(.caption)
                                .longPressAction {
                                    activityParams = seed.textOutputDescriptorActivityParams
                                }
                        }
                        
                        Spacer()
                        
                        ClearButton(title: "Remove Output Descriptor?", message: "This is not undoable.", actionName: "Remove") {
                            withAnimation {
                                self.seed.outputDescriptor = nil
                            }
                        }
                        .font(.title3)
                        .accessibility(label: Text("Clear Output Descriptor"))
                    }

                    HStack {
                        shareOutputDescriptorMenu
                        Spacer()
                    }
                }
                .formSectionStyle()
            } else {
                HStack(alignment: .top) {
                    Text(markdown: "Associate a primary output descriptor derived from this seed. You may paste either a textual descriptor or a `ur:envelope` containing a descriptor.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                    ExportDataButton("Paste", icon: Image.paste, isSensitive: false) {
                        let outputDescriptor: OutputDescriptor?
                        if let string = UIPasteboard.general.string?.trim() {
                            if
                                let desc = try? OutputDescriptor(string)
                            {
                                outputDescriptor = desc
                            } else if
                                let envelope = try? Envelope(urString: string),
                                let desc = try? OutputDescriptor(envelope: envelope)
                            {
                                outputDescriptor = desc
                            } else {
                                outputDescriptor = nil
                            }
                        } else {
                            outputDescriptor = nil
                        }
                        
                        if let outputDescriptor {
                            if outputDescriptor.isDerivedFromSeed(seed) {
                                withAnimation {
                                    seed.outputDescriptor = outputDescriptor
                                    Haptic.success()
                                }
                            } else {
                                outputDescriptorMessageInfo = ErrorAlert.Info(title: "Descriptor from Different Seed", message: "The pasted output descriptor was not derived from this seed.")
                            }
                        } else {
                            outputDescriptorMessageInfo = ErrorAlert.Info(title: "Invalid Output Descriptor", message: "The clipboard does not contain a textual or `ur:envelope` output descriptor.")
                        }
                    }
                    .messageAlert($outputDescriptorMessageInfo)
                }
            }
        }
    }
    
    @ViewBuilder
    static var outputDescriptorLabel: some View {
        Label(
            title: { Text("Output Descriptor").bold() },
            icon: { Image.outputDescriptor }
        )
    }
    
    @ViewBuilder
    var shareOutputDescriptorMenu: some View {
        HStack {
            Menu {
                ContextMenuItem(title: "Gordian Envelope", image: Image.envelope) {
                    activityParams = seed.envelopeOutputDescriptorActivityParams
                }
                ContextMenuItem(title: "Text", image: Image.outputDescriptor) {
                    activityParams = seed.textOutputDescriptorActivityParams
                }
            } label: {
                ExportDataButton("Share", icon: Image.share, isSensitive: false) {}
            }
            .menuStyle(BorderlessButtonMenuStyle())
            .disabled(!hasOutputDescriptor)
            .accessibility(label: Text("Share Output Descriptor Menu"))
            .accessibilityRemoveTraits(.isImage)
            .fixedSize()
        }
    }

    @ViewBuilder
    var envelope: some View {
        VStack(alignment: .leading, spacing: 10) {
            Self.envelopeLabel
            HStack {
                Text(seed.envelope.format(context: globalFormatContext))
                    .font(.footnote)
                    .futureMonospaced()
                    .longPressAction {
                        activityParams = seed.envelopeFormatActivityParams
                    }
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    static var envelopeLabel: some View {
        HStack {
            Label(
                title: { Text("Envelope").bold() },
                icon: { Image.envelope }
            )
            Spacer()
            Image.developer
                .foregroundColor(.green)
        }
    }
}

#if DEBUG

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
