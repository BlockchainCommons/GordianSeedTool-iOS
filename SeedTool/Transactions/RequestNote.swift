//
//  RequestNote.swift
//  SeedTool
//
//  Created by Wolf McNally on 3/7/22.
//

import SwiftUI
import BCApp

struct RequestNote: View {
    let note: String?
    
    var body: some View {
        if let note = note {
            VStack {
                Note(icon: Image.note, content:
                    Text("The sender of this request attached a note. You must decide whether to trust what it says; Seed Tool cannot verify its accuracy:"))
                Text(note)
                    .font(.system(.callout, design: .serif))
                    .padding(5)
                    .formSectionStyle()
            }
        }
    }
}
