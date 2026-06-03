import Foundation
import Observation

@Observable
@MainActor
final class CaptainLeaderboardViewModel {
    private(set) var state: CaptainLeaderboardState?
    private(set) var isLoading = false
    var errorMessage: String?

    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    func load() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            state = try await apiService.fetchLeaderboard()
            print("✅ Leaderboard loaded: \(state?.captains.count ?? 0) captains")
        } catch let error as APIError {
            errorMessage = error.errorDescription
            state = nil
            print("❌ Leaderboard API error: \(error.errorDescription ?? "")")
        } catch {
            errorMessage = error.localizedDescription
            state = nil
            print("❌ Leaderboard error: \(error.localizedDescription)")
        }

        isLoading = false
    }

    func sortedCaptains(metric: LeaderboardMetric) -> [LeaderboardCaptain] {
        guard let state else { return [] }
        return state.captains.sorted { $0.value(for: metric) > $1.value(for: metric) }
            .enumerated()
            .map { index, captain in
                LeaderboardCaptain(
                    id: captain.id,
                    rank: index + 1,
                    name: captain.name,
                    city: captain.city,
                    initials: captain.initials,
                    found: captain.found,
                    reached: captain.reached,
                    included: captain.included,
                    points: captain.points
                )
            }
    }
}
