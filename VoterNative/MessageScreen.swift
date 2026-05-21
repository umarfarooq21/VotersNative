import SwiftUI

struct MessageScreen: View {
    var body: some View {
        NavigationStack {
            List {
                ForEach(0..<8) { i in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 36, height: 36)
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Thread \(i + 1)").font(.body.weight(.semibold))
                                Spacer()
                                Text("6:2\(i) PM").font(.caption).foregroundStyle(.secondary)
                            }
                            Text("Last message preview goes here...")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Messages")
        }
    }
}

#Preview {
    MessageScreen()
}
