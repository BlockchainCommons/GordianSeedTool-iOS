//
//  ImportChildView.swift
//  Fehu
//
//  Created by Wolf McNally on 12/23/20.
//

import SwiftUI

struct ImportChildView<ModelType>: Importer where ModelType: ImportModel {
    @StateObject private var model: ModelType
    @Binding var seed: Seed?

    init(modelType: ModelType.Type, seed: Binding<Seed?>) {
        self._seed = seed
        self._model = StateObject(wrappedValue: ModelType())
    }
    
    var body: some View {
        VStack {
            inputArea
            outputArea
        }.onReceive(model.seedPublisher) { seed in
            withAnimation {
                self.seed = seed
            }
        }
    }

    var inputArea: some View {
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
        
        var body: some View {
            ImportChildView(modelType: ImportURModel.self, seed: $seed)
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
