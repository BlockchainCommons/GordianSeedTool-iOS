//
//  EntryView.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI

struct EntryView<KeypadType>: View where KeypadType: View & Keypad {
    typealias Value = KeypadType.Value

    @Binding var isDisplayed: Bool
    @StateObject private var model: EntryViewModel<KeypadType> = .init()

    init(keypadType: KeypadType.Type, isDisplayed: Binding<Bool>) {
        self._isDisplayed = isDisplayed
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

    func ContextMenuButton() -> Button<HStack<TupleView<(Text, Image)>>> {
        return Button {
            print("Copy")
        } label: {
            HStack {
                Text("Copy")
                Image(systemName: "doc.on.doc")
            }
        }
    }

    var cancelButton: some View {
        Button {
            isDisplayed = false
        } label: {
            Text("Cancel").bold()
        }
        .keyboardShortcut(.escape)
    }

    var menu: some View {
        Menu {
            CopyMenuItem() {
                UIPasteboard.general.string = Value.string(from: model.values)
            }
            .disabled(model.isEmpty)

            PasteMenuItem() {
                guard let string = UIPasteboard.general.string else { return }
                guard let values = Value.values(from: string) else { return }
                model.values = values
            }
            .disabled(!model.canPaste)

            ClearMenuItem() {
                model.values.removeAll()
            }
            .disabled(model.isEmpty)
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }

    var display: some View {
        VStack(alignment: .leading) {
            ScrollView {
                ScrollViewReader { proxy in
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: Value.minimumWidth), spacing: 5)]) {
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
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.secondary, lineWidth: 4)
            )
        }
        .foregroundColor(.primary)
    }

    var keypad: some View {
        KeypadType(isEmpty: $model.isEmpty) {
            model.append($0)
        } removeLast: {
            model.removeLast()
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                display
                    .padding(.bottom, 10)
                keypad
            }
            .padding()
            .navigationTitle(KeypadType.name)
            .navigationBarItems(leading: cancelButton, trailing: menu)
            .foregroundColor(.green)
        }
    }
}
