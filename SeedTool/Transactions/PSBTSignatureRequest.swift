//
//  PSBTView.swift
//  SeedTool
//
//  Created by Wolf McNally on 8/30/21.
//

import SwiftUI
import LibWally
import WolfBase
import URKit

struct PSBTSignatureRequest: View {
    let transactionID: UUID
    let requestBody: PSBTSignatureRequestBody
    let requestDescription: String?
    let psbt: PSBT
    @State var signedPSBT: PSBT?
    @State var isFullySigned: Bool = false
    @State var network: Network = .mainnet
    @State var inputs: [PSBTInputSigning<ModelSeed>] = []
    @State var outputs: [PSBTOutputSigning<ModelSeed>] = []
    @State private var activityParams: ActivityParams?
    @EnvironmentObject var model: Model
    @EnvironmentObject var settings: Settings

    var seeds: [ModelSeed] {
        model.seeds
    }
    
    init(transactionID: UUID, requestBody: PSBTSignatureRequestBody, requestDescription: String?) {
        self.transactionID = transactionID
        self.requestBody = requestBody
        self.requestDescription = requestDescription
        self.psbt = requestBody.psbt
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
    }
    
    var countOfSignableInputs: Int {
        PSBT.countOfSignableInputs(for: inputs)
    }
    
    var canSign: Bool {
        countOfSignableInputs > 0
    }
    
    var countOfUniqueSigners: Int {
        PSBT.countOfUniqueSigners(for: inputs)
    }
    
    func inputsCountString(_ count: Int) -> String {
        String(AttributedString(localized:"^[\(count) \("input")](inflect: true)").characters)
    }
    
    func seedsCountString(_ count: Int) -> String {
        String(AttributedString(localized:"^[\(count) \("seed")](inflect: true)").characters)
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if requestBody.isRawPSBT {
                Caution(Text("This request was received as a bare `ur:crypto-psbt`. Blockchain Commons urges developers to instead use `ur:crypto-request` for PSBT signing."))
            }
            Info("Another device is requesting signing on the inputs of the transaction below.")
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
                    BitcoinValue(symbol: Symbol.txInput, label: "In", value: psbt.totalIn)
                    Text("+")
                }
                HStack(spacing: 5) {
                    BitcoinValue(isChange: false, value: psbt.totalSent)
                    Text("–")
                }
                HStack(spacing: 5) {
                    BitcoinValue(symbol: Symbol.txFee, label: "Fee", value: psbt.fee)
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
                    BitcoinValue(symbol: Symbol.txInput, label: "Amount", value: signing.input.amount)
                    AddressValue(label: "From", address: signing.input.address(network: network))
                    if let (n, m) = signing.input.witnessScript?.multisigInfo {
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
    
    var responseUR: UR {
        TransactionResponse(id: transactionID, body: .psbtSignature(signedPSBT!)).ur
    }
    
    var responsePSBTUR: UR {
        signedPSBT!.ur
    }
    
    @State var isResponseRevealed: Bool = false
    
    @State var isPSBTRevealed: Bool = false

    var approvalSection: some View {
        VStack(alignment: .leading) {
            LockRevealButton(isRevealed: $isResponseRevealed) {
                VStack {
                    URDisplay(ur: responseUR, title: "UR for response")
                    ExportDataButton("Share as ur:crypto-response", icon: Image("ur.bar"), isSensitive: true) {
                        activityParams = ActivityParams(responseUR)
                    }
                }
            } hidden: {
                Text(requestBody.isRawPSBT ? "Approve ur:crypto-response" : "Approve")
                    .foregroundColor(canSign ? .yellowLightSafe : .gray)
            }.disabled(!canSign)

            if requestBody.isRawPSBT {
                LockRevealButton(isRevealed: $isPSBTRevealed) {
                    VStack {
                        URDisplay(ur: responseUR, title: "UR for response")
                        ExportDataButton("Share as ur:crypto-psbt", icon: Image("ur.bar"), isSensitive: true) {
                            activityParams = ActivityParams(responsePSBTUR)
                        }
                    }
                } hidden: {
                    Text("Approve ur:crypto-psbt")
                        .foregroundColor(canSign ? .yellowLightSafe : .gray)
                }.disabled(!canSign)
            }

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
        default:
            return "Unknown status."
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
            self.init(symbol: Symbol.txChange, label: "Change", value: value)
        } else {
            self.init(symbol: Symbol.txSent, label: "Sent", value: value)
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
                    .monospaced()
                    .longPressAction {
                        activityParams = ActivityParams(value.btcFormat)
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
                    .monospaced()
                    .lineLimit(3)
                    .minimumScaleFactor(0.8)
                    .longPressAction {
                        activityParams = ActivityParams(address)
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
                    activityParams = ActivityParams(origin.path.description)
                }
                .background(ActivityView(params: $activityParams))
        }
    }
}

#if DEBUG

struct PSBTSignatureRequest_Previews: PreviewProvider {
    static let alice = try! ModelSeed(urString: "ur:crypto-seed/oeadgdlfwfdwlphlfsghcphfcsaybekkkbaejkaxihfpjziniaihwleorfly")
    static let bob = try! ModelSeed(urString: "ur:crypto-seed/oeadgdcsknhkjkswgtecnslsjtrdfgimfyuykgaxiafwjlidehpyhpht")

    static let psbt1of2 = try! PSBT(urString: "ur:crypto-psbt/hkaohgjojkidjyzmadaeldaoaeaeaeadaxwtatmsbwmhjkdidtftpepkrdsbfsdphydwvtctrefmjlcmmensnltkwneskosnaeaeaeaeaezczmzmzmaoptfradaeaeaeaeaecpaecxrnqznyidfgwyemmkjptdihhghfaettjewygeplvooxfgynndtehfnyjtfsdylabavsaxaeaeaeaeaeaecpaecxwnbwuerplayaqzbkdkgeadissajtcardrnzeskihiorfaedrpdhdplbegypdhyswaeaeaeaeaeadaddngdfzadaeaeaeaeaecpaecximinidchhykidsqzglutqzpeclwnzotizslplurestjnpyadbyckwsrhnnbbchmyadahflgyclaoahvarymnfypdbdbtksflknrswefncpghttlujpfsahbdvsneeymdtikgkpwtuemdclaxguhkfxsnplmnamotkbkpnybtsfbeseaadipttienoxnlvynnknaekimnvyemtbfhgmplcpamaoahvarymnfypdbdbtksflknrswefncpghttlujpfsahbdvsneeymdtikgkpwtuemdcegoadjedldyaeaelaadaeaelaaeaeaelaaoaeaelaaeaeaeaeadaeaeaecpamaxguhkfxsnplmnamotkbkpnybtsfbeseaadipttienoxnlvynnknaekimnvyemtbfhceuehdglzcdyaeaelaadaeaelaaeaeaelaaoaeaelaaeaeaeaeadaeaeaeaeadadflgyclaokiwsaomdfxyavljenbtymdzenbmhfdstrdgsiejseslofgnnbevsswiocnwttoiyclaxylvddnoslpmsimfywkmhzslsrpmhtssffpttjysooltbsrjnlrvectmyytztwdgagmplcpaoaokiwsaomdfxyavljenbtymdzenbmhfdstrdgsiejseslofgnnbevsswiocnwttoiycegoadjedldyaeaelaadaeaelaaeaeaelaaoaeaelaadaeaeaeaoaeaeaecpaoaxylvddnoslpmsimfywkmhzslsrpmhtssffpttjysooltbsrjnlrvectmyytztwdgaceuehdglzcdyaeaelaadaeaelaaeaeaelaaoaeaelaadaeaeaeaoaeaeaeaeaeswregolr")

    static let psbt2of2 = try! PSBT(urString: "ur:crypto-psbt/hkaogrjojkidjyzmadaekiaoaeaeaeadgdvocpvtwszmoslechzcsgaxhsjpeoftsbgohyinmujsrpeefdfewsjokkjokofwaeaeaeaeaezczmzmzmaordbeadaeaeaeaeaecpaecxbemesevwuykocafhhyhsbbjnyaeefptlhgpsbwkgrofsastlmycwdabwehylttbbbediaeaeaeaeaeaecmaebbzmntoniovadldywdlnghzscaheryflrnyavlrnbwaeaeaeaeaeadaddnlaetadaeaeaeaeaecpaecxwdlozewpdlhgtlrsaxfxqdhhmodrzmrlqdwfwtvlmtwyjyvllaaxbysesgotchldadahflgmclaoahvarymnfypdbdbtksflknrswefncpghttlujpfsahbdvsneeymdtikgkpwtuemdclaxbngyhemwsedaksctwsjpatfgtkbkfrkncxcxaxsbcxisetchnldnfxcwfgvosnrlgmplcpamaoahvarymnfypdbdbtksflknrswefncpghttlujpfsahbdvsneeymdtikgkpwtuemdcegoadjedldyaeaelaadaeaelaaeaeaelaaoaeaelaaeaeaeaeadaeaeaecpamaxbngyhemwsedaksctwsjpatfgtkbkfrkncxcxaxsbcxisetchnldnfxcwfgvosnrlceosvstijtdyaeaelaadaeaelaaeaeaelaaoaeaelaaeaeaeaeadaeaeaeaeadadflgmclaoderphszmatynidgdchsppstbmhkbattefplyztoxsatasopknnrhkeclcnoemwecclaovepasewkinldmhssylatneiyfeoxwseenyotbyztfzfylnytmyztiagylpgejetkgmplcpaoaoderphszmatynidgdchsppstbmhkbattefplyztoxsatasopknnrhkeclcnoemweccegoadjedldyaeaelaadaeaelaaeaeaelaaoaeaelaadaeaeaeaxaeaeaecpaoaovepasewkinldmhssylatneiyfeoxwseenyotbyztfzfylnytmyztiagylpgejetkceosvstijtdyaeaelaadaeaelaaeaeaelaaoaeaelaadaeaeaeaxaeaeaeaeaekbgdylly")

    static let modelAliceAndBob = Model(seeds: [alice, bob], settings: Settings(storage: MockSettingsStorage()))
    static let modelAlice = Model(seeds: [alice], settings: Settings(storage: MockSettingsStorage()))
    static let modelNoSeeds = Model(seeds: [], settings: Settings(storage: MockSettingsStorage()))

    static let settings = Settings(storage: MockSettingsStorage())

    static let signatureRequest1of2 = TransactionRequest(id: UUID(), body: .psbtSignature(.init(psbt: psbt1of2)), description: nil)
    static let signatureRequest2of2 = TransactionRequest(id: UUID(), body: .psbtSignature(.init(psbt: psbt2of2)), description: nil)
    
    static var previews: some View {
        Group {
            ApproveTransaction(isPresented: .constant(true), request: signatureRequest1of2)
                .environmentObject(modelAliceAndBob)
                .environmentObject(settings)
                .previewDisplayName("1 of 2")

            ApproveTransaction(isPresented: .constant(true), request: signatureRequest2of2)
                .environmentObject(modelAliceAndBob)
                .environmentObject(settings)
                .previewDisplayName("2 of 2")

            ApproveTransaction(isPresented: .constant(true), request: signatureRequest2of2)
                .environmentObject(modelAlice)
                .environmentObject(settings)
                .previewDisplayName("2 of 2, Alice Only")

            ApproveTransaction(isPresented: .constant(true), request: signatureRequest1of2)
                .environmentObject(modelNoSeeds)
                .environmentObject(settings)
                .previewDisplayName("1 of 2, No Seeds")

            ApproveTransaction(isPresented: .constant(true), request: signatureRequest2of2)
                .environmentObject(modelNoSeeds)
                .environmentObject(settings)
                .previewDisplayName("2 of 2, No Seeds")
        }
        .darkMode()
    }
}

#endif
