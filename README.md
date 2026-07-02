# NEXT_SET

A hyper-focused, single-screen gym micro-tracker for progressive overload — built with SwiftUI, MVVM, and SwiftData.

## Requirements

- Xcode 15+
- iOS 17+
- Swift 5.9+

## Open & Run

1. Open `NEXT_SET/NEXT_SET.xcodeproj` in Xcode.
2. Select an iPhone simulator (iOS 17+).
3. Build and run (`⌘R`).

## Architecture

```
NEXT_SET/
├── NEXT_SETApp.swift          # App entry + SwiftData container
├── ContentView.swift          # Root screen composition
├── Models/
│   └── Models.swift           # Exercise & WorkoutSet (@Model)
├── ViewModels/
│   └── WorkoutViewModel.swift # Workout state, timer, persistence
├── Services/
│   └── SubscriptionManager.swift  # RevenueCat paywall hook
├── Views/
│   ├── Components.swift       # UI building blocks
│   └── PaywallView.swift      # Full-screen monetization sheet
└── Extensions/
    └── Color+Hex.swift        # Neon green & card grey palette
```

## Features

- **Gym dark mode** — pure black background, neon green accents, thin bordered inputs
- **Progressive overload target banner** — visual cue for today's goal
- **Set tracker** — weight/reps fields with spring-animated checkmarks
- **Smart rest timer** — 90s countdown on set completion, +30s extension, haptic + flash on finish
- **SwiftData persistence** — exercises and sets survive app restarts
- **Paywall hook** — `SubscriptionManager` gates exercise creation beyond 3 (set `isPremiumLocked = true` to test)

## Testing the Paywall

By default `SubscriptionManager.isPremiumLocked` is `false` so all features are unlocked during development. To test the paywall, set it to `true` in `SubscriptionManager.swift` and attempt to add a 4th exercise.

## Monetization Integration

Wire RevenueCat into `SubscriptionManager.triggerPurchase()` and toggle `isPremiumLocked` based on entitlement status.
