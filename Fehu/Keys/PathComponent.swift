//
//  PathComponent.swift
//  Guardian
//
//  Created by Wolf McNally on 1/22/21.
//

import Foundation
import URKit

struct PathComponent {
    let childIndexSpec: ChildIndexSpec
    let isHardened: Bool
    
    var array: [CBOR] {
        [childIndexSpec.cbor, CBOR.boolean(isHardened)]
    }
    
    func childNum() throws -> UInt32 {
        guard case let ChildIndexSpec.index(childIndex) = childIndexSpec else {
            throw GeneralError("Inspecific child number in derivation path.")
        }
        return isHardened ? childIndex.value | 0x80000000 : childIndex.value
    }
}
