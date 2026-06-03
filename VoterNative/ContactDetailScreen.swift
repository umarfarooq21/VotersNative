import SwiftUI

struct ContactDetailScreen: View {
    let contact: Contact
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header Section
                VStack(spacing: 20) {
                    // Name
                    Text(contact.name)
                        .font(.system(size: 40, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Parent Tag
                    HStack(spacing: 4) {
                        Text("Parent")
                            .font(.headline)
                            .foregroundStyle(.blue)
                        
                        ForEach(0..<4, id: \.self) { _ in
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 4, height: 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.12))
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Contact Info
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(.gray)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(contact.address)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                Text(contact.city)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "phone.fill")
                                .foregroundStyle(.gray)
                                .font(.title3)
                            Text(contact.phone)
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(.gray)
                                .font(.title3)
                            Text(contact.email)
                                .font(.body)
                                .foregroundStyle(.primary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Message Button
                    Button {
                        // Message action
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "message.fill")
                                .font(.title3)
                            Text("Message \(contact.firstName)")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.blue)
                        )
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
                
                // Divider
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 8)
                
                // Current Elections Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("CURRENT ELECTIONS")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Election Card
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("April 2026 Special Election")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("ACTIVE")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.blue)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.opacity(0.12))
                                )
                        }
                        
                        // Steps
                        VStack(spacing: 0) {
                            StepRow(
                                step: "1/6",
                                letter: "F",
                                letterColor: .blue,
                                title: "Find",
                                description: "Find your friend in the AMAC Circle app and add them to your contacts",
                                status: .completed,
                                icon: "person.2.fill",
                                showLine: true
                            )
                            
                            StepRow(
                                step: "2/6",
                                letter: "R",
                                letterColor: .blue,
                                title: "Reach",
                                description: "Have you asked Zainab to commit to voting?",
                                status: .completed,
                                icon: "message.fill",
                                showLine: true,
                                showReset: true
                            )
                            
                            StepRow(
                                step: "3/6",
                                letter: "I",
                                letterColor: .blue,
                                title: "Include",
                                description: "What did Zainab decide about voting?",
                                status: .pending,
                                icon: "target",
                                showLine: true
                            )
                        }
                    }
                    .padding(20)
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    .padding(.horizontal, 20)
                }
                .padding(.bottom, 20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        // Phone action
                    } label: {
                        Image(systemName: "phone.fill")
                            .font(.title3)
                            .foregroundStyle(.primary)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color(.systemGray6))
                            )
                    }
                    
                    Button {
                        // More action
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                            .foregroundStyle(.primary)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(Color(.systemGray6))
                            )
                    }
                }
            }
        }
        // Vote likelihood indicator
        .overlay(alignment: .topTrailing) {
            VStack(alignment: .trailing, spacing: 4) {
                Text("Vote likelihood")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 4) {
                    VoteLikelihoodArc(percentage: contact.voteLikelihood)
                        .frame(width: 32, height: 32)
                    Text("\(contact.voteLikelihood)%")
                        .font(.headline)
                        .foregroundStyle(.primary)
                }
            }
            .padding(.trailing, 20)
            .padding(.top, 100)
        }
    }
}

// MARK: - Step Row
struct StepRow: View {
    let step: String
    let letter: String
    let letterColor: Color
    let title: String
    let description: String
    let status: StepStatus
    let icon: String
    var showLine: Bool = false
    var showReset: Bool = false
    
    enum StepStatus {
        case completed, pending
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            // Left side - circle and line
            VStack(spacing: 0) {
                Circle()
                    .fill(letterColor)
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text(letter)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    )
                
                if showLine {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(width: 2)
                        .frame(minHeight: 80)
                }
            }
            .frame(width: 48)
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(step)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                    
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Image(systemName: icon)
                        .foregroundStyle(.secondary)
                        .font(.title3)
                }
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 8) {
                    if status == .completed {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("Completed")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    if showReset {
                        Text("Reset")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(.blue)
                .padding(.top, 4)
            }
            .padding(.leading, 16)
            .padding(.top, 4)
        }
    }
}

// MARK: - Vote Likelihood Arc
struct VoteLikelihoodArc: View {
    let percentage: Int
    
    var color: Color {
        if percentage < 33 {
            return .red
        } else if percentage < 66 {
            return .orange
        } else {
            return .green
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: CGFloat(percentage) / 100)
                .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}

// MARK: - Contact Model
struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let firstName: String
    let address: String
    let city: String
    let phone: String
    let email: String
    let voteLikelihood: Int
    let initials: String
    let color: Color
    
    static let sample = Contact(
        name: "Zainab Ahmed",
        firstName: "Zainab",
        address: "5201 Rainier Ave S",
        city: "Redmond, WA 98052",
        phone: "(425) 555-0199",
        email: "zainab.ahmed@email.com",
        voteLikelihood: 22,
        initials: "ZA",
        color: .blue
    )
}

#Preview {
    NavigationStack {
        ContactDetailScreen(contact: .sample)
    }
}
