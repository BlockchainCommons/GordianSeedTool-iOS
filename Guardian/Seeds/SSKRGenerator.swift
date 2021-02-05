//
//  SSKRGenerator.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/18/20.
//

import Foundation
import SSKR
import URKit

final class SSKRGenerator {
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
            shares.map { share in
                let cbor = CBOR.encodeTagged(tag: CBOR.Tag(rawValue: 309), value: Data(share.data))
                return Bytewords.encode(Data(cbor), style: .standard)
            }
        }
    }()

    lazy var urGroupShares: [[String]] = {
        groupShares.map { shares in
            shares.map { share in
                let cbor = CBOR.encode(Data(share.data))
                return try! UREncoder.encode( UR(type: "crypto-sskr", cbor: cbor) )
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
        formatGroupStrings(urGroupShares)
    }()
}
