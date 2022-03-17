//
//  NetworkingTests.swift
//  NetworkingTests
//
//  Created by David Castro Cisneros on 07/03/22.
//

import XCTest
import Networking
import DogFeedFeature

final class NetworkingTests: XCTestCase {
    func test_init_doesNotRequestsData() {
        let (_, clientSpy) = makeSUT()

        XCTAssertEqual(clientSpy.requestedURLs, [])
    }

    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, clientSpy) = makeSUT(url: url)

        sut.load { _ in }

        XCTAssertEqual(clientSpy.requestedURLs, [url])
    }

    func test_loadTwice_requestsDataOnDemand() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        sut.load { _ in }
        sut.load { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.connectivity), when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }


    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()

        let samples = [199,201,300,400,500]

        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData)) {
                let jsonData = Data("invalid response".utf8)
                client.complete(withStatusCode: code, data: jsonData, at: index)
            }
        }
    }

    func test_load_deliversError200HTTPReponseWithInvalidJSON() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidJSON = Data("invalidJSON".utf8)
            client.complete(withStatusCode: 200, data: invalidJSON)
        }
    }

    func test_load_deliversDogsOn200HTTPReponseWithJSONItems() {
        let (sut, client) = makeSUT()

        let dog1 = makeDogs(name: "dog 1", description: "desc 1", age: 10, url: URL(string: "https://www.any.url")!)
        let dog2 = makeDogs(name: "dog 2", description: "desc 2", age: 11, url: URL(string: "http://www.anyother.url")!)

        let dogs = [dog1.model, dog2.model]

        expect(sut, toCompleteWith: .success(dogs), when: {
            let json = makeDogsResponse([dog1.json, dog2.json])

            client.complete(withStatusCode: 200, data: json)
        })
    }


    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://www.any.url")!,
                         file: StaticString = #file,
                         line: UInt = #line) -> (sut: RemoteDogLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteDogLoader(url: url, client: client)

        return (sut: sut, client: client)
    }

    private func expect(_ sut: RemoteDogLoader,
                        toCompleteWith expectedResult: RemoteDogLoader.Result,
                        when action: () -> Void,
                        file: StaticString = #file,
                        line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedResult), .success(expectedResult)):
                XCTAssertEqual(receivedResult.count, expectedResult.count, file: file, line: line)
                for (index, dog) in receivedResult.enumerated() {
                    self.assertEqual(dog1: dog, dog2: expectedResult[index], file: file, line: line)
                }
            case let (.failure(receivedError as RemoteDogLoader.Error), .failure(expectedError as RemoteDogLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    private func failure(_ error: RemoteDogLoader.Error) -> RemoteDogLoader.Result {
        return .failure(error)
    }

    private func makeDogs(name: String,
                          description: String,
                          age: Int,
                          url: URL)
    -> (model: Dog, json: [String: Encodable]) {

        let dog = Dog(id: UUID(), name: name, description: description, age: age, imageURL: url)

        let json: [String: Encodable] = [
            "dogName": dog.name,
            "description": dog.description,
            "age": dog.age,
            "image": dog.imageURL.absoluteString
        ]

        return (model: dog, json: json)
    }

    private func makeDogsResponse(_ dogs: [[String: Encodable]]) -> Data {
        return try! JSONSerialization.data(withJSONObject: dogs)
    }

    private func assertEqual(dog1: Dog,
                             dog2: Dog,
                             file: StaticString = #file,
                             line: UInt = #line) {
        let ignoringUUID = UUID()
        let ignoringUUIDDog1 = Dog(id: ignoringUUID, name: dog1.name, description: dog1.description, age: dog1.age, imageURL: dog1.imageURL)

        let ignoringUUIDDog2 = Dog(id: ignoringUUID, name: dog2.name, description: dog2.description, age: dog2.age, imageURL: dog2.imageURL)

        XCTAssertEqual(ignoringUUIDDog1, ignoringUUIDDog2, file: file, line: line)
    }
}
