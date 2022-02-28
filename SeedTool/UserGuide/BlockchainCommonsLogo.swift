//
//  BlockchainCommonsLogo.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/5/21.
//

import SwiftUI

struct BlockchainCommonsLogo: View {
    var body: some View {
        HStack(spacing: 5) {
            Image.bcLogo
                .font(Font.system(size: 48).bold())
            VStack(alignment: .leading) {
                Text("Blockchain")
                Text("Commons")
            }
            .font(Font.system(size: 24).bold())
        }
    }
}
