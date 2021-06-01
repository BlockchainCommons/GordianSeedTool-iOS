//
//  Settings.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/30/21.
//

import SwiftUI

fileprivate let appDefaultNetwork: Network = .testnet

final class Settings: ObservableObject {
    var storage: SettingsStorage
    
    @Published var defaultNetwork: Network {
        didSet {
            storage.defaultNetwork = defaultNetwork
        }
    }
    
    @Published var isLicenseAccepted: Bool {
        didSet {
            storage.isLicenseAccepted = isLicenseAccepted
        }
    }
    
    init(storage: SettingsStorage) {
        self.storage = storage
        defaultNetwork = storage.defaultNetwork
        isLicenseAccepted = storage.isLicenseAccepted
    }
}

protocol SettingsStorage {
    var defaultNetwork: Network { get set }
    var isLicenseAccepted: Bool { get set }
}

struct MockSettingsStorage: SettingsStorage {
    var defaultNetwork: Network = appDefaultNetwork
    var isLicenseAccepted: Bool = true
}

extension UserDefaults: SettingsStorage {
    var defaultNetwork: Network {
        get { Network(id: string(forKey: "defaultNetwork") ?? appDefaultNetwork.id) ?? appDefaultNetwork }
        set { setValue(newValue.id, forKey: "defaultNetwork") }
    }
    
    var isLicenseAccepted: Bool {
        get { bool(forKey: "isLicenseAccepted") }
        set { setValue(newValue, forKey: "isLicenseAccepted") }
    }
}
