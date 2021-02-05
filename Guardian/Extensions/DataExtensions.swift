//
//  DataExtensions.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/6/20.
//

import Foundation

extension Data {
    init?(hex: String) {
        let len = hex.count / 2
        var data = Data(capacity: len)
        for i in 0..<len {
            let j = hex.index(hex.startIndex, offsetBy: i*2)
            let k = hex.index(j, offsetBy: 2)
            let bytes = hex[j..<k]
            if var num = UInt8(bytes, radix: 16) {
                data.append(&num, count: 1)
            } else {
                return nil
            }
        }
        self = data
    }

    var hex: String {
        self.reduce("", { $0 + String(format: "%02x", $1) })
    }

    var utf8: String {
        String(data: self, encoding: .utf8)!
    }

    var bytes: [UInt8] {
        Array(self)
    }

    init<A>(of a: A) {
        let d = Swift.withUnsafeBytes(of: a) {
            Data($0)
        }
        self = d
    }
    
    func store<A>(into a: inout A) {
        precondition(MemoryLayout<A>.size >= count)
        withUnsafeMutablePointer(to: &a) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                self.copyBytes(to: $0, count: count)
            }
        }
    }
    
    var isAllZero: Bool {
        return allSatisfy { $0 == 0 }
    }
}

extension Data {
    @inlinable func withUnsafeByteBuffer<ResultType>(_ body: (UnsafeBufferPointer<UInt8>) throws -> ResultType) rethrows -> ResultType {
        try withUnsafeBytes { rawBuf in
            try body(rawBuf.bindMemory(to: UInt8.self))
        }
    }
}

@inlinable func withUnsafeByteBuffer<T, ResultType>(of value: T, _ body: (UnsafeBufferPointer<UInt8>) throws -> ResultType) rethrows -> ResultType {
    try withUnsafeBytes(of: value) { rawBuf in
        try body(rawBuf.bindMemory(to: UInt8.self))
    }
}

@inlinable func withUnsafeMutableByteBuffer<T, ResultType>(of value: inout T, _ body: (UnsafeMutableBufferPointer<UInt8>) throws -> ResultType) rethrows -> ResultType {
    try withUnsafeMutableBytes(of: &value) { rawBuf in
        try body(rawBuf.bindMemory(to: UInt8.self))
    }
}
