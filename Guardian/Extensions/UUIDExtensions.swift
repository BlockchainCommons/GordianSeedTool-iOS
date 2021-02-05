//
//  UUIDExtensions.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/21/20.
//

import Foundation

extension UUID {
    var data: Data {
        withUnsafeBytes(of: uuid) { p in
            Data(p.bindMemory(to: UInt8.self))
        }
    }
}
