import Foundation

/// Low-level HTTP client with a generic async/await request method.
final class APIClient: @unchecked Sendable {
    static let shared = APIClient()

    private let session: URLSession
    private let tokenStorage: TokenStorage
    private let unauthorizedHandler: UnauthorizedHandling

    init(
        session: URLSession = .shared,
        tokenStorage: TokenStorage = .shared,
        unauthorizedHandler: UnauthorizedHandling = UnauthorizedHandler.shared
    ) {
        self.session = session
        self.tokenStorage = tokenStorage
        self.unauthorizedHandler = unauthorizedHandler
    }

    // MARK: - Generic Request

    /// Performs a request and decodes the response body into `T`.
    func request<T: Decodable>(
        _ endpoint: APIEndpoints,
        responseType: T.Type = T.self
    ) async throws -> T {
        let data = try await performRequest(endpoint)
        return try decode(data, as: T.self, endpoint: endpoint.name)
    }

    /// Performs a request with no expected response body.
    func request(_ endpoint: APIEndpoints) async throws {
        _ = try await performRequest(endpoint)
    }

    /// Returns raw response data for flexible decoding.
    func requestData(_ endpoint: APIEndpoints, baseURL: URL? = nil) async throws -> Data {
        try await performRequest(endpoint, baseURL: baseURL)
    }

    // MARK: - Core

    private func performRequest(_ endpoint: APIEndpoints, baseURL: URL? = nil) async throws -> Data {
        let urlRequest: URLRequest

        do {
            urlRequest = try endpoint.makeURLRequest(baseURL: baseURL)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.encodingError(error)
        }

        APILogger.logRequest(urlRequest, endpoint: endpoint.name)
        let startedAt = Date()

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            print("❌ API Network Error [\(endpoint.name)]: \(error.localizedDescription)")
            throw APIError.networkError(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        APILogger.logResponse(
            endpoint: endpoint.name,
            statusCode: httpResponse.statusCode,
            data: data,
            duration: Date().timeIntervalSince(startedAt)
        )

        try validate(httpResponse: httpResponse, data: data, endpoint: endpoint.name)

        guard !data.isEmpty else {
            return Data()
        }

        return data
    }

    private func validate(httpResponse: HTTPURLResponse, data: Data, endpoint: String) throws {
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            unauthorizedHandler.handleUnauthorized()
            throw APIError.unauthorized
        default:
            let message = parseErrorMessage(from: data)
            throw APIError.httpError(statusCode: httpResponse.statusCode, message: message)
        }
    }

    private func decode<T: Decodable>(_ data: Data, as type: T.Type, endpoint: String) throws -> T {
        guard !data.isEmpty else {
            throw APIError.noData
        }

        do {
            return try JSONDecoder.api.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error, endpoint: endpoint)
        }
    }

    private func parseErrorMessage(from data: Data) -> String? {
        guard !data.isEmpty else { return nil }
        return (try? JSONDecoder.api.decode(APIErrorResponse.self, from: data))?.resolvedMessage
    }
}

// MARK: - JSON Coding

extension JSONEncoder {
    static let api: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
}

extension JSONDecoder {
    static let api: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
