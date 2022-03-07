//
//  KeyExport.swift
//  SeedTool
//
//  Created by Wolf McNally on 3/6/22.
//

import SwiftUI

struct KeyExport: View {
    @Binding var isPresented: Bool
    let key: ModelHDKey
    @EnvironmentObject private var settings: Settings
    
    var body: some View {
        let isSensitive = key.keyType.isPrivate
        var items: [AnyView] = []
        items.append(
            ShareButton(
                "Share as Base58", icon: Image.base58, isSensitive: isSensitive,
                params: ActivityParams(
                    key.transformedBase58WithOrigin!,
                    name: key.name,
                    fields: key.keyExportFields(format: "Base58")
                )
            ).eraseToAnyView()
        )
        if settings.showDeveloperFunctions {
            items.append(DeveloperKeyRequestButton(key: key, seed: key.seed).eraseToAnyView())
            if !key.isMaster {
                items.append(DeveloperDerivationRequestButton(key: key).eraseToAnyView())
            }
            items.append(DeveloperKeyResponseButton(key: key, seed: key.seed).eraseToAnyView())
        }
        return ModelObjectExport(isPresented: $isPresented, isSensitive: isSensitive, subject: key, items: items)
    }
}
