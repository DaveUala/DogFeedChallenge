//
//  NetworkingEndToEndTests.swift
//  NetworkingEndToEndTests
//
//  Created by David Castro Cisneros on 08/03/22.
//

import XCTest
import Networking

final class NetworkingEndToEndTests: XCTestCase {
    func test_load_getsDogsData() {
        let url = URL(string: "https://jsonblob.com/api/945366962796773376")!
        let exp = expectation(description: "Wait for load completion")
        let client = URLSessionHTTPClient()
        let loader = RemoteDogLoader(url: url, client: client)

        loader.load { result in
            switch result {
            case let .success(dogs):
                XCTAssertNotNil(dogs)
                XCTAssertGreaterThan(dogs.count, 0)
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead")
            }

            exp.fulfill()
        }

        wait(for: [exp], timeout: 20.0)
    }
}
