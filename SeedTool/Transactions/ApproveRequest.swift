//
//  ApproveRequest.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/19/21.
//

import SwiftUI
import WolfSwiftUI
import URUI
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
                    switch request.body {
                    case .seed(let requestBody):
                        SeedRequest(transactionID: request.id, requestBody: requestBody, note: request.note)
                    case .key(let requestBody):
                        KeyRequest(transactionID: request.id, requestBody: requestBody, note: request.note)
                    case .psbtSignature(let requestBody):
                        PSBTSignatureRequest(transactionID: request.id, requestBody: requestBody, note: request.note)
                    case .outputDescriptor(let requestBody):
                        OutputDescriptorRequest(transactionID: request.id, requestBody: requestBody, note: request.note)
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
