//
//  KeyExportDerivation.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/26/21.
//

import SwiftUI

enum KeyExportDerivation: Identifiable, CaseIterable {
    case master
    case cosigner
    case segwit

    var name: String {
        switch self {
        case .master:
            return "Master Key"
        case .cosigner:
            return "Cosigner"
        case .segwit:
            return "Segwit"
        }
    }
    
    var id: String {
        "derivation-\(description)"
    }
    
    func base58Prefix(network: Network, keyType: KeyType) -> UInt32? {
        switch self {
        case .master:
            return nil
        case .cosigner:
            return nil
        case .segwit:
            // https://github.com/satoshilabs/slips/blob/master/slip-0132.md
            switch network {
            case .mainnet:
                switch keyType {
                case .private:
                    return 0x04b2430c // zprv
                case .public:
                    return 0x04b24746 // zpub
                }
            case .testnet:
                switch keyType {
                case .private:
                    return 0x045f18bc // vprv
                case .public:
                    return 0x045f1cf6 // vpub
                }
            }
        }
    }
    
    init?(origin: DerivationPath, useInfo: UseInfo) {
        guard let derivation = Self.allCases.first(where: {
            let path = $0.path(useInfo: useInfo, sourceFingerprint: origin.sourceFingerprint, depth: origin.depth)
            return path == origin
        }) else {
            return nil
        }
        self = derivation
    }
    
    func path(useInfo: UseInfo, sourceFingerprint: UInt32? = nil, depth: UInt8? = nil) -> DerivationPath {
        var path: DerivationPath
        switch self {
        case .master:
            path = []
        case .cosigner:
            path = [
                .init(48, isHardened: true),
                .init(useInfo.coinType, isHardened: true),
                .init(0, isHardened: true),
                .init(2, isHardened: true)
            ]
        case .segwit:
            path = [
                .init(84, isHardened: true),
                .init(useInfo.coinType, isHardened: true),
                .init(0, isHardened: true),
            ]
        }
        path.sourceFingerprint = sourceFingerprint
        path.depth = depth
        return path
    }
}

extension KeyExportDerivation: CustomStringConvertible {
    var description: String {
        switch self {
        case .master:
            return "master"
        case .cosigner:
            return "gordian"
        case .segwit:
            return "segwit"
        }
    }
}

struct KeyExportDerivationSegment: Segment {
    let derivation: KeyExportDerivation
    let useInfo: UseInfo
    
    var id: String {
        derivation.id
    }
    
    var label: AnyView {
        switch derivation {
        case .master:
            return segmentLabel("key.fill.circle")
        case .cosigner:
            return segmentLabel("bc-logo")
        case .segwit:
            return segmentLabel("segwit")
        }
    }
    
    private func segmentLabel(_ image: String) -> AnyView {
        let path = derivation.path(useInfo: useInfo)
        return VStack(alignment: .leading) {
            HStack {
                Image(image)
                Text(derivation.name)
            }
            .font(.headline)
            if !path.isEmpty {
                Text(String(describing: path))
                    .font(.footnote)
            }
        }
        .eraseToAnyView()
    }
}
