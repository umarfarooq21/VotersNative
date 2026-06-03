import Foundation
import Observation

@Observable
@MainActor
final class UsersViewModel {
    enum ViewState: Equatable {
        case idle
        case loading
        case loaded
        case empty
        case error(String)
    }

    private(set) var users: [User] = []
    private(set) var state: ViewState = .idle
    var isCreating = false
    var createErrorMessage: String?

    // Create-user form fields (example)
    var newEmail = ""
    var newFirstName = ""
    var newLastName = ""
    var newUsername = ""
    var newPassword = ""

    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    var isLoading: Bool {
        state == .loading
    }

    func loadUsers() async {
        state = .loading

        do {
            let fetched = try await apiService.fetchUsers()
            users = fetched
            state = fetched.isEmpty ? .empty : .loaded
        } catch let error as APIError {
            state = .error(error.errorDescription ?? "Request failed.")
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func createUser() async {
        guard !newEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            createErrorMessage = "Email is required."
            return
        }

        isCreating = true
        createErrorMessage = nil
        defer { isCreating = false }

        let request = CreateUserRequest(
            email: newEmail.trimmingCharacters(in: .whitespacesAndNewlines),
            username: newUsername.isEmpty ? nil : newUsername,
            firstName: newFirstName.isEmpty ? nil : newFirstName,
            lastName: newLastName.isEmpty ? nil : newLastName,
            phone: nil,
            password: newPassword.isEmpty ? nil : newPassword,
            role: nil
        )

        do {
            let user = try await apiService.createUser(request)
            users.insert(user, at: 0)
            state = users.isEmpty ? .empty : .loaded
            resetCreateForm()
        } catch let error as APIError {
            createErrorMessage = error.errorDescription
        } catch {
            createErrorMessage = error.localizedDescription
        }
    }

    func resetCreateForm() {
        newEmail = ""
        newFirstName = ""
        newLastName = ""
        newUsername = ""
        newPassword = ""
    }
}
