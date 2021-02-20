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
    }
}

extension MenuLabel where Content == Label<Text, Image> {
    init(_ text: Text, icon: Image) {
        self.init(content: Label(title: { text }, icon: { icon }))
    }

    init(_ string: String, icon: Image) {
        self.init(Text(string), icon: icon)
    }
}
