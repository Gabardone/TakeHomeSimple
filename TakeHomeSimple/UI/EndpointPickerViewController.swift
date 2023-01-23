//
//  ViewController.swift
//  TakeHomeSimple
//
//  Created by Óscar Morales Vivó on 1/4/23.
//

import UIKit

class EndpointPickerViewController: UIViewController {}

// MARK: - Data Fetch

extension EndpointPickerViewController {
    /**
     - Todo: Abstract away `URLSession` for testability.
     */
    private func fetchData(sourceURL: URL) {
        // Build a `Task` that we'll use to `await` the results in the loading view controller
        let fetchViewController = FetchViewController {
            let (data, _) = try await URLSession.shared.data(from: sourceURL)

            // If you're on a good network, you won't have time to see the loading UI unless you add a delay here.
            // try await Task.sleep(nanoseconds: NSEC_PER_SEC * x)

            // In case things got canceled while downloading.
            try Task.checkCancellation()

            // Decode it as well.
            let decoder = JSONDecoder()
            return try decoder.decode(EmployeeList.self, from: data)
        }
        navigationController?.pushViewController(fetchViewController, animated: true)
    }
}

// MARK: - Control Actions

extension EndpointPickerViewController {
    private static let sampleDataURL = URL(string: "https://<private>/employees.json")!

    @IBAction
    private func fetchSampleData() {
        fetchData(sourceURL: Self.sampleDataURL)
    }

    private static let malformedDataURL = URL(string: "https://<private>/employees_malformed.json")!

    @IBAction
    private func fetchMalformedData() {
        fetchData(sourceURL: Self.malformedDataURL)
    }

    private static let emptyDataURL = URL(string: "https://<private>/employees_empty.json")!

    @IBAction
    private func fetchEmptyData() {
        fetchData(sourceURL: Self.emptyDataURL)
    }
}
