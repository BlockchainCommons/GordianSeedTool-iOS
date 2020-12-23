//
//  Keychain.swift
//  Fehu
//
//  Created by Wolf McNally on 12/21/20.
//

import Foundation
import Security
import URKit

enum KeychainError: LocalizedError {
    case couldNotAdd(Int)
    case couldNotDelete(Int)
    case couldNotUpdate(Int)
    case couldNotRead(Int)
    case wrongType
    
    var errorDescription: String? {
        switch self {
        case .couldNotAdd(let code):
            return "Keychain: Could not add record \(code)."
        case .couldNotDelete(let code):
            return "Keychain: Could not delete record \(code)."
        case .couldNotUpdate(let code):
            return "Keychain: Could not update record \(code)."
        case .couldNotRead(let code):
            return "Keychain: Could not read record \(code)."
        case .wrongType:
            return "Keychain: Incorrect type."
        }
    }
}

struct Keychain {
    static let defaultAccount = "default"

    private static func composeQueryForSeed(id: UUID, additionalAttributes: [String: Any] = [:]) -> [String: Any] {
        return [
            String(kSecClass): kSecClassGenericPassword,
            String(kSecUseDataProtectionKeychain): true,

            // These attributes are the primary key of the record
            String(kSecAttrAccessGroup): "YZHG975W3A.com.blockchaincommons.shared-items",
            String(kSecAttrService): "ur:crypto-seed",
            String(kSecAttrAccount): id.uuidString,
            String(kSecAttrAccessible): kSecAttrAccessibleWhenUnlocked,
            
            // Don't sync to iCloud for now
            //String(kSecAttrSynchronizable): true,

        ].merging(additionalAttributes, uniquingKeysWith: { _, new in new })
    }

    static func add(seed: Seed) throws {
        let additionalAttributes: [String: Any] = [
            String(kSecAttrCreator): FourCharCode("Fehu"),
            String(kSecAttrModificationDate): Date(),
            String(kSecAttrLabel): seed.name,
            String(kSecValueData): Data(seed.urString.data(using: .utf8)!),
            String(kSecAttrComment): "This is a cryptographic seed managed by Blockchain Commons Fehu.",
        ]
        let query = composeQueryForSeed(id: seed.id, additionalAttributes: additionalAttributes)
        let result = SecItemAdd(query as NSDictionary, nil)
        guard result == errSecSuccess else {
            throw KeychainError.couldNotAdd(Int(result))
        }
    }

    static func delete(id: UUID) throws {
        let query = composeQueryForSeed(id: id)
        let result = SecItemDelete(query as NSDictionary)
        guard result == errSecSuccess else {
            throw KeychainError.couldNotDelete(Int(result))
        }
    }

    static func update(seed: Seed, addIfNotFound: Bool = true) throws {
        let updatedAttributes: [String: Any] = [
            String(kSecAttrModificationDate): Date(),
            String(kSecAttrLabel): seed.name,
            String(kSecValueData): Data(seed.urString.data(using: .utf8)!)
        ]

        let query = composeQueryForSeed(id: seed.id)

        let result = SecItemUpdate(query as NSDictionary, updatedAttributes as NSDictionary)
        if result == errSecItemNotFound && addIfNotFound {
            try add(seed: seed)
            return
        }

        guard result == errSecSuccess else {
            throw KeychainError.couldNotUpdate(Int(result))
        }
    }

    static func seed(for id: UUID) throws -> Seed {
        let additionalAttributes: [String: Any] = [
            String(kSecReturnData): true
        ]
        let query = composeQueryForSeed(id: id, additionalAttributes: additionalAttributes)

        var value: CFTypeRef?
        let result = SecItemCopyMatching(query as NSDictionary, &value)
        guard result == errSecSuccess else {
            throw KeychainError.couldNotRead(Int(result))
        }
        guard let data = value as? Data else {
            throw KeychainError.wrongType
        }
        guard let urString = String(data: data, encoding: .utf8) else {
            throw KeychainError.wrongType
        }
        return try Seed(id: id, urString: urString)
    }
}
