//
//  iOSComponentsUIKitSnapshotTests.swift
//  iOSComponentsUIKitSnapshotTests
//
//  Created by David Castro Cisneros on 13/03/22.
//

import XCTest
import iOSComponentsUIKit
import SnapshotTesting

final class CardTableViewCellSnapshotTests: XCTestCase {
    func test_defaultState() {
        let sut = FakeTableView()
        sut.dataSource = Array(repeating: .init(viewModel: fixture(), image: .rex), count: 4)

        let navigationController = UINavigationController(rootViewController: sut)
        sut.overrideUserInterfaceStyle = .light
        let result = verifySnapshot(matching: navigationController, as: .image(on: .iPhoneX), record: false)

        XCTAssertNil(result)
    }

    func test_defaultState_darkMode() {
        let sut = FakeTableView()
        sut.dataSource = Array(repeating: .init(viewModel: fixture(), image: .rex), count: 4)

        let navigationController = UINavigationController(rootViewController: sut)
        sut.overrideUserInterfaceStyle = .dark
        let result = verifySnapshot(matching: navigationController, as: .image(on: .iPhoneX), record: false)

        XCTAssertNil(result)
    }


    // MARK: - Helpers

    private func fixture() -> CardViewModel {
        .init(title: "Rex", description: "He is much more passive and is the first to suggest to rescue and not eat The Little Pilot", footer: "Almost 5 years")
    }

    private struct TestFixture {
        let viewModel: CardViewModel
        let image: UIImage
        let style: CardStyle = .default
    }

    private final class FakeTableView: UITableViewController {
        var dataSource: [TestFixture] = [] {
            didSet {
                tableView.reloadData()
            }
        }

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .backgroundColor
            tableView.backgroundColor = .backgroundColor
            title = "Dogs We Love"
            tableView.separatorStyle = .none
            tableView.register(CardTableViewCell.self, forCellReuseIdentifier: CardTableViewCell.identifier)
        }

        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CardTableViewCell.identifier) as? CardTableViewCell else {
                return UITableViewCell()
            }

            let testFixture = dataSource[indexPath.row]
            cell.configure(viewModel: testFixture.viewModel)
            cell.setStyle(testFixture.style)
            cell.setImage(testFixture.image)

            return cell
        }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            dataSource.count
        }
    }
}
