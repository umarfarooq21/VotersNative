import SwiftUI

// MARK: - Design Tokens

private enum RecipientPickerStyle {
    static let title = AppTheme.title
    static let subtitle = AppTheme.subtitle
    static let sectionHeader = AppTheme.sectionHeader
    static let primaryBlue = AppTheme.primaryBlue
    static let searchBackground = AppTheme.searchFieldBackground
    static let grabber = AppTheme.grabber
    static let divider = AppTheme.divider
}

// MARK: - Sheet

struct MessageRecipientPickerSheet: View {
    @Binding var selectedRecipient: MessageRecipient
    @Binding var isPresented: Bool

    @State private var viewModel = ContactsViewModel()
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            grabber
            header
            searchBar
            contactList
        }
        .background(AppTheme.sheetBackground)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .task {
            await viewModel.loadContacts()
            selectFirstContactIfNeeded()
        }
    }

    // MARK: - Header

    private var grabber: some View {
        Capsule()
            .fill(RecipientPickerStyle.grabber)
            .frame(width: 36, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 12)
    }

    private var header: some View {
        HStack {
            Text("To")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(RecipientPickerStyle.title)

            Spacer()

            Button("Done") {
                isPresented = false
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(RecipientPickerStyle.primaryBlue)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 14)
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17))
                .foregroundStyle(RecipientPickerStyle.subtitle)

            TextField("", text: $searchText, prompt: searchPrompt)
                .font(.system(size: 17))
                .foregroundStyle(RecipientPickerStyle.title)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(RecipientPickerStyle.searchBackground)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    private var searchPrompt: Text {
        Text("Search contacts")
            .font(.system(size: 17))
            .foregroundStyle(RecipientPickerStyle.subtitle)
    }

    // MARK: - List

    private var contactList: some View {
        Group {
            if viewModel.isLoading && viewModel.contacts.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if groupedContacts.isEmpty {
                Text("No contacts found")
                    .font(.system(size: 15))
                    .foregroundStyle(RecipientPickerStyle.subtitle)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                        ForEach(groupedContacts, id: \.letter) { section in
                            Section {
                                ForEach(section.contacts) { contact in
                                    contactRow(MessageRecipient(contact: contact))
                                }
                            } header: {
                                sectionHeader(section.letter)
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private var groupedContacts: [(letter: String, contacts: [ContactItem])] {
        let filtered = viewModel.filteredContacts(searchText: searchText)
        let grouped = Dictionary(grouping: filtered) { contact -> String in
            let first = contact.name.trimmingCharacters(in: .whitespacesAndNewlines).first
            guard let char = first else { return "#" }
            return String(char).uppercased()
        }

        return grouped.keys.sorted().map { letter in
            let contacts = grouped[letter]?
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending } ?? []
            return (letter: letter, contacts: contacts)
        }
    }

    private func sectionHeader(_ letter: String) -> some View {
        Text(letter)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(RecipientPickerStyle.sectionHeader)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 6)
            .background(AppTheme.sheetBackground)
    }

    private func contactRow(_ recipient: MessageRecipient) -> some View {
        VStack(spacing: 0) {
            Button {
                selectedRecipient = recipient
                isPresented = false
            } label: {
                HStack(alignment: .top, spacing: 14) {
                    Circle()
                        .fill(recipient.color)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Text(recipient.initials)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipient.name.uppercased())
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(RecipientPickerStyle.title)
                            .multilineTextAlignment(.leading)

                        if !recipient.addressLine.isEmpty {
                            Text(recipient.addressLine.uppercased())
                                .font(.system(size: 13))
                                .foregroundStyle(RecipientPickerStyle.subtitle)
                                .multilineTextAlignment(.leading)
                        }
                    }

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Divider()
                .overlay(RecipientPickerStyle.divider)
                .padding(.leading, 78)
        }
    }

    private func selectFirstContactIfNeeded() {
        guard selectedRecipient.id == MessageRecipient.placeholder.id,
              let first = viewModel.contacts.first else { return }
        selectedRecipient = MessageRecipient(contact: first)
    }
}
