//
//  GuardianApp.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/4/20.
//

import SwiftUI

let isTakingSnapshot = ProcessInfo.processInfo.arguments.contains("SNAPSHOT")
let settings = Settings(storage: UserDefaults.standard)
let model = Model.load()

@main
struct GuardianApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tapToDismiss()
                .environmentObject(model)
                .environmentObject(settings)
                .onAppear {
                    #if targetEnvironment(simulator)
                    // Disable hardware keyboards. Necessary for XCUI automation.
                    let setHardwareLayout = NSSelectorFromString("setHardwareLayout:")
                    UITextInputMode.activeInputModes
                        // Filter `UIKeyboardInputMode`s.
                        .filter({ $0.responds(to: setHardwareLayout) })
                        .forEach { $0.perform(setHardwareLayout, with: nil) }
                    #endif
                }
        }
    }
}
