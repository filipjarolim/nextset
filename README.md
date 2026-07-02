# NEXT_SET

A hyper-focused, single-screen gym micro-tracker for progressive overload — built with SwiftUI, MVVM, and SwiftData.

## Requirements

- Xcode 15+
- iOS 17+
- Swift 5.9+

## Open & Run

1. Open `NEXT_SET/NEXT_SET.xcodeproj` in Xcode on a **Mac**.
2. Select an iPhone simulator (iOS 17+).
3. Build and run (`⌘R`).

> **Note:** iOS Simulator requires macOS. The cloud workspace generates code; run it locally on your Mac.

## Design Identity

Neo-minimalist **Gym Dark Mode** inspired by premium fitness UI:

- Pure black canvas with ambient neon green glow
- Floating cards with 24–32pt continuous corner radii
- Heavy rounded typography for hero metrics and timers
- Metric summary cards (sets, target weight, volume)
- Step-line session progress chart with gradient fill
- Pill-style exercise switcher
- Full-screen rest timer overlay with circular progress ring

### Palette

| Token | Hex | Usage |
|---|---|---|
| Background | `#000000` | Full-screen canvas |
| Neon Green | `#00FF66` | Accents, progress, CTAs |
| Card Grey | `#1C1C1E` | Floating cards |
| Muted Text | `#8E8E93` | Secondary labels |

## Architecture

```
NEXT_SET/
├── NEXT_SETApp.swift
├── ContentView.swift
├── Models/Models.swift
├── ViewModels/WorkoutViewModel.swift
├── Services/SubscriptionManager.swift
├── Views/
│   ├── DesignSystem.swift
│   ├── Components.swift
│   ├── ProgressChartView.swift
│   └── PaywallView.swift
└── Extensions/Color+Hex.swift
```

## Features

- Progressive overload target banner with neon border
- Per-set card tracker with large weight/reps inputs
- Spring-animated checkmarks with haptic feedback
- 90s rest timer overlay with circular progress, +30s, skip
- SwiftData persistence across app restarts
- RevenueCat paywall hook (3-exercise free limit)

## Testing the Paywall

Set `SubscriptionManager.isPremiumLocked = true` and tap **+** when 3 exercises exist.
