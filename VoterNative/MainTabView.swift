import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .impact

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

            ProfileScreen()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle.fill")
                }
                .tag(Tab.profile)
        }
        .tint(.blue)
    }
}

#Preview {
    MainTabView()
}
