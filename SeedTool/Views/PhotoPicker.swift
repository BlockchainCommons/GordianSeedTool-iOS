//
//  PhotoPicker.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/12/21.
//

import SwiftUI
import UIKit
import PhotosUI

public extension View {
    func photoPicker(
        isPresented: Binding<Bool>,
        configuration: PHPickerConfiguration,
        completion: @escaping ([PHPickerResult]) -> Void
    ) -> some View {
        PhotoPicker(isPresented: isPresented, configuration: configuration, completion: completion)
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false
            parent.completion(results)
        }
    }
    
    @Binding var isPresented: Bool
    let configuration: PHPickerConfiguration
    let completion: ([PHPickerResult]) -> Void

    internal init(isPresented: Binding<Bool>, configuration: PHPickerConfiguration, completion: @escaping ([PHPickerResult]) -> Void) {
        self._isPresented = isPresented
        self.configuration = configuration
        self.completion = completion
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}

extension PHPickerResult: ImageLoader {
    func loadImage(completion: @escaping (Result<UIImage, Error>) -> Void) {
        itemProvider.loadDataRepresentation(forTypeIdentifier: UTType.image.identifier) { data, error in
            guard let data = data else {
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.failure(GeneralError("Unknown error loading image.")))
                }
                return
            }
            guard let image = UIImage(data: data) else {
                completion(.failure(GeneralError("Could not form image from data at: \(self)")))
                return
            }
            completion(.success(image))
        }
    }
}
