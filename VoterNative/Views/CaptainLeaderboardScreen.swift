import SwiftUI

// MARK: - Design Tokens

private enum LeaderboardStyle {
    static let background = AppTheme.screenBackground
    static let title = AppTheme.title
    static let subtitle = AppTheme.subtitle
    static let primaryBlue = AppTheme.primaryBlue
    static let accentBlue = AppTheme.accentBlue
    static let track = AppTheme.progressTrack
    static let gaugeBlue = AppTheme.primaryBlue
    static let gold = AppTheme.gold
    static let segmentBackground = AppTheme.segmentBackground
    static let metricSelectedBg = AppTheme.metricSelectedBackground
    static let tableBackground = AppTheme.tableBackground

    static let cardRadius: CGFloat = 16
}

// MARK: - Screen

struct CaptainLeaderboardScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CaptainLeaderboardViewModel()
    @State private var selectedCycle: LeaderboardCycle = .year2026
    @State private var selectedMetric: LeaderboardMetric = .included
    @State private var isHintExpanded = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.isLoading && viewModel.state == nil {
                    CaptainLeaderboardLoadingShimmer()
                } else if let error = viewModel.errorMessage, viewModel.state == nil {
                    errorState(message: error)
                } else if let state = viewModel.state {
                    goalProgressCard(state: state)
                    metricHintSection
                    metricCards(state: state)
                    leaderboardSection(state: state)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(LeaderboardStyle.background)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LeaderboardStyle.title)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(AppTheme.card))
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                }
            }

            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Captain Leaderboard")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(LeaderboardStyle.title)

                    if let state = viewModel.state {
                        Text("\(state.captainCount) captains · Viewing \(selectedMetric.viewingLabel)")
                            .font(.system(size: 12))
                            .foregroundStyle(LeaderboardStyle.subtitle)
                    }
                }
            }
        }
        .toolbarBackground(LeaderboardStyle.background, for: .navigationBar)
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
    }

    // MARK: - Error

    private func errorState(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(LeaderboardStyle.subtitle)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(LeaderboardStyle.subtitle)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task { await viewModel.load() }
            }
            .font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    // MARK: - Goal Progress Card

    private func goalProgressCard(state: CaptainLeaderboardState) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("2026 Goal Progress")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(LeaderboardStyle.title)

                    Text(state.goalSubtitle)
                        .font(.system(size: 13))
                        .foregroundStyle(LeaderboardStyle.subtitle)
                }

                Spacer(minLength: 8)

                compactCyclePicker
            }

            HStack(alignment: .center, spacing: 8) {
                LeaderboardGaugeView(
                    pointsProgress: state.pointsGaugeValue,
                    voterMilestones: state.voterMilestones
                )
                .frame(width: 200, height: 130)

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(state.votersCountText)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(LeaderboardStyle.title)
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)

                        Text("VOTERS")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(LeaderboardStyle.subtitle)
                            .tracking(0.5)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(state.percentText)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(LeaderboardStyle.primaryBlue)

                        Text("COMPLETE")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(LeaderboardStyle.subtitle)
                            .tracking(0.5)
                    }
                }
                .frame(maxWidth: 140, alignment: .leading)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: LeaderboardStyle.cardRadius, style: .continuous)
                .fill(AppTheme.card)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
        )
    }

    private var compactCyclePicker: some View {
        HStack(spacing: 0) {
            ForEach(LeaderboardCycle.allCases, id: \.self) { cycle in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCycle = cycle
                    }
                } label: {
                    Text(cycle.rawValue)
                        .font(.system(size: 13, weight: selectedCycle == cycle ? .semibold : .medium))
                        .foregroundStyle(selectedCycle == cycle ? LeaderboardStyle.title : LeaderboardStyle.subtitle)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(
                            Group {
                                if selectedCycle == cycle {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .fill(AppTheme.card)
                                        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(LeaderboardStyle.segmentBackground)
        )
    }

    // MARK: - Metrics

    private var metricHintSection: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isHintExpanded.toggle()
            }
        } label: {
            HStack {
                Text("Tap a metric to update the chart and table.")
                    .font(.system(size: 14))
                    .foregroundStyle(LeaderboardStyle.subtitle)

                Spacer()

                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(LeaderboardStyle.subtitle)
                    .rotationEffect(.degrees(isHintExpanded ? 180 : 0))
            }
        }
        .buttonStyle(.plain)
    }

    private func metricCards(state: CaptainLeaderboardState) -> some View {
        HStack(spacing: 10) {
            ForEach(LeaderboardMetric.allCases) { metric in
                metricCard(
                    metric: metric,
                    value: state.metricValue(metric),
                    isSelected: selectedMetric == metric
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedMetric = metric
                    }
                }
            }
        }
    }

    private func metricCard(
        metric: LeaderboardMetric,
        value: Int,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: metric.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(isSelected ? LeaderboardStyle.primaryBlue : LeaderboardStyle.subtitle)

                Text(metric.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isSelected ? LeaderboardStyle.primaryBlue : LeaderboardStyle.subtitle)
                    .tracking(0.3)

                Text("\(value)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(LeaderboardStyle.title)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? LeaderboardStyle.metricSelectedBg : AppTheme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? LeaderboardStyle.primaryBlue : AppTheme.border, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Leaderboard Table

    private func leaderboardSection(state: CaptainLeaderboardState) -> some View {
        let captains = viewModel.sortedCaptains(metric: selectedMetric)

        return VStack(alignment: .leading, spacing: 12) {
            if captains.isEmpty {
                Text("No captains on the leaderboard yet.")
                    .font(.system(size: 15))
                    .foregroundStyle(LeaderboardStyle.subtitle)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(
                        RoundedRectangle(cornerRadius: LeaderboardStyle.cardRadius, style: .continuous)
                            .fill(LeaderboardStyle.tableBackground)
                    )
            } else {
                leaderboardTable(captains: captains)
            }
        }
    }

    private func leaderboardTable(captains: [LeaderboardCaptain]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("LEADERBOARD")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(LeaderboardStyle.subtitle)
                    .tracking(0.6)

                Spacer()

                Button {} label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 20))
                        .foregroundStyle(LeaderboardStyle.subtitle)
                }

                Button {} label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(LeaderboardStyle.subtitle)
                }
            }

            VStack(spacing: 0) {
                tableHeader

                ForEach(Array(captains.enumerated()), id: \.element.id) { index, captain in
                    if index > 0 {
                        Divider()
                            .padding(.leading, 56)
                    }
                    leaderboardRow(captain: captain, metric: selectedMetric)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: LeaderboardStyle.cardRadius, style: .continuous)
                    .fill(LeaderboardStyle.tableBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: LeaderboardStyle.cardRadius, style: .continuous))
        }
    }

    private var tableHeader: some View {
        HStack {
            Text("RANK")
                .frame(width: 44, alignment: .leading)

            Text("CAPTAIN")
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(selectedMetric.rawValue)
                .frame(width: 56, alignment: .trailing)
        }
        .font(.system(size: 11, weight: .semibold))
        .foregroundStyle(LeaderboardStyle.subtitle)
        .tracking(0.5)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.card.opacity(0.6))
    }

    private func leaderboardRow(captain: LeaderboardCaptain, metric: LeaderboardMetric) -> some View {
        NavigationLink {
            CaptainDetailScreen(captain: captain)
        } label: {
            HStack(alignment: .center, spacing: 12) {
                Text("\(captain.rank)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(captain.rank == 1 ? LeaderboardStyle.gold : LeaderboardStyle.subtitle)
                    .frame(width: 32, alignment: .leading)

                Circle()
                    .fill(LeaderboardStyle.primaryBlue)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(captain.initials)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(captain.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(LeaderboardStyle.title)

                    Text(captain.city)
                        .font(.system(size: 13))
                        .foregroundStyle(LeaderboardStyle.subtitle)
                }

                Spacer(minLength: 0)

                Text("\(captain.value(for: metric))")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(LeaderboardStyle.title)
                    .frame(width: 44, alignment: .trailing)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppTheme.card)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Gauge

private struct LeaderboardGaugeView: View {
    let pointsProgress: CGFloat
    let voterMilestones: [String]

    private let pointLabels = ["0", "1", "2", "3", "4", "5", "6", "7"]

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height * 2)
            let lineWidth: CGFloat = 14
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height * 0.92)
            let radius = size / 2 - lineWidth

            let arcPath = Path { path in
                path.addArc(
                    center: center,
                    radius: radius,
                    startAngle: .degrees(180),
                    endAngle: .degrees(0),
                    clockwise: false
                )
            }

            ZStack {
                arcPath
                    .stroke(LeaderboardStyle.track, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

                arcPath
                    .trim(from: 0, to: min(pointsProgress, 1.0))
                    .stroke(
                        LeaderboardStyle.gaugeBlue,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )

                ForEach(Array(pointLabels.enumerated()), id: \.offset) { index, label in
                    let angle = Angle.degrees(180 - (Double(index) / 7.0) * 180)
                    let labelRadius = radius + 22
                    let x = center.x + CGFloat(cos(angle.radians)) * labelRadius
                    let y = center.y - CGFloat(sin(angle.radians)) * labelRadius

                    Text(label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(LeaderboardStyle.subtitle)
                        .position(x: x, y: y)
                }

                ForEach(Array(voterMilestones.enumerated()), id: \.offset) { index, label in
                    let angle = Angle.degrees(180 - (Double(index + 1) / Double(max(voterMilestones.count, 1))) * 135)
                    let labelRadius = radius - 18
                    let x = center.x + CGFloat(cos(angle.radians)) * labelRadius
                    let y = center.y - CGFloat(sin(angle.radians)) * labelRadius

                    Text(label)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(LeaderboardStyle.subtitle.opacity(0.8))
                        .position(x: x, y: y)
                }

                Text("POINTS")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(LeaderboardStyle.subtitle)
                    .tracking(0.5)
                    .position(x: center.x, y: center.y - 8)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CaptainLeaderboardScreen()
    }
}
