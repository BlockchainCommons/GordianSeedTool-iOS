//
//  SSKRExport.swift
//  Fehu
//
//  Created by Wolf McNally on 12/16/20.
//

import SwiftUI
import WolfSwiftUI

struct SSKRExport: View {
    let seed: Seed
    @Binding var isPresented: Bool
    @StateObject private var model: Model

    init(seed: Seed, isPresented: Binding<Bool>) {
        self.seed = seed
        self._isPresented = isPresented
        self._model = StateObject(wrappedValue: Model())
    }

    class Model: ObservableObject {
        @Published var numberOfGroups: Int = 1 {
            didSet {
                syncGroups()
            }
        }

        @Published var groupsRange: ClosedRange<Int> = 1...16
        @Published var groupThreshold: Int = 1
        @Published var groupThresholdRange: ClosedRange<Int> = 1...1
        @Published var groups: [ModelGroup] = [ModelGroup()]

        func syncGroups() {
            withAnimation {
                while groups.count > numberOfGroups {
                    groups.removeLast()
                }
                while groups.count < numberOfGroups {
                    groups.append(ModelGroup())
                }
                groupThresholdRange = 1...numberOfGroups
                groupThreshold = min(groupThreshold, groupThresholdRange.upperBound)
            }
        }

        var note: String {
            (groupThreshold == groups.count ? "All" : "\(groupThreshold) of \(groups.count)")
                + " groups must be met."
        }
    }

    class ModelGroup: ObservableObject {
        @Published var threshold: Int = 1
        @Published var count: Int = 1 {
            didSet {
                sync()
            }
        }
        @Published var countRange: ClosedRange<Int> = 1...16
        @Published var thresholdRange: ClosedRange<Int> = 1...1

        func sync() {
            withAnimation {
                thresholdRange = 1...count
                threshold = min(threshold, thresholdRange.upperBound)
            }
        }

        var note: String {
            (threshold == count ? "All" : "\(threshold) of \(count)")
                + " shares in this group must be met."
        }
    }

    var body: some View {
        Form {
            Section() {
                Stepper("Number of Groups: \(model.numberOfGroups)", value: $model.numberOfGroups.animation(), in: model.groupsRange)
                if model.groups.count > 1 {
                    Stepper("Group Threshold: \(model.groupThreshold)", value: $model.groupThreshold.animation(), in: model.groupThresholdRange)
                    Text(model.note)
                        .font(.caption)
                }
            }
            ForEach(model.groups.indices, id: \.self) { index in
                GroupView(index: index, count: model.groups.count, group: model.groups[index])
            }
        }
        .font(.callout)
        .frame(maxWidth: 500)
        .topBar(leading: CancelButton() { }, trailing: DoneButton() { })
        .padding()
    }

    struct GroupView: View {
        let index: Int
        let count: Int
        @ObservedObject var group: ModelGroup

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

struct SSKRExport_Previews: PreviewProvider {
    static let seed = Lorem.seed()
    static var previews: some View {
        SSKRExport(seed: seed, isPresented: .constant(true))
            .preferredColorScheme(.dark)
    }
}

#endif
