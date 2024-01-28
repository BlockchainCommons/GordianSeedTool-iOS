//
//  ImportChildView.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/23/20.
//

import SwiftUI
import BCApp
import WolfBase

struct ImportChildView<ModelType>: Importer where ModelType: ImportModel {
    @ObservedObject private var model: ModelType
    @Binding var seed: ModelSeed?
    @State var guidance: AttributedString?

    init(model: ModelType, seed: Binding<ModelSeed?>) {
        self._seed = seed
        self.model = model
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            textInputArea
            outputArea
            Spacer()
        }.onReceive(model.seedPublisher) { seed in
            withAnimation {
                self.seed = seed
            }
        }.onReceive(model.guidancePublisher) { guidance in
            withAnimation {
                self.guidance = guidance
            }
        }
    }

    var textInputArea: some View {
        VStack {
            Text(markdown: "Type or paste your \(model.typeName) below.")
            TextEditor(text: $model.text)
                .autocapitalization(.none)
                .keyboardType(.asciiCapable)
                .autocorrectionDisabled()
                .formSectionStyle()
                .validation(model.validator, guidancePublisher: model.guidancePublisher)
                .frame(minHeight: 60)
        }
    }

    var outputArea: some View {
        // Ensure that each re-creation of this view has a unqiue identity
        // based on the seed
        ForEach([seed].compactMap { $0 }) { seed in
            ObjectIdentityBlock(model: .constant(seed))
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
        @State var seed: ModelSeed?
        @StateObject var model: ImportSeedModel = ImportSeedModel()
        
        var body: some View {
            ImportChildView(model: model, seed: $seed)
        }
    }
    
    static var previews: some View {
        NavigationView {
            ImportChildViewWrapper()
                .padding()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .darkMode()
    }
}

#endif
