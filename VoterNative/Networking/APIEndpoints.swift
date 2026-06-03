import Foundation

enum APIEndpoints {
    case login(LoginRequest)
    case loginMFA(email: String, password: String, username: String)
    case getUsers
    case createUser(CreateUserRequest)
    case getContacts(userId: String, token: String, captainId: String)
    case plan777Mobile(userId: String, token: String, captainId: String)
    case leaderboardMobile(userId: String, token: String, captainId: String)
    case captainDetail(captainId: String, userId: String, token: String)
    case fuzzySearchApp(captainId: String, userId: String, token: String, fullNames: String)
    case saveContactNew(userId: String, token: String, body: SaveContactNewRequest)
}

// MARK: - Endpoint Configuration

extension APIEndpoints {
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .loginMFA:
            return "/loginMFA"
        case .getUsers, .createUser:
            return "/users"
        case .getContacts:
            return "/getContacts"
        case .plan777Mobile:
            return "/plan777/mobile"
        case .leaderboardMobile:
            return "/leaderboard/mobile"
        case .captainDetail(let captainId, _, _):
            return "/captain/\(captainId)/detail"
        case .fuzzySearchApp:
            return "/fuzzySearchApp"
        case .saveContactNew:
            return "/saveContactNew"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .createUser, .saveContactNew:
            return .post
        case .loginMFA, .getUsers, .getContacts, .plan777Mobile, .leaderboardMobile, .captainDetail, .fuzzySearchApp:
            return .get
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .login, .loginMFA, .getContacts, .plan777Mobile, .leaderboardMobile, .captainDetail, .fuzzySearchApp, .saveContactNew:
            return false
        case .getUsers, .createUser:
            return true
        }
    }

    var baseURL: URL {
        switch self {
        case .plan777Mobile, .fuzzySearchApp, .saveContactNew:
            return APIConfiguration.stagingBaseURL
        default:
            return APIConfiguration.baseURL
        }
    }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .loginMFA(let email, let password, let username):
            return [
                URLQueryItem(name: "times", value: APIEndpoints.timestampMillis),
                URLQueryItem(name: "email", value: email),
                URLQueryItem(name: "password", value: password),
                URLQueryItem(name: "username", value: username)
            ]
        case .getContacts(let userId, let token, let captainId):
            return [
                URLQueryItem(name: "userId", value: userId),
                URLQueryItem(name: "token", value: token),
                URLQueryItem(name: "captainId", value: captainId),
                URLQueryItem(name: "times", value: APIEndpoints.timestampMillis)
            ]
        case .plan777Mobile(let userId, let token, let captainId),
             .leaderboardMobile(let userId, let token, let captainId):
            return [
                URLQueryItem(name: "userId", value: userId),
                URLQueryItem(name: "token", value: token),
                URLQueryItem(name: "CaptainId", value: captainId),
                URLQueryItem(name: "times", value: APIEndpoints.timestampMillis)
            ]
        case .captainDetail(_, let userId, let token):
            return [
                URLQueryItem(name: "times", value: APIEndpoints.timestampMillis),
                URLQueryItem(name: "userId", value: userId),
                URLQueryItem(name: "token", value: token)
            ]
        case .fuzzySearchApp(let captainId, let userId, let token, let fullNames):
            return [
                URLQueryItem(name: "captainId", value: captainId),
                URLQueryItem(name: "full_names", value: fullNames),
                URLQueryItem(name: "times", value: APIEndpoints.timestampMillis),
                URLQueryItem(name: "userId", value: userId),
                URLQueryItem(name: "token", value: token)
            ]
        case .saveContactNew(let userId, let token, _):
            return [
                URLQueryItem(name: "times", value: APIEndpoints.timestampMillis),
                URLQueryItem(name: "userId", value: userId),
                URLQueryItem(name: "token", value: token)
            ]
        default:
            return nil
        }
    }

    var body: Data? {
        switch self {
        case .login(let request):
            return try? JSONEncoder.api.encode(request)
        case .createUser(let request):
            return try? JSONEncoder.api.encode(request)
        case .saveContactNew(_, _, let request):
            return try? JSONEncoder.api.encode(request)
        case .loginMFA, .getUsers, .getContacts, .plan777Mobile, .leaderboardMobile, .captainDetail, .fuzzySearchApp:
            return nil
        }
    }

    var name: String {
        switch self {
        case .login: return "login"
        case .loginMFA: return "loginMFA"
        case .getUsers: return "getUsers"
        case .createUser: return "createUser"
        case .getContacts: return "getContacts"
        case .plan777Mobile: return "plan777Mobile"
        case .leaderboardMobile: return "leaderboardMobile"
        case .captainDetail: return "captainDetail"
        case .fuzzySearchApp: return "fuzzySearchApp"
        case .saveContactNew: return "saveContactNew"
        }
    }

    static var timestampMillis: String {
        String(Int(Date().timeIntervalSince1970 * 1000))
    }
}

// MARK: - URLRequest Building

extension APIEndpoints {
    func makeURLRequest(baseURL: URL? = nil) throws -> URLRequest {
        let resolvedBase = baseURL ?? self.baseURL
        guard var components = URLComponents(url: resolvedBase.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }

        if let queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        request.timeoutInterval = APIConfiguration.requestTimeout

        APIConfiguration.defaultHeaders.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        switch self {
        case .captainDetail(_, let userId, let token),
             .fuzzySearchApp(_, let userId, let token, _),
             .saveContactNew(let userId, let token, _):
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue(userId, forHTTPHeaderField: "X-User-Id")
        default:
            if requiresAuth {
                guard let token = TokenStorage.shared.token else {
                    throw APIError.missingToken
                }
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        return request
    }
}
