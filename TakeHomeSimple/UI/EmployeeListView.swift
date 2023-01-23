//
//  EmployeeListView.swift
//  TakeHomeSimple
//
//  Created by Óscar Morales Vivó on 1/8/23.
//

import SwiftUI

struct EmployeeListView: View {
    @State
    var employeeList: EmployeeList

    @State
    var refreshError: Bool = false

    let refreshOperation: () async throws -> EmployeeList

    var body: some View {
        VStack {
            if employeeList.employees.isEmpty {
                VStack(spacing: 8.0) {
                    Text("This screen intentionally left blank.")
                    Button("Refresh…") {
                        Task {
                            await refresh()
                        }
                    }
                }
            } else {
                List {
                    ForEach(employeeList.employees) { employee in
                        EmployeeView(employee: employee)
                    }
                }
                .refreshable {
                    await refresh()
                }
            }
            if refreshError {
                Text("Error refreshing employee list")
                    .foregroundColor(.red)
            }
        }
    }

    private func refresh() async {
        do {
            refreshError = false
            let employeeList = try await refreshOperation()
            self.employeeList = employeeList
        } catch {
            refreshError = true
        }
    }
}

struct EmployeeListView_Previews: PreviewProvider {
    private static let sampleEmployeeList = EmployeeList(employees: [
        .init(
            id: UUID(),
            fullName: "Óscar Morales Vivó",
            emailAddress: "oscarmv@mac.com",
            team: "Awesome",
            category: .fullTime
        ),
        .init(
            id: UUID(),
            fullName: "John Mastodon",
            phoneNumber: "5551234567",
            emailAddress: "john@mastodon.org",
            biography: "The coolest the strongest the manliest the queerest, the Ballad of John Mastodon",
            team: "Super Awesome",
            category: .partTime
        )
    ])

    enum PreviewError: Error {
        case testError

        var localizedDescription: String {
            "Potato"
        }
    }

    static var previews: some View {
        // Starts with an error, refresh to see no error (after two seconds)
        EmployeeListView(employeeList: Self.sampleEmployeeList, refreshError: true) {
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * 2)
            return Self.sampleEmployeeList
        }
    }
}
