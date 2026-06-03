import Foundation

/// Persists the bearer token in `UserDefaults`.
final class TokenStorage: @unchecked Sendable {
    static let shared = TokenStorage()

    private let defaults: UserDefaults
    private let tokenKey = "auth_bearer_token"
    private let userIdKey = "auth_user_id"
    private let captainIdKey = "auth_captain_id"
    private let queue = DispatchQueue(label: "com.voternative.tokenstorage", attributes: .concurrent)

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var token: String? {
        queue.sync {
            defaults.string(forKey: tokenKey)
        }
    }

    func save(_ token: String) {
        queue.sync(flags: .barrier) {
            self.defaults.set(token, forKey: self.tokenKey)
        }
    }

    func clear() {
        queue.async(flags: .barrier) {
            self.defaults.removeObject(forKey: self.tokenKey)
            self.defaults.removeObject(forKey: self.userIdKey)
            self.defaults.removeObject(forKey: self.captainIdKey)
        }
    }

    var hasToken: Bool {
        token != nil
    }

    var userId: String? {
        queue.sync { defaults.string(forKey: userIdKey) }
    }

    var captainId: String? {
        queue.sync { defaults.string(forKey: captainIdKey) }
    }

    func saveUserContext(userId: String, captainId: String? = nil) {
        queue.sync(flags: .barrier) {
            self.defaults.set(userId, forKey: self.userIdKey)
            self.defaults.set(captainId ?? userId, forKey: self.captainIdKey)
        }
    }

    func clearUserContext() {
        queue.async(flags: .barrier) {
            self.defaults.removeObject(forKey: self.userIdKey)
            self.defaults.removeObject(forKey: self.captainIdKey)
        }
    }
}
