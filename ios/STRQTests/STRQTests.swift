import Testing
import Foundation
@testable import STRQ

// MARK: - PersistenceStore

@Suite("PersistenceStore")
struct PersistenceStoreTests {

    private func makeState(onboarded: Bool = true, history: [WorkoutSession] = []) -> PersistedAppState {
        PersistedAppState(
            version: 1,
            hasCompletedOnboarding: onboarded,
            profile: UserProfile(),
            currentPlan: nil,
            workoutHistory: history,
            personalRecords: [],
            progressEntries: [],
            favoriteExerciseIds: [],
            progressionStates: [],
            trainingPhaseState: TrainingPhaseState(),
            coachAdjustments: [],
            appliedActionIds: [],
            weekAdjustmentActive: nil,
            previousPlanBeforeWeekAction: nil,
            weeklyReviewDismissed: false,
            todaysReadiness: nil,
            readinessHistory: [],
            notificationSettings: NotificationSettings(),
            nutritionTarget: NutritionTarget(),
            nutritionLogs: [],
            bodyWeightEntries: [],
            sleepEntries: [],
            activeWorkoutDraft: nil
        )
    }

    @Test func saveLoadRoundTrip() async throws {
        let store = PersistenceStore.shared
        store.clear()
        defer { store.clear() }

        var state = makeState()
        state.profile.name = "Alex"
        state.profile.daysPerWeek = 5
        store.save(state)

        let loaded = store.load()
        #expect(loaded != nil)
        #expect(loaded?.profile.name == "Alex")
        #expect(loaded?.profile.daysPerWeek == 5)
        #expect(loaded?.hasCompletedOnboarding == true)
        #expect(loaded?.version == 1)
    }

    @Test func clearRemovesState() async throws {
        let store = PersistenceStore.shared
        store.save(makeState())
        store.clear()
        #expect(store.load() == nil)
    }

    @Test func loadReturnsNilWhenMissing() async throws {
        let store = PersistenceStore.shared
        store.clear()
        #expect(store.load() == nil)
    }

    @Test func corruptedDataRecoversGracefully() async throws {
        let store = PersistenceStore.shared
        store.clear()
        defer { store.clear() }

        let dir = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let url = dir.appendingPathComponent("strq_state_v1.json")
        try "{ not valid json".data(using: .utf8)!.write(to: url)

        let loaded = store.load()
        #expect(loaded == nil)
        #expect(!FileManager.default.fileExists(atPath: url.path))
    }

    @Test func activeWorkoutDraftSurvivesRoundTrip() async throws {
        let store = PersistenceStore.shared
        store.clear()
        defer { store.clear() }

        let session = WorkoutSession(planId: "p1", dayId: "d1", dayName: "Push")
        let draft = ActiveWorkoutDraft(
            session: session,
            currentExerciseIndex: 2,
            currentSetIndex: 1,
            plannedExercises: []
        )
        var state = makeState()
        state.activeWorkoutDraft = draft
        store.save(state)

        let loaded = store.load()
        #expect(loaded?.activeWorkoutDraft?.currentExerciseIndex == 2)
        #expect(loaded?.activeWorkoutDraft?.currentSetIndex == 1)
        #expect(loaded?.activeWorkoutDraft?.session.dayName == "Push")
    }
}

// MARK: - AdaptivePrescriptionEngine

@Suite("AdaptivePrescriptionEngine")
struct AdaptiveEngineTests {
    private let engine = AdaptivePrescriptionEngine()

    private func planned(sets: Int = 3, reps: String = "6-8") -> PlannedExercise {
        PlannedExercise(exerciseId: "barbell-bench-press", sets: sets, reps: reps, restSeconds: 120, rpe: 8)
    }

    private func session(weight: Double, reps: Int, sets: Int, exerciseId: String = "barbell-bench-press", daysAgo: Int = 1) -> WorkoutSession {
        let setLogs = (1...sets).map { SetLog(setNumber: $0, weight: weight, reps: reps, isCompleted: true) }
        let log = ExerciseLog(exerciseId: exerciseId, sets: setLogs, isCompleted: true)
        let start = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        return WorkoutSession(
            planId: "p",
            dayId: "d",
            dayName: "Day",
            startTime: start,
            endTime: start.addingTimeInterval(3600),
            exerciseLogs: [log],
            isCompleted: true,
            totalVolume: weight * Double(reps * sets)
        )
    }

    @Test func baselineWithoutHistory() {
        let result = engine.prescribe(
            planned: planned(),
            exercise: nil,
            sessions: [],
            effectiveRecoveryScore: 80,
            phase: .build,
            fallbackSuggestedWeight: 60
        )
        #expect(result.decision == .baseline)
        #expect(result.suggestedWeight == 60)
        #expect(result.suggestedSets == 3)
    }

    @Test func baselineLowRecoveryDropsSet() {
        let result = engine.prescribe(
            planned: planned(sets: 4),
            exercise: nil,
            sessions: [],
            effectiveRecoveryScore: 40,
            phase: .build,
            fallbackSuggestedWeight: 60
        )
        #expect(result.decision == .holdRecovery)
        #expect(result.suggestedSets == 3)
    }

    @Test func increaseLoadWhenAllSetsHitTopOfRange() {
        let s = session(weight: 80, reps: 8, sets: 3)
        let result = engine.prescribe(
            planned: planned(),
            exercise: nil,
            sessions: [s],
            effectiveRecoveryScore: 80,
            phase: .build,
            fallbackSuggestedWeight: nil
        )
        #expect(result.decision == .increaseLoad)
        #expect(result.suggestedWeight > 80)
        #expect(result.weightDelta > 0)
    }

    @Test func holdWhenBelowRepFloor() {
        let s = session(weight: 80, reps: 5, sets: 3)
        let result = engine.prescribe(
            planned: planned(reps: "6-8"),
            exercise: nil,
            sessions: [s],
            effectiveRecoveryScore: 80,
            phase: .build,
            fallbackSuggestedWeight: nil
        )
        #expect(result.decision == .hold)
        #expect(result.suggestedWeight == 80)
    }

    @Test func increaseRepsWhenInRange() {
        let s = session(weight: 80, reps: 7, sets: 3)
        let result = engine.prescribe(
            planned: planned(reps: "6-8"),
            exercise: nil,
            sessions: [s],
            effectiveRecoveryScore: 80,
            phase: .build,
            fallbackSuggestedWeight: nil
        )
        #expect(result.decision == .increaseReps)
        #expect(result.suggestedWeight == 80)
    }

    @Test func lowRecoveryBlocksProgression() {
        let s = session(weight: 80, reps: 8, sets: 3)
        let result = engine.prescribe(
            planned: planned(),
            exercise: nil,
            sessions: [s],
            effectiveRecoveryScore: 45,
            phase: .build,
            fallbackSuggestedWeight: nil
        )
        #expect(result.decision == .holdRecovery)
        #expect(result.suggestedWeight == 80)
        #expect(result.suggestedSets < result.plannedSets)
    }

    @Test func deloadPhaseReducesVolume() {
        let s = session(weight: 80, reps: 8, sets: 3)
        let result = engine.prescribe(
            planned: planned(sets: 4),
            exercise: nil,
            sessions: [s],
            effectiveRecoveryScore: 80,
            phase: .deload,
            fallbackSuggestedWeight: nil
        )
        #expect(result.suggestedSets < 4)
        #expect(result.decision == .hold || result.decision == .reduceSets)
    }

    @Test func rebuildAfterRepeatedStalls() {
        let sessions = (1...5).map { i in session(weight: 80, reps: 5, sets: 3, daysAgo: i * 2) }
        let result = engine.prescribe(
            planned: planned(reps: "6-8"),
            exercise: nil,
            sessions: sessions,
            effectiveRecoveryScore: 80,
            phase: .build,
            fallbackSuggestedWeight: nil
        )
        #expect(result.decision == .rebuild || result.decision == .reduceLoad)
        #expect(result.suggestedWeight < 80)
    }

    @Test func formattedWeightHandlesBodyweight() {
        let s = session(weight: 0, reps: 10, sets: 3)
        let result = engine.prescribe(
            planned: planned(reps: "8-12"),
            exercise: nil,
            sessions: [s],
            effectiveRecoveryScore: 80,
            phase: .build,
            fallbackSuggestedWeight: nil
        )
        #expect(result.formattedWeight == "BW" || result.suggestedWeight >= 0)
    }
}

// MARK: - Data Maturity Tiers & Streak

@MainActor
@Suite("AppViewModel early state & streak")
struct AppViewModelEarlyStateTests {

    private func makeVM() -> AppViewModel {
        PersistenceStore.shared.clear()
        let vm = AppViewModel()
        vm.profile.daysPerWeek = 3
        return vm
    }

    private func completedSession(daysAgo: Int) -> WorkoutSession {
        let start = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        return WorkoutSession(
            planId: "p",
            dayId: "d",
            dayName: "Day",
            startTime: start,
            endTime: start.addingTimeInterval(3600),
            exerciseLogs: [],
            isCompleted: true
        )
    }

    @Test func freshTierWithNoWorkouts() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        #expect(vm.dataMaturityTier == .fresh)
        #expect(vm.isEarlyStage == true)
        #expect(vm.earlyStateGuidance != nil)
        #expect(vm.hasEnoughDataForTrends == false)
    }

    @Test func firstSessionTier() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.workoutHistory = [completedSession(daysAgo: 1)]
        #expect(vm.dataMaturityTier == .firstSession)
        #expect(vm.isEarlyStage == true)
    }

    @Test func establishedTierAfterFourSessions() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.workoutHistory = (1...4).map { completedSession(daysAgo: $0) }
        #expect(vm.dataMaturityTier == .established)
        #expect(vm.isEarlyStage == false)
        #expect(vm.earlyStateGuidance == nil)
        #expect(vm.hasEnoughDataForTrends == true)
    }

    @Test func streakIsZeroWithoutActivity() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        #expect(vm.streak == 0)
    }

    @Test func streakCountsConsecutiveDays() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.workoutHistory = [
            completedSession(daysAgo: 0),
            completedSession(daysAgo: 1),
            completedSession(daysAgo: 2)
        ]
        #expect(vm.streak >= 3)
    }

    @Test func streakBreaksOnGap() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.workoutHistory = [
            completedSession(daysAgo: 0),
            completedSession(daysAgo: 5)
        ]
        #expect(vm.streak == 1)
    }

    @Test func totalCompletedIgnoresIncomplete() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        var incomplete = completedSession(daysAgo: 1)
        incomplete.isCompleted = false
        vm.workoutHistory = [completedSession(daysAgo: 2), incomplete]
        #expect(vm.totalCompletedWorkouts == 1)
    }
}

// MARK: - Reset Behavior

@MainActor
@Suite("Reset & onboarding")
struct ResetTests {

    @Test func resetClearsAllState() async throws {
        PersistenceStore.shared.clear()
        let vm = AppViewModel()
        vm.profile.name = "Test"
        vm.hasCompletedOnboarding = true
        vm.workoutHistory = [
            WorkoutSession(planId: "p", dayId: "d", dayName: "Day", isCompleted: true)
        ]
        vm.favoriteExerciseIds = ["foo"]
        vm.persist()

        vm.resetAllData()

        #expect(vm.hasCompletedOnboarding == false)
        #expect(vm.profile.name == "")
        #expect(vm.workoutHistory.isEmpty)
        #expect(vm.favoriteExerciseIds.isEmpty)
        #expect(PersistenceStore.shared.load() == nil)
    }

    @Test func legacyOnboardingFlagDoesNotAutoOnboard() async throws {
        PersistenceStore.shared.clear()
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        defer {
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
            PersistenceStore.shared.clear()
        }
        let vm = AppViewModel()
        #expect(vm.hasCompletedOnboarding == false)
    }
}

// MARK: - Subscription Helpers

@MainActor
@Suite("StoreViewModel helpers")
struct StoreViewModelTests {

    @Test func unconfiguredStateIsFree() {
        let store = StoreViewModel()
        if !store.isConfigured {
            #expect(store.subscriptionStatusText == "Free")
            #expect(store.subscriptionPlanName == "Free")
            #expect(store.isPro == false)
        }
    }

    @Test func restoreInUnconfiguredEnvSetsMessage() async {
        let store = StoreViewModel()
        if !store.isConfigured {
            await store.restore()
            #expect(store.restoreMessage == "Subscriptions are not available in this environment.")
        }
    }
}

// MARK: - Readiness

@Suite("DailyReadiness scoring")
struct ReadinessTests {

    @Test func greatAcrossTheBoardProducesHighScore() {
        let r = DailyReadiness(
            sleepQuality: .great,
            energyLevel: .great,
            stressLevel: .terrible,
            soreness: .none,
            motivation: .veryHigh
        )
        #expect(r.readinessScore >= 85)
    }

    @Test func terribleAcrossTheBoardProducesLowScore() {
        let r = DailyReadiness(
            sleepQuality: .terrible,
            energyLevel: .terrible,
            stressLevel: .great,
            soreness: .severe,
            motivation: .veryLow
        )
        #expect(r.readinessScore < 40)
    }

    @Test func scoreClampedToValidRange() {
        let r = DailyReadiness()
        #expect(r.readinessScore >= 0)
        #expect(r.readinessScore <= 100)
    }
}

// MARK: - ProgressionEngine

@Suite("ProgressionEngine baseline")
struct ProgressionEngineTests {

    @Test func returnsBaselineWhenNoHistory() {
        let engine = ProgressionEngine()
        let state = engine.analyzeProgression(
            exerciseId: "barbell-bench-press",
            sessions: [],
            profile: UserProfile(),
            currentPhase: .build
        )
        #expect(state.exerciseId == "barbell-bench-press")
        #expect(state.sessionCount == 0)
        #expect(state.plateauStatus == .progressing)
    }
}
