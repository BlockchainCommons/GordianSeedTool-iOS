//
//  KeyRequest.swift
//  SeedTool
//
//  Created by Wolf McNally on 10/13/21.
//

import SwiftUI
import URKit
import LibWally

struct KeyRequest: View {
    let transactionID: UUID
    let requestBody: KeyRequestBody
    let requestDescription: String?
    @EnvironmentObject private var model: Model
    @State private var key: ModelHDKey?
    @State private var parentSeed: ModelSeed?
    @State private var isSeedSelectorPresented: Bool = false
    @State private var activityParams: ActivityParams?
    @State private var isResponseRevealed: Bool = false

    init(transactionID: UUID, requestBody: KeyRequestBody, requestDescription: String?) {
        self.transactionID = transactionID
        self.requestBody = requestBody
        self.requestDescription = requestDescription
    }
    
    var responseUR: UR {
        TransactionResponse(id: transactionID, body: .key(key!)).ur
    }
    
    func haveKey(key: ModelHDKey) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Info("Another device is requesting a key on this device:")
                .font(.title3)
            ObjectIdentityBlock(model: .constant(key))
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
                ObjectIdentityBlock(model: .constant(parentSeed))
                    .frame(height: 64)
            }
            LockRevealButton(isRevealed: $isResponseRevealed) {
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
    }
    
    func noKey() -> some View {
        Group {
            if requestBody.path.originFingerprint == nil {
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
                            let masterKey = try! ModelHDKey(seed: seed, useInfo: requestBody.useInfo);
                            key = try! ModelHDKey(parent: masterKey, derivedKeyType: requestBody.keyType, childDerivationPath: requestBody.path, isDerivable: requestBody.isDerivable)
                        }
                    }
                }
            } else {
                Failure("Another device requested a key that cannot be derived from any seed on this device.")
            }
        }
    }
    
    var main: some View {
        Group {
            if let key = key {
                haveKey(key: key)
            } else {
                noKey()
            }
        }
    }
    
    var body: some View {
        main
        .onAppear {
            let key = model.derive(keyType: requestBody.keyType, path: requestBody.path, useInfo: requestBody.useInfo, isDerivable: requestBody.isDerivable)
            if let key = key {
                self.key = key
                self.parentSeed = model.findParentSeed(of: key)
            }
        }
    }
}

#if DEBUG

import WolfLorem

struct KeyRequest_Previews: PreviewProvider {
    static let model = Lorem.model()
    static let settings = Settings(storage: MockSettingsStorage())
    static let matchingSeed = model.seeds.first!
    static let nonMatchingSeed = Lorem.seed()
    
    static func requestForKey(derivedFrom seed: ModelSeed) -> TransactionRequest {
        let useInfo = UseInfo(asset: .btc, network: .testnet)
        let masterKey = try! ModelHDKey(seed: seed, useInfo: useInfo)
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
            ApproveTransaction(isPresented: .constant(true), request: matchingKeyRequest)
                .environmentObject(model)
                .environmentObject(settings)
                .previewDisplayName("Matching Key Request")

            ApproveTransaction(isPresented: .constant(true), request: nonMatchingKeyRequest)
                .environmentObject(model)
                .environmentObject(settings)
                .previewDisplayName("Non-Matching Key Request")
        }
        .environmentObject(model)
        .darkMode()
    }
}

#endif
