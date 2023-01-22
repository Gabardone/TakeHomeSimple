//
//  Employee.swift
//  TakeHomeSimple
//
//  Created by Óscar Morales Vivó on 1/4/23.
//

import Foundation

/**
 A value type containing the data for an employee from the directory.
 */
struct Employee: Identifiable, Equatable {
    /**
     The employment category of an employee.

     It is built to match the values passed back in the API JSON. If there were an expectation that other encodings
     could be possible we would omit them and built up a custom `Codable` implementation or set them up from their
     string values in `Employee.init(from:)`.
     */
    enum Category: String, Codable, Equatable {
        case fullTime = "FULL_TIME"
        case partTime = "PART_TIME"
        case contractor = "CONTRACTOR"

        var displayName: String {
            switch self {
            case .fullTime:
                return "full time"

            case .partTime:
                return "part time"

            case .contractor:
                return "contractor"
            }
        }
    }

    /// Unique identifier for the employee. Not for display.
    let id: UUID

    /// Full name of the employee.
    var fullName: String

    /// Phone number for the employee. May not be present.
    var phoneNumber: String?

    /// Employee's e-mail address.
    var emailAddress: String

    /// Additional employee information. May not be present.
    var biography: String?

    /// If present, URL pointing to a small format photo of the employee for display in lists and other compact UI.
    var thumbnailURL: URL?

    /// If present, URL pointing to a full size photo of the employee for larger scale display.
    var photoURL: URL?

    /// Team the employee is a part of.
    var team: String

    /// The employee's employment category, see `Employee.Category` for the available options.
    var category: Category
}

/**
 A note about `Employee` Implementing `Codable`:

 This compliance is implemented around the fact that we're encoding and decoding the values from a very specific JSON
 source. If we had to deal with multiple coding options it may end up being wiser to build intermediate types and
 encode/decode those, especially if versioning were involved.

 Thankfully we don't have to worry about such matters in the context of this project.
 */
extension Employee {
    enum CodingKeys: String, CodingKey {
        case id = "uuid"
        case fullName = "full_name"
        case phoneNumber = "phone_number"
        case emailAddress = "email_address"
        case biography = "biography"
        case thumbnailURL = "photo_url_small"
        case photoURL = "photo_url_large"
        case team
        case category = "employee_type"
    }
}

extension Employee: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        guard let uuid = UUID(uuidString: try values.decode(String.self, forKey: .id)) else {
            throw DecodingError.dataCorruptedError(forKey: .id, in: values, debugDescription: "Could not build UUID from JSON `uuid` data")
        }
        self.id = uuid
        // Should we just be forgiving and use `try?` for optional values?
        self.fullName = try values.decode(String.self, forKey: .fullName)
        self.phoneNumber = try values.decode(String?.self, forKey: .phoneNumber)
        self.emailAddress = try values.decode(String.self, forKey: .emailAddress)
        self.biography = try values.decode(String?.self, forKey: .biography)
        self.thumbnailURL = try Self.decodeURL(from: values, key: .thumbnailURL)
        self.photoURL = try Self.decodeURL(from: values, key: .photoURL)
        self.team = try values.decode(String.self, forKey: .team)
        self.category = try values.decode(Category.self, forKey: .category)
    }

    static private func decodeURL(from container: KeyedDecodingContainer<CodingKeys>, key: CodingKeys) throws -> URL? {
        try container.decode(String?.self, forKey: key).map { urlString in
            guard let thumbnailURL = URL(string: urlString) else {
                throw DecodingError.dataCorruptedError(forKey: .thumbnailURL, in: container, debugDescription: "Thumbnail URL string found not a valid URL")
            }

            return thumbnailURL
        }
    }
}

extension Employee: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(fullName, forKey: .fullName)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encode(emailAddress, forKey: .emailAddress)
        try container.encode(biography, forKey: .biography)
        try container.encode(thumbnailURL?.absoluteString, forKey: .thumbnailURL)
        try container.encode(photoURL?.absoluteString, forKey: .photoURL)
        try container.encode(team, forKey: .team)
        try container.encode(category, forKey: .category)
    }
}
