//
//  SeedList.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/9/20.
//

import SwiftUI
import LifeHash

struct SeedList: View {
    @EnvironmentObject var model: Model
    @EnvironmentObject var settings: Settings
    @State var isNameSeedPresented: Bool = false
    @State var newSeed: ModelSeed?
    @State var isSeedDetailValid: Bool = true
    @State var selectionID: UUID? = nil
//    @State var editMode: EditMode = .inactive
    @StateObject var undoStack = UndoStack()

    var body: some View {
        VStack(spacing: 0) {
            if model.seeds.isEmpty {
                (Text("Tap the ") + Text(Image(systemName: "plus")) + Text(" button above to add a seed."))
                    .padding()
            }

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
        .navigationTitle("Seeds")
        .navigationBarItems(leading: leadingNavigationBarItems, trailing: trailingNavigationBarItems)
        .onReceive(model.$seeds) { seeds in
            guard let selectionID = selectionID else { return }
            if seeds.first(where: {$0.id == selectionID}) == nil {
                self.selectionID = nil
            }
        }
        .onChange(of: selectionID) { value in
            //print("selectionID: \(String(describing: value))")
        }
        .onChange(of: newSeed) { value in
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
                    .environmentObject(model)
                    .environmentObject(settings)
                }
            }
        }
        .onChange(of: isNameSeedPresented) { value in
            //print("isNameSeedPresented: \(isNameSeedPresented)")
        }
//        .onChange(of: editMode) { mode in
//            //print("Edit mode: \(mode)")
//            if mode == .active {
//                selectionID = nil
//            }
//        }
        .disabled(!isSeedDetailValid)
        .onDisappear {
            undoStack.invalidate()
        }
//        .environment(\.editMode, $editMode)
    }
    
    var leadingNavigationBarItems: some View {
        HStack {
            addButton
            undoButtons
        }
    }

    var trailingNavigationBarItems: some View {
        Group {
            if model.seeds.isEmpty {
                EmptyView()
            } else {
                EditButton()
                    .padding([.top, .bottom, .leading], 10)
                    .accessibility(label: Text("Edit Seeds"))
            }
        }
    }
    
    var undoButtons: some View {
        HStack(spacing: 20) {
            Button {
                undoStack.undo()
            } label: {
                Label("Undo", systemImage: "arrow.uturn.backward.circle")
            }
//            .disabled(!undoStack.canUndo)
            .opacity(undoStack.canUndo ? 1 : 0)
    
            Button {
                undoStack.redo()
            } label: {
                Label("Redo", systemImage: "arrow.uturn.forward.circle")
            }
//            .disabled(!undoStack.canRedo)
            .opacity(undoStack.canRedo ? 1 : 0)
        }
    }

    var addButton: some View {
        AddSeedButton { seed in
            newSeed = seed
        }
        .font(.title)
        .padding([.top, .bottom, .trailing], 10)
        .accessibility(label: Text("Add Seed"))
    }

    struct Item: View {
        @ObservedObject var seed: ModelSeed
        @Binding var isSeedDetailValid: Bool
        @Binding var selectionID: UUID?
        @StateObject var lifeHashState: LifeHashState

        init(seed: ModelSeed, isSeedDetailValid: Binding<Bool>, selectionID: Binding<UUID?>) {
            self.seed = seed
            self._isSeedDetailValid = isSeedDetailValid
            self._selectionID = selectionID
            _lifeHashState = .init(wrappedValue: LifeHashState(input: seed, version: .version2))
        }

        var body: some View {
            NavigationLink(destination: SeedDetail(seed: seed, saveWhenChanged: true, isValid: $isSeedDetailValid, selectionID: $selectionID), tag: seed.id, selection: $selectionID) {
                ModelObjectIdentity(model: .constant(seed), allowLongPressCopy: false)
                    .frame(height: 64)
            }
            .accessibility(label: Text("Seed: \(seed.name)"))
        }
    }
}

#if DEBUG

import WolfLorem

struct SeedList_Previews: PreviewProvider {
    static let model: Model = Lorem.model()

    static var previews: some View {
        NavigationView {
            SeedList()
        }
        .environmentObject(model)
        .darkMode()
    }
}

#endif
