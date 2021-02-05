//
//  MenuLabel.swift
//  Guardian
//
//  Created by Wolf McNally on 1/23/21.
//

import SwiftUI

struct MenuLabel: View {
    let text: Text
    let icon: Image
    
    init(_ text: Text, icon: Image) {
        self.text = text
        self.icon = icon
    }
    
    init(_ string: String, icon: Image) {
        self.init(Text(string), icon: icon)
    }
    
    var body: some View {
        Label(title: { text }, icon: { icon })
    }
}
