//
//  ChildIndexSpec.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/22/21.
//

import Foundation
import BCFoundation

extension ChildIndexSpec {
//enum ChildIndexSpec: Equatable {
//    case index(ChildIndex)
//    case indexRange(ChildIndexRange)
//    case indexWildcard(ChildIndexWildcard)
    
    var cbor: CBOR {
        switch self {
        case .index(let index):
            return index.cbor
        case .indexRange(let indexRange):
            return indexRange.cbor
        case .indexWildcard:
            return CBOR.array([])
        }
    }
    
    static func decode(cbor: CBOR) throws -> ChildIndexSpec {
        if let a = try ChildIndex(cbor: cbor) {
            return .index(a)
        }
        if let a = ChildIndexRange(cbor: cbor) {
            return .indexRange(a)
        }
        if parseWildcard(cbor: cbor) {
            return .indexWildcard
        }
        throw GeneralError("Invalid ChildIndexSpec.")
    }
    
    private static func parseWildcard(cbor: CBOR) -> Bool {
        guard case let CBOR.array(array) = cbor else {
            return false
        }
        guard array.isEmpty else {
            return false
        }
        return true
    }

    
//    var isFixed: Bool {
//        switch self {
//        case .index:
//            return true
//        default:
//            return false
//        }
//    }
}

//extension ChildIndexSpec: CustomStringConvertible {
//    var description: String {
//        switch self {
//        case .index(let index):
//            return index.description
//        case .indexRange(let indexRange):
//            return indexRange.description
//        case .indexWildcard(let indexWildcard):
//            return indexWildcard.description
//        }
//    }
//}
//
//extension ChildIndexSpec {
//    static func parse(_ s: String) -> ChildIndexSpec? {
//        if let wildcard = ChildIndexWildcard.parse(s) {
//            return .indexWildcard(wildcard)
//        } else if let range = ChildIndexRange.parse(s) {
//            return .indexRange(range)
//        } else if let index = ChildIndex.parse(s) {
//            return .index(index)
//        } else {
//            return nil
//        }
//    }
//}
