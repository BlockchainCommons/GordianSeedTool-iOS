//
//  NavigationBarItems.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/29/21.
//

import SwiftUI

struct NavBarItemsHeight: PreferenceKey {
    static var defaultValue: CGFloat? = nil
    
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        switch (value, nextValue()) {
        case (_, nil):
            break
        case (nil, let n?):
            value = n
        case (let v?, let n?):
            value = max(v, n)
        }
    }
}

struct NavigationBarItems<Leading, Center, Trailing>: View where Leading: View, Center: View, Trailing: View {
    let leadingContent: Leading
    let centerContent: Center
    let trailingContent: Trailing
    @State private var height: CGFloat?

    init(
        leading: Leading,
        center: Center,
        trailing: Trailing
    ) {
        self.leadingContent = leading
        self.centerContent = center
        self.trailingContent = trailing
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            HStack {
                leadingContent
                    .background(GeometryReader { proxy in
                        Color.clear.preference(key: NavBarItemsHeight.self, value: proxy.size.height)
                    })
                Spacer()
            }
            .frame(height: height)

            centerContent
                .background(GeometryReader { proxy in
                    Color.clear.preference(key: NavBarItemsHeight.self, value: proxy.size.height)
                })
                .frame(height: height)

            HStack {
                Spacer()
                trailingContent
                    .background(GeometryReader { proxy in
                        Color.clear.preference(key: NavBarItemsHeight.self, value: proxy.size.height)
                    })
            }
            .frame(height: height)
        }
        .onPreferenceChange(NavBarItemsHeight.self) {
            height = $0
        }
    }
}

#if DEBUG

struct NavigationBarItems_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBarItems(
            leading: EditButton().debugBlue(),
            center: Rectangle().fill(Color.red).frame(width: 30, height: 30),
            trailing: Button { } label: { Image.add }.debugBlue()
        )
        .background(Color.black)
        .padding()
    }
}

#endif
