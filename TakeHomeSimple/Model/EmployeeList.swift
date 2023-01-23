//
//  EmployeeList.swift
//  TakeHomeSimple
//
//  Created by Óscar Morales Vivó on 1/6/23.
//

import Foundation

/**
 An encapsulation of an employee list.

 Needless to say this type is currently very dumb and is mostly good for making decoding backend payloads easier, but in
 a real-world scenario we would expect some other properties and more logic to be present here.
 */
struct EmployeeList: Codable, Equatable {
    var employees = [Employee]()
}
