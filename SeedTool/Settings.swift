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
    
    var isMock: Bool {
        storage.isMock
    }
    
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
    
    @Published var syncToCloud: SyncToCloud {
        didSet {
            storage.syncToCloud = syncToCloud
            if syncToCloud != oldValue {
                if syncToCloud == .on {
                    needsMergeWithCloud = true
                }
            }
        }
    }
    
    @Published var needsMergeWithCloud: Bool {
        didSet {
            //print("setting needsMergeWithCloud to \(needsMergeWithCloud)")
            storage.needsMergeWithCloud = needsMergeWithCloud
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
        isLicenseAccepted = storage.isLicenseAccepted
        syncToCloud = storage.syncToCloud
        needsMergeWithCloud = storage.needsMergeWithCloud
    }
}

protocol SettingsStorage {
    var isMock: Bool { get }
    var defaultNetwork: Network { get set }
    var isLicenseAccepted: Bool { get set }
    var syncToCloud: SyncToCloud { get set }
    var needsMergeWithCloud: Bool { get set }
}

struct MockSettingsStorage: SettingsStorage {
    let isMock = true
    var defaultNetwork = appDefaultNetwork
    var isLicenseAccepted = true
    var syncToCloud = SyncToCloud.on
    var needsMergeWithCloud = true
}

extension UserDefaults: SettingsStorage {
    var isMock: Bool {
        false
    }
    
    var defaultNetwork: Network {
        get { Network(id: string(forKey: "defaultNetwork") ?? appDefaultNetwork.id) ?? appDefaultNetwork }
        set { setValue(newValue.id, forKey: "defaultNetwork") }
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
    
    var icon: AnyView {
        switch self {
        case .on:
            return Image(systemName: "icloud")
                .accessibility(label: Text(self.name))
                .eraseToAnyView()
        case .off:
            return Image(systemName: "xmark.icloud")
                .accessibility(label: Text(self.name))
                .eraseToAnyView()
        }
    }
}

extension SyncToCloud: Segment {
    var label: AnyView {
        makeSegmentLabel(title: name, icon: icon)
    }
}
