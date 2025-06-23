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
// xcrun simctl openurl booted ur:seed/otadgdlfwfdwlphlfsghcphfcsaybekkkbaejkaosezofptplpayftemckpfaxihfpjziniaihttmhwnen
// ```

/// The global settings object.
///
/// Only use `globalSettings` if you must. Prefer:
///
///     @Environment(Settings.self) private var settings
///
let globalSettings = {
    Settings(storage: UserDefaults.standard)
}()

@main
struct SeedToolApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @State private var model: Model
    @State private var settings: Settings
    @State private var authManager: AuthenticationManager
    
    init() {
        let settings = globalSettings
        let model = Model(settings: settings)
        let authManager = AuthenticationManager(settings: settings)
        self.settings = settings
        self.model = model
        self.authManager = authManager
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tapToDismiss()
                .environment(model)
                .environment(settings)
                .environment(authManager)
                .onAppear {
                    disableHardwareKeyboards()
                }
                .onReceive(needsFetchPublisher) { _ in
                    Task {
                        do {
                            try await model.fetchChanges()
                        } catch {
                            logger.error("⛔️ Failed to fetch changes: \(error.localizedDescription).")
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
