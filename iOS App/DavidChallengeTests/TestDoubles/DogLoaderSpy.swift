//
//  DogLoaderSpy.swift
//  iOSComponentsUIKitSnapshotTests
//
//  Created by David Castro Cisneros on 15/03/22.
//

import Foundation
import DogFeedFeature
@testable import DavidChallenge

class DogLoaderSpy: DogLoader, ImageLoader {
    // MARK: - Dog Loader

    var loadCallCount: Int {
        completions.count
    }

    var completions = [(DogLoader.Result) -> Void]()

    func load(completion: @escaping (DogLoader.Result) -> Void) {
        completions.append(completion)
    }

    func completeLoading(dogs: [Dog] = [], at index: Int = 0) {
        completions[index](.success(dogs))
    }

    func completeLoading(with error: Error, at index: Int = 0) {
        completions[index](.failure(error))
    }

    // MARK: - Image Loader

    var cancelledImageURLs = [URL]()

    var loadedImageURLs: [URL] {
        imageRequests.map { $0.url }
    }

    private var imageRequests = [(url: URL, completion: (ImageLoader.Result) -> Void)]()

    func loadImageData(from url: URL, completion: @escaping (ImageLoader.Result) -> Void) -> ImageDataLoaderTask {
        imageRequests.append((url: url, completion: completion))

        return Task { [weak self] in self?.cancelledImageURLs.append(url) }
    }

    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
        imageRequests[index].completion(.success(imageData))
    }

    func completeImageLoadingWithError(at index: Int = 0) {
        imageRequests[index].completion(.failure(NSError(domain: "test", code: 0)))
    }

    private struct Task: ImageDataLoaderTask {
        let cancelCallback: () -> Void

        func cancel() {
            cancelCallback()
        }
    }
}
