//
//  FetchViewControllerTests.swift
//  TakeHomeSimpleTests
//
//  Created by Óscar Morales Vivó on 1/8/23.
//

@testable import TakeHomeSimple
import XCTest

/**
 Unit testing a view controller normally doesn't have enough of an upside to bother. Snapshot tests are useful to avoid
 UI regressions, especially when it comes to rarely tested dynamic UI options. Unit tests on the other hand don't make
 a lot of sense as the highly unit testable business logic _should be somewhere else_ and the integration of
 `UIViewController` with all the rest of the  frameworks mean that reproducing the environment where it runs in the
 context of a unit test to the point where the test will remain useful is a fool's errand.

 That said, this particular view controller does contain a state machine in it —to be refactored out in a future take
 home project—, and not unit testing _that_ would be a dereliction of duty. So there.
 */
final class FetchViewControllerTests: XCTestCase {
    private struct DummyEror: Error {}

    func testFailingFetch() async throws {
        let fetchExpectation = expectation(description: "Fetch block got called")
        let fetchViewController = await FetchViewController {
            fetchExpectation.fulfill()
            throw DummyEror()
        }

        _ = await fetchViewController.view

        await waitForExpectations(timeout: 1.0)

        switch await fetchViewController.loadState {
        case .error:
            // Everything is cool, Swift's `if case` syntax is just weird.
            break

        default:
            XCTFail("Fetch view controller's `loadState` ought to be .error")
        }
    }

    func testSuccessfulFetch() async throws {
        let fetchExpectation = expectation(description: "Fetch block got called")
        let fetchViewController = await FetchViewController {
            fetchExpectation.fulfill()
            return EmployeeList()
        }

        _ = await fetchViewController.view

        await waitForExpectations(timeout: 1.0)

        switch await fetchViewController.loadState {
        case .done:
            // Everything is cool, Swift's `if case` syntax is just weird.
            break

        default:
            XCTFail("Fetch view controller's `loadState` ought to be .done")
        }
    }
}
