import SwiftUI

#if DEBUG
struct ProfileV4SignatureExplorationView: View {
    let isFullscreen: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hidesDebugControls: Bool

    init(isFullscreen: Bool = false, isPresentationMode: Bool? = nil) {
        self.isFullscreen = isFullscreen
        let resolvedPresentationMode = isPresentationMode ?? ProcessInfo.processInfo.arguments.contains("-STRQProfileV4Presentation")
        _hidesDebugControls = State(initialValue: resolvedPresentationMode)
    }

    var body: some View {
        ZStack(alignment: .top) {
            ProfileV41Style.background.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    header
                    firstViewport
                    lowerScrollPreview
                }
                .frame(maxWidth: 430)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 14)
                .padding(.top, isFullscreen ? 8 : 12)
                .padding(.bottom, isFullscreen ? 34 : 18)
            }
            .scrollContentBackground(.hidden)

            if isFullscreen {
                topStatusScrim
            }
        }
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(verbatim: "Profile")
                .font(STRQTypography.headingSmall)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.76)

            Spacer(minLength: 8)

            if !hidesDebugControls {
                HStack(spacing: 7) {
                    Button {
                        enterPresentationMode()
                    } label: {
                        Image(systemName: "eye.slash")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(STRQColors.secondaryText)
                            .frame(width: 32, height: 32)
                            .background(STRQColors.white.opacity(0.06), in: Circle())
                            .overlay(Circle().strokeBorder(STRQColors.white.opacity(0.10), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text(verbatim: "Enter presentation mode"))

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(STRQColors.primaryText)
                            .frame(width: 32, height: 32)
                            .background(STRQColors.white.opacity(0.08), in: Circle())
                            .overlay(Circle().strokeBorder(STRQColors.white.opacity(0.14), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("profile-v4-close")
                }
            }
        }
        .accessibilityIdentifier("profile-v4-header")
    }

    private func enterPresentationMode() {
        if reduceMotion {
            hidesDebugControls = true
        } else {
            withAnimation(.easeInOut(duration: 0.18)) {
                hidesDebugControls = true
            }
        }
    }

    private var firstViewport: some View {
        VStack(alignment: .leading, spacing: 10) {
            ProfileV41PassportHero()
            ProfileV41ControlDoors()
        }
        .accessibilityIdentifier("profile-v4-1-first-viewport")
    }

    private var lowerScrollPreview: some View {
        VStack(alignment: .leading, spacing: 16) {
            ProfileV41Section(
                title: "Training Setup",
                rows: [
                    ProfileV41RowData(icon: "calendar", title: "Schedule", detail: "4 days/week"),
                    ProfileV41RowData(icon: "dumbbell.fill", title: "Equipment", detail: "Full Gym"),
                    ProfileV41RowData(icon: "rectangle.split.2x1", title: "Split", detail: "Upper / Lower"),
                    ProfileV41RowData(icon: "scope", title: "Focus", detail: "Chest, Back, Shoulders")
                ]
            )

            ProfileV41Section(
                title: "Coach & Inputs",
                rows: [
                    ProfileV41RowData(icon: "slider.horizontal.3", title: "Coach", detail: "Balanced"),
                    ProfileV41RowData(icon: "heart.text.square", title: "Apple Health", detail: "Connected"),
                    ProfileV41RowData(icon: "moon", title: "Sleep", detail: "Manual"),
                    ProfileV41RowData(icon: "figure", title: "Bodyweight", detail: "Manual"),
                    ProfileV41RowData(icon: "fork.knife", title: "Nutrition", detail: "Off", tone: .muted)
                ]
            )

            ProfileV41Section(
                title: "Account & Data",
                rows: [
                    ProfileV41RowData(icon: "sparkles", title: "STRQ Pro", detail: "Free"),
                    ProfileV41RowData(icon: "person.crop.circle", title: "Account", detail: "Not signed in"),
                    ProfileV41RowData(icon: "icloud", title: "iCloud", detail: "Off"),
                    ProfileV41RowData(icon: "square.and.arrow.up", title: "Export", detail: "Training data")
                ]
            )
            .accessibilityIdentifier("profile-v4-1-account-data-section")

            ProfileV41Section(
                title: "Privacy & Support",
                rows: [
                    ProfileV41RowData(icon: "lock.shield", title: "Privacy controls", detail: "Manage"),
                    ProfileV41RowData(icon: "doc.text", title: "Privacy Policy", detail: "Read"),
                    ProfileV41RowData(icon: "doc.plaintext", title: "Terms", detail: "Read"),
                    ProfileV41RowData(icon: "envelope", title: "Support", detail: "Contact")
                ]
            )

            ProfileV41Section(
                title: "Advanced Data",
                rows: [
                    ProfileV41RowData(icon: "arrow.counterclockwise", title: "Reset data", detail: "Protected", tone: .warning)
                ]
            )
            .accessibilityIdentifier("profile-v4-1-advanced-data-section")
        }
        .padding(.top, 4)
        .accessibilityIdentifier("profile-v4-1-lower-preview")
    }

    private var topStatusScrim: some View {
        VStack(spacing: 0) {
            ProfileV41Style.background
                .frame(height: 58)

            LinearGradient(
                colors: [
                    ProfileV41Style.background.opacity(0.96),
                    ProfileV41Style.background.opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 18)
        }
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
    }
}

private struct ProfileV41PassportHero: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(alignment: .top, spacing: 12) {
                ProfileV41InitialsBadge()

                VStack(alignment: .leading, spacing: 6) {
                    Text(verbatim: "Build Muscle")
                        .font(.system(size: 31, weight: .black, design: .rounded))
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text(verbatim: "Intermediate · 4 days/week · Full Gym")
                        .font(STRQTypography.labelLarge)
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                }

                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 8) {
                ProfileV41InlineFactRow(text: "Upper / Lower · Chest, Back, Shoulders")

                Text(verbatim: "Upper/lower work is set. Pressing stays in focus.")
                    .font(STRQTypography.captionRegular)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(ProfileV41Style.passportSurface)
                .overlay(alignment: .topLeading) {
                    Capsule()
                        .fill(ProfileV41Style.steel.opacity(0.62))
                        .frame(width: 92, height: 2)
                        .padding(.leading, 27)
                }
                .overlay(alignment: .bottomTrailing) {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    ProfileV41Style.gold.opacity(0.20),
                                    ProfileV41Style.gold.opacity(0.00)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 88
                            )
                        )
                        .frame(width: 176, height: 176)
                        .offset(x: 58, y: 78)
                        .allowsHitTesting(false)
                }
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(ProfileV41Style.strongBorder, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 18, y: 10)
    }
}

private struct ProfileV41InitialsBadge: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            STRQColors.white.opacity(0.16),
                            STRQColors.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .strokeBorder(ProfileV41Style.strongBorder, lineWidth: 1)

            Text(verbatim: "MR")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(STRQColors.primaryText)
        }
        .frame(width: 48, height: 48)
        .accessibilityHidden(true)
    }
}

private struct ProfileV41InlineFactRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(ProfileV41Style.steel.opacity(0.74))
                .frame(width: 6, height: 6)

            Text(verbatim: text)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(.horizontal, 10)
        .frame(height: 30)
        .background(STRQColors.white.opacity(0.060), in: Capsule())
        .overlay(Capsule().strokeBorder(STRQColors.white.opacity(0.10), lineWidth: 1))
    }
}

private struct ProfileV41ControlDoors: View {
    private let rows: [ProfileV41DoorData] = [
        ProfileV41DoorData(icon: "figure.strengthtraining.traditional", title: "Training Setup", detail: "Plan, gear, focus"),
        ProfileV41DoorData(icon: "slider.horizontal.3", title: "Coach & Inputs", detail: "Balanced · Health connected"),
        ProfileV41DoorData(icon: "person.crop.circle", title: "Account & Data", detail: "Free · Not signed in")
    ]

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                ProfileV41DoorRow(row: row)

                if index < rows.count - 1 {
                    ProfileV41Divider()
                        .padding(.leading, 54)
                }
            }
        }
        .padding(.vertical, 5)
        .background(ProfileV41Style.rowSurface, in: .rect(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(ProfileV41Style.softBorder, lineWidth: 1)
        )
    }
}

private struct ProfileV41DoorRow: View {
    let row: ProfileV41DoorData

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: row.icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(STRQColors.primaryText)
                .frame(width: 34, height: 34)
                .background(STRQColors.white.opacity(0.07), in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(verbatim: row.title)
                    .font(STRQTypography.labelLarge)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)

                Text(verbatim: row.detail)
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(STRQColors.mutedText)
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 58)
        .contentShape(Rectangle())
    }
}

private struct ProfileV41Section: View {
    let title: String
    let rows: [ProfileV41RowData]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(verbatim: title)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .padding(.horizontal, 2)

            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    ProfileV41SettingRow(row: row)

                    if index < rows.count - 1 {
                        ProfileV41Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .background(ProfileV41Style.rowSurface, in: .rect(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(ProfileV41Style.softBorder, lineWidth: 1)
            )
        }
    }
}

private struct ProfileV41SettingRow: View {
    let row: ProfileV41RowData

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: row.icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(row.tint)
                .frame(width: 32, height: 32)
                .background(row.tint.opacity(0.09), in: Circle())

            Text(verbatim: row.title)
                .font(STRQTypography.body)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.74)

            Spacer(minLength: 8)

            Text(verbatim: row.detail)
                .font(STRQTypography.caption)
                .foregroundStyle(row.detailColor)
                .lineLimit(1)
                .minimumScaleFactor(0.70)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .black))
                .foregroundStyle(STRQColors.mutedText.opacity(0.86))
        }
        .padding(.horizontal, 12)
        .frame(minHeight: 54)
    }
}

private struct ProfileV41Divider: View {
    var body: some View {
        Rectangle()
            .fill(STRQColors.white.opacity(0.075))
            .frame(height: 1 / UIScreen.main.scale)
    }
}

private struct ProfileV41DoorData {
    let icon: String
    let title: String
    let detail: String
}

private struct ProfileV41RowData {
    enum Tone {
        case standard
        case muted
        case warning
    }

    let icon: String
    let title: String
    let detail: String
    let tone: Tone

    init(icon: String, title: String, detail: String, tone: Tone = .standard) {
        self.icon = icon
        self.title = title
        self.detail = detail
        self.tone = tone
    }

    var tint: Color {
        switch tone {
        case .standard:
            return ProfileV41Style.steel
        case .muted:
            return STRQColors.mutedText
        case .warning:
            return ProfileV41Style.warning
        }
    }

    var detailColor: Color {
        switch tone {
        case .standard:
            return STRQColors.secondaryText
        case .muted:
            return STRQColors.mutedText
        case .warning:
            return ProfileV41Style.warning
        }
    }
}

private enum ProfileV41Style {
    static let background = Color(red: 0.025, green: 0.026, blue: 0.025)
    static let rowSurface = Color(red: 0.080, green: 0.082, blue: 0.078)
    static let passportSurface = LinearGradient(
        colors: [
            Color(red: 0.118, green: 0.116, blue: 0.102),
            Color(red: 0.070, green: 0.073, blue: 0.071)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static let steel = Color(red: 0.680, green: 0.725, blue: 0.710)
    static let gold = Color(red: 0.870, green: 0.740, blue: 0.475)
    static let warning = Color(red: 0.980, green: 0.500, blue: 0.420)
    static let softBorder = STRQColors.white.opacity(0.090)
    static let strongBorder = STRQColors.white.opacity(0.145)
}
#endif
