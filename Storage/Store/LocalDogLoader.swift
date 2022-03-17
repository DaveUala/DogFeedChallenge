//
//  LocalDogLoader.swift
//  Store
//
//  Created by David Castro Cisneros on 10/03/22.
//

import DogFeedFeature


public final class LocalDogLoader: DogLoader {
    public typealias SaveCompletion = DogStore.InsertionCompletion
    public typealias LoadCompletion = DogStore.RetrieveCompletion

    private let store: DogStore

    public enum Error: Swift.Error {
        case emptyData
    }

    public init(store: DogStore) {
        self.store = store
    }

    public func load(completion: @escaping (DogLoader.Result) -> Void) {
        store.retrieve { result in
            switch result {
            case let .success(dogs):
                completion(LocalDogLoader.complete(with: dogs))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    static private func complete(with dogs: [LocalDog]) -> DogLoader.Result {
        if dogs.isEmpty {
            return .failure(LocalDogLoader.Error.emptyData)
        }

        return .success(dogs.toModels())
    }
}

extension LocalDogLoader: DogFeedCache {
    public func save(_ dogs: [Dog], completion: @escaping SaveCompletion) {
        store.save(dogs.toLocal()) { result in
            switch result {
            case .success():
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

private extension Array where Element == Dog {
    func toLocal() -> [LocalDog] {
        return map { LocalDog(id: $0.id,
                              name: $0.name,
                              description: $0.description,
                              age: $0.age,
                              imageURL: $0.imageURL)
        }
    }
}

private extension Array where Element == LocalDog {
    func toModels() -> [Dog] {
        return map { Dog(id: $0.id,
                         name: $0.name,
                         description: $0.description,
                         age: $0.age,
                         imageURL: $0.imageURL) }
    }
}
