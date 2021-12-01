//
//  UseInfoExtensions.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/22/21.
//

import Foundation
import BCFoundation

extension UseInfo {
    var isDefault: Bool {
        return asset == .btc && network == .mainnet
    }
}
