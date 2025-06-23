//
//  PINSetupView.swift
//  Gordian Seed Tool
//
//  Created by Authentication System
//

import SwiftUI

struct PINSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pin = ""
    @State private var confirmPin = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var step: SetupStep = .enterPIN
    
    let authManager: AuthenticationManager
    let onComplete: () -> Void
    
    enum SetupStep {
        case enterPIN
        case confirmPIN
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Set Up PIN Code")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(step == .enterPIN ? "Enter a 4-6 digit PIN" : "Confirm your PIN")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 20) {
                    PINInputView(
                        pin: step == .enterPIN ? $pin : $confirmPin,
                        isSecure: true,
                        placeholder: step == .enterPIN ? "Enter PIN" : "Confirm PIN"
                    )
                    
                    if showError {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                VStack(spacing: 15) {
                    Button(action: handleContinue) {
                        Text(step == .enterPIN ? "Continue" : "Set PIN")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValidPIN ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!isValidPIN)
                    
                    if step == .confirmPIN {
                        Button("Back") {
                            step = .enterPIN
                            confirmPin = ""
                            showError = false
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var isValidPIN: Bool {
        let currentPin = step == .enterPIN ? pin : confirmPin
        return currentPin.count >= 4 && currentPin.count <= 6 && currentPin.allSatisfy(\.isNumber)
    }
    
    private func handleContinue() {
        showError = false
        
        switch step {
        case .enterPIN:
            if pin.count < 4 || pin.count > 6 {
                showError(message: "PIN must be 4-6 digits")
                return
            }
            step = .confirmPIN
            
        case .confirmPIN:
            if confirmPin != pin {
                showError(message: "PINs don't match")
                return
            }
            
            if authManager.setupPIN(pin) {
                onComplete()
                dismiss()
            } else {
                showError(message: "Failed to save PIN. Please try again.")
            }
        }
    }
    
    private func showError(message: String) {
        errorMessage = message
        showError = true
    }
}

struct PINInputView: View {
    @Binding var pin: String
    let isSecure: Bool
    let placeholder: String
    
    var body: some View {
        VStack {
            if isSecure {
                SecureField(placeholder, text: $pin)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title2)
                    .multilineTextAlignment(.center)
            } else {
                TextField(placeholder, text: $pin)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.title2)
                    .multilineTextAlignment(.center)
            }
            
            // PIN dots visualization
            HStack(spacing: 10) {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(index < pin.count ? Color.blue : Color.gray.opacity(0.3))
                        .frame(width: 12, height: 12)
                }
            }
            .padding(.top, 5)
        }
    }
}

#Preview {
    PINSetupView(
        authManager: AuthenticationManager(settings: Settings(storage: MockSettingsStorage())),
        onComplete: {}
    )
} 