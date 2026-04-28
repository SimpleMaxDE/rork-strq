import SwiftUI

enum STRQBrand {
    static let accent = Color.white
    static let accentSecondary = Color(white: 0.75)
    static let steel = Color(red: 0.55, green: 0.6, blue: 0.67)
    static let graphite = Color(white: 0.22)
    static let obsidian = Color(white: 0.08)
    static let slate = Color(red: 0.42, green: 0.45, blue: 0.50)

    static let accentGradient = LinearGradient(
        colors: [Color.white, Color(white: 0.82)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let steelGradient = LinearGradient(
        colors: [Color(white: 0.58), Color(white: 0.40)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let subtleGradient = LinearGradient(
        colors: [Color.white.opacity(0.10), Color.white.opacity(0.03)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let cardAccentGradient = LinearGradient(
        colors: [Color(white: 0.45), Color(white: 0.3)],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let cardBorder = Color.white.opacity(0.12)
    static let cardElevated = Color(white: 0.11)
}

enum ForgeTheme {
    static let accent: Color = STRQBrand.accent
    static let accentGradient = STRQBrand.accentGradient
    static let subtleGradient = STRQBrand.subtleGradient

    static func color(for name: String) -> Color {
        switch name {
        case "green", "mint": return STRQPalette.signalGreen
        case "yellow", "orange": return STRQPalette.sandowOrange
        case "red": return STRQPalette.dangerRed
        case "blue", "cyan", "teal": return STRQPalette.signalIce
        case "purple", "pink": return STRQPalette.pulseViolet
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
        case .standard: return 20
        case .elevated: return 24
        case .hero: return 24
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
                            LinearGradient(
                                colors: [
                                    (accent ?? STRQPalette.sandowOrange).opacity(0.08),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
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
                    ?? STRQPalette.sandowBorder.opacity(variant.borderOpacity),
                lineWidth: 1
            )
    }

    private var backgroundFill: LinearGradient {
        switch variant {
        case .standard:
            return LinearGradient(
                colors: [STRQPalette.sandowSurfaceElevated, STRQPalette.sandowSurface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .elevated:
            return LinearGradient(
                colors: [STRQPalette.sandowSurfaceHigh, STRQPalette.sandowSurfaceElevated],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .hero:
            return LinearGradient(
                colors: [STRQPalette.sandowSurfaceHigh, STRQPalette.sandowSurfaceElevated, STRQPalette.sandowSurface],
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
            return .black.opacity(0.34)
        }
    }

    private var shadowRadius: CGFloat {
        switch variant {
        case .standard: return 12
        case .elevated: return 18
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
    var tint: Color = STRQPalette.sandowOrange
    var progress: Double?
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: compact ? 7 : 10) {
            if icon != nil || delta != nil {
                HStack(spacing: 6) {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: compact ? 11 : 14, weight: .bold))
                            .frame(width: compact ? 28 : 34, height: compact ? 28 : 34)
                            .background(tint.opacity(0.14), in: .rect(cornerRadius: compact ? 9 : 11))
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
                .font(.system(size: compact ? 18 : 24, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundStyle(STRQPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.68)

            Text(label)
                .font(.system(size: compact ? 10 : 12, weight: .semibold))
                .foregroundStyle(STRQPalette.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            if let progress {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                        Capsule()
                            .fill(tint)
                            .frame(width: max(0, geo.size.width * min(max(progress, 0), 1)))
                    }
                }
                .frame(height: 4)
            }
        }
        .frame(maxWidth: .infinity, minHeight: compact ? 74 : 112, alignment: .leading)
        .padding(.horizontal, compact ? 11 : 14)
        .padding(.vertical, compact ? 10 : 14)
        .background(STRQPalette.sandowSurface.opacity(compact ? 0.92 : 1), in: .rect(cornerRadius: compact ? 18 : 20))
        .overlay(
            RoundedRectangle(cornerRadius: compact ? 18 : 20, style: .continuous)
                .strokeBorder(STRQPalette.sandowBorder, lineWidth: 1)
        )
    }
}

struct STRQBadgeChip: View {
    enum Variant {
        case neutral
        case orange
        case ice
        case violet
        case success
        case warning
        case danger

        var tint: Color {
            switch self {
            case .neutral: return STRQPalette.textSecondary
            case .orange: return STRQPalette.sandowOrange
            case .ice: return STRQPalette.signalIce
            case .violet: return STRQPalette.pulseViolet
            case .success: return STRQPalette.signalGreen
            case .warning: return STRQPalette.warningAmber
            case .danger: return STRQPalette.dangerRed
            }
        }

        var fill: Color {
            switch self {
            case .neutral: return STRQPalette.sandowControl
            case .orange: return STRQPalette.sandowOrangeSoft
            case .ice: return STRQPalette.signalIceSoft
            case .violet: return STRQPalette.pulseVioletSoft
            case .success: return STRQPalette.successSoft
            case .warning: return STRQPalette.warningSoft
            case .danger: return STRQPalette.dangerSoft
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
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
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
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(STRQPalette.sandowOrange, in: .rect(cornerRadius: 18))
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 26)
                    .allowsHitTesting(false)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
            )
            .shadow(color: STRQPalette.sandowShadow, radius: 16, y: 8)
        }
        .buttonStyle(.strqPressable)
    }
}

struct STRQSectionTitle: View {
    let title: String
    var trailing: String?
    var tint: Color = STRQPalette.sandowOrange

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(STRQPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(tint)
                    .lineLimit(1)
            }
        }
    }
}

struct STRQSectionHeader<Trailing: View>: View {
    let title: String
    let trailing: Trailing

    init(_ title: String, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(STRQPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)
            Spacer(minLength: 8)
            trailing
        }
    }
}

extension STRQSectionHeader where Trailing == EmptyView {
    init(_ title: String) {
        self.title = title
        self.trailing = EmptyView()
    }
}

struct STRQMiniProgressRing<Content: View>: View {
    var progress: Double
    var tint: Color = STRQPalette.sandowOrange
    var size: CGFloat = 92
    var lineWidth: CGFloat = 8
    let content: Content

    init(
        progress: Double,
        tint: Color = STRQPalette.sandowOrange,
        size: CGFloat = 92,
        lineWidth: CGFloat = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.progress = progress
        self.tint = tint
        self.size = size
        self.lineWidth = lineWidth
        self.content = content()
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.075), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Circle()
                .fill(STRQPalette.sandowInset)
                .padding(lineWidth + 7)

            content
        }
        .frame(width: size, height: size)
        .shadow(color: Color.black.opacity(0.22), radius: 12, y: 6)
    }
}

struct STRQAchievementBadgeMark: View {
    let icon: String
    var tint: Color = STRQPalette.sandowOrange
    var progress: Double = 1
    var size: CGFloat = 64

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                .fill(tint.opacity(0.16))
                .overlay(
                    RoundedRectangle(cornerRadius: size * 0.32, style: .continuous)
                        .strokeBorder(tint.opacity(0.32), lineWidth: 1)
                )

            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(tint, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(8)

            Image(systemName: icon)
                .font(.system(size: size * 0.32, weight: .black))
                .foregroundStyle(tint)
        }
        .frame(width: size, height: size)
        .shadow(color: tint.opacity(0.12), radius: 14, y: 8)
    }
}

struct STRQDashboardHeroCard: View {
    struct Metric: Identifiable {
        let label: String
        let value: String
        var icon: String?
        var tint: Color = STRQPalette.sandowOrange

        var id: String { "\(label)-\(value)" }
    }

    let title: String
    let status: String
    let score: Int
    let scoreLabel: String
    let insight: String
    let accent: Color
    let metrics: [Metric]

    var body: some View {
        STRQSurface(variant: .hero, accent: accent, padding: 0) {
            HStack(alignment: .center, spacing: 12) {
                VStack(spacing: 0) {
                    Text("\(score)")
                        .font(.system(size: 30, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(accent)
                        .contentTransition(.numericText())
                    Text(scoreLabel.uppercased())
                        .font(.system(size: 7, weight: .black))
                        .tracking(0.5)
                        .foregroundStyle(STRQPalette.backgroundDeep.opacity(0.70))
                        .lineLimit(1)
                        .minimumScaleFactor(0.58)
                }
                .frame(width: 64, height: 64)
                .background(STRQPalette.sandowCream, in: .rect(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(accent.opacity(0.88), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.18), radius: 10, y: 6)

                VStack(alignment: .leading, spacing: 6) {
                    Text(status)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(STRQPalette.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.74)

                    Text(insight)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(STRQPalette.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)

                    HStack(spacing: 8) {
                        ForEach(metrics.prefix(2)) { metric in
                            HStack(spacing: 4) {
                                if let icon = metric.icon {
                                    Image(systemName: icon)
                                        .font(.system(size: 11, weight: .bold))
                                }
                                Text(metric.value)
                                    .font(.system(size: 13, weight: .medium).monospacedDigit())
                                    .lineLimit(1)
                            }
                            .foregroundStyle(metric.tint)
                        }
                    }
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(STRQPalette.textMuted)
            }
            .padding(16)
        }
    }
}

struct STRQProgressRow: View {
    let label: String
    let value: String
    var detail: String?
    var icon: String = "waveform.path.ecg"
    var progress: Double
    var tint: Color = STRQPalette.sandowOrange

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(tint)
                    .frame(width: 34, height: 34)
                    .background(tint.opacity(0.14), in: .rect(cornerRadius: 11))

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(STRQPalette.textPrimary)
                        .lineLimit(1)
                    if let detail {
                        Text(detail)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(STRQPalette.textMuted)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                Text(value)
                    .font(.system(size: 14, weight: .black, design: .rounded).monospacedDigit())
                    .foregroundStyle(STRQPalette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                    Capsule()
                        .fill(tint)
                        .frame(width: max(6, geo.size.width * min(max(progress, 0), 1)))
                }
            }
            .frame(height: 7)
        }
        .padding(12)
        .background(STRQPalette.sandowSurface.opacity(0.95), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(STRQPalette.sandowBorder, lineWidth: 1)
        )
    }
}

struct STRQSignalBar: View {
    let label: String
    let value: String
    var detail: String?
    var icon: String = "waveform.path.ecg"
    var progress: Double
    var tint: Color = STRQPalette.sandowOrange

    var body: some View {
        STRQProgressRow(
            label: label,
            value: value,
            detail: detail,
            icon: icon,
            progress: progress,
            tint: tint
        )
    }
}

struct STRQAchievementPreviewCard: View {
    let eyebrow: String
    let title: String
    let detail: String
    let value: String
    let icon: String
    let tint: Color
    let progress: Double

    var body: some View {
        STRQSurface(variant: .elevated, accent: tint, padding: 14) {
            HStack(spacing: 14) {
                STRQAchievementBadgeMark(icon: icon, tint: tint, progress: progress, size: 64)

                VStack(alignment: .leading, spacing: 6) {
                    Text(eyebrow)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(tint)
                        .lineLimit(1)
                    Text(title)
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundStyle(STRQPalette.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Text(detail)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(STRQPalette.textSecondary)
                        .lineLimit(2)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.08))
                            Capsule()
                                .fill(tint)
                                .frame(width: max(6, geo.size.width * min(max(progress, 0), 1)))
                        }
                    }
                    .frame(height: 6)
                }

                Spacer(minLength: 6)

                Text(value)
                    .font(.system(size: 18, weight: .black, design: .rounded).monospacedDigit())
                    .foregroundStyle(STRQPalette.textPrimary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(tint.opacity(0.14), in: Capsule())
                    .overlay(Capsule().strokeBorder(tint.opacity(0.25), lineWidth: 0.8))
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
            .shadow(color: .white.opacity(0.13), radius: 14, y: 3)
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
