//
//  SettingsPanel.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/30/21.
//

import SwiftUI
import WolfSwiftUI

struct SettingsPanel: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var model: Model
    @State private var isEraseWarningPresented = false

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                LabeledContent {
                    Text("Default Network")
                } content: {
                    SegmentPicker(selection: Binding($settings.defaultNetwork), segments: Network.allCases)
                }
                
                GroupBox(label: Text("Danger Zone")) {
                    VStack(alignment: .leading) {
                        HStack {
                            Spacer()
                            Button {
                                isEraseWarningPresented = true
                            } label: {
                                Label("Erase All Data", systemImage: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(Font.body.bold())
                            }
                            .formSectionStyle()
                            Spacer()
                        }
                        Text("All data will be erased from the app, including ALL seeds stored in the device keychain. This is recommended before deleting the app from your device, because deleting an app does not guarantee deletion of all data added to the keychain by that app.")
                            .font(.footnote)
                    }
                }
                .formGroupBoxStyle()
                .alert(isPresented: $isEraseWarningPresented) { () -> Alert in
                    Alert(title: .init("Erase All Data"), message: .init("This action cannot be undone."),
                          primaryButton: .cancel(),
                          secondaryButton: .destructive(Text("Erase")) {
                            eraseAllData()
                          }
                    )
                }

                Spacer()
            }
            .padding()
            .navigationBarItems(leading: DoneButton($isPresented))
            .navigationBarTitle("Settings")
        }
    }
    
    func eraseAllData() {
        model.eraseAllData()
        isPresented = false
    }
}

#if DEBUG

struct SettingsPanel_Previews: PreviewProvider {
    static var storage = MockSettingsStorage()
    
    static var previews: some View {
        SettingsPanel(isPresented: .constant(true))
            .environmentObject(Settings(storage: storage))
            .darkMode()
    }
}

#endif
