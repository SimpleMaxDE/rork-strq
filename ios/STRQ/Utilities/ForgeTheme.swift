import SwiftUI

enum STRQBrand {
    static let accent = Color(red: 0.976, green: 0.451, blue: 0.086)
    static let accentSecondary = Color(red: 1.0, green: 0.722, blue: 0.290)
    static let steel = Color(red: 0.655, green: 0.659, blue: 0.678)
    static let graphite = Color(red: 0.125, green: 0.129, blue: 0.141)
    static let obsidian = Color(red: 0.031, green: 0.035, blue: 0.043)
    static let slate = Color(red: 0.439, green: 0.443, blue: 0.467)

    static let accentGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.541, blue: 0.180),
            accent,
            Color(red: 0.761, green: 0.220, blue: 0.047)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let steelGradient = LinearGradient(
        colors: [Color(red: 0.655, green: 0.659, blue: 0.678), Color(red: 0.439, green: 0.443, blue: 0.467)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let subtleGradient = LinearGradient(
        colors: [Color.white.opacity(0.08), Color.white.opacity(0.025)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let cardAccentGradient = LinearGradient(
        colors: [graphite, obsidian],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let cardBorder = Color.white.opacity(0.10)
    static let cardElevated = Color(red: 0.094, green: 0.098, blue: 0.110)
}

enum ForgeTheme {
    static let accent: Color = STRQBrand.accent
    static let accentGradient = STRQBrand.accentGradient
    static let subtleGradient = STRQBrand.subtleGradient

    static func color(for name: String) -> Color {
        switch name {
        case "green", "mint": return STRQPalette.signalGreen
        case "yellow": return STRQPalette.warningAmber
        case "orange": return STRQPalette.energyAccent
        case "red": return STRQPalette.dangerRed
        case "blue", "cyan", "teal": return STRQPalette.steel
        case "purple", "pink": return STRQPalette.steel
        case "gold": return STRQPalette.gold
        default: return STRQBrand.steel
        }
    }

    static func recoveryColor(for score: Int) -> Color {
        STRQPalette.recovery(for: score)
    }

    static func sleepColor(for hours: Double) -> Color {
        STRQPalette.sleep(for: hours)
    }

    static func formatVolume(_ v: Double) -> String {
        if v >= 1000 { return String(format: "%.1fk", v / 1000) }
        return String(format: "%.0f", v)
    }
}

enum STRQSurfaceVariant: Equatable {
    case standard
    case elevated
    case hero

    var cornerRadius: CGFloat {
        switch self {
        case .standard: return 16
        case .elevated: return 18
        case .hero: return 22
        }
    }

    var borderOpacity: Double {
        switch self {
        case .standard: return 0.62
        case .elevated: return 0.78
        case .hero: return 0.9
        }
    }
}

struct STRQSurface<Content: View>: View {
    var variant: STRQSurfaceVariant = .standard
    var accent: Color?
    var padding: CGFloat = 16
    let content: Content

    init(
        variant: STRQSurfaceVariant = .standard,
        accent: Color? = nil,
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.accent = accent
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(surfaceBackground)
            .overlay(surfaceBorder)
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)
    }

    private var surfaceBackground: some View {
        RoundedRectangle(cornerRadius: variant.cornerRadius, style: .continuous)
            .fill(backgroundFill)
            .overlay {
                if variant == .hero {
                    RoundedRectangle(cornerRadius: variant.cornerRadius, style: .continuous)
                        .fill(
                            RadialGradient(
                                colors: [
                                    (accent ?? STRQPalette.energyAccent).opacity(0.14),
                                    STRQPalette.surfaceStrong.opacity(0.32),
                                    Color.clear
                                ],
                                center: .topLeading,
                                startRadius: 8,
                                endRadius: 260
                            )
                        )
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: variant.cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.045), lineWidth: 1)
                    .blendMode(.plusLighter)
            }
    }

    private var surfaceBorder: some View {
        RoundedRectangle(cornerRadius: variant.cornerRadius, style: .continuous)
            .strokeBorder(
                accent.map { $0.opacity(variant == .hero ? 0.32 : 0.22) }
                    ?? STRQPalette.borderHairline.opacity(variant.borderOpacity),
                lineWidth: 1
            )
    }

    private var backgroundFill: LinearGradient {
        switch variant {
        case .standard:
            return LinearGradient(
                colors: [STRQPalette.surfaceCarbon, STRQPalette.backgroundDeep],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .elevated:
            return LinearGradient(
                colors: [STRQPalette.surfaceRaised, STRQPalette.surfaceBase],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .hero:
            return LinearGradient(
                colors: [STRQPalette.surfaceHero, STRQPalette.surfaceBase, STRQPalette.backgroundPrimary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var shadowColor: Color {
        switch variant {
        case .standard:
            return .black.opacity(0.18)
        case .elevated:
            return .black.opacity(0.28)
        case .hero:
            return (accent ?? STRQPalette.energyAccent).opacity(0.10)
        }
    }

    private var shadowRadius: CGFloat {
        switch variant {
        case .standard: return 10
        case .elevated: return 16
        case .hero: return 24
        }
    }

    private var shadowY: CGFloat {
        switch variant {
        case .standard: return 5
        case .elevated: return 8
        case .hero: return 10
        }
    }
}

struct STRQMetricTile: View {
    let value: String
    let label: String
    var icon: String?
    var delta: String?
    var tint: Color = STRQPalette.energyAccent
    var progress: Double?
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 5 : 8) {
            if icon != nil || delta != nil {
                HStack(spacing: 6) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: compact ? 10 : 11, weight: .bold))
                    }
                    Spacer(minLength: 0)
                    if let delta {
                        Text(delta)
                            .font(.system(size: 9, weight: .black).monospacedDigit())
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                }
                .foregroundStyle(tint)
            }

            Text(value)
                .font(.system(size: compact ? 18 : 22, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundStyle(STRQPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.68)

            Text(label.uppercased())
                .font(.system(size: compact ? 8 : 9, weight: .black))
                .tracking(0.8)
                .foregroundStyle(STRQPalette.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            if let progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                        Capsule()
                            .fill(tint.gradient)
                            .frame(width: max(0, geo.size.width * min(max(progress, 0), 1)))
                    }
                }
                .frame(height: 4)
            }
        }
        .frame(maxWidth: .infinity, minHeight: compact ? 58 : 76, alignment: .leading)
        .padding(.horizontal, compact ? 10 : 12)
        .padding(.vertical, compact ? 9 : 12)
        .background(Color.white.opacity(compact ? 0.045 : 0.055), in: .rect(cornerRadius: compact ? 12 : 14))
        .overlay(
            RoundedRectangle(cornerRadius: compact ? 12 : 14, style: .continuous)
                .strokeBorder(tint.opacity(0.16), lineWidth: 1)
        )
    }
}

struct STRQBadgeChip: View {
    enum Variant {
        case neutral
        case accent
        case muted
        case success
        case warning

        var tint: Color {
            switch self {
            case .neutral: return STRQPalette.textSecondary
            case .accent: return STRQPalette.energyAccent
            case .muted: return STRQPalette.steel
            case .success: return STRQPalette.signalGreen
            case .warning: return STRQPalette.warningAmber
            }
        }

        var fill: Color {
            switch self {
            case .neutral: return Color.white.opacity(0.07)
            case .accent: return STRQPalette.energyAccentSoft
            case .muted: return STRQPalette.steelSoft
            case .success: return STRQPalette.successSoft
            case .warning: return STRQPalette.warningSoft
            }
        }
    }

    let label: String
    var icon: String?
    var variant: Variant = .neutral

    var body: some View {
        HStack(spacing: 5) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
            }
            Text(label.uppercased())
                .font(.system(size: 9, weight: .black))
                .tracking(0.8)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(variant.tint)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(variant.fill, in: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(variant.tint.opacity(0.24), lineWidth: 0.7)
        )
    }
}

struct STRQPrimaryCTA: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .black))
                Text(title)
                    .font(.system(size: 16, weight: .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .foregroundStyle(STRQPalette.backgroundDeep)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(
                STRQPalette.energyAccentGradient,
                in: .rect(cornerRadius: 15)
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color.white.opacity(0.20))
                    .frame(height: 26)
                    .allowsHitTesting(false)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.28), lineWidth: 1)
            )
            .shadow(color: STRQPalette.energyAccent.opacity(0.18), radius: 18, y: 7)
            .shadow(color: .black.opacity(0.28), radius: 22, y: 9)
        }
        .buttonStyle(.strqPressable)
    }
}

struct STRQSectionTitle: View {
    let title: String
    var trailing: String?
    var tint: Color = STRQPalette.energyAccent

    var body: some View {
        HStack(spacing: 8) {
            Capsule()
                .fill(tint.gradient)
                .frame(width: 3, height: 16)
            Text(title.uppercased())
                .font(.system(size: 11, weight: .black))
                .tracking(1.0)
                .foregroundStyle(STRQPalette.textPrimary)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(STRQPalette.textMuted)
                    .lineLimit(1)
            }
        }
    }
}

struct ForgeCard<Content: View>: View {
    var accentColor: Color?
    var elevated: Bool = false
    let content: Content

    init(accentColor: Color? = nil, elevated: Bool = false, @ViewBuilder content: () -> Content) {
        self.accentColor = accentColor
        self.elevated = elevated
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            if let accentColor {
                accentColor
                    .frame(height: 3)
                    .frame(maxWidth: .infinity)
            }
            content
                .padding(14)
        }
        .background(elevated ? STRQBrand.cardElevated : Color(white: 0.105), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(elevated ? Color.white.opacity(0.12) : STRQBrand.cardBorder, lineWidth: 1)
        )
    }
}

struct ForgeSectionHeader: View {
    let title: String
    var trailing: String?
    var showAccent: Bool = true

    var body: some View {
        HStack(spacing: 8) {
            if showAccent {
                RoundedRectangle(cornerRadius: 2)
                    .fill(STRQBrand.steelGradient)
                    .frame(width: 3, height: 16)
            }
            Text(title)
                .font(.subheadline.weight(.bold))
                .textCase(.uppercase)
                .tracking(0.6)
                .foregroundStyle(.primary)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct ForgeEmptyState: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundStyle(STRQBrand.steel)
            Text(title)
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
    }
}

struct ForgeStatCell: View {
    let value: String
    let label: String
    var valueColor: Color = .primary

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .bold).monospacedDigit())
                .foregroundStyle(valueColor)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.3)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ForgeChip: View {
    let text: String
    var color: Color = STRQBrand.steel

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(color.opacity(0.15), in: Capsule())
            .overlay(Capsule().strokeBorder(color.opacity(0.08), lineWidth: 0.5))
    }
}

struct ForgePrimaryButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                Text(title)
                    .font(.body.weight(.bold))
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 27)
                    .frame(maxWidth: .infinity)
                    .clipShape(.rect(cornerRadius: 14))
                    .allowsHitTesting(false)
                , alignment: .top
            )
            .shadow(color: STRQPalette.energyAccent.opacity(0.13), radius: 14, y: 3)
        }
        .buttonStyle(.strqPressable)
    }
}

struct ForgeSecondaryButton: View {
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.medium))
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 12))
        }
        .buttonStyle(.strqPressable)
    }
}
