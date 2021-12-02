//
//  SSKRGenerator.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/18/20.
//

import Foundation
import WolfBase
import BCFoundation

final class SSKRGenerator {
    let seed: SeedProtocol
    let sskrModel: SSKRModel

    init(seed: SeedProtocol, sskrModel: SSKRModel) {
        self.seed = seed
        self.sskrModel = sskrModel
    }

    private lazy var groupDescriptors: [SSKRGroupDescriptor] = {
        sskrModel.groups.map { group in
            SSKRGroupDescriptor(threshold: UInt8(group.threshold), count: UInt8(group.count))
        }
    }()

    lazy var groupShares: [[SSKRShare]] = {
        try! SSKRGenerate(
            groupThreshold: sskrModel.groupThreshold,
            groups: groupDescriptors,
            secret: seed.data,
            randomGenerator: { SecureRandomNumberGenerator.shared.data(count: $0) }
        )
    }()

    lazy var bytewordsGroupShares: [[String]] = {
        groupShares.map { shares in
            shares.map { $0.bytewords(style: .standard) }
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
                (share.ur, share.bytewords(style: .standard))
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
            lines.append(sskrModel.note)
        }
        for (groupIndex, group) in groupStrings.enumerated() {
            if groupIndex > 0 {
                lines.append("")
            }
            let modelGroup = sskrModel.groups[groupIndex]
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
        "SSKR \(seed.name)"
    }
    
    lazy var shareCoupons: [SSKRShareCoupon] = {
        var result = [SSKRShareCoupon]()
        for (groupIndex, shares) in urBytewordsGroupShares.enumerated() {
            let shareThreshold = sskrModel.groups[groupIndex].threshold
            let sharesCount = shares.count
            for (shareIndex, (ur, bytewords)) in shares.enumerated() {
                result.append(
                    SSKRShareCoupon(ur: ur, bytewords: bytewords, seed: seed, groupIndex: groupIndex, shareThreshold: shareThreshold, sharesCount: sharesCount, shareIndex: shareIndex)
                )
            }
        }
        return result
    }()
}

extension SSKRGenerator: Printable {
    func printPages(model: Model) -> [SSKRPrintPage] {
        var result = [SSKRPrintPage]()
        let coupons = shareCoupons;
        let couponsPerPage = 4
        let pageCoupons = coupons.chunked(into: couponsPerPage)
        let groupThreshold = sskrModel.groupThreshold
        let groupsCount = sskrModel.groups.count
        for (pageIndex, coupons) in pageCoupons.enumerated() {
            result.append(SSKRPrintPage(pageIndex: pageIndex, pageCount: pageCoupons.count, groupThreshold: groupThreshold, groupsCount: groupsCount, seed: seed as! ModelSeed, coupons: coupons))
        }
        return result
    }
}
