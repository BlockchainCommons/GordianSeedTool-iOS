//
//  SettingsPanel.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 1/30/21.
//

import SwiftUI
import WolfSwiftUI
import BCApp

struct SettingsButton: View {
    @State private var isPresented: Bool = false
    @Environment(Model.self) private var model
    @Environment(Settings.self) private var settings
    let action: (() -> Void)?
    
    var body: some View {
        Button {
            action?()
            isPresented = true
        } label: {
            Image.settings
        }
        .sheet(isPresented: $isPresented) {
            SettingsPanel(isPresented: $isPresented)
                .environment(model)
                .environment(settings)
        }
        .dismissOnNavigationEvent(isPresented: $isPresented)
    }
}

struct SettingsPanel: View {
    @Binding var isPresented: Bool
    @Environment(Settings.self) private var settings
    @Environment(Model.self) private var model
    @State private var isEraseWarningPresented = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    LabeledContent {
                        Text("Default Network")
                    } content: {
                        @Bindable var settings = settings;
                        SegmentPicker(selection: Binding($settings.defaultNetwork), segments: .constant(Network.allCases))
                    }
                    
                    LabeledContent {
                        Text("Primary Asset")
                    } content: {
                        @Bindable var settings = settings;
                        SegmentPicker(selection: Binding($settings.primaryAsset), segments: .constant(Asset.allCases))
                    }

                    VStack(alignment: .leading) {
                        LabeledContent {
                            Text("Sync to iCloud")
                        } content: {
                            @Bindable var settings = settings;
                            SegmentPicker(selection: Binding($settings.syncToCloud), segments: .constant(SyncToCloud.allCases))
                        }
                        //    .onChange(of: settings.syncToCloud) { value in
                        //        logger.debug("syncToCloud: \(value)")
                        //    }
                        
                        HStack(alignment: .top) {
                            let syncStatus = model.cloud?.syncStatus
                            Text(syncStatus?.0 ?? "?")
                            Text(syncStatus?.1 ?? "Mock status message")
                        }
                        .font(.footnote)
                    }
                    
                    AppGroupBox("Security") {
                        NavigationLink("Authentication") {
                            AuthenticationSettingsView(settings: settings)
                        }
                    }
                    
                    AppGroupBox("Advanced") {
                        VStack(alignment: .leading) {
                            @Bindable var settings = settings
                            Toggle("Show Developer Functions", isOn: $settings.showDeveloperFunctions.animation())
                            if settings.showDeveloperFunctions {
                                (Text(Image.developer).foregroundColor(.green) + Text(" Developer functions are marked with this symbol. There are developer functions in the Seed Detail and Key Export views."))
                                    .fixedVertical()
                                    .font(.footnote)
                            }
                        }
                    }

                    AppGroupBox("Danger Zone") {
                        VStack(alignment: .leading) {
                            HStack {
                                Spacer()
                                EraseAllDataButton {
                                    isEraseWarningPresented = true
                                }
                                Spacer()
                            }
                            Text("All data will be erased from the app, including ALL seeds stored on the device. If Sync to iCloud is active, ALL seeds will also be removed from iCloud. If Sync to iCloud is *not* active, then no data in iCloud will be deleted or modified. If you wish to erase all data from iCloud, make sure Sync to iCloud is active before you use the Erase All Data function.")
                                .font(.footnote)
                        }
                    }
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
            .navigationBarTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    DoneButton($isPresented)
                }
            }
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
            .environment(settings)
            .environment(model)
            .darkMode()
            .previewDevice("iPhone 11 Pro Max")

        SettingsPanel(isPresented: .constant(true))
            .environment(settings)
            .environment(model)
            .darkMode()
            .previewDevice("iPod Touch")
    }
}

#endif
