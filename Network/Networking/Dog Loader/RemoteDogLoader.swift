//
//  RemoteDogLoader.swift
//  Networking
//
//  Created by David Castro Cisneros on 08/03/22.
//

import Foundation
import DogFeedFeature

public final class RemoteDogLoader: DogLoader {
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    private let url: URL
    private let client: HTTPClient

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public typealias Result = DogLoader.Result

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url, completion: { result in

                switch result {

                case let .success((data, response)):
                    completion(RemoteDogLoader.map(data, from: response))
                case .failure:
                    completion(.failure(Error.connectivity))
                }

        })
    }

    // MARK: - Private Methods

    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let remoteDogs = try DogsMapper.map(data, from: response)
            return .success(remoteDogs.toModel())
        } catch {
            return .failure(RemoteDogLoader.Error.invalidData)
        }
    }
}

private extension Array where Element == RemoteDog {
    func toModel() -> [Dog] {
        return map { .init(id: UUID(),
                           name: $0.dogName,
                           description: $0.description,
                           age: $0.age,
                           imageURL: $0.image)
        }
    }
}
