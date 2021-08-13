//
//  UserGuideButton.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/27/21.
//

import SwiftUI

struct UserGuideButton: View {
    @State private var isPresented: Bool = false
    let openToChapter: Chapter?
    let showShortTitle: Bool
    
    init(openToChapter: Chapter? = nil, showShortTitle: Bool = false) {
        self.openToChapter = openToChapter
        self.showShortTitle = showShortTitle
    }
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            if showShortTitle,
               let chapter = openToChapter,
               let title = chapter.shortTitle
            {
                HStack(spacing: 5) {
                    Image(systemName: "info.circle")
                    Text(title)
                }
                .font(.caption)
            } else {
                Image(systemName: "info.circle")
            }
        }
        .sheet(isPresented: $isPresented) {
            UserGuide(isPresented: $isPresented, openToChapter: openToChapter)
        }
    }
}

#if DEBUG

struct UserGuideButton_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            UserGuideButton(openToChapter: nil)
            UserGuideButton(openToChapter: .aboutSeedTool)
            UserGuideButton(openToChapter: .whatIsALifehash)
        }
        .darkMode()
    }
}

#endif
