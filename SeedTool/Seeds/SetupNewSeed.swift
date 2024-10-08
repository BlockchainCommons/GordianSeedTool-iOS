//
//  SetupNewSeed.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI
import WolfSwiftUI
import BCApp

struct SetupNewSeed: View {
    @ObservedObject var seed: ModelSeed
    @Binding var isPresented: Bool
    let save: () -> Void
    @State var shouldSave: Bool = false
    @State var isValid: Bool = false
    @Environment(Settings.self) private var settings
    @Environment(Model.self) private var model

    var body: some View {
        NavigationView {
            VStack {
                Info("You may change the name of this seed or enter notes before saving.")
                    .padding()
                SeedDetail(seed: seed, saveWhenChanged: false, provideSuggestedName: !seed.hasName, isValid: $isValid, selectionID: .constant(seed.id))
                    .environment(settings)
                    .environment(model)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CancelButton($isPresented)
                }
                ToolbarItem(placement: .confirmationAction) {
                    saveButton
                }
            }
        }
        .onDisappear {
            if shouldSave {
                save()
            }
        }
        .copyConfirmation()
    }

    var saveButton: some View {
        SaveButton {
            shouldSave = true
            isPresented = false
        }
    }
}

#if DEBUG

import WolfLorem

struct NameNewSeed_Previews: PreviewProvider {
    static let seed: ModelSeed = Lorem.seed()

    static var previews: some View {
        SetupNewSeed(seed: seed, isPresented: .constant(true), save: { })
            .environment(Settings(storage: MockSettingsStorage()))
            .environment(Lorem.model())
            .darkMode()
    }
}

#endif
