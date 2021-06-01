//
//  ChildIndexSpec.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/22/21.
//

import Foundation
import URKit

enum ChildIndexSpec {
    case index(ChildIndex)
    case indexRange(ChildIndexRange)
    case indexWildcard(ChildIndexWildcard)
    
    var cbor: CBOR {
        switch self {
        case .index(let index):
            return index.cbor
        case .indexRange(let indexRange):
            return indexRange.cbor
        case .indexWildcard(let indexWildcard):
            return indexWildcard.cbor
        }
    }
    
    static func decode(cbor: CBOR) throws -> ChildIndexSpec {
        if let a = try ChildIndex(cbor: cbor) {
            return .index(a)
        }
        if let a = try ChildIndexRange(cbor: cbor) {
            return .indexRange(a)
        }
        if let a = ChildIndexWildcard(cbor: cbor) {
            return .indexWildcard(a)
        }
        throw GeneralError("Invalid ChildIndexSpec.")
    }
}

extension ChildIndexSpec: CustomStringConvertible {
    var description: String {
        switch self {
        case .index(let index):
            return index.description
        case .indexRange(let indexRange):
            return indexRange.description
        case .indexWildcard(let indexWildcard):
            return indexWildcard.description
        }
    }
}
