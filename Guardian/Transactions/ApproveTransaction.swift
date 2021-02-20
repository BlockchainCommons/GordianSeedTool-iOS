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
    
    var body: some View {
        Text("Key")
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
    static let matchingRequest = TransactionRequest(body: .seed(.init(fingerprint: matchingSeed.fingerprint)))
    static let nonMatchingSeed = Lorem.seed()
    static let nonMatchingRequest = TransactionRequest(body: .seed(.init(fingerprint: nonMatchingSeed.fingerprint)))

    static var previews: some View {
        Group {
            ApproveTransaction(isPresented: .constant(true), request: matchingRequest)
            ApproveTransaction(isPresented: .constant(true), request: nonMatchingRequest)
        }
        .environmentObject(model)
        .darkMode()
    }
}

#endif
