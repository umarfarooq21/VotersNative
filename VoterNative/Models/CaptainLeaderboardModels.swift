import Foundation

enum LeaderboardMetric: String, CaseIterable, Identifiable {
    case found = "FOUND"
    case reached = "REACHED"
    case included = "INCLUDED"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .found: return "person.2.fill"
        case .reached: return "text.bubble.fill"
        case .included: return "checkmark.circle.fill"
        }
    }

    var viewingLabel: String {
        switch self {
        case .found: return "found"
        case .reached: return "reached"
        case .included: return "included"
        }
    }
}

enum LeaderboardCycle: String, CaseIterable {
    case year2026 = "2026"
    case overall = "Overall"
}

struct LeaderboardCaptain: Identifiable, Hashable {
    let id: String
    let rank: Int
    let name: String
    let city: String
    let initials: String
    let found: Int
    let reached: Int
    let included: Int
    let points: Int

    func value(for metric: LeaderboardMetric) -> Int {
        switch metric {
        case .found: return found
        case .reached: return reached
        case .included: return included
        }
    }

    /// API: `asked` → contacts found, `committed` → agreed to vote, `reached` → outreach reached.
    var asked: Int { found }
    var agreedToVote: Int { included }
}

struct CaptainLeaderboardState {
    let captainCount: Int
    let goalSubtitle: String
    let votersCompleted: Int
    let votersTotal: Int
    let pointsCompletion: Double
    let metrics: [LeaderboardMetric: Int]
    let captains: [LeaderboardCaptain]

    var votersCountText: String {
        "\(format(votersCompleted)) / \(format(votersTotal))"
    }

    var percentText: String {
        let pct = votersTotal > 0 ? Int((Double(votersCompleted) / Double(votersTotal)) * 100) : 0
        return "\(pct)%"
    }

    var pointsGaugeValue: CGFloat {
        CGFloat(min(pointsCompletion / 7.0, 1.0))
    }

    var voterMilestones: [String] {
        let steps = [0.25, 0.5, 0.75, 1.0]
        return steps.map { step in
            format(Int(Double(votersTotal) * step))
        }
    }

    func metricValue(_ metric: LeaderboardMetric) -> Int {
        metrics[metric] ?? 0
    }

    private func format(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static let sample = CaptainLeaderboardState(
        captainCount: 16,
        goalSubtitle: "2026 Goal: +7 Point Increase",
        votersCompleted: 431,
        votersTotal: 1719,
        pointsCompletion: 1.75,
        metrics: [
            .found: 573,
            .reached: 501,
            .included: 431
        ],
        captains: [
            LeaderboardCaptain(id: "1", rank: 1, name: "Fatima Ali", city: "Bellevue", initials: "FA", found: 52, reached: 48, included: 44, points: 55),
            LeaderboardCaptain(id: "2", rank: 2, name: "Ibrahim Farah", city: "Redmond", initials: "IF", found: 41, reached: 38, included: 36, points: 40),
            LeaderboardCaptain(id: "3", rank: 3, name: "Amina Hassan", city: "Seattle", initials: "AH", found: 38, reached: 35, included: 32, points: 35),
            LeaderboardCaptain(id: "4", rank: 4, name: "Omar Siddiqui", city: "Kirkland", initials: "OS", found: 35, reached: 31, included: 28, points: 30),
            LeaderboardCaptain(id: "5", rank: 5, name: "Layla Khan", city: "Lynnwood", initials: "LK", found: 32, reached: 29, included: 27, points: 28),
            LeaderboardCaptain(id: "6", rank: 6, name: "Yusuf Ahmed", city: "Sammamish", initials: "YA", found: 30, reached: 27, included: 25, points: 25),
            LeaderboardCaptain(id: "7", rank: 7, name: "Zainab Malik", city: "Bothell", initials: "ZM", found: 28, reached: 25, included: 23, points: 22),
            LeaderboardCaptain(id: "8", rank: 8, name: "Hassan Raza", city: "Renton", initials: "HR", found: 26, reached: 24, included: 22, points: 20)
        ]
    )
}
