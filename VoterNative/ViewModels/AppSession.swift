import Foundation
import Observation

/// Global authentication state shared across the app.
@Observable
@MainActor
final class AppSession {
    static let shared = AppSession()

    private(set) var isAuthenticated: Bool
    private(set) var unauthorizedMessage: String?
    private(set) var displayName: String = "Shaheryar"
    private(set) var displayEmail: String = "shaheryar@inabia.com"

    private let tokenStorage: TokenStorage
    private let apiService: APIService

    init(tokenStorage: TokenStorage = .shared, apiService: APIService = .shared) {
        self.tokenStorage = tokenStorage
        self.apiService = apiService
        self.isAuthenticated = tokenStorage.hasToken
    }

    func signIn(
        token: String,
        userId: String? = nil,
        captainId: String? = nil,
        name: String? = nil,
        email: String? = nil
    ) {
        tokenStorage.save(token)

        let resolvedUserId = userId ?? APIService.defaultUserId
        tokenStorage.saveUserContext(userId: resolvedUserId, captainId: captainId ?? resolvedUserId)

        if let name, !name.isEmpty {
            displayName = name
        }
        if let email, !email.isEmpty {
            displayEmail = email
        }

        isAuthenticated = true
        unauthorizedMessage = nil
    }

    func signOut(unauthorized: Bool = false) {
        apiService.signOut()
        isAuthenticated = false

        if unauthorized {
            unauthorizedMessage = APIError.unauthorized.errorDescription
        }
    }

    var profileInitials: String {
        let parts = displayName.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first.map(String.init) }
        let result = letters.joined().uppercased()
        return result.isEmpty ? "?" : result
    }

    func clearUnauthorizedMessage() {
        unauthorizedMessage = nil
    }

    func updateProfile(name: String, email: String) {
        if !name.isEmpty { displayName = name }
        if !email.isEmpty { displayEmail = email }
    }
}
