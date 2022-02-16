//
//  ActivityView.swift
//  SeedTool
//
//  Created by Wolf McNally on 7/25/21.
//

import SwiftUI
import BCFoundation
import LinkPresentation

/*
 SOURCE FILE                TRIGGER                             TEXTUAL PROMPT                  FIELD                               TITLE (FILENAME)                                    EXTENSION
 -------------------------- ----------------------------------- ------------------------------- ----------------------------------- --------------------------------------------------- -----------
 ModelObjectExport          ExportDataButton                    Share as ur:\(ur.type)          ur                                  UR for \(subject.name)                              txt
 ModelObjectExport          ExportDataButton                    Share                           ur                                  \(subject.name)                                     txt
 SSKRDisplay                ExportDataButton                    All Shares as ByteWords         sskr.bytewordsShares                SSKR Bytewords \(sskr.seed.name)                    txt
 SSKRDisplay                ExportDataButton                    All Shares as ur:crypto-sskr    sskr.urShares                       SSKR UR \(sskr.seed.name)                           txt
 SSKRSharesView             longPressAction                     NA                              share.title                         \(share.title)                                      txt
 SSKRShareSharesView        ShareButton                         NA                              bytewords                           SSKR ByteWords \(title)                             txt
 SSKRShareSharesView        ShareButton                         NA                              urString                            SSKR UR \(title)                                    txt
 SSKRShareSharesView        ShareButton                         NA                              qrCode                              SSKR QR \(title)                                    png
 SSKRShareShareExportView   longPressAction                     NA                              bytewords                           SSKR ByteWords \(title)                             txt
 SSKRShareShareExportView   longPressAction                     NA                              urString                            SSKR UR \(title)                                    txt
 SSKRShareShareExportView   longPressAction                     NA                              qrCode                              SSKR QR \(title)                                    png
 SeedRequest                ExportDataButton                    Share as ur:crypto-response     responseUR                          UR for response                                     txt
 KeyRequest                 ExportDataButton                    Share as ur:crypto-response     responseUR                          UR for key response                                 txt
 PSTBSignatureRequest       ExportDataButton                    Share                           responseUR                          UR for response                                     txt
 PSTBSignatureRequest       ExportDataButton                    Share                           responsePSBTUR                      UR for PSBT                                         txt
 PSTBSignatureRequest       ExportDataButton                    Share                           responseBase64                      PSBT Base64                                         txt
 PSTBSignatureRequest       ExportDataButton                    Share                           responseData                        SignedPSBT                                          psbt
 PSTBSignatureRequest       longPressAction                     NA                              value.btcFormat                     \(value.btcFormat)                                  txt
 PSTBSignatureRequest       longPressAction                     NA                              address                             \(address)                                          txt
 PSTBSignatureRequest       longPressAction                     NA                              origin.path.description             \(origin.path.description)                          txt
 ObjectIdentityBlock        longPressAction                     NA                              image                               Lifehash for \(model!.name)                         png
 ObjectIdentityBlock        longPressAction                     NA                              instanceDetail                      Detail of \(model.name)                             txt
 ObjectIdentityBlock        longPressAction                     NA                              fingerprintDigest                   Identifier of \(name)                               txt
 ObjectIdentityBlock        longPressAction                     NA                              name                                \(name)                                             txt
 SeedDetail                 ContextMenuItem                     ur:crypto-seed                  seed.urString                       Seed UR \(seed.name)                                txt
 SeedDetail                 ContextMenuItem                     ByteWords                       seed.byteWords                      Seed ByteWords \(seed.name)                         txt
 SeedDetail                 ContextMenuItem                     BIP39 Words                     seed.bip39.mnemonic                 Seed BIP39 \(seed.name)                             txt
 SeedDetail                 ContextMenuItem                     Hex                             seed.hex                            Seed Hex \(seed.name)                               txt
 KeyExport                  ShareButton                         Share as Base58                 key.transformedBase58WithOrigin     Base58 \(key.name)                                  txt
 KeyExport                  longPressAction                     NA                              outputDescriptor                    Output Descriptor from \(privateHDKey!.name)        txt
 KeyExport                  longPressAction                     NA                              outputBundle.ur.string              Account Descriptor from \(exportModel.seed.name)    txt
 KeyExport                  ShareOutputDescriptorAsTextButton   NA                              exportModel.outputDescriptor        Output Descriptor from \(privateHDKey!.name)        txt
 URExport                   ExportDataButton                    Share as ur:\(ur.type)          ur                                  \(title)                                            txt
 EntropyView                ShareMenuItem                       Share                           model.values                        Entropy                                             txt
 URDisplay                  URQRCode                            NA                              displayState.part                   \(title)                                            png
 */

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
    convenience init(_ string: String, title: String) {
        self.init(items: [ActivityStringSource(string: string, title: title)])
    }
    
    convenience init(_ image: UIImage, title: String) {
        self.init(items: [ActivityImageSource(image: image, title: title)])
    }
    
    convenience init(_ ur: UR, title: String) {
        self.init(ur.string, title: title)
    }
    
    convenience init(_ data: Data, title: String) {
        self.init(items: [ActivityDataSource(data: data, title: title)], excludedActivityTypes: [.copyToPasteboard])
    }
}

class ActivityStringSource: UIActivityItemProvider {
    let string: String
    let url: URL
    let title: String
    
    init(string: String, title: String) {
        self.string = string
        self.title = title
        let tempDir = FileManager.default.temporaryDirectory
        self.url = tempDir.appendingPathComponent("\(title).txt")
        super.init(placeholderItem: title)
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
        metadata.title = title
        return metadata
    }
}

class ActivityImageSource: UIActivityItemProvider {
    let url: URL
    let image: UIImage
    let title: String
    
    init(image: UIImage, title: String) {
        self.image = image
        self.title = title
        let tempDir = FileManager.default.temporaryDirectory
        self.url = tempDir.appendingPathComponent("\(title).png")
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
        metadata.title = title
        return metadata
    }
}

class ActivityDataSource: UIActivityItemProvider {
    let url: URL
    let title: String
    
    init(data: Data, title: String) {
        self.title = title
        let tempDir = FileManager.default.temporaryDirectory
        self.url = tempDir.appendingPathComponent(title)

        super.init(placeholderItem: title)

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
        metadata.title = title
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
                self.activityParams = ActivityParams("Mock text", title: "Mock Title")
            }.background(ActivityView(params: $activityParams))

            Button("Share Data") {
                self.activityParams = ActivityParams("Mock text".data(using: .utf8)!, title: "Sample Text.bin")
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
