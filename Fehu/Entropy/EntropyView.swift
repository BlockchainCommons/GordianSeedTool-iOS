//
//  EntropyView.swift
//  Fehu
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI
import Interpolate

struct EntropyView<KeypadType>: View where KeypadType: View & Keypad {
    typealias Value = KeypadType.TokenType

    @Binding var isPresented: Bool
    @StateObject private var model: EntropyViewModel<KeypadType> = .init()
    let addSeed: (Seed) -> Void

    init(keypadType: KeypadType.Type, isPresented: Binding<Bool>, addSeed: @escaping (Seed) -> Void) {
        self._isPresented = isPresented
        self.addSeed = addSeed
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
            isPresented = false
        } label: {
            Text("Cancel")
                .bold()
        }
    }

    var doneButton: some View {
        Button {
            addSeed(model.seed)
            isPresented = false
        } label: {
            Text("Done")
                .bold()
        }
        .disabled(model.values.isEmpty)
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
                .foregroundColor(Color.green)
        }
    }

    var menuRow: some View {
        HStack {
            menu
            Spacer()
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
        KeypadType(model: model)
    }

    private func keypadButtonSize(for height: CGFloat) -> CGFloat {
        height.interpolate(from: (500, 600)).clamped.interpolate(to: (minButtonSize, maxButtonSize))
    }

    var progress: some View {
        VStack {
            ProgressView(value: model.entropyProgress)
                .accentColor(model.entropyColor)
            HStack {
                Text("Entropy: \(model.entropyBits, specifier: "%0.1f") bits")
                Spacer()
                if !model.values.isEmpty {
                    Text(EntropyStrength.categorize(model.entropyBits).description)
                        .foregroundColor(model.entropyColor)
                }
            }
            .font(.caption)
        }
        .padding([.top, .bottom], 5)
    }

    var body: some View {
        NavigationView {
            GeometryReader { proxy in
                VStack {
                    menuRow
                    display
                    progress
                    keypad
                }
                .padding()
                .navigationTitle(KeypadType.name)
                .navigationBarItems(leading: cancelButton, trailing: doneButton)
                .keypadButtonSize(keypadButtonSize(for: proxy.size.height))
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
