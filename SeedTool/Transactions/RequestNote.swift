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
            VStack(spacing: 20) {
                Note(icon: Image.note, content:
                    Text("The sender of this request attached a note. You must decide whether to trust what it says; Seed Tool cannot verify its accuracy:"))
                HStack {
                    Text(note)
                    Spacer()
                }
                .font(.system(.callout, design: .serif))
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.yellow.opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.yellow, lineWidth: 2)
                )
            }
        }
    }
}

#if DEBUG

import WolfLorem

struct RequestNote_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            RequestNote(note: Lorem.sentences(4))
                .previewDisplayName("Long")
            RequestNote(note: Lorem.words(4))
                .previewDisplayName("Short")
        }
        .padding()
        .darkMode()
    }
}

#endif
