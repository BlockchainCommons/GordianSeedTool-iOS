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
    @Environment(Model.self) private var model
    @Environment(Settings.self) private var settings
    let request: TransactionRequest

    internal init(isPresented: Binding<Bool>, request: TransactionRequest) {
        self._isPresented = isPresented
        self.request = request
    }

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
                .environment(model)
                .environment(settings)
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
