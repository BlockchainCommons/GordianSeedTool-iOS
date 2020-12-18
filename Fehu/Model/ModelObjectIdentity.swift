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
    @State var height: CGFloat?

    struct HeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 0

        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }

    init(fingerprint: Fingerprint, type: ModelObjectType, name: Binding<String>) {
        self.fingerprint = fingerprint
        self.type = type
        self._name = name
        _lifeHashState = .init(wrappedValue: LifeHashState(fingerprint))
    }

    init<T: ModelObject>(modelObject: T) {
        self.init(fingerprint: modelObject.fingerprint, type: T.modelObjectType, name: .constant(modelObject.name))
    }

    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .top) {
                LifeHashView(state: lifeHashState) {
                    Rectangle()
                        .fill(Color.gray)
                }
                .background (
                    GeometryReader { p in
                        Color.clear.preference(key: HeightKey.self, value: p.size.height)
                    }
                    .onPreferenceChange(HeightKey.self) { value in
                        height = value
                    }
                )

                VStack(alignment: .leading) {
                    HStack {
                        ModelObjectTypeIcon(type: type)
                            .frame(maxHeight: proxy.size.height / 3)
                        Text(fingerprint.identifier())
                            .font(.system(.body, design: .monospaced))
                            .bold()
                            .lineLimit(1)
                            .layoutPriority(1)
                    }
                    Spacer()
                    Text("\(name)")
                        .bold()
                        .font(.largeTitle)
                        .minimumScaleFactor(0.4)
                }
            }
        }
        .frame(minWidth: 200, maxWidth: 600, minHeight: 64, maxHeight: 200)
        .frame(height: height)
    }
}

#if DEBUG

import WolfLorem

struct ModelObjectIdentity_Previews: PreviewProvider {
    static let seed = Lorem.seed()
    static let title = Lorem.title()
    static var previews: some View {
        ModelObjectIdentity(fingerprint: seed.fingerprint, type: .seed, name: .constant(title))
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 700, height: 300))
            .padding()
            .border(Color.yellow, width: 1)
        ModelObjectIdentity(fingerprint: seed.fingerprint, type: .seed, name: .constant(title))
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 300, height: 100))
            .padding()
            .border(Color.yellow, width: 1)
        ModelObjectIdentity(fingerprint: seed.fingerprint, type: .seed, name: .constant(title))
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 300, height: 300))
            .padding()
            .border(Color.yellow, width: 1)
    }
}

#endif
