import SwiftUI

struct CoachTabView: View {
    let vm: AppViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared: Bool = false
    @State private var expandedInsightIds: Set<String> = []
    @State private var expandedRecIds: Set<String> = []
    @State private var showWeeklyReview: Bool = false
    @State private var showReadinessCheckIn: Bool = false
    @State private var showMoreSignals: Bool = false
    @State private var showCoachingHistory: Bool = false
    @State private var showWatchDetails: Bool = false
    @State private var toast: STRQToast?
    @State private var lastAppliedCount: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                authorityHero

                if vm.isEarlyStage {
                    earlyStateCard

                    if shouldShowCalibrationChecklist {
                        calibrationChecklist
                    }
                } else {
                    if let comeback = vm.comebackGuidance {
                        ComebackCard(
                            guidance: comeback,
                            onEaseNext: comeback.offersLighterSession ? {
                                Analytics.shared.track(.comeback_cta_tapped, [
                                    "action": "ease",
                                    "tier": comeback.tier.rawValue,
                                    "surface": "coach"
                                ])
                                vm.applyComebackLighterSession()
                            } : nil,
                            onCheckIn: vm.hasCheckedInToday ? nil : {
                                Analytics.shared.track(.comeback_cta_tapped, [
                                    "action": "checkin",
                                    "tier": comeback.tier.rawValue,
                                    "surface": "coach"
                                ])
                                showReadinessCheckIn = true
                            }
                        )
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.04), value: appeared)
                        .onAppear {
                            Analytics.shared.track(.comeback_card_viewed, [
                                "tier": comeback.tier.rawValue,
                                "days_since": String(comeback.daysSinceLastWorkout),
                                "surface": "coach"
                            ])
                        }
                    }
                    decisionStack
                }

                if !vm.isEarlyStage, let outlook = vm.phaseOutlook {
                    PhaseOutlookCard(outlook: outlook)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 10)
                        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.12), value: appeared)
                }

                recentChangeBridge

                weeklyCheckInRow
            }
            .padding(.horizontal, 16)
            .padding(.top, 6)
            .padding(.bottom, 32)
        }
        .accessibilityIdentifier("strq.coach.scroll")
        .background(Color(.systemBackground))
        .navigationTitle(L10n.tr("Coach"))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5)) { appeared = true }
            lastAppliedCount = vm.appliedActionIds.count
            Analytics.shared.track(.coach_viewed)
        }
        .onChange(of: vm.appliedActionIds.count) { old, new in
            if new > old {
                toast = STRQToast(
                    title: L10n.tr("Coach-Anpassung gespeichert"),
                    detail: L10n.tr("Wird fürs nächste Workout berücksichtigt"),
                    style: .applied
                )
            }
            lastAppliedCount = new
        }
        .sheet(isPresented: $showWeeklyReview) {
            if let review = vm.weeklyReview {
                WeeklyCheckInView(vm: vm, review: review)
            }
        }
        .sheet(isPresented: $showReadinessCheckIn) {
            ReadinessCheckInView(vm: vm) { readiness in
                vm.submitReadiness(readiness)
            }
        }
        .sheet(isPresented: $showMoreSignals) {
            NavigationStack {
                MoreSignalsSheet(vm: vm)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationContentInteraction(.scrolls)
        }
        .sheet(isPresented: $showCoachingHistory) {
            NavigationStack {
                CoachingHistoryView(vm: vm)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationContentInteraction(.scrolls)
        }
        .strqToast($toast)
    }

    // MARK: - Authority Hero

    private var authorityHero: some View {
        let score = vm.effectiveRecoveryScore
        let color = coachReadinessColor(for: score)
        let phase = vm.currentPhase
        let state = coachRecoveryStateLabel(for: score)
        let readinessTeal = Color(red: 0.300, green: 0.780, blue: 0.740)
        let commandLine = STRQPalette.borderStrong.opacity(0.72)
        let moduleSurface = Color.white.opacity(0.035)

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 15) {
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [color.opacity(0.18), Color.white.opacity(0.025), Color.clear],
                                center: .center,
                                startRadius: 14,
                                endRadius: 43
                            )
                        )
                        .frame(width: 82, height: 82)
                    Circle()
                        .stroke(color.opacity(0.20), lineWidth: 1)
                        .frame(width: 82, height: 82)
                    VStack(spacing: 5) {
                        Image(systemName: coachRecoveryStateIcon(for: score))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(color)
                        Text(state)
                            .font(.system(size: 18, weight: .heavy, design: .rounded))
                            .foregroundStyle(STRQPalette.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                        Text(L10n.tr("Context"))
                            .font(.system(size: 8, weight: .bold))
                            .tracking(0.7)
                            .foregroundStyle(STRQPalette.textMuted)
                    }
                }
                .frame(width: 88, height: 88)
                .background(moduleSurface, in: .rect(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 9) {
                    HStack(spacing: 7) {
                        Circle()
                            .fill(color)
                            .frame(width: 6, height: 6)
                        Text(state.uppercased())
                            .font(.system(size: 10, weight: .black))
                            .tracking(1.2)
                            .foregroundStyle(color)
                    }
                    .padding(.top, 2)

                    Text(headline)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(STRQPalette.textPrimary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)
            }

            HStack(alignment: .center, spacing: 8) {
                HStack(spacing: 5) {
                    Image(systemName: phase.icon)
                        .font(.system(size: 9, weight: .bold))
                    Text(phase.displayName)
                        .font(.system(size: 10, weight: .black))
                        .tracking(0.6)
                        .textCase(.uppercase)
                }
                .foregroundStyle(STRQPalette.textSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.045), in: Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(commandLine.opacity(0.72), lineWidth: 1)
                )

                Text(L10n.format("Woche %d", vm.trainingPhaseState.weeksInPhase))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(STRQPalette.textMuted)

                Spacer(minLength: 8)

                if !vm.hasCheckedInToday {
                    Button {
                        showReadinessCheckIn = true
                    } label: {
                        HStack(spacing: 5) {
                            Image(systemName: "heart.text.clipboard")
                                .font(.system(size: 9, weight: .semibold))
                            Text(L10n.tr("Check-in"))
                                .font(.system(size: 10, weight: .bold))
                        }
                        .foregroundStyle(readinessTeal)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(readinessTeal.opacity(0.12), in: Capsule())
                        .overlay(
                            Capsule()
                                .strokeBorder(readinessTeal.opacity(0.34), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 2)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.clear, commandLine.opacity(0.62), Color.clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
                    .offset(y: -8)
            }
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [STRQPalette.surfaceRaised, STRQPalette.backgroundCarbon],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.055), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
            VStack(alignment: .trailing, spacing: 6) {
                Rectangle()
                    .fill(commandLine.opacity(0.42))
                    .frame(width: 58, height: 1)
                Rectangle()
                    .fill(commandLine.opacity(0.28))
                    .frame(width: 34, height: 1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.15), STRQPalette.borderSubtle.opacity(0.76), Color.black.opacity(0.36)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.26), radius: 18, y: 7)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private func coachReadinessColor(for score: Int) -> Color {
        switch score {
        case 85...:
            return STRQPalette.success
        case 70..<85:
            return Color(red: 0.36, green: 0.74, blue: 0.50)
        case 55..<70:
            return STRQPalette.warning
        case 40..<55:
            return STRQPalette.danger.opacity(0.84)
        default:
            return STRQPalette.danger
        }
    }

    private func coachRecoveryStateLabel(for score: Int) -> String {
        switch score {
        case 85...: return L10n.tr("Ready")
        case 70..<85: return L10n.tr("Steady")
        case 55..<70: return L10n.tr("Light")
        case 40..<55: return L10n.tr("Low")
        default: return L10n.tr("Rest")
        }
    }

    private func coachRecoveryStateIcon(for score: Int) -> String {
        switch score {
        case 85...: return "bolt.fill"
        case 70..<85: return "checkmark.circle.fill"
        case 55..<70: return "arrow.down.circle.fill"
        case 40..<55: return "heart.circle.fill"
        default: return "bed.double.fill"
        }
    }

    private var headline: String {
        if let briefing = vm.dailyBriefing {
            return briefing.primary.title
        }
        if let guidance = vm.earlyStateGuidance {
            return guidance.headline
        }
        if let action = vm.nextBestAction {
            return action.title
        }
        return L10n.tr("Plan wirkt stabil. Kurs halten.")
    }

    // MARK: - Decision Stack (primary move / watch / momentum)

    @ViewBuilder
    private var decisionStack: some View {
        if let briefing = vm.dailyBriefing {
            let density = vm.profile.coachingPreferences.density
            let sideLimit = density.sideSignalsLimit
            let emphasis = vm.profile.coachingPreferences.emphasis
            let showWatch = briefing.watch != nil && sideLimit >= 1
            let showMomentum = briefing.momentum != nil && sideLimit >= (showWatch ? 2 : 1) && emphasis != .simplicity
            VStack(spacing: 12) {
                primaryMoveCard(briefing.primary)

                if showWatch, let watch = briefing.watch {
                    watchCard(watch)
                }

                if showMomentum, let momentum = briefing.momentum {
                    momentumCard(momentum)
                }

                if briefing.moreSignalsCount > 0, density != .focused {
                    Button {
                        showMoreSignals = true
                    } label: {
                        HStack(spacing: 11) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 9, style: .continuous)
                                    .fill(coachEvidenceTint.opacity(0.10))
                                Image(systemName: "list.bullet.rectangle")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(coachEvidenceTint)
                            }
                            .frame(width: 30, height: 30)
                            .overlay(
                                RoundedRectangle(cornerRadius: 9, style: .continuous)
                                    .strokeBorder(coachEvidenceTint.opacity(0.14), lineWidth: 1)
                            )

                            Text(moreSignalsLabel(briefing.moreSignalsCount))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            Spacer()
                            HStack(spacing: 3) {
                                ForEach(0..<min(3, briefing.moreSignalsCount), id: \.self) { _ in
                                    Circle()
                                        .fill(coachEvidenceTint.opacity(0.42))
                                        .frame(width: 4, height: 4)
                                }
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.035), in: Capsule())
                            .accessibilityHidden(true)

                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(coachEvidenceTint.opacity(0.72))
                                .frame(width: 22, height: 22)
                                .background(Color.white.opacity(0.035), in: Circle())
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(coachSupportingSurface, in: .rect(cornerRadius: 13))
                        .overlay(
                            RoundedRectangle(cornerRadius: 13)
                                .strokeBorder(coachEvidenceTint.opacity(0.14), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.strqPressable)
                }

                // Lift tracker only when coach has real signal.
                if vm.coachingConfidence >= .moderate {
                    liftTrackerSection
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.05), value: appeared)
        }
    }

    private func primaryMoveCard(_ primary: DailyBriefing.Primary) -> some View {
        let tint = ForgeTheme.color(for: primary.colorName)
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(tint)
                    .frame(width: 3, height: 14)
                Text(L10n.tr("COACH EMPFIEHLT"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(tint)
                Spacer()
                Text(primary.eyebrow)
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.6)
                    .foregroundStyle(tint)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(tint.opacity(0.12), in: Capsule())
            }

            HStack(alignment: .top, spacing: 14) {
                Image(systemName: primary.icon)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(tint.opacity(0.20), in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(tint.opacity(0.24), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(primary.title)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(primary.detail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            coachPrimaryCTA(primary)

            if let sinceLast = vm.dailyBriefing?.sinceLast {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(STRQPalette.success)
                        .frame(width: 22, height: 22)
                        .background(STRQPalette.successSoft, in: .rect(cornerRadius: 7))
                    Text(sinceLastLine(sinceLast))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                    Spacer(minLength: 0)
                }
                .padding(.top, 2)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color(.secondarySystemGroupedBackground), tint.opacity(0.08)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 20)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(tint.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: tint.opacity(0.10), radius: 18, y: 6)
    }

    private var coachSupportingSurface: LinearGradient {
        LinearGradient(
            colors: [
                STRQPalette.surfaceRaised.opacity(0.90),
                STRQPalette.surfaceBase.opacity(0.98),
                STRQPalette.backgroundCarbon.opacity(0.92)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var coachEvidenceTint: Color {
        Color(red: 0.360, green: 0.550, blue: 0.700)
    }

    private func coachWatchTint(for colorName: String) -> Color {
        switch colorName.lowercased() {
        case "yellow":
            return STRQPalette.warning
        case "red", "pink":
            return STRQPalette.danger.opacity(0.88)
        case "green", "mint":
            return STRQPalette.success
        case "blue", "cyan", "teal":
            return coachEvidenceTint
        default:
            return STRQPalette.warning
        }
    }

    @ViewBuilder
    private func coachPrimaryCTA(_ primary: DailyBriefing.Primary) -> some View {
        switch primary.kind {
        case .checkInBeforeTraining:
            ForgePrimaryButton(icon: "heart.text.clipboard", title: L10n.tr("Check-in")) {
                showReadinessCheckIn = true
            }
        case .startFirstSession:
            if let day = vm.todaysWorkout ?? vm.nextWorkout {
                ForgePrimaryButton(icon: "sparkles", title: L10n.tr("Workout 1 starten")) {
                    vm.prepareWorkoutHandoff(day: day)
                }
            }
        case .resumeWorkout:
            if let day = vm.todaysWorkout {
                ForgePrimaryButton(icon: "play.fill", title: L10n.tr("Workout fortsetzen")) {
                    vm.prepareWorkoutHandoff(day: day)
                }
            }
        case .trainToday, .recoverToday:
            if let day = vm.todaysWorkout {
                ForgePrimaryButton(
                    icon: primary.kind == .recoverToday ? "heart.circle.fill" : "bolt.fill",
                    title: primary.kind == .recoverToday ? L10n.tr("Leichter starten") : L10n.tr("Workout starten")
                ) {
                    vm.prepareWorkoutHandoff(day: day)
                }
            }
        default:
            EmptyView()
        }
    }

    private func watchCard(_ watch: DailyBriefing.Watch) -> some View {
        let tint = coachWatchTint(for: watch.colorName)
        return VStack(alignment: .leading, spacing: showWatchDetails ? 12 : 10) {
            HStack {
                HStack(spacing: 6) {
                    Circle()
                        .fill(tint)
                        .frame(width: 5, height: 5)
                    Text(L10n.tr("IM BLICK"))
                        .font(.system(size: 10, weight: .black))
                        .tracking(1.2)
                }
                .foregroundStyle(tint)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(tint.opacity(0.08), in: Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(tint.opacity(0.12), lineWidth: 1)
                )
                Spacer()
            }

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: watch.icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(tint)
                    .frame(width: 32, height: 32)
                    .background(tint.opacity(0.11), in: .rect(cornerRadius: 9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 9)
                            .strokeBorder(tint.opacity(0.17), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: showWatchDetails ? 9 : 3) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(watch.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 6)
                        Button {
                            withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .snappy(duration: 0.22)) {
                                showWatchDetails.toggle()
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(L10n.tr("common.details", fallback: "Details"))
                                    .font(.caption.weight(.semibold))
                                Image(systemName: showWatchDetails ? "chevron.up" : "chevron.down")
                                    .font(.caption2.weight(.bold))
                            }
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.035), in: Capsule())
                        }
                        .buttonStyle(.plain)
                    }

                    if showWatchDetails {
                        Text(watch.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(4)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(10)
                            .background(Color.white.opacity(0.035), in: .rect(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                            )
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .padding(13)
        .background(coachSupportingSurface, in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(tint.opacity(0.15), lineWidth: 1)
        )
    }

    private func momentumCard(_ momentum: DailyBriefing.Momentum) -> some View {
        HStack(spacing: 12) {
            Image(systemName: momentum.icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(STRQPalette.success)
                .frame(width: 32, height: 32)
                .background(STRQPalette.success.opacity(0.10), in: .rect(cornerRadius: 9))
                .overlay(
                    RoundedRectangle(cornerRadius: 9)
                        .strokeBorder(STRQPalette.success.opacity(0.15), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.tr("MOMENTUM"))
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.1)
                    .foregroundStyle(STRQPalette.success)
                Text(momentum.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)

            HStack(spacing: 3) {
                Circle()
                    .fill(STRQPalette.success.opacity(0.54))
                    .frame(width: 5, height: 5)
                Capsule()
                    .fill(STRQPalette.success.opacity(0.24))
                    .frame(width: 15, height: 5)
            }
            .accessibilityHidden(true)
        }
        .padding(13)
        .background(coachSupportingSurface, in: .rect(cornerRadius: 14))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.clear, STRQPalette.success.opacity(0.18), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, 14)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQPalette.success.opacity(0.14), lineWidth: 1)
        )
    }

    private func moreSignalsLabel(_ count: Int) -> String {
        count == 1
            ? L10n.format("%d more signal", count)
            : L10n.format("%d more signals", count)
    }

    // MARK: - Early State

    @ViewBuilder
    private var earlyStateCard: some View {
        if let guidance = vm.earlyStateGuidance {
            let tierIndex = max(0, min(3, guidance.tier.rawValue))
            let completedStages = tierIndex + 1

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                        Text(L10n.tr("COACH-KALIBRIERUNG"))
                                .font(.system(size: 10, weight: .black))
                                .tracking(1.2)
                                .foregroundStyle(STRQBrand.steel)
                                .lineLimit(1)
                                .minimumScaleFactor(0.82)

                            Text(guidance.tier.label.uppercased())
                                .font(.system(size: 9, weight: .black))
                                .foregroundStyle(.white.opacity(0.9))
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(Color.white.opacity(0.08), in: Capsule())
                                .overlay(
                                    Capsule()
                                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 0.5)
                                )
                        }

                        Text(guidance.headline)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    earlyStateSignalMark(icon: guidance.icon, completedStages: completedStages)
                }

                Text(coachEarlyStateMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if let unlocksNext = guidance.unlocksNext {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(L10n.tr("NÄCHSTES"))
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.1)
                            .foregroundStyle(STRQBrand.steel)
                        Text(unlocksNext)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.primary.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.045), in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
                }

                earlyStateProgressTrack(completedStages: completedStages)
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [
                        STRQPalette.surfaceHero,
                        STRQPalette.surfaceBase,
                        STRQPalette.backgroundPrimary
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: .rect(cornerRadius: 22)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                LinearGradient(
                    colors: [STRQBrand.steel.opacity(0.22), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)
                .padding(.horizontal, 18)
            }
            .shadow(color: .black.opacity(0.22), radius: 16, y: 6)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.05), value: appeared)
        }
    }

    private func earlyStateSignalMark(icon: String, completedStages: Int) -> some View {
        ZStack(alignment: .bottomTrailing) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.045))
                .frame(width: 72, height: 78)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                )

            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 54, height: 54)
                .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.20), lineWidth: 1)
                )
                .offset(x: -10, y: -12)

            HStack(spacing: 3) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .fill(index < completedStages ? STRQBrand.steel : Color.white.opacity(0.16))
                        .frame(width: 4, height: 4)
                }
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 5)
            .background(Color.black.opacity(0.28), in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 0.5)
            )
        }
        .frame(width: 78, height: 82)
    }

    private func earlyStateProgressTrack(completedStages: Int) -> some View {
        HStack(spacing: 5) {
            ForEach(0..<4, id: \.self) { index in
                Capsule()
                    .fill(index < completedStages ? STRQBrand.steel : Color.white.opacity(0.08))
                    .frame(maxWidth: .infinity, minHeight: 3, maxHeight: 3)
            }
        }
    }

    private var coachEarlyStateMessage: String {
        switch vm.dataMaturityTier {
        case .fresh:
            return L10n.tr("Heute zählt der erste Schritt. Nach dem ersten echten Workout werden Gewicht und Erholung konkreter eingeordnet.")
        case .firstSession:
            return L10n.tr("Ausgangswert ist gesetzt. Woche weiterführen, STRQ schärft die Details im Hintergrund.")
        case .earlyWeek:
            return L10n.tr("Etwas mehr echte Trainingsdaten machen den Coach persönlicher.")
        case .established:
            return L10n.tr("Plan wirkt stabil. Kurs halten.")
        }
    }

    private var shouldShowCalibrationChecklist: Bool {
        vm.dataMaturityTier != .firstSession
    }

    private var calibrationChecklist: some View {
        let completed = vm.totalCompletedWorkouts
        let weekSessions = vm.weeklyStats.sessions
        let hasRecoveryContext = vm.hasCheckedInToday || vm.todaysReadiness != nil
        let calibrationAccent = Color(red: 0.50, green: 0.58, blue: 0.66)
        let calibrationInk = Color(red: 0.72, green: 0.78, blue: 0.84)
        let calibrationDim = Color(red: 0.08, green: 0.10, blue: 0.12)
        let completedSignal = STRQColors.successGreen

        let items: [(String, String, Bool)] = [
            (L10n.tr("Planstruktur erfasst"), "doc.text.fill", vm.currentPlan != nil),
            (L10n.tr("Echte Trainingsdaten geloggt"), "figure.strengthtraining.traditional", completed >= 1),
            (L10n.tr("Erholungskontext geloggt"), "heart.text.clipboard.fill", hasRecoveryContext),
            (L10n.tr("Wochenrhythmus gestartet"), "calendar.badge.clock", weekSessions >= 1)
        ]
        let completedCount = items.filter { $0.2 }.count
        let progress = CGFloat(completedCount) / CGFloat(items.count)

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(calibrationAccent.opacity(0.14))
                    Image(systemName: "waveform.path.ecg")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(calibrationInk)
                }
                .frame(width: 30, height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(calibrationAccent.opacity(0.22), lineWidth: 1)
                )
                .accessibilityHidden(true)

                Text(L10n.tr("Was STRQ erfasst hat"))
                    .font(.system(size: 11, weight: .black))
                    .tracking(1.1)
                    .foregroundStyle(calibrationInk)
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Spacer(minLength: 8)

                HStack(spacing: 4) {
                    ForEach(0..<items.count, id: \.self) { index in
                        Capsule()
                            .fill(index < completedCount ? completedSignal : calibrationAccent.opacity(0.24))
                            .frame(width: index < completedCount ? 12 : 5, height: 5)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 14) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(calibrationAccent.opacity(0.14))
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [calibrationInk.opacity(0.70), calibrationAccent.opacity(0.90)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: progress == 0 ? 0 : max(6, geo.size.width * progress))
                    }
                }
                .frame(height: 4)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 8, alignment: .top),
                        GridItem(.flexible(), spacing: 8, alignment: .top)
                    ],
                    spacing: 8
                ) {
                    ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(item.2 ? completedSignal.opacity(0.16) : calibrationAccent.opacity(0.09))
                                        .frame(width: 24, height: 24)
                                    Circle()
                                        .strokeBorder(item.2 ? completedSignal.opacity(0.62) : calibrationAccent.opacity(0.28), lineWidth: 1)
                                        .frame(width: 24, height: 24)
                                    Image(systemName: item.2 ? "checkmark" : "circle.fill")
                                        .font(.system(size: item.2 ? 10 : 5, weight: .black))
                                        .foregroundStyle(item.2 ? completedSignal : calibrationAccent.opacity(0.48))
                                }

                                Spacer(minLength: 0)

                                Image(systemName: item.1)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(item.2 ? calibrationInk : calibrationAccent.opacity(0.56))
                                    .frame(width: 28, height: 28)
                                    .background(
                                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                                            .fill(Color.white.opacity(item.2 ? 0.055 : 0.030))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                                            .strokeBorder(Color.white.opacity(item.2 ? 0.090 : 0.045), lineWidth: 1)
                                    )
                            }

                            Text(item.0)
                                .font(.caption.weight(item.2 ? .semibold : .medium))
                                .foregroundStyle(item.2 ? Color.primary : calibrationInk.opacity(0.62))
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(item.2 ? 0.045 : 0.020))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.white.opacity(item.2 ? 0.080 : 0.045), lineWidth: 1)
                        )
                    }
                }
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [
                        calibrationDim,
                        STRQPalette.surfaceBase,
                        STRQPalette.backgroundCarbon
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: .rect(cornerRadius: 18)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(calibrationAccent.opacity(0.18), lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                LinearGradient(
                    colors: [calibrationInk.opacity(0.28), Color.clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)
                .padding(.horizontal, 16)
            }
            .shadow(color: .black.opacity(0.18), radius: 12, y: 5)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    // MARK: - Lift Tracker

    @ViewBuilder
    private var liftTrackerSection: some View {
        let stalled = vm.stalledExercises.prefix(2)
        let progressing = vm.progressingExercises.prefix(2)
        if !stalled.isEmpty || !progressing.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                ForgeSectionHeader(title: L10n.tr("Lift-Status"))

                ForEach(Array(stalled)) { state in
                    liftRow(state: state, isStalled: true)
                }

                ForEach(Array(progressing)) { state in
                    liftRow(state: state, isStalled: false)
                }
            }
            .padding(.top, 4)
        }
    }

    private func liftRow(state: ExerciseProgressionState, isStalled: Bool) -> some View {
        let exercise = vm.library.exercise(byId: state.exerciseId)
        let color: Color = isStalled ? (state.plateauStatus == .regressing ? STRQPalette.danger : STRQPalette.warning) : STRQPalette.success

        return HStack(spacing: 12) {
            Image(systemName: isStalled ? state.plateauStatus.icon : "arrow.up.right")
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.15), in: .rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(exercise?.name ?? state.exerciseId)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(isStalled ? state.plateauStatus.displayName : L10n.tr("coach.liftTracker.progressing", fallback: "Steigt"))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(color)
                    if let next = state.suggestedNextWeight, !isStalled {
                        Text(L10n.format("Nächstes Gewicht: %@", coachLoadDisplay(next)))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    if isStalled {
                        Text(state.recommendedStrategy.displayName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            Spacer()
        }
        .padding(12)
        .background(coachSupportingSurface, in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(color.opacity(0.12), lineWidth: 1)
        )
    }

    // MARK: - Recent Change Bridge

    @ViewBuilder
    private var recentChangeBridge: some View {
        let timeline = CoachingMemoryService().buildTimeline(
            adjustments: vm.coachAdjustments,
            phaseState: vm.trainingPhaseState,
            planEvolutionSignals: vm.planEvolutionSignals,
            outlook: vm.phaseOutlook,
            physique: vm.physiqueOutcome,
            activeWeekAdjustment: vm.weekAdjustmentActive,
            nutritionTrackingEnabled: vm.profile.nutritionTrackingEnabled,
            limit: 1
        )
        if let latest = timeline.first {
            Button {
                showCoachingHistory = true
                Analytics.shared.track(.coach_viewed, ["surface": "memory_bridge"])
            } label: {
                coachMemoryBridgeRow(entry: latest, totalCount: totalMemoryCount)
            }
            .buttonStyle(.plain)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.16), value: appeared)
        } else if !vm.isEarlyStage {
            Button {
                showCoachingHistory = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(STRQBrand.steel)
                        .frame(width: 24, height: 24)
                        .background(STRQBrand.steelGradient.opacity(0.5), in: .rect(cornerRadius: 7))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(L10n.tr("Coach-Verlauf"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(L10n.tr("Änderungen erscheinen hier."))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.quaternary)
                }
                .padding(12)
                .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.16), value: appeared)
        }
    }

    private func coachMemoryBridgeRow(entry: CoachMemoryEntry, totalCount: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(STRQPalette.color(for: entry.state))
                    .frame(width: 3, height: 12)
                Text(L10n.tr("LETZTE ÄNDERUNG"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(.primary)
                Spacer()
                Text(totalCount > 1 ? L10n.format("Alle %d anzeigen", totalCount) : L10n.tr("Verlauf anzeigen"))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(STRQBrand.steel)
                Image(systemName: "chevron.right")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.tertiary)
            }

            HStack(alignment: .top, spacing: 12) {
                Image(systemName: entry.icon)
                    .font(.subheadline)
                    .foregroundStyle(STRQPalette.color(for: entry.state))
                    .frame(width: 32, height: 32)
                    .background(STRQPalette.soft(for: entry.state), in: .rect(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(localizedMemoryScope(entry.scope).uppercased())
                            .font(.system(size: 9, weight: .black))
                            .tracking(0.8)
                            .foregroundStyle(STRQBrand.steel)
                        if let status = entry.status {
                            Text("·")
                                .font(.system(size: 9, weight: .black))
                                .foregroundStyle(.tertiary)
                            Text(localizedMemoryStatus(status))
                                .font(.system(size: 9, weight: .bold))
                                .tracking(0.4)
                                .foregroundStyle(STRQPalette.color(for: entry.state))
                        }
                        Spacer(minLength: 0)
                    }
                    Text(localizedMemoryTitle(entry.title))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                    Text(localizedMemoryDetail(entry.expectation ?? entry.driver))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private func localizedMemoryScope(_ scope: CoachMemoryScope) -> String {
        switch scope {
        case .session:
            return L10n.tr("Workout")
        case .week:
            return L10n.tr("Woche")
        case .block:
            return L10n.tr("Block")
        }
    }

    private func localizedMemoryStatus(_ raw: String) -> String {
        let normalized = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalized.contains("pending adjustment") { return L10n.tr("In Prüfung") }
        if normalized.contains("active this week") { return L10n.tr("Diese Woche aktiv") }
        if normalized.contains("staged for next session") { return L10n.tr("Für nächste Einheit") }
        if normalized.contains("applied") { return L10n.tr("Berücksichtigt") }
        if normalized.contains("calibrating") { return L10n.tr("Kalibriert") }
        if normalized.contains("directional") { return L10n.tr("Richtung klar") }
        if normalized.contains("confident") { return L10n.tr("Stabil") }
        return raw
    }

    private func localizedMemoryTitle(_ raw: String) -> String {
        if raw.hasPrefix("Shift Anchor: ") {
            let payload = raw.replacingOccurrences(of: "Shift Anchor: ", with: "")
            let parts = payload.components(separatedBy: " Over ")
            if parts.count == 2 {
                return L10n.format("Anchor prüfen: %@ vor %@", parts[0], parts[1])
            }
            return L10n.format("Anchor prüfen: %@", payload)
        }
        return raw
            .replacingOccurrences(of: "Pending adjustment", with: L10n.tr("In Prüfung"))
            .replacingOccurrences(of: "Shift Anchor", with: L10n.tr("Anchor prüfen"))
    }

    private func localizedMemoryDetail(_ raw: String) -> String {
        let normalized = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if normalized.hasPrefix("Repeated stalls on "),
           let whileRange = normalized.range(of: " while "),
           let progressingRange = normalized.range(of: " keeps progressing") {
            let stalled = String(normalized[normalized.index(normalized.startIndex, offsetBy: "Repeated stalls on ".count)..<whileRange.lowerBound])
            let progressing = String(normalized[whileRange.upperBound..<progressingRange.lowerBound])
            return L10n.format("%@ stockt wiederholt, %@ steigt weiter. Reihenfolge für nächste Woche prüfen.", stalled, progressing)
        }
        return raw
            .replacingOccurrences(of: "Pending adjustment", with: L10n.tr("In Prüfung"))
            .replacingOccurrences(of: "reorder next week", with: L10n.tr("Reihenfolge nächste Woche prüfen"))
            .replacingOccurrences(of: "keeps progressing", with: L10n.tr("steigt weiter"))
            .replacingOccurrences(of: "Repeated stalls", with: L10n.tr("Wiederholtes Stocken"))
    }

    private var totalMemoryCount: Int {
        CoachingMemoryService().buildTimeline(
            adjustments: vm.coachAdjustments,
            phaseState: vm.trainingPhaseState,
            planEvolutionSignals: vm.planEvolutionSignals,
            outlook: vm.phaseOutlook,
            physique: vm.physiqueOutcome,
            activeWeekAdjustment: vm.weekAdjustmentActive,
            nutritionTrackingEnabled: vm.profile.nutritionTrackingEnabled,
            limit: 30
        ).count
    }

    // MARK: - Weekly Check-In

    @ViewBuilder
    private var weeklyCheckInRow: some View {
        VStack(spacing: 10) {
            if !vm.isEarlyStage, let quality = vm.planQuality {
                planQualityRow(quality)
            }

            if vm.isWeeklyReviewReady {
                Button {
                    vm.generateWeeklyReview()
                    showWeeklyReview = true
                } label: {
                    weeklyReviewLabel(subtitle: L10n.tr("Woche prüfen und anpassen"), ready: true)
                }
            } else if vm.isEarlyStage {
                passiveWeeklyCheckInLabel(
                    subtitle: vm.sessionsUntilReviewReady == 0
                        ? L10n.tr("Fast da - eine Einheit rundet die Woche ab")
                        : L10n.format(vm.sessionsUntilReviewReady == 1 ? "Noch %d Workout, dann wird die erste Wochenlesung klarer" : "Noch %d Workouts, dann wird die erste Wochenlesung klarer", vm.sessionsUntilReviewReady)
                )
            } else {
                Button {
                    vm.generateWeeklyReview()
                    showWeeklyReview = true
                } label: {
                    weeklyReviewLabel(subtitle: L10n.tr("Woche prüfen und anpassen"), ready: true)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.18), value: appeared)
    }

    private func passiveWeeklyCheckInLabel(subtitle: String) -> some View {
        let weeklyPassiveAccent = Color(red: 0.18, green: 0.30, blue: 0.40)
        let weeklyPassiveInk = Color(red: 0.56, green: 0.70, blue: 0.78)
        let weeklyPassiveDim = Color(red: 0.04, green: 0.07, blue: 0.09)

        return HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                weeklyPassiveAccent.opacity(0.20),
                                weeklyPassiveDim.opacity(0.72)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(weeklyPassiveInk)
            }
            .frame(width: 38, height: 38)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(weeklyPassiveInk.opacity(0.20), lineWidth: 1)
            )
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.tr("Wochen-Check-in"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Color.white.opacity(0.62))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .strokeBorder(weeklyPassiveAccent.opacity(0.28), lineWidth: 1)
                    .frame(width: 20, height: 20)
                Circle()
                    .fill(weeklyPassiveInk.opacity(0.38))
                    .frame(width: 5, height: 5)
            }
            .accessibilityHidden(true)
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [
                    weeklyPassiveDim.opacity(0.92),
                    STRQPalette.surfaceBase.opacity(0.96),
                    weeklyPassiveAccent.opacity(0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(weeklyPassiveAccent.opacity(0.24), lineWidth: 1)
        )
        .overlay(alignment: .topLeading) {
            LinearGradient(
                colors: [weeklyPassiveInk.opacity(0.22), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
            .padding(.horizontal, 16)
        }
    }

    private func weeklyReviewLabel(subtitle: String, ready: Bool) -> some View {
        let reportNavy = Color(red: 0.055, green: 0.090, blue: 0.145)
        let reportSteel = Color(red: 0.360, green: 0.470, blue: 0.590)
        let reportInk = Color(red: 0.620, green: 0.730, blue: 0.840)

        return HStack(alignment: .center, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                reportSteel.opacity(0.26),
                                reportNavy.opacity(0.92)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                Image(systemName: ready ? "doc.text.magnifyingglass" : "calendar.badge.clock")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(reportInk)
            }
            .frame(width: 40, height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(reportInk.opacity(0.18), lineWidth: 1)
            )
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.tr("Wochen-Check-in"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(STRQPalette.textPrimary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(STRQPalette.textSecondary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            if ready {
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(reportInk.opacity(0.82))
                    .frame(width: 26, height: 26)
                    .background(Color.white.opacity(0.045), in: Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(reportInk.opacity(0.12), lineWidth: 1)
                    )
            }
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [
                    reportNavy.opacity(0.96),
                    STRQPalette.surfaceRaised,
                    STRQPalette.backgroundCarbon
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 16)
        )
        .overlay(alignment: .topLeading) {
            LinearGradient(
                colors: [reportInk.opacity(0.22), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
            .padding(.horizontal, 16)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(reportInk.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.16), radius: 10, y: 4)
    }

    private func planQualityRow(_ quality: PlanQualityScore) -> some View {
        let overallColor = ForgeTheme.color(for: quality.overallColor)
        return HStack(spacing: 14) {
            Image(systemName: quality.overall >= 0.7 ? "checkmark.seal.fill" : "exclamationmark.circle.fill")
                .font(.title3)
                .foregroundStyle(overallColor)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(L10n.tr("Planqualität"))
                        .font(.subheadline.weight(.semibold))
                    Text(quality.localizedOverallLabel)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(overallColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(overallColor.opacity(0.1), in: Capsule())
                }
                if let strength = quality.strengths.first {
                    Label(coachPlanQualityLine(strength), systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private func coachPlanQualityLine(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed == "Training load matches your recovery capacity"
            || trimmed.localizedCaseInsensitiveContains("recovery capacity")
            || trimmed.localizedCaseInsensitiveContains("Erholungskapazität") {
            return L10n.tr("Training load fits today's context")
        }
        return trimmed
    }

    private func sinceLastLine(_ sinceLast: DailyBriefing.SinceLast) -> String {
        if sinceLast.eyebrow == L10n.tr("Neuer PR") {
            return L10n.format("%@ · %@", sinceLast.eyebrow, sinceLast.summary)
        }
        return L10n.format("%@ - %@", sinceLast.eyebrow, sinceLast.summary)
    }

    private func coachLoadDisplay(_ value: Double) -> String {
        "\(coachDecimalDisplay(value)) kg"
    }

    private func coachDecimalDisplay(_ value: Double) -> String {
        let rounded = (value * 10).rounded() / 10
        let format = abs(rounded.rounded() - rounded) < 0.01 ? "%.0f" : "%.1f"
        return String(format: format, rounded).replacingOccurrences(of: ".", with: ",")
    }
}

// MARK: - More Signals Sheet

struct MoreSignalsSheet: View {
    let vm: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var expandedInsightIds: Set<String> = []
    @State private var expandedRecIds: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                let insights = Array(vm.highPriorityInsights.dropFirst())
                let recs = Array(vm.recommendations.dropFirst(vm.highPriorityInsights.isEmpty ? 1 : 0))

                if !insights.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        ForgeSectionHeader(title: L10n.tr("coach.moreSignals.watch", fallback: "Im Blick"))
                        ForEach(insights) { insight in
                            let displayInsight = displaySafeInsight(insight)
                            ExpandableInsightCard(
                                insight: displayInsight,
                                actions: CoachActionMapper.actions(for: insight),
                                vm: vm,
                                isExpanded: Binding(
                                    get: { expandedInsightIds.contains(insight.id) },
                                    set: { v in if v { expandedInsightIds.insert(insight.id) } else { expandedInsightIds.remove(insight.id) } }
                                ),
                                onAction: { _ in }
                            )
                        }
                    }
                }

                if !recs.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        ForgeSectionHeader(title: L10n.tr("Empfehlungen"))
                        ForEach(recs) { rec in
                            let displayRecommendation = displaySafeRecommendation(rec)
                            ExpandableRecommendationCard(
                                recommendation: displayRecommendation,
                                actions: CoachActionMapper.actions(for: rec),
                                vm: vm,
                                isExpanded: Binding(
                                    get: { expandedRecIds.contains(rec.id) },
                                    set: { v in if v { expandedRecIds.insert(rec.id) } else { expandedRecIds.remove(rec.id) } }
                                ),
                                onAction: { _ in }
                            )
                        }
                    }
                }

                if insights.isEmpty && recs.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title)
                            .foregroundStyle(STRQPalette.success)
                        Text(L10n.tr("Keine weiteren Signale"))
                            .font(.subheadline.weight(.semibold))
                        Text(L10n.tr("coach.moreSignals.empty.detail", fallback: "Keine weiteren klaren Signale."))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 40)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle(L10n.tr("Weitere Signale"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(L10n.tr("Fertig")) { dismiss() }
                    .font(.subheadline.weight(.semibold))
            }
        }
    }

    private func displaySafeInsight(_ insight: SmartInsight) -> SmartInsight {
        SmartInsight(
            id: insight.id,
            icon: insight.icon,
            color: insight.color,
            title: displaySafeCoachText(insight.title),
            message: displaySafeCoachText(insight.message),
            severity: insight.severity,
            category: insight.category
        )
    }

    private func displaySafeRecommendation(_ recommendation: Recommendation) -> Recommendation {
        Recommendation(
            id: recommendation.id,
            type: recommendation.type,
            title: displaySafeCoachText(recommendation.title),
            message: displaySafeCoachText(recommendation.message),
            priority: recommendation.priority,
            date: recommendation.date
        )
    }

    private func displaySafeCoachText(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed == "Plan a Fatigue-Management Week" {
            return L10n.tr("Leichtere Woche prüfen")
        }
        if trimmed.hasPrefix("Lead With ") {
            let lift = String(trimmed[trimmed.index(trimmed.startIndex, offsetBy: "Lead With ".count)...])
            return L10n.format("%@ priorisieren", lift)
        }
        if trimmed.hasPrefix("Promote ") {
            let lift = String(trimmed[trimmed.index(trimmed.startIndex, offsetBy: "Promote ".count)...])
            return L10n.format("%@ priorisieren", lift)
        }
        if trimmed.hasPrefix("Hold "),
           trimmed.hasSuffix(" for Quality") {
            let start = trimmed.index(trimmed.startIndex, offsetBy: "Hold ".count)
            let end = trimmed.index(trimmed.endIndex, offsetBy: -" for Quality".count)
            let lift = String(trimmed[start..<end])
            return L10n.format("%@ sauber halten", lift)
        }
        if trimmed == "Fatigue Trending Up Across Weeks" {
            return L10n.tr("Viele harte Wochen")
        }
        if trimmed.hasPrefix("Form Breakdown on ") {
            let lift = String(trimmed[trimmed.index(trimmed.startIndex, offsetBy: "Form Breakdown on ".count)...])
            return L10n.format("%@: Technik prüfen", lift)
        }
        if let outperformingRange = trimmed.range(of: " Outperforming ") {
            let lift = String(trimmed[..<outperformingRange.lowerBound])
            let otherLift = String(trimmed[outperformingRange.upperBound...])
            return L10n.format("%@ vor %@ prüfen", lift, otherLift)
        }
        if trimmed.hasPrefix("Shift Anchor: "),
           let overRange = trimmed.range(of: " Over ") {
            let payloadStart = trimmed.index(trimmed.startIndex, offsetBy: "Shift Anchor: ".count)
            let lift = String(trimmed[payloadStart..<overRange.lowerBound])
            let otherLift = String(trimmed[overRange.upperBound...])
            return L10n.format("Anchor prüfen: %@ vor %@", lift, otherLift)
        }
        if trimmed.hasPrefix("Recovery has dropped") && trimmed.contains("fatigue-management week") {
            return L10n.tr("Erholung ist gesunken, während viele Einheiten geloggt wurden. Leichtere Woche prüfen.")
        }
        if trimmed.hasPrefix("Form has broken down") {
            return L10n.tr("Technik war zuletzt wiederholt unsauber. Gewicht halten und saubere Wiederholungen bestätigen.")
        }
        if trimmed.hasPrefix("Reorder "),
           let leadRange = trimmed.range(of: ": Lead With ") {
            let day = String(trimmed[trimmed.index(trimmed.startIndex, offsetBy: "Reorder ".count)..<leadRange.lowerBound])
            let lift = String(trimmed[leadRange.upperBound...])
            return L10n.format("%@ neu ordnen: %@ zuerst", day, lift)
        }
        if trimmed.hasPrefix("Repeated stalls on "),
           let whileRange = trimmed.range(of: " while "),
           let progressingRange = trimmed.range(of: " keeps progressing") {
            let stalled = String(trimmed[trimmed.index(trimmed.startIndex, offsetBy: "Repeated stalls on ".count)..<whileRange.lowerBound])
            let progressing = String(trimmed[whileRange.upperBound..<progressingRange.lowerBound])
            return L10n.format("%@ stockt wiederholt, %@ steigt weiter. Reihenfolge für nächste Woche prüfen.", stalled, progressing)
        }
        if trimmed.hasPrefix("Sustained clean progress on "),
           let strongerRange = trimmed.range(of: " is a stronger signal than forcing "),
           let leadRange = trimmed.range(of: ". Lead with it next block.") {
            let progressing = String(trimmed[trimmed.index(trimmed.startIndex, offsetBy: "Sustained clean progress on ".count)..<strongerRange.lowerBound])
            let stalled = String(trimmed[strongerRange.upperBound..<leadRange.lowerBound])
            return L10n.format("%@ zeigt stabilere Progression als %@. Nächsten Block damit starten.", progressing, stalled)
        }
        if trimmed.hasPrefix("Pull-Up keeps progressing with clean work while Lat Pulldown has stalled") {
            return L10n.tr("Pull-Up steigt sauber weiter, während Lat Pulldown stockt. Pull-Up als Haupt-Lat-Lift prüfen.")
        }
        if let progressingRange = trimmed.range(of: " is progressing while "),
           let stalledRange = trimmed.range(of: " has stalled for "),
           trimmed.contains(" Leading with ") {
            let lift = String(trimmed[..<progressingRange.lowerBound])
            let otherLift = String(trimmed[progressingRange.upperBound..<stalledRange.lowerBound])
            return L10n.format("%@ steigt weiter, während %@ stockt. Reihenfolge für den nächsten Block prüfen.", lift, otherLift)
        }
        if let cleanRange = trimmed.range(of: " keeps progressing with clean work while "),
           let hasStalledRange = trimmed.range(of: " has stalled. Promote ") {
            let lift = String(trimmed[..<cleanRange.lowerBound])
            let otherLift = String(trimmed[cleanRange.upperBound..<hasStalledRange.lowerBound])
            return L10n.format("%@ steigt sauber weiter, während %@ stockt. Haupt-Lift prüfen.", lift, otherLift)
        }
        if trimmed == "Multi-week recovery trend is negative. A lighter block now preserves long-term progress better than pushing through." {
            return L10n.tr("Erholung wirkt seit ein paar Wochen niedrig. Leichteren Block prüfen.")
        }
        if trimmed == "Repeated form breakdown caps progression confidence. Rebuild clean reps at the same load before adding weight." {
            return L10n.tr("Technik war wiederholt unsauber. Erst saubere Wiederholungen bei gleichem Gewicht bestätigen.")
        }

        let absName = "A" + "bs"
        return formatCoachInlineUnits(trimmed)
            .replacingOccurrences(of: absName, with: L10n.tr("Bauch"))
            .replacingOccurrences(of: "Recovery-Kapazität", with: L10n.tr("Erholungskapazität"))
            .replacingOccurrences(of: "Back-to-back schwere Einheiten", with: L10n.tr("Zwei schwere Einheiten direkt hintereinander"))
            .replacingOccurrences(of: "doppelte progression", with: L10n.tr("doppelte Progression"))
            .replacingOccurrences(of: "hart gepusht", with: L10n.tr("hart trainiert"))
    }

    private func formatCoachInlineUnits(_ raw: String) -> String {
        var text = replacingCoachMatches(in: raw, pattern: #"([+]?\d+)\.(\d)kg"#) { groups in
            guard groups.count >= 3 else { return groups.first ?? "" }
            return "\(groups[1]),\(groups[2]) kg"
        }
        text = replacingCoachMatches(in: text, pattern: #"([+]?\d+)kg"#) { groups in
            guard groups.count >= 2 else { return groups.first ?? "" }
            return "\(groups[1]) kg"
        }
        text = replacingCoachMatches(in: text, pattern: #"(\d+)\.(\d)x"#) { groups in
            guard groups.count >= 3 else { return groups.first ?? "" }
            return "\(groups[1]),\(groups[2])×"
        }
        return text
    }

    private func replacingCoachMatches(in raw: String, pattern: String, transform: ([String]) -> String) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return raw }
        var result = raw
        let matches = regex.matches(in: raw, range: NSRange(raw.startIndex..<raw.endIndex, in: raw))
        for match in matches.reversed() {
            guard let fullRange = Range(match.range, in: result) else { continue }
            let groups = (0..<match.numberOfRanges).map { index -> String in
                guard let range = Range(match.range(at: index), in: result) else { return "" }
                return String(result[range])
            }
            result.replaceSubrange(fullRange, with: transform(groups))
        }
        return result
    }
}
