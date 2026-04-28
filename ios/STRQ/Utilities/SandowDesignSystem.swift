import SwiftUI

// MARK: - Sandow Design System

enum SandowDesignSystem {
    static let sourceFileKey = "LBvxljax0ixoTvbvvUeWVC"
    static let sourceHomeNodeId = "11604:62728"
}

enum SandowColors {
    static let background = Color(sandowHex: 0x000000)
    static let surfacePrimary = Color(sandowHex: 0x18181B)
    static let surfaceSecondary = Color(sandowHex: 0x27272A)
    static let surfaceTertiary = Color(sandowHex: 0x3F3F46)
    static let cardSurface = surfacePrimary
    static let cardSurfaceElevated = surfaceSecondary
    static let controlSurface = Color(sandowHex: 0x27272A)

    static let borderPrimary = Color(sandowHex: 0xA1A1AA)
    static let borderSecondary = Color(sandowHex: 0x71717A)
    static let borderTertiary = Color(sandowHex: 0x52525B)
    static let borderMuted = Color(sandowHex: 0x3F3F46)
    static let selectedBorder = Color(sandowHex: 0xF97316)

    static let orangePrimary = Color(sandowHex: 0xF97316)
    static let orangeHover = Color(sandowHex: 0xFB923C)
    static let orangeSoft = Color(sandowHex: 0x9A3412)
    static let orangeDim = Color(sandowHex: 0x431407)

    static let success = Color(sandowHex: 0x84CC16)
    static let successSoft = Color(sandowHex: 0x3F6212)
    static let successDim = Color(sandowHex: 0x1A2E05)

    static let danger = Color(sandowHex: 0xF43F5E)
    static let dangerSoft = Color(sandowHex: 0x9F1239)
    static let dangerDim = Color(sandowHex: 0x4C0519)

    static let textPrimary = Color(sandowHex: 0xFFFFFF)
    static let textSecondary = Color(sandowHex: 0xD4D4D8)
    static let textMuted = Color(sandowHex: 0x71717A)
    static let textSubtle = Color(sandowHex: 0x52525B)
    static let textOnBrand = Color(sandowHex: 0xFFFFFF)
}

enum SandowTypography {
    static let fontFamily = "Work Sans"

    static let title = Font.custom(fontFamily, size: 24).weight(.semibold)
    static let heading = Font.custom(fontFamily, size: 20).weight(.semibold)
    static let cardTitle = Font.custom(fontFamily, size: 18).weight(.semibold)
    static let metricNumber = Font.custom(fontFamily, size: 30).weight(.semibold).monospacedDigit()
    static let label = Font.custom(fontFamily, size: 14).weight(.bold)
    static let body = Font.custom(fontFamily, size: 14).weight(.medium)
    static let caption = Font.custom(fontFamily, size: 12).weight(.medium)
    static let button = Font.custom(fontFamily, size: 18).weight(.semibold)
    static let chip = Font.custom(fontFamily, size: 14).weight(.medium)
    static let tabLabel = Font.custom(fontFamily, size: 12).weight(.medium)

    static let titleLineHeight: CGFloat = 32
    static let headingLineHeight: CGFloat = 28
    static let bodyLineHeight: CGFloat = 20
    static let captionLineHeight: CGFloat = 16
    static let labelTracking: CGFloat = 1
}

enum SandowSpacing {
    static let none: CGFloat = 0
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
    static let sectionGap: CGFloat = 24
    static let moduleGap: CGFloat = 12
    static let chipGap: CGFloat = 6
    static let cardPadding: CGFloat = 16
    static let screenHorizontalMargin: CGFloat = 16
}

enum SandowRadii {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let card: CGFloat = 24
    static let button: CGFloat = 18
    static let chip: CGFloat = 12
    static let iconContainer: CGFloat = 12
    static let tabContainer: CGFloat = 16
    static let tabItem: CGFloat = 12
    static let full: CGFloat = 999
}

enum SandowEffects {
    static let cardBorderWidth: CGFloat = 1
    static let selectedBorderWidth: CGFloat = 1
    static let shadowColor = Color.black.opacity(0.08)
    static let shadowRadius: CGFloat = 28
    static let shadowYOffset: CGFloat = 12
    static let subtleShadowColor = Color.black.opacity(0.05)
    static let subtleShadowRadius: CGFloat = 4
    static let subtleShadowYOffset: CGFloat = 2
    static let focusGlowColor = SandowColors.orangePrimary.opacity(0.30)
}

enum SandowIconAsset: String, CaseIterable {
    case home = "SandowIconHome"
    case coach = "SandowIconCoach"
    case train = "SandowIconTrain"
    case progress = "SandowIconProgress"
    case profile = "SandowIconProfile"
    case recovery = "SandowIconRecovery"
    case calendar = "SandowIconCalendar"
    case sleep = "SandowIconSleep"
    case check = "SandowIconCheck"
    case search = "SandowIconSearch"
}

// MARK: - Surfaces

struct SandowSurface<Content: View>: View {
    var selected: Bool = false
    var padding: CGFloat = SandowSpacing.cardPadding
    var radius: CGFloat = SandowRadii.card
    var background: Color = SandowColors.cardSurface
    var border: Color = SandowColors.borderMuted
    let content: Content

    init(
        selected: Bool = false,
        padding: CGFloat = SandowSpacing.cardPadding,
        radius: CGFloat = SandowRadii.card,
        background: Color = SandowColors.cardSurface,
        border: Color = SandowColors.borderMuted,
        @ViewBuilder content: () -> Content
    ) {
        self.selected = selected
        self.padding = padding
        self.radius = radius
        self.background = background
        self.border = border
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(background, in: .rect(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(
                        selected ? SandowColors.selectedBorder : border,
                        lineWidth: selected ? SandowEffects.selectedBorderWidth : SandowEffects.cardBorderWidth
                    )
            )
            .shadow(
                color: selected ? SandowColors.orangePrimary.opacity(0.10) : SandowEffects.subtleShadowColor,
                radius: selected ? 12 : SandowEffects.subtleShadowRadius,
                y: selected ? 6 : SandowEffects.subtleShadowYOffset
            )
    }
}

struct SandowCard<Content: View>: View {
    var selected: Bool = false
    var elevated: Bool = false
    let content: Content

    init(selected: Bool = false, elevated: Bool = false, @ViewBuilder content: () -> Content) {
        self.selected = selected
        self.elevated = elevated
        self.content = content()
    }

    var body: some View {
        SandowSurface(
            selected: selected,
            background: elevated ? SandowColors.cardSurfaceElevated : SandowColors.cardSurface
        ) {
            content
        }
    }
}

// MARK: - Controls

struct SandowButton: View {
    enum Hierarchy: Equatable {
        case primary
        case secondary
        case tertiary
    }

    let title: String
    var icon: SandowIconAsset?
    var hierarchy: Hierarchy = .primary
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SandowSpacing.sm) {
                if let icon {
                    Image(icon.rawValue)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }

                Text(title)
                    .font(SandowTypography.button)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .padding(.horizontal, SandowSpacing.xl)
            .background(backgroundColor, in: .rect(cornerRadius: SandowRadii.button))
            .overlay(
                RoundedRectangle(cornerRadius: SandowRadii.button, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
            .shadow(color: SandowEffects.subtleShadowColor, radius: 4, y: 2)
            .opacity(isDisabled ? 0.48 : 1)
        }
        .buttonStyle(.strqPressable)
        .disabled(isDisabled)
    }

    private var backgroundColor: Color {
        switch hierarchy {
        case .primary:
            return SandowColors.orangePrimary
        case .secondary:
            return SandowColors.orangeDim
        case .tertiary:
            return SandowColors.surfaceSecondary
        }
    }

    private var foregroundColor: Color {
        switch hierarchy {
        case .primary, .secondary:
            return SandowColors.textOnBrand
        case .tertiary:
            return SandowColors.textPrimary
        }
    }

    private var borderColor: Color {
        switch hierarchy {
        case .primary:
            return .clear
        case .secondary:
            return SandowColors.orangePrimary
        case .tertiary:
            return SandowColors.borderMuted
        }
    }

    private var borderWidth: CGFloat {
        hierarchy == .primary ? 0 : 1
    }
}

struct SandowChip: View {
    enum Tone {
        case neutral
        case brand
        case success
        case danger
    }

    let label: String
    var icon: SandowIconAsset?
    var tone: Tone = .neutral

    var body: some View {
        HStack(spacing: SandowSpacing.chipGap) {
            if let icon {
                Image(icon.rawValue)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }

            Text(label)
                .font(SandowTypography.chip)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, 10)
        .padding(.vertical, SandowSpacing.xxs)
        .frame(minHeight: 32)
        .background(backgroundColor, in: .rect(cornerRadius: SandowRadii.chip))
        .overlay(
            RoundedRectangle(cornerRadius: SandowRadii.chip, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 1)
        )
        .shadow(color: SandowEffects.subtleShadowColor, radius: 4, y: 2)
    }

    private var foregroundColor: Color {
        switch tone {
        case .neutral:
            return SandowColors.textSecondary
        case .brand:
            return SandowColors.textOnBrand
        case .success:
            return SandowColors.success
        case .danger:
            return SandowColors.danger
        }
    }

    private var backgroundColor: Color {
        switch tone {
        case .neutral:
            return SandowColors.surfaceSecondary
        case .brand:
            return SandowColors.orangePrimary
        case .success:
            return SandowColors.successDim
        case .danger:
            return SandowColors.dangerDim
        }
    }

    private var borderColor: Color {
        switch tone {
        case .neutral:
            return SandowColors.borderMuted
        case .brand:
            return .clear
        case .success:
            return SandowColors.successSoft
        case .danger:
            return SandowColors.dangerSoft
        }
    }
}

struct SandowIconContainer: View {
    enum Size {
        case sm
        case md
        case lg
        case xl

        var frame: CGFloat {
            switch self {
            case .sm: return 24
            case .md: return 32
            case .lg: return 40
            case .xl: return 48
            }
        }

        var icon: CGFloat {
            switch self {
            case .sm: return 16
            case .md: return 20
            case .lg: return 24
            case .xl: return 28
            }
        }
    }

    let icon: SandowIconAsset
    var size: Size = .lg
    var tint: Color = SandowColors.orangePrimary
    var background: Color? = nil

    var body: some View {
        Image(icon.rawValue)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .foregroundStyle(tint)
            .frame(width: size.icon, height: size.icon)
            .frame(width: size.frame, height: size.frame)
            .background(background ?? tint.opacity(0.14), in: .rect(cornerRadius: SandowRadii.iconContainer))
    }
}

// MARK: - Metrics & Progress

struct SandowMetricCard: View {
    let value: String
    let label: String
    var icon: SandowIconAsset?
    var detail: String?
    var progress: Double?
    var tint: Color = SandowColors.orangePrimary

    var body: some View {
        SandowSurface(padding: SandowSpacing.md, radius: SandowRadii.card) {
            VStack(alignment: .leading, spacing: SandowSpacing.sm) {
                if let icon {
                    SandowIconContainer(icon: icon, size: .lg, tint: tint)
                }

                VStack(alignment: .leading, spacing: SandowSpacing.xxs) {
                    Text(value)
                        .font(SandowTypography.metricNumber)
                        .foregroundStyle(SandowColors.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(label)
                        .font(SandowTypography.caption)
                        .foregroundStyle(SandowColors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }

                if let detail {
                    Text(detail)
                        .font(SandowTypography.caption)
                        .foregroundStyle(SandowColors.textMuted)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }

                if let progress {
                    SandowProgressBar(value: progress, tint: tint)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 108, alignment: .leading)
        }
    }
}

struct SandowProgressRow: View {
    let label: String
    let value: String
    var detail: String?
    var icon: SandowIconAsset = .recovery
    var progress: Double
    var tint: Color = SandowColors.orangePrimary

    var body: some View {
        VStack(alignment: .leading, spacing: SandowSpacing.sm) {
            HStack(spacing: SandowSpacing.sm) {
                SandowIconContainer(icon: icon, size: .md, tint: tint)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(SandowTypography.body)
                        .foregroundStyle(SandowColors.textPrimary)
                        .lineLimit(1)

                    if let detail {
                        Text(detail)
                            .font(SandowTypography.caption)
                            .foregroundStyle(SandowColors.textMuted)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: SandowSpacing.xs)

                Text(value)
                    .font(SandowTypography.label)
                    .foregroundStyle(SandowColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }

            SandowProgressBar(value: progress, height: 8, tint: tint)
        }
        .padding(SandowSpacing.sm)
        .background(SandowColors.surfacePrimary, in: .rect(cornerRadius: SandowRadii.lg))
        .overlay(
            RoundedRectangle(cornerRadius: SandowRadii.lg, style: .continuous)
                .strokeBorder(SandowColors.borderMuted, lineWidth: 1)
        )
    }
}

struct SandowProgressBar: View {
    var value: Double
    var height: CGFloat = 4
    var tint: Color = SandowColors.orangePrimary

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(SandowColors.surfaceTertiary)

                Capsule()
                    .fill(tint)
                    .frame(width: max(height, proxy.size.width * min(max(value, 0), 1)))
            }
        }
        .frame(height: height)
        .clipShape(Capsule())
    }
}

// MARK: - Navigation Helpers

struct SandowSectionHeader<Trailing: View>: View {
    let title: String
    let trailing: Trailing

    init(_ title: String, @ViewBuilder trailing: () -> Trailing) {
        self.title = title
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .center, spacing: SandowSpacing.sm) {
            Text(title)
                .font(SandowTypography.heading)
                .foregroundStyle(SandowColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Spacer(minLength: SandowSpacing.xs)

            trailing
        }
    }
}

extension SandowSectionHeader where Trailing == EmptyView {
    init(_ title: String) {
        self.title = title
        self.trailing = EmptyView()
    }
}

struct SandowTabBarItem: View {
    let title: String
    let icon: SandowIconAsset
    var isSelected: Bool

    var body: some View {
        VStack(spacing: SandowSpacing.xxs) {
            Image(icon.rawValue)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)

            Text(title)
                .font(isSelected ? SandowTypography.tabLabel.weight(.semibold) : SandowTypography.tabLabel)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(isSelected ? SandowColors.orangePrimary : SandowColors.textMuted)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 56)
        .padding(.vertical, SandowSpacing.xxs)
    }
}

struct SandowTabBarBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.top, SandowSpacing.xxs)
            .background(SandowColors.background)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(SandowColors.borderMuted)
                    .frame(height: 1)
            }
            .shadow(color: Color.black.opacity(0.12), radius: 16, y: -4)
    }
}

extension View {
    func sandowTabBarBackground() -> some View {
        modifier(SandowTabBarBackground())
    }
}

#if DEBUG
struct SandowFoundationPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: SandowSpacing.sectionGap) {
            SandowSectionHeader("Today") {
                SandowChip(label: "Ready", icon: .check, tone: .success)
            }

            HStack(spacing: SandowSpacing.xs) {
                SandowMetricCard(
                    value: "88%",
                    label: "Recovery",
                    icon: .recovery,
                    progress: 0.88,
                    tint: SandowColors.success
                )

                SandowMetricCard(
                    value: "3/5",
                    label: "Week",
                    icon: .calendar,
                    progress: 0.6
                )
            }

            SandowProgressRow(
                label: "Training Load",
                value: "72%",
                detail: "Weekly target pace",
                icon: .train,
                progress: 0.72
            )

            SandowButton(title: "Start", icon: .train) {}
        }
        .padding(SandowSpacing.screenHorizontalMargin)
        .background(SandowColors.background)
    }
}
#endif

private extension Color {
    init(sandowHex hex: UInt, opacity: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}
