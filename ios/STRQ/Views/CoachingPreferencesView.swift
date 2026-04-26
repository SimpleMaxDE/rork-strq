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
                    title: "Tone",
                    caption: "How STRQ talks to you when it calls a play."
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
                    eyebrow: "FOCUS",
                    title: L10n.tr("What matters most"),
                    caption: "STRQ will rank today's signal around this priority."
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
                    eyebrow: "SURFACE",
                    title: L10n.tr("How much to show"),
                    caption: "Coach and Today adapt to this."
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
                    eyebrow: "AUTOMATION",
                    title: L10n.tr("How much STRQ adjusts for you"),
                    caption: "Balance between coach authority and user control."
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
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(STRQBrand.accentGradient)
                    .frame(width: 3, height: 14)
                Text(L10n.tr("YOUR COACH, YOUR WAY"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(.primary)
                Spacer()
            }

            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "person.bust.fill")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(summaryTitle)
                        .font(.title3.weight(.bold))
                    Text(L10n.tr("STRQ stays one coach — these tune how it speaks, what it emphasizes, and how much it adjusts on its own."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 6) {
                summaryChip(icon: prefs.tone.symbolName, label: prefs.tone.displayName)
                summaryChip(icon: prefs.emphasis.symbolName, label: prefs.emphasis.displayName)
                summaryChip(icon: prefs.density.symbolName, label: prefs.density.displayName)
                summaryChip(icon: prefs.automation.symbolName, label: prefs.automation.displayName)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private var summaryTitle: String {
        let e = vm.profile.coachingPreferences.emphasis
        switch e {
        case .performance: return "Performance-first coaching"
        case .physique: return "Physique-first coaching"
        case .recovery: return "Recovery-first coaching"
        case .consistency: return "Consistency-first coaching"
        case .simplicity: return "Just the next step"
        }
    }

    private func summaryChip(icon: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .bold))
            Text(label)
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(STRQBrand.steel)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(STRQBrand.steel.opacity(0.12), in: Capsule())
        .overlay(Capsule().strokeBorder(STRQBrand.steel.opacity(0.15), lineWidth: 0.5))
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
        Button(action: action) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(isSelected ? .black : .white)
                    .frame(width: 36, height: 36)
                    .background(
                        isSelected ?
                        AnyShapeStyle(STRQBrand.accentGradient) :
                        AnyShapeStyle(STRQBrand.steelGradient),
                        in: .rect(cornerRadius: 10)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? STRQPalette.success : Color.white.opacity(0.18))
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        isSelected ? STRQPalette.success.opacity(0.35) : STRQBrand.cardBorder,
                        lineWidth: isSelected ? 1.2 : 1
                    )
            )
        }
        .buttonStyle(.strqPressable)
    }

    private func physiqueDisabledRow() -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: CoachingEmphasis.physique.symbolName)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.45))
                .frame(width: 36, height: 36)
                .background(Color.white.opacity(0.06), in: .rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(CoachingEmphasis.physique.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(L10n.tr("Turn on physique tracking in Profile to unlock this focus."))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)

            Image(systemName: "lock.fill")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground).opacity(0.5), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder.opacity(0.5), lineWidth: 1)
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
