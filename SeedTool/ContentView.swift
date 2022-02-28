//
//  ContentView.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/4/20.
//

import SwiftUI
import os
import WolfBase

fileprivate let logger = Logger(subsystem: bundleIdentifier, category: "ContentView")

struct ContentView: View {
    @State private var isLicensePresented = false
    @EnvironmentObject private var settings: Settings

    var body: some View {
        Group {
            if isLicensePresented {
                license
            } else {
                MainView()
            }
        }
        .onAppear {
            // To reshow the license, uncomment this line
//            settings.isLicenseAccepted = false
            
            if !settings.isLicenseAccepted {
                isLicensePresented = true
            }
        }
        .accentColor(.green)
        .symbolRenderingMode(.hierarchical)
    }
    
    var license: some View {
        VStack(spacing: 0) {
            UserGuidePage(chapter: .licenseAndDisclaimer)
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
