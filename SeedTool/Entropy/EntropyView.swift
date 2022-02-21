//
//  EntropyView.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/5/20.
//

import SwiftUI
import Interpolate
import WolfSwiftUI
import WolfBase

struct EntropyView<KeypadType>: View where KeypadType: View & Keypad {
    typealias Value = KeypadType.TokenType

    let addSeed: (ModelSeed) -> Void

    @Binding var isPresented: Bool
    @StateObject private var model: EntropyViewModel<KeypadType> = .init()
    @State private var isStrengthWarningPresented = false
    @State private var activityParams: ActivityParams?

    init(keypadType: KeypadType.Type, isPresented: Binding<Bool>, addSeed: @escaping (ModelSeed) -> Void) {
        self._isPresented = isPresented
        self.addSeed = addSeed
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
                .background(ActivityView(params: $activityParams))
                .copyConfirmation()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var cancelButton: some View {
        CancelButton($isPresented)
            .accessibility(label: Text("Cancel Import"))
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

    var doneButton: some View {
        DoneButton {
            if model.entropyStrength <= .weak {
                isStrengthWarningPresented = true
            } else {
                commit()
            }
        }
        .disabled(model.values.isEmpty)
    }

    var menu: some View {
        Menu {
            ShareMenuItem() {
                activityParams = ActivityParams(Value.string(from: model.values), name: "Entropy")
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
        .alert(isPresented: $isStrengthWarningPresented) { () -> Alert in
            Alert(title: .init("Weak Entropy"), message: .init("Seeds generated with this level of entropy may not offer good security."),
                  primaryButton: .cancel(),
                  secondaryButton: .destructive(Text("Continue")) {
                    commit()
                  }
            )
        }
    }

    private func commit() {
        addSeed(model.seed)
        isPresented = false
    }

    var keypad: some View {
        KeypadType(model: model)
    }

    private func keypadButtonSize(for height: CGFloat) -> CGFloat {
        height.interpolate(from: (500, 600)).clamped().interpolate(to: (minButtonSize, maxButtonSize))
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
}
