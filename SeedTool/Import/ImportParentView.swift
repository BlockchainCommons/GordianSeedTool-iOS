//
//  ImportParentView.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/22/20.
//

import SwiftUI
import WolfSwiftUI

struct ImportParentView<ImportChildViewType>: View where ImportChildViewType: Importer {
    let importChildViewType: ImportChildViewType.Type
    @Binding var isPresented: Bool
    let shouldScan: Bool
    @State private var seed: ModelSeed?
    @StateObject var model: ImportChildViewType.ModelType = ImportChildViewType.ModelType()
    let addSeed: (ModelSeed) -> Void
    
    var body: some View {
        NavigationView {
            ImportChildViewType(model: model, seed: $seed, shouldScan: shouldScan)
                .padding()
                .navigationTitle("Import \(model.name)")
                .navigationBarItems(leading: cancelButton, trailing: doneButton)
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
        .keyboardShortcut(.cancelAction)
        .accessibility(label: Text("Cancel Import"))
    }

    var doneButton: some View {
        DoneButton {
            isPresented = false
        }
        .disabled(seed == nil)
    }
}
