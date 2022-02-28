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
    init(subject: Binding<Subject>, isPresented: Binding<Bool>) {
        self.init(subject: subject, isPresented: isPresented, controls: { EmptyView() })
    }
}

struct PrintSetup<Subject, Controls>: View where Subject: Printable, Controls: View {
    @Binding var subject: Subject
    let controls: () -> Controls
    @Binding var isPresented: Bool
    @EnvironmentObject private var model: Model

    @State private var pageIndex = 0
    @State private var error: Error?
    @State var pages: [Subject.Page] = []
    @State var pageCount: Int = 0
    
    init(subject: Binding<Subject>, isPresented: Binding<Bool>, @ViewBuilder controls: @escaping () -> Controls) {
        self._subject = subject
        self._isPresented = isPresented
        self.controls = controls
    }

    var isAlertPresented: Binding<Bool> {
        Binding<Bool> (
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )
    }
    
    func subjectUpdated() {
        pages = subject.printPages
        pageCount = pages.count
        pageIndex = 0
    }
    
    var body: some View {
        NavigationView {
            VStack {
                controls()
                
                Button {
                    presentPrintInteractionController(pages: pages, jobName: subject.jobName, fitting: .fitToPaper) { result in
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
                if pageCount > 0 {
                    PagePreview(
                        page: pages[pageIndex],
                        pageSize: CGSize(width: 8.5 * pointsPerInch, height: 11 * pointsPerInch),
                        marginsWidth: .constant(0)
                    )

                    HStack {
                        Button {
                            pageIndex -= 1
                        } label: {
                            Image.navigation(.previous)
                        }
                        .disabled(pageIndex == 0)
                        Text("Page \(pageIndex + 1) of \(pageCount)")
                        Button {
                            pageIndex += 1
                        } label: {
                            Image.navigation(.next)
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
        .onAppear {
            subjectUpdated()
        }
        .onChange(of: subject) { _ in
            subjectUpdated()
        }
    }
}

#if DEBUG

import WolfLorem
import Combine

struct PrintSetupExampleControlView: View {
    @Binding var useCoverPage: Bool
    
    var body: some View {
        Toggle("Cover Page", isOn: $useCoverPage)
    }
}

struct ExampleCoverPage: Printable {
    let name = "Cover Page"
    var printPages: [AnyView] {
        [
            Text(name)
                .eraseToAnyView()
        ]
    }
    
    var printExportFields: ExportFields {
        [:]
    }
}

class PrintExampleModel: ObservableObject {
    let model = Lorem.model()
    @Published var useCoverPage: Bool
    @Published var subject: PrintablePages
    var bag: Set<AnyCancellable> = []
        
    init() {
        self._useCoverPage = Published(initialValue: true)
        self._subject = Published(initialValue: Self.pages(useCoverPage: true, model: model))
        
        $useCoverPage.sink { [weak self] in
            guard let self = self else { return }
            self.subject = Self.pages(useCoverPage: $0, model: self.model)
        }.store(in: &bag)
    }
    
    static func pages(useCoverPage: Bool, model: Model) -> PrintablePages {
        PrintablePages(name: "Example", printExportFields: [:], printables: [
            useCoverPage ? ExampleCoverPage().eraseToAnyPrintable() : nil,
            model.seeds.first!.eraseToAnyPrintable()
        ].compactMap { $0 })
    }
}

struct SeedPrintSetup_Previews: PreviewProvider {
    @ObservedObject static var printModel = PrintExampleModel()
    
    static var previews: some View {
        PrintSetup(subject: $printModel.subject, isPresented: .constant(true)) {
            PrintSetupExampleControlView(useCoverPage: $printModel.useCoverPage)
        }
        .environmentObject(printModel.model)
        .preferredColorScheme(.dark)
.previewInterfaceOrientation(.portraitUpsideDown)
    }
}

#endif
