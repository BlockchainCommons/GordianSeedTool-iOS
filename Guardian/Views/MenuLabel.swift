//
//  MenuLabel.swift
//  Guardian
//
//  Created by Wolf McNally on 1/23/21.
//

import SwiftUI

struct MenuLabel<Content>: View where Content: View {
    let content: Content
    
    var body: some View {
        content
            .font(Font.system(.body))
    }
}

extension MenuLabel where Content == Label<Text, AnyView> {
    init(_ text: Text, icon: Image) {
        let t: Text = text
        let i: AnyView = icon.eraseToAnyView()//.resizable().aspectRatio(contentMode: .fit).eraseToAnyView()
        let label: Label<Text, AnyView> = Label( title: { t } , icon: { i } )
        self.init(content: label)
    }

    init(_ string: String, icon: Image) {
        self.init(Text(string), icon: icon)
    }
}

//extension MenuLabel where Content ==
//    init(_ string: String, icon: Image) {
//        self.init(Text(string), icon: icon)
//    }
//}
