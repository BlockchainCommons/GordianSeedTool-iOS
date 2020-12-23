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

final class ImportURModel: ObservableObject {
    @Published var text: String = ""
    @Published var isValid: Bool = false
    let seedPublisher: PassthroughSubject<Seed?, Never> = .init()
    
    lazy var validator: ValidationPublisher = {
        $text
            .debounceField()
            .trimWhitespace()
            .validateUR(seedPublisher: seedPublisher)
    }()
}

struct ImportUR: View, Importer {
    @Binding var seed: Seed?
    @StateObject private var model: ImportURModel = ImportURModel()
    
    static private let placeholderSeed = Seed(id: UUID(), name: "Untitled", data: "Untitled".data(using: .utf8)!)

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
    
//    var seeds: [Seed] {
//        return seed == nil ? [] : [seed!]
//    }

    var outputArea: some View {
        // Ensure that each re-creation of this view has a unqiue identity
        // based on the seed
        ForEach([seed].compactMap { $0 }) { seed in
            ModelObjectIdentity(modelObject: seed)
        }

        // This doesn't work.
//        if seed == nil {
//            return EmptyView()
//                .eraseToAnyView()
//        } else {
//            return ModelObjectIdentity(modelObject: seed!)
//                .eraseToAnyView()
//        }
    }
}

struct ImportUR_Previews: PreviewProvider {
//    final class Model: ObservableObject {
//        @Published var seed: Seed?
//    }
//    static let model = Model()
    
    struct ImportURTest: View {
        @State var seed: Seed?
        
        var body: some View {
            ImportUR(seed: $seed)
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

