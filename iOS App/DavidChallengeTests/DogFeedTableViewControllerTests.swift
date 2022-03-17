//
//  DogFeedTableViewControllerTests.swift
//  iOSComponentsUIKitSnapshotTests
//
//  Created by David Castro Cisneros on 14/03/22.
//

import XCTest
import iOSComponentsUIKit
import DogFeedFeature
@testable import DavidChallenge

final class DogFeedTableViewControllerTests: XCTestCase {
    func test_loadFeedActions_requestsLoads() {
        let (sut, spy) = makeSUT()
        XCTAssertEqual(spy.loadCallCount, 0)

        sut.loadViewIfNeeded()
        XCTAssertEqual(spy.loadCallCount, 1)

        sut.simulateUserAction()
        XCTAssertEqual(spy.loadCallCount, 2)

        sut.simulateUserAction()
        XCTAssertEqual(spy.loadCallCount, 3)
    }

    func test_loadIndicator_isShownOnFeedLoad() {
        let (sut, spy) = makeSUT()

        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadIndicator)

        spy.completeLoading()
        XCTAssertFalse(sut.isShowingLoadIndicator)

        sut.simulateUserAction()
        XCTAssertTrue(sut.isShowingLoadIndicator)

        spy.completeLoading(with: NSError(domain: "test", code: 0), at: 1)
        XCTAssertFalse(sut.isShowingLoadIndicator)
    }

    func test_viewDidLoad_setsExpectedTitle() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.title, localized("DOG_LOCAL_TITLE"))
    }

    func test_load_rendersRetryMessageOnError() {
        let (sut, spy) = makeSUT()

        sut.loadViewIfNeeded()
        spy.completeLoading(with: anyNSError())

        XCTAssertEqual(sut.displayedError, localized("DOG_FEED_TRY_AGAIN_ERROR"))
    }

    func test_load_rendersSuccessfully() throws {
        let dog0 = makeDog(name: "dog0", description: "a description0", age: 1)
        let dog1 = makeDog(name: "dog1", description: "a description1", age: 2)
        let dog2 = makeDog(name: "dog2", description: "a description2", age: 3)
        let dog3 = makeDog(name: "dog3", description: "a description3", age: 4)
        let (sut, spy) = makeSUT()

        sut.loadViewIfNeeded()
        try assertThat(sut, isRendering: [])

        spy.completeLoading(dogs: [dog0])
        try assertThat(sut, isRendering: [dog0])

        sut.simulateUserAction()
        let dogs = [dog0, dog1, dog2, dog3]
        spy.completeLoading(dogs: dogs, at: 1)
        try assertThat(sut, isRendering: dogs)
    }

    func test_load_doesNotAlterCurrentRenderingStateOnError() throws {
        let dog0 = makeDog(name: "dog0", description: "a description0", age: 1)
        let (sut, spy) = makeSUT()

        sut.loadViewIfNeeded()
        spy.completeLoading(dogs: [dog0])
        try assertThat(sut, isRendering: [dog0])

        sut.simulateUserAction()
        spy.completeLoading(with: NSError(domain: "test", code: 0))
        try assertThat(sut, isRendering: [dog0])
    }

    func test_dogImageView_loadsImageURLWhenVisible() {
        let image0 = makeDog(url: URL(string: "http://url-0.com")!)
        let image1 = makeDog(url: URL(string: "http://url-1.com")!)
        let (sut, spy) = makeSUT()

        sut.loadViewIfNeeded()
        spy.completeLoading(dogs: [image0, image1])
        XCTAssertEqual(spy.loadedImageURLs, [], "Expected no image URL requests until views become visible")

        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(spy.loadedImageURLs, [image0.imageURL], "Expected first image url when the first view is visible")

        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(spy.loadedImageURLs, [image0.imageURL, image1.imageURL], "Expected second image url when the second view is visible")
    }

    func test_dogImageView_cancelsImageLoadingWhenNotVisible() {
        let image0 = makeDog(url: URL(string: "http://url-0.com")!)
        let image1 = makeDog(url: URL(string: "http://url-1.com")!)
        let (sut, spy) = makeSUT()

        sut.loadViewIfNeeded()
        spy.completeLoading(dogs: [image0, image1])

        XCTAssertEqual(spy.cancelledImageURLs, [], "Expected no cancelled image URL requests until image is not visible")

        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(spy.cancelledImageURLs, [image0.imageURL], "Expected one cancelled image URL request once first image is not visible anymore")

        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(spy.cancelledImageURLs, [image0.imageURL, image1.imageURL], "Expected two cancelled image URL requests once second image is also not visible anymore")
    }

    func test_loadViewIndicator_isShownWhileDownloadingImage() throws {
        let image0 = makeDog(url: URL(string: "http://url-0.com")!)
        let image1 = makeDog(url: URL(string: "http://url-1.com")!)
        let (sut, spy) = makeSUT()

        sut.loadViewIfNeeded()
        spy.completeLoading(dogs: [image0, image1])

        let view0 = try XCTUnwrap(sut.simulateFeedImageViewVisible(at: 0))
        let view1 = try XCTUnwrap(sut.simulateFeedImageViewVisible(at: 1))

        XCTAssertTrue(view0.isShowingImageLoadingIndicator, "on load request, the view should be showing an indicator")
        XCTAssertTrue(view1.isShowingImageLoadingIndicator, "on load request, the view should be showing an indicator")

        spy.completeImageLoading(at: 0)
        XCTAssertFalse(view0.isShowingImageLoadingIndicator, "on first image download it should be hidding the indicator load")
        XCTAssertTrue(view1.isShowingImageLoadingIndicator, "on load request, the view should be showing an indicator")

        spy.completeImageLoadingWithError(at: 1)
        XCTAssertFalse(view0.isShowingImageLoadingIndicator, "on first image download it should be hidding the indicator load")
        XCTAssertFalse(view1.isShowingImageLoadingIndicator, "on first image download it should be hidding the indicator load")
    }

    func test_imageView_isRenderedWithDataFromURL() throws {
        let (sut, spy) = makeSUT()

        sut.loadViewIfNeeded()
        spy.completeLoading(dogs: [
            makeDog(url: URL(string: "http://url-0.com")!),
            makeDog(url: URL(string: "http://url-1.com")!)])

        let view0 = try XCTUnwrap(sut.simulateFeedImageViewVisible(at: 0))
        let view1 = try XCTUnwrap(sut.simulateFeedImageViewVisible(at: 1))

        XCTAssertEqual(view0.renderedImage, .none, "expected no image while image is still loading")
        XCTAssertEqual(view1.renderedImage, .none, "expected no image while image is still loading")

        let image0 = UIImage.make(withColor: .red).pngData()!
        spy.completeImageLoading(with: image0, at: 0)
        XCTAssertEqual(view0.renderedImage, image0, "Expected image to appear once it has been loaded")
        XCTAssertEqual(view1.renderedImage, .none, "expected no change of state when the first image loads")

        let image1 = UIImage.make(withColor: .red).pngData()!
        spy.completeImageLoading(with: image1, at: 1)
        XCTAssertEqual(view0.renderedImage, image0, "Expected image to appear once it has been loaded")
        XCTAssertEqual(view1.renderedImage, image1, "expected no change of state when the first image loads")
    }

    func test_imageViewRetryButton_isVisibleOnDownloadError() throws {
        let (sut, spy) = makeSUT()

        sut.loadViewIfNeeded()
        spy.completeLoading(dogs: [
            makeDog(url: URL(string: "http://url-0.com")!),
            makeDog(url: URL(string: "http://url-1.com")!)])

        let view0 = try XCTUnwrap(sut.simulateFeedImageViewVisible(at: 0))
        let view1 = try XCTUnwrap(sut.simulateFeedImageViewVisible(at: 1))

        XCTAssertFalse(view0.isShowingRetryAction, "expected no retry button while image is still loading")
        XCTAssertFalse(view1.isShowingRetryAction, "expected no retry button while image is still loading")

        let image0 = UIImage.make(withColor: .red).pngData()!
        spy.completeImageLoading(with: image0, at: 0)
        XCTAssertFalse(view0.isShowingRetryAction, "Expected no retry button on success")
        XCTAssertFalse(view1.isShowingRetryAction, "expected no change of state when the first image loads")

        spy.completeImageLoadingWithError(at: 1)
        XCTAssertFalse(view0.isShowingRetryAction, "Expected no button on other image error")
        XCTAssertTrue(view1.isShowingRetryAction, "expected no change of state when the first image loads")
    }

    func test_imageViewRetryButton_retriesImageload() throws {
        let (sut, spy) = makeSUT()
        let image0 = makeDog(url: URL(string: "http://url-0.com")!)
        let image1 = makeDog(url: URL(string: "http://url-1.com")!)
        sut.loadViewIfNeeded()
        spy.completeLoading(dogs: [image0, image1])

        let view0 = try XCTUnwrap(sut.simulateFeedImageViewVisible(at: 0))
        let view1 = try XCTUnwrap(sut.simulateFeedImageViewVisible(at: 1))
        XCTAssertEqual(spy.loadedImageURLs, [image0.imageURL, image1.imageURL], "expected to loads since there are two views")

        spy.completeImageLoadingWithError(at: 0)
        spy.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(spy.loadedImageURLs, [image0.imageURL, image1.imageURL], "expected no changes in loads from before interacting with the retry action")

        view0.simulateRetryAction()
        XCTAssertEqual(spy.loadedImageURLs, [image0.imageURL, image1.imageURL, image0.imageURL], "expected to retry the image loading frmo the first image"
        )

        view1.simulateRetryAction()
        XCTAssertEqual(spy.loadedImageURLs, [image0.imageURL, image1.imageURL, image0.imageURL, image1.imageURL], "expected to retry the image loading frmo the first image"
        )
    }

    func test_imageView_removePreloadsImage_onNotNearVisibility() throws {
        let (sut, spy) = makeSUT()
        let image0 = makeDog(url: URL(string: "http://url-0.com")!)
        let image1 = makeDog(url: URL(string: "http://url-1.com")!)

        sut.loadViewIfNeeded()
        spy.completeLoading(dogs: [image0, image1])
        XCTAssertEqual(spy.cancelledImageURLs, [], "expected no loads since there is no image near")

        sut.simulateLoadOnDogInNotNearVisible(at: 0)
        XCTAssertEqual(spy.cancelledImageURLs, [image0.imageURL], "expected no loads since there is no image near")

        sut.simulateLoadOnDogInNotNearVisible(at: 1)
        XCTAssertEqual(spy.cancelledImageURLs, [image0.imageURL, image1.imageURL], "expected no loads since there is no image near")
    }

    func test_imageView_preloadsImage_onNearVisibility() throws {
        let (sut, spy) = makeSUT()
        let image0 = makeDog(url: URL(string: "http://url-0.com")!)
        let image1 = makeDog(url: URL(string: "http://url-1.com")!)

        sut.loadViewIfNeeded()
        spy.completeLoading(dogs: [image0, image1])
        XCTAssertEqual(spy.loadedImageURLs, [], "expected no loads since there is no image near")

        sut.simulateLoadOnDogNearVisible(at: 0)
        XCTAssertEqual(spy.loadedImageURLs, [image0.imageURL], "expected no loads since there is no image near")

        sut.simulateLoadOnDogNearVisible(at: 1)
        XCTAssertEqual(spy.loadedImageURLs, [image0.imageURL, image1.imageURL], "expected no loads since there is no image near")
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: DogFeedTableViewController, loader: DogLoaderSpy) {
        let spy = DogLoaderSpy()
        let sut = DogUIComposer.dogFeedComposedWith(dogLoader: spy, imageLoader: spy)

        return (sut: sut, loader: spy)
    }

    private func makeDog(name: String = "any",
                         description: String = "description",
                         age: Int = 5,
                         url: URL = URL(string: "https://www.anyurl.com")!) -> Dog {
        .init(id: UUID(), name: name, description: description, age: 0, imageURL: URL(string: "https://www.a-url.com")!)
    }

    private func assertThat(_ sut: DogFeedTableViewController, isRendering dogs: [Dog], file: StaticString = #file, line: UInt = #line) throws {
        XCTAssertEqual(sut.numberOfRenderedDogs(), dogs.count, "There's a mismatch on number of element", file: file, line: line)

        for (index, dog) in dogs.enumerated() {
            try self.assertThat(sut, hasConfigured: dog, at: index)
        }
    }

    private func assertThat(_ sut: DogFeedTableViewController, hasConfigured dog: Dog, at index: Int, file: StaticString = #file, line: UInt = #line) throws {
        let view = sut.getDog(at: index) as? CardTableViewCell

        let cell = try XCTUnwrap(view)

        XCTAssertEqual(cell.titleText, dog.name)
        XCTAssertEqual(cell.descriptionText, dog.description)
        XCTAssertEqual(cell.footerText, "Almost \(dog.age) years")
    }

}

extension DogFeedTableViewController {
    var isShowingLoadIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }

    func simulateUserAction() {
        self.refreshControl?.simulatePullToRefresh()
    }

    func simulateLoadOnDogNearVisible(at index: Int = 0) {
        let dataSource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: 0)
        dataSource?.tableView(tableView, prefetchRowsAt: [indexPath])
    }

    func simulateLoadOnDogInNotNearVisible(at index: Int = 0) {
        simulateFeedImageViewVisible(at: index)
        
        let dataSource = tableView.prefetchDataSource
        let indexPath = IndexPath(row: index, section: 0)
        dataSource?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }

    func numberOfRenderedDogs() -> Int {
        tableView(self.tableView, numberOfRowsInSection: 0)
    }

    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> CardTableViewCell? {
        return getDog(at: index) as? CardTableViewCell
    }

    func simulateFeedImageViewNotVisible(at index: Int) {
        let view = simulateFeedImageViewVisible(at: index)

        let delegate = tableView.delegate
        let indexPath = IndexPath(row: index, section: 0)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
    }

    func getDog(at index: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let indexPath = IndexPath(row: index, section: 0)
        return dataSource?.tableView(tableView, cellForRowAt: indexPath)
    }

    var displayedError: String? {
        return errorLabel.text
    }
}

extension CardTableViewCell {
    var titleText: String? { titleLabel.text }
    var descriptionText: String? { descriptionLabel.text }
    var footerText: String? { footerLabel.text }
    var isShowingImageLoadingIndicator: Bool { cardImageView.isShimmering }
    var renderedImage: Data? { cardImageView.image?.pngData() }
    var isShowingRetryAction: Bool { return !retryButton.isHidden }

    func simulateRetryAction() {
        retryButton.simulateTap()
    }
}
