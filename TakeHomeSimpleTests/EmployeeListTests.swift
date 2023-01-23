//
//  EmployeeListTests.swift
//  TakeHomeSimpleTests
//
//  Created by Óscar Morales Vivó on 1/6/23.
//

@testable import TakeHomeSimple
import XCTest

final class EmployeeListTests: XCTestCase {
    func testLoadEmptyList() throws {
        let decoder = JSONDecoder()
        let bundleListData = try Bundle.dataForTestJSONResource(named: Bundle.emptyEmployeeList)

        let emptyList = try decoder.decode(EmployeeList.self, from: bundleListData)
        XCTAssertTrue(emptyList.employees.isEmpty)
    }

    func testLoadSampleList() throws {
        let decoder = JSONDecoder()
        let sampleListData = try Bundle.dataForTestJSONResource(named: Bundle.sampleEmployeeList)

        let sampleList = try decoder.decode(EmployeeList.self, from: sampleListData)
        XCTAssertEqual(sampleList.employees.count, 11)
    }

    func testLoadMalformedList() throws {
        let decoder = JSONDecoder()
        let malformedListData = try Bundle.dataForTestJSONResource(named: Bundle.malformedEmployeeList)

        XCTAssertThrowsError(try decoder.decode(EmployeeList.self, from: malformedListData)) { error in
            // We're expecting a "key not found" error as the malformed sample is missing a "team" entry in one of the
            // employees.
            guard case .keyNotFound = error as? DecodingError else {
                XCTFail("Unexpected error type. Found \(error)")
                return
            }
        }
    }

    func testEncodeDecode() throws {
        let decoder = JSONDecoder()
        let singleEmployee = try decoder.decode(
            Employee.self,
            from: Bundle.dataForTestJSONResource(named: Bundle.singleEmployee)
        )
        let employeeList = EmployeeList(employees: [singleEmployee])

        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(employeeList)

        let decodedEmployeeList = try decoder.decode(EmployeeList.self, from: encodedData)
        XCTAssertEqual(employeeList, decodedEmployeeList)
    }
}
