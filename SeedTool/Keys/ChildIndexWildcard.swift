//
//  ChildIndexWildcard.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/22/21.
//

import Foundation
import URKit

//struct ChildIndexWildcard: Equatable {
//    init() { }
//    
//    var cbor: CBOR {
//        CBOR.array([])
//    }
//    
//    init?(cbor: CBOR) {
//        guard case let CBOR.array(array) = cbor else {
//            return nil
//        }
//        guard array.isEmpty else {
//            return nil
//        }
//        self.init()
//    }
//}
//
//extension ChildIndexWildcard: CustomStringConvertible {
//    var description: String {
//        "*"
//    }
//}
//
//extension ChildIndexWildcard {
//    static func parse(_ s: String) -> ChildIndexWildcard? {
//        guard s == "*" else {
//            return nil
//        }
//        return ChildIndexWildcard()
//    }
//}
