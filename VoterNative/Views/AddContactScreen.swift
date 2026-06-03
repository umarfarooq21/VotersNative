import SwiftUI

struct AddContactScreen: View {
    @Environment(\.dismiss) private var dismiss

    var onContactSaved: (() -> Void)?

    @State private var showContactPicker = false
    @State private var showConfirmMatch = false
    @State private var pendingContact: PickedPhoneContact?

    private let currentStep = 1

    private func finishAddContactFlow() {
        showConfirmMatch = false
        pendingContact = nil
        onContactSaved?()
        dismiss()
    }

    var body: some View {
        VStack(spacing: 0) {
            AddContactProgressHeader(currentStep: currentStep)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)

            Spacer(minLength: 0)

            stepContent

            Spacer(minLength: 0)
        }
        .background(AddContactFlowStyle.background.ignoresSafeArea())
        .addContactNavigationBar()
        .sheet(isPresented: $showContactPicker) {
            PhoneContactPicker(isPresented: $showContactPicker) { contact in
                pendingContact = contact
                showConfirmMatch = true
            }
        }
        .navigationDestination(isPresented: $showConfirmMatch) {
            if let pendingContact {
                AddContactConfirmMatchScreen(
                    pickedContact: pendingContact,
                    onFlowComplete: finishAddContactFlow
                )
            }
        }
        .onChange(of: showConfirmMatch) { _, isShowing in
            if !isShowing {
                pendingContact = nil
            }
        }
    }

    // MARK: - Step 1

    private var stepContent: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(AddContactFlowStyle.iconCircle)
                    .frame(width: 120, height: 120)

                Image(systemName: "person.badge.plus")
                    .font(.system(size: 44, weight: .medium))
                    .foregroundStyle(AddContactFlowStyle.primaryBlue)
            }
            .padding(.bottom, 28)

            (
                Text("1/3 ")
                    .foregroundStyle(AddContactFlowStyle.primaryBlue)
                + Text("Import from Contacts")
                    .foregroundStyle(AddContactFlowStyle.title)
            )
            .font(.system(size: 26, weight: .bold))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
            .padding(.bottom, 14)

            Text("Select a contact from your phone's address book to check their registration status.")
                .font(.system(size: 16))
                .foregroundStyle(AddContactFlowStyle.subtitle)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)
                .padding(.bottom, 36)

            Button {
                showContactPicker = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Select Contact")
                        .font(.system(size: 17, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule(style: .continuous)
                        .fill(AddContactFlowStyle.primaryBlue)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)

            Text("We verify against the voter file securely.")
                .font(.system(size: 14))
                .foregroundStyle(AddContactFlowStyle.footer)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.top, 20)
        }
    }
}

#Preview {
    NavigationStack {
        AddContactScreen()
    }
}
