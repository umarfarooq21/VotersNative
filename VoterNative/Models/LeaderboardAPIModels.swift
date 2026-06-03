import Foundation

// MARK: - API Response

/// `GET /leaderboard/mobile` — e.g. `leaderboard[]`, `asked`, `reached`, `committed`, `voters`, `goal_progress`
struct LeaderboardMobileDTO: Decodable {
    let asked: Int?
    let committed: Int?
    let contacts: Int?
    let goal: String?
    let goalProgress: Double?
    let leaderboard: [LeaderboardCaptainDTO]?
    let reached: Int?
    let totalCaptains: Int?
    let voters: LeaderboardVotersDTO?
    let year: Int?

    enum CodingKeys: String, CodingKey {
        case asked, committed, contacts, goal, leaderboard, reached, year, voters
        case goalProgress = "goal_progress"
        case totalCaptains = "total_captains"
    }
}

struct LeaderboardVotersDTO: Decodable {
    let completed: Int?
    let total: Int?
}

struct LeaderboardCaptainDTO: Decodable {
    let asked: Int?
    let captain: String?
    let captainId: String?
    let committed: Int?
    let location: String?
    let points: Int?
    let rank: Int?
    let reached: Int?

    enum CodingKeys: String, CodingKey {
        case asked, captain, committed, location, points, rank, reached
        case captainId = "captain_id"
    }
}

// MARK: - Mapping

extension LeaderboardMobileDTO {
    func toUIState() -> CaptainLeaderboardState {
        let rows = (leaderboard ?? []).compactMap { $0.toCaptain() }
        let votersCompleted = voters?.completed ?? 0
        let votersTotal = max(voters?.total ?? 1, 1)
        let goalText = goal ?? "+7 Point Increase"
        let yearLabel = year.map { "\($0)" } ?? "2026"

        return CaptainLeaderboardState(
            captainCount: totalCaptains ?? rows.count,
            goalSubtitle: "\(yearLabel) Goal: \(goalText)",
            votersCompleted: votersCompleted,
            votersTotal: votersTotal,
            pointsCompletion: goalProgress ?? 0,
            metrics: [
                .found: contacts ?? asked ?? rows.reduce(0) { $0 + $1.found },
                .reached: reached ?? rows.reduce(0) { $0 + $1.reached },
                .included: committed ?? rows.reduce(0) { $0 + $1.included }
            ],
            captains: rows
        )
    }
}

extension LeaderboardCaptainDTO {
    func toCaptain() -> LeaderboardCaptain? {
        guard let name = captain?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty else {
            return nil
        }

        let city = location?.trimmingCharacters(in: .whitespacesAndNewlines)
        let displayCity = (city?.isEmpty == false) ? city! : "—"

        return LeaderboardCaptain(
            id: captainId ?? "\(rank ?? 0)-\(name)",
            rank: rank ?? 0,
            name: name,
            city: displayCity,
            initials: Self.makeInitials(from: name),
            found: asked ?? 0,
            reached: reached ?? 0,
            included: committed ?? 0,
            points: points ?? 0
        )
    }

    private static func makeInitials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first.map(String.init) }
        let result = letters.joined().uppercased()
        return result.isEmpty ? "?" : result
    }
}

// MARK: - Flexible API Parsing (fallback)

enum LeaderboardMobileResponse {
    static func parse(from data: Data) throws -> CaptainLeaderboardState {
        let trimmed = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !trimmed.isEmpty else {
            throw APIError.noData
        }

        if let dto = try? JSONDecoder().decode(LeaderboardMobileDTO.self, from: data) {
            return dto.toUIState()
        }

        return try parseLegacy(from: data)
    }

    private static func parseLegacy(from data: Data) throws -> CaptainLeaderboardState {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            if let array = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                return buildState(from: [:], captainsArray: array)
            }
            throw APIError.decodingError(
                DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Expected leaderboard JSON object.")),
                endpoint: "leaderboardMobile"
            )
        }

        let captainsArray = extractCaptainsArray(from: json)
        return buildState(from: json, captainsArray: captainsArray)
    }

    private static func extractCaptainsArray(from json: [String: Any]) -> [[String: Any]] {
        let listKeys = ["leaderboard", "Leaderboard", "captains", "Captains", "captainList", "CaptainList", "data", "Data", "results", "Results"]

        for key in listKeys {
            if let array = json[key] as? [[String: Any]] {
                return array
            }
        }

        return []
    }

    private static func buildState(from json: [String: Any], captainsArray: [[String: Any]]) -> CaptainLeaderboardState {
        let votersDict = json["voters"] as? [String: Any]
            ?? json["Voters"] as? [String: Any]

        let votersCompleted = intValue(votersDict, keys: ["completed", "Completed", "included", "Included"])
            ?? intValue(json, keys: ["committed", "Committed", "included", "Included"])
            ?? 0

        let votersTotal = intValue(votersDict, keys: ["total", "Total", "target", "Target"])
            ?? intValue(json, keys: ["votersTotal", "VotersTotal", "total", "Total", "target", "Target"])
            ?? max(votersCompleted, 1)

        let found = intValue(json, keys: ["contacts", "Contacts", "asked", "Asked", "found", "Found", "totalFound", "TotalFound"]) ?? 0
        let reached = intValue(json, keys: ["reached", "Reached", "totalReached", "TotalReached"]) ?? 0
        let included = intValue(json, keys: ["committed", "Committed", "included", "Included", "totalIncluded", "TotalIncluded"]) ?? votersCompleted

        let pointsCompletion = doubleValue(json, keys: ["goal_progress", "goalProgress", "voterCompletion", "VoterCompletion", "pointsCompletion", "PointsCompletion", "points", "Points"])
            ?? (votersTotal > 0 ? (Double(votersCompleted) / Double(votersTotal)) * 7.0 : 0)

        let goal = stringValue(json, keys: ["goal", "Goal", "goalSubtitle", "GoalSubtitle"])
            ?? "+7 Point Increase"

        let year = intValue(json, keys: ["year", "Year"]) ?? 2026

        let captains: [LeaderboardCaptain] = captainsArray.enumerated().compactMap { index, dict in
            parseCaptain(dict, fallbackRank: index + 1)
        }

        let captainCount = intValue(json, keys: ["total_captains", "totalCaptains", "CaptainCount", "captainCount", "totalCaptains", "TotalCaptains"])
            ?? captains.count

        return CaptainLeaderboardState(
            captainCount: max(captainCount, captains.count),
            goalSubtitle: "\(year) Goal: \(goal.hasPrefix("+") ? goal : "+\(goal)")",
            votersCompleted: votersCompleted,
            votersTotal: max(votersTotal, 1),
            pointsCompletion: pointsCompletion,
            metrics: [
                .found: found > 0 ? found : captains.reduce(0) { $0 + $1.found },
                .reached: reached > 0 ? reached : captains.reduce(0) { $0 + $1.reached },
                .included: included > 0 ? included : captains.reduce(0) { $0 + $1.included }
            ],
            captains: captains
        )
    }

    private static func parseCaptain(_ dict: [String: Any], fallbackRank: Int) -> LeaderboardCaptain? {
        let name = stringValue(dict, keys: ["captain", "Captain", "name", "Name", "captainName", "CaptainName", "fullName", "FullName"])
            ?? stringValue(dict, keys: ["firstName", "FirstName"])
        guard let name, !name.isEmpty else { return nil }

        let location = stringValue(dict, keys: ["location", "Location", "city", "City"]) ?? ""
        let city = location.isEmpty ? "—" : location
        let found = intValue(dict, keys: ["asked", "Asked", "contacts", "Contacts", "found", "Found"]) ?? 0
        let reached = intValue(dict, keys: ["reached", "Reached"]) ?? 0
        let included = intValue(dict, keys: ["committed", "Committed", "included", "Included"]) ?? 0
        let rank = intValue(dict, keys: ["rank", "Rank"]) ?? fallbackRank
        let id = stringValue(dict, keys: ["captain_id", "captainId", "CaptainId", "id", "Id", "userId", "UserId"]) ?? "\(rank)-\(name)"

        let initials = makeInitials(from: name)

        let points = intValue(dict, keys: ["points", "Points"]) ?? 0

        return LeaderboardCaptain(
            id: id,
            rank: rank,
            name: name,
            city: city,
            initials: initials,
            found: found,
            reached: reached,
            included: included,
            points: points
        )
    }

    private static func makeInitials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first.map(String.init) }
        let result = letters.joined().uppercased()
        return result.isEmpty ? "?" : result
    }

    private static func intValue(_ dict: [String: Any]?, keys: [String]) -> Int? {
        guard let dict else { return nil }
        for key in keys {
            if let value = dict[key] as? Int { return value }
            if let value = dict[key] as? Double { return Int(value) }
            if let value = dict[key] as? String, let intValue = Int(value) { return intValue }
        }
        return nil
    }

    private static func doubleValue(_ dict: [String: Any], keys: [String]) -> Double? {
        for key in keys {
            if let value = dict[key] as? Double { return value }
            if let value = dict[key] as? Int { return Double(value) }
            if let value = dict[key] as? String, let doubleValue = Double(value) { return doubleValue }
        }
        return nil
    }

    private static func stringValue(_ dict: [String: Any], keys: [String]) -> String? {
        for key in keys {
            if let value = dict[key] as? String, !value.isEmpty { return value }
            if let value = dict[key] as? Int { return String(value) }
            if let value = dict[key] as? Double { return String(value) }
        }
        return nil
    }
}
