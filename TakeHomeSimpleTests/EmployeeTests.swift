//
//  EmployeeTests.swift
//  TakeHomeSimpleTests
//
//  Created by Óscar Morales Vivó on 1/4/23.
//

@testable import TakeHomeSimple
import XCTest

final class EmployeeTests: XCTestCase {
    /// This is the same employee data as contained in "single_employee.json"
    private static let sampleEmployee = Employee(
        id: UUID(uuidString: "0d8fcc12-4d0c-425c-8355-390b312b909c")!,
        fullName: "Justine Mason",
        phoneNumber: "5553280123",
        emailAddress: "jmason.demo@<private>.com",
        biography: "Engineer on that team.",
        thumbnailURL: URL(string: "https://<private>/16c00560-6dd3-4af4-97a6-d4754e7f2394/small.jpg")!,
        photoURL: URL(string: "https://<private>/16c00560-6dd3-4af4-97a6-d4754e7f2394/large.jpg")!,
        team: "That Team",
        category: .fullTime
    )

    func testSingleEmployeeDecoding() throws {
        let singleEmployeeData = try Bundle.dataForTestJSONResource(named: Bundle.singleEmployee)

        let decoder = JSONDecoder()
        let employee = try decoder.decode(Employee.self, from: singleEmployeeData)

        XCTAssertEqual(employee, Self.sampleEmployee)
    }

    func testSingleEmployeeEncodingAndDecoding() throws {
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(Self.sampleEmployee)

        let decoder = JSONDecoder()
        let decodedEmployee = try decoder.decode(Employee.self, from: encodedData)

        XCTAssertEqual(decodedEmployee, Self.sampleEmployee)
    }
}
