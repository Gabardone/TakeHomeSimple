//
//  FiledImageCache.swift
//  TakeHomeSimple
//
//  Created by Óscar Morales Vivó on 1/8/23.
//

import UIKit

/**
 An image cache for an app who fetches uniquely identifiable by URL, immutable images.

 The image cache is declared as an actor as to make clear that all access to it has to happen asynchronously, but the
 implementation is mostly sequential as to keep cache consistency.

 The global dependencies on system services are abstracted away behind an implementation of the `ImageDataSource`
 protocol. Use `DefaultImageDataSource` to use the system's networking/file services, or build a mock one for testing.

 The cache will work under the assumption that the URLs will be tasked to fetch and cache are built up in the same way
 as the ones found in the sample json replies. I.e. the last components of the URL path are "\<UUID\>/size.jpg".

 The cache will also assume that all images pointed at by given URLs are immutable, and once cached no refresh would
 ever be needed unless their data were dropped from storage.

 - Note: There's some issues with actor behavior (namely that the order of calls made from a serial thread
 like the main one doesn't necessarily correspond to the order in which operations begin in the actor) which make them
 surprisingly less useful than expected in regular app use. For a cache solution like this however they are not an
 obstacle, so this is an easy way to guarantee cache correctness and avoid accidental repeated operations.
 */
actor ImageCache {
    static let shared = ImageCache(imageDataProvider: DefaultImageDataProvider())

    enum CacheError: Error, Equatable {
        case unableToDecodeLocalData
        case unableToDecodeRemoteData
    }

    init(imageDataProvider: ImageDataProvider) {
        self.imageDataProvider = imageDataProvider
    }

    private let imageDataProvider: any ImageDataProvider

    func fetchImage(imageURL: URL) throws -> Task<UIImage, Error> {
        if let inMemoryImage = inMemoryImages.object(forKey: imageURL as NSURL) {
            // Well watcha know we already have it.
            return Task { return inMemoryImage }
        }

        let fetchTask: Task<UIImage, Error>
        if let inFlightTask = inFlightTasks[imageURL] {
            fetchTask = inFlightTask
        } else {
            fetchTask = Task {
                let image: UIImage
                do {
                    // Let's just try to read the data from the file.
                    let imageData = try imageDataProvider.localData(imageURL: imageURL)// Data(contentsOf: cachedFileURL)

                    // Let's make sure we can still decode the image proper.
                    guard let decodedImage = UIImage(data: imageData) else {
                        // Somehow we stored local data that we cannot decode.
                        throw CacheError.unableToDecodeLocalData
                    }

                    image = decodedImage
                } catch {
                    // If we couldn't get the data from the file we'll have to download it.
                    let imageData = try await imageDataProvider.remoteData(imageURL: imageURL)

                    // We don't want to store the data locally if we can't decode it into an UIImage.
                    guard let decodedImage = UIImage(data: imageData) else {
                        // Well we got some data but it doesn't make for an UIImage object. We'll throw.
                        throw CacheError.unableToDecodeRemoteData
                    }

                    // Time to store locally for future tasks to find earlier.
                    try imageDataProvider.storeLocally(data: imageData, imageURL: imageURL)

                    image = decodedImage
                }

                // Update the in-memory storage. We're in an actor so this should be orderly.
                // Starting with `inMemoryImages` means that even if there's reentrancy it will do the right thing.
                inMemoryImages.setObject(image, forKey: imageURL as NSURL)

                // Now that everything is in place we can remove this oversized task as to free resources.
                inFlightTasks.removeValue(forKey: imageURL)

                return image
            }

            // The task won't start running until we're done with this method. Store it in case someone else asks for
            // this `imageURL` before the task is done.
            inFlightTasks[imageURL] = fetchTask
        }

        return fetchTask
    }

    /// Once again we're using the jankiest class in Foundation because it's the one officially supported weak dictionary.
    private let inMemoryImages = NSMapTable<NSURL, UIImage>.strongToWeakObjects()

    /**
     This keeps around the current in flight tasks so we don't accidentally try to download or read from file the
     same image more than once.
     */
    private var inFlightTasks = [URL: Task<UIImage, Error>]()
}
