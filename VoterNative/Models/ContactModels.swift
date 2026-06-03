import Foundation
import SwiftUI

// MARK: - API Models

struct Contact: Decodable, Identifiable, Hashable {
    let contactId: Int
    let name: String
    let address: String?
    let city: String?
    let phone: String?
    let relation: String?
    let voterStatus: String?
    let outreachStatus: String?
    let voterResponse: String?
    let messageStatus: String?
    let contactDescription: String?
    let createdAt: String?
    let voterId: Int?
    let relationId: Int?

    var id: String { String(contactId) }

    var displayName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var initials: String {
        let words = displayName.split(separator: " ")
        let letters = words.prefix(2).compactMap { $0.first.map(String.init) }
        return letters.joined().uppercased()
    }

    enum CodingKeys: String, CodingKey {
        case contactId = "ContactId"
        case name = "Name"
        case address = "Address"
        case city = "City"
        case phone = "Phone"
        case relation = "Relation"
        case voterStatus = "VoterStatus"
        case outreachStatus = "OutreachStatus"
        case voterResponse = "VoterResponse"
        case messageStatus = "MessageStatus"
        case contactDescription = "Description"
        case createdAt = "CreatedAt"
        case voterId = "VoterId"
        case relationId = "RelationId"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let intId = try? container.decode(Int.self, forKey: .contactId) {
            contactId = intId
        } else if let stringId = try? container.decode(String.self, forKey: .contactId),
                  let intId = Int(stringId) {
            contactId = intId
        } else {
            contactId = 0
        }

        name = container.decodeFlexibleString(forKey: .name) ?? "Unknown Contact"
        address = container.decodeFlexibleString(forKey: .address)
        city = container.decodeFlexibleString(forKey: .city)
        phone = container.decodeFlexibleString(forKey: .phone)
        relation = container.decodeFlexibleString(forKey: .relation)
        voterStatus = container.decodeFlexibleString(forKey: .voterStatus)
        outreachStatus = container.decodeFlexibleString(forKey: .outreachStatus)
        voterResponse = container.decodeFlexibleString(forKey: .voterResponse)
        messageStatus = container.decodeFlexibleString(forKey: .messageStatus)
        contactDescription = container.decodeFlexibleString(forKey: .contactDescription)
        createdAt = container.decodeFlexibleString(forKey: .createdAt)
        voterId = container.decodeFlexibleInt(forKey: .voterId)
        relationId = container.decodeFlexibleInt(forKey: .relationId)
    }
}

// MARK: - Flexible JSON Decoding

private extension KeyedDecodingContainer {
    func decodeFlexibleString(forKey key: Key) -> String? {
        guard contains(key) else { return nil }

        if (try? decodeNil(forKey: key)) == true {
            return nil
        }
        if let value = try? decode(String.self, forKey: key) {
            return value.isEmpty ? nil : value
        }
        if let value = try? decode(Int.self, forKey: key) {
            return String(value)
        }
        if let value = try? decode(Double.self, forKey: key) {
            return String(value)
        }
        if let value = try? decode(Bool.self, forKey: key) {
            return value ? "true" : "false"
        }
        return nil
    }

    func decodeFlexibleInt(forKey key: Key) -> Int? {
        guard contains(key) else { return nil }

        if (try? decodeNil(forKey: key)) == true {
            return nil
        }
        if let value = try? decode(Int.self, forKey: key) {
            return value
        }
        if let value = try? decode(String.self, forKey: key) {
            return Int(value)
        }
        if let value = try? decode(Double.self, forKey: key) {
            return Int(value)
        }
        return nil
    }
}

struct ContactsListResponse: Decodable {
    let contacts: [Contact]?
    let data: [Contact]?
    let results: [Contact]?

    var resolvedContacts: [Contact] {
        contacts ?? data ?? results ?? []
    }
}

extension Array where Element == Contact {
    init(fromFlexible data: Data) throws {
        let payload = Self.normalizedPayload(data)
        let decoder = JSONDecoder()

        do {
            self = try decoder.decode([Contact].self, from: payload)
            return
        } catch let arrayError {
            if let wrapped = try? decoder.decode(ContactsListResponse.self, from: payload),
               !wrapped.resolvedContacts.isEmpty {
                self = wrapped.resolvedContacts
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: payload) as? [String: Any],
               let message = json["message"] as? String ?? json["error"] as? String {
                throw APIError.httpError(statusCode: 200, message: message)
            }

            if let raw = String(data: payload, encoding: .utf8) {
                print("❌ getContacts decode failed: \(arrayError)")
                print("❌ getContacts raw preview: \(String(raw.prefix(400)))")
            }

            throw APIError.decodingError(arrayError, endpoint: "getContacts")
        }
    }

    private static func normalizedPayload(_ data: Data) -> Data {
        guard var text = String(data: data, encoding: .utf8) else { return data }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.data(using: .utf8) ?? data
    }
}

// MARK: - UI Model

struct ContactItem: Identifiable, Hashable {
    enum Action: Hashable {
        case recordStance
        case askToVote
    }

    let id: String
    let name: String
    let initials: String
    let color: Color
    let action: Action
    let address: String?
    let city: String?
    let phone: String?
    let email: String?
    let voteLikelihood: Int?
    let voterStatus: String?
    let relation: String?

    init(from contact: Contact, colorIndex: Int) {
        id = contact.id
        name = contact.displayName
        initials = contact.initials.isEmpty ? "?" : contact.initials
        color = ContactItem.avatarColors[colorIndex % ContactItem.avatarColors.count]
        action = ContactItem.action(
            outreachStatus: contact.outreachStatus,
            voterResponse: contact.voterResponse
        )
        address = contact.address
        city = contact.city
        phone = contact.phone?.nilIfEmpty
        email = nil
        voteLikelihood = ContactItem.voteLikelihood(from: contact.voterStatus)
        voterStatus = contact.voterStatus
        relation = contact.relation
    }

    func toDetailContact() -> DetailContact {
        let firstName = name.components(separatedBy: " ").first ?? name
        return DetailContact(
            name: name,
            firstName: firstName,
            address: address ?? "—",
            city: city ?? "—",
            phone: phone ?? "—",
            email: email ?? "—",
            voteLikelihood: voteLikelihood ?? 50,
            initials: initials,
            color: color,
            relationship: relation?.isEmpty == false ? relation! : "Roommate"
        )
    }

    private static func action(outreachStatus: String?, voterResponse: String?) -> Action {
        let combined = [outreachStatus, voterResponse]
            .compactMap { $0?.lowercased() }
            .joined(separator: " ")

        // API may send OutreachStatus as numeric code (e.g. 1).
        if combined == "1" || combined.contains("stance") || combined.contains("record") {
            return .recordStance
        }
        return .askToVote
    }

    private static func voteLikelihood(from voterStatus: String?) -> Int? {
        guard let voterStatus else { return nil }
        switch voterStatus.lowercased() {
        case "registered": return 75
        case "not registered": return 25
        default: return 50
        }
    }

    static let avatarColors: [Color] = [.red, .orange, .yellow, .green, .blue, .indigo, .purple, .pink]
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
