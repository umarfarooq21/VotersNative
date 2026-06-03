import SwiftUI

struct AddContactRelationshipScreen: View {
    let draft: AddContactDraft
    var onFlowComplete: () -> Void

    @State private var viewModel = AddContactRelationshipViewModel()
    @State private var selectedRelationship: AddContactRelationship = .friend
    @State private var showErrorAlert = false

    private let currentStep = 3

    var body: some View {
        VStack(spacing: 0) {
            AddContactProgressHeader(currentStep: currentStep)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    relationshipList
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }

            saveFooter
        }
        .background(AddContactFlowStyle.screenBackground.ignoresSafeArea())
        .addContactNavigationBar()
        .alert("Could not save contact", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "Something went wrong. Please try again.")
        }
        .onChange(of: viewModel.errorMessage) { _, message in
            showErrorAlert = message != nil
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            (
                Text("3/3 ")
                    .foregroundStyle(AddContactFlowStyle.primaryBlue)
                + Text("How do you know them?")
                    .foregroundStyle(AddContactFlowStyle.title)
            )
            .font(.system(size: 26, weight: .bold))

            Text("Select your connection type")
                .font(.system(size: 16))
                .foregroundStyle(AddContactFlowStyle.subtitle)
        }
        .padding(.top, 4)
    }

    // MARK: - List

    private var relationshipList: some View {
        VStack(spacing: 10) {
            ForEach(AddContactRelationship.allCases) { option in
                relationshipRow(option)
            }
        }
    }

    private func relationshipRow(_ option: AddContactRelationship) -> some View {
        let isSelected = selectedRelationship == option

        return Button {
            selectedRelationship = option
        } label: {
            HStack {
                Text(option.rawValue)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(isSelected ? .white : AddContactFlowStyle.title)

                Spacer(minLength: 0)

                if isSelected {
                    ZStack {
                        Circle()
                            .fill(AppTheme.onPrimary)
                            .frame(width: 26, height: 26)

                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AddContactFlowStyle.primaryBlue)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isSelected ? AddContactFlowStyle.primaryBlue : AddContactFlowStyle.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                isSelected ? Color.clear : AddContactFlowStyle.cardBorder,
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(isSelected ? 0.08 : 0.04), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isSaving)
    }

    // MARK: - Footer

    private var saveFooter: some View {
        Button(action: saveContact) {
            HStack(spacing: 10) {
                if viewModel.isSaving {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Save Contact")
                        .font(.system(size: 17, weight: .bold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Capsule(style: .continuous)
                    .fill(
                        viewModel.isSaving
                            ? AddContactFlowStyle.primaryBlue.opacity(0.7)
                            : AddContactFlowStyle.primaryBlue
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isSaving)
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(AddContactFlowStyle.screenBackground)
    }

    // MARK: - Save

    private func saveContact() {
        Task {
            let saved = await viewModel.save(
                draft: draft,
                relationship: selectedRelationship
            )
            if saved {
                onFlowComplete()
            }
        }
    }
}

#Preview {
    let contact = PickedPhoneContact(
        id: "1",
        givenName: "Umar",
        familyName: "Haq",
        fullName: "Umar Haq",
        phoneNumber: nil
    )

    return NavigationStack {
        AddContactRelationshipScreen(
            draft: AddContactDraft(
                pickedContact: contact,
                voterMatch: VoterFileMatch(
                    id: "12260838",
                    name: "UMAR HAQ",
                    location: "Tukwila",
                    regCity: "TUKWILA",
                    phone: nil,
                    age: 25,
                    confidence: "VERY LIKELY",
                    voterStatus: "Registered",
                    alreadySavedForCaptain: false
                )
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

private extension VoterFileMatch {
    init(
        id: String,
        name: String,
        location: String,
        regCity: String,
        phone: String?,
        age: Int,
        confidence: String,
        voterStatus: String?,
        alreadySavedForCaptain: Bool
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.regCity = regCity
        self.phone = phone
        self.age = age
        self.confidence = confidence
        self.voterStatus = voterStatus
        self.alreadySavedForCaptain = alreadySavedForCaptain
    }
}
