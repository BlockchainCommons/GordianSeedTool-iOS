//
//  Scan.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/18/21.
//

import SwiftUI
import WolfSwiftUI
import URUI
import PhotosUI
import UniformTypeIdentifiers
import BCFoundation
import AVFoundation
import SwiftUIFlowLayout
import NFC
import WolfBase
import os
import BCApp

fileprivate let logger = Logger(subsystem: Application.bundleIdentifier, category: "Scan")

struct Scan: View {
    @Binding var isPresented: Bool
    let initialURL: URL?
    let onScanResult: (ScanResult) -> Void
    
    let codesPublisher: URCodesPublisher

    @StateObject private var videoSession: URVideoSession
    @StateObject private var scanState: URScanState
    @StateObject private var sskrDecoder: SSKRDecoder
    @StateObject private var model: ScanModel
    @StateObject private var nfcReader = NFCReader()

    @State private var presentedSheet: Sheet?
    @State private var scanResult: ScanResult? = nil
    @State private var estimatedPercentComplete = 0.0
    @State private var cameraAuthorizationStatus: AVAuthorizationStatus = .notDetermined
    @State private var captureDevices: [AVCaptureDevice] = []
    @State private var currentCaptureDevice: AVCaptureDevice? = nil
    
    enum Sheet: Int, Identifiable {
        case files
        case photos

        var id: Int { rawValue }
    }

    init(isPresented: Binding<Bool>, initalURL: URL? = nil, onScanResult: @escaping (ScanResult) -> Void) {
        self._isPresented = isPresented
        self.initialURL = initalURL
        self.onScanResult = onScanResult
        let sskrDecoder = SSKRDecoder {
            Feedback.progress()
        }
        let codesPublisher = URCodesPublisher()
        self.codesPublisher = codesPublisher
        self._videoSession = StateObject(wrappedValue: URVideoSession(codesPublisher: codesPublisher))
        self._scanState = StateObject(wrappedValue: URScanState(codesPublisher: codesPublisher))
        self._sskrDecoder = StateObject(wrappedValue: sskrDecoder)
        self._model = StateObject(wrappedValue: ScanModel(sskrDecoder: sskrDecoder))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .center) {
                Text("Scan")
                    .font(.largeTitle).bold()
                Spacer()
                DoneButton($isPresented)
                .keyboardShortcut(.cancelAction)
            }
            if scanResult == nil {
                scanView
            } else {
                resultView
            }
        }
        .onReceive(nfcReader.tagPublisher) { tag in
            Task {
                do {
                    let uri = try await nfcReader.readURI(tag)
                    // Allow a little time for the NFC reader interface to play its sound.
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                        self.receiveURL(uri)
                    }

                    nfcReader.invalidate()
                } catch {
                    logger.error("⛔️ \(error.localizedDescription)")
                    nfcReader.invalidate(errorMessage: error.localizedDescription)
                }
            }
        }
        .onReceive(videoSession.$captureDevices) { devices in
            self.captureDevices = devices
        }
        .onReceive(videoSession.$currentCaptureDevice) { device in
            self.currentCaptureDevice = device
        }
        .onChange(of: currentCaptureDevice) { device in
            guard let device = device else {
                return
            }
            self.videoSession.setCaptureDevice(device)
        }
        .padding()
        .sheet(item: $presentedSheet) { item -> AnyView in
            let isSheetPresented = Binding<Bool>(
                get: { presentedSheet != nil },
                set: { if !$0 { presentedSheet = nil } }
            )
            switch item {
            case .photos:
                var configuration = PHPickerConfiguration()
                configuration.filter = .images
                configuration.selectionLimit = 0
                configuration.preferredAssetRepresentationMode = .compatible
                return PhotoPicker(isPresented: isSheetPresented, configuration: configuration, completion: processLoadedImages)
                    .eraseToAnyView()
            case .files:
                var configuration = DocumentPickerConfiguration()
                configuration.documentTypes = [.item]
                configuration.asCopy = true
                configuration.allowsMultipleSelection = true
                return DocumentPicker(isPresented: isSheetPresented, configuration: configuration) { urls in
                    var imageURLs: [URL] = []
                    var psbtURLs: [URL] = []
                    var otherURLs: [URL] = []
                    
                    for url in urls {
                        if url.isImage {
                            imageURLs.append(url)
                        } else if url.isPSBT {
                            psbtURLs.append(url)
                        } else {
                            otherURLs.append(url)
                        }
                    }
                    
                    if let psbtURL = psbtURLs.first {
                        processPSBTFile(psbtURL)
                    } else if !imageURLs.isEmpty {
                        processLoadedImages(imageURLs)
                    } else {
                        processOtherFiles(otherURLs)
                    }
                }
                .eraseToAnyView()
            }
        }
        .onAppear {
            if let initialURL = initialURL {
                receiveURL(initialURL)
            }
        }
        .onDisappear {
            if let scanResult = scanResult {
                onScanResult(scanResult)
            }
        }
        .onNavigationEvent { event in
            switch event {
            case .url(let url):
                receiveURL(url)
            }
        }
        .font(.body)
    }
    
    @MainActor
    func receiveURL(_ url: URL) {
        model.receive(urString: url.absoluteString)
    }
    
    func processPSBTFile(_ url: URL) {
        do {
            var data = try Data(contentsOf: url)
            
            if let dataAsString = String(data: data, encoding: .utf8)?.trim(),
               let decodedBase64 = Data(base64: dataAsString)
            {
                data = decodedBase64
            }
            
            guard let psbt = PSBT(data) else {
                throw GeneralError("Invalid PSBT format.")
            }
            let request = TransactionRequest(body: .psbtSignature(.init(psbt: psbt, isRawPSBT: true)))
            model.receive(ur: request.ur)
        } catch {
            failure(error)
        }
    }
    
    func processLoadedImages<T>(_ imageLoaders: [T]) where T: ImageLoader {
        extractQRCodes(from: imageLoaders) { messages in
            var remaining = messages.makeIterator()
            
            processNext()
            
            func processNext() {
                guard scanResult == nil, let message = remaining.next() else {
                    return
                }
                DispatchQueue.main.async {
                    model.receive(urString: message)
                    processNext()
                }
            }
        }
    }
    
    func processOtherFiles(_ urls: [URL]) {
        do {
            for url in urls {
                guard scanResult == nil else {
                    return
                }
                
                let data = try Data(contentsOf: url)

                guard let dataAsString = String(data: data, encoding: .utf8)?.trim() else {
                    throw GeneralError("Invalid UTF-8 string.")
                }
                
                try processImportString(dataAsString)
            }
        } catch {
            failure(error)
        }
    }
    
    func processImportString(_ string: String) throws {
        let lines = string.split(separator: "\n").map {
            String($0).trim()
        }
        
        var success = false
        for line in lines {
            guard scanResult == nil else {
                return
            }

            if let ur = processImportLine(line) {
                model.receive(ur: ur)
                success = true
            }
        }
        
        guard success else {
            throw GeneralError("Unknown file format.")
        }
    }
    
    func processImportLine(_ line: String) -> UR? {
        if
            let decodedBase64 = Data(base64: line),
            let psbt = PSBT(decodedBase64)
        {
            return TransactionRequest(body: .psbtSignature(.init(psbt: psbt, isRawPSBT: true))).ur
        } else {
            do {
                return try URDecoder.decode(line)
            } catch {
                // Ignore non-UR lines
            }
        }
        return nil
    }
    
    var resultView: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
            
            switch scanResult! {
            case .failure(let error):
                VStack{
                    Image.operation(success: false)
                        .resizable()
                        .foregroundColor(.red)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                    Text(error.localizedDescription)
                }
            default:
                Image.operation(success: true)
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
                        icon: { Image.sskr }
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
                .foregroundColor(.white)
                .padding()
                .background(Color.black.opacity(0.5))
                .cornerRadius(10)
            }
        }
    }
    
    func videoPlaceholder(_ message: Text? = nil) -> some View {
        HStack {
            Spacer()
            ZStack {
                Rectangle()
                    .fill(Color.secondary)
                    .opacity(0.2)
                if let message = message {
                    Caution(message)
                        .padding()
                }
            }
            .aspectRatio(1, contentMode: .fill)
            .frame(maxWidth: 600)
            Spacer()
        }
    }
    
    func videoView() -> some View {
        HStack {
            Spacer()
            ZStack {
                Rectangle()
                    .fill(Color.secondary)
                    .opacity(0.2)
                URVideo(videoSession: videoSession)
            }
            .aspectRatio(1, contentMode: .fill)
            #if targetEnvironment(macCatalyst)
            .frame(maxWidth: 300)
            #endif
            Spacer()
        }
    }
    
    var scanView: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Text("Scan a QR code to import a seed or respond to a request from another device.")
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    CameraSelector(cameras: $captureDevices, selectedCamera: $currentCaptureDevice)
                }
                ZStack {
                    #if targetEnvironment(simulator)
                    videoPlaceholder(Text("The camera is not available in the simulator."))
                    #else
                    switch cameraAuthorizationStatus {
                    case .notDetermined:
                        videoPlaceholder()
                    case .restricted:
                        videoPlaceholder(Text("Permission to use the camera is restricted on this device."))
                    case .denied:
                        videoPlaceholder(Text("The settings for this app deny use of the camera. You can change this in the **Settings** app by visiting **Privacy** > **Camera** > **Seed Tool**."))
                    case .authorized:
                        videoView()
                    @unknown default:
                        videoPlaceholder(Text("Unknown camera authorization status."))
                    }
                    #endif
                    sskrStatusView
                }
                URProgressBar(value: $estimatedPercentComplete)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Paste a textual UR from the clipboard, or choose one or more images containing UR QR codes.")
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)

                    FlowLayout(mode: .scrollable, items: [
                        pasteButton.eraseToAnyView(),
                        filesButton.eraseToAnyView(),
                        photosButton.eraseToAnyView(),
                        nfcButton.eraseToAnyView(),
                    ]) { $0 }
                    .frame(maxWidth: .infinity)

                    Text("Acceptable types include ur:crypto-seed, ur:crypto-request, ur:crypto-sskr, ur:crypto-psbt, or Base64-encoded PSBT.")
                        .font(.caption)
                }
            }
        }
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
                failure(GeneralError("Unrecognized format."))
            case .progress(let p):
                Feedback.progress()
                estimatedPercentComplete = p.estimatedPercentComplete
            case .reject:
                Feedback.error()
            case .failure(let error):
                failure(error)
            }
        }
        .task {
            #if !targetEnvironment(simulator)
            _ = await AVCaptureDevice.requestAccess(for: .video)
            cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            #endif
        }
    }
    
    var pasteButton: some View {
        ExportDataButton("Paste", icon: Image.paste, isSensitive: false) {
            do {
                if let string = UIPasteboard.general.string?.trim() {
                    if let data = Data(base64: string) {
                        guard let psbt = PSBT(data) else {
                            throw GeneralError("Invalid PSBT format.")
                        }
                        let request = TransactionRequest(body: .psbtSignature(.init(psbt: psbt)))
                        model.receive(ur: request.ur)
                    } else {
                        try processImportString(string)
                    }
                } else {
                    failure(GeneralError("The clipboard does not contain a valid ur:crypto-seed, ur:crypto-request, ur:crypto-sskr, ur:crypto-psbt, or Base64-encoded PSBT."))
                }
            } catch {
                failure(error)
            }
        }
    }
    
    func failure(_ error: Error) {
        Feedback.error()
        scanResult = .failure(error)
    }
    
    var filesButton: some View {
        ExportDataButton("Files", icon: Image.files, isSensitive: false) {
            presentedSheet = .files
        }
    }
    
    var photosButton: some View {
        ExportDataButton("Photos", icon: Image.photos, isSensitive: false) {
            presentedSheet = .photos
        }
    }
    
    var nfcButton: some View {
        ExportDataButton("NFC Tag", icon: Image.nfc, isSensitive: false) {
            Task {
                do {
                    try await nfcReader.beginSession(alertMessage: "Read a tag containing a UR.")
                } catch {
                    logger.error("⛔️ \(error.localizedDescription)")
                }
            }
        }
        .disabled(!NFCReader.isReadingAvailable)
    }
}

#if DEBUG

struct Scan_Previews: PreviewProvider {
    static var previews: some View {
        Scan(isPresented: .constant(true)) { scanResult in
        }
.previewInterfaceOrientation(.portraitUpsideDown)
    }
}
#endif
