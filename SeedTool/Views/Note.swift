//
//  Note.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/19/21.
//

import SwiftUI

struct Note<Icon, Content>: View where Icon: View, Content: View {
    let icon: Icon
    let content: Content
    
    var body: some View {
        HStack(alignment: .top) {
            icon
                .font(.title)
            content
                .fixedVertical()
                .font(.body)
            Spacer()
        }
    }
}

struct DeveloperFunctions<Content>: View where Content: View {
    let content: Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        Group {
            if isTakingSnapshot {
                EmptyView()
            } else {
                AppGroupBox("Developer Functions") {
                    Note(icon: Image(systemName: "ladybug.fill").foregroundColor(.red), content: content)
                        .accessibility(label: Text("Debug"))
                }
            }
        }
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
        Note(icon: Image(systemName: "info.circle.fill").foregroundColor(.blue), content: text)
            .accessibility(label: text)
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
        Note(icon: Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.yellowLightSafe), content: text)
            .accessibility(label: text)
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
        Note(icon: Image(systemName: "xmark.octagon.fill").foregroundColor(.red), content: text)
            .accessibility(label: text)
    }
}

struct Success: View {
    let text: Text

    init(_ text: Text) {
        self.text = text
    }
    
    init(_ string: String) {
        self.init(Text(string))
    }

    var body: some View {
        Note(icon: Image(systemName: "checkmark.diamond.fill").foregroundColor(.green), content: text)
            .accessibility(label: text)
    }
}

#if DEBUG

import WolfLorem

struct Note_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 30) {
            Info(Lorem.sentences(2))
            Caution(Lorem.sentences(2))
            Success(Lorem.sentences(2))
            Failure(Lorem.sentences(2))
            DeveloperFunctions {
                Text(Lorem.sentences(2))
            }
        }
        .padding()
    }
}

#endif
