import SwiftUI

// MARK: - Design Tokens

private enum ContactStyle {
    static let background = AppTheme.screenBackground
    static let card = AppTheme.card
    static let title = AppTheme.title
    static let subtitle = AppTheme.subtitle
    static let searchBorder = AppTheme.border
    static let searchPlaceholder = AppTheme.placeholder
    static let primaryBlue = AppTheme.primaryBlue
    static let chipBackground = AppTheme.chipBackground
    static let chevron = AppTheme.chevron

    static let avatarRed = AppTheme.avatarRed
    static let avatarOrange = AppTheme.avatarOrange

    static let cardRadius: CGFloat = 16
    static let searchRadius: CGFloat = 12
}

/// Typography aligned to the Contacts mock (SF Pro / iOS large-title stack).
private enum ContactTypography {
    static let screenTitle = Font.system(size: 34, weight: .bold)
    static let countLabel = Font.system(size: 12, weight: .semibold)
    static let searchField = Font.system(size: 17, weight: .regular)
    static let searchPrompt = Font.system(size: 17, weight: .regular)
    static let contactName = Font.system(size: 17, weight: .bold)
    static let chipLabel = Font.system(size: 13, weight: .semibold)
    static let avatarInitials = Font.system(size: 15, weight: .bold)
    static let bodySecondary = Font.system(size: 15, weight: .regular)

    static let countTracking: CGFloat = 0.8
}

struct ContactScreen: View {
    @State private var viewModel = ContactsViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            screenContent
        }
    }

    private var screenContent: some View {
        ZStack {
            ContactStyle.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    header
                    searchBar
                    content
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
            .refreshable {
                await viewModel.loadContacts()
            }
        }
        .onAppear {
            Task { await viewModel.loadContacts() }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.contacts.isEmpty {
            ContactsLoadingShimmer()
        } else if let error = viewModel.errorMessage, viewModel.contacts.isEmpty {
            errorState(message: error)
        } else if viewModel.contacts.isEmpty {
            emptyState
        } else {
            VStack(spacing: 12) {
                ForEach(filteredContacts) { contact in
                    contactCard(contact)
                }
            }
        }
    }

    private var filteredContacts: [ContactItem] {
        viewModel.filteredContacts(searchText: searchText)
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center) {
                Text("Contacts")
                    .font(ContactTypography.screenTitle)
                    .foregroundStyle(ContactStyle.title)

                Spacer(minLength: 0)

                NavigationLink {
                    AddContactScreen {
                        Task { await viewModel.loadContacts() }
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(Circle().fill(ContactStyle.primaryBlue))
                        .shadow(color: ContactStyle.primaryBlue.opacity(0.35), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }

            if viewModel.isLoading && viewModel.contacts.isEmpty {
                ShimmerLine(width: 200, height: 12, cornerRadius: 4)
            } else {
                Text(viewModel.contactCountText)
                    .font(ContactTypography.countLabel)
                    .foregroundStyle(ContactStyle.subtitle)
                    .tracking(ContactTypography.countTracking)
                    .textCase(.uppercase)
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17))
                .foregroundStyle(ContactStyle.searchPlaceholder)

            TextField("", text: $searchText, prompt: searchPrompt)
                .font(ContactTypography.searchField)
                .foregroundStyle(ContactStyle.title)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            Spacer(minLength: 0)

            Button {} label: {
                Image(systemName: "arrow.up.arrow.down")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(ContactStyle.subtitle)
            }
            .buttonStyle(.plain)

            Button {} label: {
                Image(systemName: "line.3.horizontal.decrease")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(ContactStyle.subtitle)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: ContactStyle.searchRadius, style: .continuous)
                .fill(ContactStyle.card)
                .overlay(
                    RoundedRectangle(cornerRadius: ContactStyle.searchRadius, style: .continuous)
                        .stroke(ContactStyle.searchBorder, lineWidth: 1)
                )
        )
    }

    private var searchPrompt: Text {
        Text("Search contacts...")
            .font(ContactTypography.searchPrompt)
            .foregroundStyle(ContactStyle.searchPlaceholder)
    }

    // MARK: - States

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 40))
                .foregroundStyle(ContactStyle.subtitle)

            Text("No contacts found")
                .font(ContactTypography.bodySecondary)
                .foregroundStyle(ContactStyle.subtitle)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func errorState(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(ContactStyle.subtitle)

            Text(message)
                .font(ContactTypography.bodySecondary)
                .foregroundStyle(ContactStyle.subtitle)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task { await viewModel.loadContacts() }
            }
            .font(ContactTypography.chipLabel)
            .foregroundStyle(ContactStyle.primaryBlue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Contact Card

    private func contactCard(_ contact: ContactItem) -> some View {
        NavigationLink {
            ContactDetailScreen(contact: contact.toDetailContact())
        } label: {
            HStack(alignment: .center, spacing: 14) {
                avatarView(for: contact)

                VStack(alignment: .leading, spacing: 6) {
                    Text(contact.name)
                        .font(ContactTypography.contactName)
                        .foregroundStyle(ContactStyle.title)
                        .lineLimit(2)

                    actionChip(for: contact.action)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(ContactStyle.chevron)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: ContactStyle.cardRadius, style: .continuous)
                    .fill(ContactStyle.card)
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
            )
        }
        .buttonStyle(.plain)
    }

    private func avatarView(for contact: ContactItem) -> some View {
        Circle()
            .fill(avatarFill(for: contact))
            .frame(width: 48, height: 48)
            .overlay(
                Text(contact.initials)
                    .font(ContactTypography.avatarInitials)
                    .foregroundStyle(.white)
            )
    }

    private func avatarFill(for contact: ContactItem) -> Color {
        if let index = viewModel.contacts.firstIndex(where: { $0.id == contact.id }) {
            return index == 0 ? ContactStyle.avatarRed : ContactStyle.avatarOrange
        }
        return contact.color == ContactStyle.avatarRed ? ContactStyle.avatarRed : ContactStyle.avatarOrange
    }

    private func actionChip(for action: ContactItem.Action) -> some View {
        let title: String
        let icon: String

        switch action {
        case .recordStance:
            title = "Record stance"
            icon = "pencil"
        case .askToVote:
            title = "Ask to vote"
            icon = "bubble.left"
        }

        return HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .semibold))

            Text(title)
                .font(ContactTypography.chipLabel)
        }
        .foregroundStyle(ContactStyle.primaryBlue)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule(style: .continuous)
                .fill(ContactStyle.chipBackground)
        )
    }
}

#Preview {
    NavigationStack {
        ContactScreen()
    }
}
