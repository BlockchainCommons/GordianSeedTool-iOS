//
//  SizeAwareLabeledView.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/26/21.
//

import SwiftUI

fileprivate struct ParentWidthKey: PreferenceKey {
    static var defaultValue: CGFloat? = nil
    
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        switch (value, nextValue()) {
        case (_, nil):
            break
        case (_, let next):
            value = next
        }
    }
}

extension ParentWidthKey: EnvironmentKey { }

fileprivate extension EnvironmentValues {
    var parentWidth: CGFloat? {
        get { self[ParentWidthKey.self] }
        set { self[ParentWidthKey.self] = newValue }
    }
}

struct ParentWidth: ViewModifier {
    @Environment(\.parentWidth) var parentWidth

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ParentWidthKey.self, value: proxy.size.width)
                }
            )
            .frame(width: parentWidth)
    }
}

extension View {
    func parentWidth() -> some View {
        modifier(ParentWidth())
    }
}

struct ParentWidthHost: ViewModifier {
    @State var width: CGFloat? = nil
    
    func body(content: Content) -> some View {
        content
            .environment(\.parentWidth, width)
            .onPreferenceChange(ParentWidthKey.self) { self.width = $0}
    }
}

extension View {
    func parentWidthHost() -> some View {
        modifier(ParentWidthHost())
    }
}

struct MyNameKey: EnvironmentKey {
    static var defaultValue: String = "Fred"
}

extension EnvironmentValues {
    var myName: String {
        get { self[MyNameKey.self] }
        set { self[MyNameKey.self] = newValue }
    }
}

struct SizeAwareLabeledView<Label, Content>: View where Label: View, Content: View {
    let label: () -> Label
    let content: () -> Content
    @Environment(\.myName) var myName
    @Environment(\.lineLimit) var limit
    
    init(@ViewBuilder label: @escaping () -> Label, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }
    
    var body: some View {
        HStack {
            label()
            Text(myName)
            Text(String(describing: lineLimit))
            content()
        }
        .environment(\.lineLimit, 1)
        .environment(\.myName, "Wolf")
    }
}

#if DEBUG

struct SampleView: View {
    var body: some View {
        SizeAwareLabeledView {
            Text("Label 1")
                .background(Color.red)
        } content: {
            HStack {
                Spacer()
                Text("Content 1")
                Spacer()
            }
            .background(Color.blue)
        }
        //.background(Color.yellow)
    }
}

struct SizeAwareLabeledView_Previews: PreviewProvider {
    static var previews: some View {
        SampleView()
        .previewLayout(.fixed(width: 250, height: 300))

        SampleView()
        .previewLayout(.fixed(width: 350, height: 300))
    }
}

#endif
