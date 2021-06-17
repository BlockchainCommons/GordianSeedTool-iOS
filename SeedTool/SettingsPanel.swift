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
    @EnvironmentObject private var cloud: Cloud
    @State private var isEraseWarningPresented = false

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                LabeledContent {
                    Text("Default Network")
                } content: {
                    SegmentPicker(selection: Binding($settings.defaultNetwork), segments: Network.allCases)
                }

                VStack(alignment: .leading) {
                    LabeledContent {
                        Text("Sync to iCloud")
                    } content: {
                        SegmentPicker(selection: Binding($settings.syncToCloud), segments: SyncToCloud.allCases)
                    }
                    .onChange(of: settings.syncToCloud) { value in
                        print("syncToCloud: \(value)")
                    }

                    Text(cloud.syncStatus)
                        .font(.footnote)
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
                        Text("All data will be erased from the app, including ALL seeds stored on the device. If Sync to iCloud is active, ALL seeds will also be removed from iCloud.")
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

import WolfLorem

struct SettingsPanel_Previews: PreviewProvider {
    static var storage = MockSettingsStorage()
    static let settings = Settings(storage: storage)
    static let model = Lorem.model()
    static let cloud = Cloud(model: model, settings: settings)
    
    static var previews: some View {
        SettingsPanel(isPresented: .constant(true))
            .environmentObject(settings)
            .environmentObject(cloud)
            .darkMode()
    }
}

#endif
