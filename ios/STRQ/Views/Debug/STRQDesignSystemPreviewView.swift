import SwiftUI

#if DEBUG
struct STRQDesignSystemPreviewView: View {
    @State private var showActiveWorkoutLoggerPrototype = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: STRQSpacing.sectionGap) {
                TokenParitySection()
                ColorSurfacesSection()
                TypographySection()
                ButtonsSection()
                ComponentsSection()
                CardsMetricSection()
                ProgressSection()
                ActiveWorkoutLoggerPrototypeSection {
                    showActiveWorkoutLoggerPrototype = true
                }
                ProgressV2PrototypeSection()
                ProgressV3ConceptLabSection()
                ProgressV4HybridCandidateSection()
                ProgressV5ExperienceSection()
                ListScheduleSection()
                HumanBodyOverlayPilotSection()
                IconsSection()
            }
            .padding(.horizontal, STRQSpacing.screenHorizontalMargin)
            .padding(.vertical, STRQSpacing.xl)
        }
        .background(STRQColors.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .fullScreenCover(isPresented: $showActiveWorkoutLoggerPrototype) {
            ActiveWorkoutLoggerPrototypeView(isFullscreen: true)
        }
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
                .font(STRQTypography.sectionTitle)
                .tracking(STRQTypography.headingXSTracking)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            content
        }
    }
}

private struct TokenParitySection: View {
    private let columns = [
        GridItem(.adaptive(minimum: 132), spacing: STRQSpacing.xs)
    ]

    var body: some View {
        PreviewSection("Token Parity") {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                LazyVGrid(columns: columns, alignment: .leading, spacing: STRQSpacing.xs) {
                    TokenMiniSwatch(title: "Base", value: "black", color: STRQColors.baseBackground)
                    TokenMiniSwatch(title: "Card", value: "gray900", color: STRQColors.cardSurface)
                    TokenMiniSwatch(title: "Elevated", value: "gray800", color: STRQColors.elevatedCardSurface)
                    TokenMiniSwatch(title: "Inset", value: "gray950", color: STRQColors.insetSurface)
                    TokenMiniSwatch(title: "Primary Text", value: "white", color: STRQColors.primaryText)
                    TokenMiniSwatch(title: "Secondary Text", value: "gray300", color: STRQColors.secondaryText)
                    TokenMiniSwatch(title: "Muted Text", value: "gray500", color: STRQColors.mutedText)
                    TokenMiniSwatch(title: "Border", value: "gray700", color: STRQColors.borderMuted)
                    TokenMiniSwatch(title: "Success", value: "lime500", color: STRQColors.success)
                    TokenMiniSwatch(title: "Warning", value: "amber500", color: STRQColors.warning)
                    TokenMiniSwatch(title: "Danger", value: "rose500", color: STRQColors.danger)
                    TokenMiniSwatch(title: "Warm Accent", value: "optional", color: STRQColors.warmAccent)
                }

                VStack(alignment: .leading, spacing: STRQSpacing.sm) {
                    Text("Spacing / Radii")
                        .font(STRQTypography.labelSmall)
                        .tracking(STRQTypography.labelSmallTracking)
                        .foregroundStyle(STRQColors.secondaryText)

                    HStack(alignment: .bottom, spacing: STRQSpacing.md) {
                        TokenBlock(label: "8", size: STRQSpacing.xs, radius: STRQRadii.xs)
                        TokenBlock(label: "12", size: STRQSpacing.sm, radius: STRQRadii.sm)
                        TokenBlock(label: "16", size: STRQSpacing.md, radius: STRQRadii.md)
                        TokenBlock(label: "24", size: STRQSpacing.xl, radius: STRQRadii.card)
                        TokenBlock(label: "32", size: STRQSpacing.xxl, radius: STRQRadii.largeCard)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                LazyVGrid(columns: columns, alignment: .leading, spacing: STRQSpacing.xs) {
                    ShadowTokenSample(title: "Subtle", token: STRQEffects.subtleShadow)
                    ShadowTokenSample(title: "Card", token: STRQEffects.cardShadow)
                    ShadowTokenSample(title: "Soft", token: STRQEffects.softShadow)
                    ShadowTokenSample(title: "Selected", token: STRQEffects.selectionGlow)
                }

                STRQCard(.compact) {
                    VStack(alignment: .leading, spacing: STRQSpacing.sm) {
                        TypographyRoleSample(name: "screenTitle", text: "Today", font: STRQTypography.screenTitle)
                        TypographyRoleSample(name: "sectionTitle", text: "Training", font: STRQTypography.sectionTitle)
                        TypographyRoleSample(name: "body", text: "Readable interface copy", font: STRQTypography.body)
                        TypographyRoleSample(name: "metric", text: "87%", font: STRQTypography.metricMedium)
                        TypographyRoleSample(name: "button", text: "START", font: STRQTypography.button)
                    }
                }
            }
        }
    }
}

private struct ColorSurfacesSection: View {
    var body: some View {
        PreviewSection("Colors / Surfaces") {
            VStack(alignment: .leading, spacing: STRQSpacing.sm) {
                TokenSwatch(title: "Base background", value: "baseBackground", color: STRQColors.baseBackground)
                TokenSwatch(title: "Card surface", value: "cardSurface", color: STRQColors.cardSurface)
                TokenSwatch(title: "Elevated surface", value: "elevatedCardSurface", color: STRQColors.elevatedCardSurface)
                TokenSwatch(title: "Selected surface", value: "selectedSurface", color: STRQColors.selectedSurface, borderColor: STRQColors.selectedBorder)
                TokenSwatch(title: "Primary action", value: "actionSurface", color: STRQColors.actionSurface, borderColor: STRQColors.secondaryAccent)

                HStack(spacing: STRQSpacing.sm) {
                    BorderSample(title: "Subtle", color: STRQColors.borderMuted, width: 1)
                    BorderSample(title: "Selected", color: STRQColors.selectedBorder, width: 1.5)
                    BorderSample(title: "Danger", color: STRQColors.dangerRed, width: 1)
                }
            }
        }
    }
}

private struct TokenMiniSwatch: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.xs) {
            RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                .fill(color)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                        .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(value)
                    .font(STRQTypography.micro)
                    .foregroundStyle(STRQColors.mutedText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .padding(STRQSpacing.xs)
        .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.lg))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.lg, style: .continuous)
                .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
        )
    }
}

private struct TokenBlock: View {
    let label: String
    let size: CGFloat
    let radius: CGFloat

    var body: some View {
        VStack(spacing: STRQSpacing.xs) {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(STRQColors.controlSurface)
                .frame(width: max(32, size * 2), height: max(32, size * 2))
                .overlay(
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .strokeBorder(STRQColors.selectedBorder, lineWidth: 1)
                )

            Text(label)
                .font(STRQTypography.micro)
                .foregroundStyle(STRQColors.secondaryText)
                .lineLimit(1)
        }
    }
}

private struct ShadowTokenSample: View {
    let title: String
    let token: STRQShadowToken

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.xs) {
            RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                .fill(STRQColors.elevatedCardSurface)
                .frame(height: 44)
                .shadow(color: token.color, radius: token.radius, x: token.x, y: token.y)

            Text(title)
                .font(STRQTypography.caption)
                .foregroundStyle(STRQColors.secondaryText)
                .lineLimit(1)
        }
        .padding(STRQSpacing.xs)
    }
}

private struct TypographyRoleSample: View {
    let name: String
    let text: String
    let font: Font

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: STRQSpacing.sm) {
            Text(name)
                .font(STRQTypography.micro)
                .foregroundStyle(STRQColors.mutedText)
                .frame(width: 76, alignment: .leading)

            Text(text)
                .font(font)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
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
                    .font(STRQTypography.textMedium)
                    .foregroundStyle(STRQColors.primaryText)

                Text(value)
                    .font(STRQTypography.caption)
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
    private let weightColumns = [
        GridItem(.adaptive(minimum: 116), spacing: STRQSpacing.xs)
    ]

    var body: some View {
        PreviewSection("Typography") {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                Text(STRQTypography.fontStatusText)
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQTypography.isWorkSansActive ? STRQColors.successGreen : STRQColors.warningAmber)
                    .padding(.horizontal, STRQSpacing.sm)
                    .padding(.vertical, STRQSpacing.xs)
                    .background(STRQColors.controlSurface, in: .rect(cornerRadius: STRQRadii.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                            .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
                    )

                STRQCard {
                    VStack(alignment: .leading, spacing: STRQSpacing.md) {
                        TypographySample(label: "Display / Bold", text: "Display", font: STRQTypography.displaySmall, tracking: STRQTypography.displaySmallTracking)
                        TypographySample(label: "Heading / Bold", text: "Stronger hierarchy", font: STRQTypography.headingMedium, tracking: STRQTypography.headingMediumTracking)
                        TypographySample(label: "Text / Medium", text: "Primary interface copy", font: STRQTypography.textLarge)
                        TypographySample(label: "Paragraph / Regular", text: "Readable body copy uses neutral tracking and a relaxed line-height token.", font: STRQTypography.paragraphMedium)
                        TypographySample(label: "Label / Bold", text: "TRAINING LOAD", font: STRQTypography.labelMedium, tracking: STRQTypography.labelMediumTracking)
                    }
                }

                STRQCard(.compact) {
                    VStack(alignment: .leading, spacing: STRQSpacing.sm) {
                        Text("Weights")
                            .font(STRQTypography.cardTitle)
                            .foregroundStyle(STRQColors.primaryText)

                        LazyVGrid(columns: weightColumns, alignment: .leading, spacing: STRQSpacing.xs) {
                            WeightPill(title: "Regular", font: STRQTypography.font(size: 18, weight: .regular))
                            WeightPill(title: "Medium", font: STRQTypography.textFont(size: 18, weight: .medium))
                            WeightPill(title: "SemiBold", font: STRQTypography.labelFont(size: 18, weight: .semibold))
                            WeightPill(title: "Bold", font: STRQTypography.headingFont(size: 18, weight: .bold))
                            if STRQTypography.isWorkSansExtraBoldActive {
                                WeightPill(title: "ExtraBold", font: STRQTypography.metricFont(size: 18, weight: .heavy))
                            }
                            if STRQTypography.isWorkSansBlackActive {
                                WeightPill(title: "Black", font: STRQTypography.metricFont(size: 18, weight: .black))
                            }
                        }
                    }
                }

                STRQCard(.compact) {
                    VStack(alignment: .leading, spacing: STRQSpacing.sm) {
                        TypographySample(label: "screenTitle", text: "Today", font: STRQTypography.screenTitle, tracking: STRQTypography.headingXSTracking)
                        TypographySample(label: "sectionTitle", text: "Training plan", font: STRQTypography.sectionTitle)
                        TypographySample(label: "cardTitle", text: "Recovery snapshot", font: STRQTypography.cardTitle)
                        TypographySample(label: "body", text: "Plan details, cues, and supporting interface copy.", font: STRQTypography.body)
                        TypographySample(label: "caption", text: "Updated just now", font: STRQTypography.caption)
                    }
                }

                STRQCard(.compact) {
                    VStack(alignment: .leading, spacing: STRQSpacing.sm) {
                        TypographySample(label: "metric", text: "87%", font: STRQTypography.metricLarge)
                        TypographySample(label: "button", text: "START NOW", font: STRQTypography.button)
                        TypographySample(label: "chip", text: "Ready", font: STRQTypography.chip)
                        TypographySample(label: "label", text: "SESSION QUALITY", font: STRQTypography.label, tracking: STRQTypography.labelMediumTracking)
                    }
                }
            }
        }
    }
}

private struct TypographySample: View {
    let label: String
    let text: String
    let font: Font
    var tracking: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.xxs) {
            Text(label)
                .font(STRQTypography.caption)
                .foregroundStyle(STRQColors.mutedText)

            Text(text)
                .font(font)
                .tracking(tracking)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.42)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct WeightPill: View {
    let title: String
    let font: Font

    var body: some View {
        Text(title)
            .font(font)
            .foregroundStyle(STRQColors.primaryText)
            .lineLimit(1)
            .minimumScaleFactor(0.74)
            .frame(maxWidth: .infinity)
            .padding(.vertical, STRQSpacing.sm)
            .background(STRQColors.controlSurface, in: .rect(cornerRadius: STRQRadii.md))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                    .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
            )
    }
}

private struct ButtonsSection: View {
    var body: some View {
        PreviewSection("Buttons") {
            VStack(alignment: .leading, spacing: STRQSpacing.sm) {
                STRQButton("Primary", icon: .play, trailingIcon: .arrowRight, variant: .primary) {}
                STRQButton("Secondary", icon: .star, variant: .secondary) {}
                STRQButton("Destructive", icon: .trash, variant: .destructive) {}
                STRQButton("Disabled", icon: .lock, variant: .primary, isDisabled: true) {}
                STRQButton("Loading", variant: .secondary, isLoading: true) {}

                HStack(spacing: STRQSpacing.sm) {
                    STRQButton("Ghost", icon: .more, variant: .ghost) {}
                    STRQButton("Compact", icon: .check, variant: .compact) {}
                    STRQButton(icon: .plus, accessibilityLabel: "Icon only") {}
                }

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: STRQSpacing.xs)], alignment: .leading, spacing: STRQSpacing.xs) {
                    STRQIconButton(icon: .settings, variant: .primary, accessibilityLabel: "Primary icon button") {}
                    STRQIconButton(icon: .search, variant: .neutral, accessibilityLabel: "Neutral icon button") {}
                    STRQIconButton(icon: .check, variant: .selected, accessibilityLabel: "Selected icon button") {}
                    STRQIconButton(icon: .more, variant: .ghost, size: .compact, accessibilityLabel: "Compact ghost icon button") {}
                    STRQIconButton(icon: .more, variant: .ghost) {}
                    STRQIconButton(icon: .trash, variant: .destructive) {}
                    STRQIconButton(icon: .lock, isDisabled: true) {}
                }
            }
        }
    }
}

private struct ComponentsSection: View {
    @State private var searchText = "upper"
    @State private var inputText = "Strength block"
    @State private var toggleOn = true

    private let chipColumns = [
        GridItem(.adaptive(minimum: 104), spacing: STRQSpacing.xs)
    ]

    var body: some View {
        PreviewSection("Components") {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                STRQNavigationBar(
                    title: "Foundation Lab",
                    subtitle: "Debug route",
                    leading: {
                        STRQIconButton(icon: .chevronLeft, variant: .ghost) {}
                    },
                    trailing: {
                        HStack(spacing: STRQSpacing.xs) {
                            STRQIconButton(icon: .bell) {}
                            STRQAvatar(initials: "SQ", size: .sm)
                        }
                    }
                )

                LazyVGrid(columns: chipColumns, alignment: .leading, spacing: STRQSpacing.xs) {
                    STRQChip(label: "Neutral")
                    STRQChip(label: "Selected", icon: .check, trailingIcon: .chevronRight, tone: .selected)
                    STRQChip(label: "Success", icon: .checkCircle, tone: .success)
                    STRQChip(label: "Warning", icon: .warning, tone: .warning)
                    STRQChip(label: "Danger", icon: .warning, tone: .danger)
                    STRQChip(label: "Disabled", icon: .lock, tone: .disabled)
                    STRQChip(label: "Compact", icon: .bolt, size: .compact)
                }

                LazyVGrid(columns: chipColumns, alignment: .leading, spacing: STRQSpacing.xs) {
                    STRQBadge(text: "12", variant: .count, tone: .neutral)
                    STRQBadge(text: "Ready", icon: .checkCircle, variant: .status, tone: .success)
                    STRQBadge(text: "Caution", icon: .warning, variant: .status, tone: .warning)
                    STRQBadge(text: "Risk", icon: .warning, variant: .status, tone: .danger)
                    STRQBadge(text: "PR", icon: .trophy, variant: .achievement, tone: .selected)
                }

                STRQSearchField(text: $searchText, placeholder: "Search exercises")
                STRQSearchField(text: .constant(""), placeholder: "Disabled search", isDisabled: true)
                STRQInputField("Plan name", text: $inputText, placeholder: "Enter plan name", icon: .edit, helper: STRQTypography.fontStatusText)
                STRQInputField("Error state", text: .constant(""), placeholder: "Required field", icon: .warning, errorMessage: "This field needs attention.")
                STRQToggleRow(title: "Neutral selected state", subtitle: "Toggle row from list-item control patterns", icon: .checkCircle, isOn: $toggleOn)
                STRQToggleRow(title: "Disabled toggle", subtitle: "Component-level disabled state", icon: .lock, isDisabled: true, isCompact: true, isOn: .constant(false))

                HStack(spacing: STRQSpacing.sm) {
                    STRQAvatar(initials: "AL", size: .md)
                    STRQAvatar(initials: "MW", size: .lg, tint: STRQColors.selectedSurface)
                    STRQAvatar(size: .xl, icon: .profile, tint: STRQColors.controlSurface)

                    VStack(alignment: .leading, spacing: STRQSpacing.xxs) {
                        STRQRatingStars(rating: 4)
                        STRQRatingStars(rating: 3, size: STRQSpacing.iconSM, filledTint: STRQColors.warningAmber)
                    }
                }

                STRQModalSurface(title: "Modal surface") {
                    Text("Reusable elevated shell with STRQ-owned naming.")
                        .font(STRQTypography.paragraphSmall)
                        .foregroundStyle(STRQColors.secondaryText)
                }

                STRQBottomSheetSurface(title: "Bottom sheet surface") {
                    HStack(spacing: STRQSpacing.xs) {
                        STRQChip(label: "Handle")
                        STRQChip(label: "Glass", icon: .check)
                    }
                }

                STRQEmptyStateCard(
                    icon: .calendar,
                    title: "No sessions scheduled",
                    message: "Empty states stay reusable and data-free in the foundation lab.",
                    actionTitle: "Add"
                ) {}
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
                    CardPreviewContent(title: "Selected card", detail: "Neutral selected surface and border.")
                }

                STRQCard(.compact) {
                    CardPreviewContent(title: "Compact card", detail: "Reduced padding for dense rows.")
                }

                STRQCard(.hero) {
                    CardPreviewContent(title: "Hero card", detail: "Large card radius and elevated surface for rare feature modules.")
                }

                STRQSurface(variant: .inset, border: .subtle, radius: .card, padding: STRQSpacing.md) {
                    CardPreviewContent(title: "Inset surface", detail: "Primitive surface shell, separate from card semantics.")
                }

                LazyVGrid(columns: columns, spacing: STRQSpacing.sm) {
                    STRQMetricCard(value: "87", label: "Readiness", icon: .recovery, unit: "%", delta: "+4%", tint: STRQColors.successGreen)
                    STRQMetricCard(value: "4", label: "Sessions", icon: .calendar, detail: "This week", progress: 0.8)
                    STRQMetricCard(value: "42", label: "Load", icon: .activityRing, detail: "Neutral progress", progress: 0.42)
                    STRQMetricCard(value: "12", label: "Compact", icon: .bolt, unit: "pts", delta: "-2%", progress: 0.32, size: .compact, tint: STRQColors.warningAmber)
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
                .font(STRQTypography.paragraphSmall)
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
            VStack(alignment: .leading, spacing: STRQSpacing.sm) {
                STRQCard {
                    VStack(alignment: .leading, spacing: STRQSpacing.md) {
                        STRQProgressBar(value: 0.72, tone: .neutral, label: "Neutral progress", valueText: "72%")
                        STRQProgressBar(value: 0.88, tone: .success, label: "Success", valueText: "88%")
                        STRQProgressBar(value: 0.48, tone: .warning, label: "Warning", valueText: "48%")
                        STRQProgressBar(value: 0.24, tone: .danger, label: "Danger", valueText: "24%")
                        STRQProgressBar(value: 0.36, height: 4, tone: .neutral, compact: true)

                        HStack(alignment: .center, spacing: STRQSpacing.lg) {
                            STRQProgressRing(value: 0.72, variant: .score, tone: .neutral, label: "Score", valueText: "72")
                            STRQProgressRing(value: 0.88, variant: .compact, tone: .success, label: "OK", valueText: "88")
                            STRQProgressRing(value: 0.48, variant: .compact, tone: .warning, label: "Med", valueText: "48")
                            STRQProgressRing(value: 0.34, variant: .compact, tone: .danger, label: "Low", valueText: "34")
                        }
                    }
                }

                STRQProgressRow(
                    label: "Training Load",
                    value: "72%",
                    detail: "Weekly target pace",
                    icon: .train,
                    progress: 0.72
                )

                STRQProgressRow(
                    label: "Volume Target",
                    value: "88%",
                    detail: "Four-week strength block",
                    icon: .activityRing,
                    progress: 0.88,
                    tint: STRQColors.successGreen
                )
            }
        }
    }
}

private struct ProgressV2PrototypeSection: View {
    var body: some View {
        PreviewSection("Progress V2 Prototype") {
            ProgressV2PrototypeView()
                .frame(height: 1080)
                .clipShape(.rect(cornerRadius: STRQRadii.largeCard))
                .overlay(
                    RoundedRectangle(cornerRadius: STRQRadii.largeCard, style: .continuous)
                        .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
                )
        }
    }
}

private struct ActiveWorkoutLoggerPrototypeSection: View {
    let onOpen: () -> Void

    var body: some View {
        PreviewSection("Active Workout Logger Prototype") {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                HStack(alignment: .top, spacing: STRQSpacing.md) {
                    STRQIconView(.barbell, size: STRQSpacing.iconLG, tint: STRQColors.primaryAccent)
                        .frame(width: 52, height: 52)
                        .background(STRQColors.primaryAccent.opacity(0.14), in: .rect(cornerRadius: STRQRadii.largeCard))
                        .overlay(
                            RoundedRectangle(cornerRadius: STRQRadii.largeCard, style: .continuous)
                                .strokeBorder(STRQColors.primaryAccent.opacity(0.22), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: STRQSpacing.xs) {
                        Text("Fullscreen screenshot prototype")
                            .font(STRQTypography.cardTitle)
                            .foregroundStyle(STRQColors.primaryText)
                        Text("Runs outside the design-system scroll and tab bar so the sticky logger control can be judged in a real active-workout viewport.")
                            .font(STRQTypography.caption)
                            .foregroundStyle(STRQColors.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Button(action: onOpen) {
                    HStack(spacing: STRQSpacing.sm) {
                        STRQIconView(.arrowRight, size: STRQSpacing.iconSM, tint: STRQColors.actionText)
                        Text("Open active logger prototype")
                            .font(STRQTypography.button)
                            .foregroundStyle(STRQColors.actionText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(STRQColors.primaryAccent, in: .rect(cornerRadius: STRQRadii.button))
                }
                .buttonStyle(.plain)
            }
            .padding(STRQSpacing.md)
            .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.largeCard))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.largeCard, style: .continuous)
                    .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
            )
        }
    }
}

private struct ProgressV3ConceptLabSection: View {
    var body: some View {
        PreviewSection("Progress V3 Concept Lab") {
            ProgressV3ConceptLabView()
                .frame(height: 1220)
                .clipShape(.rect(cornerRadius: STRQRadii.largeCard))
                .overlay(
                    RoundedRectangle(cornerRadius: STRQRadii.largeCard, style: .continuous)
                        .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
                )
        }
    }
}

private struct ProgressV4HybridCandidateSection: View {
    var body: some View {
        PreviewSection("Progress V4 Hybrid Candidate") {
            ProgressV4HybridCandidateView()
                .frame(height: 1440)
                .clipShape(.rect(cornerRadius: STRQRadii.largeCard))
                .overlay(
                    RoundedRectangle(cornerRadius: STRQRadii.largeCard, style: .continuous)
                        .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
                )
        }
    }
}

private struct ProgressV5ExperienceSection: View {
    var body: some View {
        PreviewSection("Progress V5 Experience") {
            ProgressV5ExperiencePrototypeView()
                .frame(height: 1560)
                .clipShape(.rect(cornerRadius: STRQRadii.largeCard))
                .overlay(
                    RoundedRectangle(cornerRadius: STRQRadii.largeCard, style: .continuous)
                        .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
                )
        }
    }
}

private struct ListScheduleSection: View {
    var body: some View {
        PreviewSection("List / Schedule") {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                STRQSectionHeader("Section header") {
                    STRQSectionAction(title: "Action") {}
                }

                STRQCard(.compact) {
                    VStack(spacing: 0) {
                        STRQListItem(leadingIcon: .barbell, title: "Strength focus", subtitle: "Heavy upper work", trailingValue: "45m", showsChevron: true, isSelected: true)
                        STRQListItem(avatarText: "Q1", title: "Quarter target", subtitle: "Volume and consistency", trailingValue: "68%", showsChevron: true, tint: STRQColors.gray700)
                        STRQListItem(leadingIcon: .recovery, title: "Recovery check", subtitle: "Sleep, soreness, and readiness", trailingValue: "87%", trailingIcon: .checkCircle, showsDivider: true, tint: STRQColors.successGreen)
                        STRQListItem(leadingIcon: .lock, title: "Disabled row", subtitle: "Protected setting", trailingValue: "Off", showsChevron: true, showsDivider: false, isDisabled: true, isCompact: true)
                    }
                }

                STRQScheduleRow(dateTitle: "29", dateSubtitle: "WED", title: "Upper Strength", subtitle: "Push and pull", duration: "45m", status: "Active", icon: .barbell, isSelected: true)
                STRQScheduleRow(dateTitle: "30", dateSubtitle: "THU", title: "Lower Power", subtitle: "Hinge and squat", duration: "50m", status: "Done", icon: .train, isCompleted: true, isCompact: true)

                STRQScheduleCard(
                    title: "Schedule card",
                    subtitle: "Preview",
                    rows: [
                        STRQScheduleRow(dateTitle: "01", dateSubtitle: "FRI", title: "Recovery", subtitle: "Mobility and walk", duration: "25m", status: "Ready", icon: .recovery),
                        STRQScheduleRow(dateTitle: "02", dateSubtitle: "SAT", title: "Conditioning", subtitle: "Intervals", duration: "30m", status: "Done", icon: .activityRing, isCompleted: true)
                    ]
                )

                STRQTabBarContainer {
                    STRQTabBarItem(title: "Home", icon: .home, isSelected: true)
                    STRQTabBarItem(title: "Train", icon: .train, isSelected: false)
                    STRQTabBarCenterAction {}
                    STRQTabBarItem(title: "Progress", icon: .progress, isSelected: false)
                    STRQTabBarItem(title: "Profile", icon: .profile, isSelected: false)
                }

                Text("Tab bar background modifier")
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQColors.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, STRQSpacing.sm)
                    .strqTabBarBackground()
            }
        }
    }
}

private struct HumanBodyOverlayPilotSection: View {
    private let samples: [HumanBodyPilotSample] = [
        .init(
            title: "Male Front Base",
            base: .maleFrontBase,
            overlays: [],
            aspectRatio: 272.609 / 496.989
        ),
        .init(
            title: "Male Front + Chest",
            base: .maleFrontBase,
            overlays: [
                .init(asset: .maleFrontChestOverlay, tint: HumanBodyPilotTone.selectedTeal)
            ],
            aspectRatio: 272.609 / 496.989
        ),
        .init(
            title: "Male Front + Chest + Shoulder",
            base: .maleFrontBase,
            overlays: [
                .init(asset: .maleFrontChestOverlay, tint: HumanBodyPilotTone.selectedTeal),
                .init(asset: .maleFrontShoulderOverlay, tint: HumanBodyPilotTone.secondaryTeal, opacity: 0.72)
            ],
            aspectRatio: 272.609 / 496.989
        ),
        .init(
            title: "Male Front + Abs + Upper Leg",
            base: .maleFrontBase,
            overlays: [
                .init(asset: .maleFrontAbsOverlay, tint: HumanBodyPilotTone.selectedTeal),
                .init(asset: .maleFrontUpperLegOverlay, tint: HumanBodyPilotTone.secondaryTeal, opacity: 0.72)
            ],
            aspectRatio: 272.609 / 496.989
        ),
        .init(
            title: "Male Front + Bicep + Forearm",
            base: .maleFrontBase,
            overlays: [
                .init(asset: .maleFrontBicepOverlay, tint: HumanBodyPilotTone.selectedTeal),
                .init(asset: .maleFrontForearmOverlay, tint: HumanBodyPilotTone.secondaryTeal, opacity: 0.72)
            ],
            aspectRatio: 272.609 / 496.989
        ),
        .init(
            title: "Male Front + Lower Leg",
            base: .maleFrontBase,
            overlays: [
                .init(asset: .maleFrontLowerLegOverlay, tint: HumanBodyPilotTone.selectedTeal)
            ],
            aspectRatio: 272.609 / 496.989
        ),
        .init(
            title: "Male Back + Back",
            base: .maleBackBase,
            overlays: [
                .init(asset: .maleBackBackOverlay, tint: HumanBodyPilotTone.selectedTeal)
            ],
            aspectRatio: 286.668 / 497
        ),
        .init(
            title: "Male Back + Back + Trap",
            base: .maleBackBase,
            overlays: [
                .init(asset: .maleBackBackOverlay, tint: HumanBodyPilotTone.selectedTeal),
                .init(asset: .maleBackTrapOverlay, tint: HumanBodyPilotTone.secondaryTeal, opacity: 0.72)
            ],
            aspectRatio: 286.668 / 497
        ),
        .init(
            title: "Male Back + Glute + Hamstring",
            base: .maleBackBase,
            overlays: [
                .init(asset: .maleBackGluteOverlay, tint: HumanBodyPilotTone.selectedTeal),
                .init(asset: .maleBackHamstringOverlay, tint: HumanBodyPilotTone.secondaryTeal, opacity: 0.72)
            ],
            aspectRatio: 286.668 / 497
        ),
        .init(
            title: "Male Back + Tricep + Calf",
            base: .maleBackBase,
            overlays: [
                .init(asset: .maleBackTricepOverlay, tint: HumanBodyPilotTone.selectedTeal),
                .init(asset: .maleBackCalfOverlay, tint: HumanBodyPilotTone.secondaryTeal, opacity: 0.72)
            ],
            aspectRatio: 286.668 / 497
        )
    ]

    private let columns = [
        GridItem(.adaptive(minimum: 156), spacing: STRQSpacing.sm)
    ]

    var body: some View {
        PreviewSection("Human Body Overlay V1") {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                LazyVGrid(columns: columns, alignment: .leading, spacing: STRQSpacing.sm) {
                    ForEach(samples, id: \.title) { sample in
                        HumanBodyPilotTile(sample: sample)
                    }
                }

                HumanBodySemanticStateRow()
            }
        }
    }
}

private struct HumanBodyPilotTile: View {
    let sample: HumanBodyPilotSample

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.xs) {
            HumanBodyPilotComposite(
                base: sample.base,
                overlays: sample.overlays,
                aspectRatio: sample.aspectRatio
            )
            .frame(height: 220)
            .frame(maxWidth: .infinity)

            Text(sample.title)
                .font(STRQTypography.caption)
                .foregroundStyle(STRQColors.secondaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
                .frame(height: 32, alignment: .topLeading)
        }
        .padding(STRQSpacing.sm)
        .background(STRQColors.cardSurface, in: .rect(cornerRadius: STRQRadii.lg))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.lg, style: .continuous)
                .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
        )
    }
}

private struct HumanBodySemanticStateRow: View {
    private let states: [HumanBodyPilotState] = [
        .init(title: "Primary teal", tint: HumanBodyPilotTone.selectedTeal, opacity: 1),
        .init(title: "Secondary teal", tint: HumanBodyPilotTone.selectedTeal, opacity: 0.42),
        .init(title: "Warning amber", tint: STRQColors.warningAmber, opacity: 0.92)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.xs) {
            Text("Semantic States")
                .font(STRQTypography.labelSmall)
                .tracking(STRQTypography.labelSmallTracking)
                .foregroundStyle(STRQColors.secondaryText)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: STRQSpacing.sm) {
                    ForEach(states, id: \.title) { state in
                        HumanBodyPilotStateCell(state: state)
                    }
                }
                .padding(.bottom, 1)
            }
        }
    }
}

private struct HumanBodyPilotStateCell: View {
    let state: HumanBodyPilotState

    var body: some View {
        VStack(spacing: STRQSpacing.xs) {
            HumanBodyPilotComposite(
                base: .maleFrontBase,
                overlays: [
                    .init(asset: .maleFrontChestOverlay, tint: state.tint, opacity: state.opacity)
                ],
                aspectRatio: 272.609 / 496.989
            )
            .frame(width: 72, height: 132)

            Text(state.title)
                .font(STRQTypography.micro)
                .foregroundStyle(STRQColors.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.68)
                .frame(width: 96, height: 28)
        }
        .frame(width: 112)
        .padding(STRQSpacing.xs)
        .background(STRQColors.insetSurface, in: .rect(cornerRadius: STRQRadii.md))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                .strokeBorder(STRQColors.borderMuted.opacity(0.72), lineWidth: 1)
        )
    }
}

private struct HumanBodyPilotComposite: View {
    let base: HumanBodyPilotAsset
    let overlays: [HumanBodyPilotLayer]
    let aspectRatio: CGFloat

    var body: some View {
        ZStack {
            HumanBodyPilotBaseImage(asset: base)

            ForEach(overlays) { layer in
                HumanBodyPilotOverlayImage(layer: layer)
            }
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .padding(STRQSpacing.xs)
        .background(STRQColors.insetSurface.opacity(0.62), in: .rect(cornerRadius: STRQRadii.md))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                .strokeBorder(STRQColors.borderMuted.opacity(0.7), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Human body overlay pilot sample"))
    }
}

private struct HumanBodyPilotBaseImage: View {
    let asset: HumanBodyPilotAsset

    var body: some View {
        Image(asset.rawValue)
            .renderingMode(.original)
            .resizable()
            .scaledToFit()
    }
}

private struct HumanBodyPilotOverlayImage: View {
    let layer: HumanBodyPilotLayer

    var body: some View {
        Image(layer.asset.rawValue)
            .renderingMode(.template)
            .resizable()
            .scaledToFit()
            .foregroundStyle(layer.tint.opacity(layer.opacity))
    }
}

private struct HumanBodyPilotSample {
    let title: String
    let base: HumanBodyPilotAsset
    let overlays: [HumanBodyPilotLayer]
    let aspectRatio: CGFloat
}

private struct HumanBodyPilotLayer: Identifiable {
    let asset: HumanBodyPilotAsset
    let tint: Color
    var opacity: Double = 1

    var id: String {
        "\(asset.rawValue)-\(opacity)"
    }
}

private struct HumanBodyPilotState {
    let title: String
    let tint: Color
    let opacity: Double
}

private enum HumanBodyPilotAsset: String {
    case maleFrontBase = "STRQHumanBodyMaleFrontBase"
    case maleFrontAbsOverlay = "STRQHumanBodyMaleFrontAbsOverlay"
    case maleFrontBicepOverlay = "STRQHumanBodyMaleFrontBicepOverlay"
    case maleFrontChestOverlay = "STRQHumanBodyMaleFrontChestOverlay"
    case maleFrontForearmOverlay = "STRQHumanBodyMaleFrontForearmOverlay"
    case maleFrontLowerLegOverlay = "STRQHumanBodyMaleFrontLowerLegOverlay"
    case maleFrontShoulderOverlay = "STRQHumanBodyMaleFrontShoulderOverlay"
    case maleFrontUpperLegOverlay = "STRQHumanBodyMaleFrontUpperLegOverlay"
    case maleBackBase = "STRQHumanBodyMaleBackBase"
    case maleBackBackOverlay = "STRQHumanBodyMaleBackBackOverlay"
    case maleBackCalfOverlay = "STRQHumanBodyMaleBackCalfOverlay"
    case maleBackGluteOverlay = "STRQHumanBodyMaleBackGluteOverlay"
    case maleBackHamstringOverlay = "STRQHumanBodyMaleBackHamstringOverlay"
    case maleBackTrapOverlay = "STRQHumanBodyMaleBackTrapOverlay"
    case maleBackTricepOverlay = "STRQHumanBodyMaleBackTricepOverlay"
    case femaleFrontBase = "STRQHumanBodyFemaleFrontBase"
    case femaleFrontChestOverlay = "STRQHumanBodyFemaleFrontChestOverlay"
    case femaleBackBase = "STRQHumanBodyFemaleBackBase"
    case femaleBackGluteOverlay = "STRQHumanBodyFemaleBackGluteOverlay"
}

private enum HumanBodyPilotTone {
    static let selectedTeal = Color(red: 0.11, green: 0.82, blue: 0.78)
    static let secondaryTeal = selectedTeal.opacity(0.48)
}

private struct HumanBodyOverlayPilotSection_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            HumanBodyOverlayPilotSection()
                .padding(STRQSpacing.md)
        }
        .background(STRQColors.background)
        .preferredColorScheme(.dark)
        .previewDisplayName("Human Body Overlay Pilot")
    }
}

private struct IconsSection: View {
    var body: some View {
        PreviewSection("Icons") {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                STRQCard(.compact) {
                    HStack(spacing: STRQSpacing.sm) {
                        IconSemanticSample(icon: .checkCircle, title: "Success", tint: STRQColors.successGreen)
                        IconSemanticSample(icon: .warning, title: "Warning", tint: STRQColors.warningAmber)
                        IconSemanticSample(icon: .trash, title: "Danger", tint: STRQColors.dangerRed)
                    }
                }

                Text("\(STRQIcon.allCases.count) assets")
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQColors.mutedText)

                IconGrid()
            }
        }
    }
}

private struct IconSemanticSample: View {
    let icon: STRQIcon
    let title: String
    let tint: Color

    var body: some View {
        VStack(spacing: STRQSpacing.xs) {
            STRQIconContainer(icon: icon, size: .lg, tint: tint)

            Text(title)
                .font(STRQTypography.caption)
                .foregroundStyle(STRQColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
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
            STRQIconView(icon, size: STRQSpacing.iconLG, tint: STRQColors.iconPrimary, templateRendering: true)

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
