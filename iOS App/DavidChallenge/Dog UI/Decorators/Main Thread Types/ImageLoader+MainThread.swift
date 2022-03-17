//
//  ImageLoader+MainThread.swift
//  DavidChallenge
//
//  Created by David Castro Cisneros on 17/03/22.
//

import Foundation
import DogFeedFeature

extension MainQueueDispatchSanitizer: ImageLoader where T == ImageLoader {
    func loadImageData(from url: URL, completion: @escaping (ImageLoader.Result) -> Void) -> ImageDataLoaderTask {

        decoratee.loadImageData(from: url, completion: { [weak self] result in
            self?.dispatch {
                completion(result)
            }
        })
    }
}
