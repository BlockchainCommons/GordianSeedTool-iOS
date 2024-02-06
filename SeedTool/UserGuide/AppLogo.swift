//
//  AppLogo.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/6/21.
//

import SwiftUI

struct AppLogo: View {
    var body: some View {
        HStack(spacing: 10) {
            Image.seed
                .font(Font.system(size: 48).bold())
                .foregroundColor(.accentColor)
            VStack(alignment: .leading) {
                Text("Gordian")
                Text("Seed Tool")
            }
            .font(Font.system(size: 24).bold())
        }
    }
}
