//
//  LabeledContent.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/26/21.
//

import SwiftUI

struct LabeledContent<Label, Content>: View where Label: View, Content: View {
    let label: () -> Label
    let content: () -> Content
    @State var parentWidth: CGFloat? = nil
    
    init(@ViewBuilder label: @escaping () -> Label, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }
    
    var body: some View {
        LabeledContentContainer(label: label, content: content)
            .onPreferenceChange(LabeledContentWidth.self) {
                parentWidth = $0
            }
            .environment(\.labeledContentWidth, parentWidth)
    }
}

fileprivate struct LabeledContentWidth: EnvironmentKey {
    static var defaultValue: CGFloat? = nil
}

extension EnvironmentValues {
    var labeledContentWidth: CGFloat? {
        get { self[LabeledContentWidth.self] }
        set { self[LabeledContentWidth.self] = newValue }
    }
}

extension LabeledContentWidth: PreferenceKey {
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        switch (value, nextValue()) {
        case (_, nil):
            break
        case (nil, let next):
            value = next
        default:
            break
        }
    }
}

fileprivate struct LabeledContentContainer<Label, Content>: View where Label: View, Content: View {
    let label: () -> Label
    let content: () -> Content
    @Environment(\.labeledContentWidth) var width
    
    init(@ViewBuilder label: @escaping () -> Label, @ViewBuilder content: @escaping () -> Content) {
        self.label = label
        self.content = content
    }
    
    var isLayoutVertical: Bool {
        if let width = width, width < 320 {
            return true
        }
        return false
    }

    var body: some View {
        Group {
            if isLayoutVertical {
                VStack(spacing: 2) {
                    label()
                    content()
                }
            } else {
                HStack {
                    label()
                    content()
                }
            }
        }
        .background(GeometryReader { proxy in
            Color.clear.preference(key: LabeledContentWidth.self, value: proxy.size.width)
        })
    }
}

#if DEBUG

struct SegPick: View {
    var body: some View {
        Circle().fill(Color.yellow).frame(width: 20, height: 20)
    }
}

struct SampleLabeledContentView: View {
    var body: some View {
        LabeledContent {
            Text("Label")
                .background(Color.red)
        } content: {
            HStack {
                Spacer()
//                Text("Content")
                SegPick()
                Spacer()
            }
            .background(Color.blue)
        }
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 10) {
            SampleLabeledContentView()
            SampleLabeledContentView()
            SampleLabeledContentView()
        }
        .previewLayout(.fixed(width: 250, height: 300))

        VStack(spacing: 10) {
            SampleLabeledContentView()
            SampleLabeledContentView()
            SampleLabeledContentView()
        }
        .previewLayout(.fixed(width: 350, height: 300))
    }
}

#endif
