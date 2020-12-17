//
//  ContentView.swift
//  Fehu
//
//  Created by Wolf McNally on 12/4/20.
//

import SwiftUI

struct ContentView: View {
    init() {
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        NavigationView {
            SeedList()
        }
        // FB8936045: StackNavigationViewStyle prevents new list from entering Edit mode correctly
        // https://developer.apple.com/forums/thread/656386?answerId=651882022#651882022
        //.navigationViewStyle(StackNavigationViewStyle())
    }
}

#if DEBUG

import WolfLorem

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Lorem.model())
            .preferredColorScheme(.dark)
    }
}

#endif
