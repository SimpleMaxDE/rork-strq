import SwiftUI

#if DEBUG
struct STRQDesignSystemPreviewView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: STRQSpacing.sectionGap) {
                ColorSurfacesSection()
                TypographySection()
                ButtonsSection()
                ChipsBadgesSection()
                CardsMetricSection()
                ProgressSection()
                ListScheduleSection()
                IconsSection()
            }
            .padding(.horizontal, STRQSpacing.screenHorizontalMargin)
            .padding(.vertical, STRQSpacing.xl)
        }
        .background(STRQColors.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

private struct STRQDesignSystemPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        STRQDesignSystemPreviewView()
            .previewDisplayName("STRQ Design System")
    }
}

private struct PreviewSection<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.md) {
            Text(title)
                .font(STRQTypography.headingXS)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            content
        }
    }
}

private struct ColorSurfacesSection: View {
    var body: some View {
        PreviewSection("Colors / Surfaces") {
            VStack(alignment: .leading, spacing: STRQSpacing.sm) {
                TokenSwatch(
                    title: "Base background",
                    value: "STRQColors.baseBackground",
                    color: STRQColors.baseBackground,
                    borderColor: STRQColors.borderMuted
                )
                TokenSwatch(
                    title: "Elevated card",
                    value: "STRQColors.elevatedCardSurface",
                    color: STRQColors.elevatedCardSurface
                )
                TokenSwatch(
                    title: "Selected card",
                    value: "STRQColors.selectedSurface",
                    color: STRQColors.selectedSurface,
                    borderColor: STRQColors.selectedBorder
                )
                TokenSwatch(
                    title: "Inset surface",
                    value: "STRQColors.insetSurface",
                    color: STRQColors.insetSurface
                )

                BorderExamples()
            }
        }
    }
}

private struct TokenSwatch: View {
    let title: String
    let value: String
    let color: Color
    var borderColor: Color = STRQColors.borderMuted

    var body: some View {
        HStack(spacing: STRQSpacing.sm) {
            RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                .fill(color)
                .frame(width: 56, height: 56)
                .overlay(
                    RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                        .strokeBorder(borderColor, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(STRQTypography.bodyMedium)
                    .foregroundStyle(STRQColors.primaryText)

                Text(value)
                    .font(STRQTypography.captionRegular)
                    .foregroundStyle(STRQColors.mutedText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: STRQSpacing.xs)
        }
        .padding(STRQSpacing.sm)
        .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.lg))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.lg, style: .continuous)
                .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
        )
    }
}

private struct BorderExamples: View {
    var body: some View {
        STRQCard(.compact) {
            VStack(alignment: .leading, spacing: STRQSpacing.sm) {
                Text("Border examples")
                    .font(STRQTypography.cardTitle)
                    .foregroundStyle(STRQColors.primaryText)

                HStack(spacing: STRQSpacing.sm) {
                    BorderSample(title: "Subtle", color: STRQColors.borderMuted, width: 1)
                    BorderSample(title: "Selected", color: STRQColors.selectedBorder, width: 1.5)
                    BorderSample(title: "Danger", color: STRQColors.dangerRed, width: 1)
                }
            }
        }
    }
}

private struct BorderSample: View {
    let title: String
    let color: Color
    let width: CGFloat

    var body: some View {
        VStack(spacing: STRQSpacing.xs) {
            RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                .fill(STRQColors.insetSurface)
                .frame(height: 48)
                .overlay(
                    RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                        .strokeBorder(color, lineWidth: width)
                )

            Text(title)
                .font(STRQTypography.caption)
                .foregroundStyle(STRQColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct TypographySection: View {
    var body: some View {
        PreviewSection("Typography") {
            STRQCard {
                VStack(alignment: .leading, spacing: STRQSpacing.md) {
                    TypographySample(label: "Title", text: "Train with intent", font: STRQTypography.title)
                    TypographySample(label: "Heading", text: "Today overview", font: STRQTypography.headingMedium)
                    TypographySample(label: "Card title", text: "Recovery snapshot", font: STRQTypography.cardTitle)
                    TypographySample(label: "Body", text: "Preview copy stays local to this debug gallery.", font: STRQTypography.body)
                    TypographySample(label: "Caption", text: "Updated just for QA", font: STRQTypography.caption)
                    TypographySample(label: "Metric numbers", text: "87%", font: STRQTypography.metricLarge)
                }
            }
        }
    }
}

private struct TypographySample: View {
    let label: String
    let text: String
    let font: Font

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.xxs) {
            Text(label)
                .font(STRQTypography.caption)
                .foregroundStyle(STRQColors.mutedText)

            Text(text)
                .font(font)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
        }
    }
}

private struct ButtonsSection: View {
    var body: some View {
        PreviewSection("Buttons") {
            VStack(alignment: .leading, spacing: STRQSpacing.sm) {
                STRQButton("Primary", icon: .play, variant: .primary) {}
                STRQButton("Secondary", icon: .star, variant: .secondary) {}
                STRQButton("Destructive", icon: .trash, variant: .destructive) {}

                HStack(spacing: STRQSpacing.sm) {
                    STRQButton("Ghost", icon: .more, variant: .ghost) {}
                    STRQButton("Compact", icon: .check, variant: .compact) {}
                }

                HStack(spacing: STRQSpacing.sm) {
                    STRQButton(icon: .settings) {}
                    STRQButton(icon: .search, variant: .icon) {}
                    STRQButton("Disabled", icon: .lock, variant: .secondary, isDisabled: true) {}
                }
            }
        }
    }
}

private struct ChipsBadgesSection: View {
    private let columns = [
        GridItem(.adaptive(minimum: 104), spacing: STRQSpacing.xs)
    ]

    var body: some View {
        PreviewSection("Chips / Badges") {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                LazyVGrid(columns: columns, alignment: .leading, spacing: STRQSpacing.xs) {
                    STRQChip(label: "Neutral")
                    STRQChip(label: "Selected", icon: .check, tone: .selected)
                    STRQChip(label: "Success", icon: .checkCircle, tone: .success)
                    STRQChip(label: "Warning", icon: .warning, tone: .warning)
                    STRQChip(label: "Danger", icon: .warning, tone: .danger)
                    STRQChip(label: "Disabled", icon: .lock, tone: .disabled)
                }

                HStack(spacing: STRQSpacing.xs) {
                    STRQBadge(text: "12", variant: .count, tone: .warning)
                    STRQBadge(text: "Ready", icon: .checkCircle, variant: .status, tone: .success)
                    STRQBadge(text: "Milestone", icon: .trophy, variant: .achievement, tone: .orange)
                }
            }
        }
    }
}

private struct CardsMetricSection: View {
    private let columns = [
        GridItem(.adaptive(minimum: 148), spacing: STRQSpacing.sm)
    ]

    var body: some View {
        PreviewSection("Cards / Metric Cards") {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                STRQCard {
                    CardPreviewContent(title: "Standard card", detail: "Default surface, padding, radius, and border.")
                }

                STRQCard(.elevated) {
                    CardPreviewContent(title: "Elevated card", detail: "Raised surface token with the same component shell.")
                }

                STRQCard(.selected) {
                    CardPreviewContent(title: "Selected card", detail: "Selected surface and border for active states.")
                }

                LazyVGrid(columns: columns, spacing: STRQSpacing.sm) {
                    STRQMetricCard(
                        value: "87",
                        label: "Readiness",
                        icon: .recovery,
                        unit: "%",
                        tint: STRQColors.successGreen
                    )

                    STRQMetricCard(
                        value: "4",
                        label: "Sessions",
                        icon: .calendar,
                        detail: "This week",
                        progress: 0.8,
                        tint: STRQColors.orangePrimary
                    )
                }
            }
        }
    }
}

private struct CardPreviewContent: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.xs) {
            Text(title)
                .font(STRQTypography.cardTitle)
                .foregroundStyle(STRQColors.primaryText)

            Text(detail)
                .font(STRQTypography.bodySmall)
                .foregroundStyle(STRQColors.secondaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ProgressSection: View {
    var body: some View {
        PreviewSection("Progress") {
            STRQCard {
                VStack(alignment: .leading, spacing: STRQSpacing.md) {
                    STRQProgressBar(
                        value: 0.72,
                        tint: STRQColors.orangePrimary,
                        label: "Progress bar",
                        valueText: "72%"
                    )

                    STRQProgressBar(
                        value: 0.88,
                        tint: STRQColors.successGreen,
                        label: "Success",
                        valueText: "88%"
                    )

                    STRQProgressBar(
                        value: 0.48,
                        tint: STRQColors.warningAmber,
                        label: "Warning",
                        valueText: "48%"
                    )

                    STRQProgressBar(
                        value: 0.24,
                        tint: STRQColors.dangerRed,
                        label: "Danger",
                        valueText: "24%"
                    )

                    HStack(alignment: .center, spacing: STRQSpacing.lg) {
                        STRQProgressRing(
                            value: 0.72,
                            variant: .score,
                            tint: STRQColors.orangePrimary,
                            label: "Score",
                            valueText: "72"
                        )

                        STRQProgressRing(
                            value: 0.88,
                            variant: .compact,
                            tint: STRQColors.successGreen,
                            label: "OK",
                            valueText: "88"
                        )

                        STRQProgressRing(
                            value: 0.48,
                            variant: .compact,
                            tint: STRQColors.warningAmber,
                            label: "Med",
                            valueText: "48"
                        )

                        STRQProgressRing(
                            value: 0.34,
                            variant: .compact,
                            tint: STRQColors.dangerRed,
                            label: "Low",
                            valueText: "34"
                        )
                    }
                }
            }
        }
    }
}

private struct ListScheduleSection: View {
    var body: some View {
        PreviewSection("List / Schedule") {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                STRQCard(.compact) {
                    VStack(spacing: 0) {
                        STRQListItem(
                            leadingIcon: .barbell,
                            title: "Strength focus",
                            subtitle: "Heavy upper work",
                            trailingValue: "45m",
                            showsChevron: true
                        )

                        STRQListItem(
                            leadingIcon: .recovery,
                            title: "Recovery check",
                            subtitle: "Sleep, soreness, and readiness",
                            trailingValue: "87%",
                            showsChevron: true,
                            showsDivider: false,
                            tint: STRQColors.successGreen
                        )
                    }
                }

                STRQScheduleRow(
                    dateTitle: "29",
                    dateSubtitle: "WED",
                    title: "Upper Strength",
                    subtitle: "Push and pull",
                    duration: "45m",
                    icon: .barbell,
                    isSelected: true
                )

                STRQScheduleCard(
                    title: "Schedule card",
                    subtitle: "Preview",
                    rows: [
                        STRQScheduleRow(
                            dateTitle: "30",
                            dateSubtitle: "THU",
                            title: "Lower Power",
                            subtitle: "Hinge and squat",
                            duration: "50m",
                            icon: .train
                        ),
                        STRQScheduleRow(
                            dateTitle: "01",
                            dateSubtitle: "FRI",
                            title: "Recovery",
                            subtitle: "Mobility and walk",
                            duration: "25m",
                            icon: .recovery
                        )
                    ]
                )
            }
        }
    }
}

private struct IconsSection: View {
    var body: some View {
        PreviewSection("Icons") {
            IconGrid()
        }
    }
}

private struct IconGrid: View {
    private let columns = [
        GridItem(.adaptive(minimum: 84), spacing: STRQSpacing.xs)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: STRQSpacing.xs) {
            ForEach(STRQIcon.allCases, id: \.self) { icon in
                IconGridCell(icon: icon)
            }
        }
    }
}

private struct IconGridCell: View {
    let icon: STRQIcon

    var body: some View {
        VStack(spacing: STRQSpacing.xs) {
            STRQIconView(
                icon,
                size: STRQSpacing.iconLG,
                tint: STRQColors.orangePrimary,
                templateRendering: true
            )

            Text(caseLabel)
                .font(STRQTypography.micro)
                .foregroundStyle(STRQColors.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.68)
                .frame(height: 28)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 84)
        .padding(STRQSpacing.xs)
        .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.lg))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.lg, style: .continuous)
                .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
        )
    }

    private var caseLabel: String {
        String(describing: icon)
    }
}
#endif
