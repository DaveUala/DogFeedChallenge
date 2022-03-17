//
//  DogImageViewModel.swift
//  DavidChallenge
//
//  Created by David Castro Cisneros on 15/03/22.
//

import Foundation

public final class DogImageViewModel<Image> {
    public typealias Observer<T> = (T) -> Void

    private let model: Dog
    private let imageLoader: ImageLoader
    private var task: ImageDataLoaderTask?
    private let imageTransformer: (Data) -> Image?

    public var onImageLoad: Observer<Image>?
    public var onImageLoadingStateChange: Observer<Bool>?
    public var onShouldRetryImageLoadingStateChange: Observer<Bool>?

    public var name: String { model.name }
    public var description: String { model.description }
    public var ageDescription: String { "Almost \(model.age) years" }

    public init(model: Dog, imageLoader: ImageLoader, imageTransfomer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTransformer = imageTransfomer
    }

    public func loadImageData() {
        onImageLoadingStateChange?(true)
        onShouldRetryImageLoadingStateChange?(false)
        
        task = imageLoader.loadImageData(from: model.imageURL, completion: { [weak self] result in
            self?.handle(result)
        })
    }

    public func cancelLoad() {
        task?.cancel()
    }

    private func handle(_ result: ImageLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTransformer) {
            onImageLoad?(image)
            onShouldRetryImageLoadingStateChange?(false)
        } else {
            onShouldRetryImageLoadingStateChange?(true)
        }

        self.onImageLoadingStateChange?(false)
    }
}
