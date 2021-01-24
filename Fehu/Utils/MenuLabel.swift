//
//  MenuLabel.swift
//  Guardian
//
//  Created by Wolf McNally on 1/23/21.
//

import SwiftUI

struct MenuLabel: View {
    let title: String
    let icon: Image
    
    var body: some View {
        Label(title: { Text(title) }, icon: { icon })
    }
}
