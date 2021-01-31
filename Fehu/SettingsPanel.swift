//
//  SettingsPanel.swift
//  Guardian
//
//  Created by Wolf McNally on 1/30/21.
//

import SwiftUI
import WolfSwiftUI

struct SettingsPanel: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var settings: Settings
    
    var body: some View {
        NavigationView {
            VStack {
                LabeledContent {
                    Text("Default Network")
                } content: {
                    SegmentPicker(selection: Binding($settings.defaultNetwork), segments: Network.allCases)
                }
                Spacer()
            }
            .padding()
            .navigationBarItems(leading: doneButton)
            .navigationBarTitle("Settings")
        }
    }
    
    var doneButton: some View {
        DoneButton {
            isPresented = false
        }
    }
}

struct SettingsPanel_Previews: PreviewProvider {
    static var storage = MockSettingsStorage()
    
    static var previews: some View {
        SettingsPanel(isPresented: .constant(true))
            .environmentObject(Settings(storage: storage))
            .darkMode()
    }
}
