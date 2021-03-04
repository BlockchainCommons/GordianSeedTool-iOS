//
//  SegmentPicker.swift
//  Guardian
//
//  Created by Wolf McNally on 1/25/21.
//

import SwiftUI

struct SegmentPicker<SegmentType>: View where SegmentType: Segment {
    @Binding var selection: SegmentType? {
        didSet {
            updateSelectionIndex()
        }
    }
    @State var selectionIndex: Int?
    let segments: [SegmentType]
    
    @State private var height: CGFloat?
    @State private var segmentWidth: CGFloat?
    
    func updateSelectionIndex() {
        if let selection = selection {
            selectionIndex = segments.firstIndex(of: selection)
        } else {
            selectionIndex = nil
        }
    }
        
    var body: some View {
        GeometryReader { viewProxy in
            ZStack(alignment: .topLeading) {
                Capsule().fill(Color.formGroupBackground)
                if let selectionIndex = selectionIndex, let segmentWidth = segmentWidth {
                    Capsule()
                        .fill(Color.formGroupBackground)
                        .offset(x: CGFloat(selectionIndex) * segmentWidth)
                        .frame(width: segmentWidth)
                }
                HStack(spacing: 0) {
                    ForEach(segments) { segment in
                        segment.label
                            .padding([.leading, .trailing], 5)
                            .padding(6)
                            .frame(width: segmentWidth)
                            .background(
                                GeometryReader { segmentLabelProxy in
                                    Color.clear
                                        .preference(key: MaxHeightKey.self, value: segmentLabelProxy.size.height)
                                }
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation {
                                    selection = segment
                                }
                            }
                            .accessibilityElement(children: .combine)
                            .accessibilityAddTraits(.isButton)
                            .accessibilityRemoveTraits(.isImage)
                    }
                    .onPreferenceChange(MaxHeightKey.self) { value in
                        height = value
                    }
                }
            }
            .preference(key: SegmentWidthKey.self, value: viewProxy.size.width / CGFloat(segments.count))
            .onPreferenceChange(SegmentWidthKey.self) { value in
                segmentWidth = value
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .onAppear {
            updateSelectionIndex()
        }
        .fixedVertical()
    }
}

fileprivate struct MaxHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

fileprivate struct SegmentWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

protocol Segment: Identifiable, Equatable {
    var label: AnyView { get }
}

func makeSegmentLabel(title: String? = nil, icon: AnyView? = nil) -> AnyView {
    HStack {
        icon
        if let title = title {
            Text(title)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }
    .accessibility(label: Text(title ?? "Untitled"))
    .eraseToAnyView()
}

struct BasicSegment: Segment {
    let id: UUID = UUID()
    let title: String?
    let icon: AnyView?
    
    init(title: String) {
        self.icon = nil
        self.title = title
    }

    init(title: String? = nil, icon: AnyView) {
        self.icon = icon
        self.title = title
    }
    
    var label: AnyView {
        makeSegmentLabel(title: title, icon: icon)
    }
    
    static func ==(lhs: BasicSegment, rhs: BasicSegment) -> Bool {
        return lhs.id == rhs.id
    }
}


#if DEBUG

struct SegmentedPickerPreviewView: View {
    @State var selection: BasicSegment?
    
    private let segments: [BasicSegment] = [
        BasicSegment(title: "M", icon: Image(systemName: "m.circle").foregroundColor(Color.red).eraseToAnyView()),
        BasicSegment(title: "T", icon: Image(systemName: "t.circle").foregroundColor(Color.orange).eraseToAnyView()),
        BasicSegment(title: "W", icon: Image(systemName: "w.circle").foregroundColor(Color.yellow).eraseToAnyView()),
        BasicSegment(title: "T", icon: Image(systemName: "t.circle").foregroundColor(Color.green).eraseToAnyView()),
        BasicSegment(title: "F", icon: Image(systemName: "f.circle").foregroundColor(Color.blue).eraseToAnyView()),
    ]
    
    var body: some View {
             SegmentPicker(selection: $selection, segments: segments)
            .padding()
            .onAppear {
                selection = segments[0]
            }
    }
}

struct SegmentedPicker_Previews: PreviewProvider {
    static var previews: some View {
        SegmentedPickerPreviewView()
            .darkMode()
    }
}

#endif