//
//  KeyExportModel.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/26/21.
//

import SwiftUI
import Combine
import LibWally

final class KeyExportModel: ObservableObject {
    let seed: ModelSeed
    @Published var privateHDKey: ModelHDKey? = nil
    @Published var publicHDKey: ModelHDKey? = nil
    @Published var address: ModelAddress? = nil
    @Published var privateECKey: ModelPrivateKey? = nil
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
                derivationPath = DerivationPath(string: derivationPathText.trim(), requireFixed: true)
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
        privateHDKey != nil
    }
    
    var useInfo: UseInfo {
        UseInfo(asset: asset, network: network)
    }

    init(seed: ModelSeed, network: Network) {
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
                privateHDKey = nil
                publicHDKey = nil
                address = nil
                privateECKey = nil
                return
            }
            privateHDKey = Self.deriveKey(seed: seed, useInfo: useInfo, keyType: .private, path: derivationPath, isDerivable: isDerivable)
            publicHDKey = try! ModelHDKey(key: privateHDKey!, derivedKeyType: .public)
            let masterKey = try! ModelHDKey(seed: seed, useInfo: useInfo, origin: nil, children: nil)
            address = ModelAddress(masterKey: masterKey, derivationPath: derivationPath, name: "Address from \(seed.name)", useInfo: useInfo, parentSeed: seed)
//            address = ModelAddress(seed: seed, name: "Address from \(seed.name)", useInfo: useInfo)
            privateECKey = ModelPrivateKey(masterKey: masterKey, derivationPath: derivationPath, name: "Private Key from \(seed.name)", useInfo: useInfo, parentSeed: seed)
//            privateECKey = ModelPrivateKey(seed: seed, name: "Private Key from \(seed.name)", useInfo: useInfo)
        }
    }
    
    static func deriveKey(seed: ModelSeed, useInfo: UseInfo, keyType: KeyType, path: DerivationPath, isDerivable: Bool = true) -> ModelHDKey {
        let masterKey = try! ModelHDKey(seed: seed, useInfo: useInfo)
        
        let derivedPrivateKey = try!
            ModelHDKey(parent: masterKey,
                  derivedKeyType: .private,
                  childDerivationPath: path,
                  isDerivable: true
            )
        
        return try! ModelHDKey(key: derivedPrivateKey, derivedKeyType: keyType, isDerivable: isDerivable);
    }
    
    static func deriveKey(seed: ModelSeed, useInfo: UseInfo, keyType: KeyType, derivation: KeyExportDerivationPreset, isDerivable: Bool = true) -> ModelHDKey {
        deriveKey(seed: seed, useInfo: useInfo, keyType: keyType, path: derivation.path(useInfo: useInfo), isDerivable: isDerivable)
    }

    static func deriveCosignerKey(seed: ModelSeed, network: Network, keyType: KeyType, isDerivable: Bool = true) -> ModelHDKey {
        deriveKey(seed: seed, useInfo: .init(asset: .btc, network: network), keyType: keyType, derivation: .cosigner, isDerivable: isDerivable)
    }

    static func deriveAddress(seed: ModelSeed, useInfo: UseInfo) -> ModelAddress {
        ModelAddress(seed: seed, name: "Address from \(seed.name)", useInfo: useInfo)
    }
    
    static func derivePrivateECKey(seed: ModelSeed, useInfo: UseInfo) -> ModelPrivateKey {
        ModelPrivateKey(seed: seed, name: "Private Key from \(seed.name)", useInfo: useInfo)
    }
}
