//
//  MockImageDataProvider.swift
//  TakeHomeSimple
//
//  Created by Óscar Morales Vivó on 1/9/23.
//

import Foundation

/**
 Simple mock image data provider for testing purposes.

 Set up its override blocks to specify the behavior you want. Lives in the main app because of Swift previews needing
 to use it 🤷🏽‍♂️
 */
struct MockImageDataProvider: ImageDataProvider {
    struct UnimplementedError: Error {}

    var remoteDataOverride: ((URL) async throws -> Data)?

    func remoteData(imageURL: URL) async throws -> Data {
        if let remoteDataOverride {
            return try await remoteDataOverride(imageURL)
        } else {
            throw UnimplementedError()
        }
    }

    var localDataOverride: ((URL) throws -> Data)?

    func localData(imageURL: URL) throws -> Data {
        if let localDataOverride {
            return try localDataOverride(imageURL)
        } else {
            throw UnimplementedError()
        }
    }

    var storeLocallyOverride: ((Data, URL) throws -> Void)?

    func storeLocally(data: Data, imageURL: URL) throws {
        if let storeLocallyOverride {
            return try storeLocallyOverride(data, imageURL)
        } else {
            throw UnimplementedError()
        }
    }
}
