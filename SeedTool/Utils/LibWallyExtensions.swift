//
//  LibWallyExtensions.swift
//  SeedTool
//
//  Created by Wolf McNally on 9/18/21.
//

import Foundation
import LibWally

extension Bitcoin.Address {
    convenience init(key: HDKey, type: AddressType) {
        self.init(hdKey: key.wallyHDKey, type: type)
    }
}

extension LibWally.HDKey {
    init(key: HDKey) {
        self.init(key: key.wallyHDKey.wallyExtKey, parent: .init(), children: key.children?.wallyDerivationPath ?? .init())
    }
}

extension LibWally.Account {
    convenience init(masterKey: HDKey, useInfo: UseInfo, account: UInt32) {
        self.init(masterKey: LibWally.HDKey(key: masterKey), useInfo: useInfo, account: account)
    }
}
