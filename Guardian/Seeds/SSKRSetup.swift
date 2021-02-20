//
//  SSKRSetup.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/16/20.
//

import SwiftUI
import WolfSwiftUI

struct SSKRSetup: View {
    let seed: Seed
    @Binding var isPresented: Bool
    @StateObject private var model: SSKRModel

    init(seed: Seed, isPresented: Binding<Bool>) {
        self.seed = seed
        self._isPresented = isPresented
        self._model = StateObject(wrappedValue: SSKRModel())
    }

    var body: some View {
        NavigationView {
            VStack {
                ModelObjectIdentity(model: .constant(seed))
                    .frame(height: 100)
                    .padding()
                Form {
                    Section() {
                        Stepper("Number of Groups: \(model.numberOfGroups)", value: $model.numberOfGroups.animation(), in: model.groupsRange)
                        if model.groups.count > 1 {
                            Stepper("Group Threshold: \(model.groupThreshold)", value: $model.groupThreshold.animation(), in: model.groupThresholdRange)
                            Text(model.note)
                                .font(.caption)
                        }
                    }
                    .font(.callout)
                    ForEach(model.groups.indices, id: \.self) { index in
                        GroupView(index: index, count: model.groups.count, group: model.groups[index])
                    }
                    .font(.callout)

                    NavigationLink(
                        destination: LazyView(SSKRDisplay(seed: seed, model: model, isPresented: $isPresented)),
                        label: {
                            Button { } label: {
                                Text("Next")
                                    .bold()
                                    .frame(maxWidth: .infinity)
                            }
                        })
                }
            }
            .frame(maxWidth: 500)
            .navigationTitle("SSKR Export")
            .navigationBarItems(leading: CancelButton($isPresented))
        }
        .copyConfirmation()
        .navigationViewStyle(StackNavigationViewStyle())
    }

    struct GroupView: View {
        let index: Int
        let count: Int
        @ObservedObject var group: SSKRModelGroup

        var body: some View {
            Section(header: Text(count > 1 ? "Group \(index + 1)" : "")) {
                Stepper("Number of Shares: \(group.count)", value: $group.count.animation(), in: group.countRange)
                if group.count > 1 {
                    Stepper("Threshold: \(group.threshold)", value: $group.threshold.animation(), in: group.thresholdRange)
                    if group.count > 1 {
                        Text(group.note)
                            .font(.caption)
                    }
                }
            }
        }
    }
}

#if DEBUG

import WolfLorem

struct SSKRSetup_Previews: PreviewProvider {
    static let seed = Lorem.seed()
    static var previews: some View {
        SSKRSetup(seed: seed, isPresented: .constant(true))
            .darkMode()
    }
}

#endif
