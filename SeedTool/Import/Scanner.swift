//
//  Scanner.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/24/20.
//

import SwiftUI
import URUI
import AVFoundation
import BCFoundation

struct Scanner: View {
    @Binding var text: String
    @StateObject var scanState = URScanState()
    @State var errorMessage: String?
    @State private var estimatedPercentComplete = 0.0
    @State private var result: URScanResult?
    @State private var captureDevices: [AVCaptureDevice] = []
    @State private var currentCaptureDevice: AVCaptureDevice? = nil

    var body: some View {
        Group {
            if !text.isEmpty {
                VStack {
                    URVideo(scanState: scanState, captureDevices: $captureDevices, currentCaptureDevice: $currentCaptureDevice)
                    Spacer()
                    URProgressBar(value: $estimatedPercentComplete)
                        .padding()
                }
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else {
                EmptyView()
            }
        }
        .onReceive(scanState.resultPublisher) { result in
            switch result {
            case .ur(let ur):
                Feedback.success()
                estimatedPercentComplete = 1
                text = UREncoder.encode(ur)
            case .other(let text):
                Feedback.success()
                estimatedPercentComplete = 1
                self.text = text
            case .progress(let p):
                Feedback.progress()
                estimatedPercentComplete = p.estimatedPercentComplete
            case .reject:
                Feedback.error()
            case .failure(let error):
                Feedback.error()
                errorMessage = error.localizedDescription
            }
        }
    }
}
