//
//  PSBTView.swift
//  SeedTool
//
//  Created by Wolf McNally on 8/30/21.
//

import SwiftUI
import LibWally
import WolfBase

struct IDWrapper<T>: Identifiable, Hashable {
    let index: Int
    let value: T
    
    init(index: Int, value: T) {
        self.index = index
        self.value = value
    }
    
    var id: Int {
        index
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension IDWrapper: CustomStringConvertible where T: CustomStringConvertible {
    var description: String {
        value.description
    }
}

struct PSBTView: View {
    let psbt: PSBT
    let network: Network
    
    let isFinalized: Bool
    let inputs: [IDWrapper<PSBTInput>]
    let outputs: [IDWrapper<PSBTOutput>]
    
    init(psbt: PSBT, network: Network) {
        self.psbt = psbt
        self.network = network
        
        self.isFinalized = psbt.isFinalized
        self.inputs = psbt.inputs.enumerated().map { IDWrapper(index: $0.0, value: $0.1) }
        self.outputs = psbt.outputs.enumerated().map { IDWrapper(index: $0.0, value: $0.1) }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            inputsSection
            outputsSection
//            Text("Outputs: \(psbt.outputs.count)")
//            ForEach(outputs) { output in
//                Text("Output \(output.index + 1)")
//                Text("Address: \(output.value.address(network: network))")
//                Text("Amount: \(output.value.amount)")
//            }
//            Text("Fee: \(psbt.fee†)")
//            Text("isFinalized: \(isFinalized†)")
        }
    }
    
    var inputsSection: some View {
        GroupBox(label: Text("Inputs")) {
            ForEach(inputs) { input in
                Text("Input #\(input.index + 1)")
//                VStack {
//                    Text($0.index)
//                    Text($0.description)
//                }
            }
        }
        .formGroupBoxStyle()
    }
    
    static func path(for output: PSBTOutput) -> String {
        let origins = output.origins
        if !origins.isEmpty {
            return "\(origins)"
        } else {
            return "unknown"
        }
    }
    
    var outputsSection: some View {
        GroupBox(label: Text("Outputs")) {
            ForEach(outputs) { o in
                let output = o.value
                VStack(alignment: .leading) {
                    Text("Output #\(o.index + 1)")
                    Text("Address: \(output.address(network: network))")
                    Text("Amount: \(output.amount)")
                    Text("Origins: \(Self.path(for: output))")
                }
            }
        }
        .formGroupBoxStyle()
    }
}

#if DEBUG

struct ExamplePSBT1 {
    static let alice = try! ModelSeed(urString: "ur:crypto-seed/oeadgdlfwfdwlphlfsghcphfcsaybekkkbaejkaxihfpjziniaihwleorfly")
    static let bob = try! ModelSeed(urString: "ur:crypto-seed/oeadgdcsknhkjkswgtecnslsjtrdfgimfyuykgaxiafwjlidehpyhpht")
    static let model = Model(seeds: [alice, bob], settings: Settings(storage: MockSettingsStorage()))
    static let psbt = try! PSBT(urString: "ur:crypto-psbt/hkaohgjojkidjyzmadaeldaoaeaeaeadaxwtatmsbwmhjkdidtftpepkrdsbfsdphydwvtctrefmjlcmmensnltkwneskosnaeaeaeaeaezczmzmzmaoptfradaeaeaeaeaecpaecxrnqznyidfgwyemmkjptdihhghfaettjewygeplvooxfgynndtehfnyjtfsdylabavsaxaeaeaeaeaeaecpaecxwnbwuerplayaqzbkdkgeadissajtcardrnzeskihiorfaedrpdhdplbegypdhyswaeaeaeaeaeadaddngdfzadaeaeaeaeaecpaecximinidchhykidsqzglutqzpeclwnzotizslplurestjnpyadbyckwsrhnnbbchmyadahflgyclaoahvarymnfypdbdbtksflknrswefncpghttlujpfsahbdvsneeymdtikgkpwtuemdclaxguhkfxsnplmnamotkbkpnybtsfbeseaadipttienoxnlvynnknaekimnvyemtbfhgmplcpamaoahvarymnfypdbdbtksflknrswefncpghttlujpfsahbdvsneeymdtikgkpwtuemdcegoadjedldyaeaelaadaeaelaaeaeaelaaoaeaelaaeaeaeaeadaeaeaecpamaxguhkfxsnplmnamotkbkpnybtsfbeseaadipttienoxnlvynnknaekimnvyemtbfhceuehdglzcdyaeaelaadaeaelaaeaeaelaaoaeaelaaeaeaeaeadaeaeaeaeadadflgyclaokiwsaomdfxyavljenbtymdzenbmhfdstrdgsiejseslofgnnbevsswiocnwttoiyclaxylvddnoslpmsimfywkmhzslsrpmhtssffpttjysooltbsrjnlrvectmyytztwdgagmplcpaoaokiwsaomdfxyavljenbtymdzenbmhfdstrdgsiejseslofgnnbevsswiocnwttoiycegoadjedldyaeaelaadaeaelaaeaeaelaaoaeaelaadaeaeaeaoaeaeaecpaoaxylvddnoslpmsimfywkmhzslsrpmhtssffpttjysooltbsrjnlrvectmyytztwdgaceuehdglzcdyaeaelaadaeaelaaeaeaelaaoaeaelaadaeaeaeaoaeaeaeaeaeswregolr")
}

struct PSBTView_Previews: PreviewProvider {

    static var previews: some View {
        ScrollView {
            PSBTView(psbt: ExamplePSBT1.psbt, network: .testnet)
                .darkMode()
        }
    }
}

#endif
