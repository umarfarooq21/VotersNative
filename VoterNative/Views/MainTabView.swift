import SwiftUI

struct MainTabView: View {
    @Environment(AppSession.self) private var session
    @State private var selectedTab: Tab = .impact
    @State private var showProfileSheet = false
    @State private var lastSelectedTab: Tab = .impact

    enum Tab: Hashable { case impact, contacts, messages, profile }

    var body: some View {
        TabView(selection: $selectedTab) {
            ImpactScreen()
                .tabItem {
                    Label("Impact", systemImage: "chart.bar.fill")
                }
                .tag(Tab.impact)

            ContactScreen()
                .tabItem {
                    Label("Contacts", systemImage: "person.2.fill")
                }
                .tag(Tab.contacts)

            MessageScreen()
                .tabItem {
                    Label("Messages", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(Tab.messages)

            Color.clear
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(Tab.profile)
        }
        .tint(AppTheme.primaryBlue)
        .onChange(of: selectedTab) { _, newTab in
            if newTab == .profile {
                showProfileSheet = true
                selectedTab = lastSelectedTab
            } else {
                lastSelectedTab = newTab
            }
        }
        .sheet(isPresented: $showProfileSheet) {
            NavigationStack {
                ProfileSheetView()
                    .environment(session)
                    .environment(AppThemeStore.shared)
            }
            .presentationDetents([.height(420)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(ProfileSheetCornerRadius.radius)
        }
    }
}

private enum ProfileSheetCornerRadius {
    static let radius: CGFloat = 24
}

#Preview {
    MainTabView()
        .environment(AppSession.shared)
        .environment(AppThemeStore.shared)
}
