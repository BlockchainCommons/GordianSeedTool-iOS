//
//  SSKRModel2.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/18/21.
//

import Foundation

struct SSKRModel2 {
    private var _groupThreshold: Int
    private var _groups: [SSKRModelGroup2]
    private var _preset: SSKRPreset

    let groupsRange = 1...16
    
    var groupThresholdRange: ClosedRange<Int> {
        1..._groups.count
    }

    init(groupThreshold: Int = 1, groups: [SSKRModelGroup2] = [SSKRModelGroup2()], preset: SSKRPreset = .oneOfOne) {
        self._groupThreshold = groupThreshold.clamped(to: 1...groups.count)
        self._groups = groups
        self._preset = preset
    }
    
    private mutating func syncPreset() {
        self._preset = SSKRPreset.value(for: self)
    }
    
    init(_ groupThreshold: Int, _ groups: [(Int, Int)], _ preset: SSKRPreset) {
        self.init(groupThreshold: groupThreshold, groups: groups.map { SSKRModelGroup2($0) }, preset: preset)
    }
    
    var groupThreshold: Int {
        get {
            _groupThreshold
        }
        
        set {
            _groupThreshold = newValue.clamped(to: groupThresholdRange)
            syncPreset()
        }
    }
    
    var groupsCount: Int {
        get {
            _groups.count
        }
        
        set {
            while _groups.count > newValue {
                _groups.removeLast()
            }
            while _groups.count < newValue {
                _groups.append(SSKRModelGroup2())
            }
            groupThreshold = groupThreshold.clamped(to: groupThresholdRange)
            syncPreset()
        }
    }
    
    var groups: [SSKRModelGroup2] {
        get {
            _groups
        }
        
        set {
            _groups = newValue
            groupThreshold = groupThreshold.clamped(to: groupThresholdRange)
            syncPreset()
        }
    }


    var note: String {
        (groupThreshold == _groups.count ? "All" : "\(groupThreshold) of \(_groups.count)")
            + " groups must be met."
    }
    
    var preset: SSKRPreset {
        get {
            _preset
        }
        
        set {
            if let newModel = newValue.model {
                self = newModel
            }
        }
    }
}

extension SSKRModel2: Equatable {
    static func == (lhs: SSKRModel2, rhs: SSKRModel2) -> Bool {
        lhs.groupThreshold == rhs.groupThreshold && lhs.groups == rhs.groups
    }
}

struct SSKRModelGroup2 {
    private var _threshold: Int
    private var _count: Int
    
    static let countRange = 1...16
    
    var thresholdRange: ClosedRange<Int> {
        min(_count, 2)..._count
    }

    init(threshold: Int = 1, count: Int = 1) {
        self._threshold = threshold
        self._count = count
    }
    
    init(_ value: (Int, Int)) {
        self.init(threshold: value.0, count: value.1)
    }
    
    var threshold: Int {
        get {
            _threshold
        }
        
        set {
            _threshold = newValue.clamped(to: thresholdRange)
        }
    }
    
    var count: Int {
        get {
            _count
        }
        
        set {
            _count = newValue.clamped(to: Self.countRange)
            threshold = threshold.clamped(to: thresholdRange)
        }
    }

    var note: String {
        (threshold == count ? "All" : "\(threshold) of \(count)")
            + " shares in this group must be met."
    }
}

extension SSKRModelGroup2: Equatable {
    static func == (lhs: SSKRModelGroup2, rhs: SSKRModelGroup2) -> Bool {
        lhs.threshold == rhs.threshold && lhs.count == rhs.count
    }
}
