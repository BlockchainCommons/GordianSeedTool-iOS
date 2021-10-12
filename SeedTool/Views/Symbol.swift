//
//  Symbol.swift
//  SeedTool
//
//  Created by Wolf McNally on 10/11/21.
//

import SwiftUI

enum Symbol {
    static var txChange: AnyView {
        Image(systemName: "arrow.uturn.left")
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(Color.green)
            .eraseToAnyView()
    }

    static var txSent: AnyView {
        Image(systemName: "arrow.right")
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(Color.red)
            .eraseToAnyView()
    }

    static var txInput: AnyView {
        Image(systemName: "arrow.down")
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(Color.blue)
            .eraseToAnyView()
    }

    static var txFee: AnyView {
        Image(systemName: "lock.circle")
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(Color.yellowLightSafe)
            .eraseToAnyView()
    }
    
    static var assetBTC: AnyView {
        Image(systemName: "bitcoinsign.circle.fill")
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(Color.orange)
            .eraseToAnyView()
    }
    
    static var assetETH: AnyView {
        Image("asset.eth")
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(Color.green)
            .eraseToAnyView()
    }
}
