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

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                dashboardTopDeck

                dashboardMetricsStrip

                primaryActionCard
                    .padding(.horizontal, 16)

                if let bridge = postWorkoutBridge {
                    postWorkoutBridgeCard(bridge)
                        .padding(.horizontal, 16)
                }

                if let since = vm.dailyBriefing?.sinceLast, postWorkoutBridge == nil {
                    sinceLastCard(since)
                        .padding(.horizontal, 16)
                }

                analysisModule
                    .padding(.horizontal, 16)

                scheduleTimeline
                    .padding(.horizontal, 16)

                if let achievement = dashboardAchievement {
                    STRQAchievementPreviewCard(
                        eyebrow: achievement.eyebrow,
                        title: achievement.title,
                        detail: achievement.detail,
                        value: achievement.value,
                        icon: achievement.icon,
                        tint: achievement.tint,
                        progress: achievement.progress
                    )
                        .padding(.horizontal, 16)
                        .onAppear {
                            if let roadmap = vm.activationRoadmap {
                                Analytics.shared.track(.activation_roadmap_viewed, [
                                    "completed": String(roadmap.completedCount),
                                    "surface": "today"
                                ])
                            }
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .background(STRQPalette.sandowBackground.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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

    // MARK: - Dashboard Header / Signal

    private struct DashboardAnalysisRow: Identifiable {
        let id: String
        let label: String
        let value: String
        let detail: String
        let icon: String
        let progress: Double
        let tint: Color
    }

    private struct DashboardAchievement {
        let eyebrow: String
        let title: String
        let detail: String
        let value: String
        let icon: String
        let tint: Color
        let progress: Double
    }

    private var dashboardTopDeck: some View {
        VStack(spacing: 0) {
            dashboardHeader
                .padding(.horizontal, 16)
                .padding(.top, 16)

            dashboardHero
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 16)
        }
        .background {
            ZStack(alignment: .bottom) {
                STRQPalette.sandowBackground
                STRQPalette.sandowOrange
                    .opacity(0.18)
                    .frame(height: 84)
                    .blur(radius: 26)
                    .allowsHitTesting(false)
            }
        }
        .clipShape(
            UnevenRoundedRectangle(
                cornerRadii: .init(topLeading: 0, bottomLeading: 32, bottomTrailing: 32, topTrailing: 0),
                style: .continuous
            )
        )
        .overlay(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .strokeBorder(STRQPalette.sandowOrange.opacity(0.18), lineWidth: 1)
                .frame(height: 118)
                .allowsHitTesting(false)
        }
    }

    private var dashboardMetricsStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            STRQSectionHeader(L10n.tr("dashboard.metrics.title", fallback: "Health Metrics")) {
                Text(L10n.tr("dashboard.metrics.trailing", fallback: "Today"))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(STRQPalette.sandowOrange)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                STRQMetricTile(
                    value: "\(vm.effectiveRecoveryScore)%",
                    label: L10n.tr("dashboard.metric.recovery", fallback: "Recovery"),
                    icon: "waveform.path.ecg",
                    tint: dashboardRecoveryTint(for: vm.effectiveRecoveryScore),
                    progress: Double(vm.effectiveRecoveryScore) / 100
                )
                .frame(width: 160, height: 140)

                STRQMetricTile(
                    value: "\(vm.weeklyStats.sessions)/\(max(1, vm.profile.daysPerWeek))",
                    label: L10n.tr("dashboard.metric.week", fallback: "Week"),
                    icon: "calendar.badge.checkmark",
                    tint: trainingLoadTint,
                    progress: min(1, Double(vm.weeklyStats.sessions) / Double(max(1, vm.profile.daysPerWeek)))
                )
                .frame(width: 160, height: 140)

                Button {
                    showSleepLog = true
                } label: {
                    STRQMetricTile(
                        value: dashboardSleepMetricValue,
                        label: L10n.tr("dashboard.metric.sleep", fallback: "Sleep"),
                        icon: "moon.zzz.fill",
                        tint: dashboardSleepTint(for: vm.averageSleepHours),
                        progress: min(1.0, max(0, vm.averageSleepHours / 8.0))
                    )
                }
                .buttonStyle(.strqPressable)
                .frame(width: 160, height: 140)

                STRQMetricTile(
                    value: vm.streak > 0 ? "\(vm.streak)" : "\(vm.totalCompletedWorkouts)",
                    label: vm.streak > 0
                        ? L10n.tr("dashboard.metric.streak", fallback: "Streak")
                        : L10n.tr("dashboard.metric.completed", fallback: "Done"),
                    icon: vm.streak > 0 ? "flame.fill" : "checkmark.seal.fill",
                    tint: vm.streak > 0 ? STRQPalette.sandowOrange : STRQPalette.signalGreen,
                    progress: min(1, Double(max(vm.streak, vm.totalCompletedWorkouts)) / 7.0)
                )
                .frame(width: 160, height: 140)
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 12)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.03), value: appeared)
    }

    private var dashboardHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 6) {
                    Text(dashboardDateLabel)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(STRQPalette.textSecondary)
                        .lineLimit(1)

                    STRQBadgeChip(
                        label: vm.streak > 0 ? "\(vm.streak)" : "\(vm.weeklyStats.sessions)",
                        icon: vm.streak > 0 ? "flame.fill" : "bolt.fill",
                        variant: .orange
                    )
                }

                Text(headerGreeting)
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(STRQPalette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Spacer(minLength: 8)

            HStack(spacing: 8) {
                Button {
                    showReadinessCheckIn = true
                } label: {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(STRQPalette.textPrimary)
                        .frame(width: 40, height: 40)
                        .background(STRQPalette.sandowSurfaceElevated, in: Circle())
                        .overlay(Circle().strokeBorder(STRQPalette.sandowBorderStrong, lineWidth: 1))
                }
                .buttonStyle(.strqPressable)

                Image("STRQSigil")
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .frame(width: 40, height: 40)
                    .background(STRQPalette.sandowOrange, in: Circle())
                    .overlay(alignment: .bottomTrailing) {
                        Circle()
                            .fill(STRQPalette.signalGreen)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().strokeBorder(STRQPalette.sandowBackground, lineWidth: 1.5))
                    }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 6)
    }

    private var dashboardHero: some View {
        STRQDashboardHeroCard(
            title: L10n.tr("dashboard.hero.title", fallback: "Today's Signal"),
            status: dashboardSignalStatus,
            score: dashboardSignalScore,
            scoreLabel: L10n.tr("dashboard.hero.scoreLabel", fallback: "STRQ Score"),
            insight: dashboardSignalInsight,
            accent: dashboardSignalAccent,
            metrics: dashboardHeroMetrics
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.55), value: appeared)
    }

    private var dashboardSignalScore: Int {
        let recovery = Double(vm.effectiveRecoveryScore)
        let weekRatio = Double(vm.weeklyStats.sessions) / Double(max(1, vm.profile.daysPerWeek))
        let weekScore = min(100, max(0, weekRatio * 100))
        let sleepScore = vm.averageSleepHours <= 0 ? 62 : min(100, max(35, (vm.averageSleepHours / 8.0) * 100))
        let consistencyScore = min(100, Double(max(vm.streak, vm.weeklyStats.sessions)) * 18)
        let score = recovery * 0.60 + weekScore * 0.18 + sleepScore * 0.12 + consistencyScore * 0.10
        return max(10, min(98, Int(score.rounded())))
    }

    private var dashboardSignalStatus: String {
        switch dashboardSignalScore {
        case 86...:
            return L10n.tr("dashboard.hero.status.peak", fallback: "Peak readiness")
        case 72..<86:
            return L10n.tr("dashboard.hero.status.ready", fallback: "Ready to train")
        case 55..<72:
            return L10n.tr("dashboard.hero.status.controlled", fallback: "Controlled push")
        default:
            return L10n.tr("dashboard.hero.status.protect", fallback: "Protect recovery")
        }
    }

    private var dashboardSignalInsight: String {
        if vm.activeWorkout != nil {
            return L10n.tr(
                "dashboard.hero.insight.active",
                fallback: "Workout in progress. Finish clean and keep the signal useful."
            )
        }
        if vm.todaysWorkout != nil {
            return vm.effectiveRecoveryScore >= 60
                ? L10n.tr(
                    "dashboard.hero.insight.todayReady",
                    fallback: "Recovery, load, and week pace support today's workout."
                )
                : L10n.tr(
                    "dashboard.hero.insight.todayLow",
                    fallback: "Keep load conservative and let recovery lead today."
                )
        }
        if vm.totalCompletedWorkouts == 0 {
            return L10n.tr(
                "dashboard.hero.insight.first",
                fallback: "Start workout one to set your real baseline."
            )
        }
        return L10n.tr(
            "dashboard.hero.insight.rest",
            fallback: "No workout due. Bank recovery for the next session."
        )
    }

    private var dashboardSignalAccent: Color {
        switch dashboardSignalScore {
        case 80...:
            return STRQPalette.signalGreen
        case 60..<80:
            return STRQPalette.sandowOrange
        case 45..<60:
            return STRQPalette.sandowOrange
        default:
            return STRQPalette.dangerRed
        }
    }

    private var dashboardHeroMetrics: [STRQDashboardHeroCard.Metric] {
        [
            .init(
                label: L10n.tr("dashboard.metric.recovery", fallback: "Recovery"),
                value: "\(vm.effectiveRecoveryScore)%",
                icon: "waveform.path.ecg",
                tint: dashboardRecoveryTint(for: vm.effectiveRecoveryScore)
            ),
            .init(
                label: L10n.tr("dashboard.metric.load", fallback: "Load"),
                value: "\(vm.weeklyStats.sessions)/\(max(1, vm.profile.daysPerWeek))",
                icon: "chart.bar.fill",
                tint: trainingLoadTint
            ),
            .init(
                label: L10n.tr("dashboard.metric.focus", fallback: "Focus"),
                value: dashboardFocusLabel,
                icon: vm.todaysWorkout == nil ? vm.currentPhase.icon : "scope",
                tint: STRQPalette.sandowOrange
            )
        ]
    }

    private var dashboardFocusLabel: String {
        if let focus = vm.todaysWorkout?.focusMuscles.first?.displayName {
            return focus
        }
        return vm.currentPhase.shortLabel
    }

    private var dashboardSleepMetricValue: String {
        guard vm.averageSleepHours > 0 else {
            return L10n.tr("dashboard.metric.sleep.log", fallback: "Log")
        }
        return String(format: "%.1fh", vm.averageSleepHours)
    }

    private var dashboardDateLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.setLocalizedDateFormatFromTemplate("EEE, d MMM")
        return formatter.string(from: Date())
    }

    private var headerGreeting: String {
        let name = vm.profile.name.isEmpty ? L10n.tr("Athlete") : vm.profile.name
        return L10n.format("dashboard.header.hello", fallback: "Hello, %@!", name)
    }

    private var trainingLoadTint: Color {
        let ratio = Double(vm.weeklyStats.sessions) / Double(max(1, vm.profile.daysPerWeek))
        if ratio > 1.15 { return STRQPalette.dangerRed }
        if ratio >= 0.75 { return STRQPalette.signalGreen }
        return STRQPalette.sandowOrange
    }

    private func dashboardAccent(for colorName: String) -> Color {
        switch colorName {
        case "green", "mint":
            return STRQPalette.signalGreen
        case "red":
            return STRQPalette.dangerRed
        default:
            return STRQPalette.sandowOrange
        }
    }

    private func dashboardRecoveryTint(for score: Int) -> Color {
        if score >= 80 { return STRQPalette.signalGreen }
        if score < 45 { return STRQPalette.dangerRed }
        return STRQPalette.sandowOrange
    }

    private func dashboardSleepTint(for hours: Double) -> Color {
        if hours >= 7.5 { return STRQPalette.signalGreen }
        if hours < 6.5 { return STRQPalette.dangerRed }
        return STRQPalette.sandowOrange
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
        let tint = dashboardAccent(for: primary.colorName)
        return STRQSurface(variant: .elevated, accent: tint, padding: 16) {
            VStack(alignment: .leading, spacing: 15) {
                STRQSectionHeader(L10n.tr("dashboard.action.title", fallback: "Next Move")) {
                    if vm.isEarlyStage {
                        todayPriorityPill
                    } else if let momentum = briefing.momentum {
                        STRQBadgeChip(label: momentum.title, icon: momentum.icon, variant: .neutral)
                    }
                }

                HStack(alignment: .top, spacing: 14) {
                    STRQPulseMark(size: 48, tint: tint) {
                        Image(systemName: primary.icon)
                            .font(.system(size: 18, weight: .black))
                            .foregroundStyle(tint)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text(primary.title)
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundStyle(STRQPalette.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.76)
                        Text(primary.detail)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(STRQPalette.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }

                HStack(spacing: 7) {
                    STRQBadgeChip(label: primary.eyebrow, icon: primary.icon, variant: actionChipVariant(for: primary.colorName))
                    if let rest = briefing.restPrep {
                        STRQBadgeChip(label: rest.title, icon: rest.icon, variant: .orange)
                    } else if let next = nextScheduledDay {
                        STRQBadgeChip(
                            label: L10n.format(
                                "dashboard.action.nextWorkout",
                                fallback: "Next: %@",
                                shortName(next.name)
                            ),
                            icon: "calendar",
                            variant: .neutral
                        )
                    }
                }

                if let rest = briefing.restPrep {
                    HStack(spacing: 10) {
                        Image(systemName: rest.icon)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(STRQPalette.sandowOrange)
                            .frame(width: 28, height: 28)
                            .background(STRQPalette.sandowOrangeSoft, in: .rect(cornerRadius: 9))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(rest.title)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(STRQPalette.textPrimary)
                            Text(rest.detail)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(STRQPalette.textMuted)
                                .lineLimit(2)
                        }
                        Spacer(minLength: 0)
                    }
                    .padding(12)
                    .background(STRQPalette.sandowInset.opacity(0.72), in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(STRQPalette.sandowOrange.opacity(0.16), lineWidth: 1)
                    )
                }

                dashboardCTA(primary, briefing: briefing)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.05), value: appeared)
    }

    private func actionChipVariant(for colorName: String) -> STRQBadgeChip.Variant {
        switch colorName {
        case "green", "mint":
            return .success
        case "red":
            return .danger
        default:
            return .orange
        }
    }

    @ViewBuilder
    private func dashboardCTA(_ primary: DailyBriefing.Primary, briefing: DailyBriefing) -> some View {
        switch primary.kind {
        case .prepNextSession, .recoveryDay:
            if let day = nextScheduledDay ?? vm.nextWorkout {
                let ctaTitle = primary.kind == .prepNextSession
                    ? primary.ctaTitle
                    : L10n.tr("dashboard.action.previewNext", fallback: "Preview next workout")
                STRQPrimaryCTA(
                    icon: "calendar.badge.clock",
                    title: ctaTitle
                ) {
                    vm.prepareWorkoutHandoff(day: day)
                }
            } else if briefing.restPrep?.icon == "moon.zzz.fill" {
                STRQPrimaryCTA(icon: "moon.zzz.fill", title: L10n.tr("dashboard.action.sleepCta", fallback: "Log sleep")) {
                    showSleepLog = true
                }
            }
        default:
            primaryCTA(primary)
        }
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
        .foregroundStyle(Color.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(STRQPalette.sandowOrange, in: Capsule())
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
        STRQSurface(variant: .elevated, accent: bridge.accent, padding: 15) {
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
            return STRQPalette.sandowOrange
        case .bestSet, .volumeUp:
            return STRQPalette.success
        case .volumeDown:
            return STRQPalette.warning
        case .firstSession:
            return STRQPalette.sandowOrange
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

        return STRQSurface(
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

    // MARK: - Workout Card (training-day primary)

    private func workoutCard(_ day: WorkoutDay, briefing: DailyBriefing) -> some View {
        let primary = briefing.primary
        let tint = dashboardAccent(for: primary.colorName)
        let isRecovery = primary.kind == .recoverToday
        let isFirstSession = primary.kind == .startFirstSession
        return VStack(alignment: .leading, spacing: 8) {
            STRQSectionHeader(L10n.tr("Workouts")) {
                Text(L10n.tr("dashboard.workout.trailing", fallback: "Today"))
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(STRQPalette.sandowOrange)
            }

            STRQSurface(variant: .elevated, accent: tint, padding: 0) {
                VStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        STRQPalette.sandowInset

                        Image("STRQSigil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 148, height: 148)
                            .opacity(0.08)
                            .offset(x: 174, y: -24)

                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                STRQBadgeChip(
                                    label: primary.eyebrow,
                                    icon: primary.icon,
                                    variant: actionChipVariant(for: primary.colorName)
                                )
                                Spacer(minLength: 0)
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(STRQPalette.textMuted)
                            }

                            Spacer(minLength: 0)

                            Text(day.name)
                                .font(.system(size: isRecovery ? 24 : 26, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                                .lineLimit(2)
                                .minimumScaleFactor(0.7)

                            HStack(spacing: 8) {
                                workoutMetadataItem(icon: "figure.strengthtraining.traditional", value: "\(day.exercises.count)")
                                dotDivider
                                workoutMetadataItem(icon: "clock.fill", value: "~\(day.estimatedMinutes)m")
                                dotDivider
                                workoutMetadataItem(
                                    icon: "square.stack.3d.up.fill",
                                    value: "\(day.exercises.reduce(0) { $0 + $1.sets })"
                                )
                            }
                        }
                        .padding(16)
                    }
                    .frame(height: 172)

                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top, spacing: 12) {
                            STRQPulseMark(size: 44, tint: tint) {
                                Image(systemName: isRecovery ? "heart.fill" : "bolt.fill")
                                    .font(.system(size: 16, weight: .black))
                                    .foregroundStyle(tint)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 7) {
                                    if vm.isEarlyStage {
                                        todayPriorityPill
                                    } else if isRecovery {
                                        STRQBadgeChip(label: L10n.tr("Recovery first"), icon: "heart.circle.fill", variant: .orange)
                                    } else if isFirstSession {
                                        STRQBadgeChip(label: L10n.tr("Milestone"), icon: "sparkles", variant: .orange)
                                    } else if let momentum = briefing.momentum {
                                        STRQBadgeChip(label: momentum.title, icon: momentum.icon, variant: .neutral)
                                    }
                                }

                                Text(primary.detail)
                                    .font(.footnote.weight(.medium))
                                    .foregroundStyle(.white.opacity(0.70))
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer(minLength: 0)
                        }

                        if let adj = vm.adjustment(for: day.id) {
                            coachAdjustmentChip(adj)
                        }

                        HStack(spacing: 6) {
                            ForEach(day.focusMuscles.prefix(3)) { muscle in
                                STRQBadgeChip(label: muscle.displayName, variant: .neutral)
                            }
                        }
                    }
                    .padding(16)

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
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.05), value: appeared)
    }

    private func workoutMetadataItem(icon: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
            Text(value)
                .font(.system(size: 13, weight: .semibold).monospacedDigit())
                .lineLimit(1)
        }
        .foregroundStyle(STRQPalette.textPrimary)
    }

    private var dotDivider: some View {
        Circle()
            .fill(STRQPalette.sandowDivider)
            .frame(width: 4, height: 4)
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
        STRQBadgeChip(label: adj.description, icon: "brain.head.profile.fill", variant: .orange)
    }

    // MARK: - Analysis

    private var analysisModule: some View {
        STRQSurface(variant: .standard, accent: STRQPalette.sandowOrange, padding: 14) {
            VStack(alignment: .leading, spacing: 14) {
                STRQSectionHeader(L10n.tr("Activity")) {
                    if vm.isWeeklyReviewReady {
                        Button {
                            vm.generateWeeklyReview()
                            showWeeklyReview = true
                        } label: {
                            STRQBadgeChip(
                                label: L10n.tr("Weekly review ready"),
                                icon: "doc.text.magnifyingglass",
                                variant: .orange
                            )
                        }
                        .buttonStyle(.strqPressable)
                    }
                }

                HStack(alignment: .center, spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(activityStatusTitle)
                            .font(.system(size: 24, weight: .heavy, design: .rounded))
                            .foregroundStyle(STRQPalette.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.76)

                        Text(activityStatusDetail)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(STRQPalette.textSecondary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    STRQMiniProgressRing(
                        progress: weekCompletionProgress,
                        tint: trainingLoadTint,
                        size: 64,
                        lineWidth: 6
                    ) {
                        VStack(spacing: 0) {
                            Text("\(Int((weekCompletionProgress * 100).rounded()))")
                                .font(.system(size: 16, weight: .black, design: .rounded).monospacedDigit())
                                .foregroundStyle(STRQPalette.textPrimary)
                            Text("%")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundStyle(STRQPalette.textMuted)
                        }
                    }
                }

                VStack(spacing: 8) {
                    ForEach(Array(dashboardAnalysisRows.prefix(3))) { row in
                        STRQSignalBar(
                            label: row.label,
                            value: row.value,
                            detail: row.detail,
                            icon: row.icon,
                            progress: appeared ? row.progress : 0,
                            tint: row.tint
                        )
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.08), value: appeared)
    }

    private var weekCompletionProgress: Double {
        min(1, Double(vm.weeklyStats.sessions) / Double(max(1, vm.profile.daysPerWeek)))
    }

    private var activityStatusTitle: String {
        if vm.weeklyStats.sessions >= max(1, vm.profile.daysPerWeek) {
            return L10n.tr("dashboard.activity.complete", fallback: "Target Hit")
        }
        if vm.weeklyStats.sessions > 0 {
            return L10n.tr("dashboard.activity.active", fallback: "On Track")
        }
        return L10n.tr("dashboard.activity.lowData", fallback: "Ready")
    }

    private var activityStatusDetail: String {
        let planned = max(1, vm.profile.daysPerWeek)
        if vm.weeklyStats.sessions == 0 {
            return L10n.tr("dashboard.activity.lowData.detail", fallback: "No workout logged this week yet.")
        }
        return L10n.format(
            "dashboard.activity.detail",
            fallback: "%d of %d planned workouts completed.",
            vm.weeklyStats.sessions,
            planned
        )
    }

    private var dashboardAnalysisRows: [DashboardAnalysisRow] {
        let planned = max(1, vm.profile.daysPerWeek)
        let weekProgress = weekCompletionProgress
        let consistencySource = max(vm.streak, vm.weeklyStats.sessions)
        let consistencyProgress = min(1, Double(consistencySource) / Double(max(3, planned)))
        let sleepProgress = min(1, max(0, vm.averageSleepHours / 8.0))

        var rows: [DashboardAnalysisRow] = [
            DashboardAnalysisRow(
                id: "recovery",
                label: L10n.tr("dashboard.metric.recovery", fallback: "Recovery"),
                value: "\(vm.effectiveRecoveryScore)%",
                detail: L10n.tr("dashboard.analysis.recovery.detail", fallback: "Readiness and recent load"),
                icon: "waveform.path.ecg",
                progress: Double(vm.effectiveRecoveryScore) / 100,
                tint: dashboardRecoveryTint(for: vm.effectiveRecoveryScore)
            ),
            DashboardAnalysisRow(
                id: "week",
                label: L10n.tr("dashboard.metric.week", fallback: "Week"),
                value: "\(vm.weeklyStats.sessions)/\(planned)",
                detail: L10n.tr("dashboard.analysis.week.detail", fallback: "Weekly target pace"),
                icon: "calendar.badge.checkmark",
                progress: weekProgress,
                tint: trainingLoadTint
            ),
            DashboardAnalysisRow(
                id: "consistency",
                label: L10n.tr("dashboard.metric.consistency", fallback: "Consistency"),
                value: consistencySource > 0 ? "\(consistencySource)" : "0",
                detail: L10n.tr("dashboard.analysis.consistency.detail", fallback: "Workouts or check-ins"),
                icon: "checkmark.seal.fill",
                progress: consistencyProgress,
                tint: STRQPalette.signalGreen
            )
        ]

        if vm.averageSleepHours > 0 {
            rows.append(
                DashboardAnalysisRow(
                    id: "sleep",
                    label: L10n.tr("dashboard.metric.sleep", fallback: "Sleep"),
                    value: String(format: "%.1fh", vm.averageSleepHours),
                    detail: L10n.tr("dashboard.analysis.sleep.detail", fallback: "Seven-day average"),
                    icon: "moon.zzz.fill",
                    progress: sleepProgress,
                    tint: dashboardSleepTint(for: vm.averageSleepHours)
                )
            )
        }

        return Array(rows.prefix(3))
    }

    private var dashboardAchievement: DashboardAchievement? {
        let eyebrow = L10n.tr("dashboard.reward.eyebrow", fallback: "Reward Preview")

        if vm.streak >= 3 {
            return DashboardAchievement(
                eyebrow: eyebrow,
                title: L10n.tr("dashboard.reward.streak.title", fallback: "Streak"),
                detail: L10n.tr("dashboard.reward.streak.detail", fallback: "Consistency signal is live."),
                value: L10n.format("dashboard.reward.streak.value", fallback: "%dd", vm.streak),
                icon: "flame.fill",
                tint: STRQPalette.sandowOrange,
                progress: min(1, Double(vm.streak) / 7.0)
            )
        }

        if vm.totalCompletedWorkouts >= 1 {
            return DashboardAchievement(
                eyebrow: eyebrow,
                title: L10n.tr("dashboard.reward.firstWorkout.title", fallback: "Baseline Set"),
                detail: L10n.tr("dashboard.reward.firstWorkout.detail", fallback: "First workout logged. STRQ can calibrate from real sets."),
                value: "\(vm.totalCompletedWorkouts)",
                icon: "checkmark.seal.fill",
                tint: STRQPalette.signalGreen,
                progress: min(1, Double(vm.totalCompletedWorkouts) / 3.0)
            )
        }

        if let roadmap = vm.activationRoadmap, roadmap.completedCount > 0 {
            return DashboardAchievement(
                eyebrow: eyebrow,
                title: L10n.tr("dashboard.reward.plan.title", fallback: "Plan Built"),
                detail: L10n.tr("dashboard.reward.plan.detail", fallback: "Your first STRQ signal is ready."),
                value: "\(roadmap.completedCount)/\(roadmap.steps.count)",
                icon: "doc.text.fill",
                tint: STRQPalette.sandowOrange,
                progress: roadmap.progress
            )
        }

        return nil
    }

    // MARK: - Schedule Timeline

    @ViewBuilder
    private var scheduleTimeline: some View {
        if let plan = vm.currentPlan, plan.days.contains(where: { $0.scheduledWeekday != nil }) {
            STRQSurface(variant: .standard, padding: 14) {
                VStack(alignment: .leading, spacing: 12) {
                    STRQSectionHeader(L10n.tr("Training Week")) {
                        STRQBadgeChip(
                            label: "\(vm.weeklyStats.sessions)/\(max(1, vm.profile.daysPerWeek))",
                            icon: "checkmark",
                            variant: vm.weeklyStats.sessions >= max(1, vm.profile.daysPerWeek) ? .success : .orange
                        )
                    }

                    HStack(spacing: 6) {
                        ForEach(1...7, id: \.self) { weekday in
                            let matchingDay = plan.days.first { $0.scheduledWeekday == weekday && !$0.isSkipped }
                            let isToday = Calendar.current.component(.weekday, from: Date()) == weekday
                            let isPast = Calendar.current.component(.weekday, from: Date()) > weekday

                            VStack(spacing: 7) {
                                Text(vm.weekdayName(weekday))
                                    .font(.system(size: 9, weight: isToday ? .black : .bold))
                                    .foregroundStyle(isToday ? STRQPalette.textPrimary : STRQPalette.textMuted)
                                    .lineLimit(1)

                                ZStack {
                                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                                        .fill(weekDayFill(hasWorkout: matchingDay != nil, isPast: isPast, isToday: isToday))
                                        .frame(height: 34)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 13, style: .continuous)
                                                .strokeBorder(
                                                    isToday ? STRQPalette.sandowOrange.opacity(0.55) : Color.white.opacity(0.07),
                                                    lineWidth: 1
                                                )
                                        )

                                    if matchingDay != nil {
                                        Image(systemName: isPast ? "checkmark" : "figure.strengthtraining.traditional")
                                            .font(.system(size: 10, weight: .black))
                                            .foregroundStyle(isToday ? Color.white : STRQPalette.textPrimary)
                                    } else if isToday {
                                        Text(L10n.tr("Rest"))
                                            .font(.system(size: 8, weight: .black))
                                            .foregroundStyle(STRQPalette.sandowOrange)
                                            .lineLimit(1)
                                    }
                                }

                                Text(matchingDay.map { shortName($0.name) } ?? " ")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(isToday ? STRQPalette.sandowOrange : STRQPalette.textMuted)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }

                    if let next = nextScheduledDay {
                        HStack(spacing: 8) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(STRQPalette.sandowOrange)
                            Text(L10n.format("dashboard.week.next", fallback: "Next up: %@", next.name))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(STRQPalette.textSecondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.78)
                            Spacer(minLength: 0)
                        }
                        .padding(.top, 1)
                    }

                    if !upcomingScheduleDays.isEmpty {
                        Rectangle()
                            .fill(STRQPalette.sandowDivider)
                            .frame(height: 1)

                        Text(L10n.tr("dashboard.schedule.upcoming", fallback: "Upcoming Schedule"))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(STRQPalette.textPrimary)

                        VStack(spacing: 0) {
                            ForEach(Array(upcomingScheduleDays.enumerated()), id: \.offset) { index, day in
                                scheduleListRow(day)
                                if index < upcomingScheduleDays.count - 1 {
                                    Rectangle()
                                        .fill(STRQPalette.sandowDivider)
                                        .frame(height: 1)
                                        .padding(.leading, 48)
                                }
                            }
                        }
                        .background(STRQPalette.sandowInset.opacity(0.66), in: .rect(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(STRQPalette.sandowBorder, lineWidth: 1)
                        )
                    }
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.07), value: appeared)
        }
    }

    private func weekDayFill(hasWorkout: Bool, isPast: Bool, isToday: Bool) -> Color {
        if hasWorkout && isToday { return STRQPalette.sandowOrange }
        if hasWorkout && isPast { return STRQPalette.signalGreen.opacity(0.22) }
        if hasWorkout { return STRQPalette.sandowCardRaised.opacity(0.92) }
        if isToday { return STRQPalette.sandowOrangeSoft }
        return Color.white.opacity(0.045)
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

    private var upcomingScheduleDays: [WorkoutDay] {
        guard let plan = vm.currentPlan else { return [] }
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        let scheduled = plan.days
            .filter { !$0.isSkipped && $0.scheduledWeekday != nil }
            .sorted { ($0.scheduledWeekday ?? 0) < ($1.scheduledWeekday ?? 0) }
        let future = scheduled.filter { ($0.scheduledWeekday ?? 0) >= todayWeekday }
        return Array((future.isEmpty ? scheduled : future).prefix(2))
    }

    private func scheduleListRow(_ day: WorkoutDay) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(STRQPalette.sandowOrange)
                .frame(width: 36, height: 36)
                .background(STRQPalette.sandowOrangeSoft, in: .rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(day.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(STRQPalette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Text(scheduleListDetail(day))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(STRQPalette.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(STRQPalette.textMuted)
        }
        .padding(12)
    }

    private func scheduleListDetail(_ day: WorkoutDay) -> String {
        let weekday = day.scheduledWeekday.map { vm.weekdayName($0) } ?? L10n.tr("Training")
        return L10n.format(
            "dashboard.schedule.item.detail",
            fallback: "%@ - %d exercises - ~%dm",
            weekday,
            day.exercises.count,
            day.estimatedMinutes
        )
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
                        color: STRQPalette.sandowOrange
                    ) {
                        showNutritionLog = true
                    }
                }

                signalButton(
                    icon: "moon.zzz.fill",
                    label: L10n.tr("Sleep"),
                    value: String(format: "%.1fh", vm.averageSleepHours),
                    progress: min(1.0, vm.averageSleepHours / 8.0),
                    color: dashboardSleepTint(for: vm.averageSleepHours)
                ) {
                    showSleepLog = true
                }

                if vm.profile.nutritionTrackingEnabled {
                    signalButton(
                        icon: "scalemass.fill",
                        label: L10n.tr("Weight"),
                        value: vm.latestWeight.map { String(format: "%.1f", $0) } ?? "—",
                        progress: vm.latestWeight != nil ? 1.0 : 0.0,
                        color: STRQPalette.sandowOrange
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
                            .foregroundStyle(STRQPalette.sandowOrange)
                            .frame(width: 28, height: 28)
                            .background(STRQPalette.sandowOrangeSoft, in: .rect(cornerRadius: 8))
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
                    .background(STRQPalette.sandowCard, in: .rect(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(STRQPalette.sandowOrange.opacity(0.18), lineWidth: 1)
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
