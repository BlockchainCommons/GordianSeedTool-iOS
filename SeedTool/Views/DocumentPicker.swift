//
//  DocumentPicker.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/11/21.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

public struct DocumentPickerConfiguration {
    var documentTypes: [UTType] = []
    var asCopy: Bool = false
    var allowsMultipleSelection: Bool = false
    var directoryURL: URL? = nil
}

public extension View {
    func documentPicker(
        isPresented: Binding<Bool>,
        configuration: DocumentPickerConfiguration,
        completion: @escaping ([URL]) -> Void
    ) -> some View {
        DocumentPicker(isPresented: isPresented, configuration: configuration, completion: completion)
    }
}


struct DocumentPicker: UIViewControllerRepresentable {
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        // KLUDGE: This is only necessary under Catalyst. Apparently the
        // delegate methods don't get called because the coordinator gets
        // deallocated to early. Here we create a strong reference to it
        // that we only release after a successful delegate callback.
        static var coordinator: DocumentPicker.Coordinator?

        init(_ parent: DocumentPicker) {
            self.parent = parent
            super.init()
            Self.coordinator = self
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.isPresented = false
            parent.completion(urls)
            Self.coordinator = nil
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.isPresented = false
            parent.completion([])
            Self.coordinator = nil
        }
    }
    
    @Binding var isPresented: Bool
    let configuration: DocumentPickerConfiguration
    let completion: ([URL]) -> ()
    
    init(
        isPresented: Binding<Bool>,
        configuration: DocumentPickerConfiguration,
        completion: @escaping ([URL]) -> ()
    ) {
        self._isPresented = isPresented
        self.configuration = configuration
        self.completion = completion
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: configuration.documentTypes, asCopy: configuration.asCopy)
        controller.allowsMultipleSelection = configuration.allowsMultipleSelection
        controller.directoryURL = configuration.directoryURL
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ presentingController: UIViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
