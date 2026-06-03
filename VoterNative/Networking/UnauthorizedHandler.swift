import Foundation

protocol UnauthorizedHandling: Sendable {
    func handleUnauthorized()
}

/// Clears stored credentials and notifies the app session on HTTP 401.
final class UnauthorizedHandler: UnauthorizedHandling, @unchecked Sendable {
    static let shared = UnauthorizedHandler()

    private let tokenStorage: TokenStorage

    init(tokenStorage: TokenStorage = .shared) {
        self.tokenStorage = tokenStorage
    }

    func handleUnauthorized() {
        tokenStorage.clear()

        Task { @MainActor in
            AppSession.shared.signOut(unauthorized: true)
        }
    }
}
