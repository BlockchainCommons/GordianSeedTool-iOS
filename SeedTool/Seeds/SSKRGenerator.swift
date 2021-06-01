//
//  SSKRGenerator.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/18/20.
//

import Foundation
import SSKR
import URKit

final class SSKRGenerator: Printable {
    let seed: Seed
    let model: SSKRModel

    init(seed: Seed, model: SSKRModel) {
        self.seed = seed
        self.model = model
    }

    private lazy var groupDescriptors: [SSKRGroupDescriptor] = {
        model.groups.map { group in
            SSKRGroupDescriptor(threshold: group.threshold, count: group.count)
        }
    }()

    lazy var groupShares: [[SSKRShare]] = {
        try! SSKRGenerate(
            groupThreshold: model.groupThreshold,
            groups: groupDescriptors,
            secret: seed.data,
            randomGenerator: { SecureRandomNumberGenerator.shared.data(count: $0) }
        )
    }()

    lazy var bytewordsGroupShares: [[String]] = {
        groupShares.map { shares in
            shares.map { $0.bytewords }
        }
    }()

    lazy var urGroupShares: [[UR]] = {
        groupShares.map { shares in
            shares.map { $0.ur }
        }
    }()
    
    lazy var urBytewordsGroupShares: [[(UR, String)]] = {
        groupShares.map { shares in
            shares.map { share in
                (share.ur, share.bytewords)
            }
        }
    }()

    lazy var urGroupStringShares: [[String]] = {
        urGroupShares.map { shares in
            shares.map { share in
                return UREncoder.encode(share)
            }
        }
    }()

    private func formatGroupStrings(_ groupStrings: [[String]]) -> String {
        var lines: [String] = []

        if groupStrings.count > 1 {
            lines.append(model.note)
        }
        for (groupIndex, group) in groupStrings.enumerated() {
            if groupIndex > 0 {
                lines.append("")
            }
            let modelGroup = model.groups[groupIndex]
            if groupStrings.count > 1 {
                lines.append("Group \(groupIndex + 1)")
            }
            if modelGroup.count > 1 {
                lines.append(modelGroup.note)
            }
            for share in group {
                lines.append(share)
            }
        }

        let result = lines.joined(separator: "\n") + "\n"
        //print(result)
        return result
    }

    lazy var bytewordsShares: String = {
        formatGroupStrings(bytewordsGroupShares)
    }()

    lazy var urShares: String = {
        formatGroupStrings(urGroupStringShares)
    }()
    
    var name: String {
        "SSKR"
    }
    
    lazy var shareCoupons: [SSKRShareCoupon] = {
        var result = [SSKRShareCoupon]()
        for (groupIndex, shares) in urBytewordsGroupShares.enumerated() {
            let shareThreshold = model.groups[groupIndex].threshold
            let sharesCount = shares.count
            for (shareIndex, (ur, bytewords)) in shares.enumerated() {
                result.append(
                    SSKRShareCoupon(ur: ur, bytewords: bytewords, seed: seed, groupIndex: groupIndex, shareThreshold: shareThreshold, sharesCount: sharesCount, shareIndex: shareIndex)
                )
            }
        }
        return result
    }()
    
    var pages: [SSKRPrintPage] {
        var result = [SSKRPrintPage]()
        let coupons = shareCoupons;
        let couponsPerPage = 4
        let pageCoupons = coupons.chunked(into: couponsPerPage)
        let groupThreshold = model.groupThreshold
        let groupsCount = model.groups.count
        for (pageIndex, coupons) in pageCoupons.enumerated() {
            result.append(SSKRPrintPage(pageIndex: pageIndex, pageCount: pageCoupons.count, groupThreshold: groupThreshold, groupsCount: groupsCount, seed: seed, coupons: coupons))
        }
        return result
    }
}
