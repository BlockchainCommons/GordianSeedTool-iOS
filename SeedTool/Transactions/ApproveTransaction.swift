//
//  ApproveTransaction.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/19/21.
//

import SwiftUI
import WolfSwiftUI
import URUI
import BCFoundation
import WolfBase

struct ApproveTransaction: View {
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
                            .environmentObject(model)
                            .environmentObject(settings)
                            .navigationBarTitle("Seed Request")
                    case .key(let requestBody):
                        KeyRequest(transactionID: request.id, requestBody: requestBody, note: request.note)
                            .environmentObject(model)
                            .environmentObject(settings)
                            .navigationBarTitle("Key Request")
                    case .psbtSignature(let requestBody):
                        PSBTSignatureRequest(transactionID: request.id, requestBody: requestBody, note: request.note)
                            .environmentObject(model)
                            .environmentObject(settings)
                            .navigationBarTitle("Signature Request")
                    }
                }
                .padding()
            }
            .navigationBarItems(trailing: DoneButton($isPresented))
            .copyConfirmation()
        }
    }
}
