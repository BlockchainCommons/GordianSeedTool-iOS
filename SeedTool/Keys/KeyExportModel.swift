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
    @Published var privateKey: HDKey? = nil
    @Published var publicKey: HDKey? = nil
    @Published var derivations: [KeyExportDerivation] = Asset.btc.derivations {
        didSet {
            derivation = .master
        }
    }
    let updatePublisher: CurrentValueSubject<Void, Never>
    var ops = Set<AnyCancellable>()
    
    @Published var asset: Asset = .btc {
        didSet {
            updatePublisher.send(())
            if oldValue != asset {
                self.derivations = self.asset.derivations
            }
        }
    }
    
    @Published var network: Network = .mainnet {
        didSet {
            updatePublisher.send(())
        }
    }
    
    @Published var derivation: KeyExportDerivation = .master {
        didSet {
            updatePublisher.send(())
        }
    }
    
    @Published var isDerivable: Bool = true {
        didSet {
            updatePublisher.send(())
        }
    }

    init(seed: Seed, network: Network) {
        self.seed = seed
        self.updatePublisher = CurrentValueSubject<Void, Never>(())
        self.network = network
        
        updatePublisher
            .debounceField()
            .sink {
                self.updateKeys()
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
    
    func updateKeys() {
        privateKey = Self.deriveKey(seed: seed, useInfo: UseInfo(asset: asset, network: network), keyType: .private, derivation: derivation, isDerivable: isDerivable)
        publicKey = try! HDKey(parent: privateKey!, derivedKeyType: .public)
    }
        
    static func deriveKey(seed: Seed, useInfo: UseInfo, keyType: KeyType, derivation: KeyExportDerivation, isDerivable: Bool = true) -> HDKey {
        let masterPrivateKey = HDKey(seed: seed, useInfo: useInfo)
        
        let derivedPrivateKey = try!
            HDKey(parent: masterPrivateKey,
                  derivedKeyType: .private,
                  childDerivationPath: derivation.path(useInfo: masterPrivateKey.useInfo),
                  isDerivable: true
            )

        return try! HDKey(parent: derivedPrivateKey, derivedKeyType: keyType, isDerivable: isDerivable);
    }
    
    static func deriveCosignerKey(seed: Seed, network: Network, keyType: KeyType, isDerivable: Bool = true) -> HDKey {
        deriveKey(seed: seed, useInfo: .init(asset: .btc, network: network), keyType: keyType, derivation: .cosigner, isDerivable: isDerivable)
    }
}
