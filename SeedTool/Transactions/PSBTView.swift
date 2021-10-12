//
//  PSBTView.swift
//  SeedTool
//
//  Created by Wolf McNally on 8/30/21.
//

import SwiftUI
import LibWally
import WolfBase

struct PSBTView: View {
    let psbt: PSBT
    @State var network: Network = .mainnet
    @State var inputs: [PSBTInputSigning<ModelSeed>] = []
    @State var outputs: [PSBTOutputSigning<ModelSeed>] = []
    @EnvironmentObject var model: Model
    
    var seeds: [ModelSeed] {
        model.seeds
    }
    
    
    init(psbt: PSBT, network: Network) {
        self.psbt = psbt
        self.network = network
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            headerSection
            summarySection
            inputsSection
            outputsSection
        }
        .onAppear {
            inputs = psbt.inputSigning(signers: model.seeds)
            outputs = psbt.outputSigning(signers: model.seeds)
        }
    }
    
    var countOfSignableInputs: Int {
        PSBT.countOfSignableInputs(for: inputs)
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
            Info("Another device is requesting signing on the transaction below.")
            if countOfSignableInputs > 0 {
                Caution("If you approve, this device will sign \(inputsCountString(countOfSignableInputs)) on the transaction using keys derived from \(seedsCountString(countOfUniqueSigners)) on this device.")
            } else {
                Failure("No seeds on this device can be used to derive keys that can sign this transaction.")
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
}

extension PSBTSigningStatus where SignerType == ModelSeed {
    func view(isInput: Bool) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(isInput ? inputStatusString : outputStatusString)
                    .font(Font.system(.caption))
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

fileprivate let alice = try! ModelSeed(urString: "ur:crypto-seed/oeadgdlfwfdwlphlfsghcphfcsaybekkkbaejkaxihfpjziniaihwleorfly")
fileprivate let bob = try! ModelSeed(urString: "ur:crypto-seed/oeadgdcsknhkjkswgtecnslsjtrdfgimfyuykgaxiafwjlidehpyhpht")

fileprivate let psbt1of2 = try! PSBT(urString: "ur:crypto-psbt/hkaohgjojkidjyzmadaeldaoaeaeaeadaxwtatmsbwmhjkdidtftpepkrdsbfsdphydwvtctrefmjlcmmensnltkwneskosnaeaeaeaeaezczmzmzmaoptfradaeaeaeaeaecpaecxrnqznyidfgwyemmkjptdihhghfaettjewygeplvooxfgynndtehfnyjtfsdylabavsaxaeaeaeaeaeaecpaecxwnbwuerplayaqzbkdkgeadissajtcardrnzeskihiorfaedrpdhdplbegypdhyswaeaeaeaeaeadaddngdfzadaeaeaeaeaecpaecximinidchhykidsqzglutqzpeclwnzotizslplurestjnpyadbyckwsrhnnbbchmyadahflgyclaoahvarymnfypdbdbtksflknrswefncpghttlujpfsahbdvsneeymdtikgkpwtuemdclaxguhkfxsnplmnamotkbkpnybtsfbeseaadipttienoxnlvynnknaekimnvyemtbfhgmplcpamaoahvarymnfypdbdbtksflknrswefncpghttlujpfsahbdvsneeymdtikgkpwtuemdcegoadjedldyaeaelaadaeaelaaeaeaelaaoaeaelaaeaeaeaeadaeaeaecpamaxguhkfxsnplmnamotkbkpnybtsfbeseaadipttienoxnlvynnknaekimnvyemtbfhceuehdglzcdyaeaelaadaeaelaaeaeaelaaoaeaelaaeaeaeaeadaeaeaeaeadadflgyclaokiwsaomdfxyavljenbtymdzenbmhfdstrdgsiejseslofgnnbevsswiocnwttoiyclaxylvddnoslpmsimfywkmhzslsrpmhtssffpttjysooltbsrjnlrvectmyytztwdgagmplcpaoaokiwsaomdfxyavljenbtymdzenbmhfdstrdgsiejseslofgnnbevsswiocnwttoiycegoadjedldyaeaelaadaeaelaaeaeaelaaoaeaelaadaeaeaeaoaeaeaecpaoaxylvddnoslpmsimfywkmhzslsrpmhtssffpttjysooltbsrjnlrvectmyytztwdgaceuehdglzcdyaeaelaadaeaelaaeaeaelaaoaeaelaadaeaeaeaoaeaeaeaeaeswregolr")

fileprivate let psbt2of2 = try! PSBT(urString: "ur:crypto-psbt/hkaogrjojkidjyzmadaekiaoaeaeaeadgdvocpvtwszmoslechzcsgaxhsjpeoftsbgohyinmujsrpeefdfewsjokkjokofwaeaeaeaeaezczmzmzmaordbeadaeaeaeaeaecpaecxbemesevwuykocafhhyhsbbjnyaeefptlhgpsbwkgrofsastlmycwdabwehylttbbbediaeaeaeaeaeaecmaebbzmntoniovadldywdlnghzscaheryflrnyavlrnbwaeaeaeaeaeadaddnlaetadaeaeaeaeaecpaecxwdlozewpdlhgtlrsaxfxqdhhmodrzmrlqdwfwtvlmtwyjyvllaaxbysesgotchldadahflgmclaoahvarymnfypdbdbtksflknrswefncpghttlujpfsahbdvsneeymdtikgkpwtuemdclaxbngyhemwsedaksctwsjpatfgtkbkfrkncxcxaxsbcxisetchnldnfxcwfgvosnrlgmplcpamaoahvarymnfypdbdbtksflknrswefncpghttlujpfsahbdvsneeymdtikgkpwtuemdcegoadjedldyaeaelaadaeaelaaeaeaelaaoaeaelaaeaeaeaeadaeaeaecpamaxbngyhemwsedaksctwsjpatfgtkbkfrkncxcxaxsbcxisetchnldnfxcwfgvosnrlceosvstijtdyaeaelaadaeaelaaeaeaelaaoaeaelaaeaeaeaeadaeaeaeaeadadflgmclaoderphszmatynidgdchsppstbmhkbattefplyztoxsatasopknnrhkeclcnoemwecclaovepasewkinldmhssylatneiyfeoxwseenyotbyztfzfylnytmyztiagylpgejetkgmplcpaoaoderphszmatynidgdchsppstbmhkbattefplyztoxsatasopknnrhkeclcnoemweccegoadjedldyaeaelaadaeaelaaeaeaelaaoaeaelaadaeaeaeaxaeaeaecpaoaovepasewkinldmhssylatneiyfeoxwseenyotbyztfzfylnytmyztiagylpgejetkceosvstijtdyaeaelaadaeaelaaeaeaelaaoaeaelaadaeaeaeaxaeaeaeaeaekbgdylly")

struct ExamplePSBT1 {
    static let model = Model(seeds: [alice, bob], settings: Settings(storage: MockSettingsStorage()))
    static let psbt = psbt1of2
}

struct ExamplePSBT2 {
    static let model = Model(seeds: [alice, bob], settings: Settings(storage: MockSettingsStorage()))
    static let psbt = psbt2of2
}

struct ExamplePSBT3 {
    static let model = Model(seeds: [], settings: Settings(storage: MockSettingsStorage()))
    static let psbt = psbt2of2
}

struct PSBTView_Previews: PreviewProvider {

    static var previews: some View {
        ScrollView {
            PSBTView(psbt: ExamplePSBT2.psbt, network: .testnet)
                .environmentObject(ExamplePSBT2.model)
                .padding()
                .darkMode()
        }
    }
}

#endif
