import SwiftUI

// MARK: - Design Tokens

private enum SetGoalStyle {
    static let title = AppTheme.title
    static let subtitle = AppTheme.subtitle
    static let primaryBlue = AppTheme.brandBlue
    static let divider = AppTheme.divider
    static let chipIdle = AppTheme.chipBackground
    static let fieldBackground = AppTheme.fieldBackground
    static let fieldBorder = AppTheme.border

    static let modalRadius: CGFloat = 26
}

// MARK: - Overlay

struct SetPersonalGoalOverlay: View {
    @Binding var isPresented: Bool
    @Binding var goalValue: Int

    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            SetPersonalGoalDialog(
                isPresented: $isPresented,
                goalValue: $goalValue
            )
            .padding(.horizontal, 40)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.94)))
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            isPresented = false
        }
    }
}

// MARK: - Dialog

struct SetPersonalGoalDialog: View {
    @Binding var isPresented: Bool
    @Binding var goalValue: Int

    @State private var draftValue: Int = 50
    @FocusState private var isFieldFocused: Bool

    private let quickOptions = [10, 25, 50, 100]

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            contentSection
            footerDivider
            footerSection
        }
        .background(
            RoundedRectangle(cornerRadius: SetGoalStyle.modalRadius, style: .continuous)
                .fill(AppTheme.card)
        )
        .clipShape(RoundedRectangle(cornerRadius: SetGoalStyle.modalRadius, style: .continuous))
        .shadow(color: Color.black.opacity(0.14), radius: 24, x: 0, y: 12)
        .onAppear {
            draftValue = goalValue > 0 ? goalValue : 50
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 6) {
            Text("Set Your Goal")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(SetGoalStyle.title)

            Text("Voters to confirm")
                .font(.system(size: 15))
                .foregroundStyle(SetGoalStyle.subtitle)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.top, 22)
        .padding(.bottom, 18)
        .padding(.horizontal, 20)
    }

    // MARK: - Content

    private var contentSection: some View {
        VStack(spacing: 18) {
            HStack(spacing: 10) {
                ForEach(quickOptions, id: \.self) { option in
                    quickPickChip(option)
                }
            }

            goalValueField
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }

    private func quickPickChip(_ value: Int) -> some View {
        let isSelected = draftValue == value

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                draftValue = value
            }
        } label: {
            Text("\(value)")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(isSelected ? AppTheme.onPrimary : SetGoalStyle.primaryBlue)
                .frame(minWidth: 52, minHeight: 44)
                .background(
                    Capsule(style: .continuous)
                        .fill(isSelected ? SetGoalStyle.primaryBlue : SetGoalStyle.chipIdle)
                )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private var goalValueField: some View {
        TextField("", text: goalTextBinding)
            .font(.system(size: 44, weight: .bold))
            .foregroundStyle(SetGoalStyle.title)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .focused($isFieldFocused)
            .padding(.vertical, 18)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(SetGoalStyle.fieldBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(SetGoalStyle.fieldBorder, lineWidth: 1)
                    )
            )
    }

    private var goalTextBinding: Binding<String> {
        Binding(
            get: { draftValue > 0 ? String(draftValue) : "" },
            set: { newValue in
                let filtered = newValue.filter(\.isNumber)
                if let intValue = Int(filtered), intValue > 0 {
                    draftValue = min(intValue, 9999)
                } else if filtered.isEmpty {
                    draftValue = 0
                }
            }
        )
    }

    // MARK: - Footer

    private var footerDivider: some View {
        Rectangle()
            .fill(SetGoalStyle.divider)
            .frame(height: 1)
    }

    private var footerSection: some View {
        HStack(spacing: 0) {
            Button { dismiss() } label: {
                Text("Cancel")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(SetGoalStyle.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            Rectangle()
                .fill(SetGoalStyle.divider)
                .frame(width: 1)
                .frame(maxHeight: .infinity)

            Button { save() } label: {
                Text("Save")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(SetGoalStyle.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.plain)
            .disabled(draftValue <= 0)
            .opacity(draftValue > 0 ? 1 : 0.4)
        }
        .frame(height: 48)
    }

    // MARK: - Actions

    private func save() {
        guard draftValue > 0 else { return }
        goalValue = draftValue
        dismiss()
    }

    private func dismiss() {
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            isPresented = false
        }
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        SetPersonalGoalOverlay(isPresented: .constant(true), goalValue: .constant(50))
    }
}
