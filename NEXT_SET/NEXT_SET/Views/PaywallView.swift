import SwiftUI

struct PaywallView: View {
    let onUnlock: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 28) {
                    ZStack {
                        Circle()
                            .fill(Color.neonGreen.opacity(0.12))
                            .frame(width: 80, height: 80)
                        Image(systemName: "crown.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.neonGreen)
                    }

                    VStack(spacing: 10) {
                        Text("UNLOCK UNLIMITED\nPROGRESSION")
                            .font(AppFont.hero(24))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)

                        Text("One-time payment. Own it forever.\nNo subscriptions.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.mutedText)
                    }

                    VStack(spacing: 14) {
                        PaywallFeatureRow(icon: "infinity", text: "Track unlimited exercises")
                        PaywallFeatureRow(icon: "chart.line.uptrend.xyaxis", text: "Smart automated overload calculation")
                        PaywallFeatureRow(icon: "heart.fill", text: "Support indie development")
                    }
                    .padding(.vertical, 8)

                    Button(action: onUnlock) {
                        Text("Unlock Forever — $2.99")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    Button("Not now", action: onDismiss)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.mutedText)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                        .fill(Color.cardGrey)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

private struct PaywallFeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.neonGreen.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.neonGreen)
            }

            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.75))

            Spacer()
        }
    }
}
