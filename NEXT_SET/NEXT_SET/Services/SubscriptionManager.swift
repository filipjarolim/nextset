import Foundation

@MainActor
final class SubscriptionManager: ObservableObject {
    static let freeExerciseLimit = 3

    /// When `false` (default), all features render unlocked for development.
    /// Set to `true` for free-tier users to enforce the exercise limit and paywall.
    @Published var isPremiumLocked: Bool = false
    @Published var showPaywall: Bool = false

    var isPremiumUnlocked: Bool {
        isPremiumLocked == false
    }

    func canAddExercise(currentCount: Int) -> Bool {
        if isPremiumUnlocked {
            return true
        }
        return currentCount < Self.freeExerciseLimit
    }

    func requestAddExercise(currentCount: Int) -> Bool {
        guard canAddExercise(currentCount: currentCount) else {
            showPaywall = true
            return false
        }
        return true
    }

    func triggerPurchase() {
        print("Triggering RevenueCat purchase...")
    }

    func dismissPaywall() {
        showPaywall = false
    }
}
