//
//  ComparableExtensions.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/18/21.
//

import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}
