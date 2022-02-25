//
//  SSKRGenerator.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/18/20.
//

import Foundation
import WolfBase
import BCFoundation
import SwiftUI

final class SSKRGenerator: ObservableObject {
    let id = UUID()
    let seed: ModelSeed
    let sskrModel: SSKRModel
    let date = Date()
    var multipleSharesPerPage = false

    static let sskrDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .medium
        return f
    }()

    static func sskrGeneratedDate(_ date: Date) -> Text {
        Text("Generated: ").bold() +
            Text(sskrDateFormatter.string(from: date))
    }

    init(seed: ModelSeed, sskrModel: SSKRModel) {
        self.seed = seed
        self.sskrModel = sskrModel
    }
    
    var generatedDate: Text {
        Self.sskrGeneratedDate(date)
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

        return lines.joined(separator: "\n") + "\n"
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
    
    lazy var groupedShareCoupons: [[SSKRShareCoupon]] = {
        var result = [[SSKRShareCoupon]]()
        for (groupIndex, shares) in urBytewordsGroupShares.enumerated() {
            var group = [SSKRShareCoupon]()
            for (shareIndex, (ur, bytewords)) in shares.enumerated() {
                group.append(
                    SSKRShareCoupon(date: date, ur: ur, bytewords: bytewords, seed: seed, groupIndex: groupIndex, shareIndex: shareIndex, sharesCount: shares.count)
                )
            }
            result.append(group)
        }
        return result
    }()

    lazy var shareCoupons: [SSKRShareCoupon] = {
        groupedShareCoupons.flatMap { $0 }
//        var result = [SSKRShareCoupon]()
//        for (groupIndex, shares) in urBytewordsGroupShares.enumerated() {
//            for (shareIndex, (ur, bytewords)) in shares.enumerated() {
//                result.append(
//                    SSKRShareCoupon(date: date, ur: ur, bytewords: bytewords, seed: seed, groupIndex: groupIndex)
//                )
//            }
//        }
//        return result
    }()
}

extension SSKRGenerator: Printable {
    var printPages: [AnyView] {
        var result = [AnyView]()
        let coupons = shareCoupons;
        let couponsPerPage = multipleSharesPerPage ? 4 : 1
        let pageCoupons = coupons.chunked(into: couponsPerPage)
        for coupons in pageCoupons {
            result.append(
                SSKRSharePage(
                    multipleSharesPerPage: multipleSharesPerPage,
                    seed: seed,
                    coupons: coupons
                )
                    .eraseToAnyView()
            )
        }
        return result
    }
    
    var printExportFields: ExportFields {
        [
            .rootID: seed.digestIdentifier,
            .type: "SSKR"
        ]
    }
}

extension SSKRGenerator: Equatable {
    static func == (lhs: SSKRGenerator, rhs: SSKRGenerator) -> Bool {
        lhs.id == rhs.id
    }
}
