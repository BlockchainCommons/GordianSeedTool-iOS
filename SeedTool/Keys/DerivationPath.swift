//
//  DerivationPath.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/22/21.
//

import Foundation
import BCFoundation

extension DerivationPath {
    var cbor: CBOR {
        var a: [OrderedMapEntry] = [
            .init(key: 1, value: CBOR.array(steps.flatMap { $0.array } ))
        ]
        
        if case let .fingerprint(sourceFingerprint) = origin {
            a.append(.init(key: 2, value: CBOR.unsignedInt(UInt64(sourceFingerprint))))
        }
        
        if let depth = depth {
            a.append(.init(key: 3, value: CBOR.unsignedInt(UInt64(depth))))
        }
        
        return CBOR.orderedMap(a)
    }
    
    var taggedCBOR: CBOR {
        CBOR.tagged(.derivationPath, cbor)
    }
    
    init(cbor: CBOR) throws {
        guard case let CBOR.map(pairs) = cbor
        else {
            throw GeneralError("DerivationPath doesn't contain a map.")
        }
        
        guard
            case let CBOR.array(componentsItem) = pairs[1] ?? CBOR.null,
            componentsItem.count.isMultiple(of: 2)
        else {
            throw GeneralError("Invalid DerivationPath components.")
        }
        
        let steps: [DerivationStep] = try stride(from: 0, to: componentsItem.count, by: 2).map { i in
            let childIndexSpec = try ChildIndexSpec.decode(cbor: componentsItem[i])
            guard case let CBOR.boolean(isHardened) = componentsItem[i + 1] else {
                throw GeneralError("Invalid path component.")
            }
            return DerivationStep(childIndexSpec, isHardened: isHardened)
        }
        
        let origin: Origin?
        if let sourceFingerprintItem = pairs[2] {
            guard
                case let CBOR.unsignedInt(sourceFingerprintValue) = sourceFingerprintItem,
                sourceFingerprintValue != 0,
                sourceFingerprintValue <= UInt32.max
            else {
                throw GeneralError("Invalid source fingerprint.")
            }
            origin = .fingerprint(UInt32(sourceFingerprintValue))
        } else {
            origin = nil
        }
        
        let depth: Int?
        if let depthItem = pairs[3] {
            guard
                case let CBOR.unsignedInt(depthValue) = depthItem,
                depthValue <= UInt8.max
            else {
                throw GeneralError("Invalid depth.")
            }
            depth = Int(depthValue)
        } else {
            depth = nil
        }
        
        self.init(steps: steps, origin: origin, depth: depth)
    }
    
    init(taggedCBOR: CBOR) throws {
        guard case let CBOR.tagged(.derivationPath, cbor) = taggedCBOR else {
            throw GeneralError("DerivationPath tag (304) not found.")
        }
        try self.init(cbor: cbor)
    }
}
