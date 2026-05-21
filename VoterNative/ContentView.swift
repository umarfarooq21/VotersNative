//
//  ContentView.swift
//  VoterNative
//
//  Created by Muhammad Umar on 5/21/26.
//

import SwiftUI

struct ContentView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @State private var navigateToHome: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack {
                    NavigationLink(destination: MainTabView(), isActive: $navigateToHome) { EmptyView() }.hidden()

                    ScrollView {
                        VStack(spacing: 24) {
                            header

                            card

                            footerNote
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // App badge placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(LinearGradient(colors: [Color.blue, Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 44, height: 44)
                    Image(systemName: "banknote.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(15))
                        .offset(x: -1, y: 1)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("FRIEND BANKING")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.blue)
                    Text("Welcome back")
                        .font(.largeTitle.bold())
                        .foregroundStyle(Color.primary)
                }
                Spacer()
            }
        }
    }

    // MARK: - Card
    private var card: some View {
        VStack(spacing: 16) {
            // Social buttons
            socialButton(title: "Continue with Apple", systemImage: "apple.logo", tint: .black, foreground: .white)
            socialButton(title: "Continue with Google", systemImage: "g.circle.fill", tint: .white, foreground: .primary, border: Color(white: 0.88))
            socialButton(title: "Continue with Microsoft", systemImage: "m.circle.fill", tint: .white, foreground: .primary, border: Color(white: 0.88))

            // Divider with OR
            HStack {
                Divider().frame(height: 1).background(Color(white: 0.9))
                Text("OR")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.secondary)
                Divider().frame(height: 1).background(Color(white: 0.9))
            }
            .padding(.vertical, 4)

            // Email field
            HStack(spacing: 10) {
                Image(systemName: "envelope")
                    .foregroundStyle(.secondary)
                TextField("name@example.com", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(.secondarySystemBackground)))

            // Password field with visibility toggle
            HStack(spacing: 10) {
                Image(systemName: "lock")
                    .foregroundStyle(.secondary)
                Group {
                    if isPasswordVisible {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                }
                .textContentType(.password)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

                Button(action: { withAnimation { isPasswordVisible.toggle() } }) {
                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel(isPasswordVisible ? "Hide password" : "Show password")
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color(.secondarySystemBackground)))

            // Forgot password
            HStack {
                Spacer()
                Button("Forgot Password?") {
                    // TODO: Hook up action
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.blue)
            }
            .padding(.top, 4)

            // Sign in button
            Button(action: {
                // TODO: Validate credentials, then navigate
                navigateToHome = true
            }) {
                HStack {
                    Text("Sign in")
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .fontWeight(.semibold)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 16)
                .foregroundStyle(.white)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(LinearGradient(colors: [Color.blue, Color.indigo], startPoint: .leading, endPoint: .trailing))
                )
            }
            .buttonStyle(.plain)
            .shadow(color: Color.blue.opacity(0.25), radius: 10, x: 0, y: 6)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 20, x: 0, y: 10)
        )
    }

    // MARK: - Footer
    private var footerNote: some View {
        VStack(spacing: 8) {
            Text("Your account is secured with modern encryption and\noptional device authentication.")
                .font(.footnote)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    // MARK: - Helpers
    private func socialButton(title: String, systemImage: String, tint: Color, foreground: Color, border: Color? = nil) -> some View {
        Button(action: {
            // TODO: Social sign-in action
        }) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                Text(title)
                    .fontWeight(.semibold)
                Spacer()
            }
            .foregroundStyle(foreground)
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(tint)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(border ?? .clear, lineWidth: border == nil ? 0 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
