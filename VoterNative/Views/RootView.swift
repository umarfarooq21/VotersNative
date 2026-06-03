import SwiftUI

struct RootView: View {
    @Environment(AppSession.self) private var session
    @Environment(AppThemeStore.self) private var theme

    var body: some View {
        Group {
            if session.isAuthenticated {
                InternalView()
            } else {
                LoginView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: session.isAuthenticated)
        .preferredColorScheme(theme.preferredColorScheme)
    }
}

#Preview {
    RootView()
        .environment(AppSession.shared)
        .environment(AppThemeStore.shared)
}
