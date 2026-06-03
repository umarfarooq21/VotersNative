import Foundation

/// Prints API request/response details to the Xcode console.
enum APILogger {
    static var isEnabled = true

    static func logRequest(_ request: URLRequest, endpoint: String) {
        guard isEnabled else { return }

        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "—"

        print("\n🌐 ─────────── API REQUEST ───────────")
        print("📌 Endpoint: \(endpoint)")
        print("🔧 Method:   \(method)")
        print("🔗 URL:      \(url)")

        if let components = request.url.flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false) }),
           let queryItems = components.queryItems,
           !queryItems.isEmpty {
            print("📎 Query Params:")
            for item in queryItems {
                let value = maskedValue(name: item.name, value: item.value ?? "")
                print("   • \(item.name) = \(value)")
            }
        }

        if let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            print("📋 Headers:")
            for (key, value) in headers.sorted(by: { $0.key < $1.key }) {
                let display = key.lowercased() == "authorization" ? maskedAuthorization(value) : value
                print("   • \(key): \(display)")
            }
        }

        if let body = request.httpBody, !body.isEmpty {
            print("📦 Body:")
            print(prettyJSON(from: body) ?? String(data: body, encoding: .utf8) ?? "—")
        }

        print("────────────────────────────────────\n")
    }

    static func logResponse(
        endpoint: String,
        statusCode: Int,
        data: Data,
        duration: TimeInterval? = nil
    ) {
        guard isEnabled else { return }

        let statusEmoji = (200...299).contains(statusCode) ? "✅" : "❌"

        print("\n\(statusEmoji) ─────────── API RESPONSE ───────────")
        print("📌 Endpoint: \(endpoint)")
        print("📊 Status:   \(statusCode)")
        if let duration {
            print("⏱️  Duration: \(String(format: "%.2f", duration))s")
        }

        if data.isEmpty {
            print("📦 Body: (empty)")
        } else {
            let preview = prettyJSON(from: data) ?? String(data: data, encoding: .utf8) ?? "—"
            let maxLength = 2000
            if preview.count > maxLength {
                print("📦 Body (truncated):")
                print(String(preview.prefix(maxLength)) + "…")
            } else {
                print("📦 Body:")
                print(preview)
            }
        }

        print("────────────────────────────────────\n")
    }

    // MARK: - Helpers

    private static func maskedValue(name: String, value: String) -> String {
        #if DEBUG
        return value
        #else
        let sensitiveKeys = ["password", "token", "access_token", "refresh_token"]
        guard sensitiveKeys.contains(where: { name.lowercased().contains($0) }) else {
            return value
        }
        guard !value.isEmpty else { return "—" }
        if value.count <= 8 { return "[REDACTED]" }
        return "\(value.prefix(4))…\(value.suffix(4)) [\(value.count) chars]"
        #endif
    }

    private static func maskedAuthorization(_ value: String) -> String {
        if value.hasPrefix("Bearer ") {
            let token = String(value.dropFirst(7))
            return "Bearer \(maskedValue(name: "token", value: token))"
        }
        return maskedValue(name: "authorization", value: value)
    }

    private static func prettyJSON(from data: Data) -> String? {
        guard
            let object = try? JSONSerialization.jsonObject(with: data),
            let pretty = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]),
            let string = String(data: pretty, encoding: .utf8)
        else {
            return nil
        }
        return string
    }
}
