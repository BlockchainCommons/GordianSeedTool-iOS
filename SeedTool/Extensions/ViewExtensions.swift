//
//  ViewExtensions.swift
//  SeedTool
//
//  Created by Wolf McNally on 10/8/21.
//

import SwiftUI

extension View {
    func encircle(color: Color) -> some View {
        padding(2)
            .background(
            Circle().fill(color)
        )
    }
}
