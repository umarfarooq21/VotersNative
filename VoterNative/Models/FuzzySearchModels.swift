import Foundation

// MARK: - API Model

struct FuzzySearchResult: Decodable, Identifiable, Hashable {
    let stateVoterId: String
    let confidence: String
    let phone: String?
    let fullAddress: String?
    let regCity: String?
    let birthYear: Int?
    let fullNames: String?
    let voterStatus: String?
    let alreadySavedForCaptain: Bool?

    var id: String { stateVoterId }

    enum CodingKeys: String, CodingKey {
        case stateVoterId = "statevoterid"
        case confidence
        case phone
        case fullAddress = "fulladdress"
        case regCity = "regcity"
        case birthYear = "birthyear"
        case fullNames = "full_names"
        case voterStatus = "voterstatus"
        case alreadySavedForCaptain = "already_saved_for_captain"
        case rowCount = "row_count"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        stateVoterId = container.decodeFlexibleString(forKey: .stateVoterId) ?? UUID().uuidString
        confidence = container.decodeFlexibleString(forKey: .confidence) ?? "POSSIBLE"
        phone = container.decodeFlexibleString(forKey: .phone)
        fullAddress = container.decodeFlexibleString(forKey: .fullAddress)
        regCity = container.decodeFlexibleString(forKey: .regCity)
        birthYear = container.decodeFlexibleInt(forKey: .birthYear)
        fullNames = container.decodeFlexibleString(forKey: .fullNames)
        voterStatus = container.decodeFlexibleString(forKey: .voterStatus)
        alreadySavedForCaptain = container.decodeFlexibleBool(forKey: .alreadySavedForCaptain)
    }
}

// MARK: - Flexible Decoding

private extension KeyedDecodingContainer {
    func decodeFlexibleString(forKey key: Key) -> String? {
        guard contains(key) else { return nil }
        if (try? decodeNil(forKey: key)) == true { return nil }
        if let value = try? decode(String.self, forKey: key) {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        }
        if let value = try? decode(Int.self, forKey: key) { return String(value) }
        if let value = try? decode(Double.self, forKey: key) { return String(value) }
        return nil
    }

    func decodeFlexibleInt(forKey key: Key) -> Int? {
        guard contains(key) else { return nil }
        if (try? decodeNil(forKey: key)) == true { return nil }
        if let value = try? decode(Int.self, forKey: key) { return value }
        if let value = try? decode(String.self, forKey: key) { return Int(value) }
        if let value = try? decode(Double.self, forKey: key) { return Int(value) }
        return nil
    }

    func decodeFlexibleBool(forKey key: Key) -> Bool? {
        guard contains(key) else { return nil }
        if (try? decodeNil(forKey: key)) == true { return nil }
        if let value = try? decode(Bool.self, forKey: key) { return value }
        if let value = try? decode(String.self, forKey: key) {
            switch value.lowercased() {
            case "true", "1", "yes": return true
            case "false", "0", "no": return false
            default: return nil
            }
        }
        if let value = try? decode(Int.self, forKey: key) { return value != 0 }
        return nil
    }
}

extension Array where Element == FuzzySearchResult {
    init(fromFlexible data: Data) throws {
        let decoder = JSONDecoder()
        if let array = try? decoder.decode([FuzzySearchResult].self, from: data) {
            self = array.filter { $0.fullNames != nil || !$0.stateVoterId.isEmpty }
            return
        }

        if let wrapped = try? decoder.decode(FuzzySearchListResponse.self, from: data) {
            self = wrapped.resolvedResults
            return
        }

        throw APIError.decodingError(
            DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "fuzzySearchApp")),
            endpoint: "fuzzySearchApp"
        )
    }
}

private struct FuzzySearchListResponse: Decodable {
    let results: [FuzzySearchResult]?
    let data: [FuzzySearchResult]?
    let matches: [FuzzySearchResult]?

    var resolvedResults: [FuzzySearchResult] {
        results ?? data ?? matches ?? []
    }
}
