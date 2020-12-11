//
//  ModelObjectIdentity.swift
//  Fehu
//
//  Created by Wolf McNally on 12/10/20.
//

import LifeHash
import SwiftUI

struct ModelObjectIdentity: View {
    let fingerprint: Fingerprint
    let type: ModelObjectType
    @Binding var name: String
    @StateObject var lifeHashState: LifeHashState

    init(fingerprint: Fingerprint, type: ModelObjectType, name: Binding<String>) {
        self.fingerprint = fingerprint
        self.type = type
        self._name = name
        _lifeHashState = .init(wrappedValue: LifeHashState(fingerprint))
    }

    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .top, spacing: min(10, proxy.size.height * 0.1)) {
                LifeHashView(state: lifeHashState) {
                    Rectangle().fill(Color.gray)
                }
                VStack(alignment: .leading) {
                    ModelObjectTypeIcon(type: type)
                        .frame(height: proxy.size.height / 3)
                    Spacer()
                    Text("\(name)")
                        .bold()
                        .font(.largeTitle)
                        .minimumScaleFactor(0.4)
                }
            }
        }
        .frame(maxWidth: 600, maxHeight: 200)
    }
}

import WolfLorem

struct ModelObjectIdentity_Previews: PreviewProvider {
    static let seed = Lorem.seed()
    static var previews: some View {
        ModelObjectIdentity(fingerprint: seed.fingerprint, type: .seed, name: .constant(Lorem.title()))
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 700, height: 300))
            .padding()
            .border(Color.yellow, width: 1)
        ModelObjectIdentity(fingerprint: seed.fingerprint, type: .seed, name: .constant(Lorem.title()))
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 300, height: 100))
            .padding()
            .border(Color.yellow, width: 1)
    }
}
