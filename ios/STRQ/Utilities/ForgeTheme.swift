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
        colors: [Color.white.opacity(0.08), Color.white.opacity(0.02)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let cardAccentGradient = LinearGradient(
        colors: [Color(white: 0.45), Color(white: 0.3)],
        startPoint: .leading,
        endPoint: .trailing
    )
    static let cardBorder = Color.white.opacity(0.09)
    static let cardElevated = Color(white: 0.13)
}

enum ForgeTheme {
    static let accent: Color = STRQBrand.accent
    static let accentGradient = STRQBrand.accentGradient
    static let subtleGradient = STRQBrand.subtleGradient

    static func color(for name: String) -> Color {
        switch name {
        case "green", "mint": return STRQPalette.success
        case "yellow": return STRQPalette.warning
        case "orange": return STRQPalette.warning
        case "red": return STRQPalette.danger
        case "blue", "cyan", "teal": return STRQPalette.info
        case "purple": return STRQBrand.slate
        case "pink": return STRQPalette.info
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
        .background(elevated ? STRQBrand.cardElevated : Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
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
            .shadow(color: .white.opacity(0.08), radius: 12, y: 2)
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
