//
//  GuardianApp.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/4/20.
//

import SwiftUI

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
        }
    }
}
