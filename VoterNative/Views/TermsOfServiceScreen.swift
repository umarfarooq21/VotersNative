import SwiftUI

// MARK: - Design Tokens

private enum TermsStyle {
    static let background = AppTheme.screenBackground
    static let card = AppTheme.card
    static let title = AppTheme.title
    static let body = AppTheme.subtitle
    static let border = AppTheme.border
    static let icon = AppTheme.sectionHeader
    static let checkmark = AppTheme.primaryBlue
    static let checkboxBorder = AppTheme.border

    static let cardRadius: CGFloat = 16
}

private struct TermsDocument: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}

// MARK: - Screen

struct TermsOfServiceScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var hasAgreed = false

    private let documents: [TermsDocument] = [
        TermsDocument(title: "Terms & Conditions", icon: "doc.text"),
        TermsDocument(title: "Privacy Policy", icon: "lock"),
        TermsDocument(title: "Acceptable Use Rules", icon: "hammer"),
        TermsDocument(title: "Code of Conduct", icon: "checkmark.shield"),
        TermsDocument(title: "Data Processing Agreement", icon: "icloud.and.arrow.up")
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                documentsCard
                agreementSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(TermsStyle.background)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(TermsStyle.title)
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Terms of Service")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(TermsStyle.title)

            Text("Policies, privacy, and compliance documents.")
                .font(.system(size: 16))
                .foregroundStyle(TermsStyle.body)
        }
        .padding(.top, 8)
    }

    // MARK: - Documents

    private var documentsCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(documents.enumerated()), id: \.element.id) { index, document in
                documentRow(document)

                if index < documents.count - 1 {
                    Divider()
                        .padding(.leading, 58)
                }
            }
        }
        .background(cardBackground)
    }

    private func documentRow(_ document: TermsDocument) -> some View {
        Button {
            // Open document detail
        } label: {
            HStack(spacing: 14) {
                Image(systemName: document.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(TermsStyle.icon)
                    .frame(width: 28, alignment: .center)

                Text(document.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(TermsStyle.title)

                Spacer(minLength: 8)

                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(TermsStyle.checkmark)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Agreement

    private var agreementSection: some View {
        Button {
            hasAgreed.toggle()
        } label: {
            HStack(alignment: .top, spacing: 12) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(TermsStyle.checkboxBorder, lineWidth: 1.5)
                    .background(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(hasAgreed ? TermsStyle.checkmark : AppTheme.card)
                    )
                    .frame(width: 22, height: 22)
                    .overlay {
                        if hasAgreed {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }

                Text("I agree to AMAC Terms of Service policies.")
                    .font(.system(size: 15))
                    .foregroundStyle(TermsStyle.body)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.plain)
        .padding(.top, 4)
    }

    // MARK: - Helpers

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: TermsStyle.cardRadius, style: .continuous)
            .fill(TermsStyle.card)
            .overlay(
                RoundedRectangle(cornerRadius: TermsStyle.cardRadius, style: .continuous)
                    .stroke(TermsStyle.border, lineWidth: 1)
            )
    }
}

#Preview {
    NavigationStack {
        TermsOfServiceScreen()
    }
}
