import Foundation
import SwiftUI

struct FocusContactItem: Identifiable, Hashable {
    let id: String
    let name: String
    let initials: String
    let avatarColor: Color
    let reachLabel: String
    let contact: ContactItem

    init(from contact: Contact, colorIndex: Int) {
        let item = ContactItem(from: contact, colorIndex: colorIndex)
        id = item.id
        name = item.name
        initials = item.initials
        avatarColor = FocusContactItem.avatarColors[colorIndex % FocusContactItem.avatarColors.count]
        reachLabel = FocusContactItem.reachLabel(
            messageStatus: contact.messageStatus,
            outreachStatus: contact.outreachStatus
        )
        self.contact = item
    }

    static let avatarColors: [Color] = [
        Color(red: 0.231, green: 0.510, blue: 0.965),
        Color(red: 0.918, green: 0.345, blue: 0.047),
        Color(red: 0.961, green: 0.620, blue: 0.043),
        Color(red: 0.063, green: 0.725, blue: 0.506)
    ]

    static func reachLabel(messageStatus: String?, outreachStatus: String?) -> String {
        let message = messageStatus?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        let outreach = outreachStatus?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""

        if message.contains("sent") {
            return "Sent Reach"
        }
        if message.contains("/") {
            return messageStatus?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "2/4 Reach"
        }
        if outreach == "1" || outreach.contains("reach") {
            return "2/4 Reach"
        }
        return "2/4 Reach"
    }

    static func isNotYetContacted(_ contact: Contact) -> Bool {
        let outreach = contact.outreachStatus?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let message = contact.messageStatus?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if outreach.isEmpty && message.isEmpty {
            return true
        }

        let combined = "\(outreach) \(message)".lowercased()
        if combined.contains("complete") || combined.contains("done") || combined.contains("voted") {
            return false
        }

        return true
    }
}
