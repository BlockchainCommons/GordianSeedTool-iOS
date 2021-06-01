//
//  ModelObjectIdentity.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/24/21.
//

import SwiftUI
import LifeHash
import URKit

fileprivate struct OfferedSizeKey: PreferenceKey {
    static var defaultValue: CGSize?

    static func reduce(value: inout CGSize?, nextValue: () -> CGSize?) {
    }
}

struct ModelObjectIdentity<T: ModelObject>: View {
    @Binding var model: T?
    private let allowLongPressCopy: Bool
    private let lifeHashWeight: CGFloat
    private let suppressName: Bool
    
    @StateObject private var lifeHashState: LifeHashState
    @StateObject private var lifeHashNameGenerator: LifeHashNameGenerator

    @State private var chosenSize: CGSize?
//    {
//        didSet {
//            print("offeredSize old: \(String(describing: oldValue)), new: \(String(describing: offeredSize))")
//        }
//    }
    
    private var actualWidth: CGFloat? {
        guard let chosenSize = chosenSize else { return nil }
        return chosenSize.width
    }

    private var actualHeight: CGFloat? {
        guard let chosenSize = chosenSize else { return nil }
        return max(64, min(chosenSize.width * lifeHashWeight, chosenSize.height))
    }

    private var iconSize: CGFloat? {
        guard let actualHeight = actualHeight else { return nil }
        return actualHeight * 0.3
    }
    
    private var hStackSpacing: CGFloat? {
        guard let actualHeight = actualHeight else { return nil }
        return actualHeight * 0.02
    }

    init(model: Binding<T?>, provideSuggestedName: Bool = false, allowLongPressCopy: Bool = true, generateLifeHashAsync: Bool = true, lifeHashWeight: CGFloat = 0.3, suppressName: Bool = false) {
        self._model = model
        self.allowLongPressCopy = allowLongPressCopy
        self.lifeHashWeight = lifeHashWeight
        self.suppressName = suppressName

        let lifeHashState = LifeHashState(version: .version2, generateAsync: generateLifeHashAsync, moduleSize: generateLifeHashAsync ? 1 : 8)
        _lifeHashState = .init(wrappedValue: lifeHashState)
        _lifeHashNameGenerator = .init(wrappedValue: LifeHashNameGenerator(lifeHashState: provideSuggestedName ? lifeHashState : nil))
    }

    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .top) {
                lifeHashView
                
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        icon
                        identifier
                    }
                    instanceDetail
                    Spacer()
                    if !suppressName {
                        objectName
                            .layoutPriority(1)
                    }
                }
                
                Spacer()
            }
            .preference(key: OfferedSizeKey.self, value: proxy.size)
        }
        .frame(height: actualHeight)
        .onPreferenceChange(OfferedSizeKey.self) { offeredSize in
            if let chosenSize = chosenSize, let offeredSize = offeredSize {
                self.chosenSize = CGSize(width: max(chosenSize.width, offeredSize.width), height: max(chosenSize.height, offeredSize.height))
            } else {
                chosenSize = offeredSize
            }
        }
        .onAppear {
            lifeHashState.fingerprint = model?.fingerprint
        }
        .onReceive(lifeHashNameGenerator.$suggestedName) { suggestedName in
            guard let suggestedName = suggestedName else { return }
            model?.name = suggestedName
        }
        .onChange(of: model) { newModel in
            lifeHashState.fingerprint = newModel?.fingerprint
        }
    }
    
    var lifeHashView: some View {
        LifeHashView(state: lifeHashState) {
            Rectangle()
                .fill(Color.gray)
        }
        .accessibility(label: Text("LifeHash"))
        .conditionalLongPressAction(actionEnabled: allowLongPressCopy) {
            if let image = lifeHashState.osImage {
                PasteboardCoordinator.shared.copyToPasteboard(image.scaled(by: 8))
            }
        }
    }
    
    var icon: some View {
        if let model = model {
            return HStack(spacing: hStackSpacing) {
                ModelObjectTypeIcon(type: model.modelObjectType)
                    .frame(width: iconSize, height: iconSize)
                    .accessibility(label: Text(model.modelObjectType.name))
                ForEach(model.subtypes) {
                    $0.icon
                }
            }
            .eraseToAnyView()
        } else {
            return Image(systemName: "questionmark.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: iconSize, height: iconSize)
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
            .monospaced()
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
            .truncationMode(.middle)
            .minimumScaleFactor(0.4)
            .conditionalLongPressAction(actionEnabled: allowLongPressCopy) {
                PasteboardCoordinator.shared.copyToPasteboard(name)
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
    
    var sizeLimitedUR: UR {
        fatalError()
    }
}

#if DEBUG

import WolfLorem

struct ModelObjectIdentity_Previews: PreviewProvider {
    static let seed: Seed = {
        let seed = Lorem.seed()
        seed.name = Lorem.sentence()
        return seed
    }()
    static let seedStub = StubModelObject(model: seed)
    static let key = HDKey(seed: seed)
    static var previews: some View {
        Group {
            ModelObjectIdentity(model: .constant(seed))
                .previewLayout(.fixed(width: 700, height: 300))
            ModelObjectIdentity(model: .constant(seed))
                .previewLayout(.fixed(width: 300, height: 100))
            ModelObjectIdentity(model: .constant(seed))
                .previewLayout(.fixed(width: 300, height: 300))
            ModelObjectIdentity(model: .constant(seedStub))
                .previewLayout(.fixed(width: 700, height: 300))
            ModelObjectIdentity<Seed>(model: .constant(nil))
                .previewLayout(.fixed(width: 700, height: 300))
            ModelObjectIdentity(model: .constant(key))
                .previewLayout(.fixed(width: 300, height: 100))
            ModelObjectIdentity(model: .constant(key))
                .previewLayout(.fixed(width: 700, height: 300))
            List {
                ModelObjectIdentity(model: .constant(seed))
                    .frame(height: 64)
                ModelObjectIdentity(model: .constant(seed))
                    .frame(height: 64)
                ModelObjectIdentity(model: .constant(seed))
                    .frame(height: 64)
            }
        }
        .darkMode()
        .padding()
        .border(Color.yellowLightSafe, width: 1)
    }
}

#endif
