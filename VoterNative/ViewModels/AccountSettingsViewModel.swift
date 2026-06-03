import Foundation
import Observation

enum AppearanceMode: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        case .system: return "paintpalette.fill"
        }
    }
}

@Observable
@MainActor
final class AccountSettingsViewModel {
    var fullName: String
    var email: String
    var address: String
    var password: String
    var phone: String
    var isPasswordVisible = false

    var messageReminders = true
    var followUpPrompts = true
    var weeklySummaryDigest = false
    var goalMilestoneAlerts = true
    var termsUpdatesRequired = true

    init(session: AppSession = .shared) {
        fullName = session.displayName == "Shaheryar" ? "Amira Hassan" : session.displayName
        email = session.displayEmail.contains("shaheryar") ? "amira@amacwa.org" : session.displayEmail
        address = "1320 Lakeview Ave, Seattle, WA 981"
        password = "password"
        phone = "(206) 555-0148"
    }

    func applyProfileChanges(to session: AppSession) {
        session.updateProfile(name: fullName, email: email)
    }
}
