//
//  DogUIComposer.swift
//  iOSComponentsUIKitSnapshotTests
//
//  Created by David Castro Cisneros on 15/03/22.
//

import UIKit
import DogFeedFeature
import Combine

final class DogUIComposer {
    private init() { }
    
    static func dogFeedComposedWith(dogLoader: DogLoader, imageLoader: ImageLoader) -> DogFeedTableViewController {
        let mainThreadDogLoader = MainQueueDispatchSanitizer(decoratee: dogLoader)
        let mainThreadImageLoader = MainQueueDispatchSanitizer(decoratee: imageLoader)

        let viewModel = DogFeedViewModel(dogLoader: mainThreadDogLoader)
        let refreshController = DogFeedRefreshViewController(viewModel: viewModel)
        let dogFeedVC = DogFeedTableViewController(refreshController: refreshController)

        refreshController.statusLabel = dogFeedVC.errorLabel
        viewModel.onDogFeedLoad = adaptDogToCellController(sendTo: dogFeedVC, loader: mainThreadImageLoader)
        viewModel.onFeedFail = composeFailureResult(refreshController: refreshController)

        return dogFeedVC
    }

    // MARK: - Helpers

    private static func composeFailureResult(refreshController: DogFeedRefreshViewController) -> (Error) -> Void {
        return { [weak refreshController] _ in
            let tryAgainLocalKey = "DOG_FEED_TRY_AGAIN_ERROR"
            let message = NSLocalizedString(tryAgainLocalKey, comment: "")
            refreshController?.statusLabel?.text = message

        }
    }

    private static func adaptDogToCellController(sendTo controller: DogFeedTableViewController, loader: ImageLoader) -> ([Dog]) -> Void {
        return { [weak controller] dogs in
            controller?.tableModel = dogs.map {
                let viewModel = DogImageViewModel<UIImage>(model: $0, imageLoader: loader, imageTransfomer: UIImage.init(data:))
                return DogImageCellController(viewModel: viewModel)
            }
        }
    }
}
