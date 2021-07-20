//
//  SSKRSetup2.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/18/21.
//

import SwiftUI
import WolfSwiftUI

struct SSKRSetup2: View {
    let seed: Seed
    @Binding var isPresented: Bool
    @State private var sskrModel = SSKRModel2()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    ModelObjectIdentity(model: .constant(seed))
                        .frame(height: 100)
                        .padding()
                    GroupBox(label: Text("Presets")) {
                        ListPicker(selection: $sskrModel.preset, segments: SSKRPreset.allCases)
                    }
                    .formGroupBoxStyle()
                    
                    GroupBox(label: Text("Groups")) {
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
                    .formGroupBoxStyle()

                    ForEach(sskrModel.groups.indices, id: \.self) { index in
                        GroupView(model: $sskrModel, index: index)
                    }
                }
                .font(.callout)
                .frame(maxWidth: 500)
            }
            .navigationTitle("SSKR Export")
            .navigationBarItems(leading: CancelButton($isPresented))
        }
        .copyConfirmation()
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    struct GroupView: View {
        @Binding var model: SSKRModel2
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
            return GroupBox(label: header) {
                VStack(alignment: .leading) {
                    Stepper("Number of Shares: \(count.wrappedValue)", value: count.animation(), in: SSKRModelGroup2.countRange)
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
            .formGroupBoxStyle()
        }
    }
}

#if DEBUG

import WolfLorem

struct SSKRSetup2_Previews: PreviewProvider {
    static let seed = Lorem.seed()
    static var previews: some View {
        SSKRSetup2(seed: seed, isPresented: .constant(true))
            .darkMode()
    }
}

#endif
