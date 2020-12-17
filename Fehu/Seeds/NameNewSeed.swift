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

    var body: some View {
        VStack {
            Text("Name your new seed.")
                .padding()
            SeedDetail(seed: seed)
        }
        .topBar(leading: cancelButton, trailing: saveButton)
        .onDisappear {
            if shouldSave {
                save()
            }
        }
        .padding()
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

import WolfLorem

struct NameNewSeed_Previews: PreviewProvider {
    static let seed: Seed = Lorem.seed()

    static var previews: some View {
        NameNewSeed(seed: seed, isPresented: .constant(true), save: { })
            .preferredColorScheme(.dark)
    }
}
