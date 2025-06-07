//
//  KeychainHelper.swift
//  Gordian Seed Tool
//
//  Created by Authentication System
//

import Foundation
import Security

class KeychainHelper {
    static let shared = KeychainHelper()
    private let pinCodeKey = "user_pin_code"
    
    private init() {}
    
    func storePINCode(_ pin: String) -> Bool {
        guard let data = pin.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: pinCodeKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        // Delete any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    func retrievePINCode() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: pinCodeKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let pin = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return pin
    }
    
    func deletePINCode() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: pinCodeKey
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
    
    func hasPINCode() -> Bool {
        return retrievePINCode() != nil
    }
} 