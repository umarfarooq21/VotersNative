import SwiftUI

struct HomeScreen: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        header
                        focusCard
                        VStack(spacing: 14) {
                            smallProgressCard(title: "Personal Goal", subtitle: "Goal: Confirm 50 voters", valueText: "38/50", progress: 0.76, tint: .indigo)
                            leaderboardCard
                            smallProgressCard(title: "Community Goal", subtitle: "Increasing Muslim Voter Turnout", valueText: "771/1,800", progress: 0.43, tint: .blue)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Salaam, Shaheryar")
                    .font(.largeTitle.bold())
                Text("Your community impact at a glance.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "bell")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Focus Card
    private var focusCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your Focus Today")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Check in with your key contacts today")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("0/3")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("PROGRESS")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .textCase(.uppercase)
                }
            }

            ProgressView(value: 0.0)
                .tint(.white)
                .progressViewStyle(.linear)
                .scaleEffect(x: 1, y: 1.2, anchor: .center)

            Button {
                // TODO: View contacts action
            } label: {
                HStack(spacing: 6) {
                    Text("View Contacts")
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.indigo)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(.white))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(LinearGradient(colors: [Color.indigo, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                .shadow(color: Color.indigo.opacity(0.25), radius: 18, x: 0, y: 10)
        )
    }

    // MARK: - Small Cards
    private func smallProgressCard(title: String, subtitle: String, valueText: String, progress: CGFloat, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(valueText)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("PROGRESS")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                ProgressView(value: Double(progress))
                    .tint(tint)
                    .progressViewStyle(.linear)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var leaderboardCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Captain Leaderboard")
                        .font(.headline)
                    Text("39 captains · 104 committed")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
            }

            Button {
                // TODO: View full leaderboard
            } label: {
                HStack(spacing: 6) {
                    Text("View full leaderboard")
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                }
                .font(.subheadline.weight(.semibold))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    HomeScreen()
}
