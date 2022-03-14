//
//  SSKRShareExportView.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/10/22.
//

import SwiftUI
import URUI

fileprivate struct MinHeightKey: PreferenceKey {
    static var defaultValue: Double = .infinity
    
    static func reduce(value: inout Double, nextValue: () -> Double) {
        value = min(value, nextValue())
    }
}

struct SSKRShareExportView: View {
    let share: SSKRShareCoupon
    @Binding var shareType: SSKRShareFormat
    @State private var activityParams: ActivityParams?
    @State private var height: Double = .infinity
    
    var body: some View {
        ZStack {
            Text(share.bytewords)
                .monospaced(size: 12)
                .fixedVertical()
                .longPressAction {
                    activityParams = share.bytewordsActivityParams
                }
                .opacity(shareType == .bytewords ? 1.0 : 0.0)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: MinHeightKey.self, value: shareType == .bytewords ? proxy.size.height : .infinity)
                    }
                )
                .frame(height: self.height.isInfinite ? nil : self.height)
            Text(share.ur.string)
                .monospaced(size: 12)
                .fixedVertical()
                .longPressAction {
                    activityParams = share.urActivityParams
                }
                .opacity(shareType == .ur ? 1.0 : 0.0)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: MinHeightKey.self, value: shareType == .ur ? proxy.size.height : .infinity)
                    }
                )
                .frame(height: self.height.isInfinite ? nil : self.height)
            URQRCode(data: .constant(share.ur.qrData), foregroundColor: .black, backgroundColor: .white)
                .frame(height: 150)
                .longPressAction {
                    activityParams = share.qrCodeActivityParams
                }
                .opacity(shareType == .qrCode ? 1.0 : 0.0)
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: MinHeightKey.self, value: shareType == .qrCode ? proxy.size.height : .infinity)
                    }
                )
                .frame(height: self.height.isInfinite ? nil : self.height)
        }
        .clipped()
        .onPreferenceChange(MinHeightKey.self) {
            self.height = $0
        }
        .background(ActivityView(params: $activityParams))
    }
}
