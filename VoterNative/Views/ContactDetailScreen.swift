import SwiftUI

// MARK: - Model

struct DetailContact {
    let name: String
    let firstName: String
    let address: String
    let city: String
    let phone: String
    let email: String
    let voteLikelihood: Int
    let initials: String
    let color: Color
    let relationship: String

    var uppercaseName: String { name.uppercased() }

    var fullAddressLine: String {
        let parts = [address, city].filter { !$0.isEmpty && $0 != "—" }
        return parts.isEmpty ? "—" : parts.joined(separator: ", ")
    }
}

// MARK: - Design Tokens

private enum ContactDetailStyle {
    static let background = AppTheme.screenBackground
    static let card = AppTheme.card
    static let title = AppTheme.title
    static let subtitle = AppTheme.subtitle
    static let sectionHeader = AppTheme.sectionHeader
    static let primaryBlue = AppTheme.primaryBlue
    static let activeBadgeBg = AppTheme.activeBadgeBackground
    static let upcomingBadgeBg = AppTheme.activeBadgeBackground
    static let divider = AppTheme.divider
    static let timelineLine = AppTheme.divider
    static let notesFieldBg = AppTheme.notesFieldBackground

    static let cardRadius: CGFloat = 16
}

// MARK: - Relationship Options

enum ContactRelationshipOption: String, CaseIterable, Identifiable {
    case closeFriend = "Close friend"
    case spouse = "Spouse"
    case sibling = "Sibling"
    case cousin = "Cousine"
    case friendOfFriend = "Friend-of-friend"

    var id: String { rawValue }
}

// MARK: - Screen

struct ContactDetailScreen: View {
    let contact: DetailContact
    @Environment(\.dismiss) private var dismiss
    @State private var expandedElectionId = "aug-2026"
    @State private var voteSliderValue: Double = 0.22
    @State private var notesText = ""
    @State private var selectedRelationship: String
    @State private var showDeleteConfirmation = false

    init(contact: DetailContact) {
        self.contact = contact
        _selectedRelationship = State(initialValue: contact.relationship)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                profileCard
                currentElectionsSection
                votingHistorySection
                pastElectionsSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(ContactDetailStyle.background)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(ContactDetailStyle.title)
                }
            }

            ToolbarItem(placement: .principal) {
                Text(contact.uppercaseName)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(ContactDetailStyle.title)
            }

            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 10) {
                    Button {} label: {
                        Image(systemName: "bubble.left.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(ContactDetailStyle.primaryBlue))
                    }

                    Button {} label: {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(ContactDetailStyle.subtitle)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .stroke(ContactDetailStyle.divider, lineWidth: 1)
                                    .background(Circle().fill(ContactDetailStyle.card))
                            )
                    }

                    moreOptionsMenu
                }
            }
        }
        .toolbarBackground(ContactDetailStyle.background, for: .navigationBar)
        .alert("Delete contact?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("This will remove \(contact.name) from your contacts.")
        }
    }

    // MARK: - Profile Card

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 14) {
                    Text(contact.uppercaseName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(ContactDetailStyle.title)

                    contactInfoRow(icon: "mappin.and.ellipse", text: contact.fullAddressLine)
                    contactInfoRow(icon: "phone.fill", text: contact.phone)
                }

                Spacer(minLength: 8)

                VoteLikelihoodGaugeView(percentage: contact.voteLikelihood)
            }

            HStack {
                Spacer()
                relationshipPill
            }

            Button {} label: {
                HStack(spacing: 8) {
                    Image(systemName: "bubble.left.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Message \(contact.uppercaseName)")
                        .font(.system(size: 15, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(ContactDetailStyle.primaryBlue)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(cardBackground)
    }

    private func contactInfoRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(ContactDetailStyle.subtitle)
                .frame(width: 18)

            Text(text)
                .font(.system(size: 14))
                .foregroundStyle(ContactDetailStyle.subtitle)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder
    private var relationshipMenuOptions: some View {
        ForEach(ContactRelationshipOption.allCases) { option in
            Button {
                selectedRelationship = option.rawValue
            } label: {
                HStack {
                    Text(option.rawValue)
                    if selectedRelationship == option.rawValue {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }

    private var relationshipPill: some View {
        Menu {
            relationshipMenuOptions
        } label: {
            HStack(spacing: 6) {
                Text(selectedRelationship)
                    .font(.system(size: 14, weight: .semibold))
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundStyle(ContactDetailStyle.primaryBlue)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .stroke(ContactDetailStyle.primaryBlue, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private var moreOptionsMenu: some View {
        Menu {
            Menu {
                relationshipMenuOptions
            } label: {
                Label("Edit relationship", systemImage: "pencil")
            }

            Button {} label: {
                Label("Manage Connections", systemImage: "person.2")
            }

            Button {} label: {
                Label("View household", systemImage: "house")
            }

            Button {} label: {
                Label("Change voter match", systemImage: "person.text.rectangle")
            }

            Button {} label: {
                Label("Unlink match", systemImage: "link")
            }

            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete contact", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(ContactDetailStyle.subtitle)
                .frame(width: 40, height: 40)
                .background(
                    Circle()
                        .stroke(ContactDetailStyle.divider, lineWidth: 1)
                        .background(Circle().fill(ContactDetailStyle.card))
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Current Elections

    private var currentElectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("CURRENT ELECTIONS")

            electionCard(
                id: "aug-2026",
                title: "Aug 2026 Primary",
                badge: "ACTIVE",
                isActiveBadge: true,
                isExpanded: expandedElectionId == "aug-2026",
                content: { aug2026ExpandedContent }
            )

            electionCard(
                id: "nov-2026",
                title: "Nov 2026 General",
                badge: "UPCOMING",
                isActiveBadge: false,
                isExpanded: expandedElectionId == "nov-2026",
                content: { EmptyView() }
            )
        }
    }

    @ViewBuilder
    private var aug2026ExpandedContent: some View {
        VStack(spacing: 0) {
            timelineStep(
                number: "1",
                letter: "F",
                title: "Find",
                description: "Find your friend in the AMAC Circle app and add them to your contacts",
                isCompleted: true,
                trailingIcon: "person.2.fill",
                showLine: true
            )

            timelineStep(
                number: "2",
                letter: "R",
                title: "Reach",
                description: "Have you asked \(contact.firstName) to commit to voting?",
                isCompleted: false,
                trailingIcon: "bubble.left",
                showLine: true
            )

            timelineStep(
                number: "3",
                letter: "I",
                title: "Include",
                description: "What did \(contact.firstName) decide about voting?",
                isCompleted: false,
                trailingIcon: "circle",
                showLine: true,
                showVoteSlider: true
            )

            timelineStep(
                number: "4",
                letter: "E",
                title: "Encourage",
                description: "Did you encourage \(contact.firstName) to vote early?",
                isCompleted: false,
                trailingIcon: "bell",
                showLine: true,
                showMarkDone: true
            )

            timelineStep(
                number: "5",
                letter: "N",
                title: "Nudge",
                description: "Did you check in again right before Election Day?",
                isCompleted: false,
                trailingIcon: "clock",
                showLine: true,
                showMarkDone: true
            )

            timelineStep(
                number: "6",
                letter: "D",
                title: "Done",
                description: "Did you thank \(contact.firstName) for voting?",
                isCompleted: false,
                trailingIcon: "checkmark.circle",
                showLine: false,
                showMarkDone: true
            )
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)

        notesSection
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
    }

    private func electionCard<Content: View>(
        id: String,
        title: String,
        badge: String,
        isActiveBadge: Bool,
        isExpanded: Bool,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.easeInOut(duration: 0.22)) {
                    expandedElectionId = isExpanded ? "" : id
                }
            } label: {
                HStack {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(ContactDetailStyle.title)

                    statusBadge(badge, isActive: isActiveBadge)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ContactDetailStyle.subtitle)
                }
                .padding(16)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                content()
            }
        }
        .background(cardBackground)
    }

    private func statusBadge(_ text: String, isActive: Bool) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundStyle(ContactDetailStyle.primaryBlue)
            .tracking(0.3)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule(style: .continuous)
                    .fill(isActive ? ContactDetailStyle.activeBadgeBg : ContactDetailStyle.upcomingBadgeBg)
            )
    }

    private func timelineStep(
        number: String,
        letter: String,
        title: String,
        description: String,
        isCompleted: Bool,
        trailingIcon: String,
        showLine: Bool,
        showVoteSlider: Bool = false,
        showMarkDone: Bool = false
    ) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(spacing: 0) {
                Circle()
                    .fill(ContactDetailStyle.primaryBlue)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(letter)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    )

                if showLine {
                    Rectangle()
                        .fill(ContactDetailStyle.timelineLine)
                        .frame(width: 2)
                        .frame(minHeight: showVoteSlider ? 150 : (showMarkDone ? 110 : 90))
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 6) {
                            Text(number)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(ContactDetailStyle.title)
                            Text(title)
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(ContactDetailStyle.title)
                        }

                        Text(description)
                            .font(.system(size: 14))
                            .foregroundStyle(ContactDetailStyle.subtitle)
                            .fixedSize(horizontal: false, vertical: true)

                        if isCompleted {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                Text("Completed")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(ContactDetailStyle.primaryBlue)
                        }

                        if showVoteSlider {
                            voteLikelihoodSliderBlock
                        }

                        if showMarkDone {
                            Button {} label: {
                                Text("Mark as Done")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(ContactDetailStyle.primaryBlue)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(ContactDetailStyle.primaryBlue, lineWidth: 1.5)
                                            .background(
                                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                    .fill(AppTheme.card)
                                            )
                                    )
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 4)
                        }
                    }

                    Spacer(minLength: 4)

                    Image(systemName: trailingIcon)
                        .font(.system(size: 18))
                        .foregroundStyle(
                            trailingIcon == "circle"
                                ? ContactDetailStyle.primaryBlue
                                : ContactDetailStyle.subtitle.opacity(0.7)
                        )
                }
            }
            .padding(.bottom, showLine ? 16 : 0)
        }
    }

    private var voteLikelihoodSliderBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Voting likelihood")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(ContactDetailStyle.subtitle)

            HStack {
                Text("Won't vote")
                Spacer()
                Text("Unsure")
                Spacer()
                Text("Will vote")
            }
            .font(.system(size: 12))
            .foregroundStyle(ContactDetailStyle.subtitle)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    LinearGradient(
                        colors: [
                            AppTheme.danger,
                            AppTheme.warning,
                            AppTheme.success
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 8)
                    .clipShape(Capsule())

                    Circle()
                        .fill(AppTheme.card)
                        .frame(width: 22, height: 22)
                        .shadow(color: Color.black.opacity(0.12), radius: 3, x: 0, y: 1)
                        .offset(x: max(0, geometry.size.width * voteSliderValue - 11))
                }
            }
            .frame(height: 22)
        }
        .padding(.top, 8)
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("NOTES")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ContactDetailStyle.sectionHeader)
                .tracking(0.5)

            TextField(
                "",
                text: $notesText,
                prompt: Text("Add a note about \(contact.uppercaseName)...")
                    .foregroundStyle(ContactDetailStyle.subtitle.opacity(0.8)),
                axis: .vertical
            )
            .font(.system(size: 15))
            .lineLimit(3...6)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(ContactDetailStyle.notesFieldBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(ContactDetailStyle.divider, lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Voting History

    private var votingHistorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("VOTING HISTORY")
            VotingHistoryCard()
        }
    }

    // MARK: - Past Elections

    private var pastElectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("PAST ELECTIONS")

            Button {} label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Aug 2025 Primary")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(ContactDetailStyle.title)

                        Text("No contact date on file")
                            .font(.system(size: 14))
                            .foregroundStyle(ContactDetailStyle.subtitle)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(ContactDetailStyle.subtitle)
                }
                .padding(16)
                .background(cardBackground)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Helpers

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(ContactDetailStyle.sectionHeader)
            .tracking(0.6)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: ContactDetailStyle.cardRadius, style: .continuous)
            .fill(ContactDetailStyle.card)
            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }

}

// MARK: - Vote Likelihood Gauge (semi-circle)

private struct VoteLikelihoodGaugeView: View {
    let percentage: Int

    private let lineWidth: CGFloat = 5
    private let gaugeWidth: CGFloat = 76
    private let arcHeight: CGFloat = 28

    private var arcColor: Color {
        if percentage < 40 { return AppTheme.danger }
        if percentage < 70 { return AppTheme.warning }
        return AppTheme.success
    }

    var body: some View {
        VStack(spacing: 4) {
            Text("Vote likelihood")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(ContactDetailStyle.subtitle)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            VStack(spacing: 4) {
                arcLayer
                    .frame(width: gaugeWidth, height: arcHeight)

                Text("\(percentage)%")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(arcColor)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(width: gaugeWidth, alignment: .trailing)
    }

    private var arcLayer: some View {
        Canvas { context, size in
            let capInset = lineWidth / 2
            let center = CGPoint(x: size.width / 2, y: size.height - capInset)
            let radius = min(
                size.width / 2 - lineWidth - 1,
                center.y - lineWidth
            )
            let trackStyle = StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            let progressEnd = 180 - (180 * Double(percentage) / 100)

            var track = Path()
            track.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(180),
                endAngle: .degrees(0),
                clockwise: false
            )
            context.stroke(track, with: .color(ContactDetailStyle.divider), style: trackStyle)

            var progress = Path()
            progress.addArc(
                center: center,
                radius: radius,
                startAngle: .degrees(180),
                endAngle: .degrees(progressEnd),
                clockwise: false
            )
            context.stroke(progress, with: .color(arcColor), style: trackStyle)
        }
    }
}

// MARK: - Voting History Card

private struct VotingHistoryCard: View {
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("Year")
                    .frame(maxWidth: .infinity, alignment: .leading)
                headerColumn("(Aug)", subtitle: "Primary")
                headerColumn("(Nov)", subtitle: "General")
                Text("Special")
                    .frame(width: 56, alignment: .center)
            }
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(ContactDetailStyle.subtitle)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            Divider()

            historyRow(year: "2026", primary: .unknown, general: .unknown, special: .dash)
            Divider().padding(.leading, 14)
            historyRow(year: "2025", primary: .no, general: .no, special: .dash)
            Divider().padding(.leading, 14)
            historyRow(year: "2024", primary: .no, general: .yes, special: .dash)
        }
        .background(
            RoundedRectangle(cornerRadius: ContactDetailStyle.cardRadius, style: .continuous)
                .fill(ContactDetailStyle.card)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
        )
    }

    private func headerColumn(_ top: String, subtitle: String) -> some View {
        VStack(spacing: 2) {
            Text(top)
                .font(.system(size: 10))
            Text(subtitle)
        }
        .frame(width: 64)
    }

    private enum VoteIcon { case yes, no, unknown, dash }

    private func historyRow(year: String, primary: VoteIcon, general: VoteIcon, special: VoteIcon) -> some View {
        HStack {
            Text(year)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(ContactDetailStyle.title)
                .frame(maxWidth: .infinity, alignment: .leading)

            iconView(primary).frame(width: 64)
            iconView(general).frame(width: 64)
            iconView(special).frame(width: 56)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
    }

    @ViewBuilder
    private func iconView(_ status: VoteIcon) -> some View {
        switch status {
        case .yes:
            statusCircle(symbol: "checkmark", color: AppTheme.success)
        case .no:
            statusCircle(symbol: "xmark", color: AppTheme.danger)
        case .unknown:
            statusCircle(symbol: "questionmark", color: Color.secondary)
        case .dash:
            Text("—")
                .font(.system(size: 15))
                .foregroundStyle(ContactDetailStyle.subtitle)
        }
    }

    private func statusCircle(symbol: String, color: Color) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 12, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 30, height: 30)
            .background(Circle().fill(color))
    }
}

#Preview {
    NavigationStack {
        ContactDetailScreen(contact: DetailContact(
            name: "Wajeeha Zia",
            firstName: "Wajeeha",
            address: "2812 HEATH AVE W",
            city: "Spokane, WA 99208",
            phone: "+13323067706",
            email: "wajeeha@email.com",
            voteLikelihood: 35,
            initials: "WZ",
            color: .blue,
            relationship: "Roommate"
        ))
    }
}
