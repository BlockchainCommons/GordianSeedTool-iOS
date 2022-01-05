//
//  KeyExportModel.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/26/21.
//

import SwiftUI
import Combine
import BCFoundation
import WolfBase

final class KeyExportModel: ObservableObject {
    let seed: ModelSeed
    @Published var privateHDKey: ModelHDKey? = nil
    @Published var publicHDKey: ModelHDKey? = nil
    @Published var address: ModelAddress? = nil
    @Published var privateECKey: ModelPrivateKey? = nil
    @Published var derivations: [KeyExportDerivationPreset] = Asset.btc.derivations
    @Published var secondaryDerivationType: SecondaryDerivationType = .publicKey
    @Published var outputDescriptor: OutputDescriptor? = nil
    @Published var outputBundle: OutputDescriptorBundle? = nil
    private let keyUpdatePublisher: CurrentValueSubject<Void, Never>
    private let secondaryDerivationUpdatePublisher: CurrentValueSubject<Void, Never>

    private var ops = Set<AnyCancellable>()
    
    @Published var asset: Asset = .btc {
        didSet {
            keyUpdatePublisher.send(())
            if oldValue != asset {
                self.derivations = self.asset.derivations
            }
        }
    }
    
    @Published var network: Network = .mainnet {
        didSet {
            keyUpdatePublisher.send(())
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
            keyUpdatePublisher.send()
        }
    }
    
    @Published var outputType: AccountOutputType = .pkh {
        didSet {
            secondaryDerivationUpdatePublisher.send()
        }
    }
    
    @Published var accountNumberText: String = "0" {
        didSet {
            guard
                let a = Int(accountNumberText.trim()),
                (0...0x8fffffff).contains(a)
            else {
                accountNumber = nil
                return
            }
            withAnimation {
                accountNumber = a
            }
        }
    }

    @Published var accountNumber: Int? = 0 {
        didSet {
            secondaryDerivationUpdatePublisher.send()
        }
    }

//    @Published var accountNumberText: String = "0" {
//        didSet {
//            withAnimation {
//                accountNumber = Int(accountNumberText.trim())
//            }
//        }
//    }
    
    @Published var isDerivable: Bool = true {
        didSet {
            keyUpdatePublisher.send(())
        }
    }
    
    var isMasterDerivation: Bool {
        derivationPathText.trim().isEmpty
    }
    
    var isValid: Bool {
        privateHDKey != nil
    }
    
    var useInfo: UseInfo {
        UseInfo(asset: asset, network: network)
    }

    init(seed: ModelSeed, network: Network) {
        self.seed = seed
        self.keyUpdatePublisher = CurrentValueSubject<Void, Never>(())
        self.secondaryDerivationUpdatePublisher = CurrentValueSubject<Void, Never>(())
        self.network = network
        
        keyUpdatePublisher
            .debounceField()
            .sink {
                self.updateKeys()
                self.updateSecondaryDerivation()
            }
            .store(in: &ops)
        
        keyUpdatePublisher
            .debounceField()
            .dropFirst()
            .sink {
                Feedback.update.play()
            }
            .store(in: &ops)
        
        secondaryDerivationUpdatePublisher
            .debounceField()
            .sink {
                self.updateSecondaryDerivation()
            }
            .store(in: &ops)
        
        secondaryDerivationUpdatePublisher
            .debounceField()
            .dropFirst()
            .sink {
                Feedback.update.play()
            }
            .store(in: &ops)
    }
    
    var allowSecondaryDerivation: Bool {
        asset == .btc && isMasterDerivation
    }
    
    func updateSecondaryDerivation() {
        withAnimation {
            guard
                allowSecondaryDerivation,
                let accountNumber = accountNumber,
                let privateHDKey = privateHDKey,
                let outputBundle = OutputDescriptorBundle(masterKey: privateHDKey, network: network, account: UInt32(accountNumber))
            else {
                outputDescriptor = nil
                outputBundle = nil
                return
            }
            
            self.outputBundle = outputBundle
            self.outputDescriptor = outputBundle.descriptorsByOutputType[outputType]
        }
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
            privateECKey = ModelPrivateKey(masterKey: masterKey, derivationPath: derivationPath, name: "Private Key from \(seed.name)", useInfo: useInfo, parentSeed: seed)
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

enum SecondaryDerivationType: Int, CaseIterable, Segment {
    case publicKey
    case outputDescriptor
    case outputBundle
    
    var id: Int {
        rawValue
    }
    
    func label<T, V>(title: T, image: V, caption: String) -> some View where T: View, V: View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                image
                title
            }
            Text(caption)
                .font(.caption)
                .fixedVertical()
        }
    }
    
    var requiresAccountNumber: Bool {
        switch self {
        case .publicKey:
            return false
        case .outputDescriptor:
            return true
        case .outputBundle:
            return true
        }
    }
    
    var label: AnyView {
        switch self {
        case .publicKey:
            return label(title: Text("Public Key"), image: Image("key.pub.circle").foregroundColor(.green), caption: "A public key and Bitcoin address.")
                .eraseToAnyView()
        case .outputDescriptor:
            return label(title: Text("Output Descriptor"), image: Image(systemName: "rhombus").foregroundColor(.blue), caption: "A range of public keys derived from the master key, including the method used to derive them.")
                .eraseToAnyView()
        case .outputBundle:
            return label(title: Text("Account Descriptor"), image: Image(systemName: "square.stack.3d.up").foregroundColor(.purple), caption: "A single structure that bundles many common output descriptors used by various wallets.")
                .eraseToAnyView()
        }
    }
}

struct AccountOutputTypeLabel: View {
    let outputType: AccountOutputType
    @EnvironmentObject var exportModel: KeyExportModel
    
    var body: some View {
        Label(
            title: {
                VStack(alignment: .leading) {
                    Text(outputType.descriptorSource(keyExpression: "KEY"))
                        .bold()
                        .monospaced()
                    Text(outputType.accountDerivationPath(network: exportModel.network, account: UInt32(exportModel.accountNumber ?? 0))†)
                        .font(.caption)
                }
            }, icon: {
                Image(systemName: "rhombus")
                    .font(Font.body.bold())
                    .foregroundColor(.blue)
            }
        )
    }
}

extension AccountOutputType: Segment {
    var label: AnyView {
        AccountOutputTypeLabel(outputType: self)
            .eraseToAnyView()
    }
}
