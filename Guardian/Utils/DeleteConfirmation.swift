//
//  DeleteConfirmation.swift
//  Gordian Guardian
//
//  Created by Wolf McNally on 12/11/20.
//

import SwiftUI

extension DynamicViewContent {
    func onConfirmedDelete(title: @escaping (IndexSet) -> String, message: String? = nil, action: @escaping (IndexSet) -> Void) -> some View {
        DeleteConfirmation(source: self, title: title, message: message, action: action)
    }
}

struct DeleteConfirmation<Source>: View where Source: DynamicViewContent {
    let source: Source
    let title: (IndexSet) -> String
    let message: String?
    let action: (IndexSet) -> Void
    @State var indexSet: IndexSet = []
    @State var isPresented: Bool = false

    var body: some View {
        source
            .onDelete { indexSet in
                self.indexSet = indexSet
                isPresented = true
            }
            .alert(isPresented: $isPresented) {
                Alert(
                    title: Text(title(indexSet)),
                    message: message == nil ? nil : Text(message!),
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(
                        Text("Delete"),
                        action: {
                            withAnimation {
                                action(indexSet)
                            }
                        }
                    )
                )
            }
    }
}
