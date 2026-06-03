import SwiftUI

/// Authenticated app shell shown after a successful login.
struct InternalView: View {
    @Environment(AppSession.self) private var session

    var body: some View {
        MainTabView()
    }
}

#Preview {
    InternalView()
        .environment(AppSession.shared)
}
