//
//  InfoPage.swift
//  Guardian
//
//  Created by Wolf McNally on 2/5/21.
//

import SwiftUI
import MarkdownUI
import WolfSwiftUI

struct InfoLink<Header>: View where Header: View {
    @Binding var isPresented: Bool
    let chapter: MarkdownChapter
    let header: Header?
    
    init(isPresented: Binding<Bool>, name: String, header: Header? = nil) {
        self._isPresented = isPresented
        self.chapter = MarkdownChapter(name: name)
        self.header = header
    }
    
    var body: some View {
        NavigationLink(destination:
                        InfoPage(chapter: chapter, header: header)
                        .navigationBarItems(trailing: doneButton)
        ) {
            Text(chapter.title ?? "Untitled")
        }
    }
    
    var doneButton: some View {
        DoneButton() {
            isPresented = false
        }
    }
}

extension InfoLink where Header == EmptyView {
    init(isPresented: Binding<Bool>, name: String) {
        self._isPresented = isPresented
        self.chapter = MarkdownChapter(name: name)
        self.header = nil
    }
}

struct InfoPage<Header>: View where Header: View {
    let chapter: MarkdownChapter
    let header: Header?
    
    init(chapter: MarkdownChapter, header: Header? = nil) {
        self.chapter = chapter
        self.header = header
    }
    
    init(name: String, header: Header? = nil) {
        self.init(chapter: MarkdownChapter(name: name), header: header)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                header
                Spacer(minLength: 10)
                Markdown(Document(chapter.body))
//                Spacer()
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension InfoPage where Header == EmptyView {
    init(chapter: MarkdownChapter) {
        self.chapter = chapter
        self.header = nil
    }
    
    init(name: String) {
        self.init(chapter: MarkdownChapter(name: name))
    }
}

#if DEBUG

struct InfoPage_Previews: PreviewProvider {
    static var previews: some View {
        InfoPage(name: "about-blockchain-commons", header: BlockchainCommonsLogo())
            .darkMode()
    }
}

#endif
