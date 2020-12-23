//
//  ImportView.swift
//  Fehu
//
//  Created by Wolf McNally on 12/22/20.
//

import SwiftUI
import WolfSwiftUI

struct ImportView<ImportType>: View where ImportType: View & Importer {
    let importType: ImportType.Type
    @Binding var isPresented: Bool
    @State private var seed: Seed?
    let addSeed: (Seed) -> Void
    
    var body: some View {
        NavigationView {
            ImportType(seed: $seed)
                .padding()
                .navigationTitle("Import")
                .navigationBarItems(leading: cancelButton, trailing: saveButton)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onDisappear {
            if let seed = seed {
                addSeed(seed)
            }
        }
    }

    var cancelButton: some View {
        CancelButton {
            seed = nil
            isPresented = false
        }
    }

    var saveButton: some View {
        SaveButton {
            isPresented = false
        }
        .disabled(seed == nil)
    }
}
