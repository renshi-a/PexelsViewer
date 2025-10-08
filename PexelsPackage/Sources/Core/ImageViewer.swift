import ImageViewer
import PINRemoteImage
import SwiftUI
import UIKit

public struct ImageViewer: UIViewControllerRepresentable {
    let urls: [URL]
    let configuration: ImageViewerConfiguration
    let completion: (() -> Void)?

    public init(
        urls: [URL],
        configuration: ImageViewerConfiguration = .default(),
        completion: (() -> Void)? = nil
    ) {
        self.urls = urls
        self.configuration = configuration
        self.completion = completion
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        viewController.view.backgroundColor = .black

        if !urls.isEmpty {
            DispatchQueue.main.async {
                presentGallery(from: viewController, coordinator: context.coordinator)
            }
        }

        return viewController
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    private func presentGallery(from viewController: UIViewController, coordinator: Coordinator) {
        let galleryViewController = GalleryViewController(
            startIndex: .zero,
            itemsDataSource: coordinator,
            configuration: configuration.galleryConfiguration
        )

        galleryViewController.closedCompletion = {
            completion?()
        }

        viewController.present(galleryViewController, animated: true)
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(urls: urls)
    }

    public class Coordinator: NSObject, GalleryItemsDataSource {
        let urls: [URL]
        var currentIndex: Int = 0

        init(urls: [URL]) {
            self.urls = urls
        }

        public func itemCount() -> Int {
            urls.count
        }

        public func provideGalleryItem(_ index: Int) -> GalleryItem {
            let url = urls[index]
            return GalleryItem.image { callback in
                PINRemoteImageManager.shared().downloadImage(with: url) { result in
                    callback(result.image)
                }
            }
        }
    }
}

public struct ImageViewerConfiguration {
    public var galleryConfiguration: [GalleryConfigurationItem]

    public init(
        galleryConfiguration: [GalleryConfigurationItem] = []
    ) {
        self.galleryConfiguration = galleryConfiguration
    }

    public static func `default`() -> ImageViewerConfiguration {
        ImageViewerConfiguration(
            galleryConfiguration: [
                .closeButtonMode(.builtIn),
                .pagingMode(.standard),
                .presentationStyle(.displacement),
                .hideDecorationViewsOnLaunch(false),
                .swipeToDismissMode(.vertical),
                .toggleDecorationViewsBySingleTap(true),
                .activityViewByLongPress(true),
                .deleteButtonMode(.none),
                .thumbnailsButtonMode(.none),
                .spinnerStyle(.white),
                .statusBarHidden(true),
                .overlayColor(.black),
                .overlayColorOpacity(1),
                .overlayBlurOpacity(1),
                .overlayBlurStyle(.light),
                .videoControlsColor(.white),
                .maximumZoomScale(8),
                .swipeToDismissThresholdVelocity(500),
                .doubleTapToZoomDuration(0.15),
                .blurPresentDuration(0.3),
                .blurPresentDelay(0),
                .colorPresentDuration(0.25),
                .colorPresentDelay(0),
                .blurDismissDuration(0.3),
                .blurDismissDelay(0.1),
                .colorDismissDuration(0.25),
                .colorDismissDelay(0),
                .itemFadeDuration(0.2),
                .decorationViewsFadeDuration(0.15),
                .rotationDuration(0.2),
                .displacementDuration(0.15),
                .reverseDisplacementDuration(0.25),
                .displacementTimingCurve(.linear),
                .displacementTransitionStyle(.springBounce(0.7)),
                .displacementInsetMargin(50),
                .rotationMode(.always)
            ]
        )
    }
}
