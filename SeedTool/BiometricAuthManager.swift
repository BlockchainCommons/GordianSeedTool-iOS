//
//  BiometricAuthManager.swift
//  Gordian Seed Tool
//
//  Created by Authentication System
//

import Foundation
import LocalAuthentication
import SwiftUI

@Observable
class BiometricAuthManager {
    enum BiometricType {
        case none
        case touchID
        case faceID
        case opticID
    }
    
    enum AuthenticationError: LocalizedError {
        case biometricNotAvailable
        case biometricNotEnrolled
        case authenticationFailed
        case userCancel
        case userFallback
        case systemCancel
        case passcodeNotSet
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .biometricNotAvailable:
                return "Biometric authentication is not available on this device."
            case .biometricNotEnrolled:
                return "No biometric data is enrolled. Please set up Face ID or Touch ID in Settings."
            case .authenticationFailed:
                return "Authentication failed. Please try again."
            case .userCancel:
                return "Authentication was cancelled by user."
            case .userFallback:
                return "User selected fallback authentication method."
            case .systemCancel:
                return "Authentication was cancelled by system."
            case .passcodeNotSet:
                return "Device passcode is not set. Please set up a passcode in Settings."
            case .unknown:
                return "An unknown error occurred during authentication."
            }
        }
    }
    
    var biometricType: BiometricType {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }
        
        switch context.biometryType {
        case .touchID:
            return .touchID
        case .faceID:
            return .faceID
        case .opticID:
            return .opticID
        default:
            return .none
        }
    }
    
    var isBiometricAvailable: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    var biometricDisplayName: String {
        switch biometricType {
        case .touchID:
            return "Touch ID"
        case .faceID:
            return "Face ID"
        case .opticID:
            return "Optic ID"
        case .none:
            return "Biometric"
        }
    }
    
    func authenticateWithBiometrics() async -> Result<Bool, AuthenticationError> {
        let context = LAContext()
        var error: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let error = error {
                switch error.code {
                case LAError.biometryNotAvailable.rawValue:
                    return .failure(.biometricNotAvailable)
                case LAError.biometryNotEnrolled.rawValue:
                    return .failure(.biometricNotEnrolled)
                case LAError.passcodeNotSet.rawValue:
                    return .failure(.passcodeNotSet)
                default:
                    return .failure(.unknown)
                }
            }
            return .failure(.biometricNotAvailable)
        }
        
        do {
            let reason = "Authenticate to access your secure data"
            let success = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            return .success(success)
        } catch {
            let laError = error as! LAError
            switch laError.code {
            case .authenticationFailed:
                return .failure(.authenticationFailed)
            case .userCancel:
                return .failure(.userCancel)
            case .userFallback:
                return .failure(.userFallback)
            case .systemCancel:
                return .failure(.systemCancel)
            case .biometryNotAvailable:
                return .failure(.biometricNotAvailable)
            case .biometryNotEnrolled:
                return .failure(.biometricNotEnrolled)
            case .passcodeNotSet:
                return .failure(.passcodeNotSet)
            default:
                return .failure(.unknown)
            }
        }
    }
} 