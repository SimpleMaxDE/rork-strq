import SwiftUI

struct DashboardView: View {
    let vm: AppViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared: Bool = false
    @State private var showReadinessCheckIn: Bool = false
    @State private var showWeeklyReview: Bool = false
    @State private var showNutritionLog: Bool = false
    @State private var showSleepLog: Bool = false
    @State private var showWeightLog: Bool = false
    @State private var showWeekPulseDetails: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                todayHero
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                primaryActionCard
                    .padding(.horizontal, 16)

                if let bridge = postWorkoutBridge {
                    postWorkoutBridgeCard(bridge)
                        .padding(.horizontal, 16)
                }

                if isPostFirstSessionState {
                    if let roadmap = vm.activationRoadmap {
                        ActivationRoadmapCard(roadmap: roadmap, compact: true)
                            .padding(.horizontal, 16)
                            .onAppear {
                                Analytics.shared.track(.activation_roadmap_viewed, [
                                    "completed": String(roadmap.completedCount),
                                    "surface": "today"
                                ])
                            }
                    }

                    scheduleTimeline
                        .padding(.horizontal, 16)

                    dailySignalsRow
                        .padding(.horizontal, 16)

                    if let since = vm.dailyBriefing?.sinceLast, postWorkoutBridge == nil {
                        sinceLastCard(since)
                            .padding(.horizontal, 16)
                    }
                } else {
                    if let since = vm.dailyBriefing?.sinceLast, postWorkoutBridge == nil {
                        sinceLastCard(since)
                            .padding(.horizontal, 16)
                    }

                    if let roadmap = vm.activationRoadmap {
                        ActivationRoadmapCard(roadmap: roadmap, compact: true)
                            .padding(.horizontal, 16)
                            .onAppear {
                                Analytics.shared.track(.activation_roadmap_viewed, [
                                    "completed": String(roadmap.completedCount),
                                    "surface": "today"
                                ])
                            }
                    } else if let comeback = vm.comebackGuidance {
                        ComebackCard(
                            guidance: comeback,
                            onEaseNext: comeback.offersLighterSession ? {
                                Analytics.shared.track(.comeback_cta_tapped, [
                                    "action": "ease",
                                    "tier": comeback.tier.rawValue,
                                    "surface": "today"
                                ])
                                vm.applyComebackLighterSession()
                            } : nil,
                            onCheckIn: vm.hasCheckedInToday ? nil : {
                                Analytics.shared.track(.comeback_cta_tapped, [
                                    "action": "checkin",
                                    "tier": comeback.tier.rawValue,
                                    "surface": "today"
                                ])
                                showReadinessCheckIn = true
                            }
                        )
                        .padding(.horizontal, 16)
                        .onAppear {
                            Analytics.shared.track(.comeback_card_viewed, [
                                "tier": comeback.tier.rawValue,
                                "days_since": String(comeback.daysSinceLastWorkout),
                                "surface": "today"
                            ])
                        }
                    } else if let guidance = vm.earlyStateGuidance {
                        earlyStageHint(guidance)
                            .padding(.horizontal, 16)
                    }

                    scheduleTimeline
                        .padding(.horizontal, 16)

                    dailySignalsRow
                        .padding(.horizontal, 16)
                }

                if !vm.isEarlyStage {
                    weekPulse
                        .padding(.horizontal, 16)
                }
            }
            .padding(.bottom, 32)
        }
        .background {
            LinearGradient(
                colors: [STRQPalette.backgroundPrimary, STRQPalette.backgroundCarbon],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
        .navigationTitle(L10n.tr("Today"))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5)) { appeared = true }
            vm.refreshDailyState()
            Analytics.shared.track(.today_viewed)
        }
        .sheet(isPresented: $showReadinessCheckIn) {
            ReadinessCheckInView(vm: vm) { readiness in
                vm.submitReadiness(readiness)
            }
        }
        .sheet(isPresented: $showWeeklyReview) {
            if let review = vm.weeklyReview {
                WeeklyCheckInView(vm: vm, review: review)
            }
        }
        .sheet(isPresented: $showNutritionLog) {
            NavigationStack {
                NutritionLogView(vm: vm)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSleepLog) {
            NavigationStack {
                SleepLogView(vm: vm)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showWeightLog) {
            WeightQuickLogSheet(vm: vm)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
                .presentationContentInteraction(.scrolls)
        }
    }

    // MARK: - Today Hero

    private var todayHero: some View {
        let accent = vm.todaysReadiness.map { ForgeTheme.recoveryColor(for: $0.readinessScore) } ?? STRQPalette.borderStrong

        return ForgeSurface(variant: .hero, accent: accent, padding: 18) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(greeting)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(STRQPalette.textSecondary)
                    Text(vm.profile.name.isEmpty ? L10n.tr("Athlete") : vm.profile.name)
                        .font(.system(.title2, design: .rounded, weight: .heavy))
                        .foregroundStyle(STRQPalette.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
                Spacer()
                readinessBadge
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
    }

    private var readinessBadge: some View {
        Group {
            if let readiness = vm.todaysReadiness {
                let score = readiness.readinessScore
                let color = ForgeTheme.recoveryColor(for: score)
                STRQMetricTile(
                    value: "\(score)",
                    label: L10n.tr("Ready"),
                    icon: "waveform.path.ecg",
                    tint: color,
                    progress: appeared ? Double(score) / 100 : 0,
                    compact: true
                )
                .frame(width: 94)
                .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.8).delay(0.2), value: appeared)
            } else if vm.streak > 0 {
                STRQBadgeChip(label: "\(vm.streak)", icon: "flame.fill", variant: .accent)
            }
        }
    }

    // MARK: - Primary Action Card (Daily Briefing)

    @ViewBuilder
    private var primaryActionCard: some View {
        if let briefing = vm.dailyBriefing {
            let primary = briefing.primary
            if let today = vm.todaysWorkout, primaryTrainsToday(primary.kind) {
                workoutCard(today, briefing: briefing)
            } else {
                briefingCard(primary, briefing: briefing)
            }
        }
    }

    private func primaryTrainsToday(_ kind: DailyBriefing.PrimaryKind) -> Bool {
        switch kind {
        case .trainToday, .checkInBeforeTraining, .resumeWorkout, .recoverToday:
            return true
        default:
            return false
        }
    }

    private func briefingCard(_ primary: DailyBriefing.Primary, briefing: DailyBriefing) -> some View {
        let tint = ForgeTheme.color(for: primary.colorName)
        return ForgeSurface(variant: .elevated, accent: tint, padding: 16) {
            VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Capsule()
                    .fill(tint.gradient)
                    .frame(width: 3, height: 14)
                Text(primary.eyebrow)
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(tint)
                Spacer()
                if vm.isEarlyStage {
                    todayPriorityPill
                } else if let momentum = briefing.momentum {
                    STRQBadgeChip(label: momentum.title, icon: momentum.icon, variant: .neutral)
                }
            }

            HStack(alignment: .top, spacing: 14) {
                Image(systemName: primary.icon)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(tint)
                    .frame(width: 46, height: 46)
                    .background(tint.opacity(0.14), in: .rect(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(tint.opacity(0.24), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(primary.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(STRQPalette.textPrimary)
                    Text(primary.detail)
                        .font(.footnote)
                        .foregroundStyle(STRQPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            if let rest = briefing.restPrep {
                HStack(spacing: 10) {
                    Image(systemName: rest.icon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(STRQPalette.steel)
                        .frame(width: 24, height: 24)
                        .background(STRQPalette.steelSoft, in: .rect(cornerRadius: 7))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(rest.title)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(STRQPalette.textPrimary)
                        Text(rest.detail)
                            .font(.caption2)
                            .foregroundStyle(STRQPalette.textMuted)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.top, 2)
            }

            primaryCTA(primary)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.05), value: appeared)
    }

    @ViewBuilder
    private func primaryCTA(_ primary: DailyBriefing.Primary) -> some View {
        switch primary.kind {
        case .checkInBeforeTraining:
            STRQPrimaryCTA(icon: "heart.text.clipboard", title: L10n.tr("Check in")) {
                showReadinessCheckIn = true
            }
        case .logBodyWeight:
            STRQPrimaryCTA(icon: "scalemass.fill", title: primary.ctaTitle) {
                showWeightLog = true
            }
        case .startFirstSession:
            if let day = vm.todaysWorkout ?? vm.nextWorkout {
                STRQPrimaryCTA(icon: "sparkles", title: L10n.tr("Start Workout 1")) {
                    vm.prepareWorkoutHandoff(day: day)
                }
            }
        case .resumeWorkout:
            if let day = vm.todaysWorkout {
                STRQPrimaryCTA(icon: "play.fill", title: L10n.tr("Resume Workout")) {
                    vm.prepareWorkoutHandoff(day: day)
                }
            }
        default:
            EmptyView()
        }
    }

    private var todayPriorityPill: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.forward.circle.fill")
                .font(.system(size: 9, weight: .bold))
            Text(L10n.tr("START HERE"))
                .font(.system(size: 9, weight: .black))
                .tracking(0.8)
        }
        .foregroundStyle(.black)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(STRQPalette.energyAccent, in: Capsule())
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.28), lineWidth: 0.7))
    }

    private struct PostWorkoutBridge {
        let sessionName: String
        let timeLabel: String
        let stats: String
        let outcomes: [String]
        let nextStep: String
        let accent: Color
        let icon: String
    }

    private var postWorkoutBridge: PostWorkoutBridge? {
        guard let session = vm.workoutHistory.first(where: \.isCompleted) else { return nil }
        let referenceDate = session.endTime ?? session.startTime
        let minutesAgo = max(0, Int(Date().timeIntervalSince(referenceDate) / 60))
        guard minutesAgo <= 180 else { return nil }

        let result = WorkoutHighlightBuilder.buildResult(
            session: session,
            history: vm.workoutHistory,
            streak: vm.streak,
            exerciseName: { id in vm.library.exercise(byId: id)?.name ?? L10n.tr("Exercise") }
        )
        let completedExercises = session.distinctCompletedExerciseCount
        let completedSets = session.completedSetCount

        return PostWorkoutBridge(
            sessionName: session.dayName,
            timeLabel: postWorkoutTimeLabel(minutesAgo),
            stats: postWorkoutStatsText(exercises: completedExercises, sets: completedSets),
            outcomes: postWorkoutOutcomes(session: session, result: result, completedSets: completedSets),
            nextStep: postWorkoutNextStep(),
            accent: postWorkoutAccent(for: result.verdict.kind),
            icon: postWorkoutIcon(for: result.verdict.kind)
        )
    }

    private func postWorkoutStatsText(exercises: Int, sets: Int) -> String {
        let exerciseText = L10n.countLabel(
            exercises,
            singularKey: "count.exercise.one",
            pluralKey: "count.exercise.other",
            singularFallback: "exercise",
            pluralFallback: "exercises"
        )
        let setText = L10n.countLabel(
            sets,
            singularKey: "count.set.one",
            pluralKey: "count.set.other",
            singularFallback: "set",
            pluralFallback: "sets"
        )
        return "\(exerciseText) · \(setText)"
    }

    private func postWorkoutBridgeCard(_ bridge: PostWorkoutBridge) -> some View {
        ForgeSurface(variant: .elevated, accent: bridge.accent, padding: 15) {
            VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 12) {
                STRQPulseMark(size: 38, tint: bridge.accent) {
                    Image(systemName: bridge.icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(bridge.accent)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(L10n.tr("Workout saved"))
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.1)
                            .foregroundStyle(bridge.accent)
                        Text(bridge.timeLabel)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.38))
                    }
                    Text(bridge.sessionName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    Text(bridge.stats)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.58))
                }

                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 7) {
                ForEach(Array(bridge.outcomes.prefix(2)), id: \.self) { outcome in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(bridge.accent)
                        Text(outcome)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.88))
                            .lineLimit(1)
                    }
                }
            }

            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)

            HStack(alignment: .top, spacing: 10) {
                Text(L10n.tr("NEXT ACTION"))
                    .font(.system(size: 9, weight: .black))
                    .tracking(0.9)
                    .foregroundStyle(.white.opacity(0.42))
                    .frame(width: 78, alignment: .leading)
                Text(bridge.nextStep)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.88))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 0)
            }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.06), value: appeared)
    }

    private func postWorkoutOutcomes(
        session: WorkoutSession,
        result: WorkoutHighlightBuilder.Result,
        completedSets: Int
    ) -> [String] {
        var outcomes: [String] = []

        if let line = result.highlights.first?.improvedLine {
            outcomes.append(line)
        }

        if completedSets > 0 {
            let setLabel = L10n.countLabel(
                completedSets,
                singularKey: "count.set.one",
                pluralKey: "count.set.other",
                singularFallback: "set",
                pluralFallback: "sets"
            )
            outcomes.append(L10n.format("%@ completed", setLabel))
        }

        if session.totalVolume > 0 && outcomes.count < 2 {
            outcomes.append(L10n.format("Volume updated: %@", ForgeTheme.formatVolume(session.totalVolume)))
        }

        if outcomes.isEmpty {
            outcomes.append(L10n.tr("First signal collected"))
        }

        return Array(outcomes.prefix(2))
    }

    private func postWorkoutTimeLabel(_ minutesAgo: Int) -> String {
        if minutesAgo < 2 { return L10n.tr("JUST NOW") }
        if minutesAgo < 60 { return L10n.format("%dM AGO", minutesAgo) }
        return L10n.format("%dH AGO", max(1, minutesAgo / 60))
    }

    private func postWorkoutTakeaway(for kind: SessionVerdict.Kind) -> String {
        switch kind {
        case .firstSession:
            return L10n.tr("Baseline loads are now tied to what you actually lifted.")
        case .personalRecord:
            return L10n.tr("That PR gives STRQ room to push the next exposure.")
        case .bestSet:
            return L10n.tr("Your top set moved up, so progression can keep climbing.")
        case .volumeUp:
            return L10n.tr("You handled more work than last time. Capacity is moving up.")
        case .volumeDown:
            return L10n.tr("Today read lighter, which still sharpens STRQ's load pacing.")
        case .consolidated:
            return L10n.tr("Execution held steady, so the next call can stay confident.")
        }
    }

    private func postWorkoutNextStep() -> String {
        if vm.dataMaturityTier == .firstSession {
            return L10n.tr("Come back for Workout 2")
        }
        if let title = vm.dailyBriefing?.primary.title {
            return title
        }
        if let day = nextScheduledDay {
            return L10n.format("Prep for %@.", day.name)
        }
        return L10n.tr("Let recovery carry this forward.")
    }

    private func postWorkoutAccent(for kind: SessionVerdict.Kind) -> Color {
        switch kind {
        case .personalRecord:
            return STRQPalette.gold
        case .bestSet, .volumeUp:
            return STRQPalette.success
        case .volumeDown:
            return STRQPalette.warning
        case .firstSession:
            return STRQPalette.energyAccent
        case .consolidated:
            return STRQBrand.steel
        }
    }

    private func postWorkoutIcon(for kind: SessionVerdict.Kind) -> String {
        switch kind {
        case .personalRecord:
            return "trophy.fill"
        case .bestSet:
            return "bolt.fill"
        case .volumeUp:
            return "arrow.up.right.circle.fill"
        case .volumeDown:
            return "equal.circle.fill"
        case .firstSession:
            return "sparkles"
        case .consolidated:
            return "checkmark.seal.fill"
        }
    }

    // MARK: - Since Last Session

    private func sinceLastCard(_ since: DailyBriefing.SinceLast) -> some View {
        let isSupporting = isPostFirstSessionState

        return ForgeSurface(
            variant: isSupporting ? .standard : .elevated,
            accent: STRQPalette.signalGreen,
            padding: 12
        ) {
            HStack(spacing: 12) {
            Image(systemName: "arrow.up.right.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(STRQPalette.signalGreen)
                .frame(width: 32, height: 32)
                .background(STRQPalette.successSoft, in: .rect(cornerRadius: 9))

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(since.eyebrow)
                        .font(.system(size: 9, weight: .black))
                        .tracking(1.1)
                        .foregroundStyle(STRQPalette.success)
                    Text(timeLabel(since.hoursAgo))
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.tertiary)
                }
                Text(since.summary)
                    .font((isSupporting ? Font.caption.weight(.semibold) : Font.subheadline.weight(.semibold)))
                    .foregroundStyle(STRQPalette.textPrimary)
                    .lineLimit(2)
                Text(since.sessionName)
                    .font(.caption2)
                    .foregroundStyle(STRQPalette.textMuted)
            }
            Spacer(minLength: 0)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.06), value: appeared)
    }

    private func timeLabel(_ hours: Int) -> String {
        if hours < 1 { return L10n.tr("JUST NOW") }
        if hours < 24 { return L10n.format("%dH AGO", hours) }
        return L10n.tr("YESTERDAY")
    }

    private var isPostFirstSessionState: Bool {
        vm.dataMaturityTier == .firstSession
    }

    // MARK: - Early Stage

    private func earlyStageHint(_ guidance: EarlyStateGuidance) -> some View {
        let tierIndex = max(0, min(3, guidance.tier.rawValue))
        return ForgeSurface(variant: .standard, accent: STRQPalette.energyAccent, padding: 12) {
            VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: guidance.icon)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(STRQPalette.energyAccent)
                    .frame(width: 32, height: 32)
                    .background(STRQPalette.energyAccentSoft, in: .rect(cornerRadius: 9))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(L10n.tr("CALIBRATING"))
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.1)
                            .foregroundStyle(STRQBrand.steel)
                        Spacer()
                        Text("\(tierIndex + 1)/4")
                            .font(.system(size: 9, weight: .bold).monospacedDigit())
                            .foregroundStyle(STRQPalette.textMuted)
                    }
                    Text(guidance.headline)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(STRQPalette.textPrimary)
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { i in
                    Capsule()
                        .fill(i <= tierIndex ? AnyShapeStyle(STRQPalette.energyAccent.gradient) : AnyShapeStyle(Color.white.opacity(0.08)))
                        .frame(height: 3)
                }
            }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.07), value: appeared)
    }

    // MARK: - Workout Card (training-day primary)

    private func workoutCard(_ day: WorkoutDay, briefing: DailyBriefing) -> some View {
        let primary = briefing.primary
        let tint = ForgeTheme.color(for: primary.colorName)
        let isRecovery = primary.kind == .recoverToday
        let isFirstSession = primary.kind == .startFirstSession
        return ForgeSurface(variant: .hero, accent: tint, padding: 0) {
            VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 6) {
                    Image(systemName: vm.currentPhase.icon)
                        .font(.system(size: 9, weight: .bold))
                    Text(primary.eyebrow)
                        .font(.system(size: 9, weight: .black))
                        .tracking(1.2)
                    Spacer()
                    if vm.isEarlyStage {
                        todayPriorityPill
                    } else if isRecovery {
                        STRQBadgeChip(label: L10n.tr("Recovery first"), icon: "heart.circle.fill", variant: .success)
                    } else if isFirstSession {
                        STRQBadgeChip(label: L10n.tr("Milestone"), icon: "sparkles", variant: .accent)
                    } else if let momentum = briefing.momentum {
                        STRQBadgeChip(label: momentum.title, icon: momentum.icon, variant: .neutral)
                    } else {
                        Text(L10n.tr("TODAY"))
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.2)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .foregroundStyle(tint)

                Text(day.name)
                    .font(.system(size: isRecovery ? 25 : 29, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                Text(primary.detail)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)

                if let adj = vm.adjustment(for: day.id) {
                    coachAdjustmentChip(adj)
                }

                HStack(spacing: 6) {
                    ForEach(day.focusMuscles.prefix(3)) { muscle in
                        STRQBadgeChip(label: muscle.displayName, variant: .neutral)
                    }
                }

                Divider().opacity(0.22)

                HStack(spacing: 8) {
                    STRQMetricTile(
                        value: "\(day.exercises.count)",
                        label: L10n.tr("Exercises"),
                        icon: "figure.strengthtraining.traditional",
                        tint: tint,
                        compact: true
                    )
                    STRQMetricTile(
                        value: "~\(day.estimatedMinutes)m",
                        label: L10n.tr("Duration"),
                        icon: "clock.fill",
                        tint: STRQPalette.steel,
                        compact: true
                    )
                    STRQMetricTile(
                        value: "\(day.exercises.reduce(0) { $0 + $1.sets })",
                        label: L10n.tr("Total Sets"),
                        icon: "square.stack.3d.up.fill",
                        tint: STRQPalette.textSecondary,
                        compact: true
                    )
                }
            }
            .padding(20)

            if primary.kind == .checkInBeforeTraining {
                HStack(spacing: 10) {
                    STRQPrimaryCTA(icon: "heart.text.clipboard", title: L10n.tr("Check in")) {
                        showReadinessCheckIn = true
                    }

                    Button {
                        vm.prepareWorkoutHandoff(day: day)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                            Text(L10n.tr("Start Workout"))
                        }
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(STRQPalette.textPrimary.opacity(0.86))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.white.opacity(0.08), in: .rect(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.strqPressable)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            } else {
                STRQPrimaryCTA(
                    icon: primary.kind == .resumeWorkout ? "play.fill" : "bolt.fill",
                    title: workoutPrimaryTitle(for: primary.kind)
                ) {
                    vm.prepareWorkoutHandoff(day: day)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.05), value: appeared)
    }

    private func workoutPrimaryTitle(for kind: DailyBriefing.PrimaryKind) -> String {
        switch kind {
        case .resumeWorkout:
            return L10n.tr("Resume Workout")
        case .startFirstSession:
            return L10n.tr("Start Workout 1")
        case .recoverToday:
            return L10n.tr("Start Light Workout")
        default:
            return L10n.tr("Start Workout")
        }
    }

    private func coachAdjustmentChip(_ adj: CoachAdjustment) -> some View {
        STRQBadgeChip(label: adj.description, icon: "brain.head.profile.fill", variant: .muted)
    }

    // MARK: - Schedule Timeline

    @ViewBuilder
    private var scheduleTimeline: some View {
        if let plan = vm.currentPlan, plan.days.contains(where: { $0.scheduledWeekday != nil }) {
            ForgeSurface(variant: .standard, padding: 14) {
                VStack(alignment: .leading, spacing: 10) {
                HStack {
                    STRQSectionTitle(title: L10n.tr("Training Week"))
                    Spacer()
                    if let next = nextScheduledDay {
                        STRQBadgeChip(
                            label: L10n.format("Next: %@", vm.weekdayName(next.scheduledWeekday ?? 0)),
                            variant: .accent
                        )
                    }
                }

                HStack(spacing: 0) {
                    ForEach(1...7, id: \.self) { weekday in
                        let matchingDay = plan.days.first { $0.scheduledWeekday == weekday && !$0.isSkipped }
                        let isToday = Calendar.current.component(.weekday, from: Date()) == weekday
                        let isPast = Calendar.current.component(.weekday, from: Date()) > weekday

                        VStack(spacing: 5) {
                            Text(vm.weekdayName(weekday))
                                .font(.system(size: 9, weight: isToday ? .bold : .medium))
                                .foregroundStyle(isToday ? STRQPalette.textPrimary : STRQPalette.textMuted)

                            ZStack {
                                if matchingDay != nil {
                                    Circle()
                                        .fill(isToday ? STRQPalette.energyAccent : isPast ? STRQPalette.signalGreen.opacity(0.26) : STRQPalette.textSecondary.opacity(0.36))
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "figure.strengthtraining.traditional")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(isToday ? STRQPalette.backgroundDeep : STRQPalette.textPrimary)
                                } else {
                                    Circle()
                                        .fill(Color.white.opacity(isToday ? 0.1 : 0.04))
                                        .frame(width: 28, height: 28)
                                    if isToday {
                                        Circle()
                                            .strokeBorder(STRQPalette.energyAccent.opacity(0.5), lineWidth: 1.5)
                                            .frame(width: 28, height: 28)
                                    }
                                }
                            }

                            if let day = matchingDay {
                                Text(shortName(day.name))
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundStyle(isToday ? STRQPalette.energyAccent : STRQPalette.textMuted)
                                    .lineLimit(1)
                            } else {
                                Text(isToday ? L10n.tr("Rest") : "")
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundStyle(STRQPalette.textMuted)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 4)
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.07), value: appeared)
        }
    }

    private var nextScheduledDay: WorkoutDay? {
        guard let plan = vm.currentPlan else { return nil }
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        let future = plan.days.filter { !$0.isSkipped && ($0.scheduledWeekday ?? 0) > todayWeekday }
            .sorted { ($0.scheduledWeekday ?? 0) < ($1.scheduledWeekday ?? 0) }
        if let next = future.first { return next }
        return plan.days.filter { !$0.isSkipped && $0.scheduledWeekday != nil }
            .sorted { ($0.scheduledWeekday ?? 0) < ($1.scheduledWeekday ?? 0) }
            .first
    }

    private func shortName(_ name: String) -> String {
        let words = name.split(separator: " ")
        if words.count > 1 { return String(words[0]) }
        return String(name.prefix(6))
    }

    // MARK: - Daily Signals Row (compact)

    private var dailySignalsRow: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                if vm.profile.nutritionTrackingEnabled {
                    signalButton(
                        icon: "fork.knife",
                        label: L10n.tr("Protein"),
                        value: "\(Int(vm.todayProteinProgress * 100))%",
                        progress: vm.todayProteinProgress,
                        color: STRQPalette.signalGreen
                    ) {
                        showNutritionLog = true
                    }
                }

                signalButton(
                    icon: "moon.zzz.fill",
                    label: L10n.tr("Sleep"),
                    value: String(format: "%.1fh", vm.averageSleepHours),
                    progress: min(1.0, vm.averageSleepHours / 8.0),
                    color: ForgeTheme.sleepColor(for: vm.averageSleepHours)
                ) {
                    showSleepLog = true
                }

                if vm.profile.nutritionTrackingEnabled {
                    signalButton(
                        icon: "scalemass.fill",
                        label: L10n.tr("Weight"),
                        value: vm.latestWeight.map { String(format: "%.1f", $0) } ?? "—",
                        progress: vm.latestWeight != nil ? 1.0 : 0.0,
                        color: STRQPalette.steel
                    ) {
                        showWeightLog = true
                    }
                }
            }

            if vm.isWeeklyReviewReady {
                Button {
                    vm.generateWeeklyReview()
                    showWeeklyReview = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.subheadline)
                            .foregroundStyle(STRQPalette.energyAccent)
                            .frame(width: 28, height: 28)
                            .background(STRQPalette.energyAccentSoft, in: .rect(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(L10n.tr("Weekly review ready"))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(STRQPalette.textPrimary)
                            Text(L10n.tr("Review this week and adjust"))
                                .font(.caption2)
                                .foregroundStyle(STRQPalette.textMuted)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(STRQPalette.textMuted)
                    }
                    .padding(12)
                    .background(STRQPalette.surfaceCarbon, in: .rect(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(STRQPalette.borderSubtle, lineWidth: 1)
                    )
                }
                .buttonStyle(.strqPressable)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    private func signalButton(icon: String, label: String, value: String, progress: Double, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            STRQMetricTile(
                value: value,
                label: label,
                icon: icon,
                tint: color,
                progress: progress,
                compact: true
            )
        }
        .buttonStyle(.strqPressable)
    }

    // MARK: - Week Pulse

    private var weekPulse: some View {
        ForgeSurface(variant: .standard, padding: 16) {
            VStack(spacing: 14) {
            Button {
                withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .snappy(duration: 0.22)) {
                    showWeekPulseDetails.toggle()
                }
            } label: {
                HStack {
                    STRQSectionTitle(title: L10n.tr("This Week"))
                    Spacer()
                    if let momentum = vm.momentumData {
                        let paceName = momentum.weeklyPace.colorName
                        STRQBadgeChip(
                            label: momentum.paceMessage,
                            variant: ["green", "mint"].contains(paceName) ? .success : (["yellow", "orange"].contains(paceName) ? .warning : .neutral)
                        )
                    }
                    Image(systemName: showWeekPulseDetails ? "chevron.up" : "chevron.down")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(STRQPalette.textMuted)
                }
            }
            .buttonStyle(.plain)

            HStack(spacing: 0) {
                ForEach(vm.weeklyActivity) { day in
                    VStack(spacing: 6) {
                        Text(day.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(STRQPalette.textMuted)
                        Circle()
                            .fill(day.didTrain ? STRQPalette.signalGreen : Color.white.opacity(0.06))
                            .frame(width: 28, height: 28)
                            .overlay {
                                if day.didTrain {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(STRQPalette.backgroundDeep)
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            if showWeekPulseDetails {
                HStack(spacing: 8) {
                    STRQMetricTile(
                        value: "\(vm.weeklyStats.sessions)/\(vm.profile.daysPerWeek)",
                        label: L10n.tr("Workouts"),
                        icon: "checkmark.seal.fill",
                        tint: STRQPalette.signalGreen,
                        compact: true
                    )
                    STRQMetricTile(
                        value: ForgeTheme.formatVolume(vm.weeklyStats.volume),
                        label: L10n.tr("Volume"),
                        icon: "chart.bar.fill",
                        tint: STRQPalette.steel,
                        compact: true
                    )
                    STRQMetricTile(
                        value: "\(vm.effectiveRecoveryScore)%",
                        label: L10n.tr("Recovery"),
                        icon: "waveform.path.ecg",
                        tint: ForgeTheme.recoveryColor(for: vm.effectiveRecoveryScore),
                        compact: true
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.12), value: appeared)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return L10n.tr("Good morning")
        case 12..<17: return L10n.tr("Good afternoon")
        case 17..<22: return L10n.tr("Good evening")
        default: return L10n.tr("Late night")
        }
    }
}
