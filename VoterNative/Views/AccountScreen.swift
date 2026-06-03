import SwiftUI

// MARK: - Design Tokens

private enum AccountStyle {
    static let background = AppTheme.screenBackground
    static let card = AppTheme.card
    static let title = AppTheme.title
    static let label = AppTheme.subtitle
    static let border = AppTheme.border
    static let primaryBlue = AppTheme.primaryBlue
    static let destructive = AppTheme.destructive
    static let sectionHeader = AppTheme.sectionHeader

    static let cardRadius: CGFloat = 16
    static let fieldRadius: CGFloat = 12
}

// MARK: - Screen

struct AccountScreen: View {
    @Environment(AppSession.self) private var session
    @Environment(AppThemeStore.self) private var theme
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = AccountSettingsViewModel()
    @State private var showLogoutConfirmation = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                profilePhotoSection
                profileFormSection
                saveButton
                notificationSection
                appearanceSection
                accountActionsSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(AccountStyle.background)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AccountStyle.title)
                }
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

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Account")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(AccountStyle.title)

            Text("Manage your account and app preferences.")
                .font(.system(size: 16))
                .foregroundStyle(AccountStyle.label)
        }
        .padding(.top, 8)
    }

    // MARK: - Profile Photo

    private var profilePhotoSection: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.85, green: 0.75, blue: 0.65),
                                Color(red: 0.65, green: 0.55, blue: 0.45)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 72, height: 72)
                    .overlay(
                        Text(session.profileInitials)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.9))
                    )

                Circle()
                    .fill(AppTheme.card)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "camera.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(AccountStyle.label)
                    )
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .offset(x: 4, y: 4)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Profile photo")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AccountStyle.title)

                Text("Tap to upload a new photo.")
                    .font(.system(size: 14))
                    .foregroundStyle(AccountStyle.label)
            }

            Spacer(minLength: 0)
        }
        .padding(20)
        .background(cardBackground)
    }

    // MARK: - Profile Form

    private var profileFormSection: some View {
        VStack(spacing: 16) {
            formField(label: "Full name", text: $viewModel.fullName)
            formField(label: "Email", text: $viewModel.email, keyboard: .emailAddress)
            formField(label: "Address", text: $viewModel.address)
            passwordField
            formField(label: "Phone number", text: $viewModel.phone, keyboard: .phonePad)
        }
        .padding(20)
        .background(cardBackground)
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AccountStyle.label)

            HStack(spacing: 12) {
                Group {
                    if viewModel.isPasswordVisible {
                        TextField("", text: $viewModel.password, prompt: fieldPrompt("Password"))
                    } else {
                        SecureField("", text: $viewModel.password, prompt: fieldPrompt("Password"))
                    }
                }
                .font(.system(size: 16))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                Button {
                    viewModel.isPasswordVisible.toggle()
                } label: {
                    Image(systemName: viewModel.isPasswordVisible ? "eye.slash" : "eye")
                        .font(.system(size: 17))
                        .foregroundStyle(AccountStyle.label)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(fieldBackground)
        }
    }

    private func formField(
        label: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AccountStyle.label)

            TextField("", text: text, prompt: fieldPrompt(label))
                .font(.system(size: 16))
                .foregroundStyle(AccountStyle.title)
                .keyboardType(keyboard)
                .textInputAutocapitalization(keyboard == .emailAddress ? .never : .words)
                .autocorrectionDisabled()
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(fieldBackground)
        }
    }

    // MARK: - Save

    private var saveButton: some View {
        Button {
            viewModel.applyProfileChanges(to: session)
        } label: {
            Text("Save profile changes")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: AccountStyle.fieldRadius, style: .continuous)
                        .fill(AccountStyle.primaryBlue)
                )
        }
        .buttonStyle(.plain)
        .padding(20)
        .background(cardBackground)
    }

    // MARK: - Notifications

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("NOTIFICATION PREFERENCES")

            VStack(spacing: 10) {
                notificationRow("Message reminders", isOn: $viewModel.messageReminders)
                notificationRow("Follow-up prompts", isOn: $viewModel.followUpPrompts)
                notificationRow("Weekly summary digest", isOn: $viewModel.weeklySummaryDigest)
                notificationRow("Goal milestone alerts", isOn: $viewModel.goalMilestoneAlerts)
                notificationRow(
                    "Terms updates (required)",
                    subtitle: "Mandatory compliance notification.",
                    isOn: $viewModel.termsUpdatesRequired,
                    tint: Color(red: 0.376, green: 0.647, blue: 0.980)
                )
            }
            .padding(16)
            .background(cardBackground)
        }
    }

    private func notificationRow(
        _ title: String,
        subtitle: String? = nil,
        isOn: Binding<Bool>,
        tint: Color = AccountStyle.primaryBlue
    ) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(AccountStyle.title)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(AccountStyle.label)
                }
            }

            Spacer(minLength: 8)

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(tint)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, subtitle == nil ? 14 : 12)
        .background(
            RoundedRectangle(cornerRadius: AccountStyle.fieldRadius, style: .continuous)
                .stroke(AccountStyle.border, lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: AccountStyle.fieldRadius, style: .continuous)
                        .fill(AppTheme.card)
                )
        )
    }

    // MARK: - Appearance

    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("APPEARANCE")

            HStack(spacing: 10) {
                ForEach(AppearanceMode.allCases) { mode in
                    appearanceOption(mode)
                }
            }
            .padding(16)
            .background(cardBackground)
        }
    }

    private func appearanceOption(_ mode: AppearanceMode) -> some View {
        let isSelected = theme.mode == mode

        return Button {
            theme.mode = mode
        } label: {
            VStack(spacing: 10) {
                Image(systemName: mode.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isSelected ? AccountStyle.primaryBlue : AccountStyle.label)

                Text(mode.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(isSelected ? AccountStyle.primaryBlue : AccountStyle.label)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: AccountStyle.fieldRadius, style: .continuous)
                    .stroke(isSelected ? AccountStyle.primaryBlue : AccountStyle.border, lineWidth: isSelected ? 2 : 1)
                    .background(
                        RoundedRectangle(cornerRadius: AccountStyle.fieldRadius, style: .continuous)
                            .fill(AppTheme.card)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Account Actions

    private var accountActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("ACCOUNT ACTIONS")

            VStack(spacing: 0) {
                Button {
                    // Request deletion
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "exclamationmark.shield.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(AccountStyle.destructive)
                            .frame(width: 28)

                        Text("Request account deletion")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(AccountStyle.destructive)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AccountStyle.destructive.opacity(0.7))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.plain)

                Divider()
                    .padding(.leading, 58)

                Button {
                    showLogoutConfirmation = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 20))
                            .foregroundStyle(AccountStyle.title)
                            .frame(width: 28)

                        Text("Log out")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundStyle(AccountStyle.title)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AccountStyle.label)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
            }
            .background(cardBackground)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(AccountStyle.sectionHeader)
            .tracking(0.6)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: AccountStyle.cardRadius, style: .continuous)
            .fill(AccountStyle.card)
            .overlay(
                RoundedRectangle(cornerRadius: AccountStyle.cardRadius, style: .continuous)
                    .stroke(AccountStyle.border, lineWidth: 1)
            )
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: AccountStyle.fieldRadius, style: .continuous)
            .stroke(AccountStyle.border, lineWidth: 1)
            .background(
                RoundedRectangle(cornerRadius: AccountStyle.fieldRadius, style: .continuous)
                    .fill(AppTheme.card)
            )
    }

    private func fieldPrompt(_ text: String) -> Text {
        Text(text)
            .font(.system(size: 16))
            .foregroundStyle(AccountStyle.label.opacity(0.6))
    }
}

#Preview {
    NavigationStack {
        AccountScreen()
            .environment(AppSession.shared)
            .environment(AppThemeStore.shared)
    }
}
