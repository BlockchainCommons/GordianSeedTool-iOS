//
//  Settings.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/30/21.
//

import SwiftUI
import BCApp
import Observation

fileprivate let appDefaultNetwork: Network = .mainnet
fileprivate let appPrimaryAsset: Asset = .btc

@Observable
final class Settings {
    var storage: SettingsStorage
    
    var isMock: Bool {
        storage.isMock
    }
    
    var defaultNetwork: Network {
        didSet {
            storage.defaultNetwork = defaultNetwork
        }
    }
    
    var primaryAsset: Asset {
        didSet {
            storage.primaryAsset = primaryAsset
        }
    }
    
    var isLicenseAccepted: Bool {
        didSet {
            storage.isLicenseAccepted = isLicenseAccepted
        }
    }
    
    var syncToCloud: SyncToCloud {
        didSet {
            storage.syncToCloud = syncToCloud
            if syncToCloud != oldValue {
                if syncToCloud == .on {
                    needsMergeWithCloud = true
                }
            }
        }
    }
    
    var needsMergeWithCloud: Bool {
        didSet {
            storage.needsMergeWithCloud = needsMergeWithCloud
        }
    }
    
    var showDeveloperFunctions: Bool {
        didSet {
            storage.showDeveloperFunctions = showDeveloperFunctions
        }
    }

    init(storage: SettingsStorage) {
        UserDefaults.standard.register(
            defaults: [
                "needsMergeWithCloud" : true,
                "syncToCloud": true
            ]
        )

        self.storage = storage
        defaultNetwork = storage.defaultNetwork
        primaryAsset = storage.primaryAsset
        isLicenseAccepted = storage.isLicenseAccepted
        syncToCloud = storage.syncToCloud
        needsMergeWithCloud = storage.needsMergeWithCloud
        showDeveloperFunctions = storage.showDeveloperFunctions
    }
}

protocol SettingsStorage {
    var isMock: Bool { get }
    var defaultNetwork: Network { get set }
    var primaryAsset: Asset { get set }
    var isLicenseAccepted: Bool { get set }
    var syncToCloud: SyncToCloud { get set }
    var needsMergeWithCloud: Bool { get set }
    var showDeveloperFunctions: Bool { get set }
}

struct MockSettingsStorage: SettingsStorage {
    let isMock = true
    var defaultNetwork = appDefaultNetwork
    var primaryAsset = appPrimaryAsset
    var isLicenseAccepted = true
    var syncToCloud = SyncToCloud.on
    var needsMergeWithCloud = true
    var showDeveloperFunctions = true
}

extension UserDefaults: SettingsStorage {
    var isMock: Bool {
        false
    }
    
    var defaultNetwork: Network {
        get { Network(id: string(forKey: "defaultNetwork") ?? appDefaultNetwork.id) ?? appDefaultNetwork }
        set { setValue(newValue.id, forKey: "defaultNetwork") }
    }

    var primaryAsset: Asset {
        get { Asset(string(forKey: "primaryAsset") ?? appPrimaryAsset.symbol ) ?? appPrimaryAsset }
        set { setValue(newValue.symbol, forKey: "primaryAsset") }
    }
    
    var isLicenseAccepted: Bool {
        get { bool(forKey: "isLicenseAccepted") }
        set { setValue(newValue, forKey: "isLicenseAccepted") }
    }
    
    var syncToCloud: SyncToCloud {
        get { bool(forKey: "syncToCloud") ? .on : .off }
        set { setValue(newValue.boolValue, forKey: "syncToCloud") }
    }
    
    var needsMergeWithCloud: Bool {
        get { bool(forKey: "needsMergeWithCloud") }
        set { setValue(newValue, forKey: "needsMergeWithCloud") }
    }
    
    var showDeveloperFunctions: Bool {
        get { bool(forKey: "showDeveloperFunctions") }
        set { setValue(newValue, forKey: "showDeveloperFunctions") }
    }
}

enum SyncToCloud: CaseIterable, Identifiable {
    case on
    case off
    
    var boolValue: Bool {
        switch self {
        case .on:
            return true
        case .off:
            return false
        }
    }

    var id: String {
        switch self {
        case .on:
            return "on"
        case .off:
            return "off"
        }
    }

    var name: String {
        switch self {
        case .on:
            return "On"
        case .off:
            return "Off"
        }
    }
    
    @ViewBuilder
    var icon: some View {
        switch self {
        case .on:
            Image.iCloud(on: true)
                .accessibility(label: Text(self.name))
        case .off:
            Image.iCloud(on: false)
                .accessibility(label: Text(self.name))
        }
    }
}

extension SyncToCloud: Segment {
    var view: AnyView {
        makeSegmentLabel(title: name, icon: icon.eraseToAnyView())
    }
    
    var accessibilityLabel: String {
        name
    }
}
