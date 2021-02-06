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
                InfoLink(isPresented: $isPresented, name: "what-is-a-seed", header: seedIcon)
                InfoLink(isPresented: $isPresented, name: "about-blockchain-commons", header: BlockchainCommonsLogo())
                InfoLink(isPresented: $isPresented, name: "license-and-disclaimer")
            }
            .navigationTitle("Contents")
            .navigationBarItems(trailing: doneButton)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var seedIcon: some View {
        Image("seed.circle")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80)
    }
    
    var doneButton: some View {
        DoneButton() {
            isPresented = false
        }
    }
    
    func section<Content>(title: String, content: Content) -> some View where Content: View {
        NavigationLink(destination:
                        content
                        .navigationBarItems(trailing: doneButton)
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
