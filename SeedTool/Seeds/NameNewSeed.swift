//
//  NameNewSeed.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI
import WolfSwiftUI

struct NameNewSeed: View {
    @ObservedObject var seed: Seed
    @Binding var isPresented: Bool
    let save: () -> Void
    @State var shouldSave: Bool = false
    @State var isValid: Bool = false
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var model: Model

    var body: some View {
        VStack {
            Text("Name this seed.")
                .padding()
            SeedDetail(seed: seed, saveWhenChanged: false, provideSuggestedName: !seed.hasName, isValid: $isValid, selectionID: .constant(seed.id))
                .environmentObject(settings)
                .environmentObject(model)
        }
        .topBar(leading: CancelButton($isPresented), trailing: saveButton)
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
    static let seed: Seed = Lorem.seed()

    static var previews: some View {
        NameNewSeed(seed: seed, isPresented: .constant(true), save: { })
            .darkMode()
    }
}

#endif
