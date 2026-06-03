import Foundation
import Observation

@Observable
@MainActor
final class YourFocusTodayViewModel {
    private(set) var focusContacts: [FocusContactItem] = []
    private(set) var isLoading = false
    var errorMessage: String?

    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    var remainingCount: Int {
        focusContacts.count
    }

    func load() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await apiService.fetchContacts()
            let filtered = fetched.filter { FocusContactItem.isNotYetContacted($0) }
            let source = filtered.isEmpty ? fetched : filtered

            focusContacts = source.enumerated().map { index, contact in
                FocusContactItem(from: contact, colorIndex: index)
            }
            print("✅ Focus today loaded: \(focusContacts.count) contacts")
        } catch let error as APIError {
            errorMessage = error.errorDescription
            print("❌ Focus today API error: \(error.errorDescription ?? "")")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Focus today error: \(error.localizedDescription)")
        }

        isLoading = false
    }
}
