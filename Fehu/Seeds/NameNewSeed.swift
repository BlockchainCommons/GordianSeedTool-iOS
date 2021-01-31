//
//  NameNewSeed.swift
//  Fehu
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

    var body: some View {
        VStack {
            Text("Name this seed.")
                .padding()
            SeedDetail(seed: seed, saveWhenChanged: false, provideSuggestedName: !seed.hasName, isValid: $isValid)
        }
        .topBar(leading: cancelButton, trailing: saveButton)
        .onDisappear {
            if shouldSave {
                save()
            }
        }
        .copyConfirmation()
    }

    var cancelButton: some View {
        CancelButton {
            isPresented = false
        }
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
