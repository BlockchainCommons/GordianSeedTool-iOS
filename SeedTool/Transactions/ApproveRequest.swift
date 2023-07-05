//
//  ApproveRequest.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/19/21.
//

import SwiftUI
import WolfSwiftUI
import WolfBase
import BCApp

struct ApproveRequest: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var model: Model
    @EnvironmentObject private var settings: Settings
    let request: TransactionRequest
    
    var body: some View {
        NavigationView {
            ScrollView {
                Group {
                    switch try? request.parseBody() {
                    case let requestBody as SeedRequestBody:
                        ApproveSeedRequest(transactionID: request.id, requestBody: requestBody, note: request.note)
                    case let requestBody as KeyRequestBody:
                        ApproveKeyRequest(transactionID: request.id, requestBody: requestBody, note: request.note)
                    case let requestBody as PSBTSignatureRequestBody:
                        ApprovePSBTSignatureRequest(transactionID: request.id, requestBody: requestBody, note: request.note)
                    case let requestBody as OutputDescriptorRequestBody:
                        ApproveOutputDescriptorRequest(transactionID: request.id, requestBody: requestBody, note: request.note)
                    default:
                        Failure("Unknown request type.")
                    }
                }
                .padding()
                .environmentObject(model)
                .environmentObject(settings)
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    DoneButton($isPresented)
                }
            }
            .copyConfirmation()
        }
    }
}
