//
//  AuthenticationSettingsView.swift
//  Gordian Seed Tool
//
//  Created by Authentication System
//

import SwiftUI

struct AuthenticationSettingsView: View {
    @Environment(Settings.self) private var settings
    @State private var authManager: AuthenticationManager
    @State private var showPINSetup = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    init(settings: Settings) {
        self._authManager = State(initialValue: AuthenticationManager(settings: settings))
    }
    
    var body: some View {
        List {
            Section {
                Toggle("Enable Authentication", isOn: Binding(
                    get: { settings.authenticationEnabled },
                    set: { newValue in
                        if !newValue {
                            // Disable all authentication
                            settings.authenticationEnabled = false
                            settings.biometricAuthEnabled = false
                            _ = authManager.removePIN()
                        } else {
                            settings.authenticationEnabled = true
                        }
                        authManager.updateAuthenticationRequirement()
                    }
                ))
            } header: {
                Text("Security")
            } footer: {
                Text("When enabled, you'll need to authenticate each time you open the app.")
            }
            
            if settings.authenticationEnabled {
                Section("Authentication Methods") {
                    // Biometric Authentication
                    if authManager.isBiometricAvailable {
                        HStack {
                            Image(systemName: biometricIcon)
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(authManager.biometricDisplayName)
                                    .font(.body)
                                Text("Use \(authManager.biometricDisplayName.lowercased()) to unlock")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Toggle("", isOn: Binding(
                                get: { settings.biometricAuthEnabled },
                                set: { settings.biometricAuthEnabled = $0 }
                            )).labelsHidden()
                        }
                    } else {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Biometric Authentication")
                                    .font(.body)
                                Text("Not available on this device")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // PIN Code
                    HStack {
                        Image(systemName: "number.square")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("PIN Code")
                                .font(.body)
                            Text(settings.hasPINCode ? "PIN is set up" : "No PIN set up")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        if settings.hasPINCode {
                            Button("Change") {
                                showPINSetup = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        } else {
                            Button("Set Up") {
                                showPINSetup = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                    }
                    
                    if settings.hasPINCode {
                        Button("Remove PIN") {
                            showRemovePINAlert()
                        }
                        .foregroundColor(.red)
                    }
                }
                
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Authentication Status")
                        Spacer()
                        Text(authenticationStatusText)
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
        }
        .navigationTitle("Authentication")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPINSetup) {
            PINSetupView(authManager: authManager) {
                authManager.updateAuthenticationRequirement()
            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            if alertTitle == "Remove PIN" {
                Button("Remove", role: .destructive) {
                    removePIN()
                }
                Button("Cancel", role: .cancel) { }
            } else {
                Button("OK") { }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private var biometricIcon: String {
        switch authManager.biometricDisplayName {
        case "Face ID":
            return "faceid"
        case "Touch ID":
            return "touchid"
        case "Optic ID":
            return "opticid"
        default:
            return "person.badge.key"
        }
    }
    
    private var authenticationStatusText: String {
        if settings.biometricAuthEnabled && settings.hasPINCode {
            return "Both enabled"
        } else if settings.biometricAuthEnabled {
            return "Biometric only"
        } else if settings.hasPINCode {
            return "PIN only"
        } else {
            return "None configured"
        }
    }
    
    private func showRemovePINAlert() {
        alertTitle = "Remove PIN"
        alertMessage = "Are you sure you want to remove your PIN? This will disable PIN authentication."
        showAlert = true
    }
    
    private func removePIN() {
        if authManager.removePIN() {
            alertTitle = "Success"
            alertMessage = "PIN has been removed successfully."
        } else {
            alertTitle = "Error"
            alertMessage = "Failed to remove PIN. Please try again."
        }
        authManager.updateAuthenticationRequirement()
        showAlert = true
    }
} 
