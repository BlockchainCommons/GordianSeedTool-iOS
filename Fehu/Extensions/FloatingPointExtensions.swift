//
//  FloatingPointExtensions.swift
//  Fehu
//
//  Created by Wolf McNally on 12/8/20.
//

import Foundation

extension FloatingPoint {
    var clamped: Self {
        min(max(self, 0), 1)
    }
}
