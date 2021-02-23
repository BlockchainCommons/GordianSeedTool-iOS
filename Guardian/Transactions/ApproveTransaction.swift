//
//  ApproveTransaction.swift
//  Guardian
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
                        SeedRequest(requestBody: requestBody)
                            .navigationBarTitle("Seed Request")
                    case .key(let requestBody):
                        KeyRequest(requestBody: requestBody)
                            .navigationBarTitle("Key Request")
                    case .psbtSignature(let requestBody):
                        PSBTSignatureRequest(requestBody: requestBody)
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
    let requestBody: SeedRequestBody
    let seed: Seed?

    init(requestBody: SeedRequestBody) {
        self.requestBody = requestBody
        self.seed = model.findSeed(with: requestBody.fingerprint)
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
                    URDisplay(ur: seed.ur)
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
    let requestBody: KeyRequestBody
    let key: HDKey?
    let parentSeed: Seed?
    
    init(requestBody: KeyRequestBody) {
        self.requestBody = requestBody
        self.key = model.derive(keyType: requestBody.keyType, path: requestBody.path, useInfo: requestBody.useInfo)
        if let key = self.key {
            self.parentSeed = model.findParentSeed(of: key)
        } else {
            self.parentSeed = nil
        }
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
                    if key.isMaster {
                        Caution("This is a master private key. All account keys can be derived from it.")
                    }
                    Caution("Sending this private key will allow the other device to sign transactions with it.")
                case .public:
                    if key.isMaster {
                        Info("This is a master public key. All accounts and transactions can be found and audited with it.")
                    }
                    Info("Sending this public key will allow the other device to verify (but not sign) transactions with it.")
                }
                if let parentSeed = parentSeed {
                    Info("The key above was derived from this seed:")
                    ModelObjectIdentity(model: .constant(parentSeed))
                        .frame(height: 64)
                }
                LockRevealButton {
                    URDisplay(ur: key.ur)
                } hidden: {
                    Text("Approve")
                        .foregroundColor(.yellowLightSafe)
                }
            }
        } else {
            Failure("Another device requested a key that cannot be derived from any seed on this device.")
        }
    }
}

struct PSBTSignatureRequest: View {
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
        return TransactionRequest(body: .key(.init(keyType: keyType, path: path, useInfo: useInfo)))
    }
    
    static let matchingKeyRequest = requestForKey(derivedFrom: matchingSeed)
    static let nonMatchingKeyRequest = requestForKey(derivedFrom: nonMatchingSeed)

    static var previews: some View {
        Group {
            ApproveTransaction(isPresented: .constant(true), request: matchingSeedRequest)
            ApproveTransaction(isPresented: .constant(true), request: nonMatchingSeedRequest)
            ApproveTransaction(isPresented: .constant(true), request: matchingKeyRequest)
            ApproveTransaction(isPresented: .constant(true), request: nonMatchingKeyRequest)
        }
        .environmentObject(model)
        .darkMode()
    }
}

#endif
