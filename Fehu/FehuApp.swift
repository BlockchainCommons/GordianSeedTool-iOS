//
//  FehuApp.swift
//  Fehu
//
//  Created by Wolf McNally on 12/4/20.
//

import SwiftUI

@main
struct FehuApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(Model.load())
        }
    }
}
