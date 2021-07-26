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

    init(items: [Any], activities: [UIActivity]? = nil, completion: UIActivityViewController.CompletionWithItemsHandler? = nil) {
        self.items = items
        self.activities = activities
        self.completion = completion
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
        controller.completionWithItemsHandler = { [weak self] (activityType, success, items, error) in
            myParams.completion?(activityType, success, items, error)
            self?.completion()
        }
        present(controller, animated: true, completion: nil)
    }

}

struct ActivityViewTest: View {
    @State private var activityParams: ActivityParams?
    var body: some View {
        return Button("Share") {
            self.activityParams = ActivityParams("Mock text")
        }.background(ActivityView(params: $activityParams))
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityViewTest()
//            .previewDevice("iPhone 8 Plus")
    }
}
