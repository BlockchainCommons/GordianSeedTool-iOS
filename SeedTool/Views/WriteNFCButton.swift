//
//  WriteNFCButton.swift
//  SeedTool
//
//  Created by Wolf McNally on 3/13/22.
//

import SwiftUI
import NFC
import os
import BCFoundation

fileprivate let logger = Logger(subsystem: bundleIdentifier, category: "WriteNFCButton")

struct WriteNFCButton: View {
    let uri: URL
    let isSensitive: Bool
    let alertMessage: String?
    @StateObject private var nfcReader = NFCReader()
    
    init(uri: URL, isSensitive: Bool, alertMessage: String?) {
        self.uri = uri
        self.isSensitive = isSensitive
        self.alertMessage = alertMessage
    }
    
    init(ur: UR, isSensitive: Bool, alertMessage: String?) {
        self.init(uri: URL(string: ur.string)!, isSensitive: isSensitive, alertMessage: alertMessage)
    }

    var body: some View {
        ExportDataButton("Write NFC Tag", icon: Image.nfc, isSensitive: isSensitive) {
            Task {
                do {
                    try await nfcReader.beginSession(alertMessage: alertMessage)
                } catch {
                    logger.error("⛔️ \(error.localizedDescription)")
                }
            }
        }
        .disabled(!NFCReader.isReadingAvailable)
        .onReceive(nfcReader.tagPublisher) { tag in
            Task {
                do {
                    try await nfcReader.writeURI(tag, uri: uri)
                    nfcReader.invalidate()
                } catch {
                    logger.error("⛔️ \(error.localizedDescription)")
                    nfcReader.invalidate(errorMessage: error.localizedDescription)
                }
            }
        }
    }
}
