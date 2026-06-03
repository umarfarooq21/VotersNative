import SwiftUI

enum AddContactFlowStyle {
    static let background = AppTheme.sheetBackground
    static let title = AppTheme.title
    static let subtitle = AppTheme.subtitle
    static let primaryBlue = AppTheme.primaryBlue
    static let progressInactive = AppTheme.progressTrack
    static let iconCircle = AppTheme.iconCircle
    static let footer = AppTheme.footer
    static let screenBackground = AppTheme.screenBackground
    static let card = AppTheme.card
    static let cardBorder = AppTheme.border
    static let badgeBackground = AppTheme.badgeBackground
    static let badgeText = AppTheme.sectionHeader

    static let totalSteps = 3
}

struct AddContactProgressHeader: View {
    let currentStep: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(1...AddContactFlowStyle.totalSteps, id: \.self) { step in
                stepItem(step: step)
            }
        }
        .padding(.top, 4)
    }

    private func stepItem(step: Int) -> some View {
        let isComplete = step <= currentStep

        return HStack(spacing: 6) {
            Text("\(step)/\(AddContactFlowStyle.totalSteps)")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isComplete ? AddContactFlowStyle.primaryBlue : AddContactFlowStyle.subtitle)

            Capsule(style: .continuous)
                .fill(isComplete ? AddContactFlowStyle.primaryBlue : AddContactFlowStyle.progressInactive)
                .frame(height: step == currentStep ? 4 : 2)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AddContactNavigationBar: ViewModifier {
    @Environment(\.dismiss) private var dismiss

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(AddContactFlowStyle.title)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Add Contact")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(AddContactFlowStyle.title)
                }
            }
            .toolbarBackground(AddContactFlowStyle.background, for: .navigationBar)
    }
}

extension View {
    func addContactNavigationBar() -> some View {
        modifier(AddContactNavigationBar())
    }
}
