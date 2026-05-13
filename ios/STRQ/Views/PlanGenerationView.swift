import SwiftUI

struct PlanGenerationView: View {
    let profile: UserProfile
    let onComplete: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var phase = 0
    @State private var appeared = false
    @State private var progress: Double = 0

    private let steps: [(icon: String, title: String, detail: String)] = [
        (
            "calendar",
            L10n.tr("plan_generation_phase_structure", fallback: "Choosing the weekly structure"),
            L10n.tr("plan_generation_phase_structure_detail", fallback: "Matching your available days and session length.")
        ),
        (
            "figure.strengthtraining.traditional",
            L10n.tr("plan_generation_phase_exercises", fallback: "Matching exercises"),
            L10n.tr("plan_generation_phase_exercises_detail", fallback: "Using your setup, focus areas, and restrictions.")
        ),
        (
            "chart.bar.fill",
            L10n.tr("plan_generation_phase_volume", fallback: "Calibrating volume"),
            L10n.tr("plan_generation_phase_volume_detail", fallback: "Balancing goal, level, and recovery capacity.")
        ),
        (
            "target",
            L10n.tr("plan_generation_phase_focus", fallback: "Prioritizing focus areas"),
            L10n.tr("plan_generation_phase_focus_detail", fallback: "Giving extra attention only where you asked for it.")
        ),
        (
            "arrow.triangle.2.circlepath",
            L10n.tr("plan_generation_phase_rhythm", fallback: "Setting the training rhythm"),
            L10n.tr("plan_generation_phase_rhythm_detail", fallback: "Preparing a first week you can actually start.")
        ),
        (
            "checkmark.seal.fill",
            L10n.tr("plan_generation_phase_review", fallback: "Reviewing the plan"),
            L10n.tr("plan_generation_phase_review_detail", fallback: "Keeping the next workout clear and ready.")
        )
    ]

    private var currentStep: (icon: String, title: String, detail: String) {
        steps[min(phase, steps.count - 1)]
    }

    var body: some View {
        ZStack {
            activationBackground

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    generationHero
                        .padding(.top, 36)

                    progressPanel

                    profileSignalPanel

                    buildFactorsPanel

                    Text(L10n.tr("plan_generation_reassurance", fallback: "STRQ is using your onboarding answers to shape the plan. No extra setup is needed."))
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(STRQPalette.textMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .padding(.horizontal, 10)
                        .padding(.bottom, 34)
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            appeared = true
            startSequence()
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
                .frame(height: 180)
                Spacer()
            }
            .ignoresSafeArea()
        }
    }

    private var generationHero: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .strokeBorder(STRQPalette.borderSubtle, lineWidth: 1)
                    .frame(width: 112, height: 112)
                    .overlay(
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                STRQBrand.steelGradient,
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                    )
                    .scaleEffect(appeared && !reduceMotion ? 1.02 : 1)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: appeared)

                STRQPulseMark(
                    size: 74,
                    tint: STRQBrand.steel,
                    line: .horizontal,
                    ringOpacityMultiplier: reduceMotion ? 0.72 : 1,
                    lineOpacityMultiplier: reduceMotion ? 0.45 : 1,
                    trigger: phase
                )
            }

            VStack(spacing: 8) {
                Text(L10n.tr("plan_generation_eyebrow", fallback: "PLAN BUILD"))
                    .font(.caption2.weight(.bold))
                    .tracking(1.4)
                    .foregroundStyle(STRQBrand.steel)

                Text(L10n.tr("plan_generation_title", fallback: "Building Your Plan"))
                    .font(.system(.title2, design: .rounded).weight(.bold))
                    .foregroundStyle(STRQPalette.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.86)

                Text(profile.name.isEmpty
                     ? L10n.tr("plan_generation_subtitle_generic", fallback: "Turning your profile into a clear weekly structure.")
                     : L10n.format("plan_generation_subtitle_named", fallback: "%@, STRQ is turning your profile into a clear weekly structure.", profile.name))
                    .font(.subheadline)
                    .foregroundStyle(STRQPalette.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 8)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.86), value: appeared)
    }

    private var progressPanel: some View {
        activationCard {
            VStack(spacing: 18) {
                HStack(spacing: 14) {
                    Image(systemName: currentStep.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(STRQPalette.backgroundPrimary)
                        .frame(width: 40, height: 40)
                        .background(STRQPalette.textPrimary, in: Circle())

                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentStep.title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(STRQPalette.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.84)

                        Text(currentStep.detail)
                            .font(.footnote)
                            .foregroundStyle(STRQPalette.textSecondary)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .transaction { transaction in
                        transaction.animation = nil
                    }

                    Spacer(minLength: 0)
                }

                VStack(spacing: 10) {
                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(STRQPalette.surfaceStrong)
                            Capsule()
                                .fill(STRQBrand.steelGradient)
                                .frame(width: max(8, proxy.size.width * progress))
                        }
                    }
                    .frame(height: 7)

                    HStack(spacing: 7) {
                        ForEach(steps.indices, id: \.self) { index in
                            Capsule()
                                .fill(index <= phase ? STRQPalette.textPrimary : STRQPalette.borderSubtle)
                                .frame(height: 4)
                                .frame(maxWidth: .infinity)
                                .opacity(index <= phase ? 0.92 : 0.55)
                        }
                    }
                    .accessibilityHidden(true)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 14)
        .animation(reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.88).delay(0.08), value: appeared)
    }

    private var profileSignalPanel: some View {
        activationCard {
            VStack(alignment: .leading, spacing: 15) {
                Text(L10n.tr("plan_generation_inputs_title", fallback: "Profile signals"))
                    .font(.caption.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(STRQPalette.textMuted)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ],
                    spacing: 10
                ) {
                    signalTile(
                        icon: "target",
                        label: L10n.tr("plan_generation_goal_label", fallback: "Goal"),
                        value: profile.goal.localizedDisplayName
                    )
                    signalTile(
                        icon: "chart.line.uptrend.xyaxis",
                        label: L10n.tr("plan_generation_level_label", fallback: "Level"),
                        value: profile.trainingLevel.localizedShortName
                    )
                    signalTile(
                        icon: "calendar",
                        label: L10n.tr("plan_generation_days_label", fallback: "Rhythm"),
                        value: L10n.format("plan_generation_days_value", fallback: "%d days", profile.daysPerWeek)
                    )
                    signalTile(
                        icon: "clock",
                        label: L10n.tr("plan_generation_minutes_label", fallback: "Session"),
                        value: L10n.format("plan_generation_minutes_value", fallback: "%d min", profile.minutesPerSession)
                    )
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
        .animation(reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.88).delay(0.16), value: appeared)
    }

    private var buildFactorsPanel: some View {
        activationCard {
            VStack(alignment: .leading, spacing: 14) {
                Text(L10n.tr("plan_generation_factors_title", fallback: "What STRQ is considering"))
                    .font(.caption.weight(.bold))
                    .tracking(1.0)
                    .foregroundStyle(STRQPalette.textMuted)

                VStack(spacing: 10) {
                    ForEach(Array(inputFactors.enumerated()), id: \.offset) { _, factor in
                        factorRow(factor)
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 18)
        .animation(reduceMotion ? nil : .spring(response: 0.55, dampingFraction: 0.88).delay(0.24), value: appeared)
    }

    private var inputFactors: [(icon: String, title: String, value: String, detail: String)] {
        var rows: [(icon: String, title: String, value: String, detail: String)] = [
            (
                "calendar.badge.clock",
                L10n.tr("plan_generation_factor_schedule", fallback: "Schedule"),
                L10n.format("plan_generation_factor_schedule_value", fallback: "%d days / %d min", profile.daysPerWeek, profile.minutesPerSession),
                L10n.tr("plan_generation_factor_schedule_detail", fallback: "Sets the weekly rhythm and session density.")
            ),
            (
                "mappin.and.ellipse",
                L10n.tr("plan_generation_factor_setup", fallback: "Training setup"),
                profile.trainingLocation.displayName,
                L10n.tr("plan_generation_factor_setup_detail", fallback: "Keeps the workout realistic for where you train.")
            )
        ]

        if !profile.focusMuscles.isEmpty {
            rows.append((
                "scope",
                L10n.tr("plan_generation_factor_focus", fallback: "Focus areas"),
                focusSummary,
                L10n.tr("plan_generation_factor_focus_detail", fallback: "Adds priority without turning the plan into a one-muscle split.")
            ))
        }

        if !profile.injuries.isEmpty {
            rows.append((
                "shield.checkered",
                L10n.tr("plan_generation_factor_restrictions", fallback: "Restrictions"),
                restrictionSummary,
                L10n.tr("plan_generation_factor_restrictions_detail", fallback: "Keeps sensitive areas visible while the plan is assembled.")
            ))
        }

        return rows
    }

    private var focusSummary: String {
        let names = profile.focusMuscles.prefix(2).map(\.localizedDisplayName)
        let base = names.joined(separator: ", ")
        let remaining = max(0, profile.focusMuscles.count - names.count)
        return remaining > 0 ? L10n.format("plan_generation_focus_plus", fallback: "%@ +%d", base, remaining) : base
    }

    private var restrictionSummary: String {
        let names = profile.injuries.prefix(2).joined(separator: ", ")
        let remaining = max(0, profile.injuries.count - profile.injuries.prefix(2).count)
        return remaining > 0 ? L10n.format("plan_generation_restrictions_plus", fallback: "%@ +%d", names, remaining) : names
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

    private func signalTile(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(STRQBrand.steel)
                .frame(width: 28, height: 28)
                .background(STRQPalette.surfaceStrong, in: Circle())

            VStack(alignment: .leading, spacing: 3) {
                Text(label)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(STRQPalette.textMuted)
                    .textCase(.uppercase)
                    .lineLimit(1)

                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(STRQPalette.textPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.82)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .topLeading)
        .padding(12)
        .background(STRQPalette.surfaceRaised, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(STRQPalette.borderSubtle, lineWidth: 1)
        )
    }

    private func factorRow(_ factor: (icon: String, title: String, value: String, detail: String)) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: factor.icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(STRQPalette.textPrimary)
                .frame(width: 30, height: 30)
                .background(STRQPalette.surfaceStrong, in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(factor.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(STRQPalette.textPrimary)
                    Spacer(minLength: 6)
                    Text(factor.value)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(STRQPalette.textSecondary)
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                }

                Text(factor.detail)
                    .font(.caption)
                    .foregroundStyle(STRQPalette.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(STRQPalette.surfaceRaised.opacity(0.74), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func startSequence() {
        let stepDuration: Double = 0.6

        for index in steps.indices {
            DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(index)) {
                phase = index
                withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.38)) {
                    progress = Double(index + 1) / Double(steps.count)
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + stepDuration * Double(steps.count) + 0.5) {
            onComplete()
        }
    }
}
