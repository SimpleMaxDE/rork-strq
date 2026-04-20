import Foundation

/// Engine-facing role used to preserve training role when suggesting swaps.
/// Distinct from UI-facing `ExerciseRole` so engine logic stays independent
/// of presentation types.
nonisolated enum ReplacementRole: String, Sendable, Codable, CaseIterable {
    case anchor
    case secondary
    case accessory
    case isolation
    case warmup
    case mobility

    var displayName: String {
        switch self {
        case .anchor: "Anchor"
        case .secondary: "Support"
        case .accessory: "Accessory"
        case .isolation: "Isolation"
        case .warmup: "Warm-Up"
        case .mobility: "Mobility"
        }
    }
}

/// Distinct replacement intents a user can ask the coach for. The engine
/// ranks substitutes independently per intent, so each surface (chip / row)
/// gets its own ordered list rather than one generic fallback ranking.
nonisolated enum SwapIntent: String, Sendable, Codable, CaseIterable, Identifiable {
    case closest
    case variation
    case easier
    case harder
    case jointFriendly
    case home

    var id: String { rawValue }

    var label: String {
        switch self {
        case .closest: "Closest"
        case .variation: "Variation"
        case .easier: "Easier"
        case .harder: "Harder"
        case .jointFriendly: "Joint-Friendly"
        case .home: "Home"
        }
    }

    var shortLabel: String {
        switch self {
        case .closest: "Closest equivalent"
        case .variation: "Same family"
        case .easier: "Easier option"
        case .harder: "Harder option"
        case .jointFriendly: "Joint-friendly"
        case .home: "Works at home"
        }
    }

    var symbolName: String {
        switch self {
        case .closest: "scope"
        case .variation: "rectangle.stack.fill"
        case .easier: "arrow.down.circle.fill"
        case .harder: "arrow.up.circle.fill"
        case .jointFriendly: "hand.thumbsup.fill"
        case .home: "house.fill"
        }
    }
}
