//
//  ShareButton.swift
//  SeedTool
//
//  Created by Wolf McNally on 2/10/22.
//

import SwiftUI

struct ShareButton<Content>: View where Content: View {
    let content: Content
    let isSensitive: Bool
    let params: ActivityParams
    @State private var activityParams: ActivityParams?
    
    var body: some View {
        ExportDataButton(content: content, isSensitive: isSensitive) {
            activityParams = params
        }
        .background(ActivityView(params: $activityParams))
    }
}

extension ShareButton where Content == MenuLabel<Label<Text, AnyView>> {
    init(_ text: Text, icon: Image, isSensitive: Bool, params: ActivityParams) {
        self.init(content: MenuLabel(text, icon: icon), isSensitive: isSensitive, params: params)
    }

    init(_ string: String, icon: Image, isSensitive: Bool, params: ActivityParams) {
        self.init(Text(string), icon: icon, isSensitive: isSensitive, params: params)
    }
}
