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
        NavigationStack {
            List {
                Text(prompt)
                    .font(.title3)
                    .bold()
                    .listRowInsets(.init(top: rowMargins, leading: 30, bottom: rowMargins, trailing: 0))
                ForEach(model.seeds) { seed in
                    Item(seed: seed, selectedSeed: $selectedSeed)
                        .listRowSeparator(.hidden)
                }
                .listRowInsets(.init(top: rowMargins, leading: 20, bottom: rowMargins, trailing: 20))
            }
            .listStyle(.plain)
            .listRowSpacing(0)
            .navigationTitle("Select Seed")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CancelButton($isPresented)
                }
            }
        }
        .padding()
        .onChange(of: selectedSeed) {
            isPresented = false
        }
        .onDisappear {
            if let selectedSeed = selectedSeed {
                onSeedSelected(selectedSeed)
            }
        }
    }
    
    var rowMargins: Double {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return 5
        case .pad:
            return 10
        case .mac:
            return 20
        default:
            return 10
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
                    .frame(height: 100)
                    .fixedVertical()
                    .padding(5)
            }
            .formSectionStyle()
        }
    }
}

#if DEBUG

import WolfLorem

struct SeedSelector_Previews: PreviewProvider {
    static let model: Model = Lorem.model(count: 30)
    
    static var previews: some View {
        SeedSelector(isPresented: .constant(true), prompt: "Select a seed.") { seed in
            
        }
        .frame(maxWidth: 600)
        .environmentObject(model)
        .darkMode()
    }
}
#endif
