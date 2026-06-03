import Foundation
import Observation

@Observable
@MainActor
final class CaptainDetailViewModel {
    private(set) var state: CaptainDetailState?
    private(set) var isLoading = false
    var errorMessage: String?

    let captainId: String
    let placeholderName: String

    private let apiService: APIService

    init(
        captainId: String,
        placeholderName: String = "",
        apiService: APIService = .shared
    ) {
        self.captainId = captainId
        self.placeholderName = placeholderName
        self.apiService = apiService
    }

    var navigationTitle: String {
        state?.name ?? placeholderName
    }

    func load() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            state = try await apiService.fetchCaptainDetail(captainId: captainId)
            print("✅ Captain detail loaded: \(state?.name ?? "")")
        } catch let error as APIError {
            errorMessage = error.errorDescription
            print("❌ Captain detail API error: \(error.errorDescription ?? "")")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Captain detail error: \(error.localizedDescription)")
        }

        isLoading = false
    }
}
