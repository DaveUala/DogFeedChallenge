//
//  StoreTests.swift
//  StoreTests
//
//  Created by David Castro Cisneros on 09/03/22.
//

import XCTest
import Store
import DogFeedFeature

final class DogStoreSpy: DogStore {
    var fetchCallCount = 0
    var insertCallCount = 0
    var insertionCompletions = [InsertionCompletion]()
    var loadCompletions = [RetrieveCompletion]()

    func save(_ dogs: [LocalDog], completion: @escaping InsertionCompletion) {
        insertCallCount += 1
        insertionCompletions.append(completion)
    }

    func retrieve(_ completion: @escaping RetrieveCompletion) {
        fetchCallCount += 1
        loadCompletions.append(completion)
    }

    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }

    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }

    func completeLoadSuccessfully(dogs: [LocalDog], at index: Int = 0) {
        loadCompletions[index](.success(dogs))
    }

    func completeLoad(with error: Error, at index: Int = 0) {
        loadCompletions[index](.failure(error))
    }
}

final class StoreTests: XCTestCase {
    func test_init_doesNotTriggerDataLoad() {
        let (_, store) = makeSUT()

        XCTAssertEqual(store.fetchCallCount, 0)
    }

    func test_save_requestDataInsertion() {
        let dogs = makeUniqueDogs()
        let (sut, store) = makeSUT()

        sut.save(dogs.models) { _ in }

        XCTAssertEqual(store.insertCallCount, 1)
    }

    func test_save_forwardsErrorOnStoreError() {
        let dogs = makeUniqueDogs()
        let (sut, store) = makeSUT()

        var receivedResult: DogStore.InsertionResult?
        sut.save(dogs.models) { receivedResult = $0 }
        store.completeInsertion(with: NSError(domain: "test", code: 0))

        XCTAssertNotNil(receivedResult)
    }

    func test_save_forwardsSuccessOnNoStoreError() {
        let dogs = makeUniqueDogs()
        let (sut, store) = makeSUT()

        var receivedResult: DogStore.InsertionResult?
        sut.save(dogs.models) { receivedResult = $0 }
        store.completeInsertionSuccessfully()

        if case let .failure(error) = receivedResult {
            XCTFail("Expected success, got \(error) instead")
        }
    }

    func test_load_triggersStoreCall() {
        let (sut, store) = makeSUT()

        sut.load { _ in }

        XCTAssertEqual(store.fetchCallCount, 1)
    }

    func test_load_deliversErrorOnStoreError() {
        let (sut, store) = makeSUT()
        var receivedResult: Result<[Dog], Error>?

        sut.load { receivedResult = $0 }
        store.completeLoad(with: NSError(domain: "test", code: 0))

        if case let .failure(error) = receivedResult {
            XCTAssertEqual(error as NSError, NSError(domain: "test", code: 0))
        } else {
            XCTFail("No call was triggered")
        }
    }

    func test_load_deliversDogsOnSuccesfulRetrieval() {
        let (sut, store) = makeSUT()
        var receivedResult: Result<[Dog], Error>?
        let dogs = makeUniqueDogs()

        sut.load { receivedResult = $0 }
        store.completeLoadSuccessfully(dogs: dogs.locals)

        if case let .success(receivedDogs) = receivedResult {
            XCTAssertEqual(receivedDogs, dogs.models)
        } else {
            XCTFail("No call was triggered")
        }
    }

    func test_load_returnsErrorIfNoDogsAreFound() {
        let (sut, store) = makeSUT()
        var receivedResult: Result<[Dog], Error>?
        let expectedDogs = [LocalDog]()

        sut.load { receivedResult = $0 }
        store.completeLoadSuccessfully(dogs: expectedDogs)

        if case let .failure(error) = receivedResult {
            XCTAssertEqual(error as? LocalDogLoader.Error, LocalDogLoader.Error.emptyData)
        } else {
            XCTFail("No call was triggered")
        }
    }

    // MARK: - Helpers

    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalDogLoader, store: DogStoreSpy) {
        let store = DogStoreSpy()
        let sut = LocalDogLoader(store: store)

        return (sut: sut, store: store)
    }

    private func makeDog() -> Dog {
        .init(id: UUID(), name: "any", description: "any", age: 0, imageURL: URL(string: "https://www.a-url.com")!)
    }

    private func makeUniqueDogs() -> (models: [Dog], locals: [LocalDog]) {
        let models = [makeDog(), makeDog()]
        let locals = models.map { LocalDog(id: $0.id, name: $0.name, description: $0.description, age: $0.age, imageURL: $0.imageURL) }

        return (models: models, locals: locals)
    }
}
