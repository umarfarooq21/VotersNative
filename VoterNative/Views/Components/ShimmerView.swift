import SwiftUI

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { geometry in
                    let width = geometry.size.width
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.55),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: width * 0.45)
                    .offset(x: phase * width * 1.4)
                }
                .mask(content)
            }
            .onAppear {
                withAnimation(.linear(duration: 1.15).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

// MARK: - Shimmer Placeholders

struct ShimmerCircle: View {
    var size: CGFloat = 44

    var body: some View {
        Circle()
            .fill(AppTheme.shimmerBase)
            .frame(width: size, height: size)
            .shimmer()
    }
}

struct ShimmerLine: View {
    var width: CGFloat? = nil
    var height: CGFloat = 14
    var cornerRadius: CGFloat = 6

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(AppTheme.shimmerBase)
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: .leading)
            .shimmer()
    }
}

struct ContactCardShimmer: View {
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ShimmerCircle(size: 48)

            VStack(alignment: .leading, spacing: 10) {
                ShimmerLine(width: 160, height: 16)
                ShimmerLine(width: 120, height: 28, cornerRadius: 14)
            }

            Spacer(minLength: 0)

            ShimmerLine(width: 10, height: 16, cornerRadius: 4)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.card)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
    }
}

struct ContactsLoadingShimmer: View {
    var rowCount: Int = 6

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<rowCount, id: \.self) { _ in
                ContactCardShimmer()
            }
        }
    }
}

// MARK: - Confirm Match (Add Contact step 2)

struct ConfirmMatchCardShimmer: View {
    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            ShimmerCircle(size: 24)

            VStack(alignment: .leading, spacing: 8) {
                ShimmerLine(width: 150, height: 16, cornerRadius: 6)
                ShimmerLine(width: 110, height: 14, cornerRadius: 6)
            }

            Spacer(minLength: 8)

            ShimmerLine(width: 72, height: 24, cornerRadius: 12)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(AppTheme.card)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppTheme.border, lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
}

struct ConfirmMatchLoadingShimmer: View {
    var rowCount: Int = 5

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<rowCount, id: \.self) { _ in
                ConfirmMatchCardShimmer()
            }
        }
    }
}

struct FocusTodayLoadingShimmer: View {
    var rowCount: Int = 7

    var body: some View {
        VStack(spacing: 12) {
            ForEach(0..<rowCount, id: \.self) { _ in
                HStack(alignment: .center, spacing: 14) {
                    ShimmerCircle(size: 48)

                    VStack(alignment: .leading, spacing: 10) {
                        ShimmerLine(width: 160, height: 16)
                        ShimmerLine(width: 90, height: 26, cornerRadius: 13)
                    }

                    Spacer(minLength: 0)

                    ShimmerLine(width: 44, height: 44, cornerRadius: 12)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.card)
                )
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            }
        }
    }
}

struct CaptainDetailLoadingShimmer: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                ShimmerLine(height: 140, cornerRadius: 16)

                ShimmerLine(width: 180, height: 20, cornerRadius: 6)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(0..<4, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: 12) {
                            ShimmerLine(width: 36, height: 36, cornerRadius: 10)
                            ShimmerLine(width: 48, height: 28, cornerRadius: 6)
                            ShimmerLine(width: 90, height: 14, cornerRadius: 4)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(AppTheme.elevatedCard)
                        )
                    }
                }

                ShimmerLine(width: 160, height: 20, cornerRadius: 6)

                VStack(spacing: 20) {
                    ForEach(0..<3, id: \.self) { _ in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                ShimmerLine(width: 120, height: 14, cornerRadius: 4)
                                Spacer()
                                ShimmerLine(width: 64, height: 14, cornerRadius: 4)
                            }
                            ShimmerLine(height: 8, cornerRadius: 4)
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.card)
                )

                ShimmerLine(width: 140, height: 20, cornerRadius: 6)

                VStack(spacing: 0) {
                    ForEach(0..<6, id: \.self) { _ in
                        HStack(alignment: .top, spacing: 12) {
                            ShimmerCircle(size: 36)
                            VStack(alignment: .leading, spacing: 8) {
                                ShimmerLine(width: 200, height: 14, cornerRadius: 4)
                                ShimmerLine(width: 120, height: 12, cornerRadius: 4)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.card)
                )

                ShimmerLine(width: 120, height: 20, cornerRadius: 6)

                VStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { _ in
                        HStack {
                            ShimmerLine(width: 80, height: 14, cornerRadius: 4)
                            Spacer()
                            ShimmerLine(width: 100, height: 14, cornerRadius: 4)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(AppTheme.card)
                )
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }
}

struct CaptainLeaderboardLoadingShimmer: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ShimmerLine(width: 200, height: 80, cornerRadius: 16)

            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 8) {
                        ShimmerLine(width: 24, height: 20)
                        ShimmerLine(width: 50, height: 10)
                        ShimmerLine(width: 40, height: 22)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(AppTheme.elevatedCard)
                    )
                }
            }

            VStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { _ in
                    HStack(spacing: 12) {
                        ShimmerLine(width: 24, height: 16)
                        ShimmerCircle(size: 40)
                        VStack(alignment: .leading, spacing: 6) {
                            ShimmerLine(width: 120, height: 14)
                            ShimmerLine(width: 80, height: 12)
                        }
                        Spacer()
                        ShimmerLine(width: 32, height: 16)
                    }
                    .padding(16)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppTheme.elevatedCard)
            )
        }
    }
}

struct CommunityGoalLoadingShimmer: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ShimmerLine(width: 140, height: 18)

            HStack(spacing: 0) {
                ShimmerLine(height: 44, cornerRadius: 12)
            }
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(AppTheme.elevatedCard)
            )

            VStack(alignment: .leading, spacing: 16) {
                ShimmerLine(width: 220, height: 12)
                ShimmerLine(width: 180, height: 14)

                HStack(spacing: 12) {
                    ShimmerLine(width: 160, height: 120, cornerRadius: 80)
                    VStack(alignment: .leading, spacing: 16) {
                        ShimmerLine(width: 120, height: 22)
                        ShimmerLine(width: 60, height: 12)
                        ShimmerLine(width: 80, height: 32)
                        ShimmerLine(width: 70, height: 12)
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(AppTheme.elevatedCard)
            )

            VStack(alignment: .leading, spacing: 14) {
                ShimmerLine(width: 200, height: 20)
                ShimmerLine(width: 260, height: 14)

                ForEach(0..<4, id: \.self) { _ in
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                ShimmerLine(width: 100, height: 16)
                                ShimmerLine(width: 140, height: 12)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 8) {
                                ShimmerLine(width: 70, height: 16)
                                ShimmerLine(width: 40, height: 12)
                            }
                        }
                        ShimmerLine(height: 8, cornerRadius: 4)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(AppTheme.elevatedCard)
                    )
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        ContactsLoadingShimmer()
            .padding()
    }
    .background(AppTheme.screenBackground)
}
