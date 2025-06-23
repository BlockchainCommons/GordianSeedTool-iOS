//
//  SSKRSetup.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/18/21.
//

import SwiftUI
import WolfSwiftUI
import BCApp

struct SSKRSetup: View {
    let seed: ModelSeed
    @Binding var isPresented: Bool
    @State private var sskrModel = SSKRModel()
    @State private var isDisplayPresented = false
    @Environment(Model.self) private var model
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ObjectIdentityBlock(model: .constant(seed))
                        .frame(height: 100)
                    
                    HStack {
                        UserGuideButton(openToChapter: AppChapter.whatIsSSKR, showShortTitle: true)
                        UserGuideButton(openToChapter: AppChapter.whatIsGordianEnvelope, showShortTitle: true)
                    }
                    
                    AppGroupBox("Format") {
                        ListPicker(selection: $sskrModel.format, segments: .constant(SSKRFormat.allCases))
                    }
                    
                    AppGroupBox("Presets") {
                        ListPicker(selection: $sskrModel.preset, segments: .constant(SSKRPreset.allCases))
                    }
                    
                    AppGroupBox("Group Setup") {
                        VStack(alignment: .leading) {
                            Stepper("Number of Groups: \(sskrModel.groupsCount)", value: $sskrModel.groupsCount.animation(), in: sskrModel.groupsRange)
                                .accessibility(label: Text("Number of Groups"))
                                .accessibility(value: Text(String(describing: sskrModel.groupsCount)))
                            if sskrModel.groups.count > 1 {
                                Stepper("Group Threshold: \(sskrModel.groupThreshold)", value: $sskrModel.groupThreshold.animation(), in: sskrModel.groupThresholdRange)
                                    .accessibility(label: Text("Group Threshold"))
                                    .accessibility(value: Text(String(describing: sskrModel.groupThreshold)))
                                Text(sskrModel.note)
                                    .font(.caption)
                            }
                        }
                    }

                    ForEach(sskrModel.groups.indices, id: \.self) { index in
                        GroupView(model: $sskrModel, index: index)
                    }
                }
                .font(.callout)
            }
            .padding()
            .frame(maxWidth: 500)
            .navigationTitle("SSKR Export")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CancelButton($isPresented)
                }
                ToolbarItem(placement: .confirmationAction) {
                    nextButton
                }
            }
            .navigationDestination(isPresented: $isDisplayPresented) {
                SSKRDisplay(
                    sskr: sskr,
                    isSetupPresented: $isPresented,
                    isPresented: $isDisplayPresented
                )
                .environment(model)
            }        }
        .copyConfirmation()
    }
    
    var sskr: SSKRGenerator {
        SSKRGenerator(seed: seed, sskrModel: sskrModel)
    }
    
    var nextButton: some View {
        Button {
            isDisplayPresented = true
        } label: {
            Text("Next").bold()
        }
        .accessibility(label: Text("Next"))
    }
    
    struct GroupView: View {
        @Binding var model: SSKRModel
        let index: Int
        
        var header: Text {
            Text("Group \(index + 1)")
//            Text(model.groupsCount > 1 ? "Group \(index + 1)" : "")
        }

        var body: some View {
            let count = Binding<Int>(
                get: {
                    guard index < model.groups.count else {
                        return 0
                    }
                    return model.groups[index].count
                },
                set: { newValue in
                    guard index < model.groups.count else {
                        fatalError()
                    }
                    withAnimation {
                        model.groups[index].count = newValue
                    }
                }
            )
            let threshold = Binding<Int>(
                get: {
                    guard index < model.groups.count else {
                        return 0
                    }
                    return model.groups[index].threshold
                },
                set: { newValue in
                    guard index < model.groups.count else {
                        fatalError()
                    }
                    withAnimation {
                        model.groups[index].threshold = newValue
                    }
                }
            )
            let thresholdRange = Binding<ClosedRange<Int>> (
                get: {
                    guard index < model.groups.count else {
                        return 0...0
                    }
                    return model.groups[index].thresholdRange
                },
                set: { _ in }
            )
            return AppGroupBox(label: header) {
                VStack(alignment: .leading) {
                    Stepper("Number of Shares: \(count.wrappedValue)", value: count.animation(), in: SSKRModelGroup.countRange)
                        .accessibility(label: Text("Group \(index + 1): Number of Shares"))
                        .accessibility(value: Text(String(describing: count.wrappedValue)))
                    if count.wrappedValue > 1 {
                        Stepper("Threshold: \(threshold.wrappedValue)", value: threshold.animation(), in: thresholdRange.wrappedValue)
                            .accessibility(label: Text("Group \(index + 1): Threshold"))
                            .accessibility(value: Text(String(describing: threshold)))
                        Text(model.groups[index].note)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

#if DEBUG

import WolfLorem

struct SSKRSetup2_Previews: PreviewProvider {
    static let model = Lorem.model()
    static let seed = model.seeds.first!
    static var previews: some View {
        SSKRSetup(seed: seed, isPresented: .constant(true))
            .environment(model)
            .darkMode()
    }
}

#endif
