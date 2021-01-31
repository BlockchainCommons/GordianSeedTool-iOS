//
//  ModelObjectIdentity.swift
//  Guardian
//
//  Created by Wolf McNally on 1/24/21.
//

import SwiftUI
import LifeHash
import URKit

fileprivate struct HeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ModelObjectIdentity<T: ModelObject>: View {
    @Binding var model: T?
    private let allowLongPressCopy: Bool
    @StateObject private var lifeHashState: LifeHashState
    @StateObject private var lifeHashNameGenerator: LifeHashNameGenerator

    @State private var height: CGFloat?

    init(model: Binding<T?>, provideSuggestedName: Bool = false, allowLongPressCopy: Bool = true) {
        self._model = model
        self.allowLongPressCopy = allowLongPressCopy
        let lifeHashState = LifeHashState(version: .version2)
        _lifeHashState = .init(wrappedValue: lifeHashState)
        _lifeHashNameGenerator = .init(wrappedValue: LifeHashNameGenerator(lifeHashState: provideSuggestedName ? lifeHashState : nil))
    }
    
    var lifeHashView: some View {
        LifeHashView(state: lifeHashState) {
            Rectangle()
                .fill(Color.gray)
        }
        .conditionalLongPressAction(actionEnabled: allowLongPressCopy) {
            if let image = lifeHashState.osImage {
                PasteboardCoordinator.shared.copyToPasteboard(image.scaled(by: 8))
            }
        }
    }
    
    var icon: some View {
        if let model = model {
            return HStack {
                ModelObjectTypeIcon(type: model.modelObjectType)
                ForEach(model.subtypes) {
                    $0.icon
                }
            }
            .eraseToAnyView()
        } else {
            return Image(systemName: "questionmark.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .eraseToAnyView()
        }
    }
    
    var instanceDetail: some View {
        if let model = model, let instanceDetail = model.instanceDetail {
            return Text(instanceDetail)
                .font(.caption)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .conditionalLongPressAction(actionEnabled: allowLongPressCopy) {
                    PasteboardCoordinator.shared.copyToPasteboard(instanceDetail)
                }
                .eraseToAnyView()
        } else {
            return EmptyView().eraseToAnyView()
        }
    }
    
    var identifier: some View {
        let fingerprintIdentifier = model?.fingerprint.identifier() ?? "?"
        let fingerprintDigest = model?.fingerprint.digest.hex ?? "?"
        
        return Text(fingerprintIdentifier)
            .font(.system(.body, design: .monospaced))
            .bold()
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .conditionalLongPressAction(actionEnabled: allowLongPressCopy) {
                PasteboardCoordinator.shared.copyToPasteboard(fingerprintDigest)
            }
    }

    var objectName: some View {
        let name = model?.name ?? "?"
        
        return Text("\(name)")
            .bold()
            .font(.largeTitle)
            .minimumScaleFactor(0.4)
            .conditionalLongPressAction(actionEnabled: allowLongPressCopy) {
                PasteboardCoordinator.shared.copyToPasteboard(name)
            }
    }
    
    func lifeHashHeight(desiredLifeHashHeight: CGFloat, availableWidth: CGFloat) -> CGFloat {
        min(desiredLifeHashHeight, availableWidth / 3)
    }
    
    var body: some View {
        GeometryReader { bodyProxy in
            HStack(alignment: .top) {
                lifeHashView
                .background (
                    GeometryReader { lifeHashProxy in
                        Color.clear.preference(key: HeightKey.self, value: lifeHashHeight(desiredLifeHashHeight: lifeHashProxy.size.height, availableWidth: bodyProxy.size.width))
                    }
                    .onPreferenceChange(HeightKey.self) { value in
                        height = value
                    }
                )

                VStack(alignment: .leading) {
                    HStack {
                        icon
                            .frame(maxHeight: bodyProxy.size.height / 3)
//                            .layoutPriority(1)
                        identifier
                    }
                    instanceDetail
                    Spacer()
                    objectName
                        .layoutPriority(1)
                }
            }
        }
        .frame(minWidth: 200, maxWidth: 600, minHeight: 64, maxHeight: 200)
        .frame(height: height)
        .onAppear {
            lifeHashState.fingerprint = model?.fingerprint
        }
        .onChange(of: model) { newModel in
            lifeHashState.fingerprint = newModel?.fingerprint
        }
        .onReceive(lifeHashNameGenerator.$suggestedName) { suggestedName in
            guard let suggestedName = suggestedName else { return }
            model?.name = suggestedName
        }
    }
}

final class StubModelObject: ModelObject {
    let id: UUID
    let fingerprint: Fingerprint
    let modelObjectType: ModelObjectType
    var name: String

    init(id: UUID, fingerprint: Fingerprint, modelObjectType: ModelObjectType, name: String) {
        self.id = id
        self.fingerprint = fingerprint
        self.modelObjectType = modelObjectType
        self.name = name
    }
    
    convenience init<T: ModelObject>(model: T) {
        self.init(id: model.id, fingerprint: model.fingerprint, modelObjectType: model.modelObjectType, name: model.name)
    }

    static func ==(lhs: StubModelObject, rhs: StubModelObject) -> Bool {
        lhs.id == rhs.id
    }
    
    var fingerprintData: Data {
        fatalError()
    }

    var ur: UR {
        fatalError()
    }
}

#if DEBUG

import WolfLorem

struct ModelObjectIdentity_Previews: PreviewProvider {
    static let seed = Lorem.seed()
    static let seedStub = StubModelObject(model: seed)
    static let key = HDKey(seed: seed)
    static var previews: some View {
        Group {
            ModelObjectIdentity<Seed>(model: .constant(seed))
                .previewLayout(.fixed(width: 700, height: 300))
            ModelObjectIdentity<Seed>(model: .constant(seed))
                .previewLayout(.fixed(width: 300, height: 100))
            ModelObjectIdentity<Seed>(model: .constant(seed))
                .previewLayout(.fixed(width: 300, height: 300))
            ModelObjectIdentity<StubModelObject>(model: .constant(seedStub))
                .previewLayout(.fixed(width: 700, height: 300))
            ModelObjectIdentity<Seed>(model: .constant(nil))
                .previewLayout(.fixed(width: 700, height: 300))
            ModelObjectIdentity<HDKey>(model: .constant(key))
                .previewLayout(.fixed(width: 700, height: 300))
        }
        .darkMode()
        .padding()
        .border(Color.yellowLightSafe, width: 1)
    }
}

#endif
