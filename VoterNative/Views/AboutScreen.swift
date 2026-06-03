import SwiftUI

// MARK: - Design Tokens

private enum AboutStyle {
    static let background = AppTheme.screenBackground
    static let card = AppTheme.card
    static let title = AppTheme.title
    static let body = AppTheme.subtitle
    static let border = AppTheme.border
    static let sectionHeader = AppTheme.sectionHeader
    static let subCardBackground = AppTheme.subCardBackground
    static let howItWorksBackground = AppTheme.howItWorksBackground
    static let howItWorksBorder = AppTheme.howItWorksBorder
    static let bulletBlue = AppTheme.primaryBlue

    static let cardRadius: CGFloat = 16
    static let subCardRadius: CGFloat = 12
}

// MARK: - Screen

struct AboutScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private var appVersionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        return "Voting App v\(version)"
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                informationSection
                aboutAMACSection
                aboutThisAppSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(AboutStyle.background)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(AboutStyle.title)
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("About")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(AboutStyle.title)

            Text("Details and support.")
                .font(.system(size: 16))
                .foregroundStyle(AboutStyle.body)
        }
        .padding(.top, 8)
    }

    // MARK: - Information & Support

    private var informationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("INFORMATION & SUPPORT")

            VStack(spacing: 0) {
                HStack {
                    Text("App Version")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(AboutStyle.title)

                    Spacer()

                    Text(appVersionText)
                        .font(.system(size: 16))
                        .foregroundStyle(AboutStyle.title)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)

                Divider()
                    .padding(.leading, 16)

                Button {
                    if let url = URL(string: "mailto:support@amacwa.org") {
                        openURL(url)
                    }
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "envelope")
                            .font(.system(size: 20))
                            .foregroundStyle(AboutStyle.title)
                            .frame(width: 28)

                        Text("Contact Support")
                            .font(.system(size: 16))
                            .foregroundStyle(AboutStyle.title)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(AboutStyle.body)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                }
                .buttonStyle(.plain)
            }
            .background(cardBackground)
        }
    }

    // MARK: - About AMAC

    private var aboutAMACSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("About AMAC")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AboutStyle.title)

                Text("American Muslim Advancement Council")
                    .font(.system(size: 15))
                    .foregroundStyle(AboutStyle.body)
            }

            infoSubCard(
                title: "Who We Are",
                body: "Muslims organizing to engage in the local, state, and national political process. Currently we operate primarily out of California and Washington state."
            )

            infoSubCard(
                title: "Our Goal",
                body: "To advance Muslim participation, inclusion, and consideration in politics and policy making."
            )
        }
        .padding(20)
        .background(cardBackground)
    }

    // MARK: - About This App

    private var aboutThisAppSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About This App")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AboutStyle.title)

            Text("The Voting App amplifies your democratic voice by helping you mobilize your friends and family to vote.")
                .font(.system(size: 15))
                .foregroundStyle(AboutStyle.body)
                .fixedSize(horizontal: false, vertical: true)

            howItWorksBox
        }
        .padding(20)
        .background(cardBackground)
    }

    private var howItWorksBox: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("How It Works")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(AboutStyle.title)

            VStack(alignment: .leading, spacing: 12) {
                howItWorksBullet("Import your contacts and see their voter registration status")
                howItWorksBullet("Identify which contacts are less likely to vote using propensity scores")
                howItWorksBullet("Use pre-written message templates to encourage voting")
                howItWorksBullet("Follow a proven 4-step plan to guide each contact to the polls")
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AboutStyle.subCardRadius, style: .continuous)
                .fill(AboutStyle.howItWorksBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: AboutStyle.subCardRadius, style: .continuous)
                        .stroke(AboutStyle.howItWorksBorder, lineWidth: 1)
                )
        )
    }

    private func howItWorksBullet(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(AboutStyle.bulletBlue)
                .frame(width: 6, height: 6)
                .padding(.top, 7)

            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(AboutStyle.body)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(AboutStyle.sectionHeader)
            .tracking(0.6)
    }

    private func infoSubCard(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(AboutStyle.title)

            Text(body)
                .font(.system(size: 15))
                .foregroundStyle(AboutStyle.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AboutStyle.subCardRadius, style: .continuous)
                .fill(AboutStyle.subCardBackground)
        )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: AboutStyle.cardRadius, style: .continuous)
            .fill(AboutStyle.card)
            .overlay(
                RoundedRectangle(cornerRadius: AboutStyle.cardRadius, style: .continuous)
                    .stroke(AboutStyle.border, lineWidth: 1)
            )
    }
}

#Preview {
    NavigationStack {
        AboutScreen()
    }
}
