import SwiftUI

// MARK: - Design Tokens

private enum FocusTodayStyle {
    static let background = AppTheme.screenBackground
    static let card = AppTheme.card
    static let title = AppTheme.title
    static let subtitle = AppTheme.subtitle
    static let primaryBlue = AppTheme.accentBlue
    static let chipBackground = AppTheme.chipBackground
    static let actionButtonBackground = AppTheme.chipBackground
    static let cardBorder = AppTheme.border

    static let cardRadius: CGFloat = 16
    static let actionButtonRadius: CGFloat = 12
}

// MARK: - Screen

struct YourFocusTodayScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = YourFocusTodayViewModel()

    var body: some View {
        ZStack {
            FocusTodayStyle.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    headerSection
                    content
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
            .refreshable {
                await viewModel.load()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(FocusTodayStyle.title)
                }
            }
        }
        .toolbarBackground(FocusTodayStyle.background, for: .navigationBar)
        .task {
            await viewModel.load()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Focus Today")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(FocusTodayStyle.title)

            if viewModel.isLoading && viewModel.focusContacts.isEmpty {
                ShimmerLine(width: 280, height: 16, cornerRadius: 4)
                ShimmerLine(width: 200, height: 18, cornerRadius: 4)
            } else {
                remainingSummary
                notYetContactedHeader
            }
        }
        .padding(.top, 8)
    }

    private var remainingSummary: some View {
        Text(attributedRemainingSummary)
            .font(.system(size: 16))
            .foregroundStyle(FocusTodayStyle.subtitle)
            .fixedSize(horizontal: false, vertical: true)
    }

    private var attributedRemainingSummary: AttributedString {
        var result = AttributedString("\(viewModel.remainingCount) remaining · Focus on these contacts to make the most impact today.")
        if let range = result.range(of: "\(viewModel.remainingCount) remaining") {
            result[range].font = .system(size: 16, weight: .bold)
            result[range].foregroundColor = FocusTodayStyle.title
        }
        return result
    }

    private var notYetContactedHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Not yet contacted · \(viewModel.remainingCount)")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(FocusTodayStyle.title)

            Text("Start with these — a quick ask is step 1.")
                .font(.system(size: 15))
                .foregroundStyle(FocusTodayStyle.subtitle)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.focusContacts.isEmpty {
            FocusTodayLoadingShimmer()
        } else if let error = viewModel.errorMessage, viewModel.focusContacts.isEmpty {
            errorState(message: error)
        } else if viewModel.focusContacts.isEmpty {
            emptyState
        } else {
            VStack(spacing: 12) {
                ForEach(viewModel.focusContacts) { contact in
                    focusContactCard(contact)
                }
            }
        }
    }

    // MARK: - Contact Card

    private func focusContactCard(_ contact: FocusContactItem) -> some View {
        HStack(alignment: .center, spacing: 14) {
            NavigationLink {
                ContactDetailScreen(contact: contact.contact.toDetailContact())
            } label: {
                HStack(alignment: .center, spacing: 14) {
                    Circle()
                        .fill(contact.avatarColor)
                        .frame(width: 48, height: 48)
                        .overlay(
                            Text(contact.initials)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(.white)
                        )

                    VStack(alignment: .leading, spacing: 8) {
                        Text(contact.name)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(FocusTodayStyle.title)
                            .lineLimit(1)

                        reachChip(contact.reachLabel)
                    }

                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                // Message action
            } label: {
                RoundedRectangle(cornerRadius: FocusTodayStyle.actionButtonRadius, style: .continuous)
                    .fill(FocusTodayStyle.actionButtonBackground)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "bubble.left")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(FocusTodayStyle.primaryBlue)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: FocusTodayStyle.cardRadius, style: .continuous)
                .fill(FocusTodayStyle.card)
                .overlay(
                    RoundedRectangle(cornerRadius: FocusTodayStyle.cardRadius, style: .continuous)
                        .stroke(FocusTodayStyle.cardBorder, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }

    private func reachChip(_ label: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: "bubble.left")
                .font(.system(size: 11, weight: .semibold))

            Text(label)
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundStyle(FocusTodayStyle.primaryBlue)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule(style: .continuous)
                .fill(FocusTodayStyle.chipBackground)
        )
    }

    // MARK: - States

    private var emptyState: some View {
        Text("You're all caught up for today.")
            .font(.system(size: 15))
            .foregroundStyle(FocusTodayStyle.subtitle)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
    }

    private func errorState(message: String) -> some View {
        VStack(spacing: 16) {
            Text(message)
                .font(.system(size: 15))
                .foregroundStyle(FocusTodayStyle.subtitle)
                .multilineTextAlignment(.center)

            Button("Try Again") {
                Task { await viewModel.load() }
            }
            .font(.system(size: 15, weight: .semibold))
            .foregroundStyle(FocusTodayStyle.primaryBlue)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

#Preview {
    NavigationStack {
        YourFocusTodayScreen()
    }
}
