//
//  ModelObjectIdentity.swift
//  Fehu
//
//  Created by Wolf McNally on 12/10/20.
//

import LifeHash
import SwiftUI

struct ModelObjectIdentity: View, Identifiable {
    @State var id: UUID
    @State private var fingerprint: Fingerprint
    let type: ModelObjectType
    @Binding var name: String
    @StateObject var lifeHashState: LifeHashState
    @StateObject var lifeHashNameGenerator: LifeHashNameGenerator
    @State var height: CGFloat?

    struct HeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 0

        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }

    init(id: UUID, fingerprint: Fingerprint, type: ModelObjectType, name: Binding<String>, provideSuggestedName: Bool = false) {
        self._id = State(initialValue: id)
        self._fingerprint = State(initialValue: fingerprint)
        self.type = type
        self._name = name
        let lifeHashState = LifeHashState(fingerprint, version: .version2)
        _lifeHashState = .init(wrappedValue: lifeHashState)
        _lifeHashNameGenerator = .init(wrappedValue: LifeHashNameGenerator(lifeHashState: provideSuggestedName ? lifeHashState : nil))
    }

    init<T: ModelObject>(modelObject: T) {
        self.init(id: modelObject.id, fingerprint: modelObject.fingerprint, type: T.modelObjectType, name: .constant(modelObject.name))
    }
    
    var lifeHashView: some View {
        return LifeHashView(state: lifeHashState) {
            Rectangle()
                .fill(Color.gray)
        }
    }
    
    var icon: some View {
        ModelObjectTypeIcon(type: type)
    }
    
    var identifier: some View {
        Text(fingerprint.identifier())
            .font(.system(.body, design: .monospaced))
            .bold()
            .lineLimit(1)
    }
    
    var objectName: some View {
        Text("\(name)")
            .bold()
            .font(.largeTitle)
            .minimumScaleFactor(0.4)
    }

    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .top) {
                lifeHashView
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
                        icon
                            .frame(maxHeight: proxy.size.height / 3)
                        identifier
                            .layoutPriority(1)
                    }
                    Spacer()
                    objectName
                }
            }
        }
        .frame(minWidth: 200, maxWidth: 600, minHeight: 64, maxHeight: 200)
        .frame(height: height)
        .onReceive(lifeHashNameGenerator.$suggestedName) { suggestedName in
            guard let suggestedName = suggestedName else { return }
            name = suggestedName
        }
    }
}

#if DEBUG

import WolfLorem

struct ModelObjectIdentity_Previews: PreviewProvider {
    static let seed = Lorem.seed()
    static let title = Lorem.title()
    static var previews: some View {
        ModelObjectIdentity(id: seed.id, fingerprint: seed.fingerprint, type: .seed, name: .constant(title))
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 700, height: 300))
            .padding()
            .border(Color.yellow, width: 1)
        ModelObjectIdentity(id: seed.id, fingerprint: seed.fingerprint, type: .seed, name: .constant(title))
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 300, height: 100))
            .padding()
            .border(Color.yellow, width: 1)
        ModelObjectIdentity(id: seed.id, fingerprint: seed.fingerprint, type: .seed, name: .constant("Untitled"))
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 300, height: 100))
            .padding()
            .border(Color.yellow, width: 1)
        ModelObjectIdentity(id: seed.id, fingerprint: seed.fingerprint, type: .seed, name: .constant(title))
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 300, height: 300))
            .padding()
            .border(Color.yellow, width: 1)
    }
}

#endif
