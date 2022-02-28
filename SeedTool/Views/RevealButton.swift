//
//  RevealButton.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 12/17/20.
//

import SwiftUI

fileprivate struct MinHeightKey: PreferenceKey {
    static var defaultValue: Double = .infinity
    
    static func reduce(value: inout Double, nextValue: () -> Double) {
        value = min(value, nextValue())
    }
}

struct RevealButton<RevealedContent, HiddenContent>: View where RevealedContent: View, HiddenContent: View {
    let alignment: VerticalAlignment
    let revealed: () -> RevealedContent
    let hidden: () -> HiddenContent
    @State var isRevealed: Bool = false
    @State private var height: Double = .infinity
    @State private var didAppear = false
    
    init(alignment: VerticalAlignment = .firstTextBaseline, @ViewBuilder revealed: @escaping () -> RevealedContent, @ViewBuilder hidden: @escaping () -> HiddenContent) {
        self.alignment = alignment
        self.revealed = revealed
        self.hidden = hidden
    }
    
    var body: some View {
        HStack(alignment: alignment) {
            Button {
                isRevealed.toggle()
            } label: {
                Image.toggleVisibility(isRevealed: isRevealed)
            }
            
            ZStack(alignment: .topLeading) {
                revealed()
                    .opacity(isRevealed ? 1 : 0)
                    .background(
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: MinHeightKey.self, value: isRevealed ? proxy.size.height : .infinity)
                        }
                    )
                    .frame(height: self.height.isInfinite ? nil : self.height)
                
                VStack {
                    hidden()
                        .opacity(isRevealed ? 0 : 1)
                        .background(
                            GeometryReader { proxy in
                                Color.clear
                                    .preference(key: MinHeightKey.self, value: isRevealed ? .infinity : proxy.size.height)
                            }
                        )
                    Spacer()
                }
                .frame(height: self.height.isInfinite ? nil : self.height)
            }
            .onPreferenceChange(MinHeightKey.self) {
                self.height = $0
            }
            .frame(height: self.height.isInfinite ? nil : self.height)
            .animation(didAppear ? .easeInOut : .none, value: isRevealed)
            .animation(didAppear ? .easeInOut : .none, value: height)
            .clipped()
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                didAppear = true
            }
        }
    }
}

struct RevealButton2<RevealedContent, HiddenContent>: View where RevealedContent: View, HiddenContent: View {
    let icon: Image
    let isSensitive: Bool
    let revealed: () -> RevealedContent
    let hidden: () -> HiddenContent
    @State var isRevealed: Bool = false
    
    init(icon: Image = Image.locked, isSensitive: Bool = false, @ViewBuilder revealed: @escaping () -> RevealedContent, @ViewBuilder hidden: @escaping () -> HiddenContent) {
        self.icon = icon
        self.isSensitive = isSensitive
        self.revealed = revealed
        self.hidden = hidden
    }
    
    var activeIcon: Image {
        isRevealed ? Image.hide : icon
    }
    
    var body: some View {
        HStack {
            Button {
                withAnimation {
                    isRevealed.toggle()
                }
            } label: {
                HStack(alignment: .firstTextBaseline) {
                    activeIcon
                        .accentColor(isSensitive ? .yellowLightSafe : .accentColor)
                        .accessibility(label: Text(isRevealed ? "Hide" : "Reveal"))
                    if !isRevealed {
                        hidden()
                            .padding([.trailing], 10)
                    }
                }
            }
            if isRevealed {
                revealed()
            }
        }
        .formSectionStyle()
    }
}

#if DEBUG

import WolfLorem

struct RevealButton_Previews: PreviewProvider {
    static var previews: some View {
        RevealButton {
            Text(Lorem.sentence())
        } hidden: {
            Text("Hidden")
        }
        .formSectionStyle()
        .darkMode()
    }
}

#endif
