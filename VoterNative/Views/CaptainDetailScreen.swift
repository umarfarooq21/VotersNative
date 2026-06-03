import SwiftUI

// MARK: - Design Tokens

private enum CaptainDetailStyle {
    static let background = AppTheme.screenBackground
    static let card = AppTheme.card
    static let title = AppTheme.title
    static let label = AppTheme.subtitle
    static let rankGradientStart = AppTheme.primaryBlue
    static let rankGradientEnd = AppTheme.accentBlue
    static let rankMuted = AppTheme.onPrimary.opacity(0.75)
    static let metricPurple = AppTheme.metricPurple
    static let metricPurpleBg = AppTheme.metricPurpleBg
    static let metricGreen = AppTheme.metricGreen
    static let metricGreenBg = AppTheme.metricGreenBg
    static let progressBlue = AppTheme.primaryBlue
    static let progressPurple = AppTheme.metricPurple
    static let progressGreen = AppTheme.success
    static let progressTrack = AppTheme.progressTrack
    static let activityIconBg = AppTheme.activityIconBg
    static let activityIcon = AppTheme.primaryBlue

    static let cardRadius: CGFloat = 16
    static let metricTileRadius: CGFloat = 14
}

// MARK: - Screen

struct CaptainDetailScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CaptainDetailViewModel

    init(captain: LeaderboardCaptain) {
        _viewModel = State(
            initialValue: CaptainDetailViewModel(
                captainId: captain.id,
                placeholderName: captain.name
            )
        )
    }

    init(captainId: String, placeholderName: String = "") {
        _viewModel = State(
            initialValue: CaptainDetailViewModel(
                captainId: captainId,
                placeholderName: placeholderName
            )
        )
    }

    var body: some View {
        Group {
            if viewModel.isLoading && viewModel.state == nil {
                CaptainDetailLoadingShimmer()
            } else if let error = viewModel.errorMessage, viewModel.state == nil {
                errorContent(message: error)
            } else if let state = viewModel.state {
                detailContent(state: state)
            } else {
                CaptainDetailLoadingShimmer()
            }
        }
        .background(CaptainDetailStyle.background)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(CaptainDetailStyle.title)
                }
            }

            ToolbarItem(placement: .principal) {
                Text(viewModel.navigationTitle)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(CaptainDetailStyle.title)
            }
        }
        .toolbarBackground(CaptainDetailStyle.background, for: .navigationBar)
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
    }

    // MARK: - Error

    private func errorContent(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(CaptainDetailStyle.label)

            Text(message)
                .font(.system(size: 15))
                .foregroundStyle(CaptainDetailStyle.label)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task { await viewModel.load() }
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(CaptainDetailStyle.rankGradientStart)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    // MARK: - Content

    private func detailContent(state: CaptainDetailState) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                rankCard(state: state)
                performanceMetricsSection(state: state)
                outreachProgressSection(state: state)
                recentActivitySection(state: state)
                captainInfoSection(state: state)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Rank Card

    private func rankCard(state: CaptainDetailState) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                Text("Leaderboard Rank")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(CaptainDetailStyle.rankMuted)

                Spacer()

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("out of")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(CaptainDetailStyle.rankMuted)

                    Text("\(state.totalCaptains)")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

            Text("#\(state.rank)")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, 8)

            HStack(spacing: 6) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(CaptainDetailStyle.rankMuted)

                Text(state.rankChangeText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(CaptainDetailStyle.rankMuted)
            }
            .padding(.top, 12)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CaptainDetailStyle.cardRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [CaptainDetailStyle.rankGradientStart, CaptainDetailStyle.rankGradientEnd],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }

    // MARK: - Performance Metrics

    private func performanceMetricsSection(state: CaptainDetailState) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Performance Metrics")

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                metricTile(
                    icon: "person.3.fill",
                    iconColor: CaptainDetailStyle.metricPurple,
                    iconBackground: CaptainDetailStyle.metricPurpleBg,
                    value: "\(state.totalContacts)",
                    valueColor: CaptainDetailStyle.title,
                    label: "Total Contacts"
                )

                metricTile(
                    icon: "bubble.left.fill",
                    iconColor: CaptainDetailStyle.metricPurple,
                    iconBackground: CaptainDetailStyle.metricPurpleBg,
                    value: "\(state.asked)",
                    valueColor: CaptainDetailStyle.title,
                    label: "Asked (\(state.askedPercent)%)"
                )

                metricTile(
                    icon: "checkmark.circle.fill",
                    iconColor: CaptainDetailStyle.metricGreen,
                    iconBackground: CaptainDetailStyle.metricGreenBg,
                    value: "\(state.agreedToVote)",
                    valueColor: CaptainDetailStyle.metricGreen,
                    label: "Agreed to Vote (\(state.agreedPercent)%)"
                )

                metricTile(
                    icon: "chart.line.uptrend.xyaxis",
                    iconColor: CaptainDetailStyle.metricPurple,
                    iconBackground: CaptainDetailStyle.metricPurpleBg,
                    value: "\(state.conversionRate)%",
                    valueColor: CaptainDetailStyle.title,
                    label: "Conversion Rate"
                )
            }
        }
    }

    private func metricTile(
        icon: String,
        iconColor: Color,
        iconBackground: Color,
        value: String,
        valueColor: Color,
        label: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(iconBackground)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(iconColor)
                )

            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(valueColor)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(CaptainDetailStyle.label)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: CaptainDetailStyle.metricTileRadius, style: .continuous)
                .fill(AppTheme.elevatedCard)
        )
    }

    // MARK: - Outreach Progress

    private func outreachProgressSection(state: CaptainDetailState) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Outreach Progress")

            VStack(spacing: 20) {
                progressRow(
                    label: "Contacts Added",
                    value: "\(state.totalContacts)",
                    progress: 1.0,
                    color: CaptainDetailStyle.progressBlue
                )

                progressRow(
                    label: "Asked",
                    value: "\(state.asked) (\(state.askedPercent)%)",
                    progress: Double(state.askedPercent) / 100.0,
                    color: CaptainDetailStyle.progressPurple
                )

                progressRow(
                    label: "Agreed to Vote",
                    value: "\(state.agreedToVote) (\(state.agreedPercent)%)",
                    progress: Double(state.agreedPercent) / 100.0,
                    color: CaptainDetailStyle.progressGreen
                )
            }
            .padding(20)
            .background(cardBackground)
        }
    }

    private func progressRow(label: String, value: String, progress: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(label)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(CaptainDetailStyle.title)

                Spacer()

                Text(value)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(CaptainDetailStyle.title)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(CaptainDetailStyle.progressTrack)
                        .frame(height: 8)

                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(min(max(progress, 0), 1)), height: 8)
                }
            }
            .frame(height: 8)
        }
    }

    // MARK: - Recent Activity

    private func recentActivitySection(state: CaptainDetailState) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Recent Activity")

            VStack(spacing: 0) {
                ForEach(Array(state.activities.enumerated()), id: \.element.id) { index, activity in
                    if index > 0 {
                        Divider()
                            .padding(.leading, 52)
                    }
                    activityRow(activity)
                }
            }
            .background(cardBackground)
        }
    }

    private func activityRow(_ activity: CaptainActivityItem) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(CaptainDetailStyle.activityIconBg)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "calendar")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(CaptainDetailStyle.activityIcon)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(CaptainDetailStyle.title)

                Text(activity.timestamp)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(CaptainDetailStyle.label)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: - Captain Info

    private func captainInfoSection(state: CaptainDetailState) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionTitle("Captain Info")

            VStack(spacing: 0) {
                infoRow(label: "Joined", value: state.joined)
                Divider().padding(.leading, 16)
                infoRow(label: "Last Active", value: state.lastActive)
                Divider().padding(.leading, 16)
                infoRow(label: "City", value: state.city)
            }
            .background(cardBackground)
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15, weight: .regular))
                .foregroundStyle(CaptainDetailStyle.label)

            Spacer()

            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(CaptainDetailStyle.title)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(CaptainDetailStyle.title)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: CaptainDetailStyle.cardRadius, style: .continuous)
            .fill(CaptainDetailStyle.card)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        CaptainDetailScreen(
            captainId: "2604a747-d6ba-4830-ab62-32527e2ab655",
            placeholderName: "Nazeer Ahmed"
        )
    }
}
