//
//  SSKRDecoder.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/23/20.
//

import Foundation
import SSKR
import URKit
import SwiftUI

class SSKRDecoder : ObservableObject {
    private let onProgress: () -> Void
    private var shares = Set<SSKRShare>()
    @Published var identifier: UInt16?
    @Published var groupThreshold: Int?
    @Published var groups: [Group] = []
    
    init(onProgress: @escaping () -> Void) {
        self.onProgress = onProgress
    }
    
    struct MemberStatus: Identifiable {
        let id: Int
        let isPresent: Bool
    }
    
    struct Group: CustomStringConvertible, Identifiable {
        var index: Int
        var memberThreshold: Int?
        var members = Set<SSKRShare>()
        var isSatisfied: Bool {
            guard let memberThreshold = memberThreshold else { return false }
            return members.count >= memberThreshold
        }
        
        var memberIndexes: [Int] {
            members.map({ $0.memberIndex }).sorted()
        }
        
        var memberStatus: [MemberStatus]? {
            guard let memberThreshold = memberThreshold else {
                return nil
            }
            let memberCount = members.count
            let iconsCount = max(memberThreshold, memberCount)
            return (0..<iconsCount).map { index in
                MemberStatus(id: index, isPresent: index < memberCount)
            }
        }
        
        private var memberTresholdString: String {
            if let memberThreshold = memberThreshold {
                return " of \(memberThreshold)"
            } else {
                return ""
            }
        }
        
        var description: String {
            "\(index + 1): \(members.count)\(memberTresholdString)"
        }
        
        var id: Int {
            index
        }
    }
    
    var groupCount: Int! {
        return groups.count
    }
    
    var isSatisfied: Bool {
        guard let groupThreshold = groupThreshold else {
            return false
        }
        let groupsSatisfied = groups.reduce(0) { count, group in
            return count + (group.isSatisfied ? 1 : 0)
        }
        return groupsSatisfied >= groupThreshold
    }
    
    func addShare(ur: UR) throws -> Seed? {
//        let debug = true
        
        let share = try SSKRShare(ur: ur)
        
        //if debug { print("🔵 Got \(share).") }
        
        guard !shares.contains(share) else {
            //if debug { print("🛑 Duplicate share.") }
            return nil
        }
        
        if identifier == nil {
            withAnimation {
                identifier = share.identifier
                groupThreshold = share.groupThreshold
                groups = (0..<share.groupCount).map {
                    Group(index: $0)
                }
            }
        }
        
        guard
            share.identifier == identifier,
            share.groupThreshold == groupThreshold,
            share.groupCount == groupCount,
            share.groupIndex < groupCount
        else {
//            if debug { print("🛑 \(share) failed group validation.") }
            return nil
        }
        
        if groups[share.groupIndex].memberThreshold == nil {
            withAnimation {
                groups[share.groupIndex].memberThreshold = share.memberThreshold
            }
        }
        
        guard groups[share.groupIndex].memberThreshold == share.memberThreshold else {
//            if debug { print("🛑 \(share) failed member validation.") }
            return nil
        }
        
        guard !groups[share.groupIndex].memberIndexes.contains(share.memberIndex) else {
//            if debug { print("🛑 \(share) had duplicate index.") }
            return nil
        }
        groups[share.groupIndex].members.insert(share)

//        if debug { print("✅ \(share) accepted.") }
        shares.insert(share)

//        if debug {
//            for group in groups {
//                print(group)
//            }
//        }

        if isSatisfied {
//            if debug {
//                print("✅ All groups satisfied, combining shares.")
//                for share in shares {
//                    print(share.urString)
//                }
//            }
            var acceptedShares = [SSKRShare]()
            for group in groups {
                if group.isSatisfied {
                    acceptedShares.append(contentsOf: group.members)
                }
            }
            let secret = try acceptedShares.combineSSKRShares()
            return Seed(data: secret)
        }
        
        //if debug { print("🔵 Need more shares.") }
        onProgress()
        return nil
    }
    
    static func decode(_ sskrString: String) throws -> Data {
        try sskrString
            .split(separator: "\n")
            .map { String($0) }
            .map { $0.trim() }
            .filter { !$0.isEmpty }
            .map { $0.removeWhitespaceRuns() }
            .compactMap { try decodeShare($0) }
            .combineSSKRShares()
    }
    
    private static func decodeShare(_ string: String) throws -> SSKRShare? {
        if let share = try SSKRShare(bytewords: string) {
            return share
        }
        
        if let share = try SSKRShare(urString: string) {
            return share
        }
        
        return nil
    }
}

extension Array where Element == SSKRShare {
    fileprivate func combineSSKRShares() throws -> Data {
        do {
            return try SSKRCombine(shares: self)
        } catch {
            throw GeneralError("Invalid SSKR shares.")
        }
    }
}
