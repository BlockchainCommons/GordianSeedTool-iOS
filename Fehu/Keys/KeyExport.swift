//
//  KeyExport.swift
//  Guardian
//
//  Created by Wolf McNally on 1/23/21.
//

import SwiftUI
import WolfSwiftUI

final class KeyExportModel: ObservableObject {
    let seed: Seed

    init(seed: Seed) {
        self.seed = seed
    }

    enum KeyType {
        case `private`
        case `public`
    }
    
    @Published var network: Network = .mainnet {
        didSet {
            updateKey()
        }
    }
    
    @Published var keyType: KeyType = .private {
        didSet {
            updateKey()
        }
    }
    
    @Published var key: HDKey?
    
    func updateKey() {
        key = HDKey(seed: seed, network: network)
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
            Form {
                ModelObjectIdentity(modelObject: model.seed)
                    .frame(height: 120)
                
                Picker("Network", selection: $model.network) {
                    Text("MainNet").tag(Network.mainnet)
                    Text("TestNet").tag(Network.testnet)
                }
                .pickerStyle(SegmentedPickerStyle())
                Picker("Type", selection: $model.keyType) {
                    Text("Private").tag(KeyExportModel.KeyType.private)
                    Text("Public").tag(KeyExportModel.KeyType.public)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                if let key = model.key {
                    ModelObjectIdentity(modelObject: key)
                        .frame(height: 120)
                }
            }
            .onAppear {
                model.updateKey()
            }
            .navigationBarTitle("Key Export")
            .navigationBarItems(leading: DoneButton { isPresented = false })
            
        }
        .frame(maxWidth: 500)
//        .navigationTitle("Key Export")
//        .navigationBarItems(leading: CancelButton { isPresented = false })
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
