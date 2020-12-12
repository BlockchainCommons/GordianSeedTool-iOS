//
//  NameNewSeed.swift
//  Fehu
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI

struct NameNewSeed: View {
    @ObservedObject var seed: Seed
    @Binding var isPresented: Bool
    let save: () -> Void
    @State var shouldSave: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Text("Name your new seed.")
                    .padding()
                SeedDetail(seed: seed)
            }
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
        .onDisappear {
            if shouldSave {
                save()
            }
        }
    }

    var cancelButton: some View {
        Button {
            isPresented = false
        } label: {
            Text("Cancel")
        }
    }

    var saveButton: some View {
        Button {
            shouldSave = true
            isPresented = false
        } label: {
            Text("Save")
        }
    }
}
