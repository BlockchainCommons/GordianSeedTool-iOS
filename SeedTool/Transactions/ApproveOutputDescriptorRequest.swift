import SwiftUI
import WolfBase
import BCApp

struct ApproveOutputDescriptorRequest: View {
    let transactionID: UUID
    let requestBody: OutputDescriptorRequestBody
    let note: String?
    @EnvironmentObject private var model: Model
    @State private var seed: ModelSeed?
    @State private var accountNumberText: String = ""
    @State var accountNumber: Int?
    @State private var outputType: AccountOutputTypeSegment
    @State private var key: ModelHDKey?
    @State private var isSeedSelectorPresented: Bool = false
    @State private var activityParams: ActivityParams?
    @State private var isResponseRevealed: Bool = false

    var network: Network {
        requestBody.useInfo.network
    }
    
    init(transactionID: UUID, requestBody: OutputDescriptorRequestBody, note: String?) {
        self.transactionID = transactionID
        self.requestBody = requestBody
        self.note = note
        let testSeed: ModelSeed? = nil
//        let testSeed = Lorem.seed()
        self._seed = State(initialValue: testSeed)
        self._outputType = State(initialValue: AccountOutputTypeSegment(outputType: AccountOutputType.orderedCases[0], network: .constant(.testnet), accountNumber: .constant(0)))
    }
    
    var noteString: String? {
        var components: [String] = []
        let name = requestBody.name.trim()
        let note = (note ?? "").trim()
        if !name.isEmpty {
            components.append(name)
        }
        if !note.isEmpty {
            components.append(note)
        }
        guard !components.isEmpty else {
            return nil
        }
        return components.joined(separator: ": \n")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            promptSection
            noteSection
            seedSection
            if seed != nil {
                accountSection
                if accountNumber != nil {
                    typeSection
                    responseSection
                }
            }
        }
        .sheet(isPresented: $isSeedSelectorPresented) {
            SeedSelector(isPresented: $isSeedSelectorPresented, prompt: "Select the seed for the output descriptor.") { seed in
                withAnimation {
                    self.seed = seed;
                }
            }
        }
        .onAppear {
            accountNumberText = "0"
            outputType = AccountOutputTypeSegment(outputType: AccountOutputType.orderedCases[0], network: .constant(network), accountNumber: $accountNumber)
        }
        .onChange(of: accountNumberText) { newValue in
            withAnimation {
                accountNumber = validateAccountNumber(newValue)
            }
        }
        .navigationBarTitle("Descriptor Request")
    }
    
    @ViewBuilder
    var promptSection: some View {
        Info("Another device is requesting an output descriptor from this device.")
        
        TransactionChat {
            Rebus {
                requestBody.useInfo.asset.icon
                requestBody.useInfo.network.icon
                Symbol.outputDescriptor
                Image.questionmark
            }
        }
        Text("An output descriptor provides a public key and a method for deriving payment addressed from it. You can use Seed Tool to sign transactions created using your descriptor.")
            .font(.caption)
    }
    
    @ViewBuilder
    var noteSection: some View {
        RequestNote(note: noteString)
    }
    
    @ViewBuilder
    var seedSection: some View {
        AppGroupBox("Seed") {
            if let seed {
                ObjectIdentityBlock(model: .constant(seed))
                    .frame(minHeight: 80)
                    .padding(5)
            } else {
                VStack {
                    Text("Select the seed from which you would like to derive an output descriptor.")
                        .font(.caption)
                    Button {
                        isSeedSelectorPresented = true
                    } label: {
                        Text("Select Seed")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }
    
    @ViewBuilder
    var accountSection: some View {
        AppGroupBox("Account Number") {
            VStack(alignment: .leading) {
                Text("A single seed can be used to derive many separate accounts.")
                    .font(.caption)
                TextField("Account Number", text: $accountNumberText)
                    .keyboardType(.numberPad)
                    .disableAutocorrection(true)
                    .labelsHidden()
                    .formSectionStyle()
                if accountNumber == nil {
                    Text("Invalid account number.")
                        .errorStyle()
                }
            }
        }
    }
    
    @ViewBuilder
    var typeSection: some View {
        AppGroupBox("Output Type") {
            VStack(alignment: .leading) {
                Text("This is the method by which new keys are derived.")
                    .font(.caption)
                let segments: [AccountOutputTypeSegment] = AccountOutputType.orderedCases.map {
                    AccountOutputTypeSegment(outputType: $0, network: .constant(network), accountNumber: $accountNumber)
                }
                ListPicker(selection: $outputType, segments: .constant(segments))
                    .formSectionStyle()
            }
        }
    }
    
    var masterKey: HDKey? {
        guard let seed else {
            return nil
        }
        return try! HDKey(seed: seed, useInfo: .init(network: network))
    }
    
    var descriptor: OutputDescriptor? {
        guard
            let accountNumber,
            let masterKey
        else {
            return nil
        }
        let outputType = outputType.outputType
        return try! outputType.accountDescriptor(masterKey: masterKey, network: network, account: UInt32(accountNumber))
    }
    
    var publicKey: ModelHDKey? {
        guard
            let descriptor,
            let key = descriptor.baseKey
        else {
            return nil
        }
        let modelKey = ModelHDKey(key: key, seed: seed!, name: "Public Account Key from \(seed!.name)")
        return modelKey
    }
    
    var challengeSigningKey: HDKey? {
        guard
            let descriptor,
            let masterKey,
            let key = descriptor.hdKey(keyType: .private, chain: .external, addressIndex: 0, privateKeyProvider: { key in
                try HDKey(parent: masterKey, childDerivationPath: key.parent)
            })
        else {
            return nil
        }
        return key
    }
    
    var responseUR: UR? {
        guard
            let challengeSigningKey,
            let descriptor
        else {
            return nil
        }
        let challengeSignature = challengeSigningKey.ecPrivateKey!.ecdsaSign(message: requestBody.challenge)
        let body = OutputDescriptorResponseBody(descriptor: descriptor, challengeSignature: challengeSignature)
        let response = TransactionResponse(id: transactionID, body: .outputDescriptor(body))
        return response.ur
    }
    
    @ViewBuilder
    var responseSection: some View {
        VStack(alignment: .leading) {
            Text("Response")
                .formGroupBoxTitleFont()
            if seed == nil {
                Text("No seed selected.")
                    .errorStyle()
            }
            if accountNumber == nil {
                Text("Invalid account number.")
                    .errorStyle()
            }
            if
                let seed,
                let publicKey,
                let descriptor,
                let responseUR
            {
                LockRevealButton(isRevealed: $isResponseRevealed, isSensitive: false, isChatBubble: true) {
                    VStack(alignment: .trailing, spacing: 20) {
                        Rebus {
                            requestBody.useInfo.asset.icon
                            requestBody.useInfo.network.icon
                            Symbol.outputDescriptor
                            Symbol.sentItem
                        }
                        ObjectIdentityBlock(model: .constant(publicKey))
                            .frame(minHeight: 80)
                            .padding(5)
                        Text(descriptor.sourceWithChecksum)
                            .font(.caption)
                            .longPressAction {
                                activityParams = ActivityParams(descriptor.sourceWithChecksum, name: "Descriptor", fields: Self.responseFields(descriptor: descriptor, seed: seed))
                            }
                            .background(ActivityView(params: $activityParams))
                        URDisplay(
                            ur: responseUR,
                            name: "Response-Descriptor",
                            fields: Self.responseFields(descriptor: descriptor, seed: seed, format: "UR")
                        )
                        VStack(alignment: .trailing) {
                            ExportDataButton("Share as ur:crypto-response", icon: Image.ur, isSensitive: false) {
                                activityParams = ActivityParams(
                                    responseUR,
                                    name: seed.name,
                                    fields: Self.responseFields(descriptor: descriptor, seed: seed, format: "UR")
                                )
                            }
                            WriteNFCButton(ur: responseUR, isSensitive: false, alertMessage: "Write UR for response.")
                        }
                    }
                } hidden: {
                    Text("Approve")
                }
            }
        }
    }
    
    static func responseFields(descriptor: OutputDescriptor, seed: ModelSeed, format: String? = nil, placeholder: String? = nil) -> ExportFields {
        var fields: ExportFields = [
            .rootID: seed.digestIdentifier,
            .placeholder: "Response with Output Descriptor",
            .type: "Response",
            .subtype: "OutputDescriptor",
            .fragment: descriptor.baseKey!.parent†,
        ]
        if let placeholder {
            fields[.placeholder] = placeholder
        }
        if let format {
            fields[.format] = format
        }
        return fields
    }
}

#if DEBUG

import WolfLorem

struct OutputDescriptorRequest_Previews: PreviewProvider {
    static let model = Lorem.model()
    static let settings = Settings(storage: MockSettingsStorage())
    
    static func requestForOutputDescriptor() -> TransactionRequest {
        let useInfo = UseInfo(asset: .btc, network: .testnet)
        let body = OutputDescriptorRequestBody(name: Lorem.shortTitle(), useInfo: useInfo, challenge: SecureRandomNumberGenerator.shared.data(count: 16))
        return TransactionRequest(body: .outputDescriptor(body), note: Lorem.sentence())
    }
        
    static var previews: some View {
        ApproveRequest(isPresented: .constant(true), request: requestForOutputDescriptor())
            .previewLayout(.fixed(width: 500, height: 1500))
            .environmentObject(model)
            .environmentObject(settings)
        //.environment(\.layoutDirection, .rightToLeft)
        .darkMode()
    }
}

#endif
