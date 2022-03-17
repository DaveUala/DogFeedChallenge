//
//  ImageLoader.swift
//  iOSComponentsUIKitSnapshotTests
//
//  Created by David Castro Cisneros on 15/03/22.
//

import Foundation

public protocol ImageLoader {
    typealias Result = (Swift.Result<Data, Error>)

    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> ImageDataLoaderTask
}

public protocol ImageDataLoaderTask {
    func cancel()
}
