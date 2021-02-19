//
//  ContentView.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/4/20.
//

import SwiftUI

struct ContentView: View {
    @State private var presentedSheet: Sheet?

    enum Sheet: Identifiable {
        case settings
        case info
        case scan
        case newSeed(Seed)
        case request(TransactionRequest)

        var id: Int {
            switch self {
            case .settings:
                return 1
            case .info:
                return 2
            case .scan:
                return 3
            case .newSeed:
                return 4
            case .request:
                return 5
            }
        }
    }
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        VStack(spacing: 0) {
            topBar
                .padding([.leading, .trailing])
            NavigationView {
                SeedList()
            }
        }
        .copyConfirmation()
        .sheet(item: $presentedSheet) { item -> AnyView in
            let isSheetPresented = Binding<Bool>(
                get: { presentedSheet != nil },
                set: { if !$0 { presentedSheet = nil } }
            )
            switch item {
            case .settings:
                return SettingsPanel(isPresented: isSheetPresented)
                    .environmentObject(settings)
                    .eraseToAnyView()
            case .info:
                return TableOfContents(isPresented: isSheetPresented)
                    .eraseToAnyView()
            case .scan:
                return Scan(isPresented: isSheetPresented) { scanResult in
                    switch scanResult {
                    case .seed(let newSeed):
                        presentedSheet = .newSeed(newSeed)
                    case .request(let request):
                        presentedSheet = .request(request)
                    }
                }
                .eraseToAnyView()
            case .newSeed(let seed):
                return NameNewSeed(seed: seed, isPresented: isSheetPresented) {
                    withAnimation {
                        model.seeds.insert(seed, at: 0)
                    }
                }
                .eraseToAnyView()
            case .request(let request):
                return Text("Request")
                    .eraseToAnyView()
            }
        }
        // FB8936045: StackNavigationViewStyle prevents new list from entering Edit mode correctly
        // https://developer.apple.com/forums/thread/656386?answerId=651882022#651882022
        //.navigationViewStyle(StackNavigationViewStyle())
    }
    
    var topBar: some View {
        NavigationBarItems(leading: leadingItems, center: centerTopView, trailing: settingsButton)
    }
    
    var centerTopView: some View {
        (Text(Image("bc-logo")) + Text("Blockchain Commons"))
            .font(.body)
            .bold()
    }
    
    var settingsButton: some View {
        Button {
            presentedSheet = .settings
        } label: {
            Image(systemName: "gearshape")
                .padding([.top, .bottom, .leading], 10)
        }
    }
    
    var leadingItems: some View {
        HStack {
            infoButton
            scanButton
        }
    }
    
    var infoButton: some View {
        Button {
            presentedSheet = .info
        } label: {
            Image(systemName: "info.circle")
                .padding([.top, .bottom, .trailing], 10)
        }
    }
    
    var scanButton: some View {
        Button {
            presentedSheet = .scan
        } label: {
            Image(systemName: "qrcode.viewfinder")
                .padding([.top, .bottom, .trailing], 10)
        }
    }
}

#if DEBUG

import WolfLorem

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Lorem.model())
            .darkMode()
    }
}

#endif
