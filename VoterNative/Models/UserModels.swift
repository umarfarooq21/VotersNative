import Foundation

struct User: Codable, Identifiable, Hashable {
    let id: String
    let email: String?
    let username: String?
    let firstName: String?
    let lastName: String?
    let phone: String?
    let role: String?
    let createdAt: String?

    var displayName: String {
        if let firstName, let lastName, !firstName.isEmpty || !lastName.isEmpty {
            return [firstName, lastName].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " ")
        }
        return username ?? email ?? id
    }

    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case phone
        case role
        case createdAt = "created_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let stringID = try? container.decode(String.self, forKey: .id) {
            id = stringID
        } else if let intID = try? container.decode(Int.self, forKey: .id) {
            id = String(intID)
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .id,
                in: container,
                debugDescription: "User id must be a String or Int."
            )
        }

        email = try container.decodeIfPresent(String.self, forKey: .email)
        username = try container.decodeIfPresent(String.self, forKey: .username)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        phone = try container.decodeIfPresent(String.self, forKey: .phone)
        role = try container.decodeIfPresent(String.self, forKey: .role)
        createdAt = try container.decodeIfPresent(String.self, forKey: .createdAt)
    }

    init(
        id: String,
        email: String? = nil,
        username: String? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        phone: String? = nil,
        role: String? = nil,
        createdAt: String? = nil
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.role = role
        self.createdAt = createdAt
    }
}

struct CreateUserRequest: Encodable {
    let email: String
    let username: String?
    let firstName: String?
    let lastName: String?
    let phone: String?
    let password: String?
    let role: String?

    enum CodingKeys: String, CodingKey {
        case email
        case username
        case firstName = "first_name"
        case lastName = "last_name"
        case phone
        case password
        case role
    }
}

/// Wrapper when the API returns `{ "data": [...] }` or `{ "users": [...] }`.
struct UsersListResponse: Decodable {
    let users: [User]?
    let data: [User]?

    var resolvedUsers: [User] {
        users ?? data ?? []
    }
}

extension Array where Element == User {
    init(fromFlexible data: Data) throws {
        let decoder = JSONDecoder.api

        if let users = try? decoder.decode([User].self, from: data) {
            self = users
            return
        }

        if let wrapped = try? decoder.decode(UsersListResponse.self, from: data) {
            self = wrapped.resolvedUsers
            return
        }

        throw APIError.decodingError(
            DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Unexpected users payload.")),
            endpoint: "getUsers"
        )
    }
}
