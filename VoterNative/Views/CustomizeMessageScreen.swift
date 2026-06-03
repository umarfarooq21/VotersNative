import SwiftUI
import UIKit

// MARK: - Design Tokens

private enum CustomizeMessageStyle {
    static let background = AppTheme.screenBackground
    static let card = AppTheme.card
    static let title = AppTheme.title
    static let subtitle = AppTheme.subtitle
    static let sectionLabel = AppTheme.sectionHeader
    static let primaryBlue = AppTheme.primaryBlue
    static let fieldBorder = AppTheme.border
    static let cardRadius: CGFloat = 14
}

// MARK: - Recipient

struct MessageRecipient: Identifiable, Hashable {
    let id: String
    let name: String
    let firstName: String
    let phone: String?
    let initials: String
    let color: Color
    let addressLine: String

    init(contact: ContactItem) {
        id = contact.id
        name = contact.name
        firstName = contact.name.components(separatedBy: " ").first ?? contact.name
        phone = contact.phone
        initials = contact.initials
        color = contact.color
        let parts = [contact.address, contact.city]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0 != "—" }
        addressLine = parts.joined(separator: ", ")
    }

    static let placeholder = MessageRecipient(
        id: "placeholder",
        name: "Muhammad Ali",
        firstName: "Muhammad",
        phone: nil,
        initials: "MA",
        color: .purple,
        addressLine: ""
    )

    private init(
        id: String,
        name: String,
        firstName: String,
        phone: String?,
        initials: String,
        color: Color,
        addressLine: String
    ) {
        self.id = id
        self.name = name
        self.firstName = firstName
        self.phone = phone
        self.initials = initials
        self.color = color
        self.addressLine = addressLine
    }
}

// MARK: - Screen

struct CustomizeMessageScreen: View {
    let template: MessageTemplate

    @Environment(\.dismiss) private var dismiss
    @State private var selectedRecipient: MessageRecipient = .placeholder
    @State private var messageText: String = ""
    @State private var showRecipientPicker = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    recipientRow
                    smsPreviewSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }

            footer
        }
        .background(CustomizeMessageStyle.background.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(CustomizeMessageStyle.title)
                }
            }

            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Customize message")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(CustomizeMessageStyle.title)

                    Text(template.title)
                        .font(.system(size: 13))
                        .foregroundStyle(CustomizeMessageStyle.subtitle)
                }
            }
        }
        .toolbarBackground(CustomizeMessageStyle.background, for: .navigationBar)
        .sheet(isPresented: $showRecipientPicker) {
            MessageRecipientPickerSheet(
                selectedRecipient: $selectedRecipient,
                isPresented: $showRecipientPicker
            )
        }
        .onAppear {
            messageText = template.resolvedBody(firstName: selectedRecipient.firstName)
        }
        .onChange(of: selectedRecipient) { _, recipient in
            messageText = template.resolvedBody(firstName: recipient.firstName)
        }
    }

    // MARK: - Recipient Row

    private var recipientRow: some View {
        Button {
            showRecipientPicker = true
        } label: {
            HStack(spacing: 12) {
                Text("To")
                    .font(.system(size: 16))
                    .foregroundStyle(CustomizeMessageStyle.subtitle)

                Text(selectedRecipient.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(CustomizeMessageStyle.title)
                    .lineLimit(1)

                Spacer(minLength: 0)

                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(CustomizeMessageStyle.subtitle)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(cardBackground)
        }
        .buttonStyle(.plain)
    }

    // MARK: - SMS Preview

    private var smsPreviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SMS PREVIEW")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(CustomizeMessageStyle.sectionLabel)
                .tracking(0.6)

            TextEditor(text: $messageText)
                .font(.system(size: 16))
                .foregroundStyle(CustomizeMessageStyle.title)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 160)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: CustomizeMessageStyle.cardRadius, style: .continuous)
                        .fill(CustomizeMessageStyle.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: CustomizeMessageStyle.cardRadius, style: .continuous)
                                .stroke(CustomizeMessageStyle.fieldBorder, lineWidth: 1)
                        )
                )
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 10) {
            Button(action: sendViaSMS) {
                HStack(spacing: 10) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Send via SMS")
                        .font(.system(size: 17, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule(style: .continuous)
                        .fill(CustomizeMessageStyle.primaryBlue)
                )
            }
            .buttonStyle(.plain)

            Text("Opens your default messaging app with this text")
                .font(.system(size: 13))
                .foregroundStyle(CustomizeMessageStyle.subtitle)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 24)
        .background(CustomizeMessageStyle.background)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: CustomizeMessageStyle.cardRadius, style: .continuous)
            .fill(CustomizeMessageStyle.card)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }

    private func sendViaSMS() {
        let body = messageText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        var urlString = "sms:"
        if let phone = sanitizedPhone {
            urlString += phone
        }
        urlString += "?body=\(body)"
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }

    private var sanitizedPhone: String? {
        guard let phone = selectedRecipient.phone else { return nil }
        let digits = phone.filter { $0.isWholeNumber || $0 == "+" }
        return digits.isEmpty ? nil : String(digits)
    }
}
    
#Preview {
    NavigationStack {
        CustomizeMessageScreen(
            template: MessageTemplate(
                title: "Initial Outreach",
                preview: "Salaam [Name]! I'm volunteering...",
                body: "Salaam [Name]! I'm volunteering with AMAC to help get out the vote. Are you planning to vote in the upcoming election?"
            )
        )
    }
    //.preferredColorScheme(.dark)
    
}

