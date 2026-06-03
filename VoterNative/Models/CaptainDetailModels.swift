import Foundation

// MARK: - API Response

struct CaptainDetailResponse: Decodable {
    let captainId: String?
    let name: String
    let location: String?
    let joinedAt: String?
    let lastActiveAt: String?
    let metrics: CaptainDetailMetricsDTO
    let rank: CaptainDetailRankDTO
    let recentActivity: [CaptainDetailActivityDTO]
}

struct CaptainDetailMetricsDTO: Decodable {
    let contactsAdded: Int
    let asked: Int
    let askedPct: Int
    let agreedToVote: Int
    let agreedToVotePct: Int
    let conversionRatePct: Int
}

struct CaptainDetailRankDTO: Decodable {
    let current: Int
    let delta: Int?
    let label: String?
    let ofTotal: Int
    let weekAgo: Int?
}

struct CaptainDetailActivityDTO: Decodable {
    let at: String
    let count: Int?
    let label: String
    let type: String?
}

// MARK: - UI State

struct CaptainActivityItem: Identifiable, Hashable {
    let id: String
    let title: String
    let timestamp: String
}

struct CaptainDetailState: Hashable {
    let captainId: String
    let name: String
    let rank: Int
    let totalCaptains: Int
    let rankChangeText: String
    let totalContacts: Int
    let asked: Int
    let askedPercent: Int
    let agreedToVote: Int
    let agreedPercent: Int
    let conversionRate: Int
    let activities: [CaptainActivityItem]
    let joined: String
    let lastActive: String
    let city: String
}

extension CaptainDetailResponse {
    func toUIState() -> CaptainDetailState {
        let displayCity = location?.trimmingCharacters(in: .whitespacesAndNewlines)
        let city = (displayCity?.isEmpty == false) ? displayCity! : "—"

        return CaptainDetailState(
            captainId: captainId ?? "",
            name: name,
            rank: rank.current,
            totalCaptains: max(rank.ofTotal, 1),
            rankChangeText: rank.label ?? "No rank change this week",
            totalContacts: metrics.contactsAdded,
            asked: metrics.asked,
            askedPercent: metrics.askedPct,
            agreedToVote: metrics.agreedToVote,
            agreedPercent: metrics.agreedToVotePct,
            conversionRate: metrics.conversionRatePct,
            activities: recentActivity.enumerated().map { index, item in
                CaptainActivityItem(
                    id: "\(captainId ?? name)-\(index)",
                    title: item.label,
                    timestamp: CaptainDetailDateFormatter.displayString(from: item.at)
                )
            },
            joined: CaptainDetailDateFormatter.joinedDisplay(from: joinedAt),
            lastActive: CaptainDetailDateFormatter.relativeDisplay(from: lastActiveAt),
            city: city
        )
    }
}

// MARK: - Date Formatting

enum CaptainDetailDateFormatter {
    private static let isoFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoFallback: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let joinedOutput: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private static let activityOutput: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM 'at' HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    static func parse(_ string: String?) -> Date? {
        guard let string, !string.isEmpty else { return nil }
        if let date = isoFormatter.date(from: string) { return date }
        if let date = isoFallback.date(from: string) { return date }
        return nil
    }

    static func joinedDisplay(from string: String?) -> String {
        guard let date = parse(string) else { return "—" }
        return joinedOutput.string(from: date)
    }

    static func relativeDisplay(from string: String?) -> String {
        guard let date = parse(string) else { return "—" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    static func displayString(from string: String) -> String {
        guard let date = parse(string) else { return string }

        let calendar = Calendar.current
        if calendar.isDateInYesterday(date) {
            let time = DateFormatter()
            time.dateFormat = "HH:mm"
            time.locale = Locale(identifier: "en_US_POSIX")
            return "Yesterday at \(time.string(from: date))"
        }

        if calendar.isDateInToday(date) {
            let time = DateFormatter()
            time.dateFormat = "HH:mm"
            time.locale = Locale(identifier: "en_US_POSIX")
            return "Today at \(time.string(from: date))"
        }

        return activityOutput.string(from: date)
    }
}
