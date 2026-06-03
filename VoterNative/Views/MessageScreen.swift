import SwiftUI

struct MessageTemplate: Identifiable, Hashable {
    let title: String
    let preview: String
    let body: String

    var id: String { title }

    func resolvedBody(firstName: String) -> String {
        body.replacingOccurrences(of: "[Name]", with: firstName)
    }
}

struct MessageScreen: View {
    private let templates: [MessageTemplate] = [
        MessageTemplate(
            title: "Initial Outreach",
            preview: "Salaam [Name]! I'm volunteering with AMAC to help get out the vote. Are you...",
            body: "Salaam [Name]! I'm volunteering with AMAC to help get out the vote. Are you planning to vote in the upcoming election?"
        ),
        MessageTemplate(
            title: "Registration Check",
            preview: "Hi [Name], checking in to see if you've had a chance to update your voter regi...",
            body: "Hi [Name], checking in to see if you've had a chance to update your voter registration. Let me know if you need any help!"
        ),
        MessageTemplate(
            title: "Election Day Reminder",
            preview: "Don't forget to vote tomorrow! Polls are open from 7am to 8pm. Do you need a...",
            body: "Don't forget to vote tomorrow! Polls are open from 7am to 8pm. Do you need a ride to the polls?"
        ),
    ]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("MESSAGE TEMPLATES")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.sectionHeader)
                        .tracking(0.6)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    VStack(spacing: 12) {
                        ForEach(templates) { template in
                            NavigationLink(value: template) {
                                MessageTemplateCard(template: template)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
            .background(AppTheme.screenBackground)
            .navigationTitle("Select Message")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: MessageTemplate.self) { template in
                CustomizeMessageScreen(template: template)
            }
        }
    }
}

struct MessageTemplateCard: View {
    let template: MessageTemplate

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: "message.fill")
                .font(.system(size: 22))
                .foregroundStyle(AppTheme.primaryBlue)
                .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 6) {
                Text(template.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)

                Text(template.preview)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
}

#Preview {
    MessageScreen()
}
