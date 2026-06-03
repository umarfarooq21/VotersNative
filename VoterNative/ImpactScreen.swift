import SwiftUI

struct HomeScreen: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header
                header
                
                // Your Focus Today Card
                focusTodayCard
                
                // Personal Goal Card
                personalGoalCard
                
                // Captain Leaderboard Card
                captainLeaderboardCard
                
                // Community Goal Card
                communityGoalCard
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Salaam, Taha")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.primary)
            
            Text("Your community impact at a glance.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.bottom, 8)
    }
    
    // MARK: - Your Focus Today Card
    private var focusTodayCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Text("Your Focus Today")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Text("2/5")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.25))
                    )
            }
            
            Text("Check in with your key contacts today")
                .font(.body)
                .foregroundStyle(.white.opacity(0.95))
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("PROGRESS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("40%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Capsule()
                            .fill(.white.opacity(0.3))
                            .frame(height: 8)
                        
                        // Progress
                        Capsule()
                            .fill(.white)
                            .frame(width: geometry.size.width * 0.4, height: 8)
                    }
                }
                .frame(height: 8)
            }
            .padding(.top, 4)
            
            Button {
                // View contacts action
            } label: {
                HStack(spacing: 6) {
                    Text("View Contacts")
                        .font(.body)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "chevron.right")
                        .font(.body)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
            }
            .padding(.top, 4)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.4, green: 0.5, blue: 1.0),
                            Color(red: 0.6, green: 0.4, blue: 0.9)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
    }
    
    // MARK: - Personal Goal Card
    private var personalGoalCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 28))
                        .foregroundStyle(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Personal Goal")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("Goal: Confirm 50 voters")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 0) {
                    Button {
                        // Settings action
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("39/50")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
                .frame(height: 64)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("PROGRESS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("78%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Capsule()
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                        
                        // Progress
                        Capsule()
                            .fill(.blue)
                            .frame(width: geometry.size.width * 0.78, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Captain Leaderboard Card
    private var captainLeaderboardCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {
                // Trophy Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 64, height: 64)
                    
                    Text("🏆")
                        .font(.system(size: 32))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Captain Leaderboard")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("16 captains · 431 committed")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Button {
                // View full leaderboard action
            } label: {
                HStack(spacing: 6) {
                    Text("View full leaderboard")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Image(systemName: "chevron.right")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    // MARK: - Community Goal Card
    private var communityGoalCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.purple.opacity(0.15))
                        .frame(width: 64, height: 64)
                    
                    Image(systemName: "target")
                        .font(.system(size: 28))
                        .foregroundStyle(.purple)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Community Goal")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("Increasing Muslim Voter Turnout")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text("83/1,800")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("2026 COMMUNITY PROGRESS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("4.6%")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Capsule()
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                        
                        // Progress
                        Capsule()
                            .fill(.blue)
                            .frame(width: geometry.size.width * 0.046, height: 8)
                    }
                }
                .frame(height: 8)
            }
            
            Button {
                // Tap to view city breakdown
            } label: {
                HStack(spacing: 6) {
                    Text("Tap to view city breakdown")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Image(systemName: "chevron.right")
                        .font(.body)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    HomeScreen()
}
