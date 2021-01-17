//
//  TopBar.swift
//  Fehu
//
//  Created by Wolf McNally on 12/16/20.
//

import SwiftUI

struct TopBar<L, T>: ViewModifier where L: View, T: View {
    let leading: L
    let trailing: T

    func body(content: Content) -> some View {
        VStack {
            HStack {
                leading
                Spacer()
                trailing
            }
            .frame(maxWidth: .infinity)
            .padding()

            content
                .frame(maxHeight: .infinity)
        }
    }
}

extension View {
    func topBar<L, T>(leading: L, trailing: T) -> some View where L : View, T : View {
        modifier(TopBar(leading: leading, trailing: trailing))
    }

    func topBar<L>(leading: L) -> some View where L : View {
        modifier(TopBar(leading: leading, trailing: EmptyView()))
    }

    func topBar<T>(trailing: T) -> some View where T : View {
        modifier(TopBar(leading: EmptyView(), trailing: trailing))
    }
}

#if DEBUG

struct TopBar_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello")
            .topBar(leading: Text("Leading"), trailing: Text("Trailing"))
            .padding()
    }
}

#endif
