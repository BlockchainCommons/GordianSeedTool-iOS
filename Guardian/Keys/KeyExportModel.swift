//
//  KeyExportModel.swift
//  Guardian
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
    
    func updateKey() {
        key = Self.deriveKey(seed: seed, asset: asset, network: network, keyType: keyType, derivation: derivation)
    }
    
    static func deriveKey(seed: Seed, asset: Asset, network: Network, keyType: KeyType, derivation: KeyExportDerivation) -> HDKey {
        let masterPrivateKey = HDKey(seed: seed, asset: asset, network: network)
        
        let derivedPrivateKey: HDKey
        switch derivation {
        case .master:
            derivedPrivateKey = masterPrivateKey
        case .gordian:
            derivedPrivateKey = try!
                HDKey(parent: masterPrivateKey,
                      derivedKeyType: .private,
                      childDerivationPath: [
                        .init(48, isHardened: true),
                        .init(masterPrivateKey.coinType, isHardened: true),
                        .init(0, isHardened: true),
                        .init(2, isHardened: true)
                      ]
                )
        }
        
        let derivedKey: HDKey
        switch keyType {
        case .private:
            derivedKey = derivedPrivateKey
        case .public:
            derivedKey = try! HDKey(parent: derivedPrivateKey, derivedKeyType: .public)
        }
        
        return derivedKey
    }
    
    static func deriveGordianPublicKey(seed: Seed, network: Network) -> HDKey {
        deriveKey(seed: seed, asset: .btc, network: network, keyType: .public, derivation: .gordian)
    }
}
