//
//  PrintSetup.swift
//  Gordian Seed Tool
//
//  Created by Wolf McNally on 2/3/21.
//

import SwiftUI
import SwiftUIPrint
import WolfSwiftUI
import Dispatch

extension PrintSetup where Controls == EmptyView {
    init(subject: Subject, isPresented: Binding<Bool>) {
        self.init(subject: subject, isPresented: isPresented, controls: { EmptyView() })
    }
}

struct PrintSetup<Subject, Controls>: View where Subject: Printable, Controls: View {
    let subject: Subject
    let controls: () -> Controls
    @State private var pageIndex = 0
    @Binding var isPresented: Bool
    @State private var error: Error?
    @EnvironmentObject private var model: Model
    
    init(subject: Subject, isPresented: Binding<Bool>, @ViewBuilder controls: @escaping () -> Controls) {
        self.subject = subject
        self._isPresented = isPresented
        self.controls = controls
    }

    var isAlertPresented: Binding<Bool> {
        Binding<Bool> (
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )
    }
    
    var pages: [Subject.Page] {
        subject.printPages(model: model)
    }
    
    var pageCount: Int {
        pages.count
    }

    var body: some View {
        NavigationView {
            VStack {
                controls()
                
                Button {
                    presentPrintInteractionController(pages: pages, jobName: subject.name, fitting: .fitToPaper) { result in
                        switch result {
                        case .success:
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                isPresented = false
                            }
                        case .failure(let error):
                            self.error = error
                        case .userCancelled:
                            break
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
                    page: pages[pageIndex],
                    pageSize: CGSize(width: 8.5 * pointsPerInch, height: 11 * pointsPerInch),
                    marginsWidth: .constant(0)
                )

                if pageCount > 0 {
                    HStack {
                        Button {
                            pageIndex -= 1
                        } label: {
                            Image(systemName: "arrowtriangle.left.fill")
                        }
                        .disabled(pageIndex == 0)
                        Text("Page \(pageIndex + 1) of \(pageCount)")
                        Button {
                            pageIndex += 1
                        } label: {
                            Image(systemName: "arrowtriangle.right.fill")
                        }
                        .disabled(pageIndex == pageCount - 1)
                    }
                    .font(.title2)
                }

                Spacer()
            }
            .padding()
            .navigationBarTitle("Print \(subject.name)")
            .navigationBarItems(trailing: DoneButton($isPresented))
            .alert(isPresented: isAlertPresented) {
                Alert(
                    title: Text("😿 Sorry!").font(.title),
                    message: Text(error!.localizedDescription)
                )
            }
        }
    }
}

#if DEBUG

import WolfLorem

struct PrintSetupExampleControlView: View {
    var body: some View {
        Text("Controls")
    }
}

struct ExampleCoverPage: Printable {
    let name = "Example"
    func printPages(model: Model) -> [AnyView] {
        [
            Text(name)
                .eraseToAnyView()
        ]
    }
}

struct SeedPrintSetup_Previews: PreviewProvider {
    static let model = Lorem.model()
    static let pages = PrintablePages(name: "Example", printables: [
        ExampleCoverPage().eraseToAnyPrintable(),
        model.seeds.first!.eraseToAnyPrintable()
    ])
    
    static var previews: some View {
        PrintSetup(subject: pages, isPresented: .constant(true)) {
            PrintSetupExampleControlView()
        }
        .environmentObject(Self.model)
        .preferredColorScheme(.dark)
    }
}

#endif
