import SwiftUI

/// Example screen demonstrating `UsersViewModel` + `APIService`.
struct UsersListView: View {
    @State private var viewModel = UsersViewModel()
    @State private var showCreateForm = false

    var body: some View {
        List {
            contentSection
        }
        .navigationTitle("Users")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Add") { showCreateForm = true }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    Task { await viewModel.loadUsers() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .disabled(viewModel.isLoading)
            }
        }
        .overlay {
            if viewModel.isLoading && viewModel.users.isEmpty {
                ProgressView("Loading users…")
            }
        }
        .task {
            if viewModel.state == .idle {
                await viewModel.loadUsers()
            }
        }
        .sheet(isPresented: $showCreateForm) {
            createUserSheet
        }
        .alert(
            "Could Not Create User",
            isPresented: Binding(
                get: { viewModel.createErrorMessage != nil },
                set: { if !$0 { viewModel.createErrorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.createErrorMessage ?? "")
        }
    }

    @ViewBuilder
    private var contentSection: some View {
        switch viewModel.state {
        case .idle, .loading where viewModel.users.isEmpty:
            EmptyView()
        case .empty:
            ContentUnavailableView("No Users", systemImage: "person.3", description: Text("No users found."))
        case .error(let message):
            ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(message))
        case .loaded, .loading:
            ForEach(viewModel.users) { user in
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.displayName)
                        .font(.headline)
                    if let email = user.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var createUserSheet: some View {
        NavigationStack {
            Form {
                Section("New User") {
                    TextField("Email", text: $viewModel.newEmail)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    TextField("Username", text: $viewModel.newUsername)
                    TextField("First Name", text: $viewModel.newFirstName)
                    TextField("Last Name", text: $viewModel.newLastName)
                    SecureField("Password", text: $viewModel.newPassword)
                }
            }
            .navigationTitle("Create User")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showCreateForm = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.createUser()
                            if viewModel.createErrorMessage == nil {
                                showCreateForm = false
                            }
                        }
                    }
                    .disabled(viewModel.isCreating)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        UsersListView()
    }
}
