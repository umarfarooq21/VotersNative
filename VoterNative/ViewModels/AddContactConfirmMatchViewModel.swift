import Foundation
import Observation

@Observable
@MainActor
final class AddContactConfirmMatchViewModel {
    private(set) var matches: [VoterFileMatch] = []
    private(set) var isLoading = false
    var errorMessage: String?

    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    func search(fullName: String) async {
        let query = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            matches = []
            errorMessage = "Contact name is required to search the voter file."
            return
        }

        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        matches = []

        do {
            let results = try await apiService.fetchFuzzySearch(fullNames: query)
            matches = results.map(VoterFileMatch.init(from:))
            print("✅ Fuzzy search loaded: \(matches.count) matches for \"\(query)\"")
        } catch let error as APIError {
            errorMessage = error.errorDescription
            matches = []
            print("❌ Fuzzy search API error: \(error.errorDescription ?? "")")
        } catch {
            errorMessage = error.localizedDescription
            matches = []
            print("❌ Fuzzy search error: \(error.localizedDescription)")
        }

        isLoading = false
    }
}
