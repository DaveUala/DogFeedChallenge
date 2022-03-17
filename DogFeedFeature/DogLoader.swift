//
//  DogLoader.swift
//  Networking
//
//  Created by David Castro Cisneros on 08/03/22.
//

import Foundation

public protocol DogLoader {
    typealias Result = Swift.Result<[Dog], Error>

    func load(completion: @escaping (Result) -> Void)
}

public protocol DogFeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [Dog], completion: @escaping (Result) -> Void)
}
