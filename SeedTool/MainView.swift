//
//  MainView.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/25/21.
//

import SwiftUI

struct MainView: View {
    @State private var presentedSheet: Sheet?
    @EnvironmentObject private var model: Model
    @EnvironmentObject private var settings: Settings
    @StateObject var undoStack = UndoStack()

    enum Sheet: Identifiable {
        case newSeed(ModelSeed)
        case request(TransactionRequest)
        
        var id: Int {
            switch self {
            case .newSeed:
                return 1
            case .request:
                return 2
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
                SeedList(undoStack: undoStack)
            }
            .copyConfirmation()
            .sheet(item: $presentedSheet) { item -> AnyView in
                let isSheetPresented = Binding<Bool>(
                    get: { presentedSheet != nil },
                    set: { if !$0 { presentedSheet = nil } }
                )
                switch item {
                case .newSeed(let seed):
                    return SetupNewSeed(seed: seed, isPresented: isSheetPresented) {
                        withAnimation {
                            model.insertSeed(seed, at: 0)
                        }
                    }
                    .environmentObject(model)
                    .environmentObject(settings)
                    .eraseToAnyView()
                case .request(let request):
                    return ApproveTransaction(isPresented: isSheetPresented, request: request)
                        .environmentObject(model)
                        .environmentObject(settings)
                        .eraseToAnyView()
                }
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
        Image("bc-logo")
            .font(.largeTitle)
            .accessibility(hidden: true)
    }
    
    var settingsButton: some View {
        SettingsButton() {
            undoStack.invalidate()
        }
        .font(.title)
        .padding([.top, .bottom, .leading], 10)
        .accessibility(label: Text("Settings"))
        .environmentObject(model)
        .environmentObject(settings)
    }
    
    var leadingItems: some View {
        HStack(spacing: 20) {
            userGuideButton
            scanButton
        }
    }
    
    var userGuideButton: some View {
        UserGuideButton()
            .font(.title)
            .padding([.top, .bottom, .trailing], 10)
            .accessibility(label: Text("Documentation"))
    }
    
    var scanButton: some View {
        ScanButton { scanResult in
            switch scanResult {
            case .seed(let newSeed):
                presentedSheet = .newSeed(newSeed)
            case .request(let request):
                presentedSheet = .request(request)
            case .failure(let error):
                print("🛑 scan failure: \(error.localizedDescription)")
            }
        }
        .font(.title)
        .padding([.top, .bottom, .trailing], 10)
        .accessibility(label: Text("Scan"))
    }
}

#if DEBUG

import WolfLorem

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(Lorem.model())
            .environmentObject(Settings(storage: MockSettingsStorage()))
            .darkMode()
    }
}

#endif
