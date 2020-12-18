//
//  SecureRandomNumberGenerator.swift
//  Fehu
//
//  Created by Wolf McNally on 12/8/20.
//

import Foundation
import Security

public final class SecureRandomNumberGenerator: RandomNumberGenerator {
    public init() { }

    public static var shared = SecureRandomNumberGenerator()

    public func next() -> UInt64 {
        var result: UInt64 = 0
        precondition(SecRandomCopyBytes(kSecRandomDefault, MemoryLayout<UInt64>.size, &result) == errSecSuccess)
        return result
    }

    public func data(count: Int) -> Data {
        var s = self
        return Data((0..<count).map { _ in UInt8.random(in: 0...255, using: &s) })
    }
}

