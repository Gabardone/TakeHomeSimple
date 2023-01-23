//
//  DefaultImageDataProvider.swift
//  TakeHomeSimple
//
//  Created by Óscar Morales Vivó on 1/9/23.
//

import Foundation

/**
 The default implementation of `ImageDataProvider` uses `URLSession` to download remote content and stores local
 data in the app's `FileManager.default.temporaryFolder`, using unique file names based on its URL UUID and name.
 */
struct DefaultImageDataProvider: ImageDataProvider {
    func remoteData(imageURL: URL) async throws -> Data {
        let (imageData, _) = try await URLSession.shared.data(from: imageURL)
        return imageData
    }

    func localData(imageURL: URL) throws -> Data {
        try Data(contentsOf: FileManager.default.localCacheURLFor(remoteImageURL: imageURL))
    }

    func storeLocally(data: Data, imageURL: URL) throws {
        let localURL = FileManager.default.localCacheURLFor(remoteImageURL: imageURL)
        try data.write(to: localURL)
    }
}

private extension FileManager {
    func localCacheURLFor(remoteImageURL: URL) -> URL {
        temporaryDirectory.appending(component: remoteImageURL.storageIdentifier)
    }
}

private extension URL {
    var storageIdentifier: String {
        // A bit of a blast form the past but if it works it works.
        (pathComponents.suffix(2) as NSArray).componentsJoined(by: "-")
    }
}
