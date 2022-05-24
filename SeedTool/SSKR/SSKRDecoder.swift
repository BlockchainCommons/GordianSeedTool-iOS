//
//  SSKRDecoder.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/23/20.
//

import Foundation
import SwiftUI
import BCFoundation
import os
import BCApp

fileprivate let logger = Logger(subsystem: Application.bundleIdentifier, category: "SSKRDecoder")

class SSKRDecoder : ObservableObject {
    private let onProgress: () -> Void
    private var shares = Set<SSKRShare>()
    @Published var shareIdentifier: UInt16?
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
    
    func addShare(_ share: SSKRShare) throws -> Data? {
        logger.debug("🔵 Got \(share).")
        
        guard !shares.contains(share) else {
            logger.debug("⚠️ Duplicate share.")
            return nil
        }
        
        if shareIdentifier == nil {
            withAnimation {
                shareIdentifier = share.identifier
                groupThreshold = share.groupThreshold
                groups = (0..<share.groupCount).map {
                    Group(index: $0)
                }
            }
        }
        
        guard
            share.identifier == shareIdentifier,
            share.groupThreshold == groupThreshold,
            share.groupCount == groupCount,
            share.groupIndex < groupCount
        else {
            logger.debug("⛔️ \(share) failed group validation.")
            return nil
        }
        
        if groups[share.groupIndex].memberThreshold == nil {
            withAnimation {
                groups[share.groupIndex].memberThreshold = share.memberThreshold
            }
        }
        
        guard groups[share.groupIndex].memberThreshold == share.memberThreshold else {
            logger.debug("⛔️ \(share) failed member validation.")
            return nil
        }
        
        guard !groups[share.groupIndex].memberIndexes.contains(share.memberIndex) else {
            logger.debug("⛔️ \(share) had duplicate index.")
            return nil
        }
        groups[share.groupIndex].members.insert(share)

        logger.debug("✅ \(share) accepted.")
        shares.insert(share)

        //    for group in groups {
        //        logger.debug(group)
        //    }

        if isSatisfied {
            //    logger.debug("✅ All groups satisfied, combining shares.")
            //    for share in shares {
            //        logger.debug(share.urString)
            //    }
            var acceptedShares = [SSKRShare]()
            for group in groups {
                if group.isSatisfied {
                    acceptedShares.append(contentsOf: group.members)
                }
            }
            let secret = try acceptedShares.combineSSKRShares()
            return secret
        }
        
        logger.debug("🔵 Need more shares.")
        onProgress()
        return nil
    }
    
    func addShare(ur: UR) throws -> Data? {
        try addShare(SSKRShare(ur: ur))
    }
    
    static func decode(_ sskrString: String) throws -> Data {
        let decoder = SSKRDecoder(onProgress: {})
        var secret: Data?
        
        try sskrString
            .split(separator: "\n")
            .map { String($0) }
            .map { $0.trim() }
            .filter { !$0.isEmpty }
            .map { $0.removeWhitespaceRuns() }
            .compactMap { try decodeShare($0) }
            .forEach { secret = try decoder.addShare($0) }
        
        guard let secret = secret else {
            guard let groupThreshold = decoder.groupThreshold else {
                throw GeneralError("No valid SSKR shares found.")
            }
            let groupCount = decoder.groups.count
            let groupElems = decoder.groups.map { group -> String in
                let thresholdString: String
                if let threshold = group.memberThreshold {
                    thresholdString = String(describing: threshold)
                } else {
                    thresholdString = "?"
                }
                return "[\(group.members.count) of \(thresholdString)]"
            }
            let groups = groupElems.joined(separator: " ")
            
            throw GeneralError("Groups needed: \(groupThreshold) of \(groupCount)\nHave: \(groups)")
        }
        
        return secret
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
            throw GeneralError("Invalid or insufficient SSKR shares.")
        }
    }
}
