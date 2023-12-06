//
//  MainView.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/25/21.
//

import SwiftUI
import WolfBase
import os
import BCApp

fileprivate let logger = Logger(subsystem: Application.bundleIdentifier, category: "MainView")

struct MainView: View {
    @EnvironmentObject private var model: Model
    @EnvironmentObject private var settings: Settings

    @StateObject var undoStack = UndoStack()

    @State private var presentedSheet: Sheet?
    
    enum Sheet: Identifiable {
        case newSeed(ModelSeed)
        case request(TransactionRequest)
        case response
        case scan(URL?)
        
        var id: Int {
            switch self {
            case .newSeed:
                return 1
            case .request:
                return 2
            case .response:
                return 3
            case .scan:
                return 4
            }
        }
    }
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        NavigationView {
            SeedList(undoStack: undoStack)
            NoSeedSelected()
        }
        .copyConfirmation()
        .sheet(item: $presentedSheet) { item in
            let isSheetPresented = Binding<Bool>(
                get: { presentedSheet != nil },
                set: { if !$0 { presentedSheet = nil } }
            )
            switch item {
            case .newSeed(let seed):
                SetupNewSeed(seed: seed, isPresented: isSheetPresented) {
                    withAnimation {
                        model.insertSeed(seed, at: 0)
                    }
                }
                .environmentObject(model)
                .environmentObject(settings)
            case .request(let request):
                ApproveRequest(isPresented: isSheetPresented, request: request)
                    .environmentObject(model)
                    .environmentObject(settings)
            case .response:
                ResultScreen<Void, GeneralError>(isPresented: isSheetPresented, result: .failure(GeneralError("Seed Tool doesn't currently accept responses of any kind.")))
            case .scan(let url):
                Scan(isPresented: isSheetPresented, prompt: "Scan a QR code to import a seed or respond to a request from another device.", caption: "Acceptable types include `ur:envelope` (containing seed, SSKR share, or request), `ur:seed`, `ur:psbt`, or Base64-encoded PSBT.", initalURL: url, allowPSBT: true, onScanResult: processScanResult)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                HStack(spacing: 10) {
                    UserGuideButton<AppChapter>(openToChapter: nil)
                    ScanButton {
                        presentedSheet = .scan(nil)
                    }
                }
                
                Spacer()
                
                Image.bcLogo
                    .accessibility(hidden: true)
                
                Spacer()
                
                SettingsButton() {
                    undoStack.invalidate()
                }
                .accessibility(label: Text("Settings"))
                .environmentObject(model)
                .environmentObject(settings)
            }
        }
        .onNavigationEvent { event in
            // If the scan sheet is already presented, then ignore this event.
            switch presentedSheet {
            case .scan:
                break
            default:
                switch event {
                case .url(let url):
                    // Give any previous sheet a moment to dismiss before presenting the Scan sheet.
                    presentedSheet = nil
                    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { _ in
                        presentedSheet = .scan(url)
                    }
                }
            }
        }
        
        // FB8936045: StackNavigationViewStyle prevents new list from entering Edit mode correctly
        // https://developer.apple.com/forums/thread/656386?answerId=651882022#651882022
        //.navigationViewStyle(StackNavigationViewStyle())
    }
    
    func processScanResult(scanResult: ScanResult) {
        switch scanResult {
        case .seed(let newSeed):
            presentedSheet = .newSeed(ModelSeed(newSeed))
        case .request(let request):
            presentedSheet = .request(request)
        case .response:
            presentedSheet = .response
        case .failure(let error):
            logger.error("⛔️ scan failure: \(error.localizedDescription)")
        }
    }
}

#if DEBUG

import WolfLorem

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(Lorem.model())
            .environmentObject(Settings(storage: MockSettingsStorage()))
            .darkMode()
    }
}

#endif
