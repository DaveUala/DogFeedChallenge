//
//  SceneDelegate.swift
//  DavidChallenge
//
//  Created by David Castro Cisneros on 11/03/22.
//

import UIKit
import DogFeedFeature
import Networking
import Store
import CoreData
import Combine

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private lazy var store: DogStore? = makeStore()
    private lazy var cache: LocalDogLoader? = makeCache()
    private lazy var httpClient: HTTPClient = makeHTTPClientInfra()
    private lazy var remoteLoader: RemoteDogLoader = makeRemoteDogLoader()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)

        let navController = UINavigationController(rootViewController: makeInitialController())
        window.rootViewController = navController
        window.makeKeyAndVisible()
        self.window = window
    }

    func makeInitialController() -> UIViewController {
        let dogLoader = makeDogLoader()
        let imageLoader = RemoteImageLoader(client: httpClient)

        return DogUIComposer.dogFeedComposedWith(dogLoader: dogLoader, imageLoader: imageLoader)
    }
}

// MARK: - Composition Root

private extension SceneDelegate {
    func makeStore() -> DogStore? {
        do {
            return try makeCoreDataInfra()
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return nil
        }
    }

    func makeCoreDataInfra(path: String = "dog-feed-store.sqlite") throws -> CoreDataDogStore {
        try CoreDataDogStore(
            storeURL: NSPersistentContainer
                .defaultDirectoryURL()
                .appendingPathComponent(path))

    }

    func makeCache() -> LocalDogLoader? {
        if let store = self.store {
            return LocalDogLoader(store: store)
        }

        return nil
    }

    func makeHTTPClientInfra() -> URLSessionHTTPClient {
        return URLSessionHTTPClient(session: URLSession(configuration: .default))
    }

    func makeRemoteDogLoader() -> RemoteDogLoader {
        let url = URL(string: "https://jsonblob.com/api/945366962796773376")!
        let remoteLoader = RemoteDogLoader(url: url, client: httpClient)

        return remoteLoader
    }

    func makeRemoteLoaderSavingCacheOnSuccess(to cache: DogFeedCache) -> DogLoader {
        FeedLoaderCacheDecorator(decoratee: remoteLoader, cache: cache)
    }

    /// If no local feed is found or if it is empty, this will get the remote as fallback
    func makeLocalLoaderWithAPIServiceAsFallback(local: LocalDogLoader, remote: DogLoader) -> DogLoader {
        FeedLoaderWithFallbackComposite(primary: local, fallback: remote)
    }


    func makeDogLoader() -> DogLoader {
        let localLoader = cache
        let dogLoader: DogLoader

        if let cache = localLoader {
            let remoteLoader = makeRemoteLoaderSavingCacheOnSuccess(to: cache)
            dogLoader = makeLocalLoaderWithAPIServiceAsFallback(local: cache, remote: remoteLoader)
        } else {
            dogLoader = remoteLoader
        }

        return dogLoader
    }
}
