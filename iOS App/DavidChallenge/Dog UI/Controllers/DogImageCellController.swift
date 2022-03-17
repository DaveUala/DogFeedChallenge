//
//  DogImageCellController.swift
//  iOSComponentsUIKitSnapshotTests
//
//  Created by David Castro Cisneros on 15/03/22.
//

import UIKit
import DogFeedFeature
import iOSComponentsUIKit

final class DogImageCellController {
    private let id: UUID = .init()
    private let viewModel: DogImageViewModel<UIImage>

    init(viewModel: DogImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }

    func view(tableView: UITableView) -> UITableViewCell {
        let cell: CardTableViewCell = binded(tableView.dequeueReusableCell())
        viewModel.loadImageData()
        return cell
    }

    func preload() {
        viewModel.loadImageData()
    }

    func cancelLoad() {
        viewModel.cancelLoad()
    }

    // MARK: - MVVM Binding

    private func binded(_ cell: CardTableViewCell) -> CardTableViewCell {
        let cardModel = CardViewModel(title: viewModel.name, description: viewModel.description, footer: viewModel.ageDescription)
        cell.configure(viewModel: cardModel)
        cell.cardImageView.image = nil
        cell.retryButton.isHidden = true
        cell.onRetry = viewModel.loadImageData
        cell.setStyle(.default)

        viewModel.onImageLoad = { [weak cell] image in
            cell?.setImage(image)
            cell?.cardImageView.alpha = 0.5
            UIView.animate(withDuration: 0.3, animations: { [weak cell] in
                cell?.cardImageView.alpha = 1.0
            })
        }

        viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
            if isLoading {
                cell?.cardImageView.startShimmering()
            } else {
                cell?.cardImageView.stopShimmering()
            }
        }

        viewModel.onShouldRetryImageLoadingStateChange = { [weak cell] shouldRetry in
            cell?.retryButton.isHidden = !shouldRetry
        }

        return cell
    }
}

// MARK: - Diffable Data Source Requeriments

extension DogImageCellController: Equatable {
    static func == (lhs: DogImageCellController, rhs: DogImageCellController) -> Bool {
        lhs.id == rhs.id
    }
}

extension DogImageCellController: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
