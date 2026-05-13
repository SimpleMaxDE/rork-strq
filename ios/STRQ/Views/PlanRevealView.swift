import SwiftUI

struct PlanRevealView: View {
    let plan: WorkoutPlan
    let profile: UserProfile
    let planQuality: PlanQualityScore?
    let onStart: () -> Void
    var impacts: [OnboardingImpact] = []

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var appeared = false
    @State private var showDays = false
    @State private var showQuality = false
    @State private var showImpacts = false
    @State private var showCoachNote = false

    var body: some View {
        ZStack(alignment: .bottom) {
            activationBackground

            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    heroSection
                        .padding(.top, 34)

                    planIdentityCard

                    weeklyRhythmSection

                    whyThisFitsSection

                    nextWorkoutBridge

                    weekPreview

                    if let quality = planQuality {
                        qualitySection(quality)
                    }

                    explanationSection

                    Spacer(minLength: 116)
                }
                .padding(.horizontal, 20)
            }

            topScrollScrim

            stickyStartBar
        }
        .onAppear {
            appeared = true
            animateSequence()
        }
    }

    private var activationBackground: some View {
        ZStack {
            STRQPalette.backgroundPrimary.ignoresSafeArea()

            LinearGradient(
                colors: [
                    STRQPalette.backgroundDeep,
                    STRQPalette.backgroundCarbon,
                    STRQPalette.backgroundPrimary
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.white.opacity(0.08))
                    .frame(height: 1)
                LinearGradient(
                    colors: [Color.white.opacity(0.08), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 170)
                Spacer()
            }
            .ignoresSafeArea()
        }
    }

    private var topScrollScrim: some View {
        VStack(spacing: 0) {
            STRQPalette.backgroundPrimary
                .frame(height: 88)

            LinearGradient(
                colors: [
                    STRQPalette.backgroundPrimary,
                    STRQPalette.backgroundPrimary.opacity(0.72),
                    STRQPalette.backgroundPrimary.opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 44)

            Spacer(minLength: 0)
        }
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            STRQPulseMark(
                size: 82,
                tint: STRQBrand.steel,
                line: .horizontal,
                ringOpacityMultiplier: reduceMotion ? 0.72 : 1,
                lineOpacityMultiplier: reduceMotion ? 0.45 : 1,
                trigger: appeared ? 1 : 0
            )
            .overlay(
                Circle()
                    .strokeBorder(STRQPalette.borderSubtle, lineWidth: 1)
                    .frame(width: 106, height: 106)
            )

            VStack(spacing: 8) {
                Text(L10n.tr("plan_reveal_eyebrow", fallback: "Your Plan is Ready"))
                    .font(.caption2.weight(.bold))
                    .tracking(1.4)
                    .foregroundStyle(STRQBrand.steel)

                Text(splitName)
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(STRQPalette.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Text(revealSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(STRQPalette.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 8)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 14)
        .animation(reduceMotion ? nil : .spring(response: 0.58, dampingFraction: 0.86), value: appeared)
    }

    private var planIdentityCard: some View {
        activationCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(plan.name.isEmpty ? splitName : plan.name)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(STRQPalette.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)

                        Text(planIdentityLine)
                            .font(.subheadline)
                            .foregroundStyle(STRQPalette.textSecondary)
                            .lineSpacing(2)
                    }

                    Spacer(minLength: 10)

                    VStack(spacing: 2) {
                        Text("\(plan.durationWeeks)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(STRQPalette.textPrimary)
                        Text(L10n.tr("plan_reveal_weeks_short", fallback: "weeks"))
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(STRQPalette.textMuted)
                            .textCase(.uppercase)
                    }
                    .frame(width: 64, height: 64)
                    .background(STRQPalette.surfaceStrong, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(STRQPalette.borderSubtle, lineWidth: 1)
                    )
                }

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    planMetric(
                        icon: "calendar",
                        label: L10n.tr("plan_reveal_metric_rhythm", fallback: "Weekly rhythm"),
                        value: L10n.format("plan_reveal_metric_days", fallback: "%d days", plan.days.count)
                    )
                    planMetric(
                        icon: "clock",
                        label: L10n.tr("plan_reveal_metric_duration", fallback: "Session length"),
                        value: L10n.format("plan_reveal_metric_minutes", fallback: "%d min", averageMinutes)
                    )
                    planMetric(
                        icon: "figure.strengthtraining.traditional",
                        label: L10n.tr("plan_reveal_metric_exercises", fallback: "Exercises"),
                        value: "\(totalExerciseCount)"
                    )
                    planMetric(
                        icon: "chart.bar.fill",
                        label: L10n.tr("plan_reveal_metric_load", fallback: "Load cue"),
                        value: profile.trainingLevel.localizedShortName
                    )
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(reduceMotion ? nil : .spring(response: 0.58, dampingFraction: 0.88).delay(0.08), value: appeared)
    }

    private var weeklyRhythmSection: some View {
        activationCard {
            VStack(alignment: .leading, spacing: 15) {
                sectionLabel(
                    L10n.tr("plan_reveal_rhythm_title", fallback: "Weekly structure"),
                    detail: L10n.tr("plan_reveal_rhythm_detail", fallback: "A simple rhythm for the block ahead.")
                )

                HStack(spacing: 8) {
                    ForEach(Array(plan.days.enumerated()), id: \.element.id) { index, day in
                        rhythmTile(day: day, index: index)
                    }
                }
            }
        }
        .opacity(showDays ? 1 : 0)
        .offset(y: showDays ? 0 : 16)
        .animation(reduceMotion ? nil : .spring(response: 0.58, dampingFraction: 0.88), value: showDays)
    }

    private var whyThisFitsSection: some View {
        activationCard {
            VStack(alignment: .leading, spacing: 15) {
                sectionLabel(
                    L10n.tr("plan_reveal_why_title", fallback: "Why this fits"),
                    detail: L10n.tr("plan_reveal_why_detail", fallback: "Visible choices are tied back to your profile.")
                )

                VStack(spacing: 10) {
                    ForEach(displayImpacts) { impact in
                        fitRow(
                            icon: impact.icon,
                            title: impact.title,
                            detail: impact.detail,
                            color: impactColor(impact.color)
                        )
                    }

                    if let quality = planQuality, !quality.strengths.isEmpty {
                        Divider()
                            .background(STRQPalette.borderSubtle)
                            .padding(.vertical, 2)

                        ForEach(Array(quality.strengths.prefix(2).enumerated()), id: \.offset) { _, strength in
                            fitRow(
                                icon: "checkmark.seal.fill",
                                title: L10n.tr("plan_reveal_strength_label", fallback: "Plan strength"),
                                detail: strength,
                                color: STRQPalette.success
                            )
                        }
                    }
                }
            }
        }
        .opacity(showImpacts ? 1 : 0)
        .offset(y: showImpacts ? 0 : 16)
        .animation(reduceMotion ? nil : .spring(response: 0.58, dampingFraction: 0.88), value: showImpacts)
    }

    private var nextWorkoutBridge: some View {
        activationCard {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(STRQPalette.textPrimary)
                    .frame(width: 44, height: 44)
                    .background(STRQPalette.surfaceStrong, in: Circle())

                VStack(alignment: .leading, spacing: 6) {
                    Text(L10n.tr("plan_reveal_bridge_title", fallback: "Prepare the next workout"))
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(STRQPalette.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.84)

                    Text(L10n.tr("plan_reveal_bridge_detail", fallback: "STRQ opens a short handoff first, then you can begin training with the plan loaded."))
                        .font(.subheadline)
                        .foregroundStyle(STRQPalette.textSecondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
        }
        .opacity(showQuality ? 1 : 0)
        .offset(y: showQuality ? 0 : 16)
        .animation(reduceMotion ? nil : .spring(response: 0.58, dampingFraction: 0.88), value: showQuality)
    }

    private var weekPreview: some View {
        activationCard {
            VStack(alignment: .leading, spacing: 15) {
                sectionLabel(
                    L10n.tr("plan_reveal_week_title", fallback: "First week"),
                    detail: L10n.tr("plan_reveal_week_detail", fallback: "Each session has a clear focus and a realistic time box.")
                )

                VStack(spacing: 10) {
                    ForEach(Array(plan.days.enumerated()), id: \.element.id) { index, day in
                        dayPreviewRow(day: day, index: index)
                    }
                }
            }
        }
        .opacity(showDays ? 1 : 0)
        .offset(y: showDays ? 0 : 16)
        .animation(reduceMotion ? nil : .spring(response: 0.58, dampingFraction: 0.88).delay(0.06), value: showDays)
    }

    private func qualitySection(_ quality: PlanQualityScore) -> some View {
        activationCard {
            VStack(alignment: .leading, spacing: 15) {
                sectionLabel(
                    L10n.tr("plan_reveal_quality_title", fallback: "Plan check"),
                    detail: L10n.tr("plan_reveal_quality_detail", fallback: "A quick read on balance, time fit, recovery, and progression.")
                )

                HStack(spacing: 12) {
                    Text("\(Int((quality.overall * 100).rounded()))")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(STRQPalette.textPrimary)
                        .frame(width: 78, height: 78)
                        .background(STRQPalette.surfaceStrong, in: Circle())
                        .overlay(
                            Circle()
                                .strokeBorder(qualityColor(quality.overallColor), lineWidth: 2)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(quality.localizedOverallLabel)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(STRQPalette.textPrimary)
                        Text(L10n.tr("plan_reveal_quality_copy", fallback: "The structure is ready for a first training block. STRQ will learn more as you log sessions."))
                            .font(.footnote)
                            .foregroundStyle(STRQPalette.textSecondary)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    qualityTile(
                        L10n.tr("plan_reveal_quality_balance", fallback: "Balance"),
                        quality.muscleBalance.localizedLabel,
                        quality.muscleBalance.icon,
                        quality.muscleBalance.colorName
                    )
                    qualityTile(
                        L10n.tr("plan_reveal_quality_time", fallback: "Time fit"),
                        quality.timeFit.localizedLabel,
                        quality.timeFit.icon,
                        quality.timeFit.colorName
                    )
                    qualityTile(
                        L10n.tr("plan_reveal_quality_recovery", fallback: "Recovery"),
                        quality.recoveryFit.localizedLabel,
                        quality.recoveryFit.icon,
                        quality.recoveryFit.colorName
                    )
                    qualityTile(
                        L10n.tr("plan_reveal_quality_progression", fallback: "Progression"),
                        quality.progressionReadiness.localizedLabel,
                        quality.progressionReadiness.icon,
                        quality.progressionReadiness.colorName
                    )
                }

                if !quality.watchItems.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.tr("plan_reveal_watch_items", fallback: "Watch items"))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(STRQPalette.textMuted)
                            .textCase(.uppercase)

                        ForEach(Array(quality.watchItems.prefix(2).enumerated()), id: \.offset) { _, item in
                            HStack(alignment: .top, spacing: 8) {
                                Image(systemName: "info.circle")
                                    .foregroundStyle(STRQPalette.warning)
                                Text(item)
                                    .font(.footnote)
                                    .foregroundStyle(STRQPalette.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(12)
                    .background(STRQPalette.surfaceRaised, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
        .opacity(showQuality ? 1 : 0)
        .offset(y: showQuality ? 0 : 18)
        .animation(reduceMotion ? nil : .spring(response: 0.58, dampingFraction: 0.88), value: showQuality)
    }

    private var explanationSection: some View {
        activationCard {
            VStack(alignment: .leading, spacing: 12) {
                Button {
                    withAnimation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.86)) {
                        showCoachNote.toggle()
                    }
                } label: {
                    HStack {
                        Label(L10n.tr("plan_reveal_coach_note", fallback: "Coach note"), systemImage: "text.bubble.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(STRQPalette.textPrimary)
                        Spacer()
                        Image(systemName: showCoachNote ? "chevron.up" : "chevron.down")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(STRQPalette.textMuted)
                    }
                }
                .buttonStyle(.plain)

                if showCoachNote {
                    Text(plan.explanation)
                        .font(.footnote)
                        .foregroundStyle(STRQPalette.textSecondary)
                        .lineSpacing(4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .opacity(showQuality ? 1 : 0)
        .offset(y: showQuality ? 0 : 18)
        .animation(reduceMotion ? nil : .spring(response: 0.58, dampingFraction: 0.88).delay(0.08), value: showQuality)
    }

    private var stickyStartBar: some View {
        VStack(spacing: 10) {
            Button {
                onStart()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 17, weight: .bold))
                    Text(L10n.tr("plan_reveal_cta_prepare_workout", fallback: "Prepare Workout"))
                        .font(.headline.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.84)
                }
                .foregroundStyle(STRQPalette.backgroundPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 58)
                .background(
                    LinearGradient(
                        colors: [STRQPalette.textPrimary, STRQBrand.steel.opacity(0.88)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                )
                .shadow(color: Color.white.opacity(0.10), radius: 18, y: 6)
            }
            .buttonStyle(.plain)

            Text(L10n.tr("plan_reveal_cta_note", fallback: "STRQ opens the workout handoff before training starts."))
                .font(.caption)
                .foregroundStyle(STRQPalette.textMuted)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 14)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(STRQPalette.backgroundPrimary.opacity(0.78))
                .ignoresSafeArea(edges: .bottom)
        )
        .overlay(alignment: .top) {
            Rectangle()
                .fill(STRQPalette.borderSubtle)
                .frame(height: 1)
        }
        .opacity(showQuality ? 1 : 0)
        .offset(y: showQuality ? 0 : 22)
        .animation(reduceMotion ? nil : .spring(response: 0.58, dampingFraction: 0.86), value: showQuality)
    }

    private var splitName: String {
        SplitDisplayName.localizedDisplayName(for: plan.splitType)
    }

    private var revealSubtitle: String {
        if profile.name.isEmpty {
            return L10n.tr("plan_reveal_subtitle_generic", fallback: "Your training block is ready. Start with the next workout and let real training sharpen the plan.")
        }
        return L10n.format(
            "plan_reveal_subtitle_named",
            fallback: "%@, your training block is ready. Start with the next workout and let real training sharpen the plan.",
            profile.name
        )
    }

    private var planIdentityLine: String {
        L10n.format(
            "plan_reveal_identity_line",
            fallback: "%@ / %@",
            profile.goal.localizedDisplayName,
            profile.trainingLevel.localizedShortName
        )
    }

    private var averageMinutes: Int {
        guard !plan.days.isEmpty else { return profile.minutesPerSession }
        let total = plan.days.reduce(0) { $0 + $1.estimatedMinutes }
        return max(1, total / plan.days.count)
    }

    private var totalExerciseCount: Int {
        plan.days.reduce(0) { $0 + $1.exercises.count }
    }

    private var displayImpacts: [OnboardingImpact] {
        if !impacts.isEmpty {
            return Array(impacts.prefix(4))
        }

        return [
            OnboardingImpact(
                icon: "target",
                title: L10n.tr("plan_reveal_fallback_goal_title", fallback: "Goal matched"),
                detail: L10n.format("plan_reveal_fallback_goal_detail", fallback: "%@ goal focus.", profile.goal.localizedDisplayName),
                color: "blue"
            ),
            OnboardingImpact(
                icon: "calendar",
                title: L10n.tr("plan_reveal_fallback_schedule_title", fallback: "Schedule respected"),
                detail: L10n.format("plan_reveal_fallback_schedule_detail", fallback: "%d days / %d min sessions.", profile.daysPerWeek, profile.minutesPerSession),
                color: "green"
            ),
            OnboardingImpact(
                icon: "chart.line.uptrend.xyaxis",
                title: L10n.tr("plan_reveal_fallback_level_title", fallback: "Level calibrated"),
                detail: L10n.format("plan_reveal_fallback_level_detail", fallback: "Set for %@ training.", profile.trainingLevel.localizedShortName),
                color: "purple"
            )
        ]
    }

    private func activationCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(STRQPalette.surfaceBase.opacity(0.94))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.07), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(STRQPalette.borderSubtle, lineWidth: 1)
            )
    }

    private func sectionLabel(_ title: String, detail: String) -> some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(STRQPalette.textMuted)
                    .textCase(.uppercase)

                Text(detail)
                    .font(.footnote)
                    .foregroundStyle(STRQPalette.textSecondary)
                    .lineSpacing(2)
            }
            Spacer(minLength: 0)
        }
    }

    private func planMetric(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(STRQBrand.steel)
                .frame(width: 28, height: 28)
                .background(STRQPalette.surfaceStrong, in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(STRQPalette.textMuted)
                    .textCase(.uppercase)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)

                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(STRQPalette.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
        .padding(12)
        .background(STRQPalette.surfaceRaised, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(STRQPalette.borderSubtle, lineWidth: 1)
        )
    }

    private func rhythmTile(day: WorkoutDay, index: Int) -> some View {
        VStack(spacing: 8) {
            Text(dayShortLabel(day: day, index: index))
                .font(.caption2.weight(.bold))
                .foregroundStyle(STRQPalette.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Capsule()
                .fill(index == 0 ? STRQPalette.textPrimary : STRQPalette.surfaceStrong)
                .frame(width: 10, height: 36)
                .overlay(
                    Capsule()
                        .strokeBorder(index == 0 ? Color.white.opacity(0.22) : STRQPalette.borderSubtle, lineWidth: 1)
                )

            Text(day.focusMuscles.first?.localizedDisplayName ?? L10n.tr("plan_reveal_day_focus", fallback: "Full"))
                .font(.caption2.weight(.semibold))
                .foregroundStyle(index == 0 ? STRQPalette.textPrimary : STRQPalette.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.66)
        }
        .frame(maxWidth: .infinity, minHeight: 92)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(index == 0 ? STRQPalette.surfaceStrong : STRQPalette.surfaceRaised)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(index == 0 ? STRQPalette.borderStrong : STRQPalette.borderSubtle, lineWidth: 1)
        )
    }

    private func fitRow(icon: String, title: String, detail: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 30, height: 30)
                .background(color.opacity(0.14), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(STRQPalette.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)

                Text(detail)
                    .font(.caption)
                    .foregroundStyle(STRQPalette.textSecondary)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(STRQPalette.surfaceRaised.opacity(0.82), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func dayPreviewRow(day: WorkoutDay, index: Int) -> some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(spacing: 2) {
                Text(dayShortLabel(day: day, index: index))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(STRQPalette.textMuted)
                Text("\(index + 1)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(STRQPalette.textPrimary)
            }
            .frame(width: 44, height: 48)
            .background(STRQPalette.surfaceStrong, in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(day.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(STRQPalette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(dayFocusText(day))
                    .font(.caption)
                    .foregroundStyle(STRQPalette.textMuted)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                Text(L10n.format("plan_reveal_day_exercises", fallback: "%d exercises", day.exercises.count))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(STRQPalette.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
                Text(L10n.format("plan_reveal_day_minutes", fallback: "~%d min", day.estimatedMinutes))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(STRQPalette.textMuted)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .background(STRQPalette.surfaceRaised, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .strokeBorder(index == 0 ? STRQPalette.borderStrong : STRQPalette.borderSubtle, lineWidth: 1)
        )
    }

    private func qualityTile(_ label: String, _ value: String, _ icon: String, _ colorName: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(qualityColor(colorName))
                .frame(width: 28, height: 28)
                .background(qualityColor(colorName).opacity(0.14), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(STRQPalette.textMuted)
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(value)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(STRQPalette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(STRQPalette.surfaceRaised, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func dayShortLabel(day: WorkoutDay, index: Int) -> String {
        if let weekday = day.scheduledWeekday, (1...7).contains(weekday) {
            return Calendar.current.shortWeekdaySymbols[weekday - 1]
        }
        return L10n.format("plan_reveal_day_short", fallback: "D%d", index + 1)
    }

    private func dayFocusText(_ day: WorkoutDay) -> String {
        let text = day.focusMuscles.map(\.localizedDisplayName).joined(separator: " + ")
        return text.isEmpty ? L10n.tr("plan_reveal_day_full_body", fallback: "Full body") : text
    }

    private func impactColor(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "green":
            return STRQPalette.success
        case "red":
            return STRQPalette.danger
        case "orange", "yellow":
            return STRQPalette.warning
        case "purple", "blue":
            return STRQBrand.steel
        default:
            return STRQPalette.textPrimary
        }
    }

    private func qualityColor(_ colorName: String) -> Color {
        switch colorName.lowercased() {
        case "green":
            return STRQPalette.success
        case "red":
            return STRQPalette.danger
        case "orange", "yellow":
            return STRQPalette.warning
        default:
            return STRQBrand.steel
        }
    }

    private func animateSequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            withAnimation(reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.86)) {
                showDays = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.48) {
            withAnimation(reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.86)) {
                showImpacts = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.86)) {
                showQuality = true
            }
        }
    }
}
