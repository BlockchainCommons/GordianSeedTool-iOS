//
//  UserGuideLink.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/27/21.
//

import SwiftUI
import WolfSwiftUI

struct UserGuideLink: View {
    let chapter: Chapter
    @Binding var isPresented: Bool
    @Binding var currentChapter: Chapter?
    
    init(isPresented: Binding<Bool>, chapter: Chapter, currentChapter: Binding<Chapter?>) {
        self._isPresented = isPresented
        self._currentChapter = currentChapter
        self.chapter = chapter
    }
    
    var body: some View {
        NavigationLink(
            destination: LazyView(UserGuidePage(chapter: chapter).navigationBarItems(trailing: DoneButton($isPresented))),
            tag: chapter,
            selection: $currentChapter)
        {
            Text(chapter.title)
        }
        .accessibility(label: Text(chapter.title))
    }
}
