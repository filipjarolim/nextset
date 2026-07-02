import SwiftUI

struct PaywallView: View {
    let onUnlock: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .background(.ultraThinMaterial)
                .onTapGesture(perform: onDismiss)

            VStack(spacing: 24) {
                VStack(spacing: 10) {
                    Text("UNLOCK UNLIMITED PROGRESSION")
                        .font(.title3.weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)

                    Text("One-time payment. Own it forever. No subscriptions.")
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.white.opacity(0.6))
                }

                VStack(alignment: .leading, spacing: 12) {
                    PaywallBullet(text: "Track unlimited exercises")
                    PaywallBullet(text: "Smart automated overload calculation")
                    PaywallBullet(text: "Support indie development")
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: onUnlock) {
                    Text("Unlock Forever — $2.99")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)

                Button("Not now", action: onDismiss)
                    .font(.footnote)
                    .foregroundStyle(Color.white.opacity(0.5))
            }
            .padding(28)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.black.opacity(0.85))
                    )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.75)
            )
            .padding(.horizontal, 24)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }
}

private struct PaywallBullet: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundStyle(Color.white.opacity(0.45))
            Text(text)
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.55))
        }
    }
}
