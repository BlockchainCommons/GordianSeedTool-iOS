//
//  FieldRandomTitleButton.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI
import WolfLorem
import LifeHash
import Combine

struct FieldRandomTitleButton: View {
    let seed: Seed
    @Binding var text: String
    @StateObject var lifeHashState: LifeHashState
    @StateObject var lifeHashNameGenerator: LifeHashNameGenerator

    init(seed: Seed, text: Binding<String>) {
        self.seed = seed
        _text = text
        let lifeHashState = LifeHashState(seed.fingerprint, version: .version2)
        _lifeHashState = .init(wrappedValue: lifeHashState)
        _lifeHashNameGenerator = .init(wrappedValue: LifeHashNameGenerator(lifeHashState: lifeHashState))
    }

    var body: some View {
        Button {
            self.text = lifeHashNameGenerator.next()
        } label: {
            Image(systemName: "die.face.3.fill")
                .foregroundColor(.secondary)
                .accessibility(label: Text("Random Name"))
        }
    }
}
