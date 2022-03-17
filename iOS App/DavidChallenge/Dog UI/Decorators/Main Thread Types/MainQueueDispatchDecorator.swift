//
//  MainQueueDispatchDecorator.swift
//  iOSComponentsUIKit
//
//  Created by David Castro Cisneros on 17/03/22.
//

import Foundation

/// A decorator to ensure that the load is beign executed on the main thread
final class MainQueueDispatchSanitizer<T> {
    private(set) var decoratee: T

    init(decoratee: T) {
        self.decoratee = decoratee
    }

    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }

        completion()
    }
}
