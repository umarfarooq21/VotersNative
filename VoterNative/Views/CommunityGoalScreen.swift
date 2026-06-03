import SwiftUI

// MARK: - Design Tokens

private enum CommunityGoalStyle {
    static let background = AppTheme.screenBackground
    static let title = AppTheme.title
    static let subtitle = AppTheme.subtitle
    static let primaryBlue = AppTheme.primaryBlue
    static let accentBlue = AppTheme.accentBlue
    static let purple = AppTheme.metricPurple
    static let track = AppTheme.progressTrack
    static let segmentBackground = AppTheme.segmentBackground

    static let cardRadius: CGFloat = 16
    static let gaugeBlue = AppTheme.primaryBlue
}

// MARK: - Screen

struct CommunityGoalScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = CommunityGoalViewModel()
    @State private var selectedCycle: GoalCycle = .election2026
    @State private var isAboutExpanded = false

    enum GoalCycle: String, CaseIterable {
        case election2026 = "2026 Election Cycle"
        case overall = "Overall (7 Cycles)"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                if viewModel.isLoading && viewModel.state == nil {
                    CommunityGoalLoadingShimmer()
                } else if let error = viewModel.errorMessage, viewModel.state == nil {
                    errorState(message: error)
                } else {
                    aboutSection
                    cyclePicker

                    if let state = viewModel.state {
                        progressCard(state: state)
                        citySection(state: state)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(CommunityGoalStyle.background)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(CommunityGoalStyle.title)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(AppTheme.card))
                        .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 2)
                }
            }

            ToolbarItem(placement: .principal) {
                Text("Community Goal")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(CommunityGoalStyle.title)
            }
        }
        .toolbarBackground(CommunityGoalStyle.background, for: .navigationBar)
        .refreshable {
            await viewModel.loadPlan()
        }
        .task {
            await viewModel.loadPlan()
        }
    }

    // MARK: - About Our Goal

    private var aboutSection: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isAboutExpanded.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("About Our Goal")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(CommunityGoalStyle.subtitle)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(CommunityGoalStyle.subtitle)
                        .rotationEffect(.degrees(isAboutExpanded ? 180 : 0))
                }

                if isAboutExpanded {
                    Text(viewModel.state?.aboutText ?? "Our community goal is to increase Muslim voter turnout through organized outreach, captain-led engagement, and city-by-city progress tracking across each election cycle.")
                        .font(.system(size: 14))
                        .foregroundStyle(CommunityGoalStyle.subtitle)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }

    // MARK: - Cycle Picker

    private var cyclePicker: some View {
        HStack(spacing: 0) {
            ForEach(GoalCycle.allCases, id: \.self) { cycle in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCycle = cycle
                    }
                } label: {
                    Text(cycle.rawValue)
                        .font(.system(size: 14, weight: selectedCycle == cycle ? .semibold : .medium))
                        .foregroundStyle(selectedCycle == cycle ? CommunityGoalStyle.title : CommunityGoalStyle.subtitle)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            Group {
                                if selectedCycle == cycle {
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(AppTheme.card)
                                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(CommunityGoalStyle.segmentBackground)
        )
    }

    // MARK: - Progress Card

    private func progressCard(state: CommunityGoalUIState) -> some View {
        let isElection = selectedCycle == .election2026
        let votersText = isElection ? state.votersCountText : state.overallVotersCountText
        let percentText = isElection ? state.voterPercentText : state.overallPercentText
        let pointsValue = isElection ? state.pointsGaugeValue : CGFloat(min(state.overallVoterProgress, 1))

        return VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(isElection
                     ? "\(state.year) ELECTION CYCLE PROGRESS"
                     : "OVERALL PROGRESS (7 CYCLES)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(CommunityGoalStyle.title)
                    .tracking(0.4)

                Text(state.goalDescription)
                    .font(.system(size: 13))
                    .foregroundStyle(CommunityGoalStyle.subtitle)
            }

            HStack(alignment: .center, spacing: 8) {
                SemiCircleGaugeView(
                    pointsProgress: isElection ? state.pointsGaugeValue : pointsValue,
                    voterMilestones: gaugeMilestones(for: state, election: isElection)
                )
                .frame(width: 200, height: 130)

                Spacer(minLength: 0)

                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(votersText)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(CommunityGoalStyle.title)
                            .minimumScaleFactor(0.8)
                            .lineLimit(1)

                        Text("VOTERS")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(CommunityGoalStyle.subtitle)
                            .tracking(0.5)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(percentText)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(CommunityGoalStyle.primaryBlue)

                        Text("COMPLETE")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(CommunityGoalStyle.subtitle)
                            .tracking(0.5)
                    }
                }
                .frame(maxWidth: 140, alignment: .leading)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: CommunityGoalStyle.cardRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.accentSurface, AppTheme.softCardGradientEnd],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: CommunityGoalStyle.cardRadius, style: .continuous)
                        .stroke(AppTheme.border.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        )
    }

    private func gaugeMilestones(for state: CommunityGoalUIState, election: Bool) -> [String] {
        let total = election ? state.votersTotal : state.overallVotersTotal
        let steps = [0.25, 0.5, 0.75, 1.0]
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return steps.map { step in
            let value = Int(Double(total) * step)
            return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
        }
    }

    // MARK: - City Section

    private func citySection(state: CommunityGoalUIState) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("City-by-City Progress")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(CommunityGoalStyle.title)

                Text("Target: 1-point voter turnout increase per city")
                    .font(.system(size: 13))
                    .foregroundStyle(CommunityGoalStyle.subtitle)
            }

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            }

            VStack(spacing: 12) {
                ForEach(state.cities) { city in
                    cityCard(city)
                }
            }
        }
    }

    private func cityCard(_ city: CityProgressItem) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(city.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(CommunityGoalStyle.title)

                    Text(city.votersText)
                        .font(.system(size: 13))
                        .foregroundStyle(CommunityGoalStyle.subtitle)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(city.countText)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(CommunityGoalStyle.title)

                    Text(city.percentText)
                        .font(.system(size: 13))
                        .foregroundStyle(CommunityGoalStyle.subtitle)
                }
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(CommunityGoalStyle.track)
                        .frame(height: 8)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [CommunityGoalStyle.accentBlue, CommunityGoalStyle.purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: max(geometry.size.width * city.progress, 8),
                            height: 8
                        )
                }
            }
            .frame(height: 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: CommunityGoalStyle.cardRadius, style: .continuous)
                .fill(AppTheme.card)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }

    // MARK: - Error

    private func errorState(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(CommunityGoalStyle.subtitle)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(CommunityGoalStyle.subtitle)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task { await viewModel.loadPlan() }
            }
            .font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

// MARK: - Semi-Circle Gauge

private struct SemiCircleGaugeView: View {
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
                    .stroke(CommunityGoalStyle.track, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))

                arcPath
                    .trim(from: 0, to: min(pointsProgress, 1.0))
                    .stroke(
                        CommunityGoalStyle.gaugeBlue,
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )

                ForEach(Array(pointLabels.enumerated()), id: \.offset) { index, label in
                    let angle = Angle.degrees(180 - (Double(index) / 7.0) * 180)
                    let labelRadius = radius + 22
                    let x = center.x + CGFloat(cos(angle.radians)) * labelRadius
                    let y = center.y - CGFloat(sin(angle.radians)) * labelRadius

                    Text(label)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(CommunityGoalStyle.subtitle)
                        .position(x: x, y: y)
                }

                ForEach(Array(voterMilestones.enumerated()), id: \.offset) { index, label in
                    let angle = Angle.degrees(180 - (Double(index + 1) / Double(max(voterMilestones.count, 1))) * 135)
                    let labelRadius = radius - 18
                    let x = center.x + CGFloat(cos(angle.radians)) * labelRadius
                    let y = center.y - CGFloat(sin(angle.radians)) * labelRadius

                    Text(label)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(CommunityGoalStyle.subtitle.opacity(0.8))
                        .position(x: x, y: y)
                }

                Text("POINTS")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(CommunityGoalStyle.subtitle)
                    .tracking(0.5)
                    .position(x: center.x, y: center.y - 8)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CommunityGoalScreen()
    }
}
