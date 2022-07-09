//
//  SeedRequest.swift
//  SeedTool
//
//  Created by Wolf McNally on 10/13/21.
//

import SwiftUI
import LifeHash
import BCApp

struct SeedRequest: View {
    let transactionID: UUID
    let requestBody: SeedRequestBody
    let note: String?
    @EnvironmentObject private var model: Model
    @State private var seed: ModelSeed?
    @State private var activityParams: ActivityParams?
    @State private var isResponseRevealed: Bool = false

    init(transactionID: UUID, requestBody: SeedRequestBody, note: String?) {
        self.transactionID = transactionID
        self.requestBody = requestBody
        self.note = note
    }
    
    var responseUR: UR {
        TransactionResponse(id: transactionID, body: .seed(seed!)).ur
    }
    
    var responseFields: ExportFields {
        [
            .id: seed!.digestIdentifier,
            .placeholder: "Response with \(seed!.name)",
            .type: "Response",
            .subtype: "Seed",
            .format: "UR",
        ]
    }

    var body: some View {
        Group {
            if let seed = seed {
                VStack(alignment: .leading, spacing: 20) {
                    Info("Another device is requesting a specific seed on this device.")
                        .font(.title3)
                    TransactionChat {
                        HStack {
                            Image.seed
                            Image.questionmark
                        }
                    }
                    ObjectIdentityBlock(model: .constant(seed))
                        .frame(height: 100)
                    RequestNote(note: note)
                    Caution("Sending this seed will allow the other device to derive keys and other objects from it. The seed’s name, notes, and other metadata will also be sent.")
                    LockRevealButton(isRevealed: $isResponseRevealed, isSensitive: true, isChatBubble: true) {
                        VStack {
                            URDisplay(
                                ur: responseUR,
                                name: seed.name,
                                fields: responseFields
                            )
                            ExportDataButton("Share as ur:crypto-response", icon: Image.ur, isSensitive: true) {
                                activityParams = ActivityParams(
                                    responseUR,
                                    name: seed.name,
                                    fields: responseFields
                                )
                            }
                            WriteNFCButton(ur: responseUR, isSensitive: true, alertMessage: "Write UR for response.")
                        }
                    } hidden: {
                        Text("Approve")
                            .foregroundColor(.yellowLightSafe)
                    }
                }
                .background(ActivityView(params: $activityParams))
            } else {
                Failure("Another device requested a specific seed that is not on this device.")
                TransactionChat(cannotRespond: true) {
                    HStack {
                        Image.seed
                        Image.questionmark
                    }
                }
            }
        }
        .onAppear {
            seed = model.findSeed(with: Fingerprint(digest: requestBody.digest))
        }
    }
}

#if DEBUG

import WolfLorem

struct SeedRequest_Previews: PreviewProvider {
    static let model = Lorem.model()
    static let settings = Settings(storage: MockSettingsStorage())
    static let matchingSeed = model.seeds.first!
    static let nonMatchingSeed = Lorem.seed()

    static func requestForSeed(_ seed: ModelSeed) -> TransactionRequest {
        try! TransactionRequest(body: .seed(.init(digest: seed.fingerprint.digest)))
    }

    static let matchingSeedRequest = requestForSeed(matchingSeed)
    static let nonMatchingSeedRequest = requestForSeed(nonMatchingSeed)
        
    static var previews: some View {
        Group {
            ApproveTransaction(isPresented: .constant(true), request: matchingSeedRequest)
                .environmentObject(model)
                .environmentObject(settings)
                .previewDisplayName("Matching Seed Request")

            ApproveTransaction(isPresented: .constant(true), request: nonMatchingSeedRequest)
                .environmentObject(model)
                .environmentObject(settings)
                .previewDisplayName("Non-Matching Seed Request")
        }
        .environmentObject(model)
        .darkMode()
    }
}

#endif
