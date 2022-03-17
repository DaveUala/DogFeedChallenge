//
//  RemoteImageLoaderTests.swift
//  NetworkingTests
//
//  Created by David Castro Cisneros on 15/03/22.
//

import XCTest
import Networking

final class RemoteImageLoaderTests: XCTestCase {
    func test_init_doesNotRequestsData() {
        let (_, clientSpy) = makeSUT()

        XCTAssertEqual(clientSpy.requestedURLs, [])
    }

    func test_loadImageData_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, clientSpy) = makeSUT(url: url)

        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(clientSpy.requestedURLs, [url])
    }

    func test_loadImageDataTwice_requestsDataOnDemand() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)

        _ = sut.loadImageData(from: url) { _ in }
        _ = sut.loadImageData(from: url) { _ in }

        XCTAssertEqual(client.requestedURLs, [url, url])
    }

    func test_loadImageData_deliversErrorOnClientError() {
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

    func test_load_deliversError200HTTPReponseWithEmptyData() {
        let (sut, client) = makeSUT()

        expect(sut, toCompleteWith: failure(.invalidData)) {
            let invalidData = Data()
            client.complete(withStatusCode: 200, data: invalidData)
        }
    }

    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let (sut, client) = makeSUT()
        let url = URL(string: "https://a-given-url.com")!

        let task = sut.loadImageData(from: url) { _ in }
        XCTAssertTrue(client.cancelledURLs.isEmpty, "Expected no cancelled URL request until task is cancelled")

        task.cancel()
        XCTAssertEqual(client.cancelledURLs, [url], "Expected cancelled URL request after task is cancelled")
    }

    func test_loadImageDataFromURL_doesNotDeliverResultAfterCancellingTask() {
        let (sut, client) = makeSUT()
        let nonEmptyData = Data("non-empty data".utf8)

        var received = [RemoteImageLoader.Result]()
        let task = sut.loadImageData(from: anyURL()) { received.append($0) }
        task.cancel()

        client.complete(withStatusCode: 404, data: anyData())
        client.complete(withStatusCode: 200, data: nonEmptyData)
        client.complete(with: anyNSError())

        XCTAssertTrue(received.isEmpty, "Expected no received results after cancelling task")
    }

    // MARK: - Helpers

    private func makeSUT(url: URL = URL(string: "https://www.any.url")!,
                         file: StaticString = #file,
                         line: UInt = #line) -> (sut: RemoteImageLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageLoader(client: client)

        return (sut: sut, client: client)
    }

    private func expect(_ sut: RemoteImageLoader, toCompleteWith expectedResult: RemoteImageLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let url = URL(string: "https://a-given-url.com")!
        let exp = expectation(description: "Wait for load completion")

        _ = sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedData), .success(expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)

            case let (.failure(receivedError as RemoteImageLoader.Error), .failure(expectedError as RemoteImageLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }

            exp.fulfill()
        }

        action()

        wait(for: [exp], timeout: 1.0)
    }

    private func failure(_ error: RemoteImageLoader.Error) -> RemoteImageLoader.Result {
        return .failure(error)
    }
}
