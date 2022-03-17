//
//  DogFeedRefreshViewController.swift
//  iOSComponentsUIKitSnapshotTests
//
//  Created by David Castro Cisneros on 15/03/22.
//

import UIKit
import DogFeedFeature

final class DogFeedRefreshViewController: NSObject {
    private(set) lazy var view = binded(UIRefreshControl())
    private let viewModel: DogFeedViewModel
    weak var statusLabel: UILabel?

    init(viewModel: DogFeedViewModel) {
        self.viewModel = viewModel
    }

    @objc func refresh() {
        viewModel.loadFeed()
    }

    // - MARK: MVVM Binding

    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }

        view.addTarget(self, action: #selector(refresh), for: .valueChanged)

        return view
    }
}
