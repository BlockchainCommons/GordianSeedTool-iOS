//
//  SeedPrintSetup.swift
//  Guardian
//
//  Created by Wolf McNally on 2/3/21.
//

import SwiftUI
import SwiftUIPrint
import WolfSwiftUI
import Dispatch

struct SeedPrintSetup: View {
    let seed: Seed
    @Binding var isPresented: Bool
    @State private var error: Error?

    var page: some View {
        SeedBackupPage(seed: seed)
    }

    var isAlertPresented: Binding<Bool> {
        Binding<Bool> (
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )
    }

    var body: some View {
        NavigationView {
            VStack {
                Button {
                    presentPrintInteractionController(page: page, fitting: .fitToPaper) { result in
                        switch result {
                        case .success:
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                isPresented = false
                            }
                        case .failure(let error):
                            self.error = error
                        }
                    }
                } label: {
                    Label("Print", systemImage: "printer")
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10.0)
                                .stroke(lineWidth: 2.0)
                        )
                }
                PagePreview(
                    page: page,
                    pageSize: .constant(CGSize(width: 8.5 * 72, height: 11 * 72)),
                    marginsWidth: .constant(0)
                )
                Spacer()
            }
            .padding()
            .navigationBarTitle("Print Seed")
            .navigationBarItems(leading: doneButton)
            .alert(isPresented: isAlertPresented) {
                Alert(
                    title: Text("😿 Sorry!").font(.title),
                    message: Text(error!.localizedDescription)
                )
            }
        }
    }

    var doneButton: some View {
        DoneButton() {
            isPresented = false
        }
    }
}

#if DEBUG

import WolfLorem

struct SeedPrintSetup_Previews: PreviewProvider {
    static let seed = Lorem.seed()
    
    static var previews: some View {
        SeedPrintSetup(seed: seed, isPresented: .constant(true))
            .preferredColorScheme(.dark)
    }
}

#endif
