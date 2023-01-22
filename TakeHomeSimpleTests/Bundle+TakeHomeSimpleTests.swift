//
//  Bundle+TakeHomeSimpleTests.swift
//  TakeHomeSimpleTests
//
//  Created by Óscar Morales Vivó on 1/4/23.
//

import Foundation

/// Bundle-related utilities to facilitate JSON encoding/decoding tests.
extension Bundle {
    static let takeHomeSimpleTestsBundleID = "com.oscarmv.TakeHomeSimpleTests"

    static let takeHomeSimpleTestsBundle: Bundle = {
        guard let takeHomeSimpleTestsBundle = Bundle(identifier: takeHomeSimpleTestsBundleID) else {
            fatalError("Somehow, we haven't found the test bundle from within the tests themselves…")
        }

        return takeHomeSimpleTestsBundle
    }()

    static let singleEmployee = "single_employee"

    static let emptyEmployeeList = "employees_empty"

    static let malformedEmployeeList = "employees_malformed"

    static let sampleEmployeeList = "employees"

    enum TestError: Error {
        case resourceNotFound
    }

    static func dataForTestJSONResource(named resourceName: String) throws -> Data {
        guard let singleEmployeeURL = Bundle.takeHomeSimpleTestsBundle.url(
            forResource: resourceName,
            withExtension: ".json"
        ) else {
            throw TestError.resourceNotFound
        }

        return try Data(contentsOf: singleEmployeeURL)
    }
}
