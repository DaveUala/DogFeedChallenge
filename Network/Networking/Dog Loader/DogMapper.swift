//
//  DogMapper.swift
//  Networking
//
//  Created by David Castro Cisneros on 08/03/22.
//

import DogFeedFeature
import Foundation

public final class DogsMapper {
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteDog] {
        let jsonDecoder = JSONDecoder()

        guard response.statusCode == HTTPURLResponse.OK_200,
              let root = try? jsonDecoder.decode([RemoteDog].self, from: data) else {
                  throw RemoteDogLoader.Error.invalidData
              }

        return root
    }
}
