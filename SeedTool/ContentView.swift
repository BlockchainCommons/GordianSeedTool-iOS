//
//  ContentView.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/4/20.
//

import SwiftUI
import os
import WolfBase
import BCApp

fileprivate let logger = Logger(subsystem: Application.bundleIdentifier, category: "ContentView")

struct ContentView: View {
    @State private var isLicensePresented = false
    @State private var authManager: AuthenticationManager?
    @Environment(Settings.self) private var settings
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if isLicensePresented {
                license
            } else if let authManager = authManager, 
                      authManager.isAuthenticationRequired && !authManager.isAuthenticated {
                AuthenticationView(authManager: authManager)
            } else {
                MainView()
            }
        }
        .onAppear {
            // To reshow the license, uncomment this line
//            settings.isLicenseAccepted = false
            
            // Initialize authentication manager
            if authManager == nil {
                authManager = AuthenticationManager(settings: settings)
            }
            
            if !settings.isLicenseAccepted {
                isLicensePresented = true
            }
            //printTestPSBTSigningRequests()
        }
        .onChange(of: scenePhase) { _, newPhase in
            // Lock the app when it goes to background
            if newPhase == .background || newPhase == .inactive {
                authManager?.logout()
            }
        }
        .accentColor(.green)
        .symbolRenderingMode(.hierarchical)
    }
    
    var license: some View {
        VStack(spacing: 0) {
            UserGuidePage<AppChapter>(chapter: .licenseAndDisclaimer)
                .frame(maxWidth: 600, maxHeight: 600)
            Button {
                settings.isLicenseAccepted = true
                withAnimation {
                    self.isLicensePresented = false
                }
            } label: {
                Text("I Accept")
                    .bold()
                    .formSectionStyle()
                    .padding()
            }
        }
        .formSectionStyle()
        .padding()
    }
}
