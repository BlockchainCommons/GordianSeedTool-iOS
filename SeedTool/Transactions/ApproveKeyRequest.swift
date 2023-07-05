//
//  ApproveKeyRequest.swift
//  SeedTool
//
//  Created by Wolf McNally on 10/13/21.
//

import SwiftUI
import WolfBase
import BCApp

struct ApproveKeyRequest: View {
    let transactionID: CID
    let requestBody: KeyRequestBody
    let note: String?
    @EnvironmentObject private var model: Model
    @State private var key: ModelHDKey?
    @State private var parentSeed: ModelSeed?
    @State private var isSeedSelectorPresented: Bool = false
    @State private var activityParams: ActivityParams?
    @State private var isResponseRevealed: Bool = false

    init(transactionID: CID, requestBody: KeyRequestBody, note: String?) {
        self.transactionID = transactionID
        self.requestBody = requestBody
        self.note = note
    }
    
    var responseUR: UR {
        TransactionResponse(id: transactionID, result: HDKey(key!)).ur
    }
    
    func haveKey(key: ModelHDKey) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Info("Another device is requesting a key on this device:")
                .font(.title3)
            TransactionChat {
                Rebus {
                    requestBody.keyType.image
                    Image.questionmark
                }
            }
            ObjectIdentityBlock(model: .constant(key))
                .frame(height: 100)
            RequestNote(note: note)
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
            OutputPathInfo(path: requestBody.path)
            if let parentSeed = parentSeed {
                Info("This key is derived from this seed:")
                ObjectIdentityBlock(model: .constant(parentSeed))
                    .frame(height: 80)
            }
            LockRevealButton(isRevealed: $isResponseRevealed, isSensitive: key.keyType.isPrivate, isChatBubble: true) {
                VStack(alignment: .trailing, spacing: 20) {
                    Rebus {
                        requestBody.keyType.image
                        Symbol.sentItem
                    }
                    URDisplay(
                        ur: responseUR,
                        name: key.name,
                        fields: Self.responseFields(key: key, seed: parentSeed!)
                    )
                    VStack(alignment: .trailing) {
                        ExportDataButton("Share as ur:\(responseUR.type)", icon: Image.ur, isSensitive: key.keyType == .private) {
                            activityParams = ActivityParams(
                                responseUR,
                                name: key.name,
                                fields: Self.responseFields(key: key, seed: parentSeed!)
                            )
                        }
                        WriteNFCButton(ur: key.ur, isSensitive: key.isPrivate, alertMessage: "Write UR for \(key.name).")
                    }
                }
            } hidden: {
                Text("Approve")
                    .foregroundColor(key.keyType.isPrivate ? Color.yellowLightSafe : .accentColor)
            }
        }
        .background(ActivityView(params: $activityParams))
    }
    
    static func responseFields(key: ModelHDKey, seed: ModelSeed, placeholder: String? = nil) -> ExportFields {
        var fields: ExportFields = [
            .rootID: seed.digestIdentifier,
            .id: key.digestIdentifier,
            .type: "Response-\(key.typeString)",
            .subtype: key.subtypeString,
            .format: "UR"
        ]
        if let placeholder = placeholder {
            fields[.placeholder] = placeholder
        }
        return fields
    }
    
    var chat: some View {
        TransactionChat {
            Rebus {
                VStack {
                    HStack {
                        requestBody.keyType.icon
                            .frame(height: 48)
                            .fixedSize()
                        requestBody.useInfo.asset.icon
                        requestBody.useInfo.network.icon
                    }
                    Text("[m/\(requestBody.path.description)]")
                        .appMonospaced()
                        .fixedSize()
                        .lineLimit(1)
                }
                Image.questionmark
            }
        }
    }
    
    @ViewBuilder
    func noKey() -> some View {
        if requestBody.path.originFingerprint == nil {
            VStack(spacing: 20) {
                Info("Another device is requesting a \(requestBody.keyType.name.lowercased()) key from this device with this derivation:")
                    .font(.title3)
                
                chat
                RequestNote(note: note)
                OutputPathInfo(path: requestBody.path)
                Text("Select the seed from which you would like to derive the key.")
                
                Button {
                    isSeedSelectorPresented = true
                } label: {
                    Text("Select Seed")
                }
                .buttonStyle(.bordered)
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
            TransactionChat(response: .error) {
                Rebus {
                    requestBody.keyType.image
                    Image.questionmark
                }
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
        .navigationBarTitle("Key Request")
    }
}

#if DEBUG

import WolfLorem

struct KeyRequest_Previews: PreviewProvider {
    static let model = Lorem.model()
    static let settings = Settings(storage: MockSettingsStorage())
    static let matchingSeed = model.seeds.first!
    static let nonMatchingSeed = Lorem.seed()
    
    static func requestForKey(derivedFrom seed: ModelSeed, keyType: KeyType) -> TransactionRequest {
        let useInfo = UseInfo(asset: .btc, network: .testnet)
        let masterKey = try! ModelHDKey(seed: seed, useInfo: useInfo)
        let path = KeyExportDerivationPreset.cosigner.path(useInfo: useInfo, sourceFingerprint: masterKey.keyFingerprint)
        return TransactionRequest(body: KeyRequestBody(keyType: keyType, path: path, useInfo: useInfo))
    }
    
    static let matchingKeyRequest = requestForKey(derivedFrom: matchingSeed, keyType: .private)
    static let nonMatchingKeyRequest = requestForKey(derivedFrom: nonMatchingSeed, keyType: .public)
    
    static let selectSeedRequest: TransactionRequest = {
        let useInfo = UseInfo(asset: .btc, network: .testnet)
        let keyType = KeyType.public
        let path = KeyExportDerivationPreset.cosigner.path(useInfo: useInfo)
        return TransactionRequest(body: KeyRequestBody(keyType: keyType, path: path, useInfo: useInfo))
    }()

    static var previews: some View {
        Group {
            ApproveRequest(isPresented: .constant(true), request: matchingKeyRequest)
                .environmentObject(model)
                .environmentObject(settings)
                .previewDisplayName("Matching Key Request")

            ApproveRequest(isPresented: .constant(true), request: nonMatchingKeyRequest)
                .environmentObject(model)
                .environmentObject(settings)
                .previewDisplayName("Non-Matching Key Request")

            ApproveRequest(isPresented: .constant(true), request: selectSeedRequest)
                .environmentObject(model)
                .environmentObject(settings)
                .previewDisplayName("Select Seed Request")
        }
        .environmentObject(model)
        .darkMode()
    }
}

#endif
