//
//  LoginView.swift
//  VoterNative
//

import SwiftUI

// MARK: - Design Tokens

private enum LoginStyle {
    static let primaryBlue = AppTheme.primaryBlue
    static let brandBlue = AppTheme.brandBlue
    static let title = AppTheme.title
    static let bodyText = AppTheme.subtitle
    static let placeholder = AppTheme.placeholder
    static let border = AppTheme.border
    static let footerText = AppTheme.sectionHeader
    static let divider = AppTheme.divider

    static let cardCornerRadius: CGFloat = 32
    static let fieldCornerRadius: CGFloat = 14
    static let buttonCornerRadius: CGFloat = 14
    static let logoCornerRadius: CGFloat = 14
    static let logoSize: CGFloat = 56
}

struct LoginView: View {
    @Environment(AppSession.self) private var session
    @State private var viewModel = LoginViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        header
                            .padding(.bottom, 28)

                        loginCard
                            .padding(.bottom, 28)

                        footerNote
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }

                if viewModel.isLoading {
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.2)
                }
            }
            .navigationBarHidden(true)
            .alert(
                "Sign In Failed",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onAppear {
                if let message = session.unauthorizedMessage {
                    viewModel.errorMessage = message
                    session.clearUnauthorizedMessage()
                }
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                AppTheme.loginGradientTop,
                AppTheme.loginGradientBottom
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // MARK: - Header

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            FriendBankingLogo()
                .frame(width: LoginStyle.logoSize, height: LoginStyle.logoSize)

            VStack(alignment: .leading, spacing: 6) {
                Text("FRIEND BANKING")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(LoginStyle.brandBlue)
                    .tracking(1.2)

                Text("Welcome back")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(LoginStyle.title)
            }

            Spacer(minLength: 0)
        }
    }

    // MARK: - Login Card

    private var loginCard: some View {
        VStack(spacing: 14) {
            socialButton(
                title: "Continue with Apple",
                icon: { AppleLogoIcon().frame(width: 18, height: 22) },
                background: .black,
                foreground: .white,
                border: nil
            )

            socialButton(
                title: "Continue with Google",
                icon: { GoogleLogoIcon().frame(width: 20, height: 20) },
                background: .white,
                foreground: LoginStyle.title,
                border: LoginStyle.border
            )

            socialButton(
                title: "Continue with Microsoft",
                icon: { MicrosoftLogoIcon().frame(width: 20, height: 20) },
                background: .white,
                foreground: LoginStyle.title,
                border: LoginStyle.border
            )

            orDivider
                .padding(.vertical, 6)

            emailField
            passwordField

            optionsRow
                .padding(.top, 2)

            signInButton
                .padding(.top, 4)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: LoginStyle.cardCornerRadius, style: .continuous)
                .fill(AppTheme.card)
                .shadow(color: Color.black.opacity(0.08), radius: 24, x: 0, y: 12)
        )
    }

    // MARK: - Fields

    private var emailField: some View {
        HStack(spacing: 12) {
            Image(systemName: "envelope")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(LoginStyle.placeholder)
                .frame(width: 22)

            TextField("", text: $viewModel.email, prompt: fieldPrompt("Email"))
                .font(.system(size: 16))
                .foregroundStyle(LoginStyle.title)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(fieldBackground)
    }

    private var passwordField: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(LoginStyle.placeholder)
                .frame(width: 22)

            Group {
                if viewModel.isPasswordVisible {
                    TextField("", text: $viewModel.password, prompt: fieldPrompt("Password"))
                } else {
                    SecureField("", text: $viewModel.password, prompt: fieldPrompt("Password"))
                }
            }
            .font(.system(size: 16))
            .foregroundStyle(LoginStyle.title)
            .textContentType(.password)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()

            Button {
                withAnimation(.easeInOut(duration: 0.15)) {
                    viewModel.isPasswordVisible.toggle()
                }
            } label: {
                Image(systemName: viewModel.isPasswordVisible ? "eye.slash" : "eye")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(LoginStyle.placeholder)
            }
            .accessibilityLabel(viewModel.isPasswordVisible ? "Hide password" : "Show password")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(fieldBackground)
    }

    private var optionsRow: some View {
        HStack {
            Button {
                viewModel.staySignedIn.toggle()
            } label: {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(LoginStyle.border, lineWidth: 1.5)
                            .frame(width: 20, height: 20)

                        if viewModel.staySignedIn {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(LoginStyle.primaryBlue)
                                .frame(width: 20, height: 20)

                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }

                    Text("Stay signed in")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(LoginStyle.bodyText)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button("Forgot Password?") {
                // TODO: Hook up action
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(LoginStyle.primaryBlue)
        }
    }

    private var signInButton: some View {
        Button {
            Task { await viewModel.signIn() }
        } label: {
            HStack(spacing: 10) {
                Text("Sign in")
                    .font(.system(size: 17, weight: .semibold))

                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                RoundedRectangle(cornerRadius: LoginStyle.buttonCornerRadius, style: .continuous)
                    .fill(viewModel.canSubmit ? LoginStyle.primaryBlue : LoginStyle.primaryBlue.opacity(0.5))
            )
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.canSubmit)
    }

    // MARK: - Footer

    private var footerNote: some View {
        Text("Your account is secured with modern encryption and\noptional device authentication.")
            .font(.system(size: 13))
            .foregroundStyle(LoginStyle.footerText)
            .multilineTextAlignment(.center)
            .lineSpacing(3)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Helpers

    private var orDivider: some View {
        HStack(spacing: 16) {
            Rectangle()
                .fill(LoginStyle.divider)
                .frame(height: 1)

            Text("OR")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(LoginStyle.placeholder)
                .tracking(0.5)

            Rectangle()
                .fill(LoginStyle.divider)
                .frame(height: 1)
        }
    }

    private var fieldBackground: some View {
        RoundedRectangle(cornerRadius: LoginStyle.fieldCornerRadius, style: .continuous)
            .fill(AppTheme.card)
            .overlay(
                RoundedRectangle(cornerRadius: LoginStyle.fieldCornerRadius, style: .continuous)
                    .stroke(LoginStyle.border, lineWidth: 1)
            )
    }

    private func fieldPrompt(_ text: String) -> Text {
        Text(text)
            .font(.system(size: 16))
            .foregroundStyle(LoginStyle.placeholder)
    }

    private func socialButton<Icon: View>(
        title: String,
        @ViewBuilder icon: () -> Icon,
        background: Color,
        foreground: Color,
        border: Color?
    ) -> some View {
        Button {
            // TODO: Social sign-in action
        } label: {
            HStack(spacing: 14) {
                icon()
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(foreground)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: LoginStyle.buttonCornerRadius, style: .continuous)
                    .fill(background)
            )
            .overlay(
                RoundedRectangle(cornerRadius: LoginStyle.buttonCornerRadius, style: .continuous)
                    .stroke(border ?? .clear, lineWidth: border == nil ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Friend Banking Logo

private struct FriendBankingLogo: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: LoginStyle.logoCornerRadius, style: .continuous)
                .fill(AppTheme.card)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)

            FriendBankingEmblem()
                .padding(10)
        }
    }
}

private struct FriendBankingEmblem: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack(alignment: .bottom) {
                // Blue shield
                ShieldShape()
                    .fill(Color(red: 0.118, green: 0.251, blue: 0.686))
                    .frame(width: w * 0.88, height: h * 0.72)
                    .offset(y: -h * 0.04)

                // Crescent
                Circle()
                    .fill(AppTheme.card)
                    .frame(width: w * 0.22, height: w * 0.22)
                    .offset(x: -w * 0.04, y: -h * 0.38)

                Circle()
                    .fill(Color(red: 0.118, green: 0.251, blue: 0.686))
                    .frame(width: w * 0.17, height: w * 0.17)
                    .offset(x: w * 0.02, y: -h * 0.38)

                // Red / white stripes
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(red: 0.863, green: 0.149, blue: 0.149))
                        .frame(height: h * 0.09)
                    Rectangle()
                        .fill(AppTheme.card)
                        .frame(height: h * 0.09)
                    Rectangle()
                        .fill(Color(red: 0.863, green: 0.149, blue: 0.149))
                        .frame(height: h * 0.09)
                }
                .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
                .frame(width: w * 0.9)
            }
        }
    }
}

private struct ShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.5, y: 0))
        path.addQuadCurve(to: CGPoint(x: w, y: h * 0.22), control: CGPoint(x: w * 0.92, y: h * 0.02))
        path.addLine(to: CGPoint(x: w * 0.88, y: h * 0.78))
        path.addQuadCurve(to: CGPoint(x: w * 0.5, y: h), control: CGPoint(x: w * 0.78, y: h * 0.95))
        path.addQuadCurve(to: CGPoint(x: w * 0.12, y: h * 0.78), control: CGPoint(x: w * 0.22, y: h * 0.95))
        path.addLine(to: CGPoint(x: 0, y: h * 0.22))
        path.addQuadCurve(to: CGPoint(x: w * 0.5, y: 0), control: CGPoint(x: w * 0.08, y: h * 0.02))
        path.closeSubpath()
        return path
    }
}

// MARK: - Social Logos

private struct AppleLogoIcon: View {
    var body: some View {
        Image(systemName: "apple.logo")
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(.white)
    }
}

private struct GoogleLogoIcon: View {
    var body: some View {
        Canvas { context, size in
            let s = min(size.width, size.height)
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let r = s * 0.42

            // Blue arc
            var blue = Path()
            blue.addArc(center: center, radius: r, startAngle: .degrees(-45), endAngle: .degrees(45), clockwise: false)
            context.stroke(blue, with: .color(Color(red: 0.259, green: 0.522, blue: 0.957)), lineWidth: s * 0.18)

            // Green arc
            var green = Path()
            green.addArc(center: center, radius: r, startAngle: .degrees(45), endAngle: .degrees(135), clockwise: false)
            context.stroke(green, with: .color(Color(red: 0.204, green: 0.659, blue: 0.325)), lineWidth: s * 0.18)

            // Yellow arc
            var yellow = Path()
            yellow.addArc(center: center, radius: r, startAngle: .degrees(135), endAngle: .degrees(225), clockwise: false)
            context.stroke(yellow, with: .color(Color(red: 0.984, green: 0.737, blue: 0.020)), lineWidth: s * 0.18)

            // Red arc
            var red = Path()
            red.addArc(center: center, radius: r, startAngle: .degrees(225), endAngle: .degrees(315), clockwise: false)
            context.stroke(red, with: .color(Color(red: 0.918, green: 0.263, blue: 0.208)), lineWidth: s * 0.18)

            // Blue horizontal bar
            var bar = Path()
            bar.move(to: CGPoint(x: center.x, y: center.y))
            bar.addLine(to: CGPoint(x: center.x + r, y: center.y))
            context.stroke(bar, with: .color(Color(red: 0.259, green: 0.522, blue: 0.957)), lineWidth: s * 0.18)
        }
    }
}

private struct MicrosoftLogoIcon: View {
    var body: some View {
        let tile: CGFloat = 9
        let gap: CGFloat = 2

        VStack(spacing: gap) {
            HStack(spacing: gap) {
                Rectangle().fill(Color(red: 0.941, green: 0.325, blue: 0.220)).frame(width: tile, height: tile)
                Rectangle().fill(Color(red: 0.490, green: 0.722, blue: 0.082)).frame(width: tile, height: tile)
            }
            HStack(spacing: gap) {
                Rectangle().fill(Color(red: 0.000, green: 0.467, blue: 0.820)).frame(width: tile, height: tile)
                Rectangle().fill(Color(red: 1.000, green: 0.725, blue: 0.008)).frame(width: tile, height: tile)
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AppSession.shared)
}
