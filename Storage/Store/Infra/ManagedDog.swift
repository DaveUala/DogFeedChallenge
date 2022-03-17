//
//  ManagedDog.swift
//  Store
//
//  Created by David Castro Cisneros on 11/03/22.
//

import CoreData

@objc(ManagedDog)
class ManagedDog: NSManagedObject {
    @NSManaged internal var id: UUID
    @NSManaged internal var name: String
    @NSManaged internal var dogDescription: String
    @NSManaged internal var age: Int
    @NSManaged internal var imgURL: URL
}

extension ManagedDog {
    static func dogs(from localDogs: [LocalDog], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localDogs.map { local in
            let managed = ManagedDog(context: context)

            managed.id = local.id
            managed.name = local.name
            managed.dogDescription = local.description
            managed.age = local.age
            managed.imgURL = local.imageURL

            return managed
        })
    }

    internal var local: LocalDog {
        return LocalDog(id: id, name: name, description: dogDescription, age: age, imageURL: imgURL)
    }
}

