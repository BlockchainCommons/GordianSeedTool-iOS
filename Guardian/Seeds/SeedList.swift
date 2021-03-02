//
//  SeedList.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/9/20.
//

import SwiftUI
import LifeHash

struct SeedList: View {
    @EnvironmentObject var model: Model
    @State var isNewSeedPresented: Bool = false
    @State var isNameSeedPresented: Bool = false
    @State var newSeed: Seed?
    @State var isSeedDetailValid: Bool = true

    var body: some View {
        VStack(spacing: 0) {
            if model.seeds.isEmpty {
                (Text("Tap the ") + Text(Image(systemName: "plus")) + Text(" button above to add a seed."))
                    .padding()
            }

            List {
                ForEach(model.seeds) { seed in
                    Item(seed: seed, isSeedDetailValid: $isSeedDetailValid)
                }
                .onMove { indices, newOffset in
                    model.seeds.move(fromOffsets: indices, toOffset: newOffset)
                }
                .onConfirmedDelete(
                    title: { indexSet in
                        "Delete seed “\(model.seeds[indexSet.first!].name)”?"
                    },
                    message: "This cannot be undone.",
                    action: { indexSet in
                        model.seeds.remove(atOffsets: indexSet)
                    }
                )
            }
        }
        .navigationTitle("Seeds")
        .navigationBarItems(leading: addButton, trailing: trailingNavigationBarItems)
        .onChange(of: newSeed) { value in
            if newSeed != nil {
                isNameSeedPresented = true
            }
        }
        .sheet(isPresented: $isNameSeedPresented) {
            VStack {
                if let newSeed = newSeed {
                    NameNewSeed(seed: newSeed, isPresented: $isNameSeedPresented) {
                        withAnimation {
                            model.seeds.insert(newSeed, at: 0)
                        }
                    }
                }
            }
        }
        .onChange(of: isNewSeedPresented) { value in
            //print("isNewSeedPresented: \(isNewSeedPresented)")
        }
        .onChange(of: isNameSeedPresented) { value in
            //print("isNameSeedPresented: \(isNameSeedPresented)")
        }
        .disabled(!isSeedDetailValid)
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

    var addButton: some View {
        Button {
            isNewSeedPresented = true
        } label: {
            Image(systemName: "plus")
                .font(.title)
                .padding([.top, .bottom, .trailing], 10)
                .accessibility(label: Text("Add Seed"))
        }
        .sheet(isPresented: $isNewSeedPresented) {
            NewSeed(isPresented: $isNewSeedPresented) { seed in
                newSeed = seed
            }
        }
    }

    struct Item: View {
        @ObservedObject var seed: Seed
        @Binding var isSeedDetailValid: Bool
        @StateObject var lifeHashState: LifeHashState

        init(seed: Seed, isSeedDetailValid: Binding<Bool>) {
            self.seed = seed
            self._isSeedDetailValid = isSeedDetailValid
            _lifeHashState = .init(wrappedValue: LifeHashState(input: seed, version: .version2))
        }

        var body: some View {
            NavigationLink(destination: SeedDetail(seed: seed, saveWhenChanged: true, isValid: $isSeedDetailValid)) {
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
