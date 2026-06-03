import Foundation

enum APIConfiguration {
    static let baseURL = URL(string: "https://api.amacvoters.org")!
    static let stagingBaseURL = URL(string: "https://apistag.amacvoters.org")!

    static let defaultHeaders: [String: String] = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]

    static let requestTimeout: TimeInterval = 30
    static let resourceTimeout: TimeInterval = 60
}
