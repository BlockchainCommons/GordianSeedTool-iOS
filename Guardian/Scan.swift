//
//  Scan.swift
//  Guardian
//
//  Created by Wolf McNally on 2/18/21.
//

import SwiftUI
import WolfSwiftUI
import URKit
import URUI

struct Scan: View {
    @Binding var isPresented: Bool
    let onScanResult: (ScanResult) -> Void
    @StateObject var scanState = URScanState(feedbackProvider: Feedback())
    @State private var scanResult: ScanResult? = nil
    @StateObject private var model: ScanModel = .init()
    @State var errorMessage: String?

    var resultSymbol: some View {
        switch scanState.result! {
        case .failure:
            return Image(systemName: "xmark.octagon.fill")
                .resizable()
                .foregroundColor(.red)
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
        case .ur, .other:
            return Image(systemName: "checkmark.circle.fill")
                .resizable()
                .foregroundColor(.green)
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
        }
    }
    var body: some View {
        let isErrorPresented = Binding<Bool>(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )

        return NavigationView {
            Group {
                if !scanState.isDone {
                    VStack {
                        Text("Scan a QR code to import a seed or respond to a request from another device.")
                        URVideo(scanState: scanState)
                        Spacer()
                        URProgressBar(value: $scanState.estimatedPercentComplete)
                            .padding()
                    }
                } else {
                    resultSymbol
                }
            }
            .onReceive(model.validator) { validation in
                switch validation {
                case .valid:
                    break
                case .invalid(let message):
                    errorMessage = message
                }
            }
            .onReceive(model.resultPublisher) { scanResult in
                if let scanResult = scanResult {
                    self.scanResult = scanResult
                    self.isPresented = false
                }
            }
            .onReceive(scanState.$result) { result in
                switch result {
                case .ur(let ur):
                    model.text = UREncoder.encode(ur)
                case .other(let text):
                    model.text = text
                case .failure(let error):
                    errorMessage = error.localizedDescription
                case nil:
                    break
                }
            }
            .navigationBarItems(leading: DoneButton($isPresented))
            .navigationBarTitle("Scan")
        }
        .onDisappear {
            if let scanResult = scanResult {
                onScanResult(scanResult)
            }
        }
        .alert(isPresented: isErrorPresented) {
            Alert(
                title: Text("Something's Not Right"),
                message: Text(errorMessage!),
                dismissButton: .default(Text("OK")) {
                    isPresented = false
                }
            )
        }
    }
}
