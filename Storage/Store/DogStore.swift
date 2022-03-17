//
//  DogStore.swift
//  Store
//
//  Created by David Castro Cisneros on 10/03/22.
//

public protocol DogStore {
    typealias InsertionResult = Result<Void, Error>
    typealias InsertionCompletion = (InsertionResult) -> Void

    typealias RetrieveResult = Result<[LocalDog], Error>
    typealias RetrieveCompletion = (RetrieveResult) -> Void

    func save(_ dogs: [LocalDog], completion: @escaping InsertionCompletion)
    func retrieve(_ completion: @escaping RetrieveCompletion)
}
