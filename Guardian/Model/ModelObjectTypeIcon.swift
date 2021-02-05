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
        (type?.image ?? Image(systemName: "questionmark.circle"))
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}
