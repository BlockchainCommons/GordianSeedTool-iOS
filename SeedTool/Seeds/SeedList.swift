//
//  SeedList.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/9/20.
//

import SwiftUI
import WolfBase
import BCApp
import Observation

struct SeedList: View {
    @Environment(Model.self) private var model
    @Environment(Settings.self) private var settings
    @State private var isNameSeedPresented: Bool = false
    @State private var newSeed: ModelSeed?
    @State private var isSeedDetailValid: Bool = true
    @State private var selectionID: UUID? = nil
    @State private var editMode: EditMode = .inactive

//    @State var editMode: EditMode = .inactive
    var undoStack: UndoStack
    
    @ViewBuilder
    var list: some View {
        if model.seeds.isEmpty {
            VStack {
                Spacer()
                    .frame(height: 20)
                Text("Tap the ") + Text(Image.add) + Text(" button above to add a ") + Text(Image.seed) + Text(" seed.")
                Spacer()
            }
            .padding()
        } else {
            List {
                ForEach(model.seeds) { seed in
                    Item(seed: seed, isSeedDetailValid: $isSeedDetailValid, selectionID: $selectionID)
                }
                .onMove { indices, newOffset in
                    undoStack.invalidate()
                    model.moveSeed(fromOffsets: indices, toOffset: newOffset)
                }
                .onDelete { indexSet in
                    let index = indexSet.first!
                    let seed = model.seeds[index]

                    seed.isDirty = true
                    model.removeSeed(seed)

                    undoStack.push {
                        withAnimation {
                            model.removeSeed(seed)
                        }
                    } undo: {
                        withAnimation {
                            model.insertSeed(seed, at: index)
                        }
                    }
                }
            }
        }
    }

    var body: some View {
        list
            .listStyle(.sidebar)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    undoButtons
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    addButton
                    EditButton()
                        .padding(10)
                        .accessibility(label: Text("Edit Seeds"))
                }
            }
        .navigationTitle("Seeds")
        .onChange(of: model.seeds) {
            let seeds = model.seeds
            guard let selectionID = selectionID else { return }
            if seeds.first(where: {$0.id == selectionID}) == nil {
                self.selectionID = nil
            }
        }
        .onChange(of: newSeed) {
            if newSeed != nil {
                isNameSeedPresented = true
            }
        }
        .sheet(isPresented: $isNameSeedPresented) {
            VStack {
                if let newSeed = newSeed {
                    SetupNewSeed(seed: newSeed, isPresented: $isNameSeedPresented) {
                        withAnimation {
                            undoStack.invalidate()
                            model.insertSeed(newSeed, at: 0)
                        }
                    }
                    .environment(model)
                    .environment(settings)
                }
            }
        }
        .disabled(!isSeedDetailValid)
        .onDisappear {
            undoStack.invalidate()
        }
        .animation(nil, value: editMode)
        .environment(\.editMode, $editMode)
    }

    var undoButtons: some View {
        HStack(spacing: 5) {
            Button {
                undoStack.undo()
            } label: {
                Label("Undo", systemImage: "arrow.uturn.backward.circle")
            }
            .opacity(undoStack.canUndo ? 1 : 0)
    
            Button {
                undoStack.redo()
            } label: {
                Label("Redo", systemImage: "arrow.uturn.forward.circle")
            }
            .opacity(undoStack.canRedo ? 1 : 0)
        }
    }

    var addButton: some View {
        AddSeedButton { seed in
            newSeed = seed
        }
        .accessibility(label: Text("Add Seed"))
        .opacity(editMode.isEditing ? 0 : 1)
    }

    struct Item: View {
        @ObservedObject var seed: ModelSeed
        @Binding var isSeedDetailValid: Bool
        @Binding var selectionID: UUID?
        @State var lifeHashState: LifeHashState
        @Environment(\.editMode) var editMode

        init(seed: ModelSeed, isSeedDetailValid: Binding<Bool>, selectionID: Binding<UUID?>) {
            self.seed = seed
            self._isSeedDetailValid = isSeedDetailValid
            self._selectionID = selectionID
            _lifeHashState = .init(wrappedValue: LifeHashState(input: seed, version: .version2))
        }
        
        var isEditing: Bool {
            editMode?.wrappedValue.isEditing ?? false
        }

        var body: some View {
            if isEditing {
                label(seed: seed)
            } else {
                NavigationLink(destination: SeedDetail(seed: seed, saveWhenChanged: true, isValid: $isSeedDetailValid, selectionID: $selectionID), tag: seed.id, selection: $selectionID) {
                    label(seed: seed)
                }
                .accessibility(label: Text("Seed: \(seed.name)"))
            }
        }
        
        func label(seed: ModelSeed) -> some View {
            VStack {
#if targetEnvironment(macCatalyst)
                Spacer().frame(height: 10)
#endif
                ObjectIdentityBlock(model: .constant(seed), allowLongPressCopy: false)
                    .frame(height: 100)
                
#if targetEnvironment(macCatalyst)
                Spacer().frame(height: 10)
                Divider()
#endif
            }
        }
    }
}

#if DEBUG

import WolfLorem

struct SeedList_Previews: PreviewProvider {
    static let model: Model = Lorem.model()
    
    static var previews: some View {
        NavigationView {
            SeedList(undoStack: UndoStack())
        }
        .environment(model)
        .darkMode()
    }
}

#endif
