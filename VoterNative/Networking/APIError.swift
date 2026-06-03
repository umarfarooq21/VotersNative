import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case httpError(statusCode: Int, message: String?)
    case decodingError(Error, endpoint: String)
    case encodingError(Error)
    case networkError(Error)
    case noData
    case missingToken

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .unauthorized:
            return "Your session has expired. Please sign in again."
        case .httpError(let statusCode, let message):
            if let message, !message.isEmpty {
                return message
            }
            return "Request failed with status code \(statusCode)."
        case .decodingError(_, let endpoint):
            return "Failed to decode the response from \(endpoint)."
        case .encodingError:
            return "Failed to encode the request body."
        case .networkError(let error):
            return error.localizedDescription
        case .noData:
            return "No data was returned from the server."
        case .missingToken:
            return "Authentication is required."
        }
    }
}

struct APIErrorResponse: Decodable {
    let message: String?
    let error: String?
    let detail: String?

    var resolvedMessage: String? {
        message ?? error ?? detail
    }
}
