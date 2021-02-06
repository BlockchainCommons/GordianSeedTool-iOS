//
//  AppLogo.swift
//  Guardian
//
//  Created by Wolf McNally on 2/6/21.
//

import SwiftUI

struct AppLogo: View {
    var body: some View {
        HStack(spacing: 10) {
            Image("seed.circle")
                .font(Font.system(size: 48).bold())
            VStack(alignment: .leading) {
                Text("Gordian")
                Text("Guardian")
            }
            .font(Font.system(size: 24).bold())
        }
    }
}
