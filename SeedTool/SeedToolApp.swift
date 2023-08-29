//
//  SeedToolApp.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/4/20.
//

import SwiftUI
import UserNotifications
import CloudKit
import Combine
import WolfBase
import os
import BCApp

let needsFetchPublisher = PassthroughSubject<(UIBackgroundFetchResult) -> Void, Never>()

fileprivate let logger = Logger(subsystem: Application.bundleIdentifier, category: "Lifecycle")

let globalFormatContext = {
    addKnownFunctionExtensions()
    return FormatContext(tags: globalTags, knownValues: globalKnownValues, functions: globalFunctions, parameters: globalParameters)
}()

//
// To send an Open URL event from the command line:
// ```
// xcrun simctl openurl booted ur:crypto-seed/otadgdlfwfdwlphlfsghcphfcsaybekkkbaejkaosezofptplpayftemckpfaxihfpjziniaihttmhwnen
// ```

@main
struct SeedToolApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject private var model: Model
    @StateObject private var settings: Settings
    
    init() {
        let settings = Settings(storage: UserDefaults.standard)
        let model = Model(settings: settings)
        self._settings = StateObject(wrappedValue: settings)
        self._model = StateObject(wrappedValue: model)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tapToDismiss()
                .environmentObject(model)
                .environmentObject(settings)
                .onAppear {
                    disableHardwareKeyboards()
                }
                .onReceive(needsFetchPublisher) { completionHandler in
                    model.fetchChanges { result in
                        switch result {
                        case .success:
                            //logger.debug("✅ Fetched changes.")
                            completionHandler(.newData)
                        case .failure(let error):
                            logger.error("⛔️ Failed to fetch changes: \(error.localizedDescription).")
                            completionHandler(.failed)
                        }
                    }
                }
                .onOpenURL { url in
                    NavigationManager.send(url: url)
                }
        }
    }
}

/// Necessary for XCUI automation.
/// https://stackoverflow.com/a/57618331/2413963
func disableHardwareKeyboards() {
    #if targetEnvironment(simulator)
    let setHardwareLayout = NSSelectorFromString("setHardwareLayout:")
    UITextInputMode.activeInputModes
        // Filter `UIKeyboardInputMode`s.
        .filter({ $0.responds(to: setHardwareLayout) })
        .forEach { $0.perform(setHardwareLayout, with: nil) }
    #endif
}
