//
//  OutputPathInfo.swift
//  SeedTool
//
//  Created by Wolf McNally on 3/8/22.
//

import SwiftUI
import WolfBase
import BCApp

struct OutputPathInfo: View {
    let path: DerivationPath
    
    var body: some View {
        if let outputType = AccountOutputType.firstMatching(path: path) {
            Info(Text("The derivation path for this key: `\(path†)` has known type “\(outputType.name)”."))
        } else {
            Caution(Text("The derivation path for this key: `\(path†)` has no known type."))
        }
    }
}
