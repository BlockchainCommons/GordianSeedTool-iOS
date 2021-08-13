//
//  ChildIndexRange.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/22/21.
//

import Foundation
import URKit

struct ChildIndexRange: Equatable {
    let low: ChildIndex
    let high: ChildIndex
    init(low: ChildIndex, high: ChildIndex) throws {
        guard low < high else {
            throw GeneralError("Invalid child index range.")
        }
        self.low = low
        self.high = high
    }
    
    var cbor: CBOR {
        CBOR.array([
            CBOR.unsignedInt(UInt64(low.value)),
            CBOR.unsignedInt(UInt64(high.value))
        ])
    }
    
    init?(cbor: CBOR) throws {
        guard case let CBOR.array(array) = cbor else {
            return nil
        }
        guard array.count == 2 else {
            return nil
        }
        guard
            case let CBOR.unsignedInt(low) = array[0],
            case let CBOR.unsignedInt(high) = array[1]
        else {
            return nil
        }
        try self.init(
            low: ChildIndex(UInt32(low)),
            high: ChildIndex(UInt32(high))
        )
    }
}

extension ChildIndexRange: CustomStringConvertible {
    var description: String {
        "\(low)-\(high)"
    }
}

extension ChildIndexRange {
    static func parse(_ s: String) -> ChildIndexRange? {
        let elems = s.split(separator: "-").map { String($0) }
        guard
            elems.count == 2,
            let low = ChildIndex.parse(elems[0]),
            let high = ChildIndex.parse(elems[1]),
            low < high
        else {
            return nil
        }
        return try! ChildIndexRange(low: low, high: high)
    }
}
