import Foundation

/// Central canonical-identity resolver for exercise ids.
///
/// The ExerciseDBPro importer already tracks alias → canonical mappings for
/// duplicate rows it collapses during import. `ExerciseIdentity` is the one
/// place the rest of the app reaches to resolve a (possibly legacy alias) id
/// back to its canonical STRQ identity — so history, progression, response
/// learning, and media all behave as one identity per exercise.
///
/// For curated (non-`edb-`) ids this is a no-op. For imported ids it walks
/// through the importer's alias table. Both directions are deterministic and
/// safe to call on any thread.
nonisolated enum ExerciseIdentity {
    /// Canonical id for any exercise reference. Returns the input id unchanged
    /// when it is already canonical (or when the id is curated / unknown).
    static func canonical(_ id: String) -> String {
        guard id.hasPrefix("edb-") else { return id }
        return ExerciseDBProImporter.shared.canonicalId(for: id)
    }

    /// Canonicalize a batch of ids, preserving first-seen order.
    static func canonical(_ ids: [String]) -> [String] {
        var seen = Set<String>()
        var out: [String] = []
        out.reserveCapacity(ids.count)
        for id in ids {
            let c = canonical(id)
            if seen.insert(c).inserted { out.append(c) }
        }
        return out
    }

    /// Returns true when `a` and `b` resolve to the same canonical identity.
    static func matches(_ a: String, _ b: String) -> Bool {
        canonical(a) == canonical(b)
    }
}

/// Safe one-shot migration that upgrades persisted exercise references from
/// legacy alias ids to canonical ids. Idempotent — running it on already-
/// canonical data is a no-op. Used on hydrate and on cloud restore apply so
/// old snapshots don't fragment history / progression / response.
@MainActor
enum ExerciseIdentityMigration {
    /// Return a copy of an in-progress workout with exercise references
    /// rewritten to canonical ids. Cursor/rest/session progress is untouched.
    static func canonicalized(_ active: ActiveWorkoutState) -> ActiveWorkoutState {
        var copy = active
        _ = canonicalizeActiveWorkout(&copy)
        return copy
    }

    /// Rewrite known id-carrying fields on the view model to canonical ids.
    /// Only touches fields where a legacy alias id is observed — leaves
    /// everything else untouched. Returns the number of references migrated,
    /// purely for internal diagnostics.
    @discardableResult
    static func migrate(_ vm: AppViewModel) -> Int {
        var changed = 0

        // Plan exercises.
        if var plan = vm.currentPlan {
            for d in plan.days.indices {
                for e in plan.days[d].exercises.indices {
                    let original = plan.days[d].exercises[e].exerciseId
                    let c = ExerciseIdentity.canonical(original)
                    if c != original {
                        plan.days[d].exercises[e].exerciseId = c
                        changed += 1
                    }
                }
            }
            vm.currentPlan = plan
        }

        // Previous plan (held for week-action undo).
        if var prev = vm.previousPlanBeforeWeekAction {
            for d in prev.days.indices {
                for e in prev.days[d].exercises.indices {
                    let original = prev.days[d].exercises[e].exerciseId
                    let c = ExerciseIdentity.canonical(original)
                    if c != original {
                        prev.days[d].exercises[e].exerciseId = c
                        changed += 1
                    }
                }
            }
            vm.previousPlanBeforeWeekAction = prev
        }

        // Workout history logs.
        for s in vm.workoutHistory.indices {
            for l in vm.workoutHistory[s].exerciseLogs.indices {
                let original = vm.workoutHistory[s].exerciseLogs[l].exerciseId
                let c = ExerciseIdentity.canonical(original)
                if c != original {
                    vm.workoutHistory[s].exerciseLogs[l].exerciseId = c
                    changed += 1
                }
            }
        }

        // Personal records.
        for i in vm.personalRecords.indices {
            let original = vm.personalRecords[i].exerciseId
            let c = ExerciseIdentity.canonical(original)
            if c != original {
                vm.personalRecords[i].exerciseId = c
                changed += 1
            }
        }

        // Progression states (`exerciseId` is immutable — rebuild when
        // canonicalization moves the id). Collapse multiple alias states for
        // the same canonical exercise into one, keeping the state with the
        // richest session history so progression doesn't fragment.
        var mergedStates: [String: ExerciseProgressionState] = [:]
        var progressionChanged = false
        for state in vm.progressionStates {
            let c = ExerciseIdentity.canonical(state.exerciseId)
            if c != state.exerciseId { progressionChanged = true }
            let rebuilt: ExerciseProgressionState
            if c == state.exerciseId {
                rebuilt = state
            } else {
                rebuilt = ExerciseProgressionState(
                    id: state.id,
                    exerciseId: c,
                    lastWeight: state.lastWeight,
                    lastReps: state.lastReps,
                    lastRPE: state.lastRPE,
                    sessionCount: state.sessionCount,
                    consecutiveSamePerformance: state.consecutiveSamePerformance,
                    plateauStatus: state.plateauStatus,
                    recommendedStrategy: state.recommendedStrategy,
                    suggestedNextWeight: state.suggestedNextWeight,
                    suggestedNextReps: state.suggestedNextReps,
                    performanceTrend: state.performanceTrend,
                    lastUpdated: state.lastUpdated,
                    coachNote: state.coachNote
                )
            }
            if let existing = mergedStates[c] {
                progressionChanged = true
                mergedStates[c] = existing.sessionCount >= rebuilt.sessionCount ? existing : rebuilt
            } else {
                mergedStates[c] = rebuilt
            }
        }
        if progressionChanged {
            vm.progressionStates = Array(mergedStates.values)
            changed += 1
        }

        // Favorites.
        let canonFavorites = Set(vm.favoriteExerciseIds.map(ExerciseIdentity.canonical))
        if canonFavorites != vm.favoriteExerciseIds {
            changed += vm.favoriteExerciseIds.subtracting(canonFavorites).count
            vm.favoriteExerciseIds = canonFavorites
        }

        // Preferred / avoided exercise id lists on the user profile.
        let preferred = vm.profile.preferredExercises.map(ExerciseIdentity.canonical)
        if preferred != vm.profile.preferredExercises {
            changed += 1
            vm.profile.preferredExercises = Array(NSOrderedSet(array: preferred)) as? [String] ?? preferred
        }
        let avoided = vm.profile.avoidedExercises.map(ExerciseIdentity.canonical)
        if avoided != vm.profile.avoidedExercises {
            changed += 1
            vm.profile.avoidedExercises = Array(NSOrderedSet(array: avoided)) as? [String] ?? avoided
        }

        // Active workout — if any slot still points at a legacy id, rewrite.
        if var active = vm.activeWorkout {
            changed += canonicalizeActiveWorkout(&active)
            vm.activeWorkout = active
        }

        return changed
    }

    private static func canonicalizeActiveWorkout(_ active: inout ActiveWorkoutState) -> Int {
        var changed = 0
        for i in active.plannedExercises.indices {
            let original = active.plannedExercises[i].exerciseId
            let c = ExerciseIdentity.canonical(original)
            if c != original {
                active.plannedExercises[i].exerciseId = c
                changed += 1
            }
        }
        for i in active.session.exerciseLogs.indices {
            let original = active.session.exerciseLogs[i].exerciseId
            let c = ExerciseIdentity.canonical(original)
            if c != original {
                active.session.exerciseLogs[i].exerciseId = c
                changed += 1
            }
        }
        return changed
    }
}
