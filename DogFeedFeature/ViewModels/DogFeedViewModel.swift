//
//  DogFeedViewModel.swift
//  DavidChallenge
//
//  Created by David Castro Cisneros on 15/03/22.
//

public final class DogFeedViewModel {
    public typealias Observer<T> = (T) -> Void

    public var onLoadingStateChange: Observer<Bool>?
    public var onDogFeedLoad: Observer<[Dog]>?
    public var onFeedFail: Observer<Error>?

    private let dogLoader: DogLoader

    public init(dogLoader: DogLoader) {
        self.dogLoader = dogLoader
    }

    public func loadFeed() {
        onLoadingStateChange?(true)
        dogLoader.load(completion: { [weak self] result in
            switch result {
            case let .success(dogs):
                self?.onDogFeedLoad?(dogs)
            case let .failure(error):
                self?.onFeedFail?(error)
            }
            self?.onLoadingStateChange?(false)
        })
    }
}
