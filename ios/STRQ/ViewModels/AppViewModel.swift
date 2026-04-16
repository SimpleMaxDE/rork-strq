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
    private let coachingEngine = CoachingEngine()
    private let actionManager = CoachActionManager()
    private let progressionEngine = ProgressionEngine()
    private let volumeEngine = SmartVolumeEngine()
    let startingLoadEngine = StartingLoadEngine()
    private let adaptiveEngine = AdaptivePrescriptionEngine()

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
    private let dailyCoachEngine = DailyCoachEngine()

    // MARK: - Nutrition & Recovery
    var nutritionTarget: NutritionTarget = NutritionTarget()
    var nutritionLogs: [DailyNutritionLog] = []
    var bodyWeightEntries: [BodyWeightEntry] = []
    var sleepEntries: [SleepEntry] = []
    var nutritionInsights: [NutritionCoachInsight] = []
    var goalPace: GoalPaceStatus?
    private let nutritionEngine = NutritionCoachEngine()

    private let persistence = PersistenceStore.shared
    private var isHydrating: Bool = false

    init() {
        self.profile = UserProfile()
        self.currentPlan = nil
        self.workoutHistory = []
        self.personalRecords = []
        self.progressEntries = []
        self.recommendations = []
        self.favoriteExerciseIds = []
        self.activeWorkout = nil

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
        } else if legacyOnboardingFlag {
            isHydrating = true
            self.hasCompletedOnboarding = true
            self.profile = DemoData.profile
            self.workoutHistory = DemoData.workoutHistory
            self.personalRecords = DemoData.personalRecords
            self.progressEntries = DemoData.progressEntries
            self.recommendations = DemoData.recommendations
            self.favoriteExerciseIds = Set(["barbell-bench-press", "pull-up", "barbell-squat", "romanian-deadlift", "lateral-raise"])
            self.trainingPhaseState = DemoData.trainingPhaseState
            self.progressionStates = DemoData.progressionStates
            self.nutritionTarget = DemoData.nutritionTarget
            self.nutritionLogs = DemoData.nutritionLogs
            self.bodyWeightEntries = DemoData.bodyWeightEntries
            self.sleepEntries = DemoData.sleepEntries
            self.currentPlan = PlanGenerator().generate(
                for: DemoData.profile,
                muscleBalance: DemoData.muscleBalance,
                recentSessions: DemoData.workoutHistory,
                recoveryScore: 78,
                phase: DemoData.trainingPhaseState.currentPhase
            )
            isHydrating = false
            refreshIntelligence()
            refreshNutritionInsights()
            refreshDailyState()
            persist()
        } else {
            self.hasCompletedOnboarding = false
            refreshDailyState()
        }
    }

    func persist() {
        guard !isHydrating else { return }
        let draft: ActiveWorkoutDraft? = activeWorkout.map { state in
            ActiveWorkoutDraft(
                session: state.session,
                currentExerciseIndex: state.currentExerciseIndex,
                currentSetIndex: state.currentSetIndex,
                plannedExercises: state.plannedExercises
            )
        }
        let snapshot = PersistedAppState(
            version: persistence.version,
            hasCompletedOnboarding: hasCompletedOnboarding,
            profile: profile,
            currentPlan: currentPlan,
            workoutHistory: workoutHistory,
            personalRecords: personalRecords,
            progressEntries: progressEntries,
            favoriteExerciseIds: Array(favoriteExerciseIds),
            progressionStates: progressionStates,
            trainingPhaseState: trainingPhaseState,
            coachAdjustments: coachAdjustments,
            appliedActionIds: Array(appliedActionIds),
            weekAdjustmentActive: weekAdjustmentActive,
            previousPlanBeforeWeekAction: previousPlanBeforeWeekAction,
            weeklyReviewDismissed: weeklyReviewDismissed,
            todaysReadiness: todaysReadiness,
            readinessHistory: readinessHistory,
            notificationSettings: notificationSettings,
            nutritionTarget: nutritionTarget,
            nutritionLogs: nutritionLogs,
            bodyWeightEntries: bodyWeightEntries,
            sleepEntries: sleepEntries,
            activeWorkoutDraft: draft
        )
        persistence.save(snapshot)
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
        workoutHistory = DemoData.workoutHistory
        personalRecords = DemoData.personalRecords
        progressEntries = DemoData.progressEntries
        trainingPhaseState = DemoData.trainingPhaseState
        progressionStates = DemoData.progressionStates
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
        nutritionTarget = nutritionEngine.computeTargets(profile: profile)
        if nutritionLogs.isEmpty { nutritionLogs = DemoData.nutritionLogs }
        if bodyWeightEntries.isEmpty { bodyWeightEntries = DemoData.bodyWeightEntries }
        if sleepEntries.isEmpty { sleepEntries = DemoData.sleepEntries }
        refreshDailyState()
        refreshNutritionInsights()
        persist()
    }

    func generatePlan() {
        currentPlan = PlanGenerator().generate(
            for: profile,
            muscleBalance: muscleBalance,
            recentSessions: workoutHistory,
            recoveryScore: recoveryScore,
            phase: trainingPhaseState.currentPhase
        )
        refreshPlanQuality()
        persist()
    }

    func refreshCoachingInsights() {
        let newInsights = coachingEngine.generateInsights(
            profile: profile,
            workoutHistory: workoutHistory,
            progressEntries: progressEntries,
            personalRecords: personalRecords,
            currentPlan: currentPlan,
            muscleBalance: muscleBalance,
            progressionStates: progressionStates,
            phase: trainingPhaseState.currentPhase,
            volumeLandmarks: volumeLandmarks
        )
        _dynamicInsights = newInsights.isEmpty ? DemoData.insights : newInsights

        let newRecs = coachingEngine.generateRecommendations(
            profile: profile,
            workoutHistory: workoutHistory,
            progressEntries: progressEntries,
            personalRecords: personalRecords,
            muscleBalance: muscleBalance,
            progressionStates: progressionStates,
            phase: trainingPhaseState.currentPhase
        )
        recommendations = newRecs.isEmpty ? DemoData.recommendations : newRecs
    }

    func refreshIntelligence() {
        refreshProgressionStates()
        refreshVolumeLandmarks()
        refreshBalanceInsights()
        refreshNextBestAction()
        refreshCoachingInsights()
        refreshPlanQuality()
    }

    private func refreshProgressionStates() {
        let exerciseIds = Set(workoutHistory.flatMap(\.exerciseLogs).map(\.exerciseId))
        progressionStates = exerciseIds.prefix(10).map { exId in
            if let existing = DemoData.progressionStates.first(where: { $0.exerciseId == exId }) {
                return existing
            }
            return progressionEngine.analyzeProgression(
                exerciseId: exId,
                sessions: workoutHistory,
                profile: profile,
                currentPhase: trainingPhaseState.currentPhase
            )
        }
    }

    private func refreshVolumeLandmarks() {
        volumeLandmarks = volumeEngine.volumeLandmarks(
            for: profile,
            muscleBalance: muscleBalance,
            sessions: workoutHistory
        )
        volumeGuidance = volumeEngine.weeklyVolumeGuidance(
            landmarks: volumeLandmarks,
            profile: profile,
            phase: trainingPhaseState.currentPhase
        )
    }

    private func refreshBalanceInsights() {
        balanceInsights = volumeEngine.analyzeBalance(
            muscleBalance: muscleBalance,
            profile: profile
        )
    }

    private func refreshNextBestAction() {
        nextBestAction = progressionEngine.computeNextBestAction(
            profile: profile,
            sessions: workoutHistory,
            recoveryScore: recoveryScore,
            muscleBalance: muscleBalance,
            progressionStates: progressionStates,
            phase: trainingPhaseState.currentPhase
        )
    }

    private func refreshPlanQuality() {
        guard let plan = currentPlan else { return }
        planQuality = progressionEngine.assessPlanQuality(
            plan: plan,
            profile: profile,
            muscleBalance: muscleBalance,
            recoveryScore: recoveryScore,
            progressionStates: progressionStates,
            phase: trainingPhaseState.currentPhase
        )
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
        coachingEngine.suggestExerciseReplacement(for: exercise, profile: profile, reason: reason)
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
        let exercise = library.exercise(byId: planned.exerciseId)
        let fallback = loadSuggestion(for: planned.exerciseId, planned: planned)?.suggestedWeight
        return adaptiveEngine.prescribe(
            planned: planned,
            exercise: exercise,
            sessions: workoutHistory,
            effectiveRecoveryScore: effectiveRecoveryScore,
            phase: currentPhase,
            fallbackSuggestedWeight: fallback
        )
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

    func startWorkout(day: WorkoutDay) {
        guard let plan = currentPlan else {
            ErrorReporter.shared.reportMessage("startWorkout called without plan", level: .warning)
            return
        }
        Analytics.shared.track(.workout_started, [
            "day": day.name,
            "exercises": String(day.exercises.count),
            "phase": String(describing: trainingPhaseState.currentPhase),
            "readiness": readinessBucket
        ])
        ErrorReporter.shared.breadcrumb("Workout started: \(day.name)", category: "training")
        let exerciseLogs = day.exercises.map { planned -> ExerciseLog in
            let today = todayPrescription(for: planned)
            let prefillWeight = today.suggestedWeight
            let setCount = max(1, today.suggestedSets)
            let sets = (1...setCount).map { SetLog(setNumber: $0, weight: prefillWeight) }
            return ExerciseLog(exerciseId: planned.exerciseId, sets: sets)
        }
        activeWorkout = ActiveWorkoutState(
            session: WorkoutSession(planId: plan.id, dayId: day.id, dayName: day.name, exerciseLogs: exerciseLogs),
            currentExerciseIndex: 0,
            currentSetIndex: 0,
            isResting: false,
            restTimeRemaining: 0,
            plannedExercises: day.exercises
        )
        persist()
    }

    func saveActiveWorkoutDraft() {
        persist()
    }

    func completeWorkout() {
        guard var workout = activeWorkout else {
            ErrorReporter.shared.reportMessage("completeWorkout called without active workout", level: .warning)
            return
        }
        workout.session.isCompleted = true
        workout.session.endTime = Date()
        workout.session.totalVolume = workout.session.exerciseLogs.reduce(0.0) { total, log in
            total + log.sets.filter(\.isCompleted).reduce(0.0) { $0 + $1.weight * Double($1.reps) }
        }
        workoutHistory.insert(workout.session, at: 0)

        let entry = ProgressEntry(
            date: Date(),
            totalSets: workout.session.exerciseLogs.flatMap(\.sets).filter(\.isCompleted).count,
            totalReps: workout.session.exerciseLogs.flatMap(\.sets).filter(\.isCompleted).reduce(0) { $0 + $1.reps },
            totalVolume: workout.session.totalVolume,
            workoutDuration: Int(Date().timeIntervalSince(workout.session.startTime) / 60)
        )
        progressEntries.insert(entry, at: 0)

        activeWorkout = nil
        refreshIntelligence()
        persist()
        Analytics.shared.track(.workout_completed, [
            "day": workout.session.dayName,
            "sets": String(entry.totalSets),
            "reps": String(entry.totalReps),
            "volume": String(Int(entry.totalVolume)),
            "duration_min": String(entry.workoutDuration)
        ])
        ErrorReporter.shared.breadcrumb("Workout completed: \(workout.session.dayName)", category: "training")
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
        let dayIndex = Calendar.current.component(.weekday, from: Date()) % plan.days.count
        return plan.days[dayIndex]
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
        return max(streakCount, DemoData.streak)
    }

    private var _dynamicInsights: [SmartInsight] = []
    var insights: [SmartInsight] {
        _dynamicInsights.isEmpty ? DemoData.insights : _dynamicInsights
    }
    var weeklyActivity: [DayActivity] { DemoData.weeklyActivity }
    var muscleBalance: [MuscleBalanceEntry] { DemoData.muscleBalance }
    var strengthProgress: [StrengthEntry] { DemoData.strengthProgress }

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
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
        let recentCount = workoutHistory.filter { $0.startTime > twoDaysAgo && $0.isCompleted }.count
        switch recentCount {
        case 0: return 95
        case 1: return 78
        case 2: return 55
        default: return 35
        }
    }

    var nextWorkout: WorkoutDay? {
        guard let plan = currentPlan else { return nil }
        let calendar = Calendar.current
        let tomorrowIndex = (calendar.component(.weekday, from: Date()) + 1) % plan.days.count
        return plan.days[tomorrowIndex]
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
        return actionManager.swapExerciseOptions(for: exerciseId, in: plan, dayId: dayId, profile: profile)
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
        todaysWorkout?.id ?? currentPlan?.days.first?.id
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

        let response = dailyCoachEngine.generateCoachResponse(
            readiness: readiness,
            recoveryScore: recoveryScore,
            todaysWorkout: todaysWorkout,
            recentSessions: workoutHistory,
            phase: currentPhase
        )
        coachResponse = response
        refreshDailyState()
    }

    func refreshDailyState() {
        let weeklyCompleted = weeklyStats.sessions
        dailyCoachMessage = dailyCoachEngine.dailyCoachMessage(
            readiness: todaysReadiness,
            recoveryScore: recoveryScore,
            streak: streak,
            weeklySessionsCompleted: weeklyCompleted,
            weeklySessionsPlanned: profile.daysPerWeek,
            phase: currentPhase,
            hasWorkoutToday: todaysWorkout != nil
        )
        refreshMomentum()
    }

    private func refreshMomentum() {
        let weeklyCompleted = weeklyStats.sessions
        let planned = profile.daysPerWeek
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        let daysIntoWeek = max(1, weekday - 1)
        let expectedByNow = (planned * daysIntoWeek) / 7

        let pace: WeeklyPace = {
            if weeklyCompleted == 0 { return .missed }
            if weeklyCompleted >= planned { return .ahead }
            if weeklyCompleted >= expectedByNow { return .onTrack }
            return .behind
        }()

        let fourWeeksAgo = calendar.date(byAdding: .day, value: -28, to: Date()) ?? Date()
        let monthSessions = workoutHistory.filter { $0.startTime > fourWeeksAgo && $0.isCompleted }.count
        let possibleSessions = planned * 4
        let consistency = possibleSessions > 0 ? min(100, (monthSessions * 100) / possibleSessions) : 0

        var recentWins: [String] = []
        let recentPRs = personalRecords.filter { $0.date > (calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()) }
        if !recentPRs.isEmpty {
            recentWins.append("\(recentPRs.count) new PR\(recentPRs.count == 1 ? "" : "s") this week")
        }
        if weeklyCompleted >= planned {
            recentWins.append("Weekly target completed")
        }
        if streak >= 7 {
            recentWins.append("\(streak)-day streak")
        }
        let progressing = progressionStates.filter { $0.plateauStatus == .progressing }.count
        if progressing >= 3 {
            recentWins.append("\(progressing) exercises progressing")
        }

        momentumData = MomentumData(
            currentStreak: streak,
            longestStreak: max(streak, 14),
            weeklyPace: pace,
            weeklySessionsCompleted: weeklyCompleted,
            weeklySessionsPlanned: planned,
            consistencyPercent: consistency,
            recentWins: recentWins
        )
    }

    var effectiveRecoveryScore: Int {
        if let r = todaysReadiness {
            return (recoveryScore + r.readinessScore) / 2
        }
        return recoveryScore
    }

    // MARK: - Nutrition & Recovery Methods

    func refreshNutritionInsights() {
        nutritionInsights = nutritionEngine.generateInsights(
            target: nutritionTarget,
            recentLogs: nutritionLogs,
            weightEntries: bodyWeightEntries,
            sleepEntries: sleepEntries,
            profile: profile,
            recoveryScore: recoveryScore
        )

        let last14Weights = bodyWeightEntries.filter {
            let days = Calendar.current.dateComponents([.day], from: $0.date, to: Date()).day ?? 0
            return days <= 14
        }.sorted { $0.date < $1.date }

        if last14Weights.count >= 3 {
            let first3Avg = last14Weights.prefix(3).map(\.weightKg).reduce(0, +) / 3.0
            let last3Avg = last14Weights.suffix(3).map(\.weightKg).reduce(0, +) / 3.0
            let weeklyChange = (last3Avg - first3Avg) / 2.0
            goalPace = nutritionEngine.goalPaceStatus(target: nutritionTarget, weeklyChange: weeklyChange)
        }
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

    var nutritionCoachSummary: String {
        nutritionEngine.dailyNutritionSummary(todayLog: todaysNutritionLog, target: nutritionTarget)
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
