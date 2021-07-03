//
//  Scan.swift
//  Gordian Seed Tool
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
    @StateObject var scanState = URScanState()
    @State private var scanResult: ScanResult? = nil
    @StateObject private var sskrDecoder: SSKRDecoder
    @StateObject private var model: ScanModel
    @State private var estimatedPercentComplete = 0.0
    
    init(isPresented: Binding<Bool>, onScanResult: @escaping (ScanResult) -> Void) {
        self._isPresented = isPresented
        self.onScanResult = onScanResult
        let sskrDecoder = SSKRDecoder {
            Feedback.progress()
        }
        self._sskrDecoder = StateObject(wrappedValue: sskrDecoder)
        self._model = StateObject(wrappedValue: ScanModel(sskrDecoder: sskrDecoder))
    }
    
    var resultView: some View {
        VStack {
            switch scanResult! {
            case .failure(let error):
                Image(systemName: "xmark.octagon.fill")
                    .resizable()
                    .foregroundColor(.red)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                Text(error.localizedDescription)
            default:
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .foregroundColor(.green)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
            }
        }
        .padding()
    }
    
    func sskrMemberView(color: Color) -> some View {
        Rectangle()
            .fill(color)
            .frame(width: 30, height: 10)
    }

    func sskrMemberView(isPresent: Bool) -> some View {
        sskrMemberView(color: isPresent ? Color.green : Color.yellow)
    }
    
    func sskrGroupView(group: SSKRDecoder.Group) -> some View {
        HStack(spacing: 10) {
            Text("\(group.index + 1)")
                .foregroundColor(group.isSatisfied ? .green : .yellow)
            if let memberStatus = group.memberStatus {
                ForEach(memberStatus) { status in
                    sskrMemberView(isPresent: status.isPresent)
                }
            } else {
                sskrMemberView(color: .clear)
            }
        }
    }
    
    var sskrStatusView: some View {
        VStack {
            if let groupThreshold = sskrDecoder.groupThreshold {
                VStack {
                    Label(
                        title: { Text("Recover from SSKR") },
                        icon: { Image("sskr.bar") }
                    )
                        .font(.title)
                    Spacer()
                        .frame(height: 10)
                    Text("\(groupThreshold) of \(sskrDecoder.groups.count) Groups")
                    Spacer()
                        .frame(height: 10)
                    VStack(alignment: .leading) {
                        ForEach(sskrDecoder.groups) { group in
                            sskrGroupView(group: group)
                        }
                    }
                }
                .font(Font.system(.title3).monospacedDigit().bold())
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
            }
        }
    }
    
    var scanView: some View {
        VStack {
            Text("Scan a QR code to import a seed or respond to a request from another device.")
            ZStack {
                URVideo(scanState: scanState)
                sskrStatusView
            }
            URProgressBar(value: $estimatedPercentComplete)
                .padding()
            Text("Or paste a ur:crypto-seed or ur:crypto-request from the clipboard.")
                .padding()
            ExportDataButton("Paste", icon: Image(systemName: "doc.on.clipboard"), isSensitive: false) {
                if let string = UIPasteboard.general.string {
                    model.receive(urString: string)
                } else {
                    Feedback.error()
                    scanResult = .failure(GeneralError("The clipboard does not contain a valid ur:crypto-seed, ur:crypto-request, or ur:crypto-sskr."))
                }
            }
            .padding(.bottom)
        }
        .padding(Application.isCatalyst ? 20 : 0)
        .onReceive(model.resultPublisher) { scanResult in
            switch scanResult {
            case .seed, .request:
                Feedback.success()
                self.scanResult = scanResult
                isPresented = false
            case .failure:
                Feedback.error()
                self.scanResult = scanResult
            }
        }
        .onReceive(scanState.resultPublisher) { result in
            guard scanResult == nil else {
                return
            }
            switch result {
            case .ur(let ur):
                model.receive(ur: ur)
                scanState.restart()
            case .other:
                Feedback.error()
                scanResult = .failure(GeneralError("Unrecognized format."))
            case .progress(let p):
                Feedback.progress()
                estimatedPercentComplete = p.estimatedPercentComplete
            case .reject:
                Feedback.error()
            case .failure(let error):
                Feedback.error()
                scanResult = .failure(GeneralError(error.localizedDescription))
            }
        }
    }
    
    var body: some View {
        return NavigationView {
            Group {
                if scanResult == nil {
                    scanView
                } else {
                    resultView
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
    }
}
