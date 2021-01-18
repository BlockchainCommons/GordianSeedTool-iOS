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
    private let type: ModelObjectType
    @Binding private var name: String
    @StateObject private var lifeHashState: LifeHashState
    @StateObject private var lifeHashNameGenerator: LifeHashNameGenerator
    @State private var height: CGFloat?
    @EnvironmentObject private var pasteboardCoordinator: PasteboardCoordinator
    private let allowLongPressCopy: Bool
    

    struct HeightKey: PreferenceKey {
        static var defaultValue: CGFloat = 0

        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            value = nextValue()
        }
    }

    init(id: UUID, fingerprint: Fingerprint, type: ModelObjectType, name: Binding<String>, provideSuggestedName: Bool = false, allowLongPressCopy: Bool = true) {
        self._id = State(initialValue: id)
        self._fingerprint = State(initialValue: fingerprint)
        self.type = type
        self._name = name
        let lifeHashState = LifeHashState(fingerprint, version: .version2)
        _lifeHashState = .init(wrappedValue: lifeHashState)
        _lifeHashNameGenerator = .init(wrappedValue: LifeHashNameGenerator(lifeHashState: provideSuggestedName ? lifeHashState : nil))
        self.allowLongPressCopy = allowLongPressCopy
    }

    init<T: ModelObject>(modelObject: T) {
        self.init(id: modelObject.id, fingerprint: modelObject.fingerprint, type: T.modelObjectType, name: .constant(modelObject.name))
    }
    
    var lifeHashView: some View {
        LifeHashView(state: lifeHashState) {
            Rectangle()
                .fill(Color.gray)
        }
        .conditionalLongPressAction(actionEnabled: allowLongPressCopy) {
            if let image = lifeHashState.osImage {
                pasteboardCoordinator.copyToPasteboard(image.scaled(by: 8))
            }
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
            .conditionalLongPressAction(actionEnabled: allowLongPressCopy) {
                pasteboardCoordinator.copyToPasteboard(fingerprint.digest.hex)
            }
    }
    
    var objectName: some View {
        Text("\(name)")
            .bold()
            .font(.largeTitle)
            .minimumScaleFactor(0.4)
            .conditionalLongPressAction(actionEnabled: allowLongPressCopy) {
                pasteboardCoordinator.copyToPasteboard(name)
            }
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
