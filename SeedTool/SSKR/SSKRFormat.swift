import Foundation
import SwiftUI
import BCApp

enum SSKRFormat: Int, CaseIterable {
    case envelope
    case legacy
    
    var id: Int { rawValue }
    
    var icon: Image {
        switch self {
        case .envelope:
            return .envelope
        case .legacy:
            return .ur
        }
    }
    
    var title: String {
        switch self {
        case .envelope:
            return "Gordian Envelope"
        case .legacy:
            return "Legacy `ur:sskr`"
        }
    }
    
    var shortName: String {
        switch self {
        case .envelope:
            return "Envelope"
        case .legacy:
            return "UR"
        }
    }
    
    var subtitle: String {
        switch self {
        case .envelope:
            return "Allows the seed and all its metadata (name, notes, etc.) to be recovered."
        case .legacy:
            return "Only the raw bytes of the seed will be recoverable."
        }
    }
}

extension SSKRFormat: Segment {
    var view: AnyView {
        HStack(alignment: .firstTextBaseline) {
            icon
            VStack(alignment: .leading) {
                Text(markdown: title)
                    .bold()
                    .font(.body)
                Text(subtitle)
                    .font(.caption)
            }
        }
        .fixedVertical()
        .eraseToAnyView()
    }
    
    var accessibilityLabel: String {
        title
    }
}
