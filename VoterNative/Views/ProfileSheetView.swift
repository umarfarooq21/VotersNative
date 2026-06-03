import SwiftUI

// MARK: - Design Tokens

private enum ProfileSheetStyle {
    static let title = AppTheme.title
    static let subtitle = AppTheme.subtitle
    static let divider = AppTheme.divider
    static let logoutTint = AppTheme.destructive
    static let logoutBackground = AppTheme.logoutBackground
    static let grabber = AppTheme.grabber

    static let cornerRadius: CGFloat = 24
}

struct ProfileSheetView: View {
    @Environment(AppSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @State private var showLogoutConfirmation = false
    @State private var navigateToAccount = false
    @State private var navigateToAbout = false
    @State private var navigateToTerms = false

    var body: some View {
        VStack(spacing: 0) {
            grabber
                .padding(.top, 10)
                .padding(.bottom, 20)

            profileHeader
                .padding(.horizontal, 24)
                .padding(.bottom, 20)

            divider
                .padding(.horizontal, 24)

            menuSection
                .padding(.horizontal, 24)
                .padding(.top, 8)

            Spacer(minLength: 24)

            logoutButton
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(AppTheme.sheetBackground)
        .fullScreenCover(isPresented: $navigateToAccount) {
            NavigationStack {
                AccountScreen()
            }
        }
        .fullScreenCover(isPresented: $navigateToAbout) {
            NavigationStack {
                AboutScreen()
            }
        }
        .fullScreenCover(isPresented: $navigateToTerms) {
            NavigationStack {
                TermsOfServiceScreen()
            }
        }
        .alert("Log out", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Log out", role: .destructive) {
                session.signOut()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }

    // MARK: - Grabber

    private var grabber: some View {
        Capsule()
            .fill(ProfileSheetStyle.grabber)
            .frame(width: 40, height: 5)
    }

    // MARK: - Header

    private var profileHeader: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            AppTheme.accentBlue,
                            AppTheme.primaryBlue
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 56, height: 56)
                .overlay(
                    Text(session.profileInitials)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(session.displayName)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(ProfileSheetStyle.title)

                Text(session.displayEmail)
                    .font(.system(size: 15))
                    .foregroundStyle(ProfileSheetStyle.subtitle)
            }

            Spacer(minLength: 0)
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(ProfileSheetStyle.divider)
            .frame(height: 1)
    }

    // MARK: - Menu

    private var menuSection: some View {
        VStack(spacing: 0) {
            menuRow(icon: "person", title: "Account") {
                navigateToAccount = true
            }

            menuRow(icon: "info.circle", title: "About") {
                navigateToAbout = true
            }

            menuRow(icon: "doc.text", title: "Terms of Service") {
                navigateToTerms = true
            }
        }
    }

    private func menuRow(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(ProfileSheetStyle.title)
                    .frame(width: 28, alignment: .center)

                Text(title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(ProfileSheetStyle.title)

                Spacer(minLength: 0)
            }
            .padding(.vertical, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Log Out

    private var logoutButton: some View {
        Button {
            showLogoutConfirmation = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 20, weight: .semibold))

                Text("Log out")
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(ProfileSheetStyle.logoutTint)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(ProfileSheetStyle.logoutBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ProfileSheetView()
            .environment(AppSession.shared)
    }
    .presentationDetents([.height(420)])
}
