import Foundation
import Observation

@Observable
@MainActor
final class AddContactRelationshipViewModel {
    private(set) var isSaving = false
    var errorMessage: String?

    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    func save(
        draft: AddContactDraft,
        relationship: AddContactRelationship
    ) async -> Bool {
        guard draft.voterMatch.hasValidVoterId else {
            errorMessage = "Select a voter file match before saving. Manual-only entries cannot be saved yet."
            return false
        }

        guard !isSaving else { return false }

        isSaving = true
        errorMessage = nil

        do {
            let response = try await apiService.saveContactNew(
                draft: draft,
                relationship: relationship
            )
            print("✅ saveContactNew succeeded: contactId=\(response.contactId.map(String.init) ?? "—")")
            isSaving = false
            return true
        } catch let error as APIError {
            errorMessage = error.errorDescription
            print("❌ saveContactNew API error: \(error.errorDescription ?? "")")
        } catch {
            errorMessage = error.localizedDescription
            print("❌ saveContactNew error: \(error.localizedDescription)")
        }

        isSaving = false
        return false
    }
}
