//
//  ImportChildView.swift
//  Fehu
//
//  Created by Wolf McNally on 12/23/20.
//

import SwiftUI

struct ImportChildView<ModelType>: Importer where ModelType: ImportModel {
    @ObservedObject private var model: ModelType
    @Binding var seed: Seed?
    let shouldScan: Bool

    init(model: ModelType, seed: Binding<Seed?>, shouldScan: Bool) {
        self._seed = seed
        self.model = model
        self.shouldScan = shouldScan
    }
    
    var body: some View {
        VStack {
            if shouldScan {
                scanInputArea
            } else {
                textInputArea
            }
            outputArea
        }.onReceive(model.seedPublisher) { seed in
            withAnimation {
                self.seed = seed
            }
        }
    }

    var textInputArea: some View {
        VStack {
            Text("Paste your \(model.typeName) below.")
            TextEditor(text: $model.text)
                .autocapitalization(.none)
                .keyboardType(.URL)
                .fieldStyle()
                .validation(model.validator)
                .frame(minHeight: 60)
        }
    }
    
    var scanInputArea: some View {
        Rectangle()
            .fill(Color.red)
    }

    var outputArea: some View {
        // Ensure that each re-creation of this view has a unqiue identity
        // based on the seed
        ForEach([seed].compactMap { $0 }) { seed in
            ModelObjectIdentity(modelObject: seed)
        }

        // This doesn't work if `seed` changes from one non-nil
        // value to another non-nil value in a single tick.
        //    if seed == nil {
        //        return EmptyView()
        //            .eraseToAnyView()
        //    } else {
        //        return ModelObjectIdentity(modelObject: seed!)
        //            .eraseToAnyView()
        //    }
    }
}

#if DEBUG

struct ImportChildView_Previews: PreviewProvider {
    struct ImportChildViewWrapper: View {
        @State var seed: Seed?
        @StateObject var model: ImportURModel = ImportURModel()
        
        var body: some View {
            ImportChildView(model: model, seed: $seed, shouldScan: false)
        }
    }
    
    static var previews: some View {
        NavigationView {
            ImportChildViewWrapper()
                .padding()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
    }
}

#endif
