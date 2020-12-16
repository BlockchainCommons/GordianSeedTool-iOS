//
//  SecureRandomNumberGenerator.swift
//  Fehu
//
//  Created by Wolf McNally on 12/8/20.
//

import Foundation
import Security

public var secureRandomNumberGenerator = SecureRandomNumberGenerator()

public final class SecureRandomNumberGenerator: RandomNumberGenerator {
    public init() { }

    public func next() -> UInt64 {
        var result: UInt64 = 0
        precondition(SecRandomCopyBytes(kSecRandomDefault, MemoryLayout<UInt64>.size, &result) == errSecSuccess)
        return result
    }
}
