//
//  ChildIndexWildcard.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/22/21.
//

import Foundation
import URKit

struct ChildIndexWildcard {
    init() { }
    
    var cbor: CBOR {
        CBOR.array([])
    }
    
    init?(cbor: CBOR) {
        guard case let CBOR.array(array) = cbor else {
            return nil
        }
        guard array.isEmpty else {
            return nil
        }
        self.init()
    }
}

extension ChildIndexWildcard: CustomStringConvertible {
    var description: String {
        "*"
    }
}
