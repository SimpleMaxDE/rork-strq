import SwiftUI

/// Central semantic color system for STRQ.
///
/// Rule: color is used to clarify meaning, never to decorate.
/// - success → progressing / on-track / approved / PR secondary
/// - warning → monitor / mixed / caution / moderate
/// - danger  → off-track / underperforming / pain / reset
/// - info    → informational / neutral support
/// - steel   → baseline / coach-default / inert numeric
/// - gold    → earned moments (PRs, milestones, streak highlights)
enum STRQPalette {
    // MARK: - State

    static let success = Color(red: 0.36, green: 0.80, blue: 0.52)
    static let successSoft = Color(red: 0.36, green: 0.80, blue: 0.52).opacity(0.18)

    static let warning = Color(red: 0.98, green: 0.78, blue: 0.28)
    static let warningSoft = Color(red: 0.98, green: 0.78, blue: 0.28).opacity(0.18)

    static let danger = Color(red: 0.96, green: 0.36, blue: 0.36)
    static let dangerSoft = Color(red: 0.96, green: 0.36, blue: 0.36).opacity(0.18)

    static let info = Color(red: 0.50, green: 0.72, blue: 0.98)
    static let infoSoft = Color(red: 0.50, green: 0.72, blue: 0.98).opacity(0.18)

    // MARK: - Neutral / Brand

    static let steel = STRQBrand.steel
    static let steelSoft = Color.white.opacity(0.06)

    // MARK: - Earned / Celebratory

    static let gold = Color(red: 1.0, green: 0.83, blue: 0.38)
    static let goldDeep = Color(red: 0.95, green: 0.70, blue: 0.22)
    static let goldSoft = Color(red: 1.0, green: 0.83, blue: 0.38).opacity(0.16)
    static let goldGradient = LinearGradient(
        colors: [Color(red: 1.0, green: 0.88, blue: 0.46), Color(red: 0.94, green: 0.68, blue: 0.22)],
        startPoint: .top,
        endPoint: .bottom
    )

    // MARK: - Semantic tokens

    enum State: Hashable, Sendable {
        case success, warning, danger, info, neutral, gold
    }

    static func color(for state: State) -> Color {
        switch state {
        case .success: return success
        case .warning: return warning
        case .danger:  return danger
        case .info:    return info
        case .neutral: return steel
        case .gold:    return gold
        }
    }

    static func soft(for state: State) -> Color {
        switch state {
        case .success: return successSoft
        case .warning: return warningSoft
        case .danger:  return dangerSoft
        case .info:    return infoSoft
        case .neutral: return steelSoft
        case .gold:    return goldSoft
        }
    }

    // MARK: - Common mappings

    static func recovery(for score: Int) -> Color {
        switch score {
        case 80...: return success
        case 60..<80: return warning
        default: return danger
        }
    }

    static func sleep(for hours: Double) -> Color {
        if hours >= 7.5 { return success }
        if hours >= 6.5 { return warning }
        return danger
    }

    static func trend(delta: Double) -> Color {
        if delta > 0.02 { return success }
        if delta < -0.02 { return warning }
        return steel
    }

    static func adherence(ratio: Double) -> Color {
        if ratio >= 0.85 { return success }
        if ratio >= 0.65 { return warning }
        return danger
    }
}

// MARK: - Dot indicator

struct STRQStateDot: View {
    let state: STRQPalette.State
    var size: CGFloat = 8

    var body: some View {
        Circle()
            .fill(STRQPalette.color(for: state))
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(STRQPalette.color(for: state).opacity(0.35), lineWidth: 2)
                    .scaleEffect(1.4)
                    .opacity(0.4)
            )
    }
}

// MARK: - State badge

struct STRQStateBadge: View {
    let label: String
    let state: STRQPalette.State
    var icon: String?

    var body: some View {
        HStack(spacing: 5) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
            }
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(0.8)
        }
        .foregroundStyle(STRQPalette.color(for: state))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(STRQPalette.soft(for: state), in: Capsule())
        .overlay(
            Capsule().strokeBorder(STRQPalette.color(for: state).opacity(0.25), lineWidth: 0.5)
        )
    }
}
