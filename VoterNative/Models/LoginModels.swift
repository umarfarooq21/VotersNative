import Foundation

struct LoginRequest: Encodable {
    let email: String
    let password: String
    let username: String
}

struct LoginResponse: Decodable {
    let token: String?
    let accessToken: String?
    let refreshToken: String?
    let message: String?
    let success: Bool?
    let user: User?
    let userId: String?
    let username: String?

    /// Resolves the bearer token from common API response shapes.
    var resolvedToken: String? {
        token ?? accessToken
    }

    var resolvedDisplayName: String? {
        if let username, !username.isEmpty { return username }
        if let user {
            let parts = [user.firstName, user.lastName].compactMap { $0 }.filter { !$0.isEmpty }
            if !parts.isEmpty { return parts.joined(separator: " ") }
            return user.username ?? user.email
        }
        return nil
    }

    enum CodingKeys: String, CodingKey {
        case token
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case message
        case success
        case user
        case userId
        case username
    }

    static func authenticated(token: String, userId: String? = nil, username: String? = nil) -> LoginResponse {
        LoginResponse(
            token: token,
            accessToken: nil,
            refreshToken: nil,
            message: nil,
            success: true,
            user: nil,
            userId: userId,
            username: username
        )
    }
}
