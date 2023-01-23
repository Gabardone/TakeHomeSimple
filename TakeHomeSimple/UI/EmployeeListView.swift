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

    struct EmployeeDataRow: View {
        var label: String
        var info: String
        var font: Font = .caption

        var body: some View {
            GridRow {
                Text(label)
                    .gridCellAnchor(.trailing)
                Text(info)
                    .gridCellAnchor(.leading)
            }
            .font(font)
        }
    }

    var body: some View {
        VStack {
            List {
                ForEach(employeeList.employees) { employee in
                    VStack(alignment: .leading) {
                        Grid(horizontalSpacing: 4.0, verticalSpacing: 4.0) {
                            EmployeeDataRow(label: "Full name:", info: employee.fullName, font: .body)
                            if let phoneNumber = employee.phoneNumber {
                                EmployeeDataRow(label: "Phone:", info: phoneNumber)
                            }
                            EmployeeDataRow(label: "Email:", info: employee.emailAddress)
                            EmployeeDataRow(label: "Team:", info: employee.team)
                            EmployeeDataRow(label: "Type:", info: employee.category.displayName.capitalized)
                        }
                        if let biography = employee.biography {
                            Text(biography)
                                .padding(.top, 1.0)
                                .font(.footnote)
                        }
                    }
                }
            }
            .refreshable {
                do {
                    refreshError = false
                    let employeeList = try await refreshOperation()
                    self.employeeList = employeeList
                } catch {
                    refreshError = true
                }
            }
            if refreshError {
                Text("Error refreshing employee list")
                    .foregroundColor(.red)
            }
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
            biography: "The One and Only, the coolest the strongest the manliest the queerest, the Ballad of John Mastodon",
            team: "Super Awesome",
            category: .partTime
        )
    ])

    enum PreviewError: Error {
        case testError

        var localizedDescription: String {
            return "Potato"
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
