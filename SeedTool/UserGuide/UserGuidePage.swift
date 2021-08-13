//
//  UserGuidePage.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/5/21.
//

import SwiftUI

struct UserGuidePage: View {
    let chapter: Chapter
    
    var body: some View {
        ScrollView {
            VStack {
                chapter.header
                Spacer(minLength: 10)
                chapter.markdown
            }
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
    }
}

#if DEBUG

struct InfoPage_Previews: PreviewProvider {
    static var previews: some View {
        UserGuidePage(chapter: .licenseAndDisclaimer)
            .darkMode()
    }
}

#endif
