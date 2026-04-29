import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/*
 STRQ Design System Foundation

 Use this file for STRQ UI primitives, previews, and future screen-by-screen
 migrations. It is STRQ's isolated design-system foundation layer and should
 not override STRQPalette or change existing production screens.

 Do not import large demo/media assets into the app repository.

 Adding icons:
 1. Export a STRQ regular-style icon as template SVG or vector PDF.
 2. Add it as ios/STRQ/Assets.xcassets/STRQIcon<Name>.imageset.
 3. Set preserves-vector-representation and template-rendering-intent.
 4. Add a matching STRQIcon case whose raw value is the asset name.
 5. Render with STRQIconView(.caseName, size:tint:templateRendering:).

 Future migrations should replace one contained surface at a time, using these
 components explicitly. Existing dashboard, workout, paywall, onboarding, and
 analytics flows should remain untouched until a dedicated migration pass.
 */

// MARK: - STRQ Design System

enum STRQDesignSystem {
    static let sourceFontFamily = "Work Sans"
    static let fontFamily = sourceFontFamily
    static let workSansFontFilesBundled = false
    static let workSansRegularFontName = "WorkSans-Regular"
    static let workSansMediumFontName = "WorkSans-Medium"
    static let workSansSemiBoldFontName = "WorkSans-SemiBold"
    static let workSansBoldFontName = "WorkSans-Bold"
    static let iconAssetPrefix = "STRQIcon"
}

// MARK: - Color Tokens

enum STRQColors {
    // Primitive neutrals.
    static let black = Color(strqHex: 0x000000)
    static let white = Color(strqHex: 0xFFFFFF)
    static let gray50 = Color(strqHex: 0xFAFAFA)
    static let gray100 = Color(strqHex: 0xF4F4F5)
    static let gray200 = Color(strqHex: 0xE4E4E7)
    static let gray300 = Color(strqHex: 0xD4D4D8)
    static let gray400 = Color(strqHex: 0xA1A1AA)
    static let gray500 = Color(strqHex: 0x71717A)
    static let gray600 = Color(strqHex: 0x52525B)
    static let gray700 = Color(strqHex: 0x3F3F46)
    static let gray800 = Color(strqHex: 0x27272A)
    static let gray900 = Color(strqHex: 0x18181B)
    static let gray950 = Color(strqHex: 0x09090B)

    // Primitive orange / brand scale.
    static let orange50 = Color(strqHex: 0xFFF7ED)
    static let orange100 = Color(strqHex: 0xFFEDD5)
    static let orange200 = Color(strqHex: 0xFED7AA)
    static let orange300 = Color(strqHex: 0xFDBA74)
    static let orange400 = Color(strqHex: 0xFB923C)
    static let orange500 = Color(strqHex: 0xF97316)
    static let orange600 = Color(strqHex: 0xEA580C)
    static let orange700 = Color(strqHex: 0xC2410C)
    static let orange800 = Color(strqHex: 0x9A3412)
    static let orange900 = Color(strqHex: 0x7C2D12)
    static let orange950 = Color(strqHex: 0x431407)

    // Primitive semantic accents present in STRQ.
    static let blue500 = Color(strqHex: 0x3B82F6)
    static let purple500 = Color(strqHex: 0xA855F7)
    static let lime500 = Color(strqHex: 0x84CC16)
    static let amber500 = Color(strqHex: 0xF59E0B)
    static let rose500 = Color(strqHex: 0xF43F5E)

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
    static let selectedSurface = gray800

    // STRQ-owned monochrome accent roles.
    static let primaryAccent = white
    static let primaryAccentText = black
    static let secondaryAccent = gray300
    static let subtleAccent = gray500
    static let actionSurface = white
    static let actionText = black
    static let focusGlow = white.opacity(0.22)
    static let iconPrimary = white
    static let iconSecondary = gray400
    static let iconMuted = gray600

    // Dark-mode text foundation.
    static let primaryText = white
    static let secondaryText = gray300
    static let mutedText = gray500
    static let disabledText = gray700
    static let subtleText = gray600
    static let textOnBrand = primaryAccentText
    static let textOnInverse = black

    // Dark-mode borders and dividers.
    static let borderPrimary = gray400
    static let borderSecondary = gray500
    static let borderTertiary = gray600
    static let borderMuted = gray700
    static let divider = gray700
    static let selectedBorder = gray300

    // Legacy warm/source-kit scale. Keep explicit; do not use as default STRQ brand.
    static let warmAccent = orange500
    static let warmAccentHover = orange400
    static let warmAccentPressed = orange600
    static let warmAccentSoft = orange800
    static let warmAccentSofter = orange900
    static let warmAccentDim = orange950
    static let warmAccentTextPrimary = orange200
    static let warmAccentTextSecondary = orange500
    static let warmAccentTextTertiary = orange700

    // Backwards-compatible orange aliases from the first foundation pass.
    static let orangePrimary = warmAccent
    static let orangeHover = warmAccentHover
    static let orangePressed = warmAccentPressed
    static let orangeSoft = warmAccentSoft
    static let orangeSofter = warmAccentSofter
    static let orangeDim = warmAccentDim
    static let brandTextPrimary = warmAccentTextPrimary
    static let brandTextSecondary = warmAccentTextSecondary
    static let brandTextTertiary = warmAccentTextTertiary

    // Status semantics.
    static let successGreen = lime500
    static let success = lime500
    static let successSoft = Color(strqHex: 0x3F6212)
    static let successDim = Color(strqHex: 0x1A2E05)
    static let successTextPrimary = Color(strqHex: 0xD9F99D)
    static let successTextSecondary = lime500
    static let successTextTertiary = Color(strqHex: 0x4D7C0F)

    static let warningAmber = amber500
    static let warning = amber500
    static let warningSoft = Color(strqHex: 0x92400E)
    static let warningDim = Color(strqHex: 0x451A03)
    static let warningTextPrimary = Color(strqHex: 0xFDE68A)
    static let warningTextSecondary = amber500
    static let warningTextTertiary = Color(strqHex: 0xB45309)

    static let dangerRed = rose500
    static let danger = rose500
    static let dangerSoft = Color(strqHex: 0x9F1239)
    static let dangerDim = Color(strqHex: 0x4C0519)
    static let dangerTextPrimary = Color(strqHex: 0xFECDD3)
    static let dangerTextSecondary = rose500
    static let dangerTextTertiary = Color(strqHex: 0xBE123C)

    static let blue = blue500
    static let blueSoft = Color(strqHex: 0x172554)
    static let purple = purple500
    static let gold = Color(strqHex: 0xFACC15)

    // Backwards-compatible aliases from the first STRQ foundation pass.
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

enum STRQGradients {
    static let primaryAction = LinearGradient(
        colors: [STRQColors.white, STRQColors.gray100, STRQColors.gray300],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let progressNeutral = LinearGradient(
        colors: [STRQColors.gray300, STRQColors.white],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let orangeCTA = LinearGradient(
        colors: [STRQColors.orange400, STRQColors.orange500, STRQColors.orange600],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let orangeGlow = RadialGradient(
        colors: [STRQColors.orangePrimary.opacity(0.34), STRQColors.orangeDim.opacity(0)],
        center: .center,
        startRadius: 0,
        endRadius: 120
    )

    static let darkCard = LinearGradient(
        colors: [STRQColors.gray800, STRQColors.gray900],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let insetCard = LinearGradient(
        colors: [STRQColors.gray950, STRQColors.gray900],
        startPoint: .top,
        endPoint: .bottom
    )

    static let subtleOverlay = LinearGradient(
        colors: [STRQColors.white.opacity(0.08), STRQColors.white.opacity(0)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let progressOrange = LinearGradient(
        colors: [STRQColors.orange400, STRQColors.orangePrimary],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let progressSuccess = LinearGradient(
        colors: [STRQColors.successTextPrimary, STRQColors.successGreen],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let progressWarning = LinearGradient(
        colors: [STRQColors.warningTextPrimary, STRQColors.warningAmber],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let progressDanger = LinearGradient(
        colors: [STRQColors.dangerTextPrimary, STRQColors.dangerRed],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Typography Tokens

enum STRQTypography {
    static let fontFamily = STRQDesignSystem.fontFamily
    static let sourceFontFamily = STRQDesignSystem.sourceFontFamily
    static var runtimeFontFamily: String? {
        isWorkSansActive ? fontFamily : nil
    }

    static var isWorkSansActive: Bool {
        workSansFontName(for: .regular) != nil
    }

    static var fontStatusText: String {
        isWorkSansActive ? "Work Sans active" : "Work Sans not bundled — using system fallback"
    }

    static let displayLarge = headingFont(size: 180, weight: .bold)
    static let displayMedium = headingFont(size: 128, weight: .bold)
    static let displaySmall = headingFont(size: 96, weight: .bold)

    static let heading2XL = headingFont(size: 72, weight: .bold)
    static let headingXL = headingFont(size: 60, weight: .bold)
    static let headingLarge = headingFont(size: 48, weight: .bold)
    static let headingMedium = headingFont(size: 36, weight: .bold)
    static let headingSmall = headingFont(size: 30, weight: .bold)
    static let headingXS = headingFont(size: 24, weight: .bold)

    static let text2XL = textFont(size: 24, weight: .medium)
    static let textXL = textFont(size: 20, weight: .medium)
    static let textLarge = textFont(size: 18, weight: .medium)
    static let textMedium = textFont(size: 16, weight: .medium)
    static let textSmall = textFont(size: 14, weight: .medium)
    static let textXS = textFont(size: 12, weight: .medium)
    static let text2XS = textFont(size: 10, weight: .medium)

    static let paragraph2XL = textFont(size: 24, weight: .regular)
    static let paragraphXL = textFont(size: 20, weight: .regular)
    static let paragraphLarge = textFont(size: 18, weight: .regular)
    static let paragraphMedium = textFont(size: 16, weight: .regular)
    static let paragraphSmall = textFont(size: 14, weight: .regular)
    static let paragraphXS = textFont(size: 12, weight: .regular)

    static let label2XL = labelFont(size: 20, weight: .bold)
    static let labelXL = labelFont(size: 18, weight: .bold)
    static let labelLarge = labelFont(size: 16, weight: .bold)
    static let labelMedium = labelFont(size: 14, weight: .bold)
    static let labelSmall = labelFont(size: 12, weight: .bold)
    static let labelXS = labelFont(size: 10, weight: .bold)

    // STRQ-owned role preset: stronger hierarchy without inflating UI scale.
    static let appTitle = headingSmall
    static let screenTitle = headingXS
    static let sectionTitle = headingFont(size: 18, weight: .bold)
    static let cardTitle = headingFont(size: 18, weight: .bold)
    static let metricLarge = metricFont(size: 40, weight: .heavy)
    static let metricMedium = metricFont(size: 30, weight: .bold)
    static let metricSmall = metricFont(size: 20, weight: .bold)

    static let title = screenTitle
    static let bodyXLarge = paragraphXL
    static let bodyLarge = paragraphLarge
    static let body = paragraphMedium
    static let bodyMedium = textMedium
    static let bodySmall = paragraphSmall
    static let bodySmallMedium = textSmall

    static let button = labelFont(size: 18, weight: .bold)
    static let buttonCompact = labelFont(size: 14, weight: .bold)
    static let chip = labelFont(size: 14, weight: .semibold)
    static let chipSmall = labelFont(size: 12, weight: .semibold)
    static let tabLabel = labelFont(size: 12, weight: .semibold)
    static let caption = textXS
    static let captionRegular = paragraphXS
    static let micro = text2XS

    static let label = labelMedium

    // Backwards-compatible aliases from the first STRQ foundation pass.
    static let heading = cardTitle
    static let largeValue = title.monospacedDigit()
    static let metricNumber = metricMedium
    static let metricCompactNumber = metricSmall
    static let bodyRegular = bodySmall

    static let displayLargeLineHeight: CGFloat = 188
    static let displayMediumLineHeight: CGFloat = 136
    static let displaySmallLineHeight: CGFloat = 104
    static let heading2XLLineHeight: CGFloat = 80
    static let headingXLLineHeight: CGFloat = 68
    static let headingLargeLineHeight: CGFloat = 56
    static let headingMediumLineHeight: CGFloat = 44
    static let headingSmallLineHeight: CGFloat = 38
    static let headingXSLineHeight: CGFloat = 32

    static let text2XLLineHeight: CGFloat = 32
    static let textXLLineHeight: CGFloat = 28
    static let textLargeLineHeight: CGFloat = 24
    static let textMediumLineHeight: CGFloat = 22
    static let textSmallLineHeight: CGFloat = 20
    static let textXSLineHeight: CGFloat = 16
    static let text2XSLineHeight: CGFloat = 14

    static let paragraph2XLLineHeight: CGFloat = 38
    static let paragraphXLLineHeight: CGFloat = 32
    static let paragraphLargeLineHeight: CGFloat = 28
    static let paragraphMediumLineHeight: CGFloat = 26
    static let paragraphSmallLineHeight: CGFloat = 22
    static let paragraphXSLineHeight: CGFloat = 20

    static let label2XLLineHeight: CGFloat = 28
    static let labelXLLineHeight: CGFloat = 24
    static let labelLargeLineHeight: CGFloat = 22
    static let labelMediumLineHeight: CGFloat = 20
    static let labelSmallLineHeight: CGFloat = 16
    static let labelXSLineHeight: CGFloat = 14

    static let titleLineHeight: CGFloat = headingXSLineHeight
    static let bodyLineHeight: CGFloat = 26
    static let bodySmallLineHeight: CGFloat = 22
    static let captionLineHeight: CGFloat = 16

    static let displayLargeTracking: CGFloat = -8
    static let displayMediumTracking: CGFloat = -4
    static let displaySmallTracking: CGFloat = -2
    static let heading2XLTracking: CGFloat = -1.5
    static let headingXLTracking: CGFloat = -1
    static let headingLargeTracking: CGFloat = -0.75
    static let headingMediumTracking: CGFloat = -0.5
    static let headingSmallTracking: CGFloat = -0.25
    static let headingXSTracking: CGFloat = -0.25
    static let text2XLTracking: CGFloat = -0.25
    static let textXLTracking: CGFloat = -0.25
    static let bodyTracking: CGFloat = 0
    static let label2XLTracking: CGFloat = 2
    static let labelXLTracking: CGFloat = 2
    static let labelLargeTracking: CGFloat = 1.5
    static let labelMediumTracking: CGFloat = 1.5
    static let labelSmallTracking: CGFloat = 1
    static let labelXSTracking: CGFloat = 1
    static let headingTracking: CGFloat = headingMediumTracking
    static let labelTracking: CGFloat = 0.8
    static let labelUppercaseTracking: CGFloat = labelMediumTracking
    static let buttonTracking: CGFloat = 0
    static let chipTracking: CGFloat = 0.1
    static let tabTracking: CGFloat = 0

    static func font(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        configuredFont(size: size, weight: weight, fallbackDesign: .default, fallbackWeight: safeFallbackWeight(weight))
    }

    static func headingFont(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        configuredFont(size: size, weight: weight, fallbackDesign: .rounded, fallbackWeight: emphasizedFallbackWeight(weight))
    }

    static func textFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        configuredFont(size: size, weight: weight, fallbackDesign: .default, fallbackWeight: safeFallbackWeight(weight))
    }

    static func labelFont(size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        configuredFont(size: size, weight: weight, fallbackDesign: .rounded, fallbackWeight: emphasizedFallbackWeight(weight))
    }

    static func metricFont(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        configuredFont(size: size, weight: weight, fallbackDesign: .rounded, fallbackWeight: emphasizedFallbackWeight(weight))
            .monospacedDigit()
    }

    private static func configuredFont(
        size: CGFloat,
        weight: Font.Weight,
        fallbackDesign: Font.Design,
        fallbackWeight: Font.Weight
    ) -> Font {
        if let workSansFontName = workSansFontName(for: weight) {
            return Font.custom(workSansFontName, size: size)
        }

        return Font.system(size: size, weight: fallbackWeight, design: fallbackDesign)
    }

    private static func workSansFontName(for weight: Font.Weight) -> String? {
        registeredFontName(from: workSansFontNameCandidates(for: weight))
    }

    private static func workSansFontNameCandidates(for weight: Font.Weight) -> [String] {
        let preferredName: String

        if weight == .medium {
            preferredName = STRQDesignSystem.workSansMediumFontName
        } else if weight == .semibold {
            preferredName = STRQDesignSystem.workSansSemiBoldFontName
        } else if weight == .bold || weight == .heavy || weight == .black {
            preferredName = STRQDesignSystem.workSansBoldFontName
        } else {
            preferredName = STRQDesignSystem.workSansRegularFontName
        }

        return [
            preferredName,
            STRQDesignSystem.fontFamily,
            "\(STRQDesignSystem.fontFamily) \(workSansStyleName(for: weight))"
        ]
    }

    private static func workSansStyleName(for weight: Font.Weight) -> String {
        if weight == .medium {
            return "Medium"
        } else if weight == .semibold {
            return "SemiBold"
        } else if weight == .bold || weight == .heavy || weight == .black {
            return "Bold"
        } else {
            return "Regular"
        }
    }

    private static func safeFallbackWeight(_ weight: Font.Weight) -> Font.Weight {
        if weight == .ultraLight || weight == .thin || weight == .light {
            return .regular
        }

        return weight
    }

    private static func emphasizedFallbackWeight(_ weight: Font.Weight) -> Font.Weight {
        if weight == .ultraLight || weight == .thin || weight == .light || weight == .regular {
            return .medium
        }

        return weight
    }

    private static func registeredFontName(from candidates: [String]) -> String? {
        #if canImport(UIKit)
        for candidate in candidates where UIFont(name: candidate, size: 12) != nil {
            return candidate
        }

        return nil
        #else
        return STRQDesignSystem.workSansFontFilesBundled ? candidates.first : nil
        #endif
    }
}

// MARK: - Spacing, Radii, Effects

enum STRQSpacing {
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
    static let inputHeight: CGFloat = 52
    static let searchHeight: CGFloat = 48
    static let toggleRowMinHeight: CGFloat = 56
    static let avatarSM: CGFloat = 32
    static let avatarMD: CGFloat = 40
    static let avatarLG: CGFloat = 56
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

enum STRQRadii {
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
    static let modal = xxl
    static let bottomSheet = xxl
}

struct STRQBorderToken {
    let color: Color
    let width: CGFloat
}

struct STRQShadowToken {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

enum STRQEffects {
    static let hairline: CGFloat = 1
    static let selectedBorderWidth: CGFloat = 1.5
    static let focusRingWidth: CGFloat = 4

    static let subtleCardBorder = STRQBorderToken(color: STRQColors.borderMuted, width: hairline)
    static let selectedCardBorder = STRQBorderToken(color: STRQColors.selectedBorder, width: selectedBorderWidth)
    static let dividerStyle = STRQBorderToken(color: STRQColors.divider, width: hairline)

    static let softShadow = STRQShadowToken(
        color: Color.black.opacity(0.20),
        radius: 24,
        x: 0,
        y: 12
    )

    static let cardShadow = STRQShadowToken(
        color: Color.black.opacity(0.12),
        radius: 16,
        x: 0,
        y: 8
    )

    static let subtleShadow = STRQShadowToken(
        color: Color.black.opacity(0.08),
        radius: 8,
        x: 0,
        y: 4
    )

    static let selectionGlow = STRQShadowToken(
        color: STRQColors.white.opacity(0.12),
        radius: 14,
        x: 0,
        y: 6
    )

    static let orangeGlow = STRQShadowToken(
        color: STRQColors.orangePrimary.opacity(0.30),
        radius: 18,
        x: 0,
        y: 8
    )

    static let backgroundBlurXS: CGFloat = 4
    static let backgroundBlurSM: CGFloat = 8
    static let backgroundBlurMD: CGFloat = 16
    static let backgroundBlurLG: CGFloat = 32
    static let backgroundBlurXL: CGFloat = 64

    static let darkGlassBackground = STRQColors.gray900.opacity(0.78)
    static let darkGlassStroke = STRQColors.white.opacity(0.08)

    // Backwards-compatible aliases from the first STRQ foundation pass.
    static let cardBorderWidth = hairline
    static let shadowColor = softShadow.color
    static let shadowRadius = softShadow.radius
    static let shadowYOffset = softShadow.y
    static let subtleShadowColor = subtleShadow.color
    static let subtleShadowRadius = subtleShadow.radius
    static let subtleShadowYOffset = subtleShadow.y
    static let focusGlowColor = STRQColors.focusGlow
}

enum STRQComponentStyle {
    enum SurfaceVariant: Equatable {
        case base
        case elevated
        case card
        case inset
        case selected

        var background: Color {
            switch self {
            case .base:
                return STRQColors.baseBackground
            case .elevated:
                return STRQColors.elevatedCardSurface
            case .card:
                return STRQColors.cardSurface
            case .inset:
                return STRQColors.insetSurface
            case .selected:
                return STRQColors.selectedSurface
            }
        }
    }

    enum BorderVariant: Equatable {
        case none
        case subtle
        case selected
        case brand
        case danger

        var token: STRQBorderToken {
            switch self {
            case .none:
                return STRQBorderToken(color: .clear, width: 0)
            case .subtle:
                return STRQEffects.subtleCardBorder
            case .selected:
                return STRQEffects.selectedCardBorder
            case .brand:
                return STRQBorderToken(color: STRQColors.primaryAccent, width: STRQEffects.hairline)
            case .danger:
                return STRQBorderToken(color: STRQColors.dangerRed, width: STRQEffects.hairline)
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
                return STRQRadii.card
            case .largeCard:
                return STRQRadii.largeCard
            case .metricCard:
                return STRQRadii.metricCard
            case .button:
                return STRQRadii.button
            case .chip:
                return STRQRadii.chip
            case .iconContainer:
                return STRQRadii.iconContainer
            case .tabbar:
                return STRQRadii.tabbar
            case .nav:
                return STRQRadii.nav
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
                return STRQColors.secondaryText
            case .selected:
                return STRQColors.primaryAccentText
            case .orange:
                return STRQColors.warmAccentTextPrimary
            case .success:
                return STRQColors.successTextPrimary
            case .warning:
                return STRQColors.warningTextPrimary
            case .danger:
                return STRQColors.dangerTextPrimary
            case .blue:
                return STRQColors.blue
            case .disabled:
                return STRQColors.disabledText
            }
        }

        var background: Color {
            switch self {
            case .neutral:
                return STRQColors.surfaceSecondary
            case .selected:
                return STRQColors.primaryAccent
            case .orange:
                return STRQColors.warmAccentDim
            case .success:
                return STRQColors.successDim
            case .warning:
                return STRQColors.warningDim
            case .danger:
                return STRQColors.dangerDim
            case .blue:
                return STRQColors.blueSoft
            case .disabled:
                return STRQColors.gray800
            }
        }

        var border: Color {
            switch self {
            case .neutral:
                return STRQColors.borderMuted
            case .selected:
                return STRQColors.primaryAccent
            case .orange:
                return STRQColors.warmAccentSoft
            case .success:
                return STRQColors.successSoft
            case .warning:
                return STRQColors.warningSoft
            case .danger:
                return STRQColors.dangerSoft
            case .blue:
                return STRQColors.blue.opacity(0.45)
            case .disabled:
                return STRQColors.borderMuted
            }
        }
    }
}

// MARK: - Icon System

enum STRQIcon: String, CaseIterable {
    case home = "STRQIconHome"
    case coach = "STRQIconCoach"
    case train = "STRQIconTrain"
    case progress = "STRQIconProgress"
    case profile = "STRQIconProfile"
    case settings = "STRQIconSettings"
    case recovery = "STRQIconRecovery"
    case calendar = "STRQIconCalendar"
    case sleep = "STRQIconSleep"
    case heart = "STRQIconHeart"
    case heartbeat = "STRQIconHeartbeat"
    case moon = "STRQIconMoon"
    case bolt = "STRQIconBolt"
    case soreness = "STRQIconSoreness"
    case stress = "STRQIconStress"
    case water = "STRQIconWater"
    case nutrition = "STRQIconNutrition"
    case muscle = "STRQIconMuscle"
    case fullBody = "STRQIconFullBody"
    case gym = "STRQIconGym"
    case check = "STRQIconCheck"
    case search = "STRQIconSearch"

    case plus = "STRQIconPlus"
    case close = "STRQIconClose"
    case chevronRight = "STRQIconChevronRight"
    case chevronLeft = "STRQIconChevronLeft"
    case arrowRight = "STRQIconArrowRight"
    case arrowLeft = "STRQIconArrowLeft"
    case edit = "STRQIconEdit"
    case trash = "STRQIconTrash"
    case more = "STRQIconMore"
    case info = "STRQIconInfo"
    case warning = "STRQIconWarning"
    case lock = "STRQIconLock"
    case checkCircle = "STRQIconCheckCircle"
    case clock = "STRQIconClock"
    case repeatAction = "STRQIconRepeat"
    case swap = "STRQIconSwap"
    case play = "STRQIconPlay"
    case pause = "STRQIconPause"
    case stop = "STRQIconStop"
    case checklist = "STRQIconChecklist"
    case rest = "STRQIconRest"
    case skip = "STRQIconSkip"
    case reps = "STRQIconReps"
    case sets = "STRQIconSets"
    case target = "STRQIconTarget"
    case chartLine = "STRQIconChartLine"
    case chartBar = "STRQIconChartBar"
    case trendUp = "STRQIconTrendUp"
    case trendDown = "STRQIconTrendDown"
    case trophy = "STRQIconTrophy"
    case medal = "STRQIconMedal"
    case fire = "STRQIconFire"
    case percentage = "STRQIconPercentage"
    case activityRing = "STRQIconActivityRing"
    case barbell = "STRQIconBarbell"
    case weightScale = "STRQIconWeightScale"
    case bell = "STRQIconBell"
    case star = "STRQIconStar"
}

typealias STRQIconAsset = STRQIcon

struct STRQIconView: View {
    let icon: STRQIcon
    var size: CGFloat = STRQSpacing.iconMD
    var tint: Color = STRQColors.textPrimary
    var templateRendering: Bool = true

    init(
        _ icon: STRQIcon,
        size: CGFloat = STRQSpacing.iconMD,
        tint: Color = STRQColors.textPrimary,
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
                STRQImage
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(tint)
            } else {
                STRQMissingIconGlyph(size: size, tint: tint)
            }
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }

    private var STRQImage: Image {
        let image = Image(icon.rawValue)
        return templateRendering ? image.renderingMode(.template) : image.renderingMode(.original)
    }

    private static func assetExists(_ icon: STRQIcon) -> Bool {
        #if canImport(UIKit)
        return UIImage(named: icon.rawValue) != nil
        #else
        return true
        #endif
    }
}

private struct STRQMissingIconGlyph: View {
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

struct STRQIconContainer: View {
    enum Size {
        case sm
        case md
        case lg
        case xl

        var frame: CGFloat {
            switch self {
            case .sm: return STRQSpacing.iconContainerSM
            case .md: return STRQSpacing.iconContainerMD
            case .lg: return STRQSpacing.iconContainerLG
            case .xl: return STRQSpacing.iconContainerXL
            }
        }

        var icon: CGFloat {
            switch self {
            case .sm: return STRQSpacing.iconXS
            case .md: return STRQSpacing.iconSM
            case .lg: return STRQSpacing.iconMD
            case .xl: return STRQSpacing.iconLG
            }
        }
    }

    let icon: STRQIcon
    var size: Size = .lg
    var tint: Color = STRQColors.iconSecondary
    var background: Color? = nil

    var body: some View {
        STRQIconView(icon, size: size.icon, tint: tint)
            .frame(width: size.frame, height: size.frame)
            .background(background ?? STRQColors.controlSurface, in: .rect(cornerRadius: STRQRadii.iconContainer))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.iconContainer, style: .continuous)
                    .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
            )
    }
}

// MARK: - Surfaces & Cards

struct STRQSurface<Content: View>: View {
    var variant: STRQComponentStyle.SurfaceVariant
    var borderVariant: STRQComponentStyle.BorderVariant
    var radius: CGFloat
    var padding: CGFloat
    var customBackground: Color?
    var customBorder: Color?
    var selected: Bool
    let content: Content

    init(
        variant: STRQComponentStyle.SurfaceVariant = .card,
        border: STRQComponentStyle.BorderVariant = .subtle,
        radius: STRQComponentStyle.RadiusVariant = .card,
        padding: CGFloat = STRQSpacing.cardPadding,
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
        padding: CGFloat = STRQSpacing.cardPadding,
        radius: CGFloat = STRQRadii.card,
        background: Color = STRQColors.cardSurface,
        border: Color = STRQColors.borderMuted,
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
        let token = selected ? STRQEffects.selectedCardBorder : borderVariant.token
        let strokeColor = selected ? STRQColors.selectedBorder : (customBorder ?? token.color)
        let strokeWidth = selected ? STRQEffects.selectedBorderWidth : token.width

        content
            .padding(padding)
            .background(customBackground ?? variant.background, in: .rect(cornerRadius: radius))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(strokeColor, lineWidth: strokeWidth)
            )
            .shadow(
                color: selected ? STRQEffects.selectionGlow.color : STRQEffects.subtleShadow.color,
                radius: selected ? STRQEffects.selectionGlow.radius : STRQEffects.subtleShadow.radius,
                x: 0,
                y: selected ? STRQEffects.selectionGlow.y : STRQEffects.subtleShadow.y
            )
    }
}

struct STRQCard<Content: View>: View {
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
        STRQSurface(
            variant: surfaceVariant,
            border: borderVariant,
            radius: radius,
            padding: padding
        ) {
            content
        }
    }

    private var surfaceVariant: STRQComponentStyle.SurfaceVariant {
        switch variant {
        case .standard, .compact:
            return .card
        case .elevated, .hero:
            return .elevated
        case .selected:
            return .selected
        }
    }

    private var borderVariant: STRQComponentStyle.BorderVariant {
        variant == .selected ? .selected : .subtle
    }

    private var radius: STRQComponentStyle.RadiusVariant {
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
            return STRQSpacing.cardPaddingCompact
        case .hero:
            return STRQSpacing.xl
        case .standard, .elevated, .selected:
            return STRQSpacing.cardPadding
        }
    }
}

// MARK: - Buttons, Chips, Badges

struct STRQButton: View {
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
    var icon: STRQIcon?
    var variant: Variant = .primary
    var isDisabled: Bool = false
    let action: () -> Void

    init(
        _ title: String,
        icon: STRQIcon? = nil,
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
        icon: STRQIcon? = nil,
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
        icon: STRQIcon,
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
            HStack(spacing: title == nil ? 0 : STRQSpacing.sm) {
                if let icon {
                    STRQIconView(icon, size: iconSize, tint: foregroundColor)
                }

                if let title {
                    Text(title)
                        .font(font)
                        .tracking(STRQTypography.buttonTracking)
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
                color: variant == .primary ? STRQColors.white.opacity(0.12) : STRQEffects.subtleShadow.color,
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
            return STRQColors.actionText
        case .secondary:
            return STRQColors.primaryText
        case .ghost, .icon:
            return STRQColors.textPrimary
        case .destructive:
            return STRQColors.white
        }
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary, .compact:
            return STRQColors.actionSurface
        case .secondary:
            return STRQColors.controlSurface
        case .ghost:
            return .clear
        case .icon:
            return STRQColors.controlSurface
        case .destructive:
            return STRQColors.dangerRed
        }
    }

    private var borderColor: Color {
        switch variant {
        case .primary, .compact, .destructive:
            return .clear
        case .secondary:
            return STRQColors.borderTertiary
        case .ghost, .icon:
            return STRQColors.borderMuted
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
            return STRQSpacing.buttonCompactHeight
        case .icon:
            return STRQSpacing.iconButtonSize
        case .primary, .secondary, .ghost, .destructive:
            return STRQSpacing.buttonHeight
        }
    }

    private var fixedWidth: CGFloat? {
        variant == .icon ? STRQSpacing.iconButtonSize : nil
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
            return STRQSpacing.md
        case .icon:
            return 0
        case .ghost:
            return STRQSpacing.sm
        case .primary, .secondary, .destructive:
            return STRQSpacing.xl
        }
    }

    private var radius: CGFloat {
        variant == .icon ? STRQRadii.iconContainer : STRQRadii.button
    }

    private var iconSize: CGFloat {
        variant == .icon ? STRQSpacing.iconSM : STRQSpacing.iconMD
    }

    private var font: Font {
        variant == .compact ? STRQTypography.buttonCompact : STRQTypography.button
    }
}

struct STRQIconButton: View {
    enum Variant: Equatable {
        case primary
        case secondary
        case ghost
        case destructive
    }

    var icon: STRQIcon
    var variant: Variant = .secondary
    var size: CGFloat = STRQSpacing.iconButtonSize
    var iconSize: CGFloat = STRQSpacing.iconSM
    var isDisabled: Bool = false
    var accessibilityLabel: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            STRQIconView(icon, size: iconSize, tint: foregroundColor)
                .frame(width: size, height: size)
                .background(backgroundColor, in: .rect(cornerRadius: STRQRadii.iconContainer))
                .overlay(
                    RoundedRectangle(cornerRadius: STRQRadii.iconContainer, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: borderWidth)
                )
                .opacity(isDisabled ? 0.44 : 1)
        }
        .buttonStyle(.strqPressable)
        .disabled(isDisabled)
        .accessibilityLabel(accessibilityLabel ?? String(describing: icon))
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary:
            return STRQColors.actionText
        case .secondary, .ghost:
            return STRQColors.iconPrimary
        case .destructive:
            return STRQColors.dangerTextPrimary
        }
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary:
            return STRQColors.actionSurface
        case .secondary:
            return STRQColors.controlSurface
        case .ghost:
            return .clear
        case .destructive:
            return STRQColors.dangerDim
        }
    }

    private var borderColor: Color {
        switch variant {
        case .primary:
            return .clear
        case .secondary, .ghost:
            return STRQColors.borderMuted
        case .destructive:
            return STRQColors.dangerSoft
        }
    }

    private var borderWidth: CGFloat {
        variant == .primary ? 0 : 1
    }
}

struct STRQChip: View {
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

        var componentTone: STRQComponentStyle.Tone {
            switch self {
            case .neutral:
                return .neutral
            case .selected, .brand:
                return .selected
            case .orange:
                return .orange
            case .brandSoft:
                return .neutral
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
    var icon: STRQIcon?
    var tone: Tone = .neutral
    var size: Size = .regular

    var body: some View {
        HStack(spacing: STRQSpacing.chipGap) {
            if let icon {
                STRQIconView(icon, size: iconSize, tint: foregroundColor)
            }

            Text(label)
                .font(font)
                .tracking(STRQTypography.chipTracking)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding)
        .frame(minHeight: minHeight)
        .background(backgroundColor, in: .rect(cornerRadius: STRQRadii.chip))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.chip, style: .continuous)
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
            return STRQTypography.chipSmall
        case .regular, .large:
            return STRQTypography.chip
        }
    }

    private var iconSize: CGFloat {
        switch size {
        case .compact:
            return STRQSpacing.iconXS
        case .regular:
            return STRQSpacing.iconSM
        case .large:
            return STRQSpacing.iconMD
        }
    }

    private var horizontalPadding: CGFloat {
        switch size {
        case .compact:
            return STRQSpacing.xs
        case .regular:
            return STRQSpacing.chipHorizontalPadding
        case .large:
            return STRQSpacing.md
        }
    }

    private var verticalPadding: CGFloat {
        switch size {
        case .compact:
            return 2
        case .regular:
            return STRQSpacing.chipVerticalPadding
        case .large:
            return STRQSpacing.xs
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

struct STRQBadge: View {
    enum Variant: Equatable {
        case small
        case achievement
        case count
        case status
    }

    var text: String
    var icon: STRQIcon?
    var variant: Variant = .small
    var tone: STRQChip.Tone = .neutral

    var body: some View {
        HStack(spacing: STRQSpacing.chipGap) {
            if let icon {
                STRQIconView(icon, size: iconSize, tint: tone.componentTone.foreground)
            }

            Text(text)
                .font(font)
                .tracking(variant == .count ? 0 : STRQTypography.labelTracking)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .foregroundStyle(tone.componentTone.foreground)
        .padding(.horizontal, horizontalPadding)
        .frame(minWidth: variant == .count ? minHeight : nil, minHeight: minHeight)
        .background(tone.componentTone.background, in: .rect(cornerRadius: STRQRadii.full))
        .overlay(
            Capsule()
                .strokeBorder(tone.componentTone.border, lineWidth: 1)
        )
    }

    private var font: Font {
        switch variant {
        case .small, .count:
            return STRQTypography.labelSmall
        case .achievement, .status:
            return STRQTypography.label
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
        variant == .count ? STRQSpacing.xs : STRQSpacing.sm
    }

    private var iconSize: CGFloat {
        variant == .achievement ? STRQSpacing.iconSM : STRQSpacing.iconXS
    }
}

// MARK: - Metrics & Progress

struct STRQMetricCard: View {
    let value: String
    let label: String
    var icon: STRQIcon?
    var unit: String?
    var detail: String?
    var progress: Double?
    var selected: Bool = false
    var active: Bool = false
    var tint: Color = STRQColors.iconPrimary
    var valueFont: Font = STRQTypography.metricMedium
    var iconBackground: Color? = nil
    var minHeight: CGFloat = STRQSpacing.metricCardMinHeight

    var body: some View {
        STRQSurface(
            selected: selected || active,
            padding: STRQSpacing.md,
            radius: STRQRadii.metricCard,
            background: active ? STRQColors.selectedSurface : STRQColors.cardSurface
        ) {
            VStack(alignment: .leading, spacing: STRQSpacing.sm) {
                if let icon {
                    STRQIconContainer(icon: icon, size: .lg, tint: tint, background: iconBackground)
                }

                VStack(alignment: .leading, spacing: STRQSpacing.xxs) {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(value)
                            .font(valueFont)
                            .foregroundStyle(STRQColors.primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        if let unit {
                            Text(unit)
                                .font(STRQTypography.bodySmallMedium)
                                .foregroundStyle(STRQColors.secondaryText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    }

                    Text(label)
                        .font(STRQTypography.caption)
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }

                if let detail {
                    Text(detail)
                        .font(STRQTypography.captionRegular)
                        .foregroundStyle(STRQColors.mutedText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                }

                if let progress {
                    STRQProgressBar(value: progress, height: 6, tint: tint, compact: true)
                }
            }
            .frame(maxWidth: .infinity, minHeight: minHeight, alignment: .leading)
        }
    }
}

struct STRQProgressBar: View {
    var value: Double
    var height: CGFloat = 8
    var tint: Color = STRQColors.primaryAccent
    var label: String? = nil
    var valueText: String? = nil
    var compact: Bool = false
    var trackColor: Color = STRQColors.surfaceTertiary

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.xs) {
            if label != nil || valueText != nil {
                HStack(spacing: STRQSpacing.sm) {
                    if let label {
                        Text(label)
                            .font(STRQTypography.bodySmallMedium)
                            .foregroundStyle(STRQColors.primaryText)
                            .lineLimit(1)
                    }

                    Spacer(minLength: STRQSpacing.xs)

                    if let valueText {
                        Text(valueText)
                            .font(STRQTypography.labelSmall)
                            .foregroundStyle(STRQColors.secondaryText)
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
                            .overlay(STRQGradients.subtleOverlay.clipShape(Capsule()))
                            .frame(width: width)
                    }
                }
            }
            .frame(height: compact ? max(4, height) : height)
            .clipShape(Capsule())
        }
    }
}

struct STRQProgressRing: View {
    enum Variant: Equatable {
        case compact
        case score
        case activity
    }

    var value: Double
    var variant: Variant = .compact
    var size: CGFloat? = nil
    var lineWidth: CGFloat? = nil
    var tint: Color = STRQColors.primaryAccent
    var label: String? = nil
    var valueText: String? = nil

    var body: some View {
        ZStack {
            Circle()
                .stroke(STRQColors.surfaceTertiary, lineWidth: resolvedLineWidth)

            Circle()
                .trim(from: 0, to: min(max(value, 0), 1))
                .stroke(
                    tint,
                    style: StrokeStyle(lineWidth: resolvedLineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .overlay(STRQGradients.subtleOverlay.clipShape(Circle()))

            if valueText != nil || label != nil {
                VStack(spacing: 0) {
                    if let valueText {
                        Text(valueText)
                            .font(valueFont)
                            .foregroundStyle(STRQColors.primaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)
                    }

                    if let label {
                        Text(label)
                            .font(STRQTypography.micro)
                            .foregroundStyle(STRQColors.mutedText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)
                    }
                }
                .padding(STRQSpacing.xs)
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
        variant == .compact ? STRQTypography.labelSmall : STRQTypography.metricSmall
    }
}

struct STRQProgressRow: View {
    let label: String
    let value: String
    var detail: String?
    var icon: STRQIcon? = .recovery
    var progress: Double
    var tint: Color = STRQColors.primaryAccent
    var boxed: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            HStack(spacing: STRQSpacing.sm) {
                if let icon {
                    STRQIconContainer(icon: icon, size: .md, tint: tint)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(STRQTypography.bodySmallMedium)
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(1)

                    if let detail {
                        Text(detail)
                            .font(STRQTypography.caption)
                            .foregroundStyle(STRQColors.mutedText)
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: STRQSpacing.xs)

                Text(value)
                    .font(STRQTypography.label)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }

            STRQProgressBar(value: progress, height: 8, tint: tint, compact: true)
        }
        .padding(boxed ? STRQSpacing.sm : 0)
        .background(boxed ? STRQColors.surfacePrimary : Color.clear, in: .rect(cornerRadius: STRQRadii.lg))
        .overlay {
            if boxed {
                RoundedRectangle(cornerRadius: STRQRadii.lg, style: .continuous)
                    .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
            }
        }
    }
}

// MARK: - List Items & Section Headers

struct STRQListItem: View {
    var leadingIcon: STRQIcon?
    var avatarText: String?
    var title: String
    var subtitle: String?
    var trailingValue: String?
    var showsChevron: Bool = false
    var showsDivider: Bool = true
    var tint: Color = STRQColors.iconSecondary

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: STRQSpacing.sm) {
                leadingView

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(STRQTypography.bodyMedium)
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.82)

                    if let subtitle {
                        Text(subtitle)
                            .font(STRQTypography.captionRegular)
                            .foregroundStyle(STRQColors.mutedText)
                            .lineLimit(2)
                    }
                }

                Spacer(minLength: STRQSpacing.sm)

                if let trailingValue {
                    Text(trailingValue)
                        .font(STRQTypography.label)
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }

                if showsChevron {
                    STRQIconView(.chevronRight, size: STRQSpacing.iconSM, tint: STRQColors.mutedText)
                }
            }
            .padding(.vertical, STRQSpacing.sm)
            .padding(.horizontal, STRQSpacing.listItemPadding)

            if showsDivider {
                Rectangle()
                    .fill(STRQColors.divider)
                    .frame(height: 1)
                    .padding(.leading, leadingIndent)
            }
        }
    }

    @ViewBuilder
    private var leadingView: some View {
        if let leadingIcon {
            STRQIconContainer(icon: leadingIcon, size: .md, tint: tint)
        } else if let avatarText {
            Text(avatarText.prefix(2).uppercased())
                .font(STRQTypography.labelSmall)
                .foregroundStyle(STRQColors.textOnBrand)
                .frame(width: STRQSpacing.iconContainerMD, height: STRQSpacing.iconContainerMD)
                .background(tint, in: Circle())
        }
    }

    private var leadingIndent: CGFloat {
        (leadingIcon == nil && avatarText == nil) ? STRQSpacing.listItemPadding : 68
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
        HStack(alignment: .center, spacing: STRQSpacing.sm) {
            Text(title)
                .font(STRQTypography.cardTitle)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Spacer(minLength: STRQSpacing.xs)

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

struct STRQSectionAction: View {
    var title: String = "See All"
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: STRQSpacing.xxs) {
                Text(title)
                    .font(STRQTypography.labelSmall)
                STRQIconView(.arrowRight, size: STRQSpacing.iconXS, tint: STRQColors.primaryAccent)
            }
            .foregroundStyle(STRQColors.primaryAccent)
        }
        .buttonStyle(.strqPressable)
    }
}

// MARK: - Inputs, Navigation & Feedback

struct STRQSearchField: View {
    @Binding var text: String
    var placeholder: String = "Search"
    var onSubmit: () -> Void = {}

    var body: some View {
        HStack(spacing: STRQSpacing.sm) {
            STRQIconView(.search, size: STRQSpacing.iconSM, tint: STRQColors.iconMuted)

            TextField(placeholder, text: $text)
                .font(STRQTypography.textMedium)
                .foregroundStyle(STRQColors.primaryText)
                .submitLabel(.search)
                .onSubmit(onSubmit)

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    STRQIconView(.close, size: STRQSpacing.iconXS, tint: STRQColors.iconMuted)
                }
                .buttonStyle(.strqPressable)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, STRQSpacing.md)
        .frame(minHeight: STRQSpacing.searchHeight)
        .background(STRQColors.controlSurface, in: .rect(cornerRadius: STRQRadii.lg))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.lg, style: .continuous)
                .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
        )
    }
}

struct STRQInputField: View {
    var title: String?
    @Binding var text: String
    var placeholder: String
    var icon: STRQIcon?
    var helper: String?
    var isSecure: Bool = false

    init(
        _ title: String? = nil,
        text: Binding<String>,
        placeholder: String,
        icon: STRQIcon? = nil,
        helper: String? = nil,
        isSecure: Bool = false
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.icon = icon
        self.helper = helper
        self.isSecure = isSecure
    }

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.xs) {
            if let title {
                Text(title.uppercased())
                    .font(STRQTypography.labelSmall)
                    .tracking(STRQTypography.labelSmallTracking)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(1)
            }

            HStack(spacing: STRQSpacing.sm) {
                if let icon {
                    STRQIconView(icon, size: STRQSpacing.iconSM, tint: STRQColors.iconMuted)
                }

                Group {
                    if isSecure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .font(STRQTypography.textMedium)
                .foregroundStyle(STRQColors.primaryText)
            }
            .padding(.horizontal, STRQSpacing.md)
            .frame(minHeight: STRQSpacing.inputHeight)
            .background(STRQColors.controlSurface, in: .rect(cornerRadius: STRQRadii.lg))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.lg, style: .continuous)
                    .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
            )

            if let helper {
                Text(helper)
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQColors.mutedText)
                    .lineLimit(2)
            }
        }
    }
}

struct STRQToggleRow: View {
    var title: String
    var subtitle: String?
    var icon: STRQIcon?
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: STRQSpacing.sm) {
            if let icon {
                STRQIconContainer(icon: icon, size: .md, tint: isOn ? STRQColors.iconPrimary : STRQColors.iconSecondary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(STRQTypography.textMedium)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)

                if let subtitle {
                    Text(subtitle)
                        .font(STRQTypography.caption)
                        .foregroundStyle(STRQColors.mutedText)
                        .lineLimit(2)
                }
            }

            Spacer(minLength: STRQSpacing.sm)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(STRQColors.primaryAccent)
        }
        .padding(.horizontal, STRQSpacing.listItemPadding)
        .padding(.vertical, STRQSpacing.sm)
        .frame(minHeight: STRQSpacing.toggleRowMinHeight)
        .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.lg))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.lg, style: .continuous)
                .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
        )
    }
}

struct STRQModalSurface<Content: View>: View {
    var title: String?
    var content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        STRQSurface(
            variant: .elevated,
            border: .subtle,
            radius: .custom(STRQRadii.modal),
            padding: STRQSpacing.xl
        ) {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                if let title {
                    Text(title)
                        .font(STRQTypography.cardTitle)
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(2)
                }

                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct STRQBottomSheetSurface<Content: View>: View {
    var title: String?
    var content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.md) {
            Capsule()
                .fill(STRQColors.borderSecondary)
                .frame(width: 44, height: 4)
                .frame(maxWidth: .infinity)

            if let title {
                Text(title)
                    .font(STRQTypography.sectionTitle)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(2)
            }

            content
        }
        .padding(.horizontal, STRQSpacing.lg)
        .padding(.top, STRQSpacing.md)
        .padding(.bottom, STRQSpacing.xl)
        .background(STRQEffects.darkGlassBackground, in: .rect(cornerRadius: STRQRadii.bottomSheet))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.bottomSheet, style: .continuous)
                .strokeBorder(STRQEffects.darkGlassStroke, lineWidth: 1)
        )
        .shadow(
            color: STRQEffects.cardShadow.color,
            radius: STRQEffects.cardShadow.radius,
            x: STRQEffects.cardShadow.x,
            y: -STRQEffects.cardShadow.y
        )
    }
}

struct STRQNavigationBar<Leading: View, Trailing: View>: View {
    var title: String
    var subtitle: String?
    var leading: Leading
    var trailing: Trailing

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = leading()
        self.trailing = trailing()
    }

    var body: some View {
        HStack(spacing: STRQSpacing.sm) {
            leading

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(STRQTypography.screenTitle)
                    .tracking(STRQTypography.headingXSTracking)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                if let subtitle {
                    Text(subtitle)
                        .font(STRQTypography.caption)
                        .foregroundStyle(STRQColors.mutedText)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: STRQSpacing.sm)

            trailing
        }
        .frame(minHeight: STRQSpacing.navBarHeight)
    }
}

extension STRQNavigationBar where Leading == EmptyView {
    init(title: String, subtitle: String? = nil, @ViewBuilder trailing: () -> Trailing) {
        self.init(title: title, subtitle: subtitle, leading: { EmptyView() }, trailing: trailing)
    }
}

extension STRQNavigationBar where Leading == EmptyView, Trailing == EmptyView {
    init(title: String, subtitle: String? = nil) {
        self.init(title: title, subtitle: subtitle, leading: { EmptyView() }, trailing: { EmptyView() })
    }
}

struct STRQAvatar: View {
    enum Size {
        case sm
        case md
        case lg

        var frame: CGFloat {
            switch self {
            case .sm: return STRQSpacing.avatarSM
            case .md: return STRQSpacing.avatarMD
            case .lg: return STRQSpacing.avatarLG
            }
        }

        var font: Font {
            switch self {
            case .sm: return STRQTypography.labelXS
            case .md: return STRQTypography.labelSmall
            case .lg: return STRQTypography.labelMedium
            }
        }
    }

    var initials: String
    var size: Size = .md
    var imageName: String?
    var tint: Color = STRQColors.controlSurface

    var body: some View {
        Group {
            if let imageName {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            } else {
                Text(initials.prefix(2).uppercased())
                    .font(size.font)
                    .tracking(STRQTypography.labelXSTracking)
                    .foregroundStyle(STRQColors.primaryText)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(tint)
            }
        }
        .frame(width: size.frame, height: size.frame)
        .clipShape(Circle())
        .overlay(
            Circle()
                .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
        )
    }
}

struct STRQRatingStars: View {
    var rating: Double
    var maxRating: Int = 5
    var size: CGFloat = STRQSpacing.iconXS
    var filledTint: Color = STRQColors.primaryAccent
    var emptyTint: Color = STRQColors.iconMuted

    var body: some View {
        HStack(spacing: STRQSpacing.xxs) {
            ForEach(0..<maxRating, id: \.self) { index in
                STRQIconView(
                    .star,
                    size: size,
                    tint: rating >= Double(index + 1) ? filledTint : emptyTint
                )
            }
        }
        .accessibilityLabel(Text("\(rating, specifier: "%.1f") out of \(maxRating) stars"))
    }
}

struct STRQEmptyStateCard: View {
    var icon: STRQIcon = .info
    var title: String
    var message: String
    var actionTitle: String?
    var action: (() -> Void)?

    var body: some View {
        STRQCard {
            VStack(alignment: .center, spacing: STRQSpacing.md) {
                STRQIconContainer(icon: icon, size: .xl, tint: STRQColors.iconSecondary)

                VStack(spacing: STRQSpacing.xs) {
                    Text(title)
                        .font(STRQTypography.cardTitle)
                        .foregroundStyle(STRQColors.primaryText)
                        .multilineTextAlignment(.center)

                    Text(message)
                        .font(STRQTypography.paragraphSmall)
                        .foregroundStyle(STRQColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }

                if let actionTitle, let action {
                    STRQButton(actionTitle, icon: .plus, variant: .compact, action: action)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Tab Bar Primitives

struct STRQTabBarItem: View {
    let title: String
    let icon: STRQIcon
    var isSelected: Bool

    var body: some View {
        VStack(spacing: STRQSpacing.xxs) {
            STRQIconView(
                icon,
                size: STRQSpacing.iconMD,
                tint: isSelected ? STRQColors.primaryAccent : STRQColors.iconMuted
            )

            Text(title)
                .font(isSelected ? STRQTypography.tabLabel.weight(.semibold) : STRQTypography.tabLabel)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(isSelected ? STRQColors.primaryAccent : STRQColors.iconMuted)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 56)
        .padding(.vertical, STRQSpacing.xxs)
        .background(
            isSelected ? STRQColors.selectedSurface : Color.clear,
            in: .rect(cornerRadius: STRQRadii.tabItem)
        )
    }
}

struct STRQTabBarCenterAction: View {
    var icon: STRQIcon = .plus
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            STRQIconView(icon, size: STRQSpacing.iconMD, tint: STRQColors.actionText)
                .frame(width: 56, height: 56)
                .background(STRQGradients.primaryAction, in: Circle())
                .shadow(
                    color: STRQEffects.selectionGlow.color,
                    radius: STRQEffects.selectionGlow.radius,
                    x: 0,
                    y: STRQEffects.selectionGlow.y
                )
        }
        .buttonStyle(.strqPressable)
    }
}

struct STRQTabBarContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack(alignment: .center, spacing: STRQSpacing.xs) {
            content
        }
        .padding(.horizontal, STRQSpacing.sm)
        .frame(minHeight: STRQSpacing.tabBarHeight)
        .background(STRQEffects.darkGlassBackground, in: .rect(cornerRadius: STRQRadii.tabbar))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.tabbar, style: .continuous)
                .strokeBorder(STRQEffects.darkGlassStroke, lineWidth: 1)
        )
        .shadow(
            color: STRQEffects.cardShadow.color,
            radius: STRQEffects.cardShadow.radius,
            x: STRQEffects.cardShadow.x,
            y: STRQEffects.cardShadow.y
        )
    }
}

struct STRQTabBarBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.top, STRQSpacing.xxs)
            .background(STRQColors.background)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(STRQColors.borderMuted)
                    .frame(height: 1)
            }
            .shadow(color: Color.black.opacity(0.12), radius: 16, y: -4)
    }
}

extension View {
    func strqTabBarBackground() -> some View {
        modifier(STRQTabBarBackground())
    }
}

// MARK: - Schedule Primitives

struct STRQScheduleRow: View {
    var dateTitle: String
    var dateSubtitle: String?
    var title: String
    var subtitle: String?
    var duration: String?
    var icon: STRQIcon? = .calendar
    var isSelected: Bool = false

    var body: some View {
        HStack(spacing: STRQSpacing.sm) {
            VStack(spacing: 2) {
                Text(dateTitle)
                    .font(STRQTypography.label)
                    .foregroundStyle(isSelected ? STRQColors.actionText : STRQColors.primaryText)
                    .lineLimit(1)

                if let dateSubtitle {
                    Text(dateSubtitle)
                        .font(STRQTypography.micro)
                        .foregroundStyle(isSelected ? STRQColors.actionText.opacity(0.74) : STRQColors.mutedText)
                        .lineLimit(1)
                }
            }
            .frame(width: 48, height: 48)
            .background(isSelected ? STRQColors.actionSurface : STRQColors.surfaceSecondary, in: .rect(cornerRadius: STRQRadii.md))

            if let icon {
                STRQIconContainer(icon: icon, size: .md, tint: isSelected ? STRQColors.primaryAccent : STRQColors.iconMuted)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(STRQTypography.bodyMedium)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                if let subtitle {
                    Text(subtitle)
                        .font(STRQTypography.captionRegular)
                        .foregroundStyle(STRQColors.mutedText)
                        .lineLimit(1)
                }
            }

            Spacer(minLength: STRQSpacing.sm)

            if let duration {
                Text(duration)
                    .font(STRQTypography.labelSmall)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(1)
            }
        }
        .padding(STRQSpacing.sm)
        .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.lg))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.lg, style: .continuous)
                .strokeBorder(isSelected ? STRQColors.selectedBorder : STRQColors.borderMuted, lineWidth: 1)
        )
    }
}

struct STRQScheduleCard: View {
    var title: String
    var subtitle: String?
    var rows: [STRQScheduleRow]

    var body: some View {
        STRQCard {
            VStack(alignment: .leading, spacing: STRQSpacing.sm) {
                STRQSectionHeader(title) {
                    if let subtitle {
                        Text(subtitle)
                            .font(STRQTypography.caption)
                            .foregroundStyle(STRQColors.mutedText)
                            .lineLimit(1)
                    }
                }

                VStack(spacing: STRQSpacing.xs) {
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
struct STRQFoundationPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: STRQSpacing.sectionGap) {
                STRQSectionHeader("Foundation") {
                    STRQChip(label: "STRQ", icon: .checkCircle, tone: .success)
                }

                HStack(spacing: STRQSpacing.xs) {
                    STRQMetricCard(
                        value: "88",
                        label: "Recovery",
                        icon: .recovery,
                        unit: "%",
                        progress: 0.88,
                        tint: STRQColors.successGreen
                    )

                    STRQMetricCard(
                        value: "3/5",
                        label: "Week",
                        icon: .calendar,
                        progress: 0.6
                    )
                }

                STRQProgressRow(
                    label: "Training Load",
                    value: "72%",
                    detail: "Weekly target pace",
                    icon: .train,
                    progress: 0.72
                )

                STRQButton("Start", icon: .barbell) {}
            }
            .padding(STRQSpacing.screenHorizontalMargin)
        }
        .background(STRQColors.background)
    }
}

struct STRQComponentsPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.sectionGap) {
            HStack(spacing: STRQSpacing.xs) {
                STRQChip(label: "Neutral")
                STRQChip(label: "Active", icon: .check, tone: .selected)
                STRQBadge(text: "7", variant: .count, tone: .warning)
            }

            STRQProgressRing(
                value: 0.82,
                variant: .score,
                tint: STRQColors.primaryAccent,
                label: "Score",
                valueText: "82"
            )

            STRQListItem(
                leadingIcon: .trophy,
                title: "Strength Goal",
                subtitle: "Four week progression",
                trailingValue: "68%",
                showsChevron: true
            )

            STRQScheduleRow(
                dateTitle: "29",
                dateSubtitle: "WED",
                title: "Upper Strength",
                subtitle: "Push and pull",
                duration: "45m",
                icon: .barbell,
                isSelected: true
            )

            STRQTabBarContainer {
                STRQTabBarItem(title: "Home", icon: .home, isSelected: true)
                STRQTabBarItem(title: "Train", icon: .train, isSelected: false)
                STRQTabBarCenterAction {}
                STRQTabBarItem(title: "Progress", icon: .progress, isSelected: false)
                STRQTabBarItem(title: "Profile", icon: .profile, isSelected: false)
            }
        }
        .padding(STRQSpacing.screenHorizontalMargin)
        .background(STRQColors.background)
    }
}
#endif

private extension Color {
    init(strqHex hex: UInt, opacity: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}
