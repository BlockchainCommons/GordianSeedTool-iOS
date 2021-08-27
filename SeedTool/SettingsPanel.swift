//
//  SettingsPanel.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/30/21.
//

import SwiftUI
import WolfSwiftUI
import LibWally

struct SettingsButton: View {
    @State private var isPresented: Bool = false
    
    var body: some View {
        Button {
            isPresented = true
        } label: {
            Image(systemName: "gearshape")
        }
        .sheet(isPresented: $isPresented) {
            SettingsPanel(isPresented: $isPresented)
        }
    }
}

struct SettingsPanel: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var settings: Settings
    @EnvironmentObject private var model: Model
    @State private var isEraseWarningPresented = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    LabeledContent {
                        Text("Default Network")
                    } content: {
                        SegmentPicker(selection: Binding($settings.defaultNetwork), segments: .constant(Network.allCases))
                    }

                    VStack(alignment: .leading) {
                        LabeledContent {
                            Text("Sync to iCloud")
                        } content: {
                            SegmentPicker(selection: Binding($settings.syncToCloud), segments: .constant(SyncToCloud.allCases))
                        }
                        .onChange(of: settings.syncToCloud) { value in
                            print("syncToCloud: \(value)")
                        }
                        
                        HStack(alignment: .top) {
                            let syncStatus = model.cloud?.syncStatus
                            Text(syncStatus?.0 ?? "?")
                            Text(syncStatus?.1 ?? "Mock status message")
                        }
                        .font(.footnote)
                    }
                    
                    GroupBox(label: Text("Advanced")) {
                        VStack(alignment: .leading) {
                            Toggle("Show Developer Functions", isOn: $settings.showDeveloperFunctions.animation())
                            if settings.showDeveloperFunctions {
                                (Text(Image(systemName: "ladybug.fill")).foregroundColor(.green) + Text(" Developer functions are marked with this symbol. There are developer functions in the Seed Detail and Key Export views."))
                                    .fixedVertical()
                                    .font(.footnote)
                            }
                        }
                    }
                    .formGroupBoxStyle()

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

                    Text(Application.versionInfoBlock)
                        .font(.footnote)

                    Spacer()
                }
                .padding()
            }
            .font(.body)
            .navigationBarItems(trailing: DoneButton($isPresented))
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
    
    static var previews: some View {
        SettingsPanel(isPresented: .constant(true))
            .environmentObject(settings)
            .environmentObject(model)
            .darkMode()
    }
}

#endif
