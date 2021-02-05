//
//  GuardianApp.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/4/20.
//

import SwiftUI

let settings = Settings(storage: UserDefaults.standard)

@main
struct GuardianApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .tapToDismiss()
                .environmentObject(Model.load())
                .environmentObject(settings)
        }
    }
}
