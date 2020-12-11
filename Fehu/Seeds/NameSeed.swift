//
//  NameSeed.swift
//  Fehu
//
//  Created by Wolf McNally on 12/10/20.
//

import SwiftUI

struct NameSeed: View {
    @ObservedObject var seed: Seed
    @Binding var isPresented: Bool
    let save: () -> Void

    var body: some View {
        NavigationView {
            VStack {
                Text("Name your new seed.")
                    .padding()
                SeedDetail(seed: seed)
            }
            .navigationBarItems(leading: cancelButton, trailing: saveButton)
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
            save()
            isPresented = false
        } label: {
            Text("Save")
        }
    }
}
