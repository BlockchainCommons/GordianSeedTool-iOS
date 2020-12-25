//
//  Scanner.swift
//  Fehu
//
//  Created by Wolf McNally on 12/24/20.
//

import SwiftUI
import URKit
import URUI

struct Scanner: View {
    @Binding var text: String
    @StateObject var scanState = URScanState(feedbackProvider: ScanFeedback())
    @State var errorMessage: String?

    var body: some View {
        Group {
            if !scanState.isDone {
                VStack {
                    URVideo(scanState: scanState)
                    Spacer()
                    URProgressBar(value: $scanState.estimatedPercentComplete)
                        .padding()
                }
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                EmptyView()
            }
        }
        .onReceive(scanState.$result) { result in
            switch result {
            case .success(let ur):
                text = UREncoder.encode(ur)
            case .failure(let error):
                errorMessage = error.localizedDescription
            case nil:
                break
            }
        }
    }
}
