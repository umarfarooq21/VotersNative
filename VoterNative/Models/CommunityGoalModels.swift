import Foundation

// MARK: - API Response

struct CommunityGoalPlanResponse: Decodable {
    let cityProgress: [CityProgressDTO]?
    let goal: String?
    let voterCompletion: Double?
    let voters: VotersSummary?
    let year: Int?

    struct VotersSummary: Decodable {
        let completed: Int?
        let total: Int?
    }
}

struct CityProgressDTO: Decodable, Identifiable {
    let city: String?
    let cityVoterType: String?
    let percentageOfTotalVoters: Double?
    let totalVoters: Int?
    let voterCompletion: Int?
    let voters: Int?

    var id: String { city ?? UUID().uuidString }
}

extension CommunityGoalPlanResponse {
    init(from data: Data) throws {
        let decoder = JSONDecoder()
        self = try decoder.decode(CommunityGoalPlanResponse.self, from: data)
    }

    func toUIState() -> CommunityGoalUIState {
        let cities = (cityProgress ?? []).compactMap { dto -> CityProgressItem? in
            guard let name = dto.city, !name.isEmpty else { return nil }
            let current = dto.voterCompletion ?? 0
            let target = max(dto.totalVoters ?? 0, 1)
            let muslim = dto.voters ?? target
            return CityProgressItem(
                id: name,
                name: name,
                muslimVoters: muslim,
                current: current,
                target: target
            )
        }

        let completed = voters?.completed ?? cities.reduce(0) { $0 + $1.current }
        let total = max(voters?.total ?? cities.reduce(0) { $0 + $1.target }, 1)
        let points = voterCompletion ?? 0

        return CommunityGoalUIState(
            goalDescription: goal ?? "Target: 7-point voter turnout increase",
            aboutText: goal,
            year: year ?? 2026,
            votersCompleted: completed,
            votersTotal: total,
            pointsCompletion: points,
            cities: cities.sorted { $0.name < $1.name }
        )
    }
}

// MARK: - UI State

struct CommunityGoalUIState {
    let goalDescription: String
    let aboutText: String?
    let year: Int
    let votersCompleted: Int
    let votersTotal: Int
    let pointsCompletion: Double
    let cities: [CityProgressItem]

    var voterProgress: CGFloat {
        CGFloat(votersCompleted) / CGFloat(max(votersTotal, 1))
    }

    var voterPercentText: String {
        "\(Int(voterProgress * 100))%"
    }

    var votersCountText: String {
        "\(formatNumber(votersCompleted)) / \(formatNumber(votersTotal))"
    }

    var pointsGaugeValue: CGFloat {
        CGFloat(min(pointsCompletion / 7.0, 1.0))
    }

    var overallVotersCompleted: Int {
        cities.reduce(0) { $0 + $1.current }
    }

    var overallVotersTotal: Int {
        max(cities.reduce(0) { $0 + $1.target }, 1)
    }

    var overallVoterProgress: CGFloat {
        CGFloat(overallVotersCompleted) / CGFloat(overallVotersTotal)
    }

    var overallPercentText: String {
        "\(Int(overallVoterProgress * 100))%"
    }

    var overallVotersCountText: String {
        "\(formatNumber(overallVotersCompleted)) / \(formatNumber(overallVotersTotal))"
    }

    private func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

struct CityProgressItem: Identifiable {
    let id: String
    let name: String
    let muslimVoters: Int
    let current: Int
    let target: Int

    var progress: CGFloat {
        guard target > 0 else { return 0 }
        return min(CGFloat(current) / CGFloat(target), 1)
    }

    var percentText: String {
        "\(Int(progress * 100))%"
    }

    var countText: String {
        "\(current) / \(target)"
    }

    var votersText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let count = formatter.string(from: NSNumber(value: muslimVoters)) ?? "\(muslimVoters)"
        return "\(count) Muslim voters"
    }
}
