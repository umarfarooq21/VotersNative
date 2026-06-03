import Foundation
import Contacts

// MARK: - Picked Phone Contact

struct PickedPhoneContact: Identifiable, Hashable {
    let id: String
    let givenName: String
    let familyName: String
    let fullName: String
    let phoneNumber: String?

    init(from contact: CNContact) {
        id = contact.identifier
        givenName = contact.givenName
        familyName = contact.familyName

        let composed = [givenName, familyName]
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        if composed.isEmpty {
            fullName = CNContactFormatter.string(from: contact, style: .fullName)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown Contact"
        } else {
            fullName = composed
        }

        phoneNumber = contact.phoneNumbers.first?.value.stringValue
    }
}

// MARK: - Voter File Match

struct VoterFileMatch: Identifiable, Hashable {
    let id: String
    let name: String
    let location: String
    let regCity: String
    let phone: String?
    let age: Int
    let confidence: String
    let voterStatus: String?
    let alreadySavedForCaptain: Bool

    /// `VoterId` for `saveContactNew` (state voter file id).
    var voterId: String { id }

    var apiName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    var apiCity: String {
        let city = regCity.trimmingCharacters(in: .whitespacesAndNewlines)
        return city.isEmpty ? "" : city.uppercased()
    }

    var hasValidVoterId: Bool {
        !voterId.isEmpty && voterId.allSatisfy(\.isNumber)
    }

    var detailLine: String {
        if age > 0 {
            return "\(location) • Age \(age)"
        }
        return location
    }

    var badgeLabel: String {
        confidence
            .replacingOccurrences(of: "_", with: " ")
            .uppercased()
    }

    init(from result: FuzzySearchResult) {
        id = result.stateVoterId
        name = (result.fullNames ?? "Unknown")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        regCity = result.regCity?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        location = VoterFileMatch.formattedCity(result.regCity)
        phone = result.phone?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty
        age = result.birthYear ?? 0
        confidence = result.confidence
        voterStatus = result.voterStatus
        alreadySavedForCaptain = result.alreadySavedForCaptain ?? false
    }

    private static func formattedCity(_ city: String?) -> String {
        guard let city, !city.isEmpty else { return "—" }
        return city
            .lowercased()
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    static func manual(from contact: PickedPhoneContact) -> VoterFileMatch {
        VoterFileMatch(
            id: "manual-\(contact.id)",
            name: contact.fullName,
            location: "—",
            regCity: "",
            phone: contact.phoneNumber?.nilIfEmpty,
            age: 0,
            confidence: "MANUAL",
            voterStatus: nil,
            alreadySavedForCaptain: false
        )
    }

    var confirmFirstName: String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.components(separatedBy: " ").first ?? trimmed
    }

    private init(
        id: String,
        name: String,
        location: String,
        regCity: String,
        phone: String?,
        age: Int,
        confidence: String,
        voterStatus: String?,
        alreadySavedForCaptain: Bool
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.regCity = regCity
        self.phone = phone
        self.age = age
        self.confidence = confidence
        self.voterStatus = voterStatus
        self.alreadySavedForCaptain = alreadySavedForCaptain
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

// MARK: - Flow Draft

struct AddContactDraft: Hashable {
    let pickedContact: PickedPhoneContact
    let voterMatch: VoterFileMatch
    var isManualEntry: Bool = false

    var resolvedPhone: String {
        let phone = pickedContact.phoneNumber?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? voterMatch.phone
            ?? ""
        return phone
    }
}

// MARK: - Relationship

enum AddContactRelationship: String, CaseIterable, Identifiable {
    case friend = "Friend"
    case spouse = "Spouse"
    case parent = "Parent"
    case sibling = "Sibling"
    case cousin = "Cousin"
    case relative = "Relative"
    case roommate = "Roommate"

    var id: String { rawValue }

    /// Maps to `GET /getRelations` ids on staging/production.
    var relationId: Int {
        switch self {
        case .friend: return 1
        case .spouse: return 2
        case .parent: return 3
        case .sibling: return 4
        case .cousin: return 5
        case .relative: return 6
        case .roommate: return 7
        }
    }

    var apiDescription: String {
        switch self {
        case .friend: return "Close Friend"
        case .spouse: return "Spouse"
        case .parent: return "Parent"
        case .sibling: return "Sibling"
        case .cousin: return "Cousin"
        case .relative: return "Relative"
        case .roommate: return "Roommate"
        }
    }
}
