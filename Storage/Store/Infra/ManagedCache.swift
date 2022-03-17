//
//  ManagedCache.swift
//  Store
//
//  Created by David Castro Cisneros on 11/03/22.
//

import CoreData

@objc(ManagedCache)
internal class ManagedCache: NSManagedObject {
    @NSManaged internal var dogs: NSOrderedSet
}

extension ManagedCache {
    internal var localDogs: [LocalDog] {
        return dogs.compactMap { ($0 as? ManagedDog)?.local }
    }

    internal static func find(in context: NSManagedObjectContext) throws -> ManagedCache? {
        let request = NSFetchRequest<ManagedCache>(entityName: entity().name!)
        request.returnsObjectsAsFaults = false
        return try context.fetch(request).first
    }

    internal static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedCache {
        try find(in: context).map(context.delete)
        return ManagedCache(context: context)
    }
}

