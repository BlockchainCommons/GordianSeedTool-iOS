//
//  ApprovePSBTSignatureRequest.swift
//  SeedTool
//
//  Created by Wolf McNally on 8/30/21.
//

import SwiftUI
import WolfBase
import BCApp

struct ApprovePSBTSignatureRequest: View {
    let transactionID: ARID
    let requestBody: PSBTSignatureRequestBody
    let note: String?
    let psbt: PSBT
    @State private var signedPSBT: PSBT?
    @State private var isFullySigned: Bool = false
    @State private var network: Network = .mainnet
    @State private var inputs: [PSBTInputSigning<ModelSeed>] = []
    @State private var outputs: [PSBTOutputSigning<ModelSeed>] = []
    @State private var activityParams: ActivityParams?
    @State private var isResponseRevealed: Bool = false
    @State private var isPSBTRevealed: Bool = false
    @EnvironmentObject private var model: Model
    @EnvironmentObject private var settings: Settings

    init(transactionID: ARID, requestBody: PSBTSignatureRequestBody, note: String?) {
        self.transactionID = transactionID
        self.requestBody = requestBody
        self.note = note
        self.psbt = requestBody.psbt
    }

    private var seeds: [ModelSeed] { model.seeds }
    
    private var countOfSignableInputs: Int {
        PSBT.countOfSignableInputs(for: inputs)
    }
    
    private var canSign: Bool {
        countOfSignableInputs > 0
    }
    
    private var countOfUniqueSigners: Int {
        PSBT.countOfUniqueSigners(for: inputs)
    }
    
    private func inputsCountString(_ count: Int) -> String {
        String(AttributedString(localized:"^[\(count) \("input")](inflect: true)").characters)
    }
    
    private func seedsCountString(_ count: Int) -> String {
        String(AttributedString(localized:"^[\(count) \("seed")](inflect: true)").characters)
    }
    
    private var responseUR: UR {
        TransactionResponse(id: transactionID, result: signedPSBT!).ur
    }
    
    private var responsePSBTUR: UR {
        if requestBody.psbtRequestStyle == .urVersion1 {
            let urVersion2 = signedPSBT!.ur
            let urVersion1 = try! UR(type: "crypto-psbt", cbor: urVersion2.cbor)
            return urVersion1
        } else {
            return signedPSBT!.ur
        }
    }
    
    private var responseBase64: String {
        signedPSBT!.base64
    }
    
    private var responseData: Data {
        signedPSBT!.data
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerSection
            summarySection
            controlsSection
            inputsSection
            outputsSection
            approvalSection
        }
        .onAppear {
            inputs = psbt.inputSigning(signers: model.seeds)
            outputs = psbt.outputSigning(signers: model.seeds)
            network = settings.defaultNetwork
            signedPSBT = psbt.signed(with: inputs)
            isFullySigned = signedPSBT?.isFullySigned ?? false
        }
        .background(ActivityView(params: $activityParams))
        .navigationBarTitle("Signature Request")
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if requestBody.psbtRequestStyle != .envelope {
                Caution(Text("This request was received as a bare PSBT. Blockchain Commons urges developers to instead use Gordian Envelope-based requests for PSBT signing."))
            }
            Info("Another device is requesting signing on the inputs of the transaction below.")
            TransactionChat(response: canSign ? .composing : .error) {
                Rebus {
                    Image.signature
                    Image.questionmark
                }
            }
            RequestNote(note: note)
            if canSign {
                Note(icon: Symbol.signature, content: Text("If you approve, this device will sign \(inputsCountString(countOfSignableInputs)) on the transaction using keys derived from \(seedsCountString(countOfUniqueSigners)) on this device."))
                if isFullySigned {
                    Success("Once signed, this transaction will be fully signed and ready to send to the network.")
                } else {
                    Note(icon: Symbol.signatureNeeded, content: Text("Once signed, this transaction will still require one or more additional signatures before it will be ready to send to the network."))
                }
            } else {
                NotSigned()
            }
        }
    }
    
    var summarySection: some View {
        AppGroupBox("Summary") {
            VStack(spacing: 5) {
                HStack(spacing: 5) {
                    BitcoinValue(symbol: Symbol.txInput.eraseToAnyView(), label: "In", value: psbt.totalIn)
                    Text("+")
                }
                HStack(spacing: 5) {
                    BitcoinValue(isChange: false, value: psbt.totalSent)
                    Text("–")
                }
                HStack(spacing: 5) {
                    BitcoinValue(symbol: Symbol.txFee.eraseToAnyView(), label: "Fee", value: psbt.fee)
                    Text("–")
                }
                HStack(spacing: 5) {
                    BitcoinValue(isChange: true, value: psbt.totalChange)
                    Text("=")
                }
            }
        }
    }
    
    var controlsSection: some View {
        LabeledContent {
            Text("Display addresses for:")
        } content: {
            SegmentPicker(selection: Binding($network), segments: .constant(Network.allCases))
        }
    }
    
    var inputsTitleString: String {
        String(AttributedString(localized:"^[\(inputs.count) \("Input")](inflect: true)").characters)
    }

    var inputsSection: some View {
        AppGroupBox(inputsTitleString) {
            ForEach(inputs) { signing in
                VStack(alignment: .leading, spacing: 10) {
                    BitcoinValue(symbol: Symbol.txInput.eraseToAnyView(), label: "Amount", value: signing.input.amount)
                    AddressValue(label: "From", address: signing.input.address(network: network))
                    if
                        !signing.input.witnessStack.isEmpty,
                        let (n, m) = signing.input.witnessStack[0]?.multisigInfo
                    {
                        MultisigValue(n: n, m: m)
                    }
                    AppGroupBox {
                        ForEach(signing.statuses) { status in
                            status.view(isInput: true)
                        }
                    }
                }
            }
        }
    }
    
    var outputsTitleString: String {
        String(AttributedString(localized:"^[\(outputs.count) \("Output")](inflect: true)").characters)
    }
    
    var outputsSection: some View {
        AppGroupBox(outputsTitleString) {
            ForEach(outputs) { signing in
                VStack(alignment: .leading, spacing: 10) {
                    BitcoinValue(isChange: signing.output.isChange, value: signing.output.amount)
                    AddressValue(label: "To", address: signing.output.address(network: network))
                    if let (n, m) = signing.output.txOutput.scriptPubKey.multisigInfo {
                        MultisigValue(n: n, m: m)
                    }
                    AppGroupBox {
                        ForEach(signing.statuses) { status in
                            status.view(isInput: false)
                        }
                    }
                }
            }
        }
    }

    var approvalSection: some View {
        VStack(alignment: .trailing) {
            LockRevealButton(isRevealed: $isResponseRevealed, isSensitive: true, isChatBubble: true) {
                HStack {
                    VStack(alignment: .trailing, spacing: 20) {
                        Rebus {
                            Image.signature
                            Symbol.sentItem
                        }
                        
                        transactionResponseSection
                        
                        switch requestBody.psbtRequestStyle {
                        case .base64:
                            base64Section
                        case .urVersion1, .urVersion2:
                            urSection
                        case .envelope:
                            EmptyView()
                        }
                        
                        psbtBinarySection

                        if requestBody.psbtRequestStyle != .envelope && settings.showDeveloperFunctions {
                            transactionResponseSection
                        }
                    }
                }
            } hidden: {
                Text("Approve")
                    .foregroundColor(canSign ? .yellowLightSafe : .gray)
            }
            .disabled(!canSign)

            if !canSign {
                NotSigned()
            }
        }
        .onChange(of: isResponseRevealed) {
            if $0 {
                withAnimation {
                    isPSBTRevealed = false
                }
            }
        }
        .onChange(of: isPSBTRevealed) {
            if $0 {
                withAnimation {
                    isResponseRevealed = false
                }
            }
        }
    }

    var transactionResponseSection: some View {
        VStack(alignment: .trailing) {
            groupTitle("ur:\(responseUR.type)")
            if requestBody.psbtRequestStyle != .envelope && settings.showDeveloperFunctions {
                Spacer()
                    .frame(height: 5)
                (Text(Image.developer).foregroundColor(.green) + Text("This is a mock response for use by developers."))
                    .font(.caption)
            }
            VStack(alignment: .trailing) {
                RevealButton2(icon: Image.displayQRCode, isSensitive: true) {
                    URDisplay(ur: responseUR, name: "UR for response")
                } hidden: {
                    Text("QR Code")
                        .foregroundColor(.yellowLightSafe)
                }
                WriteNFCButton(ur: responseUR, isSensitive: true, alertMessage: "Write UR for response.")
                ExportDataButton("Share", icon: Image.share, isSensitive: true) {
                    activityParams = ActivityParams(responseUR, name: "UR for response")
                }
            }
        }
    }
    
    var base64Section: some View {
        VStack(alignment: .trailing) {
            groupTitle("Base-64")
            ExportDataButton("Share", icon: Image.share, isSensitive: true) {
                activityParams = ActivityParams(responseBase64, name: "PSBT Base64")
            }
        }
    }
    
    var urSection: some View {
        VStack(alignment: .trailing) {
            groupTitle(requestBody.psbtRequestStyle == .urVersion1 ? "ur:crypto-psbt" : "ur:psbt")
            RevealButton2(icon: Image.displayQRCode, isSensitive: true) {
                URDisplay(ur: responsePSBTUR, name: "PSBT UR for response")
            } hidden: {
                Text("QR Code")
                    .foregroundColor(.yellowLightSafe)
            }
            WriteNFCButton(ur: responsePSBTUR, isSensitive: true, alertMessage: "Write PSBT UR for response.")
            ExportDataButton("Share", icon: Image.share, isSensitive: true) {
                activityParams = ActivityParams(responsePSBTUR, name: "UR for PSBT")
            }
        }
    }
    
    var psbtBinarySection: some View {
        VStack(alignment: .trailing) {
            groupTitle(".psbt file (binary)")
            ExportDataButton("Share", icon: Image.share, isSensitive: true) {
                activityParams = ActivityParams(responseData, name: "SignedPSBT.psbt")
            }
        }
    }
}

extension PSBTSigningStatus where SignerType == ModelSeed {
    func view(isInput: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    if isInput {
                        if canBeSigned {
                            Symbol.signature
                        } else {
                            Symbol.signatureNeeded
                        }
                    }
                    Text(isInput ? inputStatusString : outputStatusString)
                }
                .font(Font.system(.body))
                signerView
                OriginPathValue(origin: origin)
                    .font(Font.system(.caption).bold())
            }
            Spacer()
        }
    }
    
    var inputStatusString: String {
        switch status {
        case .isSignedBy:
            return "This input is already signed with:"
        case .isSignedByUnknown:
            return "This input is already signed with an unknown signer."
        case .canBeSignedBy:
            return "This device will sign this input with:"
        case .noKnownSigner:
            return "No known signer on this device."
        }
    }
    
    var outputStatusString: String {
        switch status {
        case .canBeSignedBy:
            return "This output may eventually be signed with:"
        case .noKnownSigner:
            return "This output may eventually be signed with an unknown signer."
        default:
            return "Unknown status."
        }
    }
    
    var signerSeed: ModelSeed? {
        switch status {
        case .isSignedBy(let seed):
            return seed
        case .canBeSignedBy(let seed):
            return seed
        default:
            return nil
        }
    }

    var signerView: some View {
        Group {
            if let seed = signerSeed {
                ObjectIdentityBlock(model: .constant(seed))
            }
        }
    }
}

struct BitcoinValue: View {
    let symbol: AnyView?
    let label: String
    let value: Satoshi?
    @State private var activityParams: ActivityParams?

    init(symbol: AnyView? = nil, label: String, value: Satoshi?) {
        self.symbol = symbol
        self.label = label
        self.value = value
    }
    
    init(isChange: Bool, value: Satoshi?) {
        if isChange {
            self.init(symbol: Symbol.txChange.eraseToAnyView(), label: "Change", value: value)
        } else {
            self.init(symbol: Symbol.txSent.eraseToAnyView(), label: "Sent", value: value)
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            HStack {
                if let symbol = symbol {
                    symbol
                }
                Text("\(label) ")
            }
            .font(Font.system(.body).bold())
            Spacer()
            if let value = value {
                Text(Asset.btc.symbol.uppercased())
                    .font(.caption)
                Text(" \(value.btcFormat)")
                    .appMonospaced()
                    .longPressAction {
                        activityParams = ActivityParams(value.btcFormat, name: value.btcFormat)
                    }
                    .background(ActivityView(params: $activityParams))
            } else {
                Text("unknown")
                    .foregroundColor(.gray)
            }
        }
    }
}

struct NotSigned: View {
    var body: some View {
        Failure("No seeds on this device can be used to derive keys that can sign this transaction.")
    }
}

struct AddressValue: View {
    let label: String
    let address: String?
    @State private var activityParams: ActivityParams?

    init(label: String, address: String?) {
        self.label = label
        self.address = address
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                (Text(label) + Text(":"))
                    .bold()
                Spacer()
            }
            if let address = address {
                Text(address)
                    .appMonospaced()
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .longPressAction {
                        activityParams = ActivityParams(address, name: address)
                    }
            } else {
                Text("unknown")
                    .foregroundColor(.gray)
            }
        }
        .background(ActivityView(params: $activityParams))
    }
}

struct MultisigValue: View {
    let n: Int
    let m: Int
        
    var body: some View {
        Text("\(n) of \(m) Multisig")
            .bold()
    }
}

struct OriginPathValue: View {
    let origin: PSBTSigningOrigin
    @State private var activityParams: ActivityParams?

    var body: some View {
        HStack {
            if origin.isChange {
                Symbol.txChange
            }
            Text(origin.path.description)
                .longPressAction {
                    activityParams = ActivityParams(origin.path.description, name: origin.path.description)
                }
                .background(ActivityView(params: $activityParams))
        }
    }
}

#if DEBUG

fileprivate let alice = try! ModelSeed(urString: "ur:seed/oeadgdlfwfdwlphlfsghcphfcsaybekkkbaejkaxihfpjziniaihwleorfly")
fileprivate let bob = try! ModelSeed(urString: "ur:seed/oeadgdcsknhkjkswgtecnslsjtrdfgimfyuykgaxiafwjlidehpyhpht")

fileprivate let psbt1of2 = try! PSBT(urString: "ur:psbt/hkaohgjojkidjyzmadaeldaoaeaeaeadaxwtatmsbwmhjkdidtftpepkrdsbfsdphydwvtctrefmjlcmmensnltkwneskosnaeaeaeaeaezczmzmzmaoptfradaeaeaeaeaecpaecxrnqznyidfgwyemmkjptdihhghfaettjewygeplvooxfgynndtehfnyjtfsdylabavsaxaeaeaeaeaeaecpaecxwnbwuerplayaqzbkdkgeadissajtcardrnzeskihiorfaedrpdhdplbegypdhyswaeaeaeaeaeadaddngdfzadaeaeaeaeaecpaecximinidchhykidsqzglutqzpeclwnzotizslplurestjnpyadbyckwsrhnnbbchmyadahflgyclaoahvarymnfypdbdbtksflknrswefncpghttlujpfsahbdvsneeymdtikgkpwtuemdclaxguhkfxsnplmnamotkbkpnybtsfbeseaadipttienoxnlvynnknaekimnvyemtbfhgmplcpamaoahvarymnfypdbdbtksflknrswefncpghttlujpfsahbdvsneeymdtikgkpwtuemdcegoadjedldyaeaelaadaeaelaaeaeaelaaoaeaelaaeaeaeaeadaeaeaecpamaxguhkfxsnplmnamotkbkpnybtsfbeseaadipttienoxnlvynnknaekimnvyemtbfhceuehdglzcdyaeaelaadaeaelaaeaeaelaaoaeaelaaeaeaeaeadaeaeaeaeadadflgyclaokiwsaomdfxyavljenbtymdzenbmhfdstrdgsiejseslofgnnbevsswiocnwttoiyclaxylvddnoslpmsimfywkmhzslsrpmhtssffpttjysooltbsrjnlrvectmyytztwdgagmplcpaoaokiwsaomdfxyavljenbtymdzenbmhfdstrdgsiejseslofgnnbevsswiocnwttoiycegoadjedldyaeaelaadaeaelaaeaeaelaaoaeaelaadaeaeaeaoaeaeaecpaoaxylvddnoslpmsimfywkmhzslsrpmhtssffpttjysooltbsrjnlrvectmyytztwdgaceuehdglzcdyaeaelaadaeaelaaeaeaelaaoaeaelaadaeaeaeaoaeaeaeaeaeswregolr")

fileprivate let psbt2of2 = try! PSBT(urString: "ur:psbt/hkaogrjojkidjyzmadaekiaoaeaeaeadgdvocpvtwszmoslechzcsgaxhsjpeoftsbgohyinmujsrpeefdfewsjokkjokofwaeaeaeaeaezczmzmzmaordbeadaeaeaeaeaecpaecxbemesevwuykocafhhyhsbbjnyaeefptlhgpsbwkgrofsastlmycwdabwehylttbbbediaeaeaeaeaeaecmaebbzmntoniovadldywdlnghzscaheryflrnyavlrnbwaeaeaeaeaeadaddnlaetadaeaeaeaeaecpaecxwdlozewpdlhgtlrsaxfxqdhhmodrzmrlqdwfwtvlmtwyjyvllaaxbysesgotchldadahflgmclaoahvarymnfypdbdbtksflknrswefncpghttlujpfsahbdvsneeymdtikgkpwtuemdclaxbngyhemwsedaksctwsjpatfgtkbkfrkncxcxaxsbcxisetchnldnfxcwfgvosnrlgmplcpamaoahvarymnfypdbdbtksflknrswefncpghttlujpfsahbdvsneeymdtikgkpwtuemdcegoadjedldyaeaelaadaeaelaaeaeaelaaoaeaelaaeaeaeaeadaeaeaecpamaxbngyhemwsedaksctwsjpatfgtkbkfrkncxcxaxsbcxisetchnldnfxcwfgvosnrlceosvstijtdyaeaelaadaeaelaaeaeaelaaoaeaelaaeaeaeaeadaeaeaeaeadadflgmclaoderphszmatynidgdchsppstbmhkbattefplyztoxsatasopknnrhkeclcnoemwecclaovepasewkinldmhssylatneiyfeoxwseenyotbyztfzfylnytmyztiagylpgejetkgmplcpaoaoderphszmatynidgdchsppstbmhkbattefplyztoxsatasopknnrhkeclcnoemweccegoadjedldyaeaelaadaeaelaaeaeaelaaoaeaelaadaeaeaeaxaeaeaecpaoaovepasewkinldmhssylatneiyfeoxwseenyotbyztfzfylnytmyztiagylpgejetkceosvstijtdyaeaelaadaeaelaaeaeaelaaoaeaelaadaeaeaeaxaeaeaeaeaekbgdylly")

/// Prints test vectors
/// 
/// This prints the test vectors for:
/// - `Testing/PSBT Signing Request/PSBT 1 of 2/PSBT Signing Request 1 of 2.md`
/// - `Testing/PSBT Signing Request/PSBT 2 of 2/PSBT Signing Request 2 of 2.md`
///
/// To activate:
///   1. Uncomment the call in `SeedTool/ContentView.swift/ContentView.body`
///   2. Run the app.
func printTestPSBTSigningRequests() {
    print("1 of 2")
    let request1Of2 = TransactionRequest(body: PSBTSignatureRequestBody(psbt: psbt1of2))
    print(request1Of2.ur.string)
    print(request1Of2.ur.string.uppercased())
    print(psbt1of2.urString)

    print("2 of 2")
    let request2Of2 = TransactionRequest(body: PSBTSignatureRequestBody(psbt: psbt2of2))
    print(request2Of2.ur.string)
    print(request2Of2.ur.string.uppercased())
    print(psbt2of2.urString)
}

struct PSBTSignatureRequest_Previews: PreviewProvider {
    static let modelAliceAndBob = Model(seeds: [alice, bob], settings: Settings(storage: MockSettingsStorage()))
    static let modelAlice = Model(seeds: [alice], settings: Settings(storage: MockSettingsStorage()))
    static let modelNoSeeds = Model(seeds: [], settings: Settings(storage: MockSettingsStorage()))

    static let settings = Settings(storage: MockSettingsStorage())

    static let signatureRequest1of2 = TransactionRequest(id: ARID(), body: PSBTSignatureRequestBody(psbt: psbt1of2, psbtRequestStyle: .urVersion2))
    static let signatureRequest2of2 = TransactionRequest(id: ARID(), body: PSBTSignatureRequestBody(psbt: psbt2of2, psbtRequestStyle: .urVersion2))
    static let signatureRequest2of2Raw = TransactionRequest(id: ARID(), body: PSBTSignatureRequestBody(psbt: psbt2of2, psbtRequestStyle: .base64))

    static var previews: some View {
        Group {
            ApproveRequest(isPresented: .constant(true), request: signatureRequest1of2)
                .environmentObject(modelAliceAndBob)
                .environmentObject(settings)
                .previewDisplayName("1 of 2")

            ApproveRequest(isPresented: .constant(true), request: signatureRequest2of2)
                .environmentObject(modelAliceAndBob)
                .environmentObject(settings)
                .previewDisplayName("2 of 2")

            ApproveRequest(isPresented: .constant(true), request: signatureRequest2of2)
                .environmentObject(modelAlice)
                .environmentObject(settings)
                .previewDisplayName("2 of 2, Alice Only")

            ApproveRequest(isPresented: .constant(true), request: signatureRequest1of2)
                .environmentObject(modelNoSeeds)
                .environmentObject(settings)
                .previewDisplayName("1 of 2, No Seeds")

            ApproveRequest(isPresented: .constant(true), request: signatureRequest2of2)
                .environmentObject(modelNoSeeds)
                .environmentObject(settings)
                .previewDisplayName("2 of 2, No Seeds")

            ApproveRequest(isPresented: .constant(true), request: signatureRequest2of2Raw)
                .environmentObject(modelAliceAndBob)
                .environmentObject(settings)
                .previewDisplayName("2 of 2, Raw")
        }
        .darkMode()
    }
}

#endif
