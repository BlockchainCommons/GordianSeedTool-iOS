//
//  ContentView.swift
//  Fehu
//
//  Created by Wolf McNally on 12/4/20.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var model: EntryViewModel<PlayingCardKeypad> = .init()

    var body: some View {
        let keypad = PlayingCardKeypad(isEmpty: $model.isEmpty) {
            model.append(value: $0)
        } removeLast: {
            model.removeLast()
        }
        return EntryView(keypad: keypad, model: model)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
}
