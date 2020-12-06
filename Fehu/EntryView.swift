//
//  EntryView.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI

struct EntryView<KeypadType>: View where KeypadType: View & Keypad {
    typealias Value = KeypadType.Value

    private var keypad: KeypadType
    @ObservedObject private var model: EntryViewModel<KeypadType>

    init(keypad: KeypadType, model: EntryViewModel<KeypadType>) {
        self.keypad = keypad
        self.model = model
    }

    struct Row: Identifiable {
        let id: Int
        let values: [Value]
    }

    private var valueRows: [Row] {
        let valueChunks = model.values.chunked(into: 5)
        return valueChunks.enumerated().map {
            Row(id: $0, values: $1)
        }
    }

    private var display: some View {
        let gridItemLayout = [GridItem(.adaptive(minimum: Value.minimumWidth), spacing: 5)]
        return ScrollView {
            ScrollViewReader { proxy in
                LazyVGrid(columns: gridItemLayout) {
                    ForEach(model.values) { value in
                        value.view
                    }
                }
                .onChange(of: model.values) { _ in
                    if let id = model.values.last?.id {
                        proxy.scrollTo(id, anchor: .bottom)
                    }
                }
            }
        }
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary, lineWidth: 4))
        .frame(idealWidth: 300)
    }

    var body: some View {
        VStack {
            display
                .padding(.bottom, 10)
            keypad
        }
        .padding()
    }
}
