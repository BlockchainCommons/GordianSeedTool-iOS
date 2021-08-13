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
    @Published var derivations: [KeyExportDerivationPreset] = Asset.btc.derivations
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
    
    @Published var derivationPathText: String = "" {
        didSet {
            withAnimation {
                derivationPath = DerivationPath.parseFixed(derivationPathText.trim())
            }
        }
    }
    
    @Published var derivationPath: DerivationPath? = DerivationPath(steps: []) {
        didSet {
//            print("derivationPath: \(derivationPath)")
            updatePublisher.send()
        }
    }
    
    @Published var isDerivable: Bool = true {
        didSet {
            updatePublisher.send(())
        }
    }
    
    var isValid: Bool {
        privateKey != nil
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
        withAnimation {
            guard let derivationPath = derivationPath else {
                privateKey = nil
                publicKey = nil
                return
            }
            privateKey = Self.deriveKey(seed: seed, useInfo: UseInfo(asset: asset, network: network), keyType: .private, path: derivationPath, isDerivable: isDerivable)
            publicKey = try! HDKey(parent: privateKey!, derivedKeyType: .public)
        }
    }
    
    static func deriveKey(seed: Seed, useInfo: UseInfo, keyType: KeyType, path: DerivationPath, isDerivable: Bool = true) -> HDKey {
        let masterPrivateKey = HDKey(seed: seed, useInfo: useInfo)
        
        let derivedPrivateKey = try!
            HDKey(parent: masterPrivateKey,
                  derivedKeyType: .private,
                  childDerivationPath: path,
                  isDerivable: true
            )
        
        return try! HDKey(parent: derivedPrivateKey, derivedKeyType: keyType, isDerivable: isDerivable);
    }
    
    static func deriveKey(seed: Seed, useInfo: UseInfo, keyType: KeyType, derivation: KeyExportDerivationPreset, isDerivable: Bool = true) -> HDKey {
        deriveKey(seed: seed, useInfo: useInfo, keyType: keyType, path: derivation.path(useInfo: useInfo), isDerivable: isDerivable)
    }

    static func deriveCosignerKey(seed: Seed, network: Network, keyType: KeyType, isDerivable: Bool = true) -> HDKey {
        deriveKey(seed: seed, useInfo: .init(asset: .btc, network: network), keyType: keyType, derivation: .cosigner, isDerivable: isDerivable)
    }
}
