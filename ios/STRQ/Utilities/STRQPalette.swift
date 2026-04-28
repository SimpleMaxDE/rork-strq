import SwiftUI

/// Central semantic color system for STRQ.
///
/// Rule: color is used to clarify meaning, never to decorate.
/// - success: progressing / on-track / approved / PR secondary
/// - warning: monitor / mixed / caution / moderate
/// - danger: off-track / underperforming / pain / reset
/// - info: informational / neutral support
/// - steel: baseline / coach-default / inert numeric
/// - gold: earned moments (PRs, milestones, streak highlights)
enum STRQPalette {
    // MARK: - STRQ visual foundation

    static let backgroundPrimary = Color(red: 0.012, green: 0.012, blue: 0.012)
    static let backgroundCarbon = Color(red: 0.031, green: 0.035, blue: 0.043)
    static let backgroundDeep = Color(red: 0.020, green: 0.020, blue: 0.020)
    static let surfaceBase = Color(red: 0.067, green: 0.067, blue: 0.075)
    static let surfaceRaised = Color(red: 0.094, green: 0.098, blue: 0.110)
    static let surfaceStrong = Color(red: 0.125, green: 0.129, blue: 0.141)
    static let surfaceCarbon = surfaceBase
    static let surfaceHero = surfaceRaised

    static let borderSubtle = Color(red: 0.165, green: 0.169, blue: 0.184)
    static let borderStrong = Color(red: 0.227, green: 0.231, blue: 0.251)
    static let borderHairline = borderSubtle

    static let textPrimary = Color(red: 0.969, green: 0.969, blue: 0.973)
    static let textSecondary = Color(red: 0.655, green: 0.659, blue: 0.678)
    static let textMuted = Color(red: 0.439, green: 0.443, blue: 0.467)

    static let energyAccent = Color(red: 0.976, green: 0.451, blue: 0.086)
    static let energyAccentSoft = energyAccent.opacity(0.16)
    static let energyAccentGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.541, blue: 0.180),
            energyAccent,
            Color(red: 0.761, green: 0.220, blue: 0.047)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let signalGreen = Color(red: 0.290, green: 0.871, blue: 0.502)
    static let warningAmber = Color(red: 1.0, green: 0.722, blue: 0.290)
    static let dangerRed = Color(red: 1.0, green: 0.302, blue: 0.427)

    // MARK: - State

    static let success = signalGreen
    static let successSoft = signalGreen.opacity(0.16)

    static let warning = warningAmber
    static let warningSoft = warningAmber.opacity(0.16)

    static let danger = dangerRed
    static let dangerSoft = dangerRed.opacity(0.16)

    static let info = STRQBrand.steel
    static let infoSoft = STRQBrand.steel.opacity(0.14)

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
