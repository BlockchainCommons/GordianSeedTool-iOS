//
//  IntUtils.swift
//  Guardian
//
//  Created by Wolf McNally on 1/26/21.
//

import Foundation

extension UInt32 {
    init(fromBigEndian data: Data) {
        assert(data.count == 4)
        self = withUnsafeBytes(of: data) {
            $0.bindMemory(to: UInt32.self).baseAddress!.pointee.bigEndian
        }
    }
    
    var bigEndianData: Data {
        withUnsafeByteBuffer(of: self.bigEndian) { Data($0) }
    }
}
