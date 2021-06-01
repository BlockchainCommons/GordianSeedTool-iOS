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

struct ApproveTransaction: View {
    @Binding var isPresented: Bool
    let request: TransactionRequest
    
    var body: some View {
        NavigationView {
            ScrollView {
                Group {
                    switch request.body {
                    case .seed(let requestBody):
                        SeedRequest(transactionID: request.id, requestBody: requestBody)
                            .navigationBarTitle("Seed Request")
                    case .key(let requestBody):
                        KeyRequest(transactionID: request.id, requestBody: requestBody)
                            .navigationBarTitle("Key Request")
                    case .psbtSignature(let requestBody):
                        PSBTSignatureRequest(transactionID: request.id, requestBody: requestBody)
                            .navigationBarTitle("PSBT Signature Request")
                    }
                }
                .padding()
            }
            .navigationBarItems(leading: DoneButton($isPresented))
            .copyConfirmation()
        }
    }
}

struct SeedRequest: View {
    let transactionID: UUID
    let requestBody: SeedRequestBody
    let seed: Seed?

    init(transactionID: UUID, requestBody: SeedRequestBody) {
        self.transactionID = transactionID
        self.requestBody = requestBody
        self.seed = model.findSeed(with: requestBody.fingerprint)
    }
    
    var responseUR: UR {
        TransactionResponse(id: transactionID, body: .seed(seed!)).ur
    }

    var body: some View {
        if let seed = seed {
            VStack(alignment: .leading, spacing: 20) {
                Info("Another device is requesting a seed on this device:")
                    .font(.title3)
                ModelObjectIdentity(model: .constant(seed))
                    .frame(height: 100)
                Caution("Sending this seed will allow the other device to derive keys and other objects from it. The seed’s name, notes, and other metadata will also be sent.")
                LockRevealButton {
                    VStack {
                        URDisplay(ur: responseUR)
                        ExportDataButton("Copy as ur:crypto-response", icon: Image("ur.bar"), isSensitive: true) {
                            PasteboardCoordinator.shared.copyToPasteboard(responseUR)
                        }
                    }
                } hidden: {
                    Text("Approve")
                        .foregroundColor(.yellowLightSafe)
                }
            }
        } else {
            Failure("Another device requested a seed that is not on this device.")
        }
    }
}

struct KeyRequest: View {
    let transactionID: UUID
    let requestBody: KeyRequestBody
    @State private var key: HDKey?
    @State private var parentSeed: Seed?
    @State private var isSeedSelectorPresented: Bool = false
    
    init(transactionID: UUID, requestBody: KeyRequestBody) {
        self.transactionID = transactionID
        self.requestBody = requestBody
        let key = model.derive(keyType: requestBody.keyType, path: requestBody.path, useInfo: requestBody.useInfo, isDerivable: requestBody.isDerivable)
        if let key = key {
            self._key = State(wrappedValue: key)
            self._parentSeed = State(wrappedValue: model.findParentSeed(of: key))
        }
    }
    
    var responseUR: UR {
        TransactionResponse(id: transactionID, body: .key(key!)).ur
    }
    
    var body: some View {
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
                        URDisplay(ur: responseUR)
                        ExportDataButton("Copy as ur:crypto-response", icon: Image("ur.bar"), isSensitive: key.keyType == .private) {
                            PasteboardCoordinator.shared.copyToPasteboard(responseUR)
                        }
                    }
                } hidden: {
                    Text("Approve")
                        .foregroundColor(.yellowLightSafe)
                }
            }
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
}

struct PSBTSignatureRequest: View {
    let transactionID: UUID
    let requestBody: PSBTSignatureRequestBody
    
    var body: some View {
        Text("PSBT Signature")
    }
}

#if DEBUG

import WolfLorem

struct ApproveTransaction_Previews: PreviewProvider {
    static let model = Lorem.model()
    static let matchingSeed = model.seeds.first!
    static let nonMatchingSeed = Lorem.seed()

    static func requestForSeed(_ seed: Seed) -> TransactionRequest {
        TransactionRequest(body: .seed(.init(fingerprint: seed.fingerprint)))
    }

    static let matchingSeedRequest = requestForSeed(matchingSeed)
    static let nonMatchingSeedRequest = requestForSeed(nonMatchingSeed)
    
    static func requestForKey(derivedFrom seed: Seed) -> TransactionRequest {
        let useInfo = UseInfo(asset: .btc, network: .testnet)
        let masterKey = HDKey(seed: seed, useInfo: useInfo)
        let keyType = KeyType.public
        let path = KeyExportModel.gordianDerivationPath(useInfo: useInfo, sourceFingerprint: masterKey.keyFingerprint)
        return TransactionRequest(body: .key(.init(keyType: keyType, path: path, useInfo: useInfo, isDerivable: true)))
    }
    
    static let matchingKeyRequest = requestForKey(derivedFrom: matchingSeed)
    static let nonMatchingKeyRequest = requestForKey(derivedFrom: nonMatchingSeed)
    
    static let selectSeedRequest: TransactionRequest = {
        let useInfo = UseInfo(asset: .btc, network: .testnet)
        let keyType = KeyType.public
        let path = KeyExportModel.gordianDerivationPath(useInfo: useInfo, sourceFingerprint: nil)
        return TransactionRequest(body: .key(.init(keyType: keyType, path: path, useInfo: useInfo, isDerivable: true)))
    }()

    static var previews: some View {
        Group {
            ApproveTransaction(isPresented: .constant(true), request: matchingSeedRequest)
            ApproveTransaction(isPresented: .constant(true), request: nonMatchingSeedRequest)
            ApproveTransaction(isPresented: .constant(true), request: matchingKeyRequest)
            ApproveTransaction(isPresented: .constant(true), request: nonMatchingKeyRequest)
            ApproveTransaction(isPresented: .constant(true), request: selectSeedRequest)
        }
        .environmentObject(model)
        .darkMode()
    }
}

#endif
