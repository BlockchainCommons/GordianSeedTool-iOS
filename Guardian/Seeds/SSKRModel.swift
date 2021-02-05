//
//  SSKRModel.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/17/20.
//

import SwiftUI

class SSKRModel: ObservableObject {
    @Published var numberOfGroups: Int = 1 {
        didSet {
            syncGroups()
        }
    }

    @Published var groupsRange: ClosedRange<Int> = 1...16
    @Published var groupThreshold: Int
    @Published var groupThresholdRange: ClosedRange<Int> = 1...1
    @Published var groups: [SSKRModelGroup]

    init(groupThreshold: Int = 1, groups: [SSKRModelGroup] = [SSKRModelGroup()]) {
        self.groupThreshold = groupThreshold
        self.groups = groups
    }

    func syncGroups() {
        withAnimation {
            while groups.count > numberOfGroups {
                groups.removeLast()
            }
            while groups.count < numberOfGroups {
                groups.append(SSKRModelGroup())
            }
            groupThresholdRange = 1...numberOfGroups
            groupThreshold = min(groupThreshold, groupThresholdRange.upperBound)
        }
    }

    var note: String {
        (groupThreshold == groups.count ? "All" : "\(groupThreshold) of \(groups.count)")
            + " groups must be met."
    }
}

class SSKRModelGroup: ObservableObject {
    @Published var threshold: Int
    @Published var count: Int {
        didSet {
            sync()
        }
    }
    @Published var countRange: ClosedRange<Int> = 1...16
    @Published var thresholdRange: ClosedRange<Int> = 1...1

    init(threshold: Int = 1, count: Int = 1) {
        self.threshold = threshold
        self.count = count
    }

    func sync() {
        withAnimation {
            thresholdRange = min(count, 2)...count
            threshold = min(max(threshold, thresholdRange.lowerBound), thresholdRange.upperBound)
        }
    }

    var note: String {
        (threshold == count ? "All" : "\(threshold) of \(count)")
            + " shares in this group must be met."
    }
}
