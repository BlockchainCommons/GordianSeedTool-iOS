//
//  Segment.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/17/21.
//

import SwiftUI

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
