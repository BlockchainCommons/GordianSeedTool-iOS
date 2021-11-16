//
//  ActivityView.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/25/21.
//

import SwiftUI
import URKit
import LinkPresentation

struct ActivityParams {
    let items: [Any]
    let activities: [UIActivity]?
    let completion: UIActivityViewController.CompletionWithItemsHandler?
    let excludedActivityTypes: [UIActivity.ActivityType]?

    init(items: [Any], activities: [UIActivity]? = nil, completion: UIActivityViewController.CompletionWithItemsHandler? = nil, excludedActivityTypes: [UIActivity.ActivityType]? = nil) {
        self.items = items
        self.activities = activities
        self.completion = completion
        self.excludedActivityTypes = excludedActivityTypes
    }
}

extension ActivityParams {
    init(_ string: String) {
        self.init(items: [string])
    }
    
    init(_ image: UIImage, title: String?) {
        self.init(items: [ActivityImageSource(image: image, title: title)])
    }
    
    init(_ ur: UR) {
        self.init(ur.string)
    }
    
    init(_ data: Data, filename: String) {
        self.init(items: [ActivityDataSource(data: data, filename: filename)], excludedActivityTypes: [.copyToPasteboard])
    }
}

class ActivityImageSource: UIActivityItemProvider {
    let image: UIImage
    let title: String?
    
    init(image: UIImage, title: String?) {
        self.image = image
        self.title = title
        super.init(placeholderItem: image)
    }

    override var item: Any {
        image
    }

    override func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let imageProvider = NSItemProvider(object: image)
        let metadata = LPLinkMetadata()
        metadata.imageProvider = imageProvider
        metadata.title = title
        return metadata
    }
}

class ActivityDataSource: UIActivityItemProvider {
    let url: URL
    let filename: String
    
    init(data: Data, filename: String) {
        self.filename = filename
        let tempDir = FileManager.default.temporaryDirectory
        self.url = tempDir.appendingPathComponent(filename)

        super.init(placeholderItem: filename)

        try? data.write(to: url)
    }
    
    deinit {
        try? FileManager.default.removeItem(at: url)
    }

    override var item: Any {
        url
    }
    
    override func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "PSBT"
    }

    override func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
        let metadata = LPLinkMetadata()
        metadata.title = filename
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
                self.activityParams = ActivityParams("Mock text")
            }.background(ActivityView(params: $activityParams))

            Button("Share Data") {
                self.activityParams = ActivityParams("Mock text".data(using: .utf8)!, filename: "Sample Text.bin")
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
