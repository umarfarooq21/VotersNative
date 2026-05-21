import SwiftUI

struct ImpactScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Salaam,")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("Your community impact at a glance.")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    // Placeholder content matching the screenshot's spirit
                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Your Focus Today")
                                    .font(.headline)
                                Spacer()
                                Text("2/5")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            ProgressView(value: 0.4)
                                .tint(.blue)
                            Button("View Contacts") {}
                                .buttonStyle(.borderedProminent)
                        }
                    }

                    GroupBox {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Personal Goal")
                                        .font(.headline)
                                    Text("Goal: Confirm 50 voters")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("39/50")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            ProgressView(value: 0.78)
                                .tint(.indigo)
                        }
                    }

                    GroupBox {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Captain Leaderboard")
                                .font(.headline)
                            Text("16 captains · 431 committed")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Button("View full leaderboard") {}
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("Impact")
        }
    }
}

#Preview {
    ImpactScreen()
}
