//
//  Note.swift
//  Guardian
//
//  Created by Wolf McNally on 2/19/21.
//

import SwiftUI

struct Note: View {
    let icon: Image
    let iconColor: Color
    let text: Text
    
    var body: some View {
        HStack(alignment: .top) {
            icon
                .font(.title)
                .foregroundColor(iconColor)
            text
                .fixedVertical()
            Spacer()
        }
        .frame(width: .infinity)
    }
}

struct Info: View {
    let text: Text
    
    init(_ text: Text) {
        self.text = text
    }
    
    init(_ string: String) {
        self.init(Text(string))
    }

    var body: some View {
        Note(icon: Image(systemName: "info.circle.fill"), iconColor: .blue, text: text)
    }
}

struct Caution: View {
    let text: Text

    init(_ text: Text) {
        self.text = text
    }
    
    init(_ string: String) {
        self.init(Text(string))
    }

    var body: some View {
        Note(icon: Image(systemName: "exclamationmark.triangle.fill"), iconColor: .yellowLightSafe, text: text)
    }
}

struct Failure: View {
    let text: Text

    init(_ text: Text) {
        self.text = text
    }
    
    init(_ string: String) {
        self.init(Text(string))
    }

    var body: some View {
        Note(icon: Image(systemName: "xmark.octagon.fill"), iconColor: .red, text: text)
    }
}

#if DEBUG

import WolfLorem

struct Note_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            Info(Lorem.sentences(2))
            Caution(Lorem.sentences(2))
            Failure(Lorem.sentences(2))
        }
        .padding()
    }
}

#endif
