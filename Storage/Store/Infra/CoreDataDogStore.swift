//
//  CoreDataDogStore.swift
//  Store
//
//  Created by David Castro Cisneros on 11/03/22.
//

import CoreData

public final class CoreDataDogStore: DogStore {
    private static let modelName = "DogDataStore"
    private static let model = NSManagedObjectModel.with(name: modelName, in: Bundle(for: CoreDataDogStore.self))
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext

    enum StoreError: Error {
        case modelNotFound
        case failedToLoadPersistentContainer(Error)
    }

    public init(storeURL: URL) throws {
        guard let model = CoreDataDogStore.model else {
            throw StoreError.modelNotFound
        }

        do {
            container = try NSPersistentContainer.load(name: CoreDataDogStore.modelName, model: model, url: storeURL)
            context = container.newBackgroundContext()
        } catch {
            throw StoreError.failedToLoadPersistentContainer(error)
        }
    }

    public func save(_ dogs: [LocalDog], completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                let managedDogs = try ManagedCache.newUniqueInstance(in: context)
                managedDogs.dogs = ManagedDog.dogs(from: dogs, in: context)

                try context.save()
            })
        }
    }

    public func retrieve(_ completion: @escaping RetrieveCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    return $0.localDogs
                } ?? []
            })
        }
    }

    private func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
}
