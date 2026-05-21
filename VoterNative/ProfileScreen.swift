import SwiftUI

struct ProfileScreen: View {
    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    HStack {
                        Circle().fill(.blue).frame(width: 44, height: 44)
                        VStack(alignment: .leading) {
                            Text("Amira")
                                .font(.headline)
                            Text("amira@example.com")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Section("Preferences") {
                    Toggle("Notifications", isOn: .constant(true))
                    Toggle("Dark Mode", isOn: .constant(false))
                }
                Section {
                    Button(role: .destructive) { } label: { Text("Sign out") }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileScreen()
}
