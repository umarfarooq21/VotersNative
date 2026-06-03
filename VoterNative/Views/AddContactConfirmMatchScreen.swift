import SwiftUI

struct AddContactConfirmMatchScreen: View {
    let pickedContact: PickedPhoneContact
    var onFlowComplete: () -> Void

    @State private var viewModel = AddContactConfirmMatchViewModel()
    @State private var selectedMatchId: String?
    @State private var showRelationshipStep = false
    @State private var flowDraft: AddContactDraft?

    private let currentStep = 2

    private var selectedMatch: VoterFileMatch? {
        guard let selectedMatchId else { return nil }
        return viewModel.matches.first { $0.id == selectedMatchId }
    }

    private var confirmFirstName: String {
        selectedMatch?.confirmFirstName ?? pickedContact.givenName
    }

    private var showBottomActions: Bool {
        !viewModel.matches.isEmpty && !viewModel.isLoading
    }

    var body: some View {
        VStack(spacing: 0) {
            AddContactProgressHeader(currentStep: currentStep)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    content
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }

            if showBottomActions {
                bottomActions
            }
        }
        .background(AddContactFlowStyle.screenBackground.ignoresSafeArea())
        .addContactNavigationBar()
        .task {
            await loadMatches()
        }
        .onChange(of: viewModel.matches) { _, matches in
            if selectedMatchId == nil {
                selectedMatchId = matches.first?.id
            }
        }
        .refreshable {
            await loadMatches()
        }
        .navigationDestination(isPresented: $showRelationshipStep) {
            if let flowDraft {
                AddContactRelationshipScreen(draft: flowDraft, onFlowComplete: onFlowComplete)
            }
        }
    }

    // MARK: - Load

    private func loadMatches() async {
        await viewModel.search(fullName: pickedContact.fullName)
        if selectedMatchId == nil {
            selectedMatchId = viewModel.matches.first?.id
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            (
                Text("2/3 ")
                    .foregroundStyle(AddContactFlowStyle.primaryBlue)
                + Text("Confirm Match")
                    .foregroundStyle(AddContactFlowStyle.title)
            )
            .font(.system(size: 26, weight: .bold))

            Text("Select the correct voter file for '\(pickedContact.fullName)'.")
                .font(.system(size: 16))
                .foregroundStyle(AddContactFlowStyle.subtitle)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 4)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            loadingState
        } else if let error = viewModel.errorMessage, viewModel.matches.isEmpty {
            errorState(message: error)
        } else if viewModel.matches.isEmpty {
            emptyState
        } else {
            matchList
        }
    }

    private var loadingState: some View {
        VStack(alignment: .leading, spacing: 12) {
            ConfirmMatchLoadingShimmer(rowCount: 5)

            Text("Searching voter file…")
                .font(.system(size: 14))
                .foregroundStyle(AddContactFlowStyle.subtitle)
                .frame(maxWidth: .infinity)
                .padding(.top, 4)
        }
    }

    private func errorState(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundStyle(AddContactFlowStyle.subtitle)

            Text(message)
                .font(.system(size: 15))
                .foregroundStyle(AddContactFlowStyle.subtitle)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task { await loadMatches() }
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(AddContactFlowStyle.primaryBlue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 36))
                .foregroundStyle(AddContactFlowStyle.subtitle)

            Text("No voter file matches found")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(AddContactFlowStyle.title)

            Text("Try a different contact or check the spelling of their name.")
                .font(.system(size: 14))
                .foregroundStyle(AddContactFlowStyle.subtitle)
                .multilineTextAlignment(.center)

            Button("Add Manually") {
                proceedWithManualEntry()
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(AddContactFlowStyle.primaryBlue)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Matches

    private var matchList: some View {
        VStack(spacing: 12) {
            ForEach(viewModel.matches) { match in
                matchCard(match)
            }
        }
    }

    private func matchCard(_ match: VoterFileMatch) -> some View {
        let isSelected = selectedMatchId == match.id

        return Button {
            selectedMatchId = match.id
        } label: {
            HStack(alignment: .center, spacing: 14) {
                selectionIndicator(isSelected: isSelected)

                VStack(alignment: .leading, spacing: 4) {
                    Text(match.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(AddContactFlowStyle.title)
                        .multilineTextAlignment(.leading)

                    Text(match.detailLine)
                        .font(.system(size: 15))
                        .foregroundStyle(AddContactFlowStyle.subtitle)
                }

                Spacer(minLength: 8)

                Text(displayBadge(for: match))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(AddContactFlowStyle.badgeText)
                    .tracking(0.4)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        Capsule(style: .continuous)
                            .fill(AddContactFlowStyle.badgeBackground)
                    )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AddContactFlowStyle.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                isSelected ? AddContactFlowStyle.primaryBlue : AddContactFlowStyle.cardBorder,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(color: Color.black.opacity(isSelected ? 0.06 : 0.04), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private func displayBadge(for match: VoterFileMatch) -> String {
        let label = match.badgeLabel
        if label.contains("LIKELY") || label == "MANUAL" {
            return "POSSIBLE"
        }
        return label
    }

    private func selectionIndicator(isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .stroke(AddContactFlowStyle.cardBorder, lineWidth: 2)
                .frame(width: 24, height: 24)

            if isSelected {
                Circle()
                    .fill(AddContactFlowStyle.primaryBlue)
                    .frame(width: 24, height: 24)

                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }

    // MARK: - Bottom Actions

    private var bottomActions: some View {
        VStack(spacing: 14) {
            Button {
                Task { await loadMatches() }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 18, weight: .medium))
                    Text("Refine Search Results")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(AddContactFlowStyle.primaryBlue)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(AddContactFlowStyle.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(AddContactFlowStyle.cardBorder, lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)

            HStack(spacing: 4) {
                Text("None of these look right?")
                    .font(.system(size: 14))
                    .foregroundStyle(AddContactFlowStyle.subtitle)

                Button("Add Manually") {
                    proceedWithManualEntry()
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(AddContactFlowStyle.primaryBlue)
                .underline()
            }

            Button(action: proceedWithSelectedMatch) {
                Text("Confirm \(confirmFirstName)")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Capsule(style: .continuous)
                            .fill(
                                selectedMatch != nil
                                    ? AddContactFlowStyle.primaryBlue
                                    : AddContactFlowStyle.primaryBlue.opacity(0.45)
                            )
                    )
            }
            .buttonStyle(.plain)
            .disabled(selectedMatch == nil)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(AddContactFlowStyle.screenBackground)
    }

    // MARK: - Navigation

    private func proceedWithSelectedMatch() {
        guard let selectedMatch else { return }
        flowDraft = AddContactDraft(
            pickedContact: pickedContact,
            voterMatch: selectedMatch,
            isManualEntry: false
        )
        showRelationshipStep = true
    }

    private func proceedWithManualEntry() {
        flowDraft = AddContactDraft(
            pickedContact: pickedContact,
            voterMatch: .manual(from: pickedContact),
            isManualEntry: true
        )
        showRelationshipStep = true
    }
}

#Preview {
    NavigationStack {
        AddContactConfirmMatchScreen(
            pickedContact: PickedPhoneContact(
                id: "preview",
                givenName: "Anna",
                familyName: "Hart",
                fullName: "Anna Hart Whalen",
                phoneNumber: nil
            ),
            onFlowComplete: {}
        )
    }
}

private extension PickedPhoneContact {
    init(id: String, givenName: String, familyName: String, fullName: String, phoneNumber: String?) {
        self.id = id
        self.givenName = givenName
        self.familyName = familyName
        self.fullName = fullName
        self.phoneNumber = phoneNumber
    }
}
