//
//  KeyExportModel.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/26/21.
//

import SwiftUI
import Combine

final class KeyExportModel: ObservableObject {
    let seed: Seed
    @Published var key: HDKey? = nil
    let updatePublisher: CurrentValueSubject<Void, Never>
    var ops = Set<AnyCancellable>()
    
    @Published var asset: Asset = .btc {
        didSet {
            updatePublisher.send(())
        }
    }
    
    @Published var network: Network = .mainnet {
        didSet {
            updatePublisher.send(())
        }
    }
    
    @Published var derivation: KeyExportDerivation = .gordian {
        didSet {
            updatePublisher.send(())
        }
    }
    
    @Published var keyType: KeyType = .public {
        didSet {
            updatePublisher.send(())
        }
    }
    
    @Published var isDerivable: Bool = true {
        didSet {
            updatePublisher.send(())
        }
    }

    init(seed: Seed) {
        self.seed = seed
        self.updatePublisher = CurrentValueSubject<Void, Never>(())
        self.network = settings.defaultNetwork
        
        updatePublisher
            .debounceField()
            .sink {
                self.updateKey()
            }
            .store(in: &ops)
        
        updatePublisher
            .debounceField()
            .dropFirst()
            .sink {
                Feedback.update.play()
            }
            .store(in: &ops)
    }
    
    func updateKey() {
        key = Self.deriveKey(seed: seed, useInfo: UseInfo(asset: asset, network: network), keyType: keyType, derivation: derivation, isDerivable: isDerivable)
    }
    
    static func gordianDerivationPath(useInfo: UseInfo, sourceFingerprint: UInt32? = nil) -> DerivationPath {
        var path: DerivationPath = [
            .init(48, isHardened: true),
            .init(useInfo.coinType, isHardened: true),
            .init(0, isHardened: true),
            .init(2, isHardened: true)
        ]
        if let sourceFingerprint = sourceFingerprint {
            path.sourceFingerprint = sourceFingerprint
        }
        return path
    }
    
    static func deriveKey(seed: Seed, useInfo: UseInfo, keyType: KeyType, derivation: KeyExportDerivation, isDerivable: Bool) -> HDKey {
        let masterPrivateKey = HDKey(seed: seed, useInfo: useInfo)
        
        let derivedPrivateKey: HDKey
        switch derivation {
        case .master:
            derivedPrivateKey = masterPrivateKey
        case .gordian:
            derivedPrivateKey = try!
                HDKey(parent: masterPrivateKey,
                      derivedKeyType: .private,
                      childDerivationPath: gordianDerivationPath(useInfo: masterPrivateKey.useInfo),
                      isDerivable: true
                )
        }
        
        return try! HDKey(parent: derivedPrivateKey, derivedKeyType: keyType, isDerivable: isDerivable);
    }
    
    static func deriveGordianKey(seed: Seed, network: Network, keyType: KeyType, isDerivable: Bool) -> HDKey {
        deriveKey(seed: seed, useInfo: .init(asset: .btc, network: network), keyType: keyType, derivation: .gordian, isDerivable: isDerivable)
    }
}
