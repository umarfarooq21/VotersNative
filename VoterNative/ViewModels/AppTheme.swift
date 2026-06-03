import SwiftUI
import UIKit

/// Shared semantic colors that adapt to light and dark mode app-wide.
enum AppTheme {
    // MARK: - Surfaces

    static let screenBackground = Color(.systemGroupedBackground)
    static let card = Color(.secondarySystemGroupedBackground)
    static let elevatedCard = Color(.tertiarySystemGroupedBackground)
    static let sheetBackground = Color(.systemBackground)
    static let fieldBackground = Color(.secondarySystemGroupedBackground)
    static let searchFieldBackground = Color(.tertiarySystemGroupedBackground)
    static let notesFieldBackground = Color(.tertiarySystemGroupedBackground)
    static let segmentBackground = Color(.tertiarySystemGroupedBackground)
    static let tableBackground = Color(.secondarySystemGroupedBackground)
    static let toolbarBackground = Color(.systemBackground)

    // MARK: - Text

    static let title = Color.primary
    static let subtitle = Color.secondary
    static let body = Color.primary
    static let sectionHeader = Color.secondary
    static let placeholder = Color.secondary.opacity(0.75)

    // MARK: - Chrome

    static let border = Color(.separator)
    static let divider = Color(.separator)
    static let grabber = Color(.systemGray4)
    static let chevron = Color.secondary.opacity(0.65)
    static let shimmerBase = Color(.systemGray5)
    static let onPrimary = Color.white

    // MARK: - Brand

    static let primaryBlue = Color(red: 0.145, green: 0.388, blue: 0.922)
    static let brandBlue = Color(red: 0.231, green: 0.400, blue: 0.898)
    static let accentBlue = Color(red: 0.231, green: 0.510, blue: 0.965)
    static let destructive = Color(red: 0.937, green: 0.267, blue: 0.267)

    // MARK: - Adaptive tints

    static let accentSurface = dynamic(
        light: (0.922, 0.945, 1.0),
        dark: (0.14, 0.20, 0.32)
    )
    static let chipBackground = accentSurface
    static let badgeBackground = Color(.tertiarySystemFill)
    static let activeBadgeBackground = accentSurface
    static let logoutBackground = dynamic(
        light: (1.0, 0.945, 0.945),
        dark: (0.32, 0.14, 0.14)
    )
    static let howItWorksBackground = dynamic(
        light: (0.941, 0.969, 1.0),
        dark: (0.12, 0.18, 0.28)
    )
    static let howItWorksBorder = dynamic(
        light: (0.816, 0.890, 1.0),
        dark: (0.20, 0.28, 0.42)
    )
    static let subCardBackground = Color(.tertiarySystemGroupedBackground)
    static let metricSelectedBackground = accentSurface
    static let progressTrack = Color(.separator)
    static let iconCircle = accentSurface
    static let footer = Color.secondary

    // MARK: - Status

    static let success = Color(red: 0.298, green: 0.686, blue: 0.314)
    static let warning = Color(red: 0.961, green: 0.620, blue: 0.043)
    static let danger = Color(red: 0.937, green: 0.325, blue: 0.314)
    static let gold = Color(red: 0.851, green: 0.647, blue: 0.125)

    // MARK: - Captain detail metrics

    static let metricPurple = Color(red: 0.486, green: 0.227, blue: 0.929)
    static let metricPurpleBg = dynamic(
        light: (0.953, 0.910, 1.0),
        dark: (0.22, 0.14, 0.32)
    )
    static let metricGreen = Color(red: 0.133, green: 0.659, blue: 0.294)
    static let metricGreenBg = dynamic(
        light: (0.929, 0.969, 0.941),
        dark: (0.12, 0.26, 0.18)
    )
    static let metricGoldBg = dynamic(
        light: (1.0, 0.961, 0.902),
        dark: (0.28, 0.22, 0.12)
    )
    static let metricGoldIcon = Color(red: 0.851, green: 0.592, blue: 0.235)
    static let softCardGradientEnd = dynamic(
        light: (0.988, 0.949, 0.961),
        dark: (0.16, 0.12, 0.20)
    )
    static let activityIconBg = dynamic(
        light: (0.890, 0.949, 1.0),
        dark: (0.14, 0.22, 0.34)
    )

    // MARK: - Avatars (brand accents — same in both modes)

    static let avatarRed = Color(red: 0.827, green: 0.184, blue: 0.184)
    static let avatarOrange = Color(red: 0.961, green: 0.651, blue: 0.137)

    // MARK: - Login gradient

    static let loginGradientTop = dynamic(
        light: (0.965, 0.973, 0.988),
        dark: (0.08, 0.10, 0.14)
    )
    static let loginGradientBottom = dynamic(
        light: (0.929, 0.945, 0.976),
        dark: (0.05, 0.07, 0.11)
    )

    // MARK: - Helpers

    static func dynamic(
        light: (CGFloat, CGFloat, CGFloat),
        dark: (CGFloat, CGFloat, CGFloat)
    ) -> Color {
        Color(uiColor: UIColor { trait in
            let rgb = trait.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: rgb.0, green: rgb.1, blue: rgb.2, alpha: 1)
        })
    }
}
