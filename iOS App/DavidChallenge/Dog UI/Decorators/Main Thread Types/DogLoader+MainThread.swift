//
//  DogLoader+MainThread.swift
//  iOSComponentsUIKit
//
//  Created by David Castro Cisneros on 17/03/22.
//

import DogFeedFeature

extension MainQueueDispatchSanitizer: DogLoader where T == DogLoader {
    func load(completion: @escaping (DogLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
