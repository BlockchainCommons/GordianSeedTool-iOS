//
//  SeedSelector.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/26/21.
//

import SwiftUI
import WolfSwiftUI
import BCApp

struct SeedSelector: View {
    @Binding var isPresented: Bool
    let prompt: String
    let onSeedSelected: (ModelSeed) -> Void
    @EnvironmentObject var model: Model
    @State private var selectedSeed: ModelSeed?
    
    var body: some View {
        NavigationView {
            List {
                Text(prompt)
                    .font(.title3)
                    .bold()
                    .listRowSeparator(.hidden)

                ForEach(model.seeds) { seed in
                    Item(seed: seed, selectedSeed: $selectedSeed)
                        .listRowSeparator(.hidden)
                }
            }
            .listRowInsets(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            .listStyle(.plain)
            .navigationTitle("Select Seed")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CancelButton($isPresented)
                }
            }
        }
        .padding()
        .navigationViewStyle(.stack)
        .onChange(of: selectedSeed) { value in
            isPresented = false
        }
        .onDisappear {
            if let selectedSeed = selectedSeed {
                onSeedSelected(selectedSeed)
            }
        }
    }
    
    struct Item: View {
        let seed: ModelSeed
        @Binding var selectedSeed: ModelSeed?
        
        var body: some View {
            Button {
                selectedSeed = seed
            } label: {
                ObjectIdentityBlock(model: .constant(seed), allowLongPressCopy: false)
                    .frame(height: 64)
                    .padding(10)
            }
            .formSectionStyle()
        }
    }
}

#if DEBUG

import WolfLorem

struct SeedSelector_Previews: PreviewProvider {
    static let model: Model = Lorem.model()
    
    static var previews: some View {
        SeedSelector(isPresented: .constant(true), prompt: "Select a seed.") { seed in
            
        }
        .frame(maxWidth: 600)
        .environmentObject(model)
        .darkMode()
    }
}
#endif
