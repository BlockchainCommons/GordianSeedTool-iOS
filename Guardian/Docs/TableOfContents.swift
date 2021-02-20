//
//  TableOfContents.swift
//  Guardian
//
//  Created by Wolf McNally on 2/5/21.
//

import SwiftUI
import WolfSwiftUI

struct TableOfContents: View {
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            List {
                AppLogo()
                InfoLink(isPresented: $isPresented, name: "what-is-a-seed", header: IconHeader(image: Image("seed.circle")))
                InfoLink(isPresented: $isPresented, name: "what-is-a-lifehash", header: LifeHashHeader())
                InfoLink(isPresented: $isPresented, name: "what-is-a-ur", header: URHeader())
                InfoLink(isPresented: $isPresented, name: "what-are-bytewords", header: ByteWordsHeader())
                InfoLink(isPresented: $isPresented, name: "what-is-sskr", header: IconHeader(image: Image("sskr.bar")))
                InfoLink(isPresented: $isPresented, name: "what-is-a-cosigner", header: IconHeader(image: Image("bc-logo")))
                InfoLink(isPresented: $isPresented, name: "about-blockchain-commons", header: BlockchainCommonsLogo())
                InfoLink(isPresented: $isPresented, name: "license-and-disclaimer")
            }
            .navigationTitle("Contents")
            .navigationBarItems(leading: DoneButton($isPresented))
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func section<Content>(title: String, content: Content) -> some View where Content: View {
        NavigationLink(destination:
                        content
                        .navigationBarItems(trailing: DoneButton($isPresented))
        ) {
            Text(title)
        }
    }
}

#if DEBUG

struct TableOfContents_Previews: PreviewProvider {
    static var previews: some View {
        TableOfContents(isPresented: .constant(true))
            .darkMode()
    }
}

#endif
