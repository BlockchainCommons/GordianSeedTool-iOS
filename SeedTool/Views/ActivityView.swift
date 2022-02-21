//
//  ActivityView.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/25/21.
//

import SwiftUI
import BCFoundation
import LinkPresentation

class ActivityParams {
    let items: [Any]
    let activities: [UIActivity]?
    let completion: UIActivityViewController.CompletionWithItemsHandler?
    let excludedActivityTypes: [UIActivity.ActivityType]?
    
    init(items: [Any], activities: [UIActivity]? = nil, completion: UIActivityViewController.CompletionWithItemsHandler? = nil, excludedActivityTypes: [UIActivity.ActivityType]? = nil) {
        self.items = items
        self.activities = [activities, [PasteboardActivity()]].compactMap { $0 }.flatMap { $0 }
        self.completion = completion
        self.excludedActivityTypes = excludedActivityTypes
    }
}

extension ActivityParams {
    convenience init(_ string: String, export: Export) {
        self.init(items: [ActivityStringSource(string: string, export: export)])
    }
    
    convenience init(_ image: UIImage, export: Export) {
        self.init(items: [ActivityImageSource(image: image, export: export)])
    }
    
    convenience init(_ ur: UR, export: Export) {
        self.init(ur.string, export: export)
    }
    
    convenience init(_ data: Data, export: Export) {
        self.init(items: [ActivityDataSource(data: data, export: export)], excludedActivityTypes: [.copyToPasteboard])
    }
}

class ActivityStringSource: UIActivityItemProvider {
    let string: String
    let url: URL
    let export: Export
    
    init(string: String, export: Export) {
        self.string = string
        self.export = export
        let tempDir = FileManager.default.temporaryDirectory
        self.url = tempDir.appendingPathComponent("\(export.filename).txt")
        super.init(placeholderItem: export.placeholder)
        try? string.utf8Data.write(to: url)
    }
    
    deinit {
        try? FileManager.default.removeItem(at: url)
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if activityType == .copyToPasteboard {
            return string
        } else {
            return url
        }
    }
    
    override func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = export.placeholder
        return metadata
    }
}

class ActivityImageSource: UIActivityItemProvider {
    let url: URL
    let image: UIImage
    let export: Export

    init(image: UIImage, export: Export) {
        self.image = image
        self.export = export
        let tempDir = FileManager.default.temporaryDirectory
        self.url = tempDir.appendingPathComponent("\(export.filename).png")
        super.init(placeholderItem: image)
        try? image.pngData()!.write(to: url)
    }
    
    deinit {
        try? FileManager.default.removeItem(at: url)
    }
    
    override func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if activityType == .copyToPasteboard {
            return image
        } else {
            return url
        }
    }

    override func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let imageProvider = NSItemProvider(object: image)
        let metadata = LPLinkMetadata()
        metadata.imageProvider = imageProvider
        metadata.title = export.placeholder
        return metadata
    }
}

class ActivityDataSource: UIActivityItemProvider {
    let url: URL
    let export: Export

    init(data: Data, export: Export) {
        self.export = export
        let tempDir = FileManager.default.temporaryDirectory
        self.url = tempDir.appendingPathComponent(export.filename)

        super.init(placeholderItem: export.placeholder)

        try? data.write(to: url)
    }
    
    deinit {
        try? FileManager.default.removeItem(at: url)
    }

    override var item: Any {
        url
    }
    
//    override func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
//        return "PSBT"
//    }

    override func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = export.placeholder
        return metadata
    }
}

struct ActivityView: UIViewControllerRepresentable {
    @Binding var params: ActivityParams?

    init(params: Binding<ActivityParams?>) {
        _params = params
    }

    func makeUIViewController(context: Context) -> ActivityViewControllerWrapper {
        ActivityViewControllerWrapper() {
            params = nil
        }
    }

    func updateUIViewController(_ uiViewController: ActivityViewControllerWrapper, context: Context) {
        uiViewController.params = params
        uiViewController.updateState()
    }

}

final class ActivityViewControllerWrapper: UIViewController {
    var params: ActivityParams?
    let completion: () -> Void
    
    init(completion: @escaping () -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        updateState()
    }

    fileprivate func updateState() {
        guard presentedViewController == nil, let myParams = params else {
            return
        }

        let controller = UIActivityViewController(activityItems: myParams.items, applicationActivities: myParams.activities)
        controller.popoverPresentationController?.sourceView = view
        controller.excludedActivityTypes = myParams.excludedActivityTypes
        controller.completionWithItemsHandler = { [weak self] (activityType, success, items, error) in
            myParams.completion?(activityType, success, items, error)
            self?.completion()
        }
        present(controller, animated: true, completion: nil)
    }

}

#if DEBUG

struct ActivityViewTest: View {
    @State private var activityParams: ActivityParams?
    var body: some View {
        VStack {
            Button("Share Text") {
                self.activityParams = ActivityParams("Mock text", export: Export(name: "Mock Filename"))
            }.background(ActivityView(params: $activityParams))

            Button("Share Data") {
                self.activityParams = ActivityParams("Mock text".data(using: .utf8)!, export: Export(name: "Sample Data"))
            }.background(ActivityView(params: $activityParams))
        }
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityViewTest()
//            .previewDevice("iPhone 8 Plus")
    }
}

#endif
