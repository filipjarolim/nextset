import SwiftUI

enum AppTheme {
    static let horizontalPadding: CGFloat = 20
    static let cardPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 20
    static let itemSpacing: CGFloat = 12
    static let borderWidth: CGFloat = 0.75
    static let cornerRadiusSmall: CGFloat = 14
    static let cornerRadius: CGFloat = 24
    static let cornerRadiusLarge: CGFloat = 32
}

enum AppFont {
    static func hero(_ size: CGFloat = 42) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }

    static func display(_ size: CGFloat = 56) -> Font {
        .system(size: size, weight: .black, design: .rounded).monospacedDigit()
    }

    static func metric(_ size: CGFloat = 28) -> Font {
        .system(size: size, weight: .bold, design: .rounded).monospacedDigit()
    }

    static func label() -> Font {
        .caption.weight(.semibold)
    }

    static func sectionTitle() -> Font {
        .subheadline.weight(.bold)
    }
}

struct FloatingCardModifier: ViewModifier {
    var cornerRadius: CGFloat = AppTheme.cornerRadius
    var elevated: Bool = false

    func body(content: Content) -> some View {
        content
            .background(elevated ? Color.cardGreyElevated : Color.cardGrey)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: AppTheme.borderWidth)
            )
    }
}

struct NeonBorderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.neonGreen, Color.neonGreenDim.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.25
                    )
            )
    }
}

extension View {
    func floatingCard(cornerRadius: CGFloat = AppTheme.cornerRadius, elevated: Bool = false) -> some View {
        modifier(FloatingCardModifier(cornerRadius: cornerRadius, elevated: elevated))
    }

    func neonBorder() -> some View {
        modifier(NeonBorderModifier())
    }
}

struct AmbientBackground: View {
    var body: some View {
        ZStack {
            Color.black

            Circle()
                .fill(Color.neonGreen.opacity(0.06))
                .frame(width: 320, height: 320)
                .blur(radius: 80)
                .offset(x: -120, y: -280)

            Circle()
                .fill(Color.neonGreen.opacity(0.04))
                .frame(width: 260, height: 260)
                .blur(radius: 70)
                .offset(x: 140, y: 400)
        }
        .ignoresSafeArea()
    }
}

struct StatusPill: View {
    let text: String
    let icon: String
    var accent: Bool = false

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2.weight(.bold))
            Text(text.uppercased())
                .font(.caption2.weight(.bold))
                .tracking(0.8)
        }
        .foregroundStyle(accent ? Color.black : Color.neonGreen)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(accent ? Color.neonGreen : Color.neonGreen.opacity(0.12))
        .clipShape(Capsule())
    }
}

struct SectionHeader: View {
    let title: String
    var trailing: String? = nil

    var body: some View {
        HStack {
            Text(title)
                .font(AppFont.sectionTitle())
                .foregroundStyle(.white)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.mutedText)
            }
        }
    }
}
