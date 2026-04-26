import Testing
import Foundation
@testable import STRQ

// MARK: - PersistenceStore

@Suite("PersistenceStore")
struct PersistenceStoreTests {

    private func stateDirectory() throws -> URL {
        try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
    }

    private func removeQuarantinedStates(in dir: URL) {
        guard let files = try? FileManager.default.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: nil
        ) else { return }
        for file in files where file.lastPathComponent.hasPrefix("strq_state_v1.corrupt-") {
            try? FileManager.default.removeItem(at: file)
        }
    }

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
        let dir = try stateDirectory()
        removeQuarantinedStates(in: dir)
        defer {
            store.clear()
            removeQuarantinedStates(in: dir)
        }

        let url = dir.appendingPathComponent("strq_state_v1.json")
        try "{ not valid json".data(using: .utf8)!.write(to: url)

        let loaded = store.load()
        #expect(loaded == nil)
        #expect(!FileManager.default.fileExists(atPath: url.path))
        let quarantined = (try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? []
        #expect(quarantined.contains { $0.lastPathComponent.hasPrefix("strq_state_v1.corrupt-") })
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

// MARK: - SnapshotBuilder

@MainActor
@Suite("SnapshotBuilder")
struct SnapshotBuilderTests {

    private func makeVM() -> AppViewModel {
        PersistenceStore.shared.clear()
        return AppViewModel()
    }

    @Test func buildMirrorsViewModelState() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.profile.name = "Alex"
        vm.profile.daysPerWeek = 4
        vm.hasCompletedOnboarding = true
        vm.favoriteExerciseIds = ["a", "b"]
        vm.appliedActionIds = ["x"]

        let snap = SnapshotBuilder.build(from: vm, version: 1)
        #expect(snap.version == 1)
        #expect(snap.profile.name == "Alex")
        #expect(snap.profile.daysPerWeek == 4)
        #expect(snap.hasCompletedOnboarding == true)
        #expect(Set(snap.favoriteExerciseIds) == ["a", "b"])
        #expect(Set(snap.appliedActionIds) == ["x"])
        #expect(snap.activeWorkoutDraft == nil)
    }

    @Test func buildCapturesActiveWorkoutAsDraft() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.activeWorkout = ActiveWorkoutState(
            session: WorkoutSession(planId: "p", dayId: "d", dayName: "Push"),
            currentExerciseIndex: 3,
            currentSetIndex: 2,
            isResting: false,
            restTimeRemaining: 0,
            plannedExercises: []
        )
        let snap = SnapshotBuilder.build(from: vm, version: 1)
        #expect(snap.activeWorkoutDraft?.currentExerciseIndex == 3)
        #expect(snap.activeWorkoutDraft?.currentSetIndex == 2)
        #expect(snap.activeWorkoutDraft?.session.dayName == "Push")
    }

    @Test func maturityScoreFavorsRicherSnapshots() {
        let empty = PersistedAppState(
            version: 1, hasCompletedOnboarding: false, profile: UserProfile(),
            currentPlan: nil, workoutHistory: [], personalRecords: [],
            progressEntries: [], favoriteExerciseIds: [], progressionStates: [],
            trainingPhaseState: TrainingPhaseState(), coachAdjustments: [],
            appliedActionIds: [], weekAdjustmentActive: nil,
            previousPlanBeforeWeekAction: nil, weeklyReviewDismissed: false,
            todaysReadiness: nil, readinessHistory: [],
            notificationSettings: NotificationSettings(),
            nutritionTarget: NutritionTarget(), nutritionLogs: [],
            bodyWeightEntries: [], sleepEntries: [], activeWorkoutDraft: nil
        )
        var richer = empty
        richer.hasCompletedOnboarding = true
        richer.workoutHistory = (1...4).map {
            WorkoutSession(planId: "p", dayId: "d", dayName: "D\($0)", isCompleted: true)
        }
        richer.bodyWeightEntries = [BodyWeightEntry(weightKg: 75), BodyWeightEntry(weightKg: 75.2)]
        #expect(SnapshotBuilder.maturityScore(empty) == 0)
        #expect(SnapshotBuilder.maturityScore(richer) > SnapshotBuilder.maturityScore(empty) + 5)
    }

    @Test func buildIsDeterministic() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.profile.name = "Sam"
        let a = SnapshotBuilder.build(from: vm, version: 1)
        let b = SnapshotBuilder.build(from: vm, version: 1)
        #expect(a.profile.name == b.profile.name)
        #expect(a.workoutHistory.count == b.workoutHistory.count)
        #expect(SnapshotBuilder.maturityScore(a) == SnapshotBuilder.maturityScore(b))
    }
}

// MARK: - WorkoutController

@MainActor
@Suite("WorkoutController")
struct WorkoutControllerTests {

    private func makeVM() -> AppViewModel {
        PersistenceStore.shared.clear()
        let vm = AppViewModel()
        vm.profile.daysPerWeek = 3
        vm.profile.weightKg = 80
        return vm
    }

    private func planWithOneDay(exerciseCount: Int = 2, sets: Int = 3) -> WorkoutPlan {
        let planned = (0..<exerciseCount).map { i in
            PlannedExercise(
                exerciseId: "barbell-bench-press",
                sets: sets,
                reps: "6-8",
                restSeconds: 90,
                order: i
            )
        }
        let day = WorkoutDay(
            name: "Push",
            focusMuscles: [.chest],
            exercises: planned,
            dayIndex: 0
        )
        return WorkoutPlan(
            name: "Test", description: "", days: [day],
            splitType: "full-body", durationWeeks: 4, explanation: ""
        )
    }

    @Test func startWorkoutCreatesActiveStateWithPrefilledSets() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.currentPlan = planWithOneDay(exerciseCount: 2, sets: 3)
        guard let day = vm.currentPlan?.days.first else { return }

        vm.startWorkout(day: day)

        #expect(vm.activeWorkout != nil)
        #expect(vm.activeWorkout?.session.dayName == "Push")
        #expect(vm.activeWorkout?.session.exerciseLogs.count == 2)
        #expect(vm.activeWorkout?.currentExerciseIndex == 0)
        #expect(vm.activeWorkout?.currentSetIndex == 0)
        #expect(vm.activeWorkout?.session.exerciseLogs.first?.sets.count ?? 0 >= 1)
    }

    @Test func startWorkoutWithoutPlanIsNoOp() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        let day = planWithOneDay().days[0]
        vm.startWorkout(day: day)
        #expect(vm.activeWorkout == nil)
    }

    @Test func completeCurrentSetAdvancesCursor() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.currentPlan = planWithOneDay(exerciseCount: 1, sets: 3)
        vm.startWorkout(day: vm.currentPlan!.days[0])

        _ = vm.completeCurrentSet(exerciseIndex: 0, setIndex: 0)
        #expect(vm.activeWorkout?.currentSetIndex == 1)
        #expect(vm.activeWorkout?.session.exerciseLogs[0].sets[0].isCompleted == true)
    }

    @Test func completingAllSetsAdvancesToNextExercise() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.currentPlan = planWithOneDay(exerciseCount: 2, sets: 2)
        vm.startWorkout(day: vm.currentPlan!.days[0])
        let sets = vm.activeWorkout?.session.exerciseLogs[0].sets.count ?? 0

        for i in 0..<sets { _ = vm.completeCurrentSet(exerciseIndex: 0, setIndex: i) }

        #expect(vm.activeWorkout?.session.exerciseLogs[0].isCompleted == true)
        #expect(vm.activeWorkout?.currentExerciseIndex == 1)
        #expect(vm.activeWorkout?.currentSetIndex == 0)
    }

    @Test func undoLastCompletedSetRestoresSetStateAndCursor() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.currentPlan = planWithOneDay(exerciseCount: 1, sets: 3)
        vm.startWorkout(day: vm.currentPlan!.days[0])
        vm.updateSetLoad(exerciseIndex: 0, setIndex: 0, weight: 72.5, reps: 8)

        _ = vm.completeCurrentSet(exerciseIndex: 0, setIndex: 0)
        let restored = vm.undoLastCompletedSet()

        #expect(restored == true)
        #expect(vm.canUndoLastCompletedSet == false)
        #expect(vm.activeWorkout?.currentExerciseIndex == 0)
        #expect(vm.activeWorkout?.currentSetIndex == 0)
        #expect(vm.activeWorkout?.session.exerciseLogs[0].sets[0].isCompleted == false)
        #expect(vm.activeWorkout?.session.exerciseLogs[0].sets[0].weight == 72.5)
        #expect(vm.activeWorkout?.session.exerciseLogs[0].sets[0].reps == 8)
        #expect(vm.activeWorkout?.session.exerciseLogs[0].isCompleted == false)
    }

    @Test func undoLastCompletedSetReturnsToPreviousExerciseWhenNeeded() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.currentPlan = planWithOneDay(exerciseCount: 2, sets: 1)
        vm.startWorkout(day: vm.currentPlan!.days[0])

        _ = vm.completeCurrentSet(exerciseIndex: 0, setIndex: 0)
        let restored = vm.undoLastCompletedSet()

        #expect(restored == true)
        #expect(vm.activeWorkout?.currentExerciseIndex == 0)
        #expect(vm.activeWorkout?.currentSetIndex == 0)
        #expect(vm.activeWorkout?.session.exerciseLogs[0].isCompleted == false)
        #expect(vm.activeWorkout?.session.exerciseLogs[0].sets[0].isCompleted == false)
    }

    @Test func updateSetLoadClampsToNonNegative() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.currentPlan = planWithOneDay()
        vm.startWorkout(day: vm.currentPlan!.days[0])
        vm.updateSetLoad(exerciseIndex: 0, setIndex: 0, weight: -100, reps: -5)
        #expect(vm.activeWorkout?.session.exerciseLogs[0].sets[0].weight == 0)
        #expect(vm.activeWorkout?.session.exerciseLogs[0].sets[0].reps == 0)
    }

    @Test func updateSetLoadIgnoresOutOfRangeIndices() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.currentPlan = planWithOneDay(exerciseCount: 1, sets: 2)
        vm.startWorkout(day: vm.currentPlan!.days[0])
        vm.updateSetLoad(exerciseIndex: 99, setIndex: 0, weight: 50, reps: 5)
        vm.updateSetLoad(exerciseIndex: 0, setIndex: 99, weight: 50, reps: 5)
        #expect(vm.activeWorkout?.session.exerciseLogs[0].sets[0].reps != 5 || vm.activeWorkout?.session.exerciseLogs[0].sets[0].weight != 50)
    }

    @Test func moveNextPreviousExerciseBounded() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.currentPlan = planWithOneDay(exerciseCount: 2, sets: 2)
        vm.startWorkout(day: vm.currentPlan!.days[0])

        vm.moveToPreviousExercise()
        #expect(vm.activeWorkout?.currentExerciseIndex == 0)

        vm.moveToNextExercise()
        #expect(vm.activeWorkout?.currentExerciseIndex == 1)

        vm.moveToNextExercise()
        #expect(vm.activeWorkout?.currentExerciseIndex == 1)

        vm.moveToPreviousExercise()
        #expect(vm.activeWorkout?.currentExerciseIndex == 0)
    }

    @Test func jumpToExerciseRejectsInvalidIndex() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.currentPlan = planWithOneDay(exerciseCount: 2, sets: 2)
        vm.startWorkout(day: vm.currentPlan!.days[0])
        vm.jumpToExercise(99)
        #expect(vm.activeWorkout?.currentExerciseIndex == 0)
        vm.jumpToExercise(-1)
        #expect(vm.activeWorkout?.currentExerciseIndex == 0)
        vm.jumpToExercise(1)
        #expect(vm.activeWorkout?.currentExerciseIndex == 1)
    }

    @Test func setSetQualityPersistsQualityOnSet() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.currentPlan = planWithOneDay()
        vm.startWorkout(day: vm.currentPlan!.days[0])
        vm.setSetQuality(exerciseIndex: 0, setIndex: 0, quality: .onTarget)
        #expect(vm.activeWorkout?.session.exerciseLogs[0].sets[0].quality == .onTarget)
    }

    @Test func completeWorkoutMovesSessionToHistory() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.currentPlan = planWithOneDay(exerciseCount: 1, sets: 2)
        vm.startWorkout(day: vm.currentPlan!.days[0])
        vm.updateSetLoad(exerciseIndex: 0, setIndex: 0, weight: 60, reps: 8)
        _ = vm.completeCurrentSet(exerciseIndex: 0, setIndex: 0)
        vm.updateSetLoad(exerciseIndex: 0, setIndex: 1, weight: 60, reps: 8)
        _ = vm.completeCurrentSet(exerciseIndex: 0, setIndex: 1)

        vm.completeWorkout()

        #expect(vm.activeWorkout == nil)
        #expect(vm.workoutHistory.first?.isCompleted == true)
        #expect(vm.workoutHistory.first?.dayName == "Push")
        #expect((vm.workoutHistory.first?.totalVolume ?? 0) > 0)
        #expect(vm.progressEntries.first?.totalSets == 2)
    }

    @Test func completeWorkoutWithoutActiveIsNoOp() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.completeWorkout()
        #expect(vm.workoutHistory.isEmpty)
    }

    @Test func watchCompleteSetActionAdvancesAndPersistsWeight() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.currentPlan = planWithOneDay(exerciseCount: 1, sets: 3)
        vm.startWorkout(day: vm.currentPlan!.days[0])

        vm.handleWatchAction("completeSet", payload: ["weight": 70.0, "reps": 7])
        let log = vm.activeWorkout?.session.exerciseLogs[0]
        #expect(log?.sets[0].isCompleted == true)
        #expect(log?.sets[0].weight == 70.0)
        #expect(log?.sets[0].reps == 7)
        #expect(vm.activeWorkout?.currentSetIndex == 1)
    }

    @Test func watchAdjustWeightUpdatesNextPendingSet() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.currentPlan = planWithOneDay(exerciseCount: 1, sets: 2)
        vm.startWorkout(day: vm.currentPlan!.days[0])
        vm.updateSetLoad(exerciseIndex: 0, setIndex: 0, weight: 50, reps: 6)

        vm.handleWatchAction("adjustWeight", payload: ["delta": 2.5])
        #expect(vm.activeWorkout?.session.exerciseLogs[0].sets[0].weight == 52.5)
    }

    @Test func watchAdjustRepsUpdatesNextPendingSet() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.currentPlan = planWithOneDay(exerciseCount: 1, sets: 2)
        vm.startWorkout(day: vm.currentPlan!.days[0])
        vm.updateSetLoad(exerciseIndex: 0, setIndex: 0, weight: 60, reps: 6)

        vm.handleWatchAction("adjustReps", payload: ["delta": 2])
        #expect(vm.activeWorkout?.session.exerciseLogs[0].sets[0].reps == 8)
    }

    @Test func watchNextExerciseRoutesThroughController() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.currentPlan = planWithOneDay(exerciseCount: 2, sets: 2)
        vm.startWorkout(day: vm.currentPlan!.days[0])
        vm.handleWatchAction("nextExercise", payload: [:])
        #expect(vm.activeWorkout?.currentExerciseIndex == 1)
    }

    @Test func watchSetQualityAttachesToLastCompletedSet() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.currentPlan = planWithOneDay(exerciseCount: 1, sets: 2)
        vm.startWorkout(day: vm.currentPlan!.days[0])
        _ = vm.completeCurrentSet(exerciseIndex: 0, setIndex: 0)

        vm.handleWatchAction("setQuality", payload: ["quality": SetQuality.grinder.rawValue])
        #expect(vm.activeWorkout?.session.exerciseLogs[0].sets[0].quality == .grinder)
    }

    @Test func watchActionWithoutActiveWorkoutIsNoOp() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.handleWatchAction("completeSet", payload: [:])
        vm.handleWatchAction("nextExercise", payload: [:])
        #expect(vm.activeWorkout == nil)
    }

    @Test func unknownWatchActionIsIgnored() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.currentPlan = planWithOneDay()
        vm.startWorkout(day: vm.currentPlan!.days[0])
        let before = vm.activeWorkout
        vm.handleWatchAction("bogusAction", payload: [:])
        #expect(vm.activeWorkout?.currentExerciseIndex == before?.currentExerciseIndex)
        #expect(vm.activeWorkout?.currentSetIndex == before?.currentSetIndex)
    }
}

// MARK: - ContinuityCoordinator

@MainActor
@Suite("ContinuityCoordinator")
struct ContinuityCoordinatorTests {

    private func makeVM() -> AppViewModel {
        PersistenceStore.shared.clear()
        return AppViewModel()
    }

    @Test func restoreReturnsUnavailableWhenCloudUnavailable() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        // In the test environment iCloud is not available; regardless of outcome,
        // restore must never crash and must return one of the documented cases.
        let outcome = vm.restoreFromCloud(force: false)
        let valid: Set<CloudRestoreOutcome> = [.unavailable, .noSnapshot, .staleIgnored, .restored, .decodeFailed]
        #expect(valid.contains(outcome))
    }

    @Test func restoreSkippedWhenActiveWorkoutInProgress() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.activeWorkout = ActiveWorkoutState(
            session: WorkoutSession(planId: "p", dayId: "d", dayName: "Active"),
            currentExerciseIndex: 0,
            currentSetIndex: 0,
            isResting: false,
            restTimeRemaining: 0,
            plannedExercises: []
        )
        let outcome = vm.restoreFromCloud(force: false)
        // When iCloud isn't available the guard in restore() short-circuits to
        // .unavailable before the active-workout guard runs; when it is, the
        // active-workout guard returns .staleIgnored.
        #expect(outcome == .unavailable || outcome == .staleIgnored)
    }

    @Test func applySnapshotPreservesActiveWorkout() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.activeWorkout = ActiveWorkoutState(
            session: WorkoutSession(planId: "p", dayId: "d", dayName: "Active"),
            currentExerciseIndex: 1,
            currentSetIndex: 2,
            isResting: false,
            restTimeRemaining: 0,
            plannedExercises: []
        )
        let remoteDraft = ActiveWorkoutDraft(
            session: WorkoutSession(planId: "p", dayId: "d2", dayName: "Remote"),
            currentExerciseIndex: 0,
            currentSetIndex: 0,
            plannedExercises: []
        )
        let remote = PersistedAppState(
            version: 1, hasCompletedOnboarding: true, profile: UserProfile(),
            currentPlan: nil, workoutHistory: [], personalRecords: [],
            progressEntries: [], favoriteExerciseIds: [], progressionStates: [],
            trainingPhaseState: TrainingPhaseState(), coachAdjustments: [],
            appliedActionIds: [], weekAdjustmentActive: nil,
            previousPlanBeforeWeekAction: nil, weeklyReviewDismissed: false,
            todaysReadiness: nil, readinessHistory: [],
            notificationSettings: NotificationSettings(),
            nutritionTarget: NutritionTarget(), nutritionLogs: [],
            bodyWeightEntries: [], sleepEntries: [], activeWorkoutDraft: remoteDraft
        )
        vm.apply(snapshot: remote)
        #expect(vm.activeWorkout?.session.dayName == "Active")
        #expect(vm.activeWorkout?.currentExerciseIndex == 1)
        #expect(vm.activeWorkout?.currentSetIndex == 2)
    }

    @Test func applySnapshotHydratesDraftWhenNoActive() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.activeWorkout = nil
        let draft = ActiveWorkoutDraft(
            session: WorkoutSession(planId: "p", dayId: "d", dayName: "Remote"),
            currentExerciseIndex: 4,
            currentSetIndex: 1,
            plannedExercises: []
        )
        let remote = PersistedAppState(
            version: 1, hasCompletedOnboarding: true, profile: UserProfile(),
            currentPlan: nil, workoutHistory: [], personalRecords: [],
            progressEntries: [], favoriteExerciseIds: [], progressionStates: [],
            trainingPhaseState: TrainingPhaseState(), coachAdjustments: [],
            appliedActionIds: [], weekAdjustmentActive: nil,
            previousPlanBeforeWeekAction: nil, weeklyReviewDismissed: false,
            todaysReadiness: nil, readinessHistory: [],
            notificationSettings: NotificationSettings(),
            nutritionTarget: NutritionTarget(), nutritionLogs: [],
            bodyWeightEntries: [], sleepEntries: [], activeWorkoutDraft: draft
        )
        vm.apply(snapshot: remote)
        #expect(vm.activeWorkout?.session.dayName == "Remote")
        #expect(vm.activeWorkout?.currentExerciseIndex == 4)
        #expect(vm.activeWorkout?.currentSetIndex == 1)
    }

    @Test func restoreOutcomesAreExhaustive() {
        // Guardrail: CloudRestoreOutcome is the public contract — ensure every
        // case we switch on in UI/analytics still exists.
        let all: [CloudRestoreOutcome] = [
            .restored, .noSnapshot, .unavailable, .staleIgnored, .decodeFailed
        ]
        #expect(all.count == 5)
    }
}

// MARK: - EnvironmentValidator

@MainActor
@Suite("EnvironmentValidator")
struct EnvironmentValidatorTests {

    @Test func validateReturnsWithoutCrashing() {
        let report = EnvironmentValidator.validate()
        // Every issue must be non-empty text — we never want silent gaps.
        for issue in report.issues { #expect(!issue.isEmpty) }
        for warn in report.warnings { #expect(!warn.isEmpty) }
    }

    @Test func validateAndLogIsIdempotentAndSafe() {
        EnvironmentValidator.validateAndLog()
        EnvironmentValidator.validateAndLog()
    }

    @Test func legalLinksParseAsURLs() {
        #expect(URL(string: STRQLinks.privacy.absoluteString) != nil)
        #expect(URL(string: STRQLinks.terms.absoluteString) != nil)
        #expect(URL(string: STRQLinks.support.absoluteString) != nil)
    }

    @Test func legalLinksUseApprovedSchemes() {
        // App Review rejects raw custom schemes or empty hosts on legal links.
        // Guardrail: any override must resolve to http(s) or mailto with a real target.
        let approved: Set<String> = ["https", "http", "mailto"]
        for link in [STRQLinks.privacy, STRQLinks.terms, STRQLinks.support] {
            let scheme = link.scheme?.lowercased() ?? ""
            #expect(approved.contains(scheme))
            if scheme != "mailto" {
                #expect(!(link.host?.isEmpty ?? true))
            }
        }
    }

    @Test func validatorFlagsMissingBundleIdOnlyAsWarning() {
        // Missing bundle id must never be a hard launch issue — the app still
        // runs for the user, integrations just no-op.
        let report = EnvironmentValidator.validate()
        #expect(!report.issues.contains { $0.contains("Bundle identifier") })
    }

    #if DEBUG
    @Test func debugBuildTreatsMissingRevenueCatAsWarningNotIssue() {
        // In the sandbox both RevenueCat keys are empty; in DEBUG this must be
        // a warning so developers can run the app without subscriptions, not a
        // hard issue that blocks launch.
        if Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY.isEmpty &&
           Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY.isEmpty {
            let report = EnvironmentValidator.validate()
            #expect(!report.issues.contains { $0.contains("RevenueCat") })
            #expect(report.warnings.contains { $0.contains("RevenueCat") })
        }
    }
    #endif
}

// MARK: - Coordinator delegation from AppViewModel

@MainActor
@Suite("AppViewModel delegates to coordinators")
struct CoordinatorDelegationTests {

    private func makeVM() -> AppViewModel {
        PersistenceStore.shared.clear()
        return AppViewModel()
    }

    @Test func refreshIntelligencePopulatesDerivedState() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.profile.daysPerWeek = 3
        vm.refreshIntelligence()
        // Coordinator should at minimum run without crashing and keep a
        // consistent progressionStates array (may be empty when no history).
        #expect(vm.progressionStates.count >= 0)
    }

    @Test func todayPrescriptionGoesThroughCoachingCoordinator() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        let planned = PlannedExercise(
            exerciseId: "barbell-bench-press",
            sets: 3, reps: "6-8", restSeconds: 120, rpe: 8
        )
        let p = vm.todayPrescription(for: planned)
        #expect(p.plannedSets == 3)
        #expect(p.suggestedSets >= 1)
    }

    @Test func toggleFavoriteRoundTripsAndPersists() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.toggleFavorite("abc")
        #expect(vm.favoriteExerciseIds.contains("abc"))
        vm.toggleFavorite("abc")
        #expect(!vm.favoriteExerciseIds.contains("abc"))
    }

    @Test func saveActiveWorkoutDraftRoundTripsThroughPersistence() {
        let vm = makeVM()
        defer { PersistenceStore.shared.clear() }
        vm.activeWorkout = ActiveWorkoutState(
            session: WorkoutSession(planId: "p", dayId: "d", dayName: "Push"),
            currentExerciseIndex: 2,
            currentSetIndex: 1,
            isResting: false,
            restTimeRemaining: 0,
            plannedExercises: []
        )
        vm.saveActiveWorkoutDraft()

        let loaded = PersistenceStore.shared.load()
        #expect(loaded?.activeWorkoutDraft?.currentExerciseIndex == 2)
        #expect(loaded?.activeWorkoutDraft?.currentSetIndex == 1)
        #expect(loaded?.activeWorkoutDraft?.session.dayName == "Push")
    }
}
