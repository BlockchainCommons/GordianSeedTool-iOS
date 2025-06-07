//
//  AuthenticationView.swift
//  Gordian Seed Tool
//
//  Created by Authentication System
//

import SwiftUI

struct AuthenticationView: View {
    @Environment(Settings.self) private var settings
    let authManager: AuthenticationManager
    @State private var pin = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showPINSetup = false
    @State private var authenticationInProgress = false
    
    init(authManager: AuthenticationManager) {
        self.authManager = authManager
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // App Icon and Title
            VStack(spacing: 20) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Gordian Seed Tool")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Authentication Required")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 25) {
                // Biometric Authentication Button
                if settings.biometricAuthEnabled && authManager.isBiometricAvailable {
                    Button {
                        Task {
                            await authenticateWithBiometrics()
                        }
                    } label: {
                        HStack {
                            Image(systemName: biometricIcon)
                                .font(.title2)
                            Text("Unlock with \(authManager.biometricDisplayName)")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(authenticationInProgress || authManager.isLockedOut)
                }
                
                // PIN Authentication
                if settings.hasPINCode {
                    VStack(spacing: 15) {
                        PINInputView(
                            pin: $pin,
                            isSecure: true,
                            placeholder: "Enter PIN"
                        )
                        
                        Button(action: authenticateWithPIN) {
                            Text("Unlock")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(pin.count >= 4 ? Color.green : Color.gray)
                                .cornerRadius(12)
                        }
                        .disabled(pin.count < 4 || authenticationInProgress || authManager.isLockedOut)
                    }
                }
                
                // Setup PIN Button (if no authentication is set up)
                if !settings.biometricAuthEnabled && !settings.hasPINCode {
                    VStack(spacing: 15) {
                        Text("No authentication method is set up")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Set Up PIN Code") {
                            showPINSetup = true
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                }
                
                // Error Message
                if showError {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Lockout Message
                if authManager.isLockedOut {
                    VStack(spacing: 5) {
                        Text("Too many failed attempts")
                            .foregroundColor(.red)
                            .font(.headline)
                        Text("Please restart the app to try again")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .multilineTextAlignment(.center)
                } else if authManager.authenticationAttempts > 0 {
                    Text("\(authManager.remainingAttempts) attempts remaining")
                        .foregroundColor(.orange)
                        .font(.caption)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .sheet(isPresented: $showPINSetup) {
            PINSetupView(authManager: authManager) {
                authManager.updateAuthenticationRequirement()
            }
        }
        .onAppear {
            // Auto-trigger biometric authentication if available and enabled
            if settings.biometricAuthEnabled && authManager.isBiometricAvailable {
                Task {
                    await authenticateWithBiometrics()
                }
            }
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
    
    private func authenticateWithBiometrics() async {
        guard !authenticationInProgress else { return }
        
        authenticationInProgress = true
        showError = false
        
        let success = await authManager.authenticateWithBiometrics()
        
        authenticationInProgress = false
        
        if !success && !authManager.isAuthenticated {
            showError(message: "Biometric authentication failed. Please try again or use your PIN.")
        }
    }
    
    private func authenticateWithPIN() {
        guard !authenticationInProgress else { return }
        
        authenticationInProgress = true
        showError = false
        
        let success = authManager.authenticateWithPIN(pin)
        
        authenticationInProgress = false
        
        if success {
            pin = ""
        } else {
            pin = ""
            if authManager.isLockedOut {
                showError(message: "Too many failed attempts. Please restart the app.")
            } else {
                showError(message: "Incorrect PIN. \(authManager.remainingAttempts) attempts remaining.")
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
        
        // Hide error after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showError = false
        }
    }
} 