//
//  ModelObjectTypeIcon.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI

struct ModelObjectTypeIcon: View {
    let type: ModelObjectType?

    var body: some View {
        (type?.icon ?? Image(systemName: "questionmark.circle").icon().eraseToAnyView())
    }
}

extension Image {
    func icon() -> some View {
        resizable()
            .aspectRatio(contentMode: .fit)
    }
}
