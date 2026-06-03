import Foundation

/// High-level, domain-focused API service built on `APIClient`.
final class APIService: @unchecked Sendable {
    static let shared = APIService()

    private let client: APIClient
    private let tokenStorage: TokenStorage

    init(client: APIClient = .shared, tokenStorage: TokenStorage = .shared) {
        self.client = client
        self.tokenStorage = tokenStorage
    }

    // MARK: - Auth

    /// Standard login — `POST /auth/login`
    func login(email: String, password: String) async throws -> LoginResponse {
        let request = LoginRequest(email: email, password: password, username: email)
        let response: LoginResponse = try await client.request(.login(request))

        if let token = response.resolvedToken {
            tokenStorage.save(token)
        }

        return response
    }

    /// MFA login used by the production curl — `GET /loginMFA`
    func loginMFA(email: String, password: String, username: String? = nil) async throws -> LoginResponse {
        let resolvedUsername = username ?? email
        let data = try await client.requestData(
            .loginMFA(email: email, password: password, username: resolvedUsername)
        )

        if let response = try? JSONDecoder.api.decode(LoginResponse.self, from: data) {
            persistToken(from: response, fallbackEmail: email)
            return response
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let token = extractToken(from: json) {
                tokenStorage.save(token)
                return LoginResponse.authenticated(token: token)
            }

            let succeeded = (json["success"] as? Bool) == true
                || (json["ok"] as? Bool) == true
                || (json["authenticated"] as? Bool) == true

            if succeeded {
                let token = (json["access_token"] as? String) ?? "mfa-\(email)"
                let userId = json["userId"] as? String
                let username = json["username"] as? String
                tokenStorage.save(token)
                if let userId { tokenStorage.saveUserContext(userId: userId, captainId: userId) }
                return LoginResponse.authenticated(token: token, userId: userId, username: username)
            }
        }

        // HTTP 200 with empty or non-JSON body — treat as successful MFA login.
        let sessionToken = "mfa-\(email)"
        tokenStorage.save(sessionToken)
        return LoginResponse.authenticated(token: sessionToken)
    }

    private func persistToken(from response: LoginResponse, fallbackEmail: String) {
        if let token = response.resolvedToken {
            tokenStorage.save(token)
        } else if (response.success == true || response.user != nil), !tokenStorage.hasToken {
            tokenStorage.save("mfa-\(fallbackEmail)")
        }

        if let userId = response.userId ?? response.user?.id {
            tokenStorage.saveUserContext(userId: userId, captainId: userId)
        }
    }

    private func extractToken(from json: [String: Any]) -> String? {
        let candidates = ["token", "access_token", "accessToken", "bearer", "jwt"]
        for key in candidates {
            if let value = json[key] as? String, !value.isEmpty {
                return value
            }
        }
        return nil
    }

    // MARK: - Users

    /// `GET /users`
    func fetchUsers() async throws -> [User] {
        let data = try await client.requestData(.getUsers)
        return try [User](fromFlexible: data)
    }

    /// `POST /users`
    func createUser(_ request: CreateUserRequest) async throws -> User {
        try await client.request(.createUser(request))
    }

    // MARK: - Contacts

    /// `GET /getContacts?userId=&token=&captainId=&times=`
    func fetchContacts(
        userId: String? = nil,
        captainId: String? = nil
    ) async throws -> [Contact] {
        guard let token = tokenStorage.token else {
            throw APIError.missingToken
        }

        let resolvedUserId = userId ?? tokenStorage.userId ?? APIService.defaultUserId
        let resolvedCaptainId = captainId ?? tokenStorage.captainId ?? resolvedUserId

        let data = try await client.requestData(
            .getContacts(userId: resolvedUserId, token: token, captainId: resolvedCaptainId)
        )
        return try [Contact](fromFlexible: data)
    }

    // MARK: - Community Goal

    /// `GET /plan777/mobile` on staging (falls back to production if staging is unavailable)
    func fetchCommunityGoalPlan(
        userId: String? = nil,
        captainId: String? = nil
    ) async throws -> CommunityGoalUIState {
        guard let token = tokenStorage.token else {
            throw APIError.missingToken
        }

        let resolvedUserId = userId ?? tokenStorage.userId ?? APIService.defaultUserId
        let resolvedCaptainId = captainId ?? tokenStorage.captainId ?? resolvedUserId
        let endpoint = APIEndpoints.plan777Mobile(
            userId: resolvedUserId,
            token: token,
            captainId: resolvedCaptainId
        )

        do {
            let data = try await client.requestData(endpoint)
            let response = try CommunityGoalPlanResponse(from: data)
            return response.toUIState()
        } catch {
            print("⚠️ plan777 staging failed, retrying production: \(error.localizedDescription)")
            let data = try await client.requestData(endpoint, baseURL: APIConfiguration.baseURL)
            let response = try CommunityGoalPlanResponse(from: data)
            return response.toUIState()
        }
    }

    // MARK: - Leaderboard

    /// `GET /leaderboard/mobile?userId=&token=&CaptainId=&times=`
    func fetchLeaderboard(
        userId: String? = nil,
        captainId: String? = nil
    ) async throws -> CaptainLeaderboardState {
        guard let token = tokenStorage.token else {
            throw APIError.missingToken
        }

        let resolvedUserId = userId ?? tokenStorage.userId ?? APIService.defaultUserId
        let resolvedCaptainId = captainId ?? tokenStorage.captainId ?? resolvedUserId

        let data = try await client.requestData(
            .leaderboardMobile(
                userId: resolvedUserId,
                token: token,
                captainId: resolvedCaptainId
            )
        )

        return try LeaderboardMobileResponse.parse(from: data)
    }

    // MARK: - Fuzzy Search

    /// `GET /fuzzySearchApp?captainId=&full_names=&times=&userId=&token=`
    func fetchFuzzySearch(
        fullNames: String,
        userId: String? = nil,
        captainId: String? = nil
    ) async throws -> [FuzzySearchResult] {
        guard let token = tokenStorage.token else {
            throw APIError.missingToken
        }

        let resolvedUserId = userId ?? tokenStorage.userId ?? APIService.defaultUserId
        let resolvedCaptainId = captainId ?? tokenStorage.captainId ?? resolvedUserId
        let endpoint = APIEndpoints.fuzzySearchApp(
            captainId: resolvedCaptainId,
            userId: resolvedUserId,
            token: token,
            fullNames: fullNames
        )

        do {
            let data = try await client.requestData(endpoint)
            return try [FuzzySearchResult](fromFlexible: data)
        } catch {
            print("⚠️ fuzzySearchApp staging failed, retrying production: \(error.localizedDescription)")
            let data = try await client.requestData(endpoint, baseURL: APIConfiguration.baseURL)
            return try [FuzzySearchResult](fromFlexible: data)
        }
    }

    // MARK: - Save Contact

    /// `POST /saveContactNew?times=&userId=&token=`
    func saveContactNew(
        draft: AddContactDraft,
        relationship: AddContactRelationship,
        userId: String? = nil,
        captainId: String? = nil
    ) async throws -> SaveContactNewResponse {
        guard let token = tokenStorage.token else {
            throw APIError.missingToken
        }

        let resolvedUserId = userId ?? tokenStorage.userId ?? APIService.defaultUserId
        let resolvedCaptainId = captainId ?? tokenStorage.captainId ?? resolvedUserId

        let requestBody = SaveContactNewRequest(
            draft: draft,
            relationship: relationship,
            captainId: resolvedCaptainId
        )

        let endpoint = APIEndpoints.saveContactNew(
            userId: resolvedUserId,
            token: token,
            body: requestBody
        )

        do {
            return try await performSaveContactNew(endpoint)
        } catch let error as APIError {
            if case .httpError = error {
                throw error
            }
            print("⚠️ saveContactNew staging failed, retrying production: \(error.localizedDescription)")
            return try await performSaveContactNew(endpoint, baseURL: APIConfiguration.baseURL)
        }
    }

    private func performSaveContactNew(
        _ endpoint: APIEndpoints,
        baseURL: URL? = nil
    ) async throws -> SaveContactNewResponse {
        let data = try await client.requestData(endpoint, baseURL: baseURL)
        let response = try SaveContactNewResponseParser.parse(data: data)
        guard response.isSuccessful else {
            throw APIError.httpError(
                statusCode: 200,
                message: response.resolvedMessage ?? "Unable to save contact."
            )
        }
        return response
    }

    // MARK: - Captain Detail

    /// `GET /captain/{captainId}/detail?times=&userId=&token=`
    func fetchCaptainDetail(captainId: String) async throws -> CaptainDetailState {
        guard let token = tokenStorage.token else {
            throw APIError.missingToken
        }

        let userId = tokenStorage.userId ?? APIService.defaultUserId

        let response = try await client.request(
            .captainDetail(captainId: captainId, userId: userId, token: token),
            responseType: CaptainDetailResponse.self
        )

        return response.toUIState()
    }

    // MARK: - Session

    /// Default captain/user id used when the login response does not include one.
    static let defaultUserId = "2aa9e79e-5959-46d5-a72e-737dc93ec119"

    func signOut() {
        tokenStorage.clear()
    }

    var isAuthenticated: Bool {
        tokenStorage.hasToken
    }
}
