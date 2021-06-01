//
//  SeedToolApp.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/4/20.
//

import SwiftUI

let isTakingSnapshot = ProcessInfo.processInfo.arguments.contains("SNAPSHOT")
let settings = Settings(storage: UserDefaults.standard)
let model = Model.load()

@main
struct SeedToolApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tapToDismiss()
                .environmentObject(model)
                .environmentObject(settings)
                .onAppear {
                    disableHardwareKeyboards()
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
