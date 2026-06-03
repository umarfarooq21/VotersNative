import Foundation
import Observation

@Observable
@MainActor
final class ContactsViewModel {
    private(set) var contacts: [ContactItem] = []
    private(set) var isLoading = false
    var errorMessage: String?

    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    var contactCountText: String {
        let count = contacts.count
        return "\(count) CONTACT\(count == 1 ? "" : "S") IMPORTED"
    }

    func filteredContacts(searchText: String) -> [ContactItem] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return contacts }
        return contacts.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    func loadContacts() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await apiService.fetchContacts()
            contacts = fetched.enumerated().map { index, contact in
                ContactItem(from: contact, colorIndex: index)
            }
            print("✅ Contacts loaded: \(contacts.count) items")
        } catch let error as APIError {
            errorMessage = error.errorDescription
            print("❌ Contacts API error: \(error.errorDescription ?? "")")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Contacts error: \(error.localizedDescription)")
        }

        isLoading = false
    }
}
