//
//  SeedSelector.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/26/21.
//

import SwiftUI
import WolfSwiftUI

struct SeedSelector: View {
    @Binding var isPresented: Bool
    let prompt: String
    let onSeedSelected: (ModelSeed) -> Void
    @EnvironmentObject var model: Model
    @State private var selectedSeed: ModelSeed?

    var body: some View {
        NavigationView {
            VStack {
                Text(prompt)
                    .font(.title)
                    .bold()
                List {
                    ForEach(model.seeds) { seed in
                        Item(seed: seed, selectedSeed: $selectedSeed)
                    }
                }
                .listStyle(InsetListStyle())
            }
            .navigationBarItems(leading: CancelButton($isPresented))
        }
        .navigationViewStyle(StackNavigationViewStyle())
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
        .environmentObject(model)
        .darkMode()
    }
}
#endif
