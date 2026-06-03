import Foundation

// MARK: - Request

struct SaveContactNewRequest: Encodable {
    let captainId: String
    let voterId: String
    let relationId: Int
    let desc: String
    let phone: String
    let city: String
    let contactType: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case captainId = "CaptainId"
        case voterId = "VoterId"
        case relationId = "RelationId"
        case desc = "Desc"
        case phone = "Phone"
        case city = "City"
        case contactType = "ContactType"
        case name = "Name"
    }

    init(draft: AddContactDraft, relationship: AddContactRelationship, captainId: String) {
        self.captainId = captainId
        self.voterId = draft.voterMatch.voterId
        self.relationId = relationship.relationId
        self.desc = relationship.apiDescription
        self.phone = draft.resolvedPhone
        self.city = draft.voterMatch.apiCity
        self.contactType = "Phonebook"
        self.name = draft.voterMatch.apiName
    }
}

// MARK: - Response

struct SaveContactNewResponse: Decodable {
    let success: Bool?
    let message: String?
    let contactId: Int?
    let error: String?

    enum CodingKeys: String, CodingKey {
        case success
        case message
        case contactId = "ContactId"
        case error
    }

    var resolvedMessage: String? {
        if let error, !error.isEmpty { return error }
        return message
    }

    var isSuccessful: Bool {
        if let success { return success }
        if let error, !error.isEmpty { return false }
        return contactId != nil
    }
}

enum SaveContactNewResponseParser {
    static func parse(data: Data) throws -> SaveContactNewResponse {
        let decoder = JSONDecoder()

        if let response = try? decoder.decode(SaveContactNewResponse.self, from: data) {
            return response
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return SaveContactNewResponse(
                success: json["success"] as? Bool,
                message: json["message"] as? String ?? json["Message"] as? String,
                contactId: json["ContactId"] as? Int ?? json["contactId"] as? Int,
                error: json["error"] as? String ?? json["Error"] as? String
            )
        }

        throw APIError.decodingError(
            DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "saveContactNew")),
            endpoint: "saveContactNew"
        )
    }
}
