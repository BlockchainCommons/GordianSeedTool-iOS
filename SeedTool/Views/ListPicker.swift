//
//  ListPicker.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/19/21.
//

import SwiftUI

struct ListPicker<SegmentType>: View where SegmentType: Segment {
    @Binding var selection: SegmentType
    @Binding var segments: [SegmentType]
    
    var selectionIndex: Int? {
        return segments.firstIndex(of: selection)
    }
    
    @State private var width: CGFloat?
    @State private var height: CGFloat?
    @State private var segmentRects: [Int: CGRect] = [:]
    
    let margin: CGFloat = 10
    
    private func rect(for index: Int) -> CGRect {
        segmentRects[index]!
    }
    
    private struct IndexedSegment: Identifiable {
        let index: Int
        let segment: SegmentType
        
        var id: SegmentType.ID {
            segment.id
        }
    }

    var body: some View {
        let indexedSegments: [IndexedSegment] = segments.enumerated().map { elem in
            IndexedSegment(index: elem.0, segment: elem.1)
        }
        return GeometryReader { viewProxy in
            ZStack(alignment: .topLeading) {
                if let selectionIndex = selectionIndex, let rect = segmentRects[selectionIndex] {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.formGroupBackground)
                        .frame(width: viewProxy.size.width + 2 * margin, height: rect.size.height + 2 * margin)
                        .offset(x: -margin, y: rect.minY - margin)
                }
                VStack(alignment: .leading, spacing: margin + 5) {
                    ForEach(indexedSegments) { indexedSegment in
                        indexedSegment.segment.label
                            .padding([.leading, .trailing], margin)
                            //.debugBlue()
                            .background(
                                GeometryReader { segmentLabelProxy in
                                    Color.clear
                                        .preference(key: SegmentRectsKey.self, value: [indexedSegment.index: segmentLabelProxy.frame(in: .named("ListPicker"))])
                                }
                            )
                    }
                    .offset(x: -margin)
                }
                ForEach(Array(segmentRects.keys.sorted()), id: \.self) { index in
                    let rect = rect(for: index)
                    Rectangle()
                        .fill(Color.clear)
                        //.fill(Color.yellow.opacity(0.2))
                        .contentShape(Rectangle())
                        .frame(width: viewProxy.size.width, height: rect.size.height)
                        .offset(x: rect.minX, y: rect.minY)
                        .onTapGesture {
                            withAnimation {
                                selection = segments[index]
                            }
                        }
                }
                .coordinateSpace(name: "ListPicker")
            }
            .background(
                GeometryReader { viewProxy in
                    Color.clear
                        .preference(key: WidthKey.self, value: viewProxy.size.width)
                }
            )
            .coordinateSpace(name: "ListPicker")
            .onPreferenceChange(SegmentRectsKey.self) { value in
                segmentRects = value
                let minTop = segmentRects.values.reduce(CGFloat.infinity) { result, rect in
                    min(result, rect.minY)
                }
                let maxBottom = segmentRects.values.reduce(0) { result, rect in
                    max(result, rect.maxY)
                }
                height = maxBottom - minTop //+ 2 * margin
            }
            .onPreferenceChange(WidthKey.self) { value in
                width = value
            }
//            .padding([.top], margin)
        }
        .frame(width: width, height: height)
        //.debugRed()
    }
    
    var effectiveWidth: CGFloat? {
        guard let width = width else {
            return nil
        }
        return width + 2 * margin
    }
}

fileprivate struct WidthKey: PreferenceKey {
    static var defaultValue: CGFloat?
    
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        value = nextValue()
    }
}

fileprivate struct SegmentRectsKey: PreferenceKey {
    static var defaultValue: [Int: CGRect] = [:]

    static func reduce(value: inout [Int: CGRect], nextValue: () -> [Int: CGRect]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

#if DEBUG

import WolfLorem

struct ListPickerPickerPreviewView: View {
    @State var selection: TestSegment = Self.segments[0]
    
    struct TestSegment: Segment {
        let id = UUID()
        let title: String
        let subtitle: String?
        
        var label: AnyView {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title)
                    .fixedVertical()
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .fixedVertical()
                }
            }
            .eraseToAnyView()
        }
    }
    
    private static let segments: [TestSegment] = [
        TestSegment(title: Lorem.words(10), subtitle: Lorem.sentence()),
        TestSegment(title: Lorem.words(3), subtitle: Lorem.sentence()),
        TestSegment(title: Lorem.words(3), subtitle: Lorem.sentence()),
        TestSegment(title: Lorem.words(3), subtitle: Lorem.sentence()),
        TestSegment(title: Lorem.words(3), subtitle: Lorem.sentence()),
    ]
    
    var body: some View {
        VStack {
            ListPicker(selection: $selection, segments: .constant(Self.segments))
                .padding()
            Button {
                withAnimation {
                    selection = Self.segments.filter({ $0 != selection }).randomElement()!
                }
            } label: {
                Text("Select Random")
            }
        }
    }
}

struct ListPicker_Previews: PreviewProvider {
    static var previews: some View {
        ListPickerPickerPreviewView()
            .darkMode()
    }
}

#endif
