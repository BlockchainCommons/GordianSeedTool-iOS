//
//  AboutBlockchainCommons.swift
//  Guardian
//
//  Created by Wolf McNally on 2/5/21.
//

import SwiftUI

struct AboutBlockchainCommons: View {
    var body: some View {
        InfoPage(name: "about-blockchain-commons", header: BlockchainCommonsLogo())
    }
}

struct AboutBlockchainCommons_Previews: PreviewProvider {
    static var previews: some View {
        AboutBlockchainCommons()
            .darkMode()
    }
}
