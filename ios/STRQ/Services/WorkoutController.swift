import Foundation

/// Dedicated orchestrator for the active workout subsystem.
///
/// Every workout-state change — whether driven by the iPhone UI, the Apple
/// Watch, the Live Activity, or a scene-phase handoff — flows through this
/// controller. It is the single source of truth for:
///
///   - starting / completing / cancelling a workout
///   - updating set weight, reps, and quality
///   - advancing the set / exercise cursor
///   - driving the Live Activity lifecycle
///   - routing incoming Watch actions back into the mutation layer
///   - persistence handoff for draft saves
///
/// `AppViewModel` retains storage of `activeWorkout` so SwiftUI views keep
/// observing the same reactive property, but it no longer implements workout
/// mutation logic. This isolates workout state as its own subsystem and makes
/// side-effect ordering (persistence, widget refresh, watch push, Live
/// Activity update) consistent across all call sites.
@MainActor
final class WorkoutController {
    private unowned let vm: AppViewModel
    private let liveActivity = WorkoutLiveActivityManager.shared

    init(vm: AppViewModel) {
        self.vm = vm
    }

    // MARK: - Lifecycle

    func startWorkout(day: WorkoutDay) {
        guard let plan = vm.currentPlan else {
            ErrorReporter.shared.reportMessage("startWorkout called without plan", level: .warning)
            return
        }
        Analytics.shared.track(.workout_started, [
            "day": day.name,
            "exercises": String(day.exercises.count),
            "phase": String(describing: vm.trainingPhaseState.currentPhase),
            "readiness": vm.readinessBucket
        ])
        let priorCompleted = vm.totalCompletedWorkouts
        if priorCompleted == 0 {
            Analytics.shared.track(.first_session_started, ["day": day.name])
        } else if priorCompleted == 1 {
            Analytics.shared.track(.second_session_started, ["day": day.name])
        }
        ErrorReporter.shared.breadcrumb("Workout started: \(day.name)", category: "training")
        let exerciseLogs = day.exercises.map { planned -> ExerciseLog in
            let today = vm.todayPrescription(for: planned)
            let prefillWeight = today.suggestedWeight
            let setCount = max(1, today.suggestedSets)
            let sets = (1...setCount).map { SetLog(setNumber: $0, weight: prefillWeight) }
            return ExerciseLog(exerciseId: planned.exerciseId, sets: sets)
        }
        vm.activeWorkout = ActiveWorkoutState(
            session: WorkoutSession(planId: plan.id, dayId: day.id, dayName: day.name, exerciseLogs: exerciseLogs),
            currentExerciseIndex: 0,
            currentSetIndex: 0,
            isResting: false,
            restTimeRemaining: 0,
            plannedExercises: day.exercises
        )
        vm.workoutMinimized = false
        vm.completedWorkoutHandoff = nil
        startLiveActivity()
        vm.persist()
    }

    func completeWorkout() {
        guard var workout = vm.activeWorkout else {
            ErrorReporter.shared.reportMessage("completeWorkout called without active workout", level: .warning)
            return
        }
        workout.session.isCompleted = true
        workout.session.endTime = Date()
        workout.session.totalVolume = workout.session.exerciseLogs.reduce(0.0) { total, log in
            total + log.sets.filter(\.isCompleted).reduce(0.0) { $0 + $1.weight * Double($1.reps) }
        }
        vm.workoutHistory.insert(workout.session, at: 0)

        let entry = ProgressEntry(
            date: Date(),
            totalSets: workout.session.exerciseLogs.flatMap(\.sets).filter(\.isCompleted).count,
            totalReps: workout.session.exerciseLogs.flatMap(\.sets).filter(\.isCompleted).reduce(0) { $0 + $1.reps },
            totalVolume: workout.session.totalVolume,
            workoutDuration: Int(Date().timeIntervalSince(workout.session.startTime) / 60)
        )
        vm.progressEntries.insert(entry, at: 0)

        let sessionStart = workout.session.startTime
        let sessionEnd = workout.session.endTime ?? Date()
        let sessionVolume = workout.session.totalVolume
        endLiveActivity(completed: true)
        vm.workoutMinimized = false
        vm.completedWorkoutHandoff = workout.session
        vm.activeWorkout = nil
        vm.refreshIntelligence()
        vm.persist()
        if vm.notificationSettings.healthKitSyncEnabled {
            Task { await HealthKitService.shared.saveWorkout(start: sessionStart, end: sessionEnd, totalVolumeKg: sessionVolume) }
        }
        Analytics.shared.track(.workout_completed, [
            "day": workout.session.dayName,
            "sets": String(entry.totalSets),
            "reps": String(entry.totalReps),
            "volume": String(Int(entry.totalVolume)),
            "duration_min": String(entry.workoutDuration)
        ])
        let newCompleted = vm.totalCompletedWorkouts
        switch newCompleted {
        case 1:
            Analytics.shared.track(.first_session_completed, ["day": workout.session.dayName])
            Analytics.shared.track(.activation_step_unlocked, ["step": "s1"])
        case 2:
            Analytics.shared.track(.second_session_completed, ["day": workout.session.dayName])
            Analytics.shared.track(.activation_step_unlocked, ["step": "s2"])
        case 3:
            Analytics.shared.track(.third_session_completed, ["day": workout.session.dayName])
            Analytics.shared.track(.activation_step_unlocked, ["step": "s3"])
        default:
            break
        }
        let weekTarget = min(3, max(1, vm.profile.daysPerWeek))
        if vm.weeklyStats.sessions == weekTarget && newCompleted >= 3 && newCompleted <= weekTarget + 2 {
            Analytics.shared.track(.week_one_target_hit, [
                "target": String(weekTarget),
                "total_completed": String(newCompleted)
            ])
            Analytics.shared.track(.activation_step_unlocked, ["step": "week"])
        }
        ErrorReporter.shared.breadcrumb("Workout completed: \(workout.session.dayName)", category: "training")
    }

    func saveDraft() {
        vm.persist()
    }

    /// Pauses and leaves the current workout — session stays as a draft so it
    /// can be resumed later from the Today surface.
    func pauseWorkout() {
        guard vm.activeWorkout != nil else { return }
        Analytics.shared.track(.workout_paused, [:])
        ErrorReporter.shared.breadcrumb("Workout paused", category: "training")
        vm.workoutMinimized = true
        updateLiveActivity()
        vm.persist()
    }

    /// Permanently discards the active workout. All logged sets are lost. Live
    /// Activity ends immediately. No session is written to history.
    func discardWorkout() {
        guard let workout = vm.activeWorkout else { return }
        Analytics.shared.track(.workout_discarded, [
            "day": workout.session.dayName,
            "exercises_touched": String(workout.session.exerciseLogs.filter { $0.sets.contains(where: \.isCompleted) }.count)
        ])
        ErrorReporter.shared.breadcrumb("Workout discarded: \(workout.session.dayName)", category: "training")
        endLiveActivity(completed: false)
        vm.workoutMinimized = false
        vm.completedWorkoutHandoff = nil
        vm.activeWorkout = nil
        vm.persist()
    }

    /// Replaces a planned exercise inside the *active* workout without mutating
    /// the plan itself. Preserves completed-set history for earlier exercises;
    /// replaces the log & planned row for the targeted slot with a fresh prescription.
    func replaceExerciseInActiveWorkout(exerciseIndex: Int, with newExercise: Exercise) {
        guard var workout = vm.activeWorkout,
              exerciseIndex < workout.session.exerciseLogs.count,
              exerciseIndex < workout.plannedExercises.count else { return }
        let oldPlanned = workout.plannedExercises[exerciseIndex]
        let newPlanned = PlannedExercise(
            id: oldPlanned.id,
            exerciseId: newExercise.id,
            sets: oldPlanned.sets,
            reps: oldPlanned.reps,
            restSeconds: oldPlanned.restSeconds,
            rpe: oldPlanned.rpe,
            notes: oldPlanned.notes,
            order: oldPlanned.order,
            coachDefault: oldPlanned.coachDefault
        )
        workout.plannedExercises[exerciseIndex] = newPlanned

        let today = vm.todayPrescription(for: newPlanned)
        let setCount = max(1, today.suggestedSets)
        let prefill = today.suggestedWeight
        let sets = (1...setCount).map { SetLog(setNumber: $0, weight: prefill) }
        let oldLog = workout.session.exerciseLogs[exerciseIndex]
        var newLog = ExerciseLog(exerciseId: newExercise.id, sets: sets)
        if oldLog.sets.allSatisfy({ !$0.isCompleted }) == false {
            // If user had already logged into this slot, reset completion state safely
            newLog.isCompleted = false
        }
        workout.session.exerciseLogs[exerciseIndex] = newLog
        if workout.currentExerciseIndex == exerciseIndex {
            workout.currentSetIndex = 0
        }
        vm.activeWorkout = workout
        Analytics.shared.track(.exercise_swapped_in_workout, [
            "old": oldLog.exerciseId,
            "new": newExercise.id
        ])
        updateLiveActivity()
        vm.persist()
    }

    // MARK: - Set edits

    func updateSetLoad(exerciseIndex: Int, setIndex: Int, weight: Double, reps: Int) {
        guard var workout = vm.activeWorkout,
              exerciseIndex < workout.session.exerciseLogs.count,
              setIndex < workout.session.exerciseLogs[exerciseIndex].sets.count else { return }
        workout.session.exerciseLogs[exerciseIndex].sets[setIndex].weight = max(0, weight)
        workout.session.exerciseLogs[exerciseIndex].sets[setIndex].reps = max(0, reps)
        vm.activeWorkout = workout
    }

    /// Marks the set complete, advances the cursor, and returns the planned
    /// rest duration so the caller can drive its own timer UI.
    @discardableResult
    func completeCurrentSet(exerciseIndex: Int, setIndex: Int) -> Int {
        guard var workout = vm.activeWorkout,
              exerciseIndex < workout.session.exerciseLogs.count,
              setIndex < workout.session.exerciseLogs[exerciseIndex].sets.count else { return 0 }

        workout.session.exerciseLogs[exerciseIndex].sets[setIndex].isCompleted = true

        let allDone = workout.session.exerciseLogs[exerciseIndex].sets.allSatisfy(\.isCompleted)
        if allDone {
            workout.session.exerciseLogs[exerciseIndex].isCompleted = true
            if exerciseIndex < workout.session.exerciseLogs.count - 1 {
                workout.currentExerciseIndex = exerciseIndex + 1
                workout.currentSetIndex = 0
            }
        } else {
            workout.currentSetIndex = setIndex + 1
        }

        let planned = exerciseIndex < workout.plannedExercises.count
            ? workout.plannedExercises[exerciseIndex]
            : nil
        let rest = planned?.restSeconds ?? 90

        vm.activeWorkout = workout
        updateLiveActivity(restEndsAt: Date().addingTimeInterval(TimeInterval(rest)))
        return rest
    }

    func setSetQuality(exerciseIndex: Int, setIndex: Int, quality: SetQuality?) {
        guard var workout = vm.activeWorkout,
              exerciseIndex < workout.session.exerciseLogs.count,
              setIndex < workout.session.exerciseLogs[exerciseIndex].sets.count else { return }
        workout.session.exerciseLogs[exerciseIndex].sets[setIndex].quality = quality
        vm.activeWorkout = workout
    }

    // MARK: - Cursor moves

    func jumpToSet(exerciseIndex: Int, setIndex: Int) {
        guard var workout = vm.activeWorkout,
              exerciseIndex < workout.session.exerciseLogs.count,
              setIndex < workout.session.exerciseLogs[exerciseIndex].sets.count else { return }
        workout.currentExerciseIndex = exerciseIndex
        workout.currentSetIndex = setIndex
        vm.activeWorkout = workout
        updateLiveActivity()
    }

    func moveToNextExercise() {
        guard var workout = vm.activeWorkout else { return }
        guard workout.currentExerciseIndex < workout.session.exerciseLogs.count - 1 else { return }
        workout.currentExerciseIndex += 1
        workout.currentSetIndex = 0
        vm.activeWorkout = workout
        updateLiveActivity()
    }

    func moveToPreviousExercise() {
        guard var workout = vm.activeWorkout else { return }
        guard workout.currentExerciseIndex > 0 else { return }
        workout.currentExerciseIndex -= 1
        workout.currentSetIndex = 0
        vm.activeWorkout = workout
        updateLiveActivity()
    }

    func jumpToExercise(_ index: Int) {
        guard var workout = vm.activeWorkout else { return }
        guard index >= 0, index < workout.session.exerciseLogs.count else { return }
        workout.currentExerciseIndex = index
        workout.currentSetIndex = 0
        vm.activeWorkout = workout
        updateLiveActivity()
    }

    // MARK: - Watch Actions

    func handleWatchAction(_ action: String, payload: [String: Any]) {
        guard let workout = vm.activeWorkout, !workout.session.exerciseLogs.isEmpty else { return }
        let exIdx = min(workout.currentExerciseIndex, workout.session.exerciseLogs.count - 1)
        let log = workout.session.exerciseLogs[exIdx]

        switch action {
        case "completeSet":
            guard let setIdx = log.sets.firstIndex(where: { !$0.isCompleted }) else { return }
            let weight = (payload["weight"] as? Double) ?? log.sets[setIdx].weight
            let reps = (payload["reps"] as? Int) ?? log.sets[setIdx].reps
            updateSetLoad(exerciseIndex: exIdx, setIndex: setIdx, weight: weight, reps: reps)
            _ = completeCurrentSet(exerciseIndex: exIdx, setIndex: setIdx)
            vm.persist()
        case "nextExercise":
            moveToNextExercise()
            vm.persist()
        case "adjustWeight":
            let delta = (payload["delta"] as? Double) ?? 0
            guard let setIdx = log.sets.firstIndex(where: { !$0.isCompleted }) else { return }
            let current = log.sets[setIdx]
            updateSetLoad(exerciseIndex: exIdx, setIndex: setIdx, weight: current.weight + delta, reps: current.reps)
            vm.persist()
        case "adjustReps":
            let delta = (payload["delta"] as? Int) ?? 0
            guard let setIdx = log.sets.firstIndex(where: { !$0.isCompleted }) else { return }
            let current = log.sets[setIdx]
            updateSetLoad(exerciseIndex: exIdx, setIndex: setIdx, weight: current.weight, reps: current.reps + delta)
            vm.persist()
        case "setQuality":
            guard let raw = payload["quality"] as? String, let q = SetQuality(rawValue: raw) else { return }
            guard let setIdx = log.sets.lastIndex(where: { $0.isCompleted }) else { return }
            setSetQuality(exerciseIndex: exIdx, setIndex: setIdx, quality: q)
            vm.persist()
        default:
            break
        }
    }

    // MARK: - Live Activity

    func startLiveActivity() {
        guard let workout = vm.activeWorkout, let state = buildLiveActivityState() else { return }
        liveActivity.start(state: state, workoutId: workout.session.id)
    }

    func updateLiveActivity(restEndsAt: Date? = nil) {
        guard let state = buildLiveActivityState(restEndsAt: restEndsAt) else { return }
        liveActivity.update(state: state)
    }

    func endLiveActivity(completed: Bool) {
        var finalState = buildLiveActivityState()
        if completed, finalState != nil {
            finalState?.isCompleted = true
            finalState?.restEndsAt = nil
        }
        liveActivity.end(finalState: finalState, immediate: !completed)
    }

    private func buildLiveActivityState(restEndsAt: Date? = nil) -> WorkoutActivityAttributes.ContentState? {
        guard let workout = vm.activeWorkout else { return nil }
        let logs = workout.session.exerciseLogs
        guard !logs.isEmpty else { return nil }
        let idx = min(workout.currentExerciseIndex, logs.count - 1)
        let log = logs[idx]
        let exerciseName = vm.library.exercise(byId: log.exerciseId)?.name ?? log.exerciseId
        let completedSetsInCurrent = log.sets.filter(\.isCompleted).count
        let currentSetNumber = min(log.sets.count, completedSetsInCurrent + 1)
        let totalCompleted = logs.flatMap(\.sets).filter(\.isCompleted).count
        let totalSessionSets = logs.flatMap(\.sets).count
        let nextIdx = idx + 1
        let nextName: String? = nextIdx < logs.count
            ? (vm.library.exercise(byId: logs[nextIdx].exerciseId)?.name ?? logs[nextIdx].exerciseId)
            : nil
        let allDone = logs.allSatisfy(\.isCompleted)
        return WorkoutActivityAttributes.ContentState(
            dayName: workout.session.dayName,
            exerciseName: exerciseName,
            currentExerciseIndex: idx,
            totalExercises: logs.count,
            currentSetNumber: currentSetNumber,
            totalSets: log.sets.count,
            completedSets: totalCompleted,
            totalSessionSets: totalSessionSets,
            startedAt: workout.session.startTime,
            restEndsAt: restEndsAt,
            nextExerciseName: nextName,
            isCompleted: allDone
        )
    }
}
