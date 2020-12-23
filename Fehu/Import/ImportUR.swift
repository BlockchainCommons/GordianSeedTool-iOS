//
//  ImportUR.swift
//  Fehu
//
//  Created by Wolf McNally on 12/19/20.
//

import SwiftUI
import WolfSwiftUI
import Combine
import URKit
import CryptoBase
import LifeHash

extension Publisher where Output == String, Failure == Never {
    func validateUR(seedPublisher: PassthroughSubject<Seed?, Never>) -> ValidationPublisher {
        map { string in
            do {
                let seed = try Seed(urString: string)
                seedPublisher.send(seed)
                return .valid
            } catch {
                seedPublisher.send(nil)
                return .invalid(error.localizedDescription)
            }
        }
        .dropFirst()
        .eraseToAnyPublisher()
    }
}

final class ImportURModel: ImportModel {
    required init() {
        super.init()
        validator = fieldValidator
            .validateUR(seedPublisher: seedPublisher)
    }
}

struct Import<ModelType>: View, ImportChildView where ModelType: ImportModel {
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
            Text("Paste your ur:crypto-seed below.")
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

struct Import_Previews: PreviewProvider {
    struct ImportURTest: View {
        @State var seed: Seed?
        
        var body: some View {
            Import(modelType: ImportURModel.self, seed: $seed)
        }
    }
    
    static var previews: some View {
        NavigationView {
            ImportURTest()
                .padding()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
    }
}

