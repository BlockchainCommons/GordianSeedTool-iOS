//
//  ApproveTransaction.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/19/21.
//

import SwiftUI
import WolfSwiftUI
import URKit
import URUI
import LibWally
import WolfBase

struct ApproveTransaction: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var model: Model
    let request: TransactionRequest
    
    var body: some View {
        NavigationView {
            ScrollView {
                Group {
                    switch request.body {
                    case .seed(let requestBody):
                        SeedRequest(transactionID: request.id, requestBody: requestBody, requestDescription: request.requestDescription)
                            .environmentObject(model)
                            .navigationBarTitle("Seed Request")
                    case .key(let requestBody):
                        KeyRequest(transactionID: request.id, requestBody: requestBody, requestDescription: request.requestDescription)
                            .environmentObject(model)
                            .navigationBarTitle("Key Request")
                    case .psbtSignature(let requestBody):
                        PSBTSignatureRequest(transactionID: request.id, requestBody: requestBody, requestDescription: request.requestDescription)
                            .environmentObject(model)
                            .navigationBarTitle("PSBT Signature Request")
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: DoneButton($isPresented))
            .copyConfirmation()
        }
    }
}

struct SeedRequest: View {
    let transactionID: UUID
    let requestBody: SeedRequestBody
    let requestDescription: String?
    @EnvironmentObject private var model: Model
    @State private var seed: ModelSeed?
    @State private var activityParams: ActivityParams?

    init(transactionID: UUID, requestBody: SeedRequestBody, requestDescription: String?) {
        self.transactionID = transactionID
        self.requestBody = requestBody
        self.requestDescription = requestDescription
    }
    
    var responseUR: UR {
        TransactionResponse(id: transactionID, body: .seed(seed!)).ur
    }

    var body: some View {
        Group {
            if let seed = seed {
                VStack(alignment: .leading, spacing: 20) {
                    Info("Another device is requesting a seed on this device:")
                        .font(.title3)
                    ModelObjectIdentity(model: .constant(seed))
                        .frame(height: 100)
                    Caution("Sending this seed will allow the other device to derive keys and other objects from it. The seed’s name, notes, and other metadata will also be sent.")
                    LockRevealButton {
                        VStack {
                            URDisplay(ur: responseUR, title: "UR for response")
                            ExportDataButton("Share as ur:crypto-response", icon: Image("ur.bar"), isSensitive: true) {
                                activityParams = ActivityParams(responseUR)
                            }
                        }
                    } hidden: {
                        Text("Approve")
                            .foregroundColor(.yellowLightSafe)
                    }
                }
                .background(ActivityView(params: $activityParams))
            } else {
                Failure("Another device requested a seed that is not on this device.")
            }
        }
        .onAppear {
            seed = model.findSeed(with: requestBody.fingerprint)
        }
    }
}

struct KeyRequest: View {
    let transactionID: UUID
    let requestBody: KeyRequestBody
    let requestDescription: String?
    @EnvironmentObject private var model: Model
    @State private var key: HDKey?
    @State private var parentSeed: ModelSeed?
    @State private var isSeedSelectorPresented: Bool = false
    @State private var activityParams: ActivityParams?

    init(transactionID: UUID, requestBody: KeyRequestBody, requestDescription: String?) {
        self.transactionID = transactionID
        self.requestBody = requestBody
        self.requestDescription = requestDescription
    }
    
    var responseUR: UR {
        TransactionResponse(id: transactionID, body: .key(key!)).ur
    }
    
    var body: some View {
        Group {
            if let key = key {
                VStack(alignment: .leading, spacing: 20) {
                    Info("Another device is requesting a key on this device:")
                        .font(.title3)
                    ModelObjectIdentity(model: .constant(key))
                        .frame(height: 100)
                    switch key.keyType {
                    case .private:
                        if key.isMaster && key.isDerivable {
                            Caution("This is a master private key. All account keys can be derived from it.")
                        }
                        Caution("Sending this private key will allow the other device to sign transactions with it.")
                    case .public:
                        if key.isMaster && key.isDerivable {
                            Info("This is a master public key. All accounts and transactions can be found and audited with it.")
                        }
                        Info("Sending this public key will allow the other device to verify (but not sign) transactions with it.")
                    }
                    if key.isDerivable {
                        Caution("This key is derivable: additional keys can be derived from it.")
                    } else {
                        Info("This key is not derivable: it can be used by iself, but further keys cannot be derived from it.")
                    }
                    if let parentSeed = parentSeed {
                        Info("The key above was derived from this seed:")
                        ModelObjectIdentity(model: .constant(parentSeed))
                            .frame(height: 64)
                    }
                    LockRevealButton {
                        VStack {
                            URDisplay(ur: responseUR, title: "UR for key response")
                            ExportDataButton("Share as ur:crypto-response", icon: Image("ur.bar"), isSensitive: key.keyType == .private) {
                                activityParams = ActivityParams(responseUR)
                            }
                        }
                    } hidden: {
                        Text("Approve")
                            .foregroundColor(.yellowLightSafe)
                    }
                }
                .background(ActivityView(params: $activityParams))
            } else {
                if requestBody.path.sourceFingerprint == nil {
                    VStack(spacing: 20) {
                        Info("Another device is requesting a \(requestBody.keyType.name.lowercased()) key from this device with this derivation:")
                            .font(.title3)
                        HStack(spacing: 5) {
                            requestBody.keyType.icon
                                .frame(height: 48)
                            requestBody.useInfo.asset.icon
                            requestBody.useInfo.network.icon
                            Text("[m/\(requestBody.path.description)]")
                                .monospaced()
                        }
                        Info("Select the seed from which you would like to derive the key.")
                        
                        Button {
                            isSeedSelectorPresented = true
                        } label: {
                            Text("Select Seed")
                                .bold()
                                .padding(10)
                        }
                        .formSectionStyle()
                    }
                    .sheet(isPresented: $isSeedSelectorPresented) {
                        SeedSelector(isPresented: $isSeedSelectorPresented, prompt: "Select the seed for this derivation.") { seed in
                            withAnimation {
                                parentSeed = seed;
                                let masterKey = HDKey(seed: seed, useInfo: requestBody.useInfo);
                                key = try! HDKey(parent: masterKey, derivedKeyType: requestBody.keyType, childDerivationPath: requestBody.path, isDerivable: requestBody.isDerivable)
                            }
                        }
                    }
                } else {
                    Failure("Another device requested a key that cannot be derived from any seed on this device.")
                }
            }
        }
        .onAppear {
            let key = model.derive(keyType: requestBody.keyType, path: requestBody.path, useInfo: requestBody.useInfo, isDerivable: requestBody.isDerivable)
            if let key = key {
                self.key = key
                self.parentSeed = model.findParentSeed(of: key)
            }
        }
    }
}

struct PSBTSignatureRequest: View {
    let transactionID: UUID
    let requestBody: PSBTSignatureRequestBody
    let requestDescription: String?
    @EnvironmentObject private var model: Model
    let psbt: PSBT

    init(transactionID: UUID, requestBody: PSBTSignatureRequestBody, requestDescription: String?) {
        self.transactionID = transactionID
        self.requestBody = requestBody
        self.requestDescription = requestDescription
        self.psbt = requestBody.psbt
    }

    var body: some View {
        Text("PSBT")
//        PSBTView(psbt: psbt)
    }
}

#if DEBUG

import WolfLorem

struct ApproveTransaction_Previews: PreviewProvider {
    static let model = Lorem.model()
    static let matchingSeed = model.seeds.first!
    static let nonMatchingSeed = Lorem.seed()

    static func requestForSeed(_ seed: ModelSeed) -> TransactionRequest {
        TransactionRequest(body: .seed(.init(fingerprint: seed.fingerprint)))
    }

    static let matchingSeedRequest = requestForSeed(matchingSeed)
    static let nonMatchingSeedRequest = requestForSeed(nonMatchingSeed)
    
    static func requestForKey(derivedFrom seed: ModelSeed) -> TransactionRequest {
        let useInfo = UseInfo(asset: .btc, network: .testnet)
        let masterKey = HDKey(seed: seed, useInfo: useInfo)
        let keyType = KeyType.public
        let path = KeyExportDerivationPreset.cosigner.path(useInfo: useInfo, sourceFingerprint: masterKey.keyFingerprint)
        return TransactionRequest(body: .key(.init(keyType: keyType, path: path, useInfo: useInfo)))
    }
    
    static let matchingKeyRequest = requestForKey(derivedFrom: matchingSeed)
    static let nonMatchingKeyRequest = requestForKey(derivedFrom: nonMatchingSeed)
    
    static let selectSeedRequest: TransactionRequest = {
        let useInfo = UseInfo(asset: .btc, network: .testnet)
        let keyType = KeyType.public
        let path = KeyExportDerivationPreset.cosigner.path(useInfo: useInfo)
        return TransactionRequest(body: .key(.init(keyType: keyType, path: path, useInfo: useInfo)))
    }()
        
    static var previews: some View {
        Group {
            ApproveTransaction(isPresented: .constant(true), request: matchingSeedRequest)
                .previewDisplayName("Matching Seed Request")

            ApproveTransaction(isPresented: .constant(true), request: nonMatchingSeedRequest)
                .previewDisplayName("Non-Matching Seed Request")

            ApproveTransaction(isPresented: .constant(true), request: matchingKeyRequest)
                .previewDisplayName("Matching Key Request")

            ApproveTransaction(isPresented: .constant(true), request: nonMatchingKeyRequest)
                .previewDisplayName("Non-Matching Key Request")

            ApproveTransaction(isPresented: .constant(true), request: selectSeedRequest)
                .previewDisplayName("Select Seed Request")
        }
        .environmentObject(model)
        .darkMode()
    }
}

#endif
