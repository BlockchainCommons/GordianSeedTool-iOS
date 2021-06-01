//
//  IntExtensions.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 4/12/21.
//

import Foundation

extension UInt16 {
    var hex: String {
        String(format:"%04X", self)
    }
}
