//
//  AuthenticationManager.swift
//  Gordian Seed Tool
//
//  Created by Authentication System
//

import SwiftUI
import Observation

@Observable
class AuthenticationManager {
    var isAuthenticated = false
    var isAuthenticationRequired = false
    var authenticationAttempts = 0
    private let maxAttempts = 5
    
    private let biometricManager = BiometricAuthManager()
    private let settings: Settings
    
    init(settings: Settings) {
        self.settings = settings
        updateAuthenticationRequirement()
    }
    
    func updateAuthenticationRequirement() {
        isAuthenticationRequired = settings.authenticationEnabled && 
                                 (settings.biometricAuthEnabled || settings.hasPINCode)
    }
    
    func authenticateWithBiometrics() async -> Bool {
        guard settings.biometricAuthEnabled && biometricManager.isBiometricAvailable else {
            return false
        }
        
        let result = await biometricManager.authenticateWithBiometrics()
        switch result {
        case .success(let success):
            if success {
                isAuthenticated = true
                authenticationAttempts = 0
            }
            return success
        case .failure:
            return false
        }
    }
    
    func authenticateWithPIN(_ pin: String) -> Bool {
        guard let storedPIN = KeychainHelper.shared.retrievePINCode() else {
            return false
        }
        
        if pin == storedPIN {
            isAuthenticated = true
            authenticationAttempts = 0
            return true
        } else {
            authenticationAttempts += 1
            return false
        }
    }
    
    func setupPIN(_ pin: String) -> Bool {
        let success = KeychainHelper.shared.storePINCode(pin)
        if success {
            settings.authenticationEnabled = true
        }
        return success
    }
    
    func removePIN() -> Bool {
        let success = KeychainHelper.shared.deletePINCode()
        if success && !settings.biometricAuthEnabled {
            settings.authenticationEnabled = false
        }
        return success
    }
    
    func logout() {
        isAuthenticated = false
        authenticationAttempts = 0
    }
    
    var isBiometricAvailable: Bool {
        biometricManager.isBiometricAvailable
    }
    
    var biometricDisplayName: String {
        biometricManager.biometricDisplayName
    }
    
    var isLockedOut: Bool {
        authenticationAttempts >= maxAttempts
    }
    
    var remainingAttempts: Int {
        max(0, maxAttempts - authenticationAttempts)
    }
} 