import Foundation
import Observation

@Observable
@MainActor
final class LoginViewModel {
    var email = "shaheryar@inabia.com"//shaheryar@inabia.com//taha@inabia.com
    var password = "Shery1@#"//Shery1@# //Taha@510
    var isPasswordVisible = false
    var staySignedIn = true
    var isLoading = false
    var errorMessage: String?

    private let apiService: APIService
    private let session: AppSession

    /// Uses MFA login (`GET /loginMFA`) by default to match the production curl.
    var useMFALogin = true

    init(apiService: APIService = .shared, session: AppSession = .shared) {
        self.apiService = apiService
        self.session = session
    }

    var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.isEmpty &&
        !isLoading
    }

    func signIn() async {
        guard canSubmit else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            let response: LoginResponse

            if useMFALogin {
                response = try await apiService.loginMFA(
                    email: trimmedEmail,
                    password: password,
                    username: trimmedEmail
                )
            } else {
                response = try await apiService.login(
                    email: trimmedEmail,
                    password: password
                )
            }

            let token = response.resolvedToken
                ?? TokenStorage.shared.token
                ?? "session-\(trimmedEmail)"

            let userId = response.userId ?? response.user?.id
            session.signIn(
                token: token,
                userId: userId,
                captainId: userId,
                name: response.resolvedDisplayName,
                email: trimmedEmail
            )
        } catch let error as APIError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
