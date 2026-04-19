import Foundation

/// Single source of truth for building `PersistedAppState` snapshots.
/// Used by both local persistence and iCloud upload so the two paths
/// can never drift out of sync.
@MainActor
enum SnapshotBuilder {
    static func build(from vm: AppViewModel, version: Int) -> PersistedAppState {
        let draft: ActiveWorkoutDraft? = vm.activeWorkout.map { state in
            ActiveWorkoutDraft(
                session: state.session,
                currentExerciseIndex: state.currentExerciseIndex,
                currentSetIndex: state.currentSetIndex,
                plannedExercises: state.plannedExercises
            )
        }
        return PersistedAppState(
            version: version,
            hasCompletedOnboarding: vm.hasCompletedOnboarding,
            profile: vm.profile,
            currentPlan: vm.currentPlan,
            workoutHistory: vm.workoutHistory,
            personalRecords: vm.personalRecords,
            progressEntries: vm.progressEntries,
            favoriteExerciseIds: Array(vm.favoriteExerciseIds),
            progressionStates: vm.progressionStates,
            trainingPhaseState: vm.trainingPhaseState,
            coachAdjustments: vm.coachAdjustments,
            appliedActionIds: Array(vm.appliedActionIds),
            weekAdjustmentActive: vm.weekAdjustmentActive,
            previousPlanBeforeWeekAction: vm.previousPlanBeforeWeekAction,
            weeklyReviewDismissed: vm.weeklyReviewDismissed,
            todaysReadiness: vm.todaysReadiness,
            readinessHistory: vm.readinessHistory,
            notificationSettings: vm.notificationSettings,
            nutritionTarget: vm.nutritionTarget,
            nutritionLogs: vm.nutritionLogs,
            bodyWeightEntries: vm.bodyWeightEntries,
            sleepEntries: vm.sleepEntries,
            activeWorkoutDraft: draft
        )
    }

    /// Compact fingerprint used to detect whether a remote snapshot is
    /// materially newer/richer than the local state before we overwrite.
    static func maturityScore(_ state: PersistedAppState) -> Int {
        var score = 0
        score += state.workoutHistory.filter(\.isCompleted).count * 10
        score += state.readinessHistory.count
        score += state.bodyWeightEntries.count
        score += state.sleepEntries.count
        score += state.nutritionLogs.count
        score += state.progressionStates.count
        if state.hasCompletedOnboarding { score += 5 }
        return score
    }
}

nonisolated enum CloudRestoreOutcome: Sendable, Equatable {
    case restored
    case noSnapshot
    case unavailable
    case staleIgnored
    case decodeFailed
}
