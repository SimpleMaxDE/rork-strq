import Foundation

/// Centralized workout mutation layer.
///
/// Every source of truth change to `activeWorkout` — whether driven by the
/// iPhone UI, the Watch, or the Live Activity — flows through one of these
/// methods. They are the single path for:
///   - updating set weight/reps
///   - completing a set
///   - changing the active set / exercise
///   - tagging set quality
///   - finishing the workout
///
/// This removes scattered `vm.activeWorkout = workout` assignments from views
/// and keeps Live Activity, Watch context, and persistence in sync
/// automatically.
@MainActor
extension AppViewModel {

    // MARK: - Set edits

    func updateSetLoad(exerciseIndex: Int, setIndex: Int, weight: Double, reps: Int) {
        guard var workout = activeWorkout,
              exerciseIndex < workout.session.exerciseLogs.count,
              setIndex < workout.session.exerciseLogs[exerciseIndex].sets.count else { return }
        workout.session.exerciseLogs[exerciseIndex].sets[setIndex].weight = max(0, weight)
        workout.session.exerciseLogs[exerciseIndex].sets[setIndex].reps = max(0, reps)
        activeWorkout = workout
    }

    /// Marks the set complete, advances the cursor, and returns the planned
    /// rest duration so the caller can drive its own timer UI.
    @discardableResult
    func completeCurrentSet(exerciseIndex: Int, setIndex: Int) -> Int {
        guard var workout = activeWorkout,
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

        activeWorkout = workout
        updateLiveActivity(restEndsAt: Date().addingTimeInterval(TimeInterval(rest)))
        return rest
    }

    func setSetQuality(exerciseIndex: Int, setIndex: Int, quality: SetQuality?) {
        guard var workout = activeWorkout,
              exerciseIndex < workout.session.exerciseLogs.count,
              setIndex < workout.session.exerciseLogs[exerciseIndex].sets.count else { return }
        workout.session.exerciseLogs[exerciseIndex].sets[setIndex].quality = quality
        activeWorkout = workout
    }

    // MARK: - Cursor moves

    func jumpToSet(exerciseIndex: Int, setIndex: Int) {
        guard var workout = activeWorkout,
              exerciseIndex < workout.session.exerciseLogs.count,
              setIndex < workout.session.exerciseLogs[exerciseIndex].sets.count else { return }
        workout.currentExerciseIndex = exerciseIndex
        workout.currentSetIndex = setIndex
        activeWorkout = workout
        updateLiveActivity()
    }

    func moveToNextExercise() {
        guard var workout = activeWorkout else { return }
        guard workout.currentExerciseIndex < workout.session.exerciseLogs.count - 1 else { return }
        workout.currentExerciseIndex += 1
        workout.currentSetIndex = 0
        activeWorkout = workout
        updateLiveActivity()
    }

    func moveToPreviousExercise() {
        guard var workout = activeWorkout else { return }
        guard workout.currentExerciseIndex > 0 else { return }
        workout.currentExerciseIndex -= 1
        workout.currentSetIndex = 0
        activeWorkout = workout
        updateLiveActivity()
    }

    func jumpToExercise(_ index: Int) {
        guard var workout = activeWorkout else { return }
        guard index >= 0, index < workout.session.exerciseLogs.count else { return }
        workout.currentExerciseIndex = index
        workout.currentSetIndex = 0
        activeWorkout = workout
        updateLiveActivity()
    }
}
