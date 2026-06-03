import Foundation
import Observation

@Observable
@MainActor
final class CommunityGoalViewModel {
    private(set) var state: CommunityGoalUIState?
    private(set) var isLoading = false
    var errorMessage: String?

    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    func loadPlan() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            state = try await apiService.fetchCommunityGoalPlan()
            print("✅ Community goal plan loaded: \(state?.cities.count ?? 0) cities")
        } catch let error as APIError {
            errorMessage = error.errorDescription
            print("❌ Community goal API error: \(error.errorDescription ?? "")")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Community goal error: \(error.localizedDescription)")
        }

        isLoading = false
    }
}
