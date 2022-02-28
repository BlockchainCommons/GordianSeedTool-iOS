//
//  ScanButton.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/23/22.
//

import SwiftUI

struct ScanButton: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image.scan
        }
        .font(.title)
        .padding([.top, .bottom, .trailing], 10)
        .accessibility(label: Text("Scan"))
    }
}
