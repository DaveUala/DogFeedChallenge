//
//  DogFeedTableViewController.swift
//  DavidChallenge
//
//  Created by David Castro Cisneros on 11/03/22.
//

import UIKit
import iOSComponentsUIKit

final class DogFeedTableViewController: UITableViewController {
    private var refreshController: DogFeedRefreshViewController?
    private(set) lazy var errorLabel: UILabel = .makeWithUnlimitedLines(size: 17.0)
    lazy var dataSource = makeDiffableDataSource()
    var tableModel = [DogImageCellController]() {
        didSet {
            display(cellControllers: tableModel)
        }
    }

    convenience init(refreshController: DogFeedRefreshViewController) {
        self.init()
        self.refreshController = refreshController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
        layoutController()
        setUpTableView()
        setUpRefreshControl()
    }

    // MARK: - Private functions

    private func cellController(forRowAt indexPath: IndexPath) -> DogImageCellController {
        return tableModel[indexPath.row]
    }

    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        tableModel[indexPath.row].cancelLoad()
    }

    private func display(cellControllers: [DogImageCellController]) {
      var snapshot = NSDiffableDataSourceSnapshot<Int, DogImageCellController>()
      snapshot.appendSections([0])
      snapshot.appendItems(cellControllers)
      dataSource.apply(snapshot)
    }

    private func makeDiffableDataSource() -> UITableViewDiffableDataSource<Int, DogImageCellController> {
        .init(tableView: tableView) { tableView, _, cellController in
            return cellController.view(tableView: tableView)
        }
    }

    private func setUpRefreshControl() {
        refreshControl = refreshController?.view
        refreshController?.refresh()
    }

    private func setUpUI() {
        let titleLocalKey = "DOG_LOCAL_TITLE"
        title = NSLocalizedString(titleLocalKey, comment: "")

        view.backgroundColor = .contentBackgroundColor
    }

    private func layoutController() {
        view.addSubview(errorLabel)
        errorLabel.centerX(inView: view, topAnchor: view.topAnchor, paddingTop: .smallSpace)
    }

    private func setUpTableView() {
        tableView.prefetchDataSource = self
        tableView.separatorStyle = .none
        tableView.register(CardTableViewCell.self, forCellReuseIdentifier: CardTableViewCell.identifier)
        dataSource.defaultRowAnimation = .fade
        tableView.dataSource = dataSource
    }
}

// MARK: - DataSource

extension DogFeedTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableModel.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view(tableView: tableView)
    }

}

// MARK: - Delegate

extension DogFeedTableViewController {
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
}

// MARK: - Prefetching

extension DogFeedTableViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelCellControllerLoad)
    }
}
