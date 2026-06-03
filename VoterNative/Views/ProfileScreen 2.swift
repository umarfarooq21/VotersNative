import SwiftUI

struct ProfileScreen: View {
    @Environment(AppSession.self) private var session
    @State private var showSignOutAlert = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        // Avatar
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text("SH")
                                    .font(.system(size: 36, weight: .semibold))
                                    .foregroundStyle(.blue)
                            )
                        
                        VStack(spacing: 4) {
                            Text("Shaheryar")
                                .font(.system(size: 28, weight: .bold))
                            
                            Text("shaheryar@inabia.com")
                                .font(.system(size: 16))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Settings Section
                    VStack(spacing: 12) {
                        settingRow(icon: "person.circle", title: "Account Settings")
                        settingRow(icon: "bell", title: "Notifications")
                        settingRow(icon: "lock.shield", title: "Privacy & Security")
                        settingRow(icon: "questionmark.circle", title: "Help & Support")
                    }
                    .padding(.horizontal, 16)
                    
                    // Sign Out Button
                    Button {
                        showSignOutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Text("Sign Out")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.red)
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                .padding(.bottom, 40)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    // Sign out and navigate back to LoginView
                    session.signOut()
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
    }
    
    private func settingRow(icon: String, title: String) -> some View {
        Button {
            // Settings action
        } label: {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(.blue)
                    .frame(width: 32)
                
                Text(title)
                    .font(.system(size: 17))
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.secondarySystemBackground))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ProfileScreen()
        .environment(AppSession.shared)
}
