//
//  CardTableViewCellTests.swift
//  iOSComponentsUIKitTests
//
//  Created by David Castro Cisneros on 13/03/22.
//

import XCTest
import iOSComponentsUIKit

final class CardTableViewCellTests: XCTestCase {
    func test_configure_rendersData() {
        let sut = makeSUT()
        let viewModel = makeFixture()

        sut.configure(viewModel: viewModel)
        
        XCTAssertEqual(sut.titleLabel.text, viewModel.title)
        XCTAssertEqual(sut.descriptionLabel.text, viewModel.description)
        XCTAssertEqual(sut.footerLabel.text, viewModel.footer)
    }

    func test_setImage_rendersGivenImage() {
        let sut = makeSUT()
        let image = UIImage()

        sut.setImage(image)

        XCTAssertIdentical(sut.cardImageView.image, image)
    }

    func test_setStyle_rendersColors() {
        let sut = makeSUT()
        let style = CardStyle(titleColor: .red, descriptionColor: .green, footerColor: .blue, backgroundColor: .cyan, contentBackgroundColor: .brown)

        sut.setStyle(style)

        XCTAssertEqual(sut.titleLabel.textColor, style.titleColor)
        XCTAssertEqual(sut.descriptionLabel.textColor, style.descriptionColor)
        XCTAssertEqual(sut.footerLabel.textColor, style.footerColor)
        XCTAssertEqual(sut.contentView.backgroundColor, style.contentBackgroundColor)
        XCTAssertEqual(sut.content.backgroundColor, style.backgroundColor)
    }

    // MARK: - Helpers

    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CardTableViewCell {
        let sut = CardTableViewCell()

        return sut
    }

    func makeFixture() -> CardViewModel {
        return CardViewModel(title: "any title", description: "any description", footer: "footer label")
    }
}
