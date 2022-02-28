//
//  Symbol.swift
//  SeedTool
//
//  Created by Wolf McNally on 10/11/21.
//

import SwiftUI

struct Symbol: View {
    let icon: Image
    let renderingMode: SymbolRenderingMode
    let color: Color
    
    var body: some View {
        icon
            .symbolRenderingMode(renderingMode)
            .foregroundStyle(color)
    }
    
    static var txSent: Symbol {
        Symbol(icon: .txSent, renderingMode: .monochrome, color: .red)
    }

    static var txChange: Symbol {
        Symbol(icon: .txChange, renderingMode: .monochrome, color: .green)
    }

    static var txInput: Symbol {
        Symbol(icon: .txInput, renderingMode: .monochrome, color: .blue)
    }

    static var txFee: Symbol {
        Symbol(icon: .txFee, renderingMode: .hierarchical, color: .yellowLightSafe)
    }
    
    static var bitcoin: Symbol {
        Symbol(icon: .bitcoin, renderingMode: .hierarchical, color: .orange)
    }
    
    static var ethereum: Symbol {
        Symbol(icon: .ethereum, renderingMode: .hierarchical, color: .green)
    }
    
    static var signature: Symbol {
        Symbol(icon: .signature, renderingMode: .hierarchical, color: .teal)
    }
    
    static var signatureNeeded: Symbol {
        Symbol(icon: .signatureNeeded, renderingMode: .hierarchical, color: .teal)
    }
}
