import SwiftUI

struct CoachingPreferencesView: View {
    @Bindable var vm: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var appeared: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                heroCard

                section(
                    eyebrow: L10n.tr("COACH VOICE"),
                    title: L10n.tr("Tone"),
                    caption: L10n.tr("How STRQ talks to you when it calls a play.")
                ) {
                    VStack(spacing: 8) {
                        ForEach(CoachingTone.allCases) { tone in
                            optionRow(
                                isSelected: vm.profile.coachingPreferences.tone == tone,
                                icon: tone.symbolName,
                                title: tone.displayName,
                                detail: tone.detail
                            ) {
                                updateTone(tone)
                            }
                        }
                    }
                }

                section(
                    eyebrow: L10n.tr("FOCUS"),
                    title: L10n.tr("What matters most"),
                    caption: L10n.tr("STRQ will rank today's signal around this priority.")
                ) {
                    VStack(spacing: 8) {
                        ForEach(CoachingEmphasis.allCases) { emphasis in
                            if emphasis == .physique && !vm.profile.nutritionTrackingEnabled {
                                physiqueDisabledRow()
                            } else {
                                optionRow(
                                    isSelected: vm.profile.coachingPreferences.emphasis == emphasis,
                                    icon: emphasis.symbolName,
                                    title: emphasis.displayName,
                                    detail: emphasis.detail
                                ) {
                                    updateEmphasis(emphasis)
                                }
                            }
                        }
                    }
                }

                section(
                    eyebrow: L10n.tr("SURFACE"),
                    title: L10n.tr("How much to show"),
                    caption: L10n.tr("Coach and Today adapt to this.")
                ) {
                    VStack(spacing: 8) {
                        ForEach(CoachingDensity.allCases) { density in
                            optionRow(
                                isSelected: vm.profile.coachingPreferences.density == density,
                                icon: density.symbolName,
                                title: density.displayName,
                                detail: density.detail
                            ) {
                                updateDensity(density)
                            }
                        }
                    }
                }

                section(
                    eyebrow: L10n.tr("AUTOMATION"),
                    title: L10n.tr("How much STRQ adjusts for you"),
                    caption: L10n.tr("Balance between coach authority and user control.")
                ) {
                    VStack(spacing: 8) {
                        ForEach(CoachingAutomation.allCases) { level in
                            optionRow(
                                isSelected: vm.profile.coachingPreferences.automation == level,
                                icon: level.symbolName,
                                title: level.displayName,
                                detail: level.detail
                            ) {
                                updateAutomation(level)
                            }
                        }
                    }
                }

                footerNote
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .navigationTitle(L10n.tr("Coaching Style"))
        .navigationBarTitleDisplayMode(.large)
        .onAppear { withAnimation(.easeOut(duration: 0.45)) { appeared = true } }
    }

    // MARK: - Hero

    private var heroCard: some View {
        let prefs = vm.profile.coachingPreferences
        return VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "person.bust.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(STRQColors.iconSecondary)
                    .frame(width: 42, height: 42)
                    .background(STRQColors.controlSurface, in: .rect(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.tr("YOUR COACH, YOUR WAY"))
                        .font(STRQTypography.labelXS)
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(1)

                    Text(summaryTitle)
                        .font(STRQTypography.cardTitle)
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                }

                Spacer(minLength: 0)
            }

            Text(L10n.tr("STRQ stays one coach — these tune how it speaks, what it emphasizes, and how much it adjusts on its own."))
                .font(STRQTypography.paragraphSmall)
                .foregroundStyle(STRQColors.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(STRQColors.iconMuted)

                Text(summaryLine(for: prefs))
                    .font(STRQTypography.labelSmall)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(STRQColors.insetSurface, in: .rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
            )
        }
        .padding(STRQSpacing.cardPadding)
        .background(STRQGradients.insetCard, in: .rect(cornerRadius: STRQRadii.xl))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.xl, style: .continuous)
                .strokeBorder(STRQColors.borderMuted, lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private var summaryTitle: String {
        let e = vm.profile.coachingPreferences.emphasis
        switch e {
        case .performance: return L10n.tr("Performance-first coaching")
        case .physique: return L10n.tr("Physique-first coaching")
        case .recovery: return L10n.tr("Recovery-first coaching")
        case .consistency: return L10n.tr("Consistency-first coaching")
        case .simplicity: return L10n.tr("Just the next step")
        }
    }

    private func summaryLine(for prefs: CoachingPreferences) -> String {
        [
            prefs.tone.displayName,
            prefs.emphasis.displayName,
            prefs.density.displayName,
            prefs.automation.displayName
        ].joined(separator: " · ")
    }

    // MARK: - Sections

    @ViewBuilder
    private func section<Content: View>(
        eyebrow: String,
        title: String,
        caption: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(eyebrow)
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(STRQBrand.steel)
                Text(title)
                    .font(.title3.weight(.bold))
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            content()
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
    }

    // MARK: - Option row

    private func optionRow(
        isSelected: Bool,
        icon: String,
        title: String,
        detail: String,
        action: @escaping () -> Void
    ) -> some View {
        let cardBackground = isSelected ? STRQColors.selectedSurface : STRQColors.cardSurface
        let cardBorder = isSelected ? STRQColors.selectedBorder.opacity(0.58) : STRQColors.borderMuted
        let iconBackground = isSelected ? STRQColors.insetSurface : STRQColors.controlSurface
        let iconBorder = isSelected ? STRQColors.selectedBorder.opacity(0.32) : STRQColors.borderMuted
        let iconForeground = isSelected ? STRQColors.iconPrimary : STRQColors.iconSecondary
        let checkForeground = isSelected ? STRQColors.iconPrimary.opacity(0.78) : STRQColors.iconMuted.opacity(0.62)

        return Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(iconForeground)
                    .frame(width: STRQSpacing.iconContainerMD, height: STRQSpacing.iconContainerMD)
                    .background(iconBackground, in: .rect(cornerRadius: STRQRadii.iconContainer))
                    .overlay(
                        RoundedRectangle(cornerRadius: STRQRadii.iconContainer, style: .continuous)
                            .strokeBorder(iconBorder, lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(STRQTypography.labelMedium)
                        .foregroundStyle(STRQColors.primaryText)
                    Text(detail)
                        .font(STRQTypography.paragraphXS)
                        .foregroundStyle(STRQColors.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)

                Image(systemName: isSelected ? "checkmark.circle" : "circle")
                    .font(.system(size: 18, weight: isSelected ? .semibold : .medium))
                    .foregroundStyle(checkForeground)
            }
            .padding(STRQSpacing.cardPaddingCompact)
            .background(cardBackground, in: .rect(cornerRadius: STRQRadii.lg))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.lg, style: .continuous)
                    .strokeBorder(
                        cardBorder,
                        lineWidth: isSelected ? 1.25 : 1
                    )
            )
        }
        .buttonStyle(.strqPressable)
    }

    private func physiqueDisabledRow() -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: CoachingEmphasis.physique.symbolName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(STRQColors.iconMuted)
                .frame(width: STRQSpacing.iconContainerMD, height: STRQSpacing.iconContainerMD)
                .background(STRQColors.controlSurface.opacity(0.56), in: .rect(cornerRadius: STRQRadii.iconContainer))
                .overlay(
                    RoundedRectangle(cornerRadius: STRQRadii.iconContainer, style: .continuous)
                        .strokeBorder(STRQColors.borderMuted.opacity(0.5), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(CoachingEmphasis.physique.displayName)
                    .font(STRQTypography.labelMedium)
                    .foregroundStyle(STRQColors.secondaryText.opacity(0.62))
                Text(L10n.tr("Turn on physique tracking in Profile to unlock this focus."))
                    .font(STRQTypography.paragraphXS)
                    .foregroundStyle(STRQColors.mutedText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)

            Image(systemName: "lock.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(STRQColors.iconMuted)
        }
        .padding(STRQSpacing.cardPaddingCompact)
        .background(STRQColors.cardSurface.opacity(0.56), in: .rect(cornerRadius: STRQRadii.lg))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.lg, style: .continuous)
                .strokeBorder(STRQColors.borderMuted.opacity(0.52), lineWidth: 1)
        )
    }

    private var footerNote: some View {
        HStack(spacing: 8) {
            Image(systemName: "sparkles")
                .font(.caption)
                .foregroundStyle(STRQBrand.steel)
            Text(L10n.tr("Preferences shape the surface only. The underlying intelligence stays the same."))
                .font(.caption2)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
        }
        .padding(.top, 4)
    }

    // MARK: - Updates

    private func updateTone(_ value: CoachingTone) {
        var prefs = vm.profile.coachingPreferences
        guard prefs.tone != value else { return }
        prefs.tone = value
        commit(prefs)
    }

    private func updateDensity(_ value: CoachingDensity) {
        var prefs = vm.profile.coachingPreferences
        guard prefs.density != value else { return }
        prefs.density = value
        commit(prefs)
    }

    private func updateEmphasis(_ value: CoachingEmphasis) {
        var prefs = vm.profile.coachingPreferences
        guard prefs.emphasis != value else { return }
        prefs.emphasis = value
        commit(prefs)
    }

    private func updateAutomation(_ value: CoachingAutomation) {
        var prefs = vm.profile.coachingPreferences
        guard prefs.automation != value else { return }
        prefs.automation = value
        commit(prefs)
    }

    private func commit(_ prefs: CoachingPreferences) {
        withAnimation(.snappy(duration: 0.2)) {
            vm.profile.coachingPreferences = prefs
        }
        vm.refreshCoachingInsights()
        vm.refreshDailyState()
        Analytics.shared.track(.profile_viewed, [
            "tone": prefs.tone.rawValue,
            "density": prefs.density.rawValue,
            "emphasis": prefs.emphasis.rawValue,
            "automation": prefs.automation.rawValue
        ])
    }
}
