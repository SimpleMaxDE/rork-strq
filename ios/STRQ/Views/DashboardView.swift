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
        .background(Color(.systemBackground))
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
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 3) {
                Text(greeting)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(vm.profile.name.isEmpty ? L10n.tr("Athlete") : vm.profile.name)
                    .font(.system(.title2, design: .rounded, weight: .bold))
            }
            Spacer()
            readinessBadge
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
    }

    private var readinessBadge: some View {
        Group {
            if let readiness = vm.todaysReadiness {
                let score = readiness.readinessScore
                let color = ForgeTheme.recoveryColor(for: score)
                VStack(spacing: 3) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 4)
                            .frame(width: 46, height: 46)
                        Circle()
                            .trim(from: 0, to: appeared ? CGFloat(score) / 100 : 0)
                            .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 46, height: 46)
                            .rotationEffect(.degrees(-90))
                            .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.8).delay(0.2), value: appeared)
                        STRQCountUpText(value: Double(score), duration: 0.7)
                            .font(.system(size: 14, weight: .bold, design: .rounded).monospacedDigit())
                    }
                    Text(L10n.tr("Ready"))
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.3)
                }
            } else if vm.streak > 0 {
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(STRQBrand.steel)
                    Text("\(vm.streak)")
                        .font(.system(.subheadline, design: .rounded, weight: .bold).monospacedDigit())
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(STRQBrand.steel.opacity(0.12), in: Capsule())
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
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(tint)
                    .frame(width: 3, height: 12)
                Text(primary.eyebrow)
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(tint)
                Spacer()
                if vm.isEarlyStage {
                    todayPriorityPill
                } else if let momentum = briefing.momentum {
                    HStack(spacing: 4) {
                        Image(systemName: momentum.icon)
                            .font(.system(size: 9, weight: .bold))
                        Text(momentum.title)
                            .font(.system(size: 10, weight: .bold))
                            .lineLimit(1)
                    }
                    .foregroundStyle(STRQBrand.steel)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(STRQBrand.steel.opacity(0.12), in: Capsule())
                }
            }

            HStack(alignment: .top, spacing: 14) {
                Image(systemName: primary.icon)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(primary.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.primary)
                    Text(primary.detail)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }

            if let rest = briefing.restPrep {
                HStack(spacing: 10) {
                    Image(systemName: rest.icon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(STRQBrand.steel)
                        .frame(width: 24, height: 24)
                        .background(STRQBrand.steel.opacity(0.12), in: .rect(cornerRadius: 7))
                    VStack(alignment: .leading, spacing: 1) {
                        Text(rest.title)
                            .font(.caption.weight(.semibold))
                        Text(rest.detail)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.top, 2)
            }

            primaryCTA(primary)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.05), value: appeared)
    }

    @ViewBuilder
    private func primaryCTA(_ primary: DailyBriefing.Primary) -> some View {
        switch primary.kind {
        case .checkInBeforeTraining:
            ForgePrimaryButton(icon: "heart.text.clipboard", title: L10n.tr("Check in")) {
                showReadinessCheckIn = true
            }
        case .logBodyWeight:
            ForgePrimaryButton(icon: "scalemass.fill", title: primary.ctaTitle) {
                showWeightLog = true
            }
        case .startFirstSession:
            if let day = vm.todaysWorkout ?? vm.nextWorkout {
                ForgePrimaryButton(icon: "sparkles", title: L10n.tr("Start Session 1")) {
                    vm.prepareWorkoutHandoff(day: day)
                }
            }
        case .resumeWorkout:
            if let day = vm.todaysWorkout {
                ForgePrimaryButton(icon: "play.fill", title: L10n.tr("Resume Workout")) {
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
        .background(ForgeTheme.accentGradient, in: Capsule())
    }

    private struct PostWorkoutBridge {
        let sessionName: String
        let timeLabel: String
        let stats: String
        let takeaway: String
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
        let completedExercises = session.exerciseLogs.filter(\.isCompleted).count
        let completedSets = session.exerciseLogs.flatMap(\.sets).filter(\.isCompleted).count

        return PostWorkoutBridge(
            sessionName: session.dayName,
            timeLabel: postWorkoutTimeLabel(minutesAgo),
            stats: postWorkoutStatsText(exercises: completedExercises, sets: completedSets),
            takeaway: postWorkoutTakeaway(for: result.verdict.kind),
            nextStep: postWorkoutNextStep(),
            accent: postWorkoutAccent(for: result.verdict.kind),
            icon: postWorkoutIcon(for: result.verdict.kind)
        )
    }

    private func postWorkoutStatsText(exercises: Int, sets: Int) -> String {
        let exerciseWord = L10n.tr(exercises == 1 ? "exercise.singular" : "exercise.plural")
        let setWord = L10n.tr(sets == 1 ? "set.singular" : "set.plural")
        return L10n.format("%d %@ · %d %@", exercises, exerciseWord, sets, setWord)
    }

    private func postWorkoutBridgeCard(_ bridge: PostWorkoutBridge) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: bridge.icon)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(bridge.accent)
                    .frame(width: 34, height: 34)
                    .background(bridge.accent.opacity(0.16), in: .rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(L10n.tr("JUST COMPLETED"))
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.1)
                            .foregroundStyle(bridge.accent)
                        Text(bridge.timeLabel)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.tertiary)
                    }
                    Text(bridge.sessionName)
                        .font(.subheadline.weight(.semibold))
                    Text(bridge.stats)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)
            }

            VStack(alignment: .leading, spacing: 8) {
                postWorkoutBridgeLine(label: L10n.tr("STRQ took"), text: bridge.takeaway)
                postWorkoutBridgeLine(label: L10n.tr("Next"), text: bridge.nextStep)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.06), value: appeared)
    }

    private func postWorkoutBridgeLine(label: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 9, weight: .black))
                .tracking(0.8)
                .foregroundStyle(.tertiary)
                .frame(width: 60, alignment: .leading)
            Text(text)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
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
            return L10n.tr("Session 2 is the next signal that matters.")
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
            return STRQPalette.info
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

        return HStack(spacing: 12) {
            Image(systemName: "arrow.up.right.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(STRQPalette.success)
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
                    .lineLimit(2)
                Text(since.sessionName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(isSupporting ? Color(.secondarySystemGroupedBackground) : STRQPalette.successSoft.opacity(0.5), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(isSupporting ? STRQBrand.cardBorder : STRQPalette.success.opacity(0.2), lineWidth: 1)
        )
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
        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: guidance.icon)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 9))

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(L10n.tr("CALIBRATING"))
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.1)
                            .foregroundStyle(STRQBrand.steel)
                        Spacer()
                        Text("\(tierIndex + 1)/4")
                            .font(.system(size: 9, weight: .bold).monospacedDigit())
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    Text(guidance.headline)
                        .font(.subheadline.weight(.semibold))
                }
                Spacer(minLength: 0)
            }

            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { i in
                    Capsule()
                        .fill(i <= tierIndex ? AnyShapeStyle(STRQBrand.accentGradient) : AnyShapeStyle(Color.white.opacity(0.08)))
                        .frame(height: 3)
                }
            }
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
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
        return VStack(spacing: 0) {
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
                        STRQCelebrationBadge(title: L10n.tr("Recovery first"), icon: "heart.circle.fill", variant: .steel)
                    } else if isFirstSession {
                        STRQCelebrationBadge(title: L10n.tr("Milestone"), icon: "sparkles", variant: .gold)
                    } else if let momentum = briefing.momentum {
                        Text(momentum.title)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.55))
                            .lineLimit(1)
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
                        ForgeChip(text: muscle.displayName)
                    }
                }

                Divider().opacity(0.22)

                HStack(spacing: 0) {
                    ForgeStatCell(value: "\(day.exercises.count)", label: L10n.tr("Exercises"))
                    ForgeStatCell(value: "~\(day.estimatedMinutes)m", label: L10n.tr("Duration"))
                    ForgeStatCell(value: "\(day.exercises.reduce(0) { $0 + $1.sets })", label: L10n.tr("Total Sets"))
                }
            }
            .padding(20)

            if primary.kind == .checkInBeforeTraining {
                HStack(spacing: 10) {
                    Button {
                        showReadinessCheckIn = true
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "heart.text.clipboard")
                            Text(L10n.tr("Check in"))
                        }
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 12))
                    }
                    .buttonStyle(.strqPressable)

                    Button {
                        vm.prepareWorkoutHandoff(day: day)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                            Text(L10n.tr("Start Workout"))
                        }
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white.opacity(0.82))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
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
                ForgePrimaryButton(
                    icon: primary.kind == .resumeWorkout ? "play.fill" : "bolt.fill",
                    title: workoutPrimaryTitle(for: primary.kind)
                ) {
                    vm.prepareWorkoutHandoff(day: day)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .background(
            LinearGradient(
                colors: isRecovery
                    ? [Color(white: 0.14), Color(white: 0.10)]
                    : [Color(white: 0.19), Color(white: 0.09)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 22)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(tint.opacity(isRecovery ? 0.18 : 0.32), lineWidth: 1)
        )
        .overlay(alignment: .top) {
            tint
                .frame(height: 3)
                .clipShape(.rect(cornerRadii: .init(topLeading: 22, bottomLeading: 0, bottomTrailing: 0, topTrailing: 22)))
        }
        .shadow(color: tint.opacity(isRecovery ? 0.10 : 0.16), radius: 22, y: 8)
        .shadow(color: .black.opacity(0.25), radius: 18, y: 6)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.05), value: appeared)
    }

    private func workoutPrimaryTitle(for kind: DailyBriefing.PrimaryKind) -> String {
        switch kind {
        case .resumeWorkout:
            return L10n.tr("Resume Workout")
        case .startFirstSession:
            return L10n.tr("Start Session 1")
        case .recoverToday:
            return L10n.tr("Start Light Session")
        default:
            return L10n.tr("Start Workout")
        }
    }

    private func coachAdjustmentChip(_ adj: CoachAdjustment) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "brain.head.profile.fill")
                .font(.system(size: 9))
            Text(adj.description)
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(STRQBrand.steel)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(STRQBrand.steel.opacity(0.1), in: Capsule())
    }

    // MARK: - Schedule Timeline

    @ViewBuilder
    private var scheduleTimeline: some View {
        if let plan = vm.currentPlan, plan.days.contains(where: { $0.scheduledWeekday != nil }) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ForgeSectionHeader(title: L10n.tr("Training Week"), showAccent: true)
                    Spacer()
                    if let next = nextScheduledDay {
                        Text(L10n.format("Next: %@", vm.weekdayName(next.scheduledWeekday ?? 0)))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(STRQBrand.steel)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(STRQBrand.steel.opacity(0.1), in: Capsule())
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
                                .foregroundStyle(isToday ? Color.white : Color.secondary)

                            ZStack {
                                if matchingDay != nil {
                                    Circle()
                                        .fill(isToday ? Color.white : isPast ? STRQBrand.steel.opacity(0.3) : STRQBrand.steel)
                                        .frame(width: 28, height: 28)
                                    Image(systemName: "figure.strengthtraining.traditional")
                                        .font(.system(size: 10, weight: .medium))
                                        .foregroundStyle(isToday ? .black : .white)
                                } else {
                                    Circle()
                                        .fill(Color.white.opacity(isToday ? 0.1 : 0.04))
                                        .frame(width: 28, height: 28)
                                    if isToday {
                                        Circle()
                                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 1.5)
                                            .frame(width: 28, height: 28)
                                    }
                                }
                            }

                            if let day = matchingDay {
                                Text(shortName(day.name))
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundStyle(isToday ? STRQBrand.steel : Color.gray)
                                    .lineLimit(1)
                            } else {
                                Text(isToday ? L10n.tr("Rest") : "")
                                    .font(.system(size: 8, weight: .medium))
                                    .foregroundStyle(Color.gray)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 4)
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
            )
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
                        color: STRQBrand.steel
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
                        color: STRQBrand.steel
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
                            .foregroundStyle(.white)
                            .frame(width: 28, height: 28)
                            .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(L10n.tr("Weekly review ready"))
                                .font(.subheadline.weight(.semibold))
                            Text(L10n.tr("Review this week and adjust"))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
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
                .buttonStyle(.strqPressable)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    private func signalButton(icon: String, label: String, value: String, progress: Double, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 5) {
                HStack(spacing: 4) {
                    Image(systemName: icon)
                        .font(.system(size: 10))
                        .foregroundStyle(STRQBrand.steel)
                    Text(label)
                        .font(.system(size: 10, weight: .bold))
                        .textCase(.uppercase)
                        .tracking(0.2)
                }
                Text(value)
                    .font(.system(.subheadline, design: .rounded, weight: .bold).monospacedDigit())

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 4)
                        Capsule()
                            .fill(color.gradient)
                            .frame(width: max(0, geo.size.width * min(progress, 1.0)), height: 4)
                    }
                }
                .frame(height: 4)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.strqPressable)
    }

    // MARK: - Week Pulse

    private var weekPulse: some View {
        VStack(spacing: 14) {
            Button {
                withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .snappy(duration: 0.22)) {
                    showWeekPulseDetails.toggle()
                }
            } label: {
                HStack {
                    ForgeSectionHeader(title: L10n.tr("This Week"), showAccent: true)
                    Spacer()
                    if let momentum = vm.momentumData {
                        let paceColor = ForgeTheme.color(for: momentum.weeklyPace.colorName)
                        Text(momentum.paceMessage)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(paceColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(paceColor.opacity(0.1), in: Capsule())
                    }
                    Image(systemName: showWeekPulseDetails ? "chevron.up" : "chevron.down")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.tertiary)
                }
            }
            .buttonStyle(.plain)

            HStack(spacing: 0) {
                ForEach(vm.weeklyActivity) { day in
                    VStack(spacing: 6) {
                        Text(day.label)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.tertiary)
                        Circle()
                            .fill(day.didTrain ? Color.white : Color.white.opacity(0.06))
                            .frame(width: 28, height: 28)
                            .overlay {
                                if day.didTrain {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundStyle(.black)
                                }
                            }
                    }
                    .frame(maxWidth: .infinity)
                }
            }

            if showWeekPulseDetails {
                HStack(spacing: 12) {
                    ForgeStatCell(value: "\(vm.weeklyStats.sessions)/\(vm.profile.daysPerWeek)", label: L10n.tr("Sessions"))
                    ForgeStatCell(value: ForgeTheme.formatVolume(vm.weeklyStats.volume), label: L10n.tr("Volume"))
                    ForgeStatCell(value: "\(vm.effectiveRecoveryScore)%", label: L10n.tr("Recovery"), valueColor: ForgeTheme.recoveryColor(for: vm.effectiveRecoveryScore))
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
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
