//
//  DogFeedLoaderWithFallbackComposite.swift
//  DavidChallenge
//
//  Created by David Castro Cisneros on 16/03/22.
//

import DogFeedFeature

/// Attemps to fetch data from a primary source, on fail, it retries with a fallback one
public class FeedLoaderWithFallbackComposite: DogLoader {
    private let primary: DogLoader
    private let fallback: DogLoader

    public init(primary: DogLoader, fallback: DogLoader) {
        self.primary = primary
        self.fallback = fallback
    }

    public func load(completion: @escaping (DogLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case .success:
                completion(result)

            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
