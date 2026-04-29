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
    static let fontFamily = "Work Sans"
    static let workSansFontFilesBundled = false
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

    static let displayLarge = strqFont(size: 180, weight: .semibold)
    static let displayMedium = strqFont(size: 128, weight: .semibold)
    static let displaySmall = strqFont(size: 96, weight: .semibold)

    static let heading2XL = strqFont(size: 72, weight: .semibold)
    static let headingXL = strqFont(size: 60, weight: .semibold)
    static let headingLarge = strqFont(size: 48, weight: .semibold)
    static let headingMedium = strqFont(size: 36, weight: .semibold)
    static let headingSmall = strqFont(size: 30, weight: .semibold)
    static let headingXS = strqFont(size: 24, weight: .semibold)

    static let title = strqFont(size: 24, weight: .semibold)
    static let cardTitle = strqFont(size: 18, weight: .semibold)
    static let metricLarge = strqFont(size: 40, weight: .semibold).monospacedDigit()
    static let metricMedium = strqFont(size: 30, weight: .semibold).monospacedDigit()
    static let metricSmall = strqFont(size: 20, weight: .bold).monospacedDigit()

    static let bodyXLarge = strqFont(size: 20, weight: .regular)
    static let bodyLarge = strqFont(size: 18, weight: .regular)
    static let body = strqFont(size: 16, weight: .regular)
    static let bodyMedium = strqFont(size: 16, weight: .medium)
    static let bodySmall = strqFont(size: 14, weight: .regular)
    static let bodySmallMedium = strqFont(size: 14, weight: .medium)

    static let caption = strqFont(size: 12, weight: .medium)
    static let captionRegular = strqFont(size: 12, weight: .regular)
    static let micro = strqFont(size: 10, weight: .medium)

    static let label = strqFont(size: 14, weight: .bold)
    static let labelLarge = strqFont(size: 18, weight: .bold)
    static let labelSmall = strqFont(size: 12, weight: .bold)
    static let chip = strqFont(size: 14, weight: .medium)
    static let chipSmall = strqFont(size: 12, weight: .medium)
    static let button = strqFont(size: 18, weight: .semibold)
    static let buttonCompact = strqFont(size: 14, weight: .semibold)
    static let tabLabel = strqFont(size: 12, weight: .medium)

    // Backwards-compatible aliases from the first STRQ foundation pass.
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

    private static func strqFont(size: CGFloat, weight: Font.Weight) -> Font {
        Font.custom(fontFamily, size: size).weight(weight)
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
    static let focusGlowColor = STRQColors.orangePrimary.opacity(0.30)
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
                return STRQBorderToken(color: STRQColors.orangePrimary, width: STRQEffects.hairline)
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
            case .selected, .orange:
                return STRQColors.brandTextPrimary
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
                return STRQColors.selectedSurface
            case .orange:
                return STRQColors.orangeDim
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
            case .selected, .orange:
                return STRQColors.orangeSoft
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
    var tint: Color = STRQColors.orangePrimary
    var background: Color? = nil

    var body: some View {
        STRQIconView(icon, size: size.icon, tint: tint)
            .frame(width: size.frame, height: size.frame)
            .background(background ?? tint.opacity(0.14), in: .rect(cornerRadius: STRQRadii.iconContainer))
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
                color: selected ? STRQEffects.orangeGlow.color : STRQEffects.subtleShadow.color,
                radius: selected ? STRQEffects.orangeGlow.radius : STRQEffects.subtleShadow.radius,
                x: 0,
                y: selected ? STRQEffects.orangeGlow.y : STRQEffects.subtleShadow.y
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
                color: variant == .primary ? STRQColors.orangePrimary.opacity(0.20) : STRQEffects.subtleShadow.color,
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
            return STRQColors.textOnBrand
        case .secondary:
            return STRQColors.brandTextPrimary
        case .ghost, .icon:
            return STRQColors.textPrimary
        case .destructive:
            return STRQColors.white
        }
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary, .compact:
            return STRQColors.orangePrimary
        case .secondary:
            return STRQColors.orangeDim
        case .ghost, .icon:
            return STRQColors.surfaceSecondary
        case .destructive:
            return STRQColors.dangerRed
        }
    }

    private var borderColor: Color {
        switch variant {
        case .primary, .compact, .destructive:
            return .clear
        case .secondary:
            return STRQColors.orangeSoft
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
    var tint: Color = STRQColors.orangePrimary
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
    var tint: Color = STRQColors.orangePrimary
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
    var tint: Color = STRQColors.orangePrimary
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
    var tint: Color = STRQColors.orangePrimary
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
    var tint: Color = STRQColors.orangePrimary

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
                STRQIconView(.arrowRight, size: STRQSpacing.iconXS, tint: STRQColors.orangePrimary)
            }
            .foregroundStyle(STRQColors.orangePrimary)
        }
        .buttonStyle(.strqPressable)
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
                tint: isSelected ? STRQColors.orangePrimary : STRQColors.mutedText
            )

            Text(title)
                .font(isSelected ? STRQTypography.tabLabel.weight(.semibold) : STRQTypography.tabLabel)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .foregroundStyle(isSelected ? STRQColors.orangePrimary : STRQColors.mutedText)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 56)
        .padding(.vertical, STRQSpacing.xxs)
        .background(
            isSelected ? STRQColors.orangeDim.opacity(0.38) : Color.clear,
            in: .rect(cornerRadius: STRQRadii.tabItem)
        )
    }
}

struct STRQTabBarCenterAction: View {
    var icon: STRQIcon = .plus
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            STRQIconView(icon, size: STRQSpacing.iconMD, tint: STRQColors.textOnBrand)
                .frame(width: 56, height: 56)
                .background(STRQGradients.orangeCTA, in: Circle())
                .shadow(
                    color: STRQEffects.orangeGlow.color,
                    radius: STRQEffects.orangeGlow.radius,
                    x: 0,
                    y: STRQEffects.orangeGlow.y
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
                    .foregroundStyle(isSelected ? STRQColors.textOnBrand : STRQColors.primaryText)
                    .lineLimit(1)

                if let dateSubtitle {
                    Text(dateSubtitle)
                        .font(STRQTypography.micro)
                        .foregroundStyle(isSelected ? STRQColors.textOnBrand.opacity(0.74) : STRQColors.mutedText)
                        .lineLimit(1)
                }
            }
            .frame(width: 48, height: 48)
            .background(isSelected ? STRQColors.orangePrimary : STRQColors.surfaceSecondary, in: .rect(cornerRadius: STRQRadii.md))

            if let icon {
                STRQIconContainer(icon: icon, size: .md, tint: isSelected ? STRQColors.orangePrimary : STRQColors.mutedText)
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
                STRQChip(label: "Active", icon: .check, tone: .orange)
                STRQBadge(text: "7", variant: .count, tone: .warning)
            }

            STRQProgressRing(
                value: 0.82,
                variant: .score,
                tint: STRQColors.orangePrimary,
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
