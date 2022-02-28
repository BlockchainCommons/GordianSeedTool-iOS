//
//  Symbol.swift
//  SeedTool
//
//  Created by Wolf McNally on 10/11/21.
//

import SwiftUI

enum Symbol {
    static var txSent: AnyView {
        Image.txSent
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(Color.red)
            .eraseToAnyView()
    }

    static var txChange: AnyView {
        Image.txChange
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(Color.green)
            .eraseToAnyView()
    }

    static var txInput: AnyView {
        Image.txInput
            .symbolRenderingMode(.monochrome)
            .foregroundStyle(Color.blue)
            .eraseToAnyView()
    }

    static var txFee: AnyView {
        Image.txFee
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(Color.yellowLightSafe)
            .eraseToAnyView()
    }
    
    static var bitcoin: some View {
        Image.bitcoin
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(Color.orange)
    }
    
    static var ethereum: some View {
        Image.ethereum
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(Color.green)
    }
    
    static var signature: AnyView {
        Image.signature
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(Color.teal)
            .eraseToAnyView()
    }
    
    static var signatureNeeded: AnyView {
        Image.signatureNeeded
            .symbolRenderingMode(.hierarchical)
            .foregroundStyle(Color.teal)
            .eraseToAnyView()
    }
}
