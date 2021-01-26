//
//  KeyExport.swift
//  Guardian
//
//  Created by Wolf McNally on 1/23/21.
//

import SwiftUI
import WolfSwiftUI
import Combine

final class KeyExportModel: ObservableObject {
    let seed: Seed
    @Published var key: HDKey? = nil
    let updatePublisher: CurrentValueSubject<Void, Never>
    var ops = Set<AnyCancellable>()

    init(seed: Seed) {
        self.seed = seed
        self.updatePublisher = CurrentValueSubject<Void, Never>(())
        
        updatePublisher
            .debounceField()
            .sink {
                self.updateKey()
            }
            .store(in: &ops)
    }
    
    @Published var asset: Asset = .btc {
        didSet {
            updatePublisher.send(())
        }
    }
    
    @Published var network: Network = .mainnet {
        didSet {
            updatePublisher.send(())
        }
    }
    
    @Published var keyType: KeyType = .private {
        didSet {
            updatePublisher.send(())
        }
    }
    
    func updateKey() {
        let masterPrivateKey = HDKey(seed: seed, asset: asset, network: network)
        switch keyType {
        case .private:
            key = masterPrivateKey
        case .public:
            key = try! HDKey(parent: masterPrivateKey, derivedKeyType: .public)
        }
    }
}

struct KeyExport: View {
    @Binding var isPresented: Bool
    @StateObject private var model: KeyExportModel
    @EnvironmentObject var pasteboardCoordinator: PasteboardCoordinator

    init(seed: Seed, isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._model = StateObject(wrappedValue: KeyExportModel(seed: seed))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack() {
                    inputSeedSection
                    connectionArrow()
                    parametersSection
                    connectionArrow()
                    outputKeySection
                }
                .onAppear {
                    model.updateKey()
                }
                .navigationBarTitle("Key Export")
                .navigationBarItems(leading: DoneButton { isPresented = false })
            }
        }
        .frame(maxWidth: 500)
        .padding()
        .copyConfirmation()
    }
    
    func connectionArrow() -> some View {
        Image(systemName: "arrowtriangle.down.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.formGroupBackground)
            .frame(height: 40)
    }

    var inputSeedSection: some View {
        GroupBox(label: Text("Input Seed")) {
            ModelObjectIdentity(model: .constant(model.seed))
                .frame(maxHeight: 100)
        }
        .formGroupBoxStyle()
    }

    var parametersSection: some View {
        GroupBox(label: Text("Parameters")) {
            VStack(alignment: .leading) {
                HStack {
                    Text("Asset")
                    SegmentPicker(selection: Binding($model.asset), segments: Asset.allCases)
                }
                HStack {
                    Text("Network")
                    SegmentPicker(selection: Binding($model.network), segments: Network.allCases)
                }
                SegmentPicker(selection: Binding($model.keyType), segments: KeyType.allCases)
            }
        }
        .formGroupBoxStyle()
    }
    
    var outputKeySection: some View {
        GroupBox(label: Text("Derived Key")) {
            ModelObjectIdentity(model: $model.key)
                .frame(height: 100)
        }
        .formGroupBoxStyle()
    }
}

#if DEBUG

import WolfLorem

struct KeyExport_Previews: PreviewProvider {
    static let seed = Lorem.seed();
    
    static var previews: some View {
        KeyExport(seed: seed, isPresented: .constant(true))
            .preferredColorScheme(.dark)
    }
}

#endif
