//
//  DerivationStep.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/22/21.
//

import Foundation
import URKit
import LibWally

struct DerivationStep : Equatable {
    let childIndexSpec: ChildIndexSpec
    let isHardened: Bool
    
    var wallyDerivationStep: LibWally.DerivationStep {
        switch childIndexSpec {
        case .index(let childIndex):
            return LibWally.DerivationStep(.childNum(childIndex.value), isHardened: isHardened)!
        case .indexWildcard:
            return LibWally.DerivationStep(.wildcard)!
        case .indexRange:
            fatalError()
        }
    }
    
    init(_ childIndexSpec: ChildIndexSpec, isHardened: Bool) {
        self.childIndexSpec = childIndexSpec
        self.isHardened = isHardened
    }
    
    init(_ index: UInt32, isHardened: Bool) {
        try! self.init(ChildIndexSpec.index(ChildIndex(index)), isHardened: isHardened)
    }
    
    var array: [CBOR] {
        [childIndexSpec.cbor, CBOR.boolean(isHardened)]
    }
    
    func childNum() throws -> UInt32 {
        guard case let ChildIndexSpec.index(childIndex) = childIndexSpec else {
            throw GeneralError("Inspecific child number in derivation path.")
        }
        return isHardened ? childIndex.value | 0x80000000 : childIndex.value
    }
    
    var isFixed: Bool {
        childIndexSpec.isFixed
    }
}

extension DerivationStep: CustomStringConvertible {
    var description: String {
        childIndexSpec.description + (isHardened ? "'" : "")
    }
}

extension DerivationStep {
    static func parse(_ s: String) -> DerivationStep? {
        guard !s.isEmpty else {
            return nil
        }
        let isHardened = s.last! == "'"
        let specString = isHardened ? String(s.dropLast()) : s
        guard let spec = ChildIndexSpec.parse(specString) else {
            return nil
        }
        return DerivationStep(spec, isHardened: isHardened)
    }
}
