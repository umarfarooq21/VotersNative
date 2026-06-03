import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class AppThemeStore {
    static let shared = AppThemeStore()

    private let storageKey = "app.theme.mode"

    var mode: AppearanceMode {
        didSet { UserDefaults.standard.set(mode.rawValue, forKey: storageKey) }
    }

    init() {
        if let raw = UserDefaults.standard.string(forKey: storageKey),
           let saved = AppearanceMode(rawValue: raw) {
            mode = saved
        } else {
            mode = .system
        }
    }

    var preferredColorScheme: ColorScheme? {
        switch mode {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

