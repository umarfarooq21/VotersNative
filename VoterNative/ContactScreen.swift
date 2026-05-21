import SwiftUI

struct ContactScreen: View {
    var body: some View {
        NavigationStack {
            List {
                Section("Key Contacts") {
                    ForEach(0..<10) { i in
                        HStack {
                            Circle()
                                .fill(Color.blue.opacity(0.2))
                                .frame(width: 36, height: 36)
                                .overlay(Text(String(i+1)).font(.footnote))
                            VStack(alignment: .leading) {
                                Text("Contact \(i + 1)")
                                Text("Last checked in 2d ago")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Contacts")
        }
    }
}

#Preview {
    ContactScreen()
}
