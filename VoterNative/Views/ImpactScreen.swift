import SwiftUI

// MARK: - Design Tokens

private enum ImpactStyle {
    static let screenBackground = AppTheme.screenBackground
    static let cardBackground = AppTheme.card
    static let title = AppTheme.title
    static let subtitle = AppTheme.subtitle
    static let primaryBlue = AppTheme.brandBlue
    static let badgeBackground = AppTheme.chipBackground
    static let progressTrack = AppTheme.progressTrack

    static let cardCornerRadius: CGFloat = 26
    static let iconContainerSize: CGFloat = 48
    static let iconContainerRadius: CGFloat = 12
    static let progressBarHeight: CGFloat = 8
}

private struct ImpactCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: ImpactStyle.cardCornerRadius, style: .continuous)
                    .fill(ImpactStyle.cardBackground)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
            )
    }
}

private extension View {
    func impactCard() -> some View {
        modifier(ImpactCardModifier())
    }
}

struct ImpactScreen: View {
    @State private var showSetGoalDialog = false
    @State private var personalGoalTarget = 50
    @State private var personalGoalProgress: CGFloat = 0.78

    private var personalGoalCurrent: Int {
        min(Int((CGFloat(personalGoalTarget) * personalGoalProgress).rounded()), personalGoalTarget)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 16) {
                        header
                        focusTodayCard
                        personalGoalCard
                        captainLeaderboardCard
                        communityGoalCard
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 32)
                }
                .background(ImpactStyle.screenBackground)

                if showSetGoalDialog {
                    SetPersonalGoalOverlay(
                        isPresented: $showSetGoalDialog,
                        goalValue: $personalGoalTarget
                    )
                }
            }
            .navigationBarHidden(true)
            .animation(.spring(response: 0.35, dampingFraction: 0.86), value: showSetGoalDialog)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Salaam, Taha")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(ImpactStyle.title)

            Text("Your community impact at a glance.")
                .font(.system(size: 17))
                .foregroundStyle(ImpactStyle.subtitle)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }

    // MARK: - Your Focus Today Card

    private var focusTodayCard: some View {
        NavigationLink {
            YourFocusTodayScreen()
        } label: {
            focusTodayCardContent
        }
        .buttonStyle(.plain)
    }

    private var focusTodayCardContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                Text("Your Focus Today")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)

                Spacer()

                Text("2/5")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.25))
                    )
            }

            Text("Check in with your key contacts today")
                .font(.system(size: 17))
                .foregroundStyle(.white.opacity(0.95))

            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("PROGRESS")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .tracking(0.5)

                    Spacer()

                    Text("40%")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(.white)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.white.opacity(0.3))
                            .frame(height: 10)

                        Capsule()
                            .fill(.white)
                            .frame(width: geometry.size.width * 0.4, height: 10)
                    }
                }
                .frame(height: 10)
            }

            HStack(spacing: 8) {
                Text("View Contacts")
                    .font(.system(size: 17, weight: .semibold))

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundStyle(.white)
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.accentBlue, AppTheme.metricPurple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }

    // MARK: - Personal Goal Card

    private var personalGoalCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 14) {
                iconContainer(
                    background: AppTheme.accentSurface,
                    systemName: "chart.line.uptrend.xyaxis",
                    iconColor: ImpactStyle.primaryBlue
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text("Personal Goal")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(ImpactStyle.title)

                    Text("Goal: Confirm \(personalGoalTarget) voters")
                        .font(.system(size: 14))
                        .foregroundStyle(ImpactStyle.subtitle)
                }

                Spacer(minLength: 8)

                HStack(spacing: 10) {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                            showSetGoalDialog = true
                        }
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(ImpactStyle.subtitle)
                    }
                    .buttonStyle(.plain)

                    progressBadge("\(personalGoalCurrent)/\(personalGoalTarget)")
                }
            }

            progressSection(
                label: "PROGRESS",
                value: "\(Int(personalGoalProgress * 100))%",
                progress: personalGoalProgress
            )
        }
        .impactCard()
    }

    // MARK: - Captain Leaderboard Card

    private var captainLeaderboardCard: some View {
        NavigationLink {
            CaptainLeaderboardScreen()
        } label: {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .center, spacing: 14) {
                    iconContainer(
                        background: AppTheme.metricGoldBg,
                        systemName: "trophy.fill",
                        iconColor: AppTheme.metricGoldIcon
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Captain Leaderboard")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(ImpactStyle.title)

                        Text("16 captains · 431 committed")
                            .font(.system(size: 14))
                            .foregroundStyle(ImpactStyle.subtitle)
                    }

                    Spacer(minLength: 0)
                }

                HStack(spacing: 4) {
                    Text("View full leaderboard")
                        .font(.system(size: 15, weight: .medium))

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(ImpactStyle.subtitle)
            }
            .impactCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Community Goal Card

    private var communityGoalCard: some View {
        NavigationLink {
            CommunityGoalScreen()
        } label: {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .center, spacing: 14) {
                    iconContainer(
                        background: AppTheme.metricPurpleBg,
                        systemName: "target",
                        iconColor: AppTheme.metricPurple
                    )

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Community Goal")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(ImpactStyle.title)

                        Text("Increasing Muslim Voter Turnout")
                            .font(.system(size: 14))
                            .foregroundStyle(ImpactStyle.subtitle)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)

                    progressBadge("84/1,800")
                }

                progressSection(label: "2026 COMMUNITY PROGRESS", value: "4.7%", progress: 0.047)

                HStack(spacing: 4) {
                    Text("Tap to view city breakdown")
                        .font(.system(size: 15, weight: .medium))

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                }
                .foregroundStyle(ImpactStyle.subtitle)
            }
            .impactCard()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Shared Components

    private func iconContainer(background: Color, systemName: String, iconColor: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: ImpactStyle.iconContainerRadius, style: .continuous)
                .fill(background)
                .frame(width: ImpactStyle.iconContainerSize, height: ImpactStyle.iconContainerSize)

            Image(systemName: systemName)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(iconColor)
        }
    }

    private func progressBadge(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(ImpactStyle.primaryBlue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(ImpactStyle.badgeBackground)
            )
    }

    private func progressSection(label: String, value: String, progress: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(ImpactStyle.subtitle)
                    .tracking(0.6)

                Spacer()

                Text(value)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(ImpactStyle.title)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(ImpactStyle.progressTrack)
                        .frame(height: ImpactStyle.progressBarHeight)

                    Capsule()
                        .fill(ImpactStyle.primaryBlue)
                        .frame(
                            width: max(geometry.size.width * progress, ImpactStyle.progressBarHeight),
                            height: ImpactStyle.progressBarHeight
                        )
                }
            }
            .frame(height: ImpactStyle.progressBarHeight)
        }
    }

    private func cardFooterLink(_ title: String) -> some View {
        Button {
            // Action
        } label: {
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .medium))

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(ImpactStyle.subtitle)
        }
    }
}

#Preview {
    ImpactScreen()
}
