//
//  DogLoaderCacheDecorator.swift
//  DavidChallenge
//
//  Created by David Castro Cisneros on 16/03/22.
//

import DogFeedFeature
import Store

/// Adds saving capability to a successful dog load
public final class FeedLoaderCacheDecorator: DogLoader {
    private let decoratee: DogLoader
    private let cache: DogFeedCache

    public init(decoratee: DogLoader, cache: DogFeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }

    public func load(completion: @escaping (DogLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            completion(result.map { dogs in
                self?.cache.save(dogs, completion: { _ in })
                return dogs
            })
        }
    }
}
