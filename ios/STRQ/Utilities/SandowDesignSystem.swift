import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/*
 Sandow Design System Foundation

 This file is STRQ's isolated Sandow foundation layer. It mirrors the purchased
 Sandow UI Kit tokens and primitive components without overriding STRQPalette or
 changing existing production screens.

 Use this file for new Sandow-based UI primitives, previews, and future
 screen-by-screen migrations. Do not import Sandow demo photos, coach/person
 imagery, marketing mockups, huge mesh backgrounds, the full source Figma file,
 or the full ZIP into the app repository.

 Adding icons:
 1. Export a Sandow Regular-style icon as template SVG or vector PDF.
 2. Add it as ios/STRQ/Assets.xcassets/SandowIcon<Name>.imageset.
 3. Set preserves-vector-representation and template-rendering-intent.
 4. Add a matching SandowIcon case whose raw value is the asset name.
 5. Render with SandowIconView(.caseName, size:tint:templateRendering:).

 Future migrations should replace one contained surface at a time, using these
 components explicitly. Existing dashboard, workout, paywall, onboarding, and
 analytics flows should remain untouched until a dedicated migration pass.
 */

// MARK: - Sandow Design System

enum SandowDesignSystem {
    static let sourceFileKey = "LBvxljax0ixoTvbvvUeWVC"
    static let sourceFileURL = "https://www.figma.com/design/LBvxljax0ixoTvbvvUeWVC/SH-sandow-UI-Kit--v3.0-"

    static let foundationsPageNodeId = "5358:6096"
    static let colorsNodeId = "5359:9002"
    static let gradientsNodeId = "5442:13546"
    static let typographyNodeId = "9119:6481"
    static let effectsNodeId = "9120:58753"
    static let sizeSpacingNodeId = "9122:6944"

    static let iconSetPageNodeId = "5367:38988"
    static let iconsNodeId = "5454:22014"

    static let generalComponentsPageNodeId = "5358:4030"
    static let appComponentsPageNodeId = "5643:11300"
    static let sourceHomeNodeId = "11604:62728"

    static let fontFamily = "Work Sans"
    static let workSansFontFilesBundled = false
    static let iconAssetPrefix = "SandowIcon"
}

// MARK: - Color Tokens

enum SandowColors {
    // Primitive neutrals.
    static let black = Color(sandowHex: 0x000000)
    static let white = Color(sandowHex: 0xFFFFFF)
    static let gray50 = Color(sandowHex: 0xFAFAFA)
    static let gray100 = Color(sandowHex: 0xF4F4F5)
    static let gray200 = Color(sandowHex: 0xE4E4E7)
    static let gray300 = Color(sandowHex: 0xD4D4D8)
    static let gray400 = Color(sandowHex: 0xA1A1AA)
    static let gray500 = Color(sandowHex: 0x71717A)
    static let gray600 = Color(sandowHex: 0x52525B)
    static let gray700 = Color(sandowHex: 0x3F3F46)
    static let gray800 = Color(sandowHex: 0x27272A)
    static let gray900 = Color(sandowHex: 0x18181B)
    static let gray950 = Color(sandowHex: 0x09090B)

    // Primitive orange / brand scale.
    static let orange50 = Color(sandowHex: 0xFFF7ED)
    static let orange100 = Color(sandowHex: 0xFFEDD5)
    static let orange200 = Color(sandowHex: 0xFED7AA)
    static let orange300 = Color(sandowHex: 0xFDBA74)
    static let orange400 = Color(sandowHex: 0xFB923C)
    static let orange500 = Color(sandowHex: 0xF97316)
    static let orange600 = Color(sandowHex: 0xEA580C)
    static let orange700 = Color(sandowHex: 0xC2410C)
    static let orange800 = Color(sandowHex: 0x9A3412)
    static let orange900 = Color(sandowHex: 0x7C2D12)
    static let orange950 = Color(sandowHex: 0x431407)

    // Primitive semantic accents present in Sandow.
    static let blue500 = Color(sandowHex: 0x3B82F6)
    static let purple500 = Color(sandowHex: 0xA855F7)
    static let lime500 = Color(sandowHex: 0x84CC16)
    static let amber500 = Color(sandowHex: 0xF59E0B)
    static let rose500 = Color(sandowHex: 0xF43F5E)

    // Dark-mode background and surface foundation.
    static let baseBackground = black
    static let elevatedBackground = gray900
    static let secondaryBackground = gray900
    static let tertiaryBackground = gray800
    static let quaternaryBackground = gray700
    static let inverseBackground = white

    static let cardSurface = gray900
    static let elevatedCardSurface = gray800
    static let insetSurface = gray950
    static let controlSurface = gray800
    static let selectedSurface = orange950

    // Dark-mode text foundation.
    static let primaryText = white
    static let secondaryText = gray300
    static let mutedText = gray500
    static let disabledText = gray700
    static let subtleText = gray600
    static let textOnBrand = gray800
    static let textOnInverse = gray800

    // Dark-mode borders and dividers.
    static let borderPrimary = gray400
    static let borderSecondary = gray500
    static let borderTertiary = gray600
    static let borderMuted = gray700
    static let divider = gray700
    static let selectedBorder = orange500

    // Brand semantics.
    static let orangePrimary = orange500
    static let orangeHover = orange400
    static let orangePressed = orange600
    static let orangeSoft = orange800
    static let orangeSofter = orange900
    static let orangeDim = orange950
    static let brandTextPrimary = orange200
    static let brandTextSecondary = orange500
    static let brandTextTertiary = orange700

    // Status semantics.
    static let successGreen = lime500
    static let success = lime500
    static let successSoft = Color(sandowHex: 0x3F6212)
    static let successDim = Color(sandowHex: 0x1A2E05)
    static let successTextPrimary = Color(sandowHex: 0xD9F99D)
    static let successTextSecondary = lime500
    static let successTextTertiary = Color(sandowHex: 0x4D7C0F)

    static let warningAmber = amber500
    static let warning = amber500
    static let warningSoft = Color(sandowHex: 0x92400E)
    static let warningDim = Color(sandowHex: 0x451A03)
    static let warningTextPrimary = Color(sandowHex: 0xFDE68A)
    static let warningTextSecondary = amber500
    static let warningTextTertiary = Color(sandowHex: 0xB45309)

    static let dangerRed = rose500
    static let danger = rose500
    static let dangerSoft = Color(sandowHex: 0x9F1239)
    static let dangerDim = Color(sandowHex: 0x4C0519)
    static let dangerTextPrimary = Color(sandowHex: 0xFECDD3)
    static let dangerTextSecondary = rose500
    static let dangerTextTertiary = Color(sandowHex: 0xBE123C)

    static let blue = blue500
    static let blueSoft = Color(sandowHex: 0x172554)
    static let purple = purple500
    static let gold = Color(sandowHex: 0xFACC15)

    // Backwards-compatible aliases from the first Sandow foundation pass.
    static let background = baseBackground
    static let cloneInk = gray900
    static let surfacePrimary = cardSurface
    static let surfaceSecondary = elevatedCardSurface
    static let surfaceTertiary = quaternaryBackground
    static let cardSurfaceElevated = elevatedCardSurface
    static let textPrimary = primaryText
    static let textSecondary = secondaryText
    static let textMuted = mutedText
    static let textSubtle = subtleText
}

// MARK: - Gradient Tokens

enum SandowGradients {
    static let orangeCTA = LinearGradient(
        colors: [SandowColors.orange400, SandowColors.orange500, SandowColors.orange600],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let orangeGlow = RadialGradient(
        colors: [SandowColors.orangePrimary.opacity(0.34), SandowColors.orangeDim.opacity(0)],
        center: .center,
        startRadius: 0,
        endRadius: 120
    )

    static let darkCard = LinearGradient(
        colors: [SandowColors.gray800, SandowColors.gray900],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let insetCard = LinearGradient(
        colors: [SandowColors.gray950, SandowColors.gray900],
        startPoint: .top,
        endPoint: .bottom
    )

    static let subtleOverlay = LinearGradient(
        colors: [SandowColors.white.opacity(0.08), SandowColors.white.opacity(0)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let progressOrange = LinearGradient(
        colors: [SandowColors.orange400, SandowColors.orangePrimary],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let progressSuccess = LinearGradient(
        colors: [SandowColors.successTextPrimary, SandowColors.successGreen],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let progressWarning = LinearGradient(
        colors: [SandowColors.warningTextPrimary, SandowColors.warningAmber],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let progressDanger = LinearGradient(
        colors: [SandowColors.dangerTextPrimary, SandowColors.dangerRed],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Typography Tokens

enum SandowTypography {
    static let fontFamily = SandowDesignSystem.fontFamily

    static let displayLarge = sandowFont(size: 180, weight: .semibold)
    static let displayMedium = sandowFont(size: 128, weight: .semibold)
    static let displaySmall = sandowFont(size: 96, weight: .semibold)

    static let heading2XL = sandowFont(size: 72, weight: .semibold)
    static let headingXL = sandowFont(size: 60, weight: .semibold)
    static let headingLarge = sandowFont(size: 48, weight: .semibold)
    static let headingMedium = sandowFont(size: 36, weight: .semibold)
    static let headingSmall = sandowFont(size: 30, weight: .semibold)
    static let headingXS = sandowFont(size: 24, weight: .semibold)

    static let title = sandowFont(size: 24, weight: .semibold)
    static let cardTitle = sandowFont(size: 18, weight: .semibold)
    static let metricLarge = sandowFont(size: 40, weight: .semibold).monospacedDigit()
    static let metricMedium = sandowFont(size: 30, weight: .semibold).monospacedDigit()
    static let metricSmall = sandowFont(size: 20, weight: .bold).monospacedDigit()

    static let bodyXLarge = sandowFont(size: 20, weight: .regular)
    static let bodyLarge = sandowFont(size: 18, weight: .regular)
    static let body = sandowFont(size: 16, weight: .regular)
    static let bodyMedium = sandowFont(size: 16, weight: .medium)
    static let bodySmall = sandowFont(size: 14, weight: .regular)
    static let bodySmallMedium = sandowFont(size: 14, weight: .medium)

    static let caption = sandowFont(size: 12, weight: .medium)
    static let captionRegular = sandowFont(size: 12, weight: .regular)
    static let micro = sandowFont(size: 10, weight: .medium)

    static let label = sandowFont(size: 14, weight: .bold)
    static let labelLarge = sandowFont(size: 18, weight: .bold)
    static let labelSmall = sandowFont(size: 12, weight: .bold)
    static let chip = sandowFont(size: 14, weight: .medium)
    static let chipSmall = sandowFont(size: 12, weight: .medium)
    static let button = sandowFont(size: 18, weight: .semibold)
    static let buttonCompact = sandowFont(size: 14, weight: .semibold)
    static let tabLabel = sandowFont(size: 12, weight: .medium)

    // Backwards-compatible aliases from the first Sandow foundation pass.
    static let heading = cardTitle
    static let largeValue = title.monospacedDigit()
    static let metricNumber = metricMedium
    static let metricCompactNumber = metricSmall
    static let bodyRegular = bodySmall

    static let displayLargeLineHeight: CGFloat = 188
    static let displayMediumLineHeight: CGFloat = 136
    static let headingLargeLineHeight: CGFloat = 56
    static let headingMediumLineHeight: CGFloat = 44
    static let headingSmallLineHeight: CGFloat = 38
    static let titleLineHeight: CGFloat = 32
    static let bodyLineHeight: CGFloat = 26
    static let bodySmallLineHeight: CGFloat = 22
    static let captionLineHeight: CGFloat = 16

    static let displayLargeTracking: CGFloat = -8
    static let displayMediumTracking: CGFloat = -4
    static let headingTracking: CGFloat = -0.5
    static let labelTracking: CGFloat = 1

    private static func sandowFont(size: CGFloat, weight: Font.Weight) -> Font {
        Font.custom(fontFamily, size: size).weight(weight)
    }
}

// MARK: - Spacing, Radii, Effects

enum SandowSpacing {
    static let none: CGFloat = 0
    static let px50: CGFloat = 2
    static let px100: CGFloat = 4
    static let px150: CGFloat = 6
    static let px200: CGFloat = 8
    static let px250: CGFloat = 10
    static let px300: CGFloat = 12
    static let px350: CGFloat = 14
    static let px400: CGFloat = 16
    static let px500: CGFloat = 20
    static let px600: CGFloat = 24
    static let px800: CGFloat = 32
    static let px1000: CGFloat = 40
    static let px1200: CGFloat = 48
    static let px1400: CGFloat = 56
    static let px1600: CGFloat = 64
    static let px2000: CGFloat = 80
    static let px2400: CGFloat = 96
    static let px3200: CGFloat = 128

    static let xxs = px100
    static let xs = px200
    static let sm = px300
    static let md = px400
    static let lg = px500
    static let xl = px600
    static let xxl = px800
    static let xxxl = px1000

    static let screenHorizontalMargin = px400
    static let sectionGap = px600
    static let cardGap = px300
    static let moduleGap = px300
    static let cardPadding = px400
    static let cardPaddingCompact = px300
    static let listItemPadding = px400
    static let chipHorizontalPadding = px250
    static let chipVerticalPadding = px100
    static let chipGap = px150

    static let metricCardMinHeight: CGFloat = 108
    static let metricCardMinWidth: CGFloat = 148
    static let buttonHeight: CGFloat = 56
    static let buttonCompactHeight: CGFloat = 40
    static let buttonMiniHeight: CGFloat = 32
    static let iconButtonSize: CGFloat = 44
    static let tabBarHeight: CGFloat = 72
    static let navBarHeight: CGFloat = 56

    static let icon2XS: CGFloat = 12
    static let iconXS: CGFloat = 16
    static let iconSM: CGFloat = 20
    static let iconMD: CGFloat = 24
    static let iconLG: CGFloat = 28
    static let iconXL: CGFloat = 32
    static let icon2XL: CGFloat = 40

    static let iconContainerSM: CGFloat = 32
    static let iconContainerMD: CGFloat = 40
    static let iconContainerLG: CGFloat = 48
    static let iconContainerXL: CGFloat = 56
}

enum SandowRadii {
    static let none: CGFloat = 0
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
    static let full: CGFloat = 9999

    static let card = xxl
    static let largeCard = xxxl
    static let metricCard = xxl
    static let button = xl
    static let chip = md
    static let iconContainer = md
    static let tabbar = xl
    static let tabContainer = lg
    static let tabItem = md
    static let nav = xl
}

struct SandowBorderToken {
    let color: Color
    let width: CGFloat
}

struct SandowShadowToken {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

enum SandowEffects {
    static let hairline: CGFloat = 1
    static let selectedBorderWidth: CGFloat = 1.5
    static let focusRingWidth: CGFloat = 4

    static let subtleCardBorder = SandowBorderToken(color: SandowColors.borderMuted, width: hairline)
    static let selectedCardBorder = SandowBorderToken(color: SandowColors.selectedBorder, width: selectedBorderWidth)
    static let dividerStyle = SandowBorderToken(color: SandowColors.divider, width: hairline)

    static let softShadow = SandowShadowToken(
        color: Color.black.opacity(0.20),
        radius: 24,
        x: 0,
        y: 12
    )

    static let cardShadow = SandowShadowToken(
        color: Color.black.opacity(0.12),
        radius: 16,
        x: 0,
        y: 8
    )

    static let subtleShadow = SandowShadowToken(
        color: Color.black.opacity(0.08),
        radius: 8,
        x: 0,
        y: 4
    )

    static let orangeGlow = SandowShadowToken(
        color: SandowColors.orangePrimary.opacity(0.30),
        radius: 18,
        x: 0,
        y: 8
    )

    static let backgroundBlurXS: CGFloat = 4
    static let backgroundBlurSM: CGFloat = 8
    static let backgroundBlurMD: CGFloat = 16
    static let backgroundBlurLG: CGFloat = 32
    static let backgroundBlurXL: CGFloat = 64

    static let darkGlassBackground = SandowColors.gray900.opacity(0.78)
    static let darkGlassStroke = SandowColors.white.opacity(0.08)

    // Backwards-compatible aliases from the first Sandow foundation pass.
    static let cardBorderWidth = hairline
    static let shadowColor = softShadow.color
    static let shadowRadius = softShadow.radius
    static let shadowYOffset = softShadow.y
    static let subtleShadowColor = subtleShadow.color
    static let subtleShadowRadius = subtleShadow.radius
    static let subtleShadowYOffset = subtleShadow.y
    static let focusGlowColor = SandowColors.orangePrimary.opacity(0.30)
}

enum SandowComponentStyle {
    enum SurfaceVariant: Equatable {
        case base
        case elevated
        case card
        case inset
        case selected

        var background: Color {
            switch self {
            case .base:
                return SandowColors.baseBackground
            case .elevated:
                return SandowColors.elevatedCardSurface
            case .card:
                return SandowColors.cardSurface
            case .inset:
                return SandowColors.insetSurface
            case .selected:
                return SandowColors.selectedSurface
            }
        }
    }

    enum BorderVariant: Equatable {
        case none
        case subtle
        case selected
        case brand
        case danger

        var token: SandowBorderToken {
            switch self {
            case .none:
                return SandowBorderToken(color: .clear, width: 0)
            case .subtle:
                return SandowEffects.subtleCardBorder
            case .selected:
                return SandowEffects.selectedCardBorder
            case .brand:
                return SandowBorderToken(color: SandowColors.orangePrimary, width: SandowEffects.hairline)
            case .danger:
                return SandowBorderToken(color: SandowColors.dangerRed, width: SandowEffects.hairline)
            }
        }
    }

    enum RadiusVariant {
        case card
        case largeCard
        case metricCard
        case button
        case chip
        case iconContainer
        case tabbar
        case nav
        case custom(CGFloat)

        var value: CGFloat {
            switch self {
            case .card:
                return SandowRadii.card
            case .largeCard:
                return SandowRadii.largeCard
            case .metricCard:
                return SandowRadii.metricCard
            case .button:
                return SandowRadii.button
            case .chip:
                return SandowRadii.chip
            case .iconContainer:
                return SandowRadii.iconContainer
            case .tabbar:
                return SandowRadii.tabbar
            case .nav:
                return SandowRadii.nav
            case .custom(let radius):
                return radius
            }
        }
    }

    enum Tone: Equatable {
        case neutral
        case selected
        case orange
        case success
        case warning
        case danger
        case blue
        case disabled

        var foreground: Color {
            switch self {
            case .neutral:
                return SandowColors.secondaryText
            case .selected, .orange:
                return SandowColors.brandTextPrimary
            case .success:
                return SandowColors.successTextPrimary
            case .warning:
                return SandowColors.warningTextPrimary
            case .danger:
                return SandowColors.dangerTextPrimary
            case .blue:
                return SandowColors.blue
            case .disabled:
                return SandowColors.disabledText
            }
        }

        var background: Color {
            switch self {
            case .neutral:
                return SandowColors.surfaceSecondary
            case .selected:
                return SandowColors.selectedSurface
            case .orange:
                return SandowColors.orangeDim
            case .success:
                return SandowColors.successDim
            case .warning:
                return SandowColors.warningDim
            case .danger:
                return SandowColors.dangerDim
            case .blue:
                return SandowColors.blueSoft
            case .disabled:
                return SandowColors.gray800
            }
        }

        var border: Color {
            switch self {
            case .neutral:
                return SandowColors.borderMuted
            case .selected, .orange:
                return SandowColors.orangeSoft
            case .success:
                return SandowColors.successSoft
            case .warning:
                return SandowColors.warningSoft
            case .danger:
                return SandowColors.dangerSoft
            case .blue:
                return SandowColors.blue.opacity(0.45)
            case .disabled:
                return SandowColors.borderMuted
            }
        }
    }
}

// MARK: - Icon System

enum SandowIcon: String, CaseIterable {
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

    case plus = "SandowIconPlus"
    case chevronRight = "SandowIconChevronRight"
    case arrowRight = "SandowIconArrowRight"
    case checkCircle = "SandowIconCheckCircle"
    case clock = "SandowIconClock"
    case target = "SandowIconTarget"
    case trophy = "SandowIconTrophy"
    case barbell = "SandowIconBarbell"
    case weightScale = "SandowIconWeightScale"
    case bell = "SandowIconBell"
    case star = "SandowIconStar"
}

typealias SandowIconAsset = SandowIcon

struct SandowIconView: View {
    let icon: SandowIcon
    var size: CGFloat = SandowSpacing.iconMD
    var tint: Color = SandowColors.textPrimary
    var templateRendering: Bool = true

    init(
        _ icon: SandowIcon,
        size: CGFloat = SandowSpacing.iconMD,
        tint: Color = SandowColors.textPrimary,
        templateRendering: Bool = true
    ) {
        self.icon = icon
        self.size = size
        self.tint = tint
        self.templateRendering = templateRendering
    }

    var body: some View {
        Group {
            if Self.assetExists(icon) {
                sandowImage
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(tint)
            } else {
                SandowMissingIconGlyph(size: size, tint: tint)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private var sandowImage: Image {
        let image = Image(icon.rawValue)
        return templateRendering ? image.renderingMode(.template) : image.renderingMode(.original)
    }

    private static func assetExists(_ icon: SandowIcon) -> Bool {
        #if canImport(UIKit)
        return UIImage(named: icon.rawValue) != nil
        #else
        return true
        #endif
    }
}

private struct SandowMissingIconGlyph: View {
    let size: CGFloat
    let tint: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: max(3, size * 0.22), style: .continuous)
                .strokeBorder(tint.opacity(0.56), lineWidth: max(1, size / 12))

            RoundedRectangle(cornerRadius: max(1, size * 0.08), style: .continuous)
                .fill(tint.opacity(0.56))
                .frame(width: max(2, size * 0.44), height: max(1, size / 12))
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
            case .sm: return SandowSpacing.iconContainerSM
            case .md: return SandowSpacing.iconContainerMD
            case .lg: return SandowSpacing.iconContainerLG
            case .xl: return SandowSpacing.iconContainerXL
            }
        }

        var icon: CGFloat {
            switch self {
            case .sm: return SandowSpacing.iconXS
            case .md: return SandowSpacing.iconSM
            case .lg: return SandowSpacing.iconMD
            case .xl: return SandowSpacing.iconLG
            }
        }
    }

    let icon: SandowIcon
    var size: Size = .lg
    var tint: Color = SandowColors.orangePrimary
    var background: Color? = nil

    var body: some View {
        SandowIconView(icon, size: size.icon, tint: tint)
            .frame(width: size.frame, height: size.frame)
            .background(background ?? tint.opacity(0.14), in: .rect(cornerRadius: SandowRadii.iconContainer))
    }
}

// MARK: - Surfaces & Cards

struct SandowSurface<Content: View>: View {
    var variant: SandowComponentStyle.SurfaceVariant
    var borderVariant: SandowComponentStyle.BorderVariant
    var radius: CGFloat
    var padding: CGFloat
    var customBackground: Color?
    var customBorder: Color?
    var selected: Bool
    let content: Content

    init(
        variant: SandowComponentStyle.SurfaceVariant = .card,
        border: SandowComponentStyle.BorderVariant = .subtle,
        radius: SandowComponentStyle.RadiusVariant = .card,
        padding: CGFloat = SandowSpacing.cardPadding,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.borderVariant = border
        self.radius = radius.value
        self.padding = padding
        self.customBackground = nil
        self.customBorder = nil
        self.selected = variant == .selected || border == .selected
        self.content = content()
    }

    init(
        selected: Bool,
        padding: CGFloat = SandowSpacing.cardPadding,
        radius: CGFloat = SandowRadii.card,
        background: Color = SandowColors.cardSurface,
        border: Color = SandowColors.borderMuted,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = selected ? .selected : .card
        self.borderVariant = selected ? .selected : .subtle
        self.radius = radius
        self.padding = padding
        self.customBackground = background
        self.customBorder = border
        self.selected = selected
        self.content = content()
    }

    var body: some View {
        let token = selected ? SandowEffects.selectedCardBorder : borderVariant.token
        let strokeColor = selected ? SandowColors.selectedBorder : (customBorder ?? token.color)
        let strokeWidth = selected ? SandowEffects.selectedBorderWidth : token.width

        content
            .padding(padding)
            .background(customBackground ?? variant.background, in: .rect(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(strokeColor, lineWidth: strokeWidth)
            )
            .shadow(
                color: selected ? SandowEffects.orangeGlow.color : SandowEffects.subtleShadow.color,
                radius: selected ? SandowEffects.orangeGlow.radius : SandowEffects.subtleShadow.radius,
                x: 0,
                y: selected ? SandowEffects.orangeGlow.y : SandowEffects.subtleShadow.y
            )
    }
}

struct SandowCard<Content: View>: View {
    enum Variant: Equatable {
        case standard
        case elevated
        case selected
        case compact
        case hero
    }

    var variant: Variant = .standard
    let content: Content

    init(_ variant: Variant = .standard, @ViewBuilder content: () -> Content) {
        self.variant = variant
        self.content = content()
    }

    init(selected: Bool, elevated: Bool = false, @ViewBuilder content: () -> Content) {
        if selected {
            self.variant = .selected
        } else if elevated {
            self.variant = .elevated
        } else {
            self.variant = .standard
        }
        self.content = content()
    }

    var body: some View {
        SandowSurface(
            variant: surfaceVariant,
            border: borderVariant,
            radius: radius,
            padding: padding
        ) {
            content
        }
    }

    private var surfaceVariant: SandowComponentStyle.SurfaceVariant {
        switch variant {
        case .standard, .compact:
            return .card
        case .elevated, .hero:
            return .elevated
        case .selected:
            return .selected
        }
    }

    private var borderVariant: SandowComponentStyle.BorderVariant {
        variant == .selected ? .selected : .subtle
    }

    private var radius: SandowComponentStyle.RadiusVariant {
        switch variant {
        case .hero:
            return .largeCard
        case .standard, .elevated, .selected, .compact:
            return .card
        }
    }

    private var padding: CGFloat {
        switch variant {
        case .compact:
            return SandowSpacing.cardPaddingCompact
        case .hero:
            return SandowSpacing.xl
        case .standard, .elevated, .selected:
            return SandowSpacing.cardPadding
        }
    }
}

// MARK: - Buttons, Chips, Badges

struct SandowButton: View {
    enum Variant: Equatable {
        case primary
        case secondary
        case ghost
        case destructive
        case compact
        case icon
    }

    enum Hierarchy: Equatable {
        case primary
        case secondary
        case tertiary
        case destructive
    }

    enum Size: Equatable {
        case regular
        case compact
        case text
    }

    var title: String?
    var icon: SandowIcon?
    var variant: Variant = .primary
    var isDisabled: Bool = false
    let action: () -> Void

    init(
        _ title: String,
        icon: SandowIcon? = nil,
        variant: Variant = .primary,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = variant
        self.isDisabled = isDisabled
        self.action = action
    }

    init(
        title: String,
        icon: SandowIcon? = nil,
        hierarchy: Hierarchy = .primary,
        size: Size = .regular,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.variant = Self.variant(hierarchy: hierarchy, size: size)
        self.isDisabled = isDisabled
        self.action = action
    }

    init(
        icon: SandowIcon,
        variant: Variant = .icon,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = nil
        self.icon = icon
        self.variant = variant
        self.isDisabled = isDisabled
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: title == nil ? 0 : SandowSpacing.sm) {
                if let icon {
                    SandowIconView(icon, size: iconSize, tint: foregroundColor)
                }

                if let title {
                    Text(title)
                        .font(font)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: maxWidth)
            .frame(width: fixedWidth, height: buttonHeight)
            .padding(.horizontal, horizontalPadding)
            .background(backgroundColor, in: .rect(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            )
            .shadow(
                color: variant == .primary ? SandowColors.orangePrimary.opacity(0.20) : SandowEffects.subtleShadow.color,
                radius: variant == .primary ? 12 : 4,
                x: 0,
                y: variant == .primary ? 6 : 2
            )
            .opacity(isDisabled ? 0.44 : 1)
        }
        .buttonStyle(.strqPressable)
        .disabled(isDisabled)
    }

    private static func variant(hierarchy: Hierarchy, size: Size) -> Variant {
        if size == .compact {
            return .compact
        }

        switch hierarchy {
        case .primary:
            return .primary
        case .secondary:
            return .secondary
        case .tertiary:
            return size == .text ? .ghost : .ghost
        case .destructive:
            return .destructive
        }
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary, .compact:
            return SandowColors.textOnBrand
        case .secondary:
            return SandowColors.brandTextPrimary
        case .ghost, .icon:
            return SandowColors.textPrimary
        case .destructive:
            return SandowColors.white
        }
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary, .compact:
            return SandowColors.orangePrimary
        case .secondary:
            return SandowColors.orangeDim
        case .ghost, .icon:
            return SandowColors.surfaceSecondary
        case .destructive:
            return SandowColors.dangerRed
        }
    }

    private var borderColor: Color {
        switch variant {
        case .primary, .compact, .destructive:
            return .clear
        case .secondary:
            return SandowColors.orangeSoft
        case .ghost, .icon:
            return SandowColors.borderMuted
        }
    }

    private var borderWidth: CGFloat {
        switch variant {
        case .primary, .compact, .destructive:
            return 0
        case .secondary, .ghost, .icon:
            return 1
        }
    }

    private var buttonHeight: CGFloat {
        switch variant {
        case .compact:
            return SandowSpacing.buttonCompactHeight
        case .icon:
            return SandowSpacing.iconButtonSize
        case .primary, .secondary, .ghost, .destructive:
            return SandowSpacing.buttonHeight
        }
    }

    private var fixedWidth: CGFloat? {
        variant == .icon ? SandowSpacing.iconButtonSize : nil
    }

    private var maxWidth: CGFloat? {
        switch variant {
        case .icon, .ghost:
            return nil
        case .primary, .secondary, .destructive, .compact:
            return .infinity
        }
    }

    private var horizontalPadding: CGFloat {
        switch variant {
        case .compact:
            return SandowSpacing.md
        case .icon:
            return 0
        case .ghost:
            return SandowSpacing.sm
        case .primary, .secondary, .destructive:
            return SandowSpacing.xl
        }
    }

    private var radius: CGFloat {
        variant == .icon ? SandowRadii.iconContainer : SandowRadii.button
    }

    private var iconSize: CGFloat {
        variant == .icon ? SandowSpacing.iconSM : SandowSpacing.iconMD
    }

    private var font: Font {
        variant == .compact ? SandowTypography.buttonCompact : SandowTypography.button
    }
}

struct SandowChip: View {
    enum Tone: Equatable {
        case neutral
        case selected
        case orange
        case brand
        case brandSoft
        case success
        case warning
        case danger
        case disabled

        var componentTone: SandowComponentStyle.Tone {
            switch self {
            case .neutral:
                return .neutral
            case .selected:
                return .selected
            case .orange, .brand, .brandSoft:
                return .orange
            case .success:
                return .success
            case .warning:
                return .warning
            case .danger:
                return .danger
            case .disabled:
                return .disabled
            }
        }
    }

    enum Size: Equatable {
        case compact
        case regular
        case large
    }

    let label: String
    var icon: SandowIcon?
    var tone: Tone = .neutral
    var size: Size = .regular

    var body: some View {
        HStack(spacing: SandowSpacing.chipGap) {
            if let icon {
                SandowIconView(icon, size: iconSize, tint: foregroundColor)
            }

            Text(label)
                .font(font)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .frame(minHeight: minHeight)
        .background(backgroundColor, in: .rect(cornerRadius: SandowRadii.chip))
        .overlay(
            RoundedRectangle(cornerRadius: SandowRadii.chip, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 1)
        )
        .opacity(tone == .disabled ? 0.58 : 1)
    }

    private var foregroundColor: Color { tone.componentTone.foreground }
    private var backgroundColor: Color { tone.componentTone.background }
    private var borderColor: Color { tone.componentTone.border }

    private var font: Font {
        switch size {
        case .compact:
            return SandowTypography.chipSmall
        case .regular, .large:
            return SandowTypography.chip
        }
    }

    private var iconSize: CGFloat {
        switch size {
        case .compact:
            return SandowSpacing.iconXS
        case .regular:
            return SandowSpacing.iconSM
        case .large:
            return SandowSpacing.iconMD
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .compact:
            return SandowSpacing.xs
        case .regular:
            return SandowSpacing.chipHorizontalPadding
        case .large:
            return SandowSpacing.md
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .compact:
            return 2
        case .regular:
            return SandowSpacing.chipVerticalPadding
        case .large:
            return SandowSpacing.xs
        }
    }

    private var minHeight: CGFloat {
        switch size {
        case .compact:
            return 24
        case .regular:
            return 32
        case .large:
            return 40
        }
    }
}

struct SandowBadge: View {
    enum Variant: Equatable {
        case small
        case achievement
        case count
        case status
    }

    var text: String
    var icon: SandowIcon?
    var variant: Variant = .small
    var tone: SandowChip.Tone = .neutral

    var body: some View {
        HStack(spacing: SandowSpacing.chipGap) {
            if let icon {
                SandowIconView(icon, size: iconSize, tint: tone.componentTone.foreground)
            }

            Text(text)
                .font(font)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .foregroundStyle(tone.componentTone.foreground)
        .padding(.horizontal, horizontalPadding)
        .frame(minWidth: variant == .count ? minHeight : nil, minHeight: minHeight)
        .background(tone.componentTone.background, in: .rect(cornerRadius: SandowRadii.full))
        .overlay(
            Capsule()
                .strokeBorder(tone.componentTone.border, lineWidth: 1)
        )
    }

    private var font: Font {
        switch variant {
        case .small, .count:
            return SandowTypography.labelSmall
        case .achievement, .status:
            return SandowTypography.label
        }
    }

    private var minHeight: CGFloat {
        switch variant {
        case .small, .count:
            return 22
        case .status:
            return 28
        case .achievement:
            return 34
        }
    }

    private var horizontalPadding: CGFloat {
        variant == .count ? SandowSpacing.xs : SandowSpacing.sm
    }

    private var iconSize: CGFloat {
        variant == .achievement ? SandowSpacing.iconSM : SandowSpacing.iconXS
    }
}

// MARK: - Metrics & Progress

struct SandowMetricCard: View {
    let value: String
    let label: String
    var icon: SandowIcon?
    var unit: String?
    var detail: String?
    var progress: Double?
    var selected: Bool = false
    var active: Bool = false
    var tint: Color = SandowColors.orangePrimary
    var valueFont: Font = SandowTypography.metricMedium
    var iconBackground: Color? = nil
    var minHeight: CGFloat = SandowSpacing.metricCardMinHeight

    var body: some View {
        SandowSurface(
            selected: selected || active,
            padding: SandowSpacing.md,
            radius: SandowRadii.metricCard,
            background: active ? SandowColors.selectedSurface : SandowColors.cardSurface
        ) {
            VStack(alignment: .leading, spacing: SandowSpacing.sm) {
                if let icon {
                    SandowIconContainer(icon: icon, size: .lg, tint: tint, background: iconBackground)
                }

                VStack(alignment: .leading, spacing: SandowSpacing.xxs) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(value)
                            .font(valueFont)
                            .foregroundStyle(SandowColors.primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        if let unit {
                            Text(unit)
                                .font(SandowTypography.bodySmallMedium)
                                .foregroundStyle(SandowColors.secondaryText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    }

                    Text(label)
                        .font(SandowTypography.caption)
                        .foregroundStyle(SandowColors.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }

                if let detail {
                    Text(detail)
                        .font(SandowTypography.captionRegular)
                        .foregroundStyle(SandowColors.mutedText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                }

                if let progress {
                    SandowProgressBar(value: progress, height: 6, tint: tint, compact: true)
                }
            }
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
        }
    }
}

struct SandowProgressBar: View {
    var value: Double
    var height: CGFloat = 8
    var tint: Color = SandowColors.orangePrimary
    var label: String? = nil
    var valueText: String? = nil
    var compact: Bool = false
    var trackColor: Color = SandowColors.surfaceTertiary

    var body: some View {
        VStack(alignment: .leading, spacing: SandowSpacing.xs) {
            if label != nil || valueText != nil {
                HStack(spacing: SandowSpacing.sm) {
                    if let label {
                        Text(label)
                            .font(SandowTypography.bodySmallMedium)
                            .foregroundStyle(SandowColors.primaryText)
                            .lineLimit(1)
                    }

                    Spacer(minLength: SandowSpacing.xs)

                    if let valueText {
                        Text(valueText)
                            .font(SandowTypography.labelSmall)
                            .foregroundStyle(SandowColors.secondaryText)
                            .lineLimit(1)
                    }
                }
            }

            GeometryReader { proxy in
                let clamped = min(max(value, 0), 1)
                let width = proxy.size.width * CGFloat(clamped)

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(trackColor)

                    if clamped > 0 {
                        Capsule()
                            .fill(tint)
                            .overlay(SandowGradients.subtleOverlay.clipShape(Capsule()))
                            .frame(width: width)
                    }
                }
            }
            .frame(height: compact ? max(4, height) : height)
            .clipShape(Capsule())
        }
    }
}

struct SandowProgressRing: View {
    enum Variant: Equatable {
        case compact
        case score
        case activity
    }

    var value: Double
    var variant: Variant = .compact
    var size: CGFloat? = nil
    var lineWidth: CGFloat? = nil
    var tint: Color = SandowColors.orangePrimary
    var label: String? = nil
    var valueText: String? = nil

    var body: some View {
        ZStack {
            Circle()
                .stroke(SandowColors.surfaceTertiary, lineWidth: resolvedLineWidth)

            Circle()
                .trim(from: 0, to: min(max(value, 0), 1))
                .stroke(
                    tint,
                    style: StrokeStyle(lineWidth: resolvedLineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .overlay(SandowGradients.subtleOverlay.clipShape(Circle()))

            if valueText != nil || label != nil {
                VStack(spacing: 0) {
                    if let valueText {
                        Text(valueText)
                            .font(valueFont)
                            .foregroundStyle(SandowColors.primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)
                    }

                    if let label {
                        Text(label)
                            .font(SandowTypography.micro)
                            .foregroundStyle(SandowColors.mutedText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)
                    }
                }
                .padding(SandowSpacing.xs)
            }
        }
        .frame(width: resolvedSize, height: resolvedSize)
    }

    private var resolvedSize: CGFloat {
        if let size {
            return size
        }

        switch variant {
        case .compact:
            return 44
        case .score:
            return 96
        case .activity:
            return 120
        }
    }

    private var resolvedLineWidth: CGFloat {
        if let lineWidth {
            return lineWidth
        }

        switch variant {
        case .compact:
            return 5
        case .score:
            return 8
        case .activity:
            return 10
        }
    }

    private var valueFont: Font {
        variant == .compact ? SandowTypography.labelSmall : SandowTypography.metricSmall
    }
}

struct SandowProgressRow: View {
    let label: String
    let value: String
    var detail: String?
    var icon: SandowIcon? = .recovery
    var progress: Double
    var tint: Color = SandowColors.orangePrimary
    var boxed: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: SandowSpacing.sm) {
            HStack(spacing: SandowSpacing.sm) {
                if let icon {
                    SandowIconContainer(icon: icon, size: .md, tint: tint)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(SandowTypography.bodySmallMedium)
                        .foregroundStyle(SandowColors.primaryText)
                        .lineLimit(1)

                    if let detail {
                        Text(detail)
                            .font(SandowTypography.caption)
                            .foregroundStyle(SandowColors.mutedText)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: SandowSpacing.xs)

                Text(value)
                    .font(SandowTypography.label)
                    .foregroundStyle(SandowColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }

            SandowProgressBar(value: progress, height: 8, tint: tint, compact: true)
        }
        .padding(boxed ? SandowSpacing.sm : 0)
        .background(boxed ? SandowColors.surfacePrimary : Color.clear, in: .rect(cornerRadius: SandowRadii.lg))
        .overlay {
            if boxed {
                RoundedRectangle(cornerRadius: SandowRadii.lg, style: .continuous)
                    .strokeBorder(SandowColors.borderMuted, lineWidth: 1)
            }
        }
    }
}

// MARK: - List Items & Section Headers

struct SandowListItem: View {
    var leadingIcon: SandowIcon?
    var avatarText: String?
    var title: String
    var subtitle: String?
    var trailingValue: String?
    var showsChevron: Bool = false
    var showsDivider: Bool = true
    var tint: Color = SandowColors.orangePrimary

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: SandowSpacing.sm) {
                leadingView

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(SandowTypography.bodyMedium)
                        .foregroundStyle(SandowColors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    if let subtitle {
                        Text(subtitle)
                            .font(SandowTypography.captionRegular)
                            .foregroundStyle(SandowColors.mutedText)
                            .lineLimit(2)
                    }
                }

                Spacer(minLength: SandowSpacing.sm)

                if let trailingValue {
                    Text(trailingValue)
                        .font(SandowTypography.label)
                        .foregroundStyle(SandowColors.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }

                if showsChevron {
                    SandowIconView(.chevronRight, size: SandowSpacing.iconSM, tint: SandowColors.mutedText)
                }
            }
            .padding(.vertical, SandowSpacing.sm)
            .padding(.horizontal, SandowSpacing.listItemPadding)

            if showsDivider {
                Rectangle()
                    .fill(SandowColors.divider)
                    .frame(height: 1)
                    .padding(.leading, leadingIndent)
            }
        }
    }

    @ViewBuilder
    private var leadingView: some View {
        if let leadingIcon {
            SandowIconContainer(icon: leadingIcon, size: .md, tint: tint)
        } else if let avatarText {
            Text(avatarText.prefix(2).uppercased())
                .font(SandowTypography.labelSmall)
                .foregroundStyle(SandowColors.textOnBrand)
                .frame(width: SandowSpacing.iconContainerMD, height: SandowSpacing.iconContainerMD)
                .background(tint, in: Circle())
        }
    }

    private var leadingIndent: CGFloat {
        (leadingIcon == nil && avatarText == nil) ? SandowSpacing.listItemPadding : 68
    }
}

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
                .font(SandowTypography.cardTitle)
                .foregroundStyle(SandowColors.primaryText)
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

struct SandowSectionAction: View {
    var title: String = "See All"
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SandowSpacing.xxs) {
                Text(title)
                    .font(SandowTypography.labelSmall)
                SandowIconView(.arrowRight, size: SandowSpacing.iconXS, tint: SandowColors.orangePrimary)
            }
            .foregroundStyle(SandowColors.orangePrimary)
        }
        .buttonStyle(.strqPressable)
    }
}

// MARK: - Tab Bar Primitives

struct SandowTabBarItem: View {
    let title: String
    let icon: SandowIcon
    var isSelected: Bool

    var body: some View {
        VStack(spacing: SandowSpacing.xxs) {
            SandowIconView(
                icon,
                size: SandowSpacing.iconMD,
                tint: isSelected ? SandowColors.orangePrimary : SandowColors.mutedText
            )

            Text(title)
                .font(isSelected ? SandowTypography.tabLabel.weight(.semibold) : SandowTypography.tabLabel)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(isSelected ? SandowColors.orangePrimary : SandowColors.mutedText)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 56)
        .padding(.vertical, SandowSpacing.xxs)
        .background(
            isSelected ? SandowColors.orangeDim.opacity(0.38) : Color.clear,
            in: .rect(cornerRadius: SandowRadii.tabItem)
        )
    }
}

struct SandowTabBarCenterAction: View {
    var icon: SandowIcon = .plus
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            SandowIconView(icon, size: SandowSpacing.iconMD, tint: SandowColors.textOnBrand)
                .frame(width: 56, height: 56)
                .background(SandowGradients.orangeCTA, in: Circle())
                .shadow(
                    color: SandowEffects.orangeGlow.color,
                    radius: SandowEffects.orangeGlow.radius,
                    x: 0,
                    y: SandowEffects.orangeGlow.y
                )
        }
        .buttonStyle(.strqPressable)
    }
}

struct SandowTabBar<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack(alignment: .center, spacing: SandowSpacing.xs) {
            content
        }
        .padding(.horizontal, SandowSpacing.sm)
        .frame(minHeight: SandowSpacing.tabBarHeight)
        .background(SandowEffects.darkGlassBackground, in: .rect(cornerRadius: SandowRadii.tabbar))
        .overlay(
            RoundedRectangle(cornerRadius: SandowRadii.tabbar, style: .continuous)
                .strokeBorder(SandowEffects.darkGlassStroke, lineWidth: 1)
        )
        .shadow(
            color: SandowEffects.cardShadow.color,
            radius: SandowEffects.cardShadow.radius,
            x: SandowEffects.cardShadow.x,
            y: SandowEffects.cardShadow.y
        )
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

// MARK: - Schedule Primitives

struct SandowScheduleRow: View {
    var dateTitle: String
    var dateSubtitle: String?
    var title: String
    var subtitle: String?
    var duration: String?
    var icon: SandowIcon? = .calendar
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: SandowSpacing.sm) {
            VStack(spacing: 2) {
                Text(dateTitle)
                    .font(SandowTypography.label)
                    .foregroundStyle(isSelected ? SandowColors.textOnBrand : SandowColors.primaryText)
                    .lineLimit(1)

                if let dateSubtitle {
                    Text(dateSubtitle)
                        .font(SandowTypography.micro)
                        .foregroundStyle(isSelected ? SandowColors.textOnBrand.opacity(0.74) : SandowColors.mutedText)
                        .lineLimit(1)
                }
            }
            .frame(width: 48, height: 48)
            .background(isSelected ? SandowColors.orangePrimary : SandowColors.surfaceSecondary, in: .rect(cornerRadius: SandowRadii.md))

            if let icon {
                SandowIconContainer(icon: icon, size: .md, tint: isSelected ? SandowColors.orangePrimary : SandowColors.mutedText)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(SandowTypography.bodyMedium)
                    .foregroundStyle(SandowColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                if let subtitle {
                    Text(subtitle)
                        .font(SandowTypography.captionRegular)
                        .foregroundStyle(SandowColors.mutedText)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: SandowSpacing.sm)

            if let duration {
                Text(duration)
                    .font(SandowTypography.labelSmall)
                    .foregroundStyle(SandowColors.secondaryText)
                    .lineLimit(1)
            }
        }
        .padding(SandowSpacing.sm)
        .background(SandowColors.cardSurface, in: .rect(cornerRadius: SandowRadii.lg))
        .overlay(
            RoundedRectangle(cornerRadius: SandowRadii.lg, style: .continuous)
                .strokeBorder(isSelected ? SandowColors.selectedBorder : SandowColors.borderMuted, lineWidth: 1)
        )
    }
}

struct SandowScheduleCard: View {
    var title: String
    var subtitle: String?
    var rows: [SandowScheduleRow]

    var body: some View {
        SandowCard {
            VStack(alignment: .leading, spacing: SandowSpacing.sm) {
                SandowSectionHeader(title) {
                    if let subtitle {
                        Text(subtitle)
                            .font(SandowTypography.caption)
                            .foregroundStyle(SandowColors.mutedText)
                            .lineLimit(1)
                    }
                }

                VStack(spacing: SandowSpacing.xs) {
                    ForEach(Array(rows.enumerated()), id: \.offset) { item in
                        item.element
                    }
                }
            }
        }
    }
}

// MARK: - Debug Previews

#if DEBUG
struct SandowFoundationPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SandowSpacing.sectionGap) {
                SandowSectionHeader("Foundation") {
                    SandowChip(label: "Sandow", icon: .checkCircle, tone: .success)
                }

                HStack(spacing: SandowSpacing.xs) {
                    SandowMetricCard(
                        value: "88",
                        label: "Recovery",
                        icon: .recovery,
                        unit: "%",
                        progress: 0.88,
                        tint: SandowColors.successGreen
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

                SandowButton("Start", icon: .barbell) {}
            }
            .padding(SandowSpacing.screenHorizontalMargin)
        }
        .background(SandowColors.background)
    }
}

struct SandowComponentsPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: SandowSpacing.sectionGap) {
            HStack(spacing: SandowSpacing.xs) {
                SandowChip(label: "Neutral")
                SandowChip(label: "Active", icon: .check, tone: .orange)
                SandowBadge(text: "7", variant: .count, tone: .warning)
            }

            SandowProgressRing(
                value: 0.82,
                variant: .score,
                tint: SandowColors.orangePrimary,
                label: "Score",
                valueText: "82"
            )

            SandowListItem(
                leadingIcon: .trophy,
                title: "Strength Goal",
                subtitle: "Four week progression",
                trailingValue: "68%",
                showsChevron: true
            )

            SandowScheduleRow(
                dateTitle: "29",
                dateSubtitle: "WED",
                title: "Upper Strength",
                subtitle: "Push and pull",
                duration: "45m",
                icon: .barbell,
                isSelected: true
            )

            SandowTabBar {
                SandowTabBarItem(title: "Home", icon: .home, isSelected: true)
                SandowTabBarItem(title: "Train", icon: .train, isSelected: false)
                SandowTabBarCenterAction {}
                SandowTabBarItem(title: "Progress", icon: .progress, isSelected: false)
                SandowTabBarItem(title: "Profile", icon: .profile, isSelected: false)
            }
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
