import SwiftUI

@Observable
@MainActor
class AppViewModel {
    var profile: UserProfile
    var currentPlan: WorkoutPlan?
    var workoutHistory: [WorkoutSession]
    var personalRecords: [PersonalRecord]
    var progressEntries: [ProgressEntry]
    var recommendations: [Recommendation]
    var favoriteExerciseIds: Set<String>
    var activeWorkout: ActiveWorkoutState?
    var hasCompletedOnboarding: Bool

    let library = ExerciseLibrary.shared
    private let actionManager = CoachActionManager()
    private let progressionEngine = ProgressionEngine()
    let startingLoadEngine = StartingLoadEngine()
    var planEvolutionSignals: [PlanEvolutionSignal] = []
    var toleranceSignals: [ToleranceSignal] = []

    var coachAdjustments: [CoachAdjustment] = []
    var appliedActionIds: Set<String> = []
    var weekAdjustmentActive: CoachAdjustmentType?
    var previousPlanBeforeWeekAction: WorkoutPlan?

    var weeklyReview: WeeklyReview?
    var showWeeklyReview: Bool = false
    var weeklyReviewDismissed: Bool = false
    private let reviewGenerator = WeeklyReviewGenerator()


    var progressionStates: [ExerciseProgressionState] = []
    var trainingPhaseState: TrainingPhaseState = TrainingPhaseState()
    var planQuality: PlanQualityScore?
    var nextBestAction: NextBestAction?
    var volumeLandmarks: [VolumeLandmark] = []
    var balanceInsights: [BalanceInsight] = []
    var volumeGuidance: [VolumeGuidance] = []

    // MARK: - Onboarding Flow
    var onboardingPhase: OnboardingPhase = .form

    // MARK: - Daily Readiness
    var todaysReadiness: DailyReadiness?
    var readinessHistory: [DailyReadiness] = []
    var coachResponse: ReadinessCoachResponse?
    var dailyCoachMessage: DailyCoachMessage?
    var momentumData: MomentumData?
    var notificationSettings: NotificationSettings = NotificationSettings()


    // MARK: - Nutrition & Recovery
    var nutritionTarget: NutritionTarget = NutritionTarget()
    var nutritionLogs: [DailyNutritionLog] = []
    var bodyWeightEntries: [BodyWeightEntry] = []
    var sleepEntries: [SleepEntry] = []
    var nutritionInsights: [NutritionCoachInsight] = []
    var goalPace: GoalPaceStatus?
    var physiqueOutcome: PhysiqueOutcome?

    private let persistence = PersistenceStore.shared
    let account = AccountManager.shared
    let cloudSync = CloudSyncService.shared
    private var isHydrating: Bool = false

    // MARK: - Domain coordinators (composition root)
    private var _workoutController: WorkoutController?
    var workoutController: WorkoutController {
        if let c = _workoutController { return c }
        let c = WorkoutController(vm: self)
        _workoutController = c
        return c
    }
    @ObservationIgnored private var _coachingCoordinator: CoachingCoordinator!
    @ObservationIgnored private var _nutritionCoordinator: NutritionPhysiqueCoordinator!
    @ObservationIgnored private var _dailyStateCoordinator: DailyStateCoordinator!
    @ObservationIgnored private var _continuityCoordinator: ContinuityCoordinator!
    @ObservationIgnored private var _reminderWidgetCoordinator: ReminderWidgetCoordinator!
    private var coachingCoordinator: CoachingCoordinator { _coachingCoordinator }
    private var nutritionCoordinator: NutritionPhysiqueCoordinator { _nutritionCoordinator }
    private var dailyStateCoordinator: DailyStateCoordinator { _dailyStateCoordinator }
    private var continuityCoordinator: ContinuityCoordinator { _continuityCoordinator }
    private var reminderWidgetCoordinator: ReminderWidgetCoordinator { _reminderWidgetCoordinator }

    init() {
        self.profile = UserProfile()
        self.currentPlan = nil
        self.workoutHistory = []
        self.personalRecords = []
        self.progressEntries = []
        self.recommendations = []
        self.favoriteExerciseIds = []
        self.activeWorkout = nil
        self.hasCompletedOnboarding = false

        self._coachingCoordinator = CoachingCoordinator(vm: self)
        self._nutritionCoordinator = NutritionPhysiqueCoordinator(vm: self)
        self._dailyStateCoordinator = DailyStateCoordinator(vm: self)
        self._continuityCoordinator = ContinuityCoordinator(vm: self)
        self._reminderWidgetCoordinator = ReminderWidgetCoordinator(vm: self)

        let legacyOnboardingFlag = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

        if let saved = persistence.load() {
            Analytics.shared.track(.persistence_loaded, ["source": "v1"])
            ErrorReporter.shared.breadcrumb("Persistence loaded", category: "persistence")
            isHydrating = true
            self.hasCompletedOnboarding = saved.hasCompletedOnboarding
            self.profile = saved.profile
            self.currentPlan = saved.currentPlan
            self.workoutHistory = saved.workoutHistory
            self.personalRecords = saved.personalRecords
            self.progressEntries = saved.progressEntries
            self.favoriteExerciseIds = Set(saved.favoriteExerciseIds)
            self.progressionStates = saved.progressionStates
            self.trainingPhaseState = saved.trainingPhaseState
            self.coachAdjustments = saved.coachAdjustments
            self.appliedActionIds = Set(saved.appliedActionIds)
            self.weekAdjustmentActive = saved.weekAdjustmentActive
            self.previousPlanBeforeWeekAction = saved.previousPlanBeforeWeekAction
            self.weeklyReviewDismissed = saved.weeklyReviewDismissed
            self.todaysReadiness = saved.todaysReadiness
            self.readinessHistory = saved.readinessHistory
            self.notificationSettings = saved.notificationSettings
            self.nutritionTarget = saved.nutritionTarget
            self.nutritionLogs = saved.nutritionLogs
            self.bodyWeightEntries = saved.bodyWeightEntries
            self.sleepEntries = saved.sleepEntries
            if let draft = saved.activeWorkoutDraft {
                self.activeWorkout = ActiveWorkoutState(
                    session: draft.session,
                    currentExerciseIndex: draft.currentExerciseIndex,
                    currentSetIndex: draft.currentSetIndex,
                    isResting: false,
                    restTimeRemaining: 0,
                    plannedExercises: draft.plannedExercises
                )
                Analytics.shared.track(.active_workout_restored, ["day": draft.session.dayName])
            }
            isHydrating = false
            refreshIntelligence()
            refreshNutritionInsights()
            refreshDailyState()
            scheduleSmartRemindersIfNeeded(force: true)
        } else if legacyOnboardingFlag {
            self.hasCompletedOnboarding = false
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
            refreshDailyState()
        } else {
            self.hasCompletedOnboarding = false
            refreshDailyState()
        }
    }

    func persist() {
        guard !isHydrating else { return }
        let snapshot = SnapshotBuilder.build(from: self, version: persistence.version)
        continuityCoordinator.save(snapshot: snapshot)
        reminderWidgetCoordinator.scheduleIfNeeded()
        reminderWidgetCoordinator.refreshWidgetSnapshot()
        WatchConnectivityService.shared.pushActiveWorkoutState()
        continuityCoordinator.uploadIfSignedIn(snapshot)
    }

    // MARK: - Cloud Sync

    @discardableResult
    func restoreFromCloud(force: Bool = false) -> CloudRestoreOutcome {
        continuityCoordinator.restore(force: force)
    }

    func uploadToCloud() {
        continuityCoordinator.uploadNow()
    }

    func apply(snapshot saved: PersistedAppState) {
        // Preserve an in-progress workout across a snapshot apply.
        // Restore should never yank the user out of the session they're
        // currently logging — even if the remote snapshot is richer overall.
        let preservedActive = activeWorkout
        isHydrating = true
        hasCompletedOnboarding = saved.hasCompletedOnboarding
        profile = saved.profile
        currentPlan = saved.currentPlan
        workoutHistory = saved.workoutHistory
        personalRecords = saved.personalRecords
        progressEntries = saved.progressEntries
        favoriteExerciseIds = Set(saved.favoriteExerciseIds)
        progressionStates = saved.progressionStates
        trainingPhaseState = saved.trainingPhaseState
        coachAdjustments = saved.coachAdjustments
        appliedActionIds = Set(saved.appliedActionIds)
        weekAdjustmentActive = saved.weekAdjustmentActive
        previousPlanBeforeWeekAction = saved.previousPlanBeforeWeekAction
        weeklyReviewDismissed = saved.weeklyReviewDismissed
        todaysReadiness = saved.todaysReadiness
        readinessHistory = saved.readinessHistory
        notificationSettings = saved.notificationSettings
        nutritionTarget = saved.nutritionTarget
        nutritionLogs = saved.nutritionLogs
        bodyWeightEntries = saved.bodyWeightEntries
        sleepEntries = saved.sleepEntries
        if let preservedActive {
            activeWorkout = preservedActive
            ErrorReporter.shared.breadcrumb("Snapshot applied — active workout preserved", category: "sync")
        } else if let draft = saved.activeWorkoutDraft {
            activeWorkout = ActiveWorkoutState(
                session: draft.session,
                currentExerciseIndex: draft.currentExerciseIndex,
                currentSetIndex: draft.currentSetIndex,
                isResting: false,
                restTimeRemaining: 0,
                plannedExercises: draft.plannedExercises
            )
        } else {
            activeWorkout = nil
        }
        isHydrating = false
        refreshIntelligence()
        refreshNutritionInsights()
        refreshDailyState()
        persist()
    }

    // MARK: - Smart Reminders / Widgets (delegated)

    func scheduleSmartRemindersIfNeeded(force: Bool = false) {
        reminderWidgetCoordinator.scheduleIfNeeded(force: force)
    }

    func rescheduleSmartReminders() {
        reminderWidgetCoordinator.scheduleIfNeeded(force: true)
    }

    func refreshWidgetSnapshot() {
        reminderWidgetCoordinator.refreshWidgetSnapshot()
    }

    func resetAllData() {
        Analytics.shared.track(.persistence_reset)
        ErrorReporter.shared.breadcrumb("Reset all data", category: "persistence")
        persistence.clear()
        hasCompletedOnboarding = false
        profile = UserProfile()
        currentPlan = nil
        workoutHistory = []
        personalRecords = []
        progressEntries = []
        recommendations = []
        favoriteExerciseIds = []
        progressionStates = []
        trainingPhaseState = TrainingPhaseState()
        coachAdjustments = []
        appliedActionIds = []
        weekAdjustmentActive = nil
        previousPlanBeforeWeekAction = nil
        weeklyReview = nil
        showWeeklyReview = false
        weeklyReviewDismissed = false
        todaysReadiness = nil
        readinessHistory = []
        coachResponse = nil
        dailyCoachMessage = nil
        momentumData = nil
        notificationSettings = NotificationSettings()
        nutritionTarget = NutritionTarget()
        nutritionLogs = []
        bodyWeightEntries = []
        sleepEntries = []
        nutritionInsights = []
        goalPace = nil
        physiqueOutcome = nil
        activeWorkout = nil
        onboardingPhase = .form
    }

    func beginPlanGeneration() {
        profile.startWeightKg = profile.weightKg
        onboardingPhase = .generating
        Analytics.shared.track(.plan_generation_started, [
            "goal": profile.goal.displayName,
            "level": profile.trainingLevel.shortName,
            "days_per_week": String(profile.daysPerWeek)
        ])
        ErrorReporter.shared.breadcrumb("Plan generation started", category: "onboarding")
    }

    func finishPlanGeneration() {
        workoutHistory = []
        personalRecords = []
        progressEntries = []
        trainingPhaseState = TrainingPhaseState()
        progressionStates = []
        generatePlan()
        refreshIntelligence()
        onboardingPhase = .reveal
        Analytics.shared.track(.plan_generation_completed, [
            "exercises": String(currentPlan?.days.flatMap(\.exercises).count ?? 0),
            "days": String(currentPlan?.days.count ?? 0)
        ])
        Analytics.shared.track(.plan_reveal_viewed)
    }

    func completeOnboarding() {
        profile.hasCompletedOnboarding = true
        hasCompletedOnboarding = true
        onboardingPhase = .form
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        Analytics.shared.track(.onboarding_completed, [
            "goal": profile.goal.displayName,
            "level": profile.trainingLevel.shortName,
            "days_per_week": String(profile.daysPerWeek)
        ])
        Analytics.shared.track(.plan_reveal_started_training)
        ErrorReporter.shared.breadcrumb("Onboarding completed", category: "onboarding")
        nutritionTarget = nutritionCoordinator.computeTargets()
        if bodyWeightEntries.isEmpty {
            bodyWeightEntries = [BodyWeightEntry(weightKg: profile.weightKg, bodyFatPercent: profile.bodyFatPercentage)]
        }
        refreshDailyState()
        refreshNutritionInsights()
        persist()
    }

    func generatePlan() {
        var plan = PlanGenerator().generate(
            for: profile,
            muscleBalance: muscleBalance,
            recentSessions: workoutHistory,
            recoveryScore: recoveryScore,
            phase: trainingPhaseState.currentPhase
        )
        let preferred = profile.preferredTrainingDays.isEmpty
            ? defaultTrainingDays(count: plan.days.count)
            : Array(profile.preferredTrainingDays.prefix(plan.days.count))
        for i in plan.days.indices where i < preferred.count {
            if plan.days[i].scheduledWeekday == nil {
                plan.days[i].scheduledWeekday = preferred[i]
            }
        }
        currentPlan = plan
        refreshPlanQuality()
        persist()
    }

    func refreshCoachingInsights() {
        coachingCoordinator.refreshCoachingInsights()
    }

    func refreshIntelligence() {
        coachingCoordinator.refreshIntelligence()
    }

    func refreshPlanQuality() {
        coachingCoordinator.refreshPlanQuality()
    }

    var currentPhase: TrainingPhase {
        trainingPhaseState.currentPhase
    }

    var progressingExercises: [ExerciseProgressionState] {
        progressionStates.filter { $0.plateauStatus == .progressing }
    }

    var stalledExercises: [ExerciseProgressionState] {
        progressionStates.filter { $0.plateauStatus == .plateaued || $0.plateauStatus == .regressing || $0.plateauStatus == .stalling }
    }

    func exerciseReplacements(for exercise: Exercise, reason: ReplacementReason = .general) -> [Exercise] {
        coachingCoordinator.exerciseReplacements(for: exercise, reason: reason)
    }

    func toggleFavorite(_ exerciseId: String) {
        if favoriteExerciseIds.contains(exerciseId) {
            favoriteExerciseIds.remove(exerciseId)
        } else {
            favoriteExerciseIds.insert(exerciseId)
        }
        persist()
    }

    func loadSuggestion(for exerciseId: String, planned: PlannedExercise? = nil) -> StartingLoadEngine.LoadSuggestion? {
        startingLoadEngine.suggestStartingLoad(
            exerciseId: exerciseId,
            profile: profile,
            sessions: workoutHistory,
            progressionStates: progressionStates,
            planned: planned
        )
    }

    func todayPrescription(for planned: PlannedExercise) -> TodayPrescription {
        coachingCoordinator.todayPrescription(for: planned)
    }

    struct LastPerformance {
        let date: Date
        let topWeight: Double
        let topReps: Int
        let totalSets: Int
        let totalReps: Int
        let bestVolume: Double
    }

    func lastPerformance(for exerciseId: String) -> LastPerformance? {
        for session in workoutHistory where session.isCompleted {
            guard let log = session.exerciseLogs.first(where: { $0.exerciseId == exerciseId }) else { continue }
            let doneSets = log.sets.filter(\.isCompleted)
            guard !doneSets.isEmpty else { continue }
            let top = doneSets.max(by: { $0.weight < $1.weight }) ?? doneSets[0]
            let volume = doneSets.reduce(0.0) { $0 + $1.weight * Double($1.reps) }
            return LastPerformance(
                date: session.startTime,
                topWeight: top.weight,
                topReps: top.reps,
                totalSets: doneSets.count,
                totalReps: doneSets.reduce(0) { $0 + $1.reps },
                bestVolume: volume
            )
        }
        return nil
    }

    func nextSessionGuidance(for exerciseId: String) -> NextSessionGuidance? {
        startingLoadEngine.nextSessionSuggestion(
            exerciseId: exerciseId,
            profile: profile,
            sessions: workoutHistory,
            progressionStates: progressionStates,
            phase: currentPhase
        )
    }

    // MARK: - Workout subsystem (delegated to WorkoutController)

    func startWorkout(day: WorkoutDay) {
        workoutController.startWorkout(day: day)
    }

    func completeWorkout() {
        workoutController.completeWorkout()
    }

    func saveActiveWorkoutDraft() {
        workoutController.saveDraft()
    }

    func updateSetLoad(exerciseIndex: Int, setIndex: Int, weight: Double, reps: Int) {
        workoutController.updateSetLoad(exerciseIndex: exerciseIndex, setIndex: setIndex, weight: weight, reps: reps)
    }

    @discardableResult
    func completeCurrentSet(exerciseIndex: Int, setIndex: Int) -> Int {
        workoutController.completeCurrentSet(exerciseIndex: exerciseIndex, setIndex: setIndex)
    }

    func setSetQuality(exerciseIndex: Int, setIndex: Int, quality: SetQuality?) {
        workoutController.setSetQuality(exerciseIndex: exerciseIndex, setIndex: setIndex, quality: quality)
    }

    func jumpToSet(exerciseIndex: Int, setIndex: Int) {
        workoutController.jumpToSet(exerciseIndex: exerciseIndex, setIndex: setIndex)
    }

    func moveToNextExercise() {
        workoutController.moveToNextExercise()
    }

    func moveToPreviousExercise() {
        workoutController.moveToPreviousExercise()
    }

    func jumpToExercise(_ index: Int) {
        workoutController.jumpToExercise(index)
    }

    func handleWatchAction(_ action: String, payload: [String: Any]) {
        workoutController.handleWatchAction(action, payload: payload)
    }

    func updateLiveActivity(restEndsAt: Date? = nil) {
        workoutController.updateLiveActivity(restEndsAt: restEndsAt)
    }

    var readinessBucket: String {
        let score = effectiveRecoveryScore
        switch score {
        case 85...: return "peak"
        case 70..<85: return "high"
        case 55..<70: return "moderate"
        case 40..<55: return "low"
        default: return "very_low"
        }
    }

    var todaysWorkout: WorkoutDay? {
        guard let plan = currentPlan else { return nil }
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        if plan.days.contains(where: { $0.scheduledWeekday != nil }) {
            return plan.days.first { $0.scheduledWeekday == todayWeekday && !$0.isSkipped }
        }
        let active = plan.days.filter { !$0.isSkipped }
        guard !active.isEmpty else { return nil }
        let dayIndex = todayWeekday % active.count
        return active[dayIndex]
    }

    var weeklyStats: (sessions: Int, volume: Double, sets: Int) {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recent = workoutHistory.filter { $0.startTime > weekAgo && $0.isCompleted }
        return (
            sessions: recent.count,
            volume: recent.reduce(0) { $0 + $1.totalVolume },
            sets: recent.flatMap(\.exerciseLogs).flatMap(\.sets).filter(\.isCompleted).count
        )
    }

    var streak: Int { computedStreak }

    private var computedStreak: Int {
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: Date())
        var streakCount = 0
        let todayHasWorkout = workoutHistory.contains { calendar.isDate($0.startTime, inSameDayAs: currentDate) && $0.isCompleted }
        let todayHasReadiness = readinessHistory.contains { calendar.isDate($0.date, inSameDayAs: currentDate) }
        if todayHasWorkout || todayHasReadiness {
            streakCount = 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        for _ in 0..<60 {
            let hasActivity = workoutHistory.contains { calendar.isDate($0.startTime, inSameDayAs: currentDate) && $0.isCompleted }
            let hasCheckin = readinessHistory.contains { calendar.isDate($0.date, inSameDayAs: currentDate) }
            if hasActivity || hasCheckin {
                streakCount += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        return streakCount
    }

    var _dynamicInsights: [SmartInsight] = []
    var insights: [SmartInsight] { _dynamicInsights }

    var weeklyActivity: [DayActivity] {
        let calendar = Calendar.current
        let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]
        return (0..<7).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: Date()) ?? Date()
            let weekday = calendar.component(.weekday, from: date) - 1
            let session = workoutHistory.first { calendar.isDate($0.startTime, inSameDayAs: date) && $0.isCompleted }
            let duration: Int = {
                guard let s = session, let end = s.endTime else { return 0 }
                return Int(end.timeIntervalSince(s.startTime) / 60)
            }()
            return DayActivity(
                label: weekdaySymbols[weekday],
                date: date,
                didTrain: session != nil,
                volume: session?.totalVolume ?? 0,
                duration: duration
            )
        }
    }

    var muscleBalance: [MuscleBalanceEntry] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let fourWeeksAgo = calendar.date(byAdding: .day, value: -28, to: Date()) ?? Date()

        let thisWeek = progressEntries.filter { $0.date > weekAgo }
        let fourWeek = progressEntries.filter { $0.date > fourWeeksAgo }

        let muscles = ["Chest", "Back", "Shoulders", "Quads", "Hamstrings", "Glutes", "Arms", "Abs"]
        let keyMap: [String: String] = [
            "Chest": "chest", "Back": "back", "Shoulders": "shoulders",
            "Quads": "quads", "Hamstrings": "hamstrings", "Glutes": "glutes",
            "Arms": "arms", "Abs": "abs"
        ]

        return muscles.map { name in
            let key = keyMap[name] ?? name.lowercased()
            let weekVol = thisWeek.reduce(0.0) { $0 + ($1.muscleGroupVolume[key] ?? 0) }
            let totalVol = fourWeek.reduce(0.0) { $0 + ($1.muscleGroupVolume[key] ?? 0) }
            let weeks = max(1, min(4, fourWeek.count / 7 + 1))
            let avg = totalVol / Double(weeks)
            return MuscleBalanceEntry(muscle: name, thisWeek: weekVol, average: avg)
        }
    }

    var strengthProgress: [StrengthEntry] {
        let calendar = Calendar.current

        // Pattern-based anchor lift detection. Any compound lift tagged with the right
        // movement pattern counts — barbell, dumbbell, machine, cable, hack squat, leg
        // press, pulldown, row — not just the classic barbell 4.
        func anchorIds(for patterns: Set<MovementPattern>, allowIsolation: Bool = false) -> Set<String> {
            var ids: Set<String> = []
            for session in workoutHistory where session.isCompleted {
                for log in session.exerciseLogs {
                    guard let ex = library.exercise(byId: log.exerciseId) else { continue }
                    guard patterns.contains(ex.movementPattern) else { continue }
                    if !allowIsolation && ex.category != .compound { continue }
                    ids.insert(ex.id)
                }
            }
            return ids
        }

        let pushIds = anchorIds(for: [.horizontalPush])
        let squatIds = anchorIds(for: [.squat])
        let hingeIds = anchorIds(for: [.hipHinge])
        let pullIds = anchorIds(for: [.verticalPull, .horizontalPull])

        func best1RM(in sessions: [WorkoutSession], ids: Set<String>) -> Double {
            guard !ids.isEmpty else { return 0 }
            var best: Double = 0
            for s in sessions {
                for log in s.exerciseLogs where ids.contains(log.exerciseId) {
                    for set in log.sets where set.isCompleted && set.reps > 0 {
                        let oneRM = set.weight * (1.0 + Double(set.reps) / 30.0)
                        if oneRM > best { best = oneRM }
                    }
                }
            }
            return best
        }

        var lastKnown: (bench: Double, squat: Double, deadlift: Double, ohp: Double) = (0, 0, 0, 0)
        var entries: [StrengthEntry] = []
        for weekOffset in (0..<8).reversed() {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: Date()) ?? Date()
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? Date()
            let weekSessions = workoutHistory.filter { $0.startTime >= weekStart && $0.startTime < weekEnd && $0.isCompleted }
            let b = best1RM(in: weekSessions, ids: pushIds)
            let s = best1RM(in: weekSessions, ids: squatIds)
            let d = best1RM(in: weekSessions, ids: hingeIds)
            let o = best1RM(in: weekSessions, ids: pullIds)
            let bench = b > 0 ? b : lastKnown.bench
            let squat = s > 0 ? s : lastKnown.squat
            let dead = d > 0 ? d : lastKnown.deadlift
            let ohp = o > 0 ? o : lastKnown.ohp
            lastKnown = (bench, squat, dead, ohp)
            if bench + squat + dead + ohp > 0 {
                entries.append(StrengthEntry(date: weekStart, bench: bench, squat: squat, deadlift: dead, ohp: ohp))
            }
        }
        return entries
    }

    // MARK: - Coaching Confidence

    private let confidenceAssessor = ConfidenceAssessor()

    var coachingConfidence: CoachingConfidence {
        let calendar = Calendar.current
        let fourWeeksAgo = calendar.date(byAdding: .day, value: -28, to: Date()) ?? Date()
        let completed = workoutHistory.filter { $0.startTime > fourWeeksAgo && $0.isCompleted }.count
        let readinessCount = readinessHistory.prefix(14).count
        let sleepCount = sleepEntries.prefix(7).count
        let weightCount = bodyWeightEntries.prefix(14).count
        let firstSession = workoutHistory.filter(\.isCompleted).last?.startTime
        let weeksTrained: Int = {
            guard let first = firstSession else { return 0 }
            let days = calendar.dateComponents([.day], from: first, to: Date()).day ?? 0
            return max(0, days / 7)
        }()
        return confidenceAssessor.assess(
            completedWorkouts: completed,
            readinessCheckIns: readinessCount,
            sleepLogs: sleepCount,
            weeksTrained: weeksTrained,
            weightLogs: weightCount
        )
    }

    var highPriorityInsights: [SmartInsight] {
        insights.filter { $0.severity == .high || $0.severity == .medium }
    }

    var positiveInsights: [SmartInsight] {
        insights.filter { $0.severity == .positive }
    }

    var insightsByCategory: [(InsightCategory, [SmartInsight])] {
        let grouped = Dictionary(grouping: insights) { $0.category }
        return grouped.sorted { $0.value.first?.severityRank ?? 0 > $1.value.first?.severityRank ?? 0 }
    }

    var recoveryStatus: String {
        switch recoveryScore {
        case 85...: return "Fully Recovered"
        case 70..<85: return "Well Rested"
        case 50..<70: return "Moderate"
        case 30..<50: return "Fatigued"
        default: return "Overreached"
        }
    }

    var totalCompletedWorkouts: Int {
        workoutHistory.filter(\.isCompleted).count
    }

    var totalTrainingVolume: Double {
        workoutHistory.filter(\.isCompleted).reduce(0) { $0 + $1.totalVolume }
    }

    var averageSessionDuration: Int {
        let completed = workoutHistory.filter(\.isCompleted)
        guard !completed.isEmpty else { return 0 }
        let totalMinutes = completed.compactMap { session -> Int? in
            guard let end = session.endTime else { return nil }
            return Int(end.timeIntervalSince(session.startTime) / 60)
        }
        guard !totalMinutes.isEmpty else { return 0 }
        return totalMinutes.reduce(0, +) / totalMinutes.count
    }

    var monthlyStats: (sessions: Int, volume: Double, sets: Int) {
        let monthAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let recent = workoutHistory.filter { $0.startTime > monthAgo && $0.isCompleted }
        return (
            sessions: recent.count,
            volume: recent.reduce(0) { $0 + $1.totalVolume },
            sets: recent.flatMap(\.exerciseLogs).flatMap(\.sets).filter(\.isCompleted).count
        )
    }

    var recoveryScore: Int {
        let calendar = Calendar.current
        let now = Date()
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: now) ?? now
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now

        let last48Count = workoutHistory.filter { $0.startTime > twoDaysAgo && $0.isCompleted }.count
        let weekSessions = workoutHistory.filter { $0.startTime > sevenDaysAgo && $0.isCompleted }
        let weekCount = weekSessions.count

        // Density baseline (last 48h dominates short-term fatigue).
        var score: Double = {
            switch last48Count {
            case 0: return 90
            case 1: return 78
            case 2: return 58
            default: return 38
            }
        }()

        // Weekly load vs. planned — sustained over/under-training shifts baseline.
        let planned = max(1, profile.daysPerWeek)
        let loadRatio = Double(weekCount) / Double(planned)
        if loadRatio > 1.3 { score -= 10 }
        else if loadRatio > 1.1 { score -= 5 }
        else if loadRatio < 0.4 && weekCount > 0 { score += 3 }

        // Recent volume spike vs. prior week (crude CNS proxy).
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        let priorWeekVolume = workoutHistory
            .filter { $0.startTime > twoWeeksAgo && $0.startTime <= sevenDaysAgo && $0.isCompleted }
            .reduce(0.0) { $0 + $1.totalVolume }
        let thisWeekVolume = weekSessions.reduce(0.0) { $0 + $1.totalVolume }
        if priorWeekVolume > 0 {
            let spike = (thisWeekVolume - priorWeekVolume) / priorWeekVolume
            if spike > 0.35 { score -= 8 }
            else if spike > 0.2 { score -= 4 }
        }

        // Sleep signal (last 3 nights).
        let recentSleep = sleepEntries.prefix(3)
        if !recentSleep.isEmpty {
            let avgHours = recentSleep.map(\.hoursSlept).reduce(0, +) / Double(recentSleep.count)
            let avgQuality = Double(recentSleep.map { $0.quality.rawValue }.reduce(0, +)) / Double(recentSleep.count)
            if avgHours < 6.0 || avgQuality <= 2.0 { score -= 10 }
            else if avgHours < 6.8 || avgQuality <= 2.5 { score -= 5 }
            else if avgHours >= 7.5 && avgQuality >= 4.0 { score += 4 }
        }

        // Today's readiness check-in, if present, nudges the score lightly.
        if let r = todaysReadiness {
            let delta = Double(r.readinessScore) - 70.0
            score += delta * 0.15
            if r.painOrRestriction { score -= 6 }
        }

        // Phase-aware cushion.
        switch trainingPhaseState.currentPhase {
        case .deload: score += 5
        case .fatigueManagement: score += 2
        case .push: score -= 2
        default: break
        }

        return max(10, min(98, Int(score.rounded())))
    }

    var nextWorkout: WorkoutDay? {
        nextScheduledWorkout(after: Date())
    }

    var nextScheduledWorkoutDate: Date? {
        guard let plan = currentPlan else { return nil }
        let active = plan.days.filter { !$0.isSkipped && $0.scheduledWeekday != nil }
        guard !active.isEmpty else { return nil }
        let calendar = Calendar.current
        let now = Date()
        let todayWeekday = calendar.component(.weekday, from: now)

        func date(forWeekday wd: Int, addWeek: Bool) -> Date? {
            var diff = wd - todayWeekday
            if addWeek { diff += 7 } else if diff < 0 { diff += 7 }
            return calendar.date(byAdding: .day, value: diff, to: calendar.startOfDay(for: now))
        }

        // Prefer today if still scheduled and not yet started
            let todayHasSession = active.contains { $0.scheduledWeekday == todayWeekday }
            if todayHasSession { return calendar.startOfDay(for: now) }

        let future = active.compactMap { day -> (Int, Date)? in
            guard let wd = day.scheduledWeekday else { return nil }
            guard let d = date(forWeekday: wd, addWeek: false), d >= calendar.startOfDay(for: now) else { return nil }
            return (wd, d)
        }.sorted { $0.1 < $1.1 }
        if let next = future.first { return next.1 }

        // Wrap around next week
        let wrapped = active.compactMap { day -> Date? in
            guard let wd = day.scheduledWeekday else { return nil }
            return date(forWeekday: wd, addWeek: true)
        }.sorted()
        return wrapped.first
    }

    private func nextScheduledWorkout(after date: Date) -> WorkoutDay? {
        guard let plan = currentPlan else { return nil }
        let active = plan.days.filter { !$0.isSkipped }
        guard !active.isEmpty else { return nil }
        let calendar = Calendar.current
        let todayWeekday = calendar.component(.weekday, from: date)

        if active.contains(where: { $0.scheduledWeekday != nil }) {
            let scheduled = active.filter { $0.scheduledWeekday != nil }
            let future = scheduled
                .filter { ($0.scheduledWeekday ?? 0) > todayWeekday }
                .sorted { ($0.scheduledWeekday ?? 0) < ($1.scheduledWeekday ?? 0) }
            if let next = future.first { return next }
            return scheduled.sorted { ($0.scheduledWeekday ?? 0) < ($1.scheduledWeekday ?? 0) }.first
        }
        let tomorrowIndex = (todayWeekday) % active.count
        return active[tomorrowIndex]
    }

    // MARK: - Coach Actions

    func previewVolumeReduction(for dayId: String) -> VolumeReductionPreview? {
        guard let plan = currentPlan else { return nil }
        return actionManager.previewVolumeReduction(plan: plan, dayId: dayId, recoveryScore: recoveryScore)
    }

    func applyVolumeReduction(dayId: String, preview: VolumeReductionPreview) {
        guard var plan = currentPlan else { return }
        if let adjustment = actionManager.applyVolumeReduction(plan: &plan, dayId: dayId, preview: preview) {
            currentPlan = plan
            coachAdjustments.append(adjustment)
            persist()
            Analytics.shared.track(.coach_action_applied, ["type": "volume_reduced", "day_id": dayId])
        }
    }

    func previewLighterSession(for dayId: String) -> LighterSessionPreview? {
        guard let plan = currentPlan else { return nil }
        return actionManager.previewLighterSession(plan: plan, dayId: dayId)
    }

    func applyLighterSession(dayId: String) {
        guard var plan = currentPlan else { return }
        if let adjustment = actionManager.applyLighterSession(plan: &plan, dayId: dayId) {
            currentPlan = plan
            coachAdjustments.append(adjustment)
            persist()
            Analytics.shared.track(.coach_action_applied, ["type": "lighter_session", "day_id": dayId])
        }
    }

    func swapExerciseOptions(for exerciseId: String, dayId: String) -> [ExerciseSwapOption] {
        guard let plan = currentPlan else { return [] }
        return actionManager.swapExerciseOptions(
            for: exerciseId,
            in: plan,
            dayId: dayId,
            profile: profile,
            progressionStates: progressionStates,
            workoutHistory: workoutHistory,
            recoveryScore: recoveryScore,
            phase: trainingPhaseState.currentPhase
        )
    }

    func applyExerciseSwap(dayId: String, oldExerciseId: String, newExercise: Exercise) {
        guard var plan = currentPlan else { return }
        if let adjustment = actionManager.applyExerciseSwap(plan: &plan, dayId: dayId, oldExerciseId: oldExerciseId, newExercise: newExercise) {
            currentPlan = plan
            coachAdjustments.append(adjustment)
            persist()
            Analytics.shared.track(.coach_action_applied, [
                "type": "exercise_swapped",
                "day_id": dayId,
                "old": oldExerciseId,
                "new": newExercise.id
            ])
        }
    }

    func undoAdjustment(_ adjustment: CoachAdjustment) {
        Analytics.shared.track(.coach_action_undone, ["type": String(describing: adjustment.type)])
        if adjustment.type == .weekRegenerated || adjustment.type == .deloadWeek {
            if let oldPlan = previousPlanBeforeWeekAction {
                currentPlan = oldPlan
                previousPlanBeforeWeekAction = nil
                weekAdjustmentActive = nil
                coachAdjustments.removeAll { $0.id == adjustment.id }
                persist()
            }
            return
        }
        guard var plan = currentPlan else { return }
        if actionManager.undoAdjustment(plan: &plan, adjustment: adjustment) {
            currentPlan = plan
            coachAdjustments.removeAll { $0.id == adjustment.id }
            persist()
        }
    }

    func adjustment(for dayId: String) -> CoachAdjustment? {
        coachAdjustments.last { $0.dayId == dayId }
    }

    func hasAdjustment(for dayId: String) -> Bool {
        coachAdjustments.contains { $0.dayId == dayId }
    }

    var hasWeekAdjustment: Bool {
        weekAdjustmentActive != nil
    }

    var weekAdjustment: CoachAdjustment? {
        coachAdjustments.last { $0.dayId == "week-all" }
    }

    // MARK: - Week-Level Coach Actions

    func previewWeekRegeneration() -> WeekRegenerationPreview? {
        guard let plan = currentPlan else { return nil }
        return actionManager.previewWeekRegeneration(
            plan: plan,
            profile: profile,
            muscleBalance: muscleBalance,
            recentSessions: workoutHistory,
            recoveryScore: recoveryScore
        )
    }

    func applyWeekRegeneration() {
        guard var plan = currentPlan else { return }
        Analytics.shared.track(.coach_action_applied, ["type": "week_regenerated"])
        if let (adjustment, oldPlan) = actionManager.applyWeekRegeneration(
            plan: &plan,
            profile: profile,
            muscleBalance: muscleBalance,
            recentSessions: workoutHistory,
            recoveryScore: recoveryScore
        ) {
            previousPlanBeforeWeekAction = oldPlan
            currentPlan = plan
            weekAdjustmentActive = .weekRegenerated
            coachAdjustments.append(adjustment)
            persist()
        }
    }

    func previewDeloadWeek() -> DeloadWeekPreview? {
        guard let plan = currentPlan else { return nil }
        return actionManager.previewDeloadWeek(plan: plan)
    }

    func applyDeloadWeek() {
        guard var plan = currentPlan else { return }
        Analytics.shared.track(.coach_action_applied, ["type": "deload_week"])
        if let (adjustment, oldPlan) = actionManager.applyDeloadWeek(plan: &plan) {
            previousPlanBeforeWeekAction = oldPlan
            currentPlan = plan
            weekAdjustmentActive = .deloadWeek
            coachAdjustments.append(adjustment)
            persist()
        }
    }

    var nextSessionDayId: String? {
        if let today = todaysWorkout { return today.id }
        if let next = nextScheduledWorkout(after: Date()) { return next.id }
        return currentPlan?.days.first(where: { !$0.isSkipped })?.id ?? currentPlan?.days.first?.id
    }

    var showPreWorkoutHandoff: Bool = false
    var handoffDay: WorkoutDay?

    func prepareWorkoutHandoff(day: WorkoutDay) {
        handoffDay = day
        showPreWorkoutHandoff = true
    }

    func confirmStartWorkout() {
        guard let day = handoffDay else { return }
        showPreWorkoutHandoff = false
        startWorkout(day: day)
        handoffDay = nil
    }

    func cancelHandoff() {
        showPreWorkoutHandoff = false
        handoffDay = nil
    }

    // MARK: - Scheduling

    func assignSchedule(dayId: String, weekday: Int?) {
        guard var plan = currentPlan,
              let idx = plan.days.firstIndex(where: { $0.id == dayId }) else { return }
        plan.days[idx].scheduledWeekday = weekday
        currentPlan = plan
        persist()
    }

    func skipDay(dayId: String) {
        guard var plan = currentPlan,
              let idx = plan.days.firstIndex(where: { $0.id == dayId }) else { return }
        plan.days[idx].isSkipped.toggle()
        let event: AnalyticsEvent = plan.days[idx].isSkipped ? .workout_skipped : .workout_unskipped
        currentPlan = plan
        persist()
        Analytics.shared.track(event, ["day_id": dayId])
    }

    func moveDayToNext(dayId: String) {
        guard var plan = currentPlan,
              let idx = plan.days.firstIndex(where: { $0.id == dayId }) else { return }
        let current = plan.days[idx].scheduledWeekday ?? (Calendar.current.component(.weekday, from: Date()))
        plan.days[idx].scheduledWeekday = (current % 7) + 1
        currentPlan = plan
        persist()
        Analytics.shared.track(.workout_moved, ["day_id": dayId])
    }

    func autoScheduleDays() {
        guard var plan = currentPlan else { return }
        let preferred = profile.preferredTrainingDays.isEmpty
            ? defaultTrainingDays(count: plan.days.count)
            : Array(profile.preferredTrainingDays.prefix(plan.days.count))
        for i in plan.days.indices {
            if i < preferred.count {
                plan.days[i].scheduledWeekday = preferred[i]
            }
        }
        currentPlan = plan
        persist()
        Analytics.shared.track(.auto_schedule_used, ["days": String(plan.days.count)])
    }

    private func defaultTrainingDays(count: Int) -> [Int] {
        switch count {
        case 1: return [2]
        case 2: return [2, 5]
        case 3: return [2, 4, 6]
        case 4: return [2, 3, 5, 6]
        case 5: return [2, 3, 4, 5, 6]
        case 6: return [2, 3, 4, 5, 6, 7]
        default: return Array(2...min(7, count + 1))
        }
    }

    func weekdayName(_ weekday: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let symbols = formatter.shortWeekdaySymbols ?? ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let idx = (weekday - 1) % 7
        return symbols[idx]
    }

    func fullWeekdayName(_ weekday: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        let symbols = formatter.weekdaySymbols ?? ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let idx = (weekday - 1) % 7
        return symbols[idx]
    }

    var scheduledTodayWorkout: WorkoutDay? {
        guard let plan = currentPlan else { return nil }
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        return plan.days.first { $0.scheduledWeekday == todayWeekday && !$0.isSkipped }
    }

    // MARK: - Prescription Intelligence

    func exercisePrescription(for planned: PlannedExercise, in day: WorkoutDay, index: Int) -> ExercisePrescription {
        let exercise = library.exercise(byId: planned.exerciseId)
        let role = classifyRole(planned, index: index, day: day)
        let suggestion = loadSuggestion(for: planned.exerciseId, planned: planned)
        let guidance = nextSessionGuidance(for: planned.exerciseId)
        let progression = progressionStates.first(where: { $0.exerciseId == planned.exerciseId })

        let whyThisExercise = buildWhyExercise(exercise: exercise, role: role, day: day)
        let whySetsReps = buildWhySetsReps(planned: planned, exercise: exercise)
        let whyWeight = buildWhyWeight(suggestion: suggestion, exercise: exercise)
        let whyEffort = buildWhyEffort(planned: planned)
        let progressionNote = buildProgressionNote(guidance: guidance, progression: progression)

        return ExercisePrescription(
            role: role,
            whyThisExercise: whyThisExercise,
            whySetsReps: whySetsReps,
            whyWeight: whyWeight,
            whyEffort: whyEffort,
            progressionNote: progressionNote,
            suggestedWeight: suggestion?.formattedWeight,
            confidence: suggestion?.confidence,
            guidanceAction: guidance?.action,
            guidanceColor: guidance?.color ?? "steel"
        )
    }

    private func classifyRole(_ planned: PlannedExercise, index: Int, day: WorkoutDay) -> ExerciseRole {
        guard let exercise = library.exercise(byId: planned.exerciseId) else { return .accessory }
        if exercise.category == .compound && index < 2 { return .keyLift }
        if exercise.category == .compound { return .supportLift }
        if exercise.category == .warmup || exercise.category == .mobility { return .warmup }
        return .accessory
    }

    private func buildWhyExercise(exercise: Exercise?, role: ExerciseRole, day: WorkoutDay) -> String {
        guard let ex = exercise else { return "Selected for this session." }
        let muscles = day.focusMuscles.prefix(2).map(\.displayName).joined(separator: " & ")
        let levelNote = profile.trainingLevel == .beginner && ex.isBeginnerFriendly ? " Beginner-friendly movement." : ""
        let focusNote = profile.focusMuscles.contains(ex.primaryMuscle) ? " Prioritized based on your focus areas." : ""
        switch role {
        case .keyLift:
            return "Primary compound for \(muscles). Drives the most progressive overload this session.\(levelNote)\(focusNote)"
        case .supportLift:
            return "Secondary compound adding volume to \(muscles).\(levelNote)\(focusNote)"
        case .accessory:
            return "Isolation work targeting \(ex.primaryMuscle.displayName) to complete stimulus.\(focusNote)"
        case .warmup:
            return "Prepares muscles and joints for heavier work."
        case .saferSubstitute:
            return "Joint-friendly alternative selected for better recovery."
        }
    }

    private func buildWhySetsReps(planned: PlannedExercise, exercise: Exercise?) -> String {
        let level = profile.trainingLevel
        let goal = profile.goal
        var parts: [String] = []
        parts.append("\(planned.sets) sets × \(planned.reps) reps")
        switch goal {
        case .strength:
            parts.append("Lower reps build maximal strength.")
        case .muscleGain:
            parts.append("Moderate reps optimize hypertrophy stimulus.")
        case .fatLoss:
            parts.append("Higher reps increase metabolic demand.")
        case .endurance:
            parts.append("High reps build muscular endurance.")
        default:
            parts.append("Balanced rep range for general fitness.")
        }
        if level == .beginner {
            parts.append("Volume kept moderate for your experience level.")
        } else if level == .advanced {
            parts.append("Higher volume to continue driving adaptation.")
        }
        if currentPhase == .deload {
            parts.append("Reduced during deload week.")
        } else if currentPhase == .fatigueManagement {
            parts.append("Lowered to manage fatigue.")
        }
        return parts.joined(separator: " ")
    }

    private func buildWhyWeight(suggestion: StartingLoadEngine.LoadSuggestion?, exercise: Exercise?) -> String {
        guard let s = suggestion else { return "No weight data yet. Start light and build." }
        return "\(s.formattedWeight) — \(s.basis)."
    }

    private func buildWhyEffort(planned: PlannedExercise) -> String {
        guard let rpe = planned.rpe else { return "Train to a comfortable challenge. Stop 2-3 reps short of failure." }
        if rpe >= 9.0 {
            return "RPE \(Int(rpe)) — Near maximum effort. Last rep should be very difficult."
        } else if rpe >= 7.5 {
            return "RPE \(Int(rpe)) — Hard effort. Keep 1-2 reps in reserve."
        } else if rpe >= 6.0 {
            return "RPE \(Int(rpe)) — Moderate effort. Focus on quality movement."
        }
        return "RPE \(Int(rpe)) — Light effort. Warm-up intensity."
    }

    private func buildProgressionNote(guidance: NextSessionGuidance?, progression: ExerciseProgressionState?) -> String? {
        if let g = guidance {
            return "\(g.action) — \(g.detail)"
        }
        if let p = progression, !p.coachNote.isEmpty {
            return p.coachNote
        }
        return nil
    }

    // MARK: - Onboarding Impact

    func onboardingImpactSummary() -> [OnboardingImpact] {
        var impacts: [OnboardingImpact] = []

        impacts.append(OnboardingImpact(
            icon: profile.goal.symbolName,
            title: profile.goal.displayName,
            detail: goalImpactDetail(),
            color: "blue"
        ))

        impacts.append(OnboardingImpact(
            icon: "scalemass.fill",
            title: "\(String(format: "%.0f", profile.weightKg)) kg",
            detail: weightImpactDetail(),
            color: "green"
        ))

        let levelIcon: String = {
            switch profile.trainingLevel {
            case .beginner: return "leaf.fill"
            case .intermediate: return "bolt.fill"
            case .advanced: return "star.fill"
            }
        }()
        impacts.append(OnboardingImpact(
            icon: levelIcon,
            title: profile.trainingLevel.shortName,
            detail: levelImpactDetail(),
            color: "purple"
        ))

        impacts.append(OnboardingImpact(
            icon: "calendar",
            title: "\(profile.daysPerWeek) days/week",
            detail: scheduleImpactDetail(),
            color: "steel"
        ))

        if !profile.injuries.isEmpty {
            impacts.append(OnboardingImpact(
                icon: "cross.circle.fill",
                title: "\(profile.injuries.count) restriction\(profile.injuries.count == 1 ? "" : "s")",
                detail: "Exercises filtered to avoid \(profile.injuries.joined(separator: ", ")) aggravation.",
                color: "red"
            ))
        }

        if !profile.focusMuscles.isEmpty {
            let names = profile.focusMuscles.prefix(3).map(\.displayName).joined(separator: ", ")
            impacts.append(OnboardingImpact(
                icon: "scope",
                title: "Focus: \(names)",
                detail: "Extra volume and exercise priority for these muscle groups.",
                color: "cyan"
            ))
        }

        return impacts
    }

    private func goalImpactDetail() -> String {
        switch profile.goal {
        case .strength: return "Heavier loads, lower reps, longer rest. Compound-first programming."
        case .muscleGain: return "Moderate loads, higher volume, hypertrophy-optimized rep ranges."
        case .fatLoss: return "Higher reps, shorter rest, increased metabolic demand."
        case .endurance: return "High rep ranges, circuit-style structure, conditioning focus."
        default: return "Balanced programming across strength and endurance."
        }
    }

    private func weightImpactDetail() -> String {
        if let target = profile.targetWeightKg {
            let diff = target - profile.weightKg
            if diff > 0 {
                return "Starting load estimates calibrated to your body weight. Targeting +\(String(format: "%.0f", diff)) kg."
            } else if diff < 0 {
                return "Starting load estimates calibrated to your body weight. Targeting \(String(format: "%.0f", diff)) kg."
            }
        }
        return "Starting load estimates calibrated to your body weight."
    }

    private func levelImpactDetail() -> String {
        switch profile.trainingLevel {
        case .beginner: return "Simpler exercises, moderate volume, faster initial progression."
        case .intermediate: return "More exercise variety, structured periodization, balanced volume."
        case .advanced: return "Advanced techniques, higher volume, slower progression cycles."
        }
    }

    private func scheduleImpactDetail() -> String {
        guard let plan = currentPlan else { return "Split optimized for \(profile.daysPerWeek) training days." }
        return "\(plan.splitType) split — optimized for \(profile.daysPerWeek) days with \(profile.minutesPerSession)-minute sessions."
    }

    func sessionBriefing(for day: WorkoutDay) -> SessionBriefing {
        let adj = adjustment(for: day.id)
        let totalSets = day.exercises.reduce(0) { $0 + $1.sets }
        let compounds = day.exercises.filter { ex in
            guard let e = library.exercise(byId: ex.exerciseId) else { return false }
            return e.category == .compound
        }.count
        let isolations = day.exercises.count - compounds

        let avgRPE: Double = {
            let rpes = day.exercises.compactMap(\.rpe)
            guard !rpes.isEmpty else { return 7.0 }
            return rpes.reduce(0, +) / Double(rpes.count)
        }()

        let intensityLabel: String = {
            switch avgRPE {
            case 0..<6: return "Light"
            case 6..<7.5: return "Moderate"
            case 7.5..<8.5: return "Hard"
            default: return "Intense"
            }
        }()

        let coachNote: String? = {
            if let adj {
                switch adj.type {
                case .volumeReduced: return "Volume reduced for better recovery"
                case .exerciseSwapped: return "Exercise swapped for better fit"
                case .lighterSession: return "Lighter effort to manage fatigue"
                case .weekRegenerated: return "Week intelligently regenerated"
                case .deloadWeek: return "Deload week — reduced stress"
                }
            }
            return nil
        }()

        let dayExplanation = buildDayExplanation(day: day)

        return SessionBriefing(
            dayName: day.name,
            focusMuscles: day.focusMuscles,
            estimatedMinutes: day.estimatedMinutes,
            exerciseCount: day.exercises.count,
            totalSets: totalSets,
            compoundCount: compounds,
            isolationCount: isolations,
            intensityLabel: intensityLabel,
            avgRPE: avgRPE,
            recoveryScore: recoveryScore,
            recoveryStatus: recoveryStatus,
            phase: trainingPhaseState.currentPhase,
            coachNote: coachNote,
            hasCoachAdjustment: adj != nil,
            adjustmentType: adj?.type,
            warmupHint: day.warmupHint,
            dayExplanation: dayExplanation
        )
    }

    private func buildDayExplanation(day: WorkoutDay) -> String {
        let muscles = day.focusMuscles.prefix(3).map(\.displayName).joined(separator: ", ")
        let phase = trainingPhaseState.currentPhase
        switch phase {
        case .build:
            return "Building work capacity with \(muscles) focus. Establishing solid training rhythm."
        case .push:
            return "Pushing toward new performance levels on \(muscles). Progressive overload priority."
        case .fatigueManagement:
            return "Managing fatigue while maintaining \(muscles) stimulus. Controlled effort today."
        case .deload:
            return "Deload session for \(muscles). Lower stress to allow recovery and supercompensation."
        case .rebalance:
            return "Rebalancing focus on \(muscles) to address weak points and improve symmetry."
        }
    }

    // MARK: - Weekly Review

    func generateWeeklyReview() {
        weeklyReview = reviewGenerator.generate(
            profile: profile,
            workoutHistory: workoutHistory,
            progressEntries: progressEntries,
            personalRecords: personalRecords,
            muscleBalance: muscleBalance,
            currentPlan: currentPlan,
            recoveryScore: recoveryScore,
            streak: streak
        )
    }

    func openWeeklyReview() {
        generateWeeklyReview()
        showWeeklyReview = true
        Analytics.shared.track(.weekly_review_opened)
    }

    func dismissWeeklyReview() {
        showWeeklyReview = false
        weeklyReviewDismissed = true
        persist()
    }

    func applyReviewAction(_ action: ReviewAction) {
        Analytics.shared.track(.weekly_review_action_applied, ["type": String(describing: action.type)])
        switch action.type {
        case .keepAsIs:
            break
        case .regenerateWeek:
            applyWeekRegeneration()
        case .deloadWeek:
            applyDeloadWeek()
        case .reduceVolume:
            if let dayId = nextSessionDayId, let preview = previewVolumeReduction(for: dayId) {
                applyVolumeReduction(dayId: dayId, preview: preview)
            }
        case .rebalancePlan:
            applyWeekRegeneration()
        case .increaseFrequency:
            break
        }
        dismissWeeklyReview()
        refreshCoachingInsights()
    }

    var isWeeklyReviewReady: Bool {
        guard !weeklyReviewDismissed else { return false }
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let thisWeekSessions = workoutHistory.filter { $0.startTime > weekAgo && $0.isCompleted }
        return thisWeekSessions.count >= max(1, profile.daysPerWeek - 1)
    }

    var weeklyVolumeByMuscle: [(String, Double)] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let recentEntries = progressEntries.filter { $0.date > weekAgo }
        var totals: [String: Double] = [:]
        for entry in recentEntries {
            for (muscle, vol) in entry.muscleGroupVolume {
                totals[muscle, default: 0] += vol
            }
        }
        return totals.sorted { $0.value > $1.value }
    }

    // MARK: - Daily Readiness

    var hasCheckedInToday: Bool {
        guard let r = todaysReadiness else { return false }
        return Calendar.current.isDateInToday(r.date)
    }

    func submitReadiness(_ readiness: DailyReadiness) {
        todaysReadiness = readiness
        readinessHistory.insert(readiness, at: 0)
        defer { persist() }
        Analytics.shared.track(.readiness_logged, [
            "score": String(readiness.readinessScore),
            "bucket": readinessBucket
        ])

        coachResponse = dailyStateCoordinator.makeCoachResponse(for: readiness)
        refreshDailyState()
    }

    func refreshDailyState() {
        dailyStateCoordinator.refresh()
    }

    var effectiveRecoveryScore: Int {
        if let r = todaysReadiness {
            return (recoveryScore + r.readinessScore) / 2
        }
        return recoveryScore
    }

    // MARK: - Nutrition & Recovery Methods

    func refreshNutritionInsights() {
        nutritionCoordinator.refresh()
    }

    var todaysNutritionLog: DailyNutritionLog? {
        nutritionLogs.first { Calendar.current.isDateInToday($0.date) }
    }

    var todayProteinProgress: Double {
        guard nutritionTarget.proteinGrams > 0 else { return 0 }
        let logged = todaysNutritionLog?.proteinGrams ?? 0
        return min(1.0, Double(logged) / Double(nutritionTarget.proteinGrams))
    }

    var todayCalorieProgress: Double {
        guard nutritionTarget.calories > 0 else { return 0 }
        let logged = todaysNutritionLog?.calories ?? 0
        return min(1.0, Double(logged) / Double(nutritionTarget.calories))
    }

    var latestWeight: Double? {
        bodyWeightEntries.sorted { $0.date > $1.date }.first?.weightKg
    }

    var weightTrendDescription: String {
        let sorted = bodyWeightEntries.sorted { $0.date < $1.date }
        guard sorted.count >= 4 else { return "Not enough data" }
        let recent = sorted.suffix(3).map(\.weightKg).reduce(0, +) / 3.0
        let earlier = sorted.prefix(3).map(\.weightKg).reduce(0, +) / 3.0
        let diff = recent - earlier
        if abs(diff) < 0.3 { return "Stable" }
        return diff > 0 ? "Trending up" : "Trending down"
    }

    var averageSleepHours: Double {
        let last7 = sleepEntries.prefix(7)
        guard !last7.isEmpty else { return 0 }
        return last7.map(\.hoursSlept).reduce(0, +) / Double(last7.count)
    }

    var sleepQualityLabel: String {
        let avg = averageSleepHours
        if avg >= 7.5 { return "Good" }
        if avg >= 6.5 { return "Fair" }
        return "Poor"
    }

    func logNutrition(_ log: DailyNutritionLog) {
        if let idx = nutritionLogs.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: log.date) }) {
            nutritionLogs[idx] = log
        } else {
            nutritionLogs.insert(log, at: 0)
        }
        refreshNutritionInsights()
        persist()
        Analytics.shared.track(.nutrition_logged, [
            "calories": String(log.calories),
            "protein_g": String(log.proteinGrams)
        ])
    }

    func logBodyWeight(weight: Double, bodyFat: Double? = nil) {
        let entry = BodyWeightEntry(weightKg: weight, bodyFatPercent: bodyFat)
        bodyWeightEntries.insert(entry, at: 0)
        profile.weightKg = weight
        if let bf = bodyFat {
            profile.bodyFatPercentage = bf
        }
        refreshNutritionInsights()
        persist()
        Analytics.shared.track(.weight_logged, ["has_bf": bodyFat != nil ? "true" : "false"])
        if notificationSettings.healthKitSyncEnabled {
            Task { await HealthKitService.shared.saveBodyWeight(kg: weight) }
        }
    }

    func logSleep(hours: Double, quality: ReadinessLevel) {
        let entry = SleepEntry(hoursSlept: hours, quality: quality)
        sleepEntries.insert(entry, at: 0)
        refreshNutritionInsights()
        persist()
        Analytics.shared.track(.sleep_logged, [
            "hours": String(format: "%.1f", hours),
            "quality": String(describing: quality)
        ])
    }

    // MARK: - HealthKit

    func syncHealthKitOnEnable() async {
        let hk = HealthKitService.shared
        guard hk.authState == .authorized else { return }
        if let latest = await hk.readLatestBodyWeight() {
            let alreadyLogged = bodyWeightEntries.contains { Calendar.current.isDate($0.date, inSameDayAs: latest.date) }
            if !alreadyLogged {
                let entry = BodyWeightEntry(date: latest.date, weightKg: latest.kg, bodyFatPercent: nil)
                bodyWeightEntries.insert(entry, at: 0)
                profile.weightKg = latest.kg
                refreshNutritionInsights()
                persist()
            }
        }
        if let hours = await hk.readRecentSleepHours(days: 1) {
            let alreadyLogged = sleepEntries.contains { Calendar.current.isDateInToday($0.date) }
            if !alreadyLogged, hours >= 2 {
                let quality: ReadinessLevel = hours >= 7.5 ? .great : hours >= 6.5 ? .good : hours >= 5.5 ? .okay : .poor
                let entry = SleepEntry(hoursSlept: hours, quality: quality)
                sleepEntries.insert(entry, at: 0)
                refreshNutritionInsights()
                persist()
            }
        }
    }

    var nutritionCoachSummary: String {
        nutritionCoordinator.dailyNutritionSummary()
    }

    var readinessBasedRecoveryStatus: String {
        let score = effectiveRecoveryScore
        switch score {
        case 85...: return "Peak Readiness"
        case 70..<85: return "Well Prepared"
        case 55..<70: return "Moderate"
        case 40..<55: return "Low Energy"
        default: return "Rest Needed"
        }
    }

    var recoveryTrainingBridge: String {
        let avgSleep = averageSleepHours
        let proteinPct = todayProteinProgress
        let recovery = effectiveRecoveryScore
        let goal = nutritionTarget.nutritionGoal

        if avgSleep < 6.5 && recovery < 55 {
            return "Poor sleep is dragging recovery down. Consider lighter training until sleep improves."
        }
        if proteinPct < 0.5 && (goal == .leanBulk || goal == .muscleGain) {
            return "Protein far below target today. Your muscle-building stimulus needs fuel to convert to gains."
        }
        if avgSleep >= 7.5 && recovery >= 80 && proteinPct >= 0.7 {
            return "Sleep, recovery, and nutrition are all aligned. Great day to push your training."
        }
        if recovery < 50 {
            return "Recovery is low. Prioritize sleep and protein to get back on track for your next session."
        }
        if let summary = physiqueOutcome?.summary, !summary.isEmpty {
            return summary
        }
        if let pace = goalPace, !pace.isOnTrack {
            return "\(pace.headline) — adjust nutrition to better match your \(goal.displayName) goal."
        }
        return ""
    }

    var recoveryTrendData: [(date: Date, score: Int)] {
        let calendar = Calendar.current
        return (0..<14).reversed().compactMap { dayOffset -> (Date, Int)? in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { return nil }
            let sleepForDay = sleepEntries.first { calendar.isDate($0.date, inSameDayAs: date) }
            let readinessForDay = readinessHistory.first { calendar.isDate($0.date, inSameDayAs: date) }
            let workedOut = workoutHistory.contains { calendar.isDate($0.startTime, inSameDayAs: date) && $0.isCompleted }

            var score = 70
            if let sleep = sleepForDay {
                let sleepScore = sleep.hoursSlept >= 7.5 ? 90 : sleep.hoursSlept >= 6.5 ? 70 : 50
                score = (score + sleepScore) / 2
            }
            if let readiness = readinessForDay {
                score = (score + readiness.readinessScore) / 2
            }
            if workedOut {
                score = max(40, score - 10)
            }
            return (date, score)
        }
    }

    var weeklyNutritionAdherence: Double {
        let last7 = nutritionLogs.prefix(7)
        guard !last7.isEmpty else { return 0 }
        let proteinHits = last7.filter { Double($0.proteinGrams) / Double(max(1, nutritionTarget.proteinGrams)) >= 0.8 }.count
        return Double(proteinHits) / Double(last7.count)
    }

    // MARK: - Early-State Intelligence

    var dataMaturityTier: DataMaturityTier {
        let completed = totalCompletedWorkouts
        if completed == 0 { return .fresh }
        if completed == 1 { return .firstSession }
        if completed <= 3 { return .earlyWeek }
        return .established
    }

    var isEarlyStage: Bool { dataMaturityTier < .established }

    var earlyStateGuidance: EarlyStateGuidance? {
        let tier = dataMaturityTier
        switch tier {
        case .fresh:
            return EarlyStateGuidance(
                tier: tier,
                headline: "Let's lock in your baseline",
                message: "Your plan is built. Your first session is the starting point — STRQ calibrates from what you actually lift.",
                primaryAction: todaysWorkout == nil ? "Open your plan" : "Start your first session",
                unlocksNext: "First session unlocks real progression signals",
                icon: "sparkles"
            )
        case .firstSession:
            return EarlyStateGuidance(
                tier: tier,
                headline: "Baseline set. Build from here.",
                message: "Your first session is in. A few more and STRQ will start spotting progression, balance, and fatigue patterns.",
                primaryAction: "Log session 2",
                unlocksNext: "Progression signals unlock around session 3",
                icon: "chart.line.uptrend.xyaxis"
            )
        case .earlyWeek:
            return EarlyStateGuidance(
                tier: tier,
                headline: "Coach is calibrating",
                message: "A couple more sessions and your coach will start making sharper calls on load, reps, and recovery.",
                primaryAction: "Keep the week going",
                unlocksNext: "Weekly review unlocks after \(max(0, max(1, profile.daysPerWeek - 1) - weeklyStats.sessions)) more session\(max(0, max(1, profile.daysPerWeek - 1) - weeklyStats.sessions) == 1 ? "" : "s") this week",
                icon: "waveform.path.ecg"
            )
        case .established:
            return nil
        }
    }

    var hasEnoughDataForStrengthChart: Bool {
        let entries = strengthProgress
        guard entries.count >= 2 else { return false }
        // Require at least one anchor series to have two real data points.
        let benchPoints = entries.filter { $0.bench > 0 }.count
        let squatPoints = entries.filter { $0.squat > 0 }.count
        let deadPoints = entries.filter { $0.deadlift > 0 }.count
        let ohpPoints = entries.filter { $0.ohp > 0 }.count
        return [benchPoints, squatPoints, deadPoints, ohpPoints].contains { $0 >= 2 }
    }

    var hasEnoughDataForTrends: Bool {
        dataMaturityTier >= .established
    }

    var sessionsUntilReviewReady: Int {
        let needed = max(1, profile.daysPerWeek - 1)
        let have = weeklyStats.sessions
        return max(0, needed - have)
    }
}

nonisolated enum DataMaturityTier: Int, Sendable, Comparable {
    case fresh = 0
    case firstSession = 1
    case earlyWeek = 2
    case established = 3

    static func < (lhs: DataMaturityTier, rhs: DataMaturityTier) -> Bool { lhs.rawValue < rhs.rawValue }

    var label: String {
        switch self {
        case .fresh: return "Getting started"
        case .firstSession: return "First session logged"
        case .earlyWeek: return "Building your baseline"
        case .established: return "Signal locked in"
        }
    }
}

nonisolated struct EarlyStateGuidance: Sendable {
    let tier: DataMaturityTier
    let headline: String
    let message: String
    let primaryAction: String
    let unlocksNext: String?
    let icon: String
}

nonisolated struct ActiveWorkoutState: Codable, Sendable {
    var session: WorkoutSession
    var currentExerciseIndex: Int
    var currentSetIndex: Int
    var isResting: Bool
    var restTimeRemaining: Int
    var plannedExercises: [PlannedExercise]
}

enum OnboardingPhase {
    case form
    case generating
    case reveal
}

struct SessionBriefing {
    let dayName: String
    let focusMuscles: [MuscleGroup]
    let estimatedMinutes: Int
    let exerciseCount: Int
    let totalSets: Int
    let compoundCount: Int
    let isolationCount: Int
    let intensityLabel: String
    let avgRPE: Double
    let recoveryScore: Int
    let recoveryStatus: String
    let phase: TrainingPhase
    let coachNote: String?
    let hasCoachAdjustment: Bool
    let adjustmentType: CoachAdjustmentType?
    let warmupHint: String
    let dayExplanation: String
}
