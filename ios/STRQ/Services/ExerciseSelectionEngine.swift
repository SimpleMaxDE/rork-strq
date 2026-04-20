import Foundation

// Exercise-selection intelligence. Scores candidate exercises for substitutions,
// identifies the best anchor lift per muscle from what the user actually progresses
// on, and surfaces exercise-order optimizations. Routes through existing swap /
// insight / recommendation surfaces — no new UI.

nonisolated struct ExerciseSelectionContext: Sendable {
    let profile: UserProfile
    let progressionStates: [ExerciseProgressionState]
    let workoutHistory: [WorkoutSession]
    let recoveryScore: Int
    let phase: TrainingPhase
}

nonisolated struct ScoredExercise: Identifiable, Sendable {
    let id: String
    let exercise: Exercise
    let score: Double
    let reasons: [String]
    let tags: [String]
}

nonisolated struct AnchorCandidate: Sendable {
    let exercise: Exercise
    let state: ExerciseProgressionState
    let score: Double
}

nonisolated struct ReorderSuggestion: Sendable {
    let dayId: String
    let dayName: String
    let exerciseIdToPromote: String
    let exerciseName: String
    let reason: String
    let confidence: PlanEvolutionConfidence
}

struct ExerciseSelectionEngine {
    private let library = ExerciseLibrary.shared
    private let familyService = ExerciseFamilyService.shared
    private let readiness = ImportedExerciseReadinessService.shared

    // MARK: - Role inference (engine-side)

    /// Derive the coaching role of an exercise from its catalog shape. Used to
    /// preserve role during substitution — an anchor should not casually swap
    /// into an isolation, and vice versa.
    func replacementRole(for exercise: Exercise) -> ReplacementRole {
        switch exercise.category {
        case .warmup: return .warmup
        case .mobility, .recovery: return .mobility
        case .isolation: return .isolation
        case .bodyweight:
            return exercise.progressionLevel == .progression ? .secondary : .accessory
        case .compound:
            switch exercise.movementPattern {
            case .squat, .hipHinge, .horizontalPush, .verticalPush, .horizontalPull, .verticalPull:
                return .anchor
            default:
                return .secondary
            }
        case .cardio, .pilates:
            return .accessory
        }
    }

    private func difficultyRank(_ d: ExerciseDifficulty) -> Int {
        switch d {
        case .beginner: 0
        case .intermediate: 1
        case .advanced: 2
        }
    }

    private func rolesMatch(_ a: ReplacementRole, _ b: ReplacementRole) -> Bool {
        if a == b { return true }
        // Accessory and isolation are mutually compatible — both are
        // low-priority volume work with overlapping prescriptions.
        if (a == .accessory && b == .isolation) || (a == .isolation && b == .accessory) { return true }
        return false
    }

    // MARK: - Score a candidate as a substitute for another exercise

    func score(
        candidate: Exercise,
        replacing original: Exercise,
        context: ExerciseSelectionContext,
        reason: ReplacementReason
    ) -> ScoredExercise {
        var s: Double = 50
        var reasons: [String] = []
        var tags: [String] = []

        let profile = context.profile

        // Role preservation — strongest structural constraint.
        let originalRole = replacementRole(for: original)
        let candidateRole = replacementRole(for: candidate)
        if rolesMatch(originalRole, candidateRole) {
            s += 22
        } else {
            // Penalize role mismatch heavily so an anchor never casually
            // becomes an isolation (and vice versa).
            switch (originalRole, candidateRole) {
            case (.anchor, .isolation), (.anchor, .accessory),
                 (.isolation, .anchor), (.accessory, .anchor):
                s -= 50
            case (.anchor, .secondary), (.secondary, .anchor):
                s -= 8
            default:
                s -= 18
            }
        }

        if candidate.movementPattern == original.movementPattern {
            s += 18
            tags.append("Same pattern")
        }
        if candidate.primaryMuscle == original.primaryMuscle {
            s += 14
            tags.append("Same target")
        } else if candidate.secondaryMuscles.contains(original.primaryMuscle) {
            s += 6
        }

        if let originalFamily = familyService.family(forExercise: original.id),
           originalFamily.memberIds.contains(candidate.id) {
            s += 10
            if !tags.contains("Same pattern") && !tags.contains("Same target") {
                tags.append("Same family")
            }
        }

        let location: LocationType = {
            switch profile.trainingLocation {
            case .gym: return .gym
            case .homeGym: return .homeGym
            case .homeNoEquipment: return .homeNoEquipment
            }
        }()
        if !isEquipmentAvailable(candidate, location: location, profile: profile) {
            s -= 100
        } else if candidate.locationType == .anywhere || candidate.locationType == .homeNoEquipment {
            if profile.trainingLocation != .gym { tags.append("Minimal equipment") }
        }

        switch profile.trainingLevel {
        case .beginner:
            if candidate.isBeginnerFriendly { s += 12 }
            if candidate.difficulty == .advanced { s -= 20 }
        case .intermediate:
            if candidate.difficulty == .advanced && !candidate.isBeginnerFriendly { s -= 5 }
        case .advanced:
            if candidate.difficulty == .advanced { s += 3 }
        }

        if let state = historicalState(for: candidate, in: context) {
            switch state.plateauStatus {
            case .progressing:
                s += 16
                reasons.append("You've been progressing on this")
            case .stalling: s -= 2
            case .plateaued: s -= 6
            case .regressing: s -= 10
            }
        }

        if isRiskyGivenInjuries(candidate, profile: profile) {
            s -= 40
        } else if candidate.isJointFriendly {
            s += 4
            if !original.isJointFriendly {
                tags.append("Joint-friendly")
            }
        }

        if profile.focusMuscles.contains(candidate.primaryMuscle) { s += 8 }

        let avoided = Set(profile.avoidedExercises.map { $0.lowercased() })
        if avoided.contains(candidate.name.lowercased()) { s -= 60 }

        if adherenceScore(for: candidate, context: context) < 0.3 && candidate.difficulty == .advanced {
            s -= 6
        }

        if context.recoveryScore < 60 && candidate.category == .compound && candidate.difficulty == .advanced {
            s -= 6
        }

        switch reason {
        case .injuryAvoidance:
            if candidate.isJointFriendly { s += 18 } else { s -= 20 }
        case .equipmentUnavailable:
            if candidate.locationType == .anywhere || candidate.locationType == .homeNoEquipment { s += 10 }
        case .samePattern:
            if candidate.movementPattern != original.movementPattern { s -= 40 }
        case .easier:
            if candidate.difficulty.rawValue < original.difficulty.rawValue { s += 12; tags.append("Easier") }
            if candidate.isBeginnerFriendly { s += 6 }
        case .harder:
            if candidate.difficulty.rawValue > original.difficulty.rawValue { s += 12; tags.append("Harder") }
        case .general:
            break
        }

        let primaryReason: String = Self.buildPrimaryReason(
            candidate: candidate,
            original: original,
            originalRole: originalRole,
            candidateRole: candidateRole,
            reasons: reasons,
            reason: reason,
            profile: profile
        )

        var combinedReasons = [primaryReason]
        for r in reasons where r != primaryReason { combinedReasons.append(r) }

        return ScoredExercise(
            id: candidate.id,
            exercise: candidate,
            score: s,
            reasons: combinedReasons,
            tags: Array(Set(tags))
        )
    }

    // MARK: - Intent-ranked substitutes

    /// Ranked substitutes for a specific swap intent. The engine filters and
    /// re-weights the pool so each intent produces a genuinely different
    /// list — not the same ranking with a tag stamped on.
    func rankedSubstitutes(
        for exerciseId: String,
        intent: SwapIntent,
        context: ExerciseSelectionContext,
        limit: Int = 5
    ) -> [ScoredExercise] {
        guard let original = library.exercise(byId: exerciseId) else { return [] }

        let baseReason: ReplacementReason = {
            switch intent {
            case .closest: .samePattern
            case .variation: .general
            case .easier: .easier
            case .harder: .harder
            case .jointFriendly: .injuryAvoidance
            case .home: .equipmentUnavailable
            }
        }()

        let pool = candidatePool(for: original)
        let originalRole = replacementRole(for: original)

        let scored: [ScoredExercise] = pool.compactMap { candidate -> ScoredExercise? in
            // Intent-level filters — if the candidate can't satisfy the intent,
            // don't let it surface at all. This keeps each mode distinct.
            switch intent {
            case .closest:
                guard candidate.movementPattern == original.movementPattern else { return nil }
                guard candidate.primaryMuscle == original.primaryMuscle ||
                      candidate.secondaryMuscles.contains(original.primaryMuscle) else { return nil }
            case .variation:
                let sameFamily = familyService.family(forExercise: original.id)?.memberIds.contains(candidate.id) == true
                let importedSibling = familyService.family(forExercise: original.id).flatMap { fam in
                    familyService.importedMembers(for: fam.id).contains(where: { $0.id == candidate.id })
                } ?? false
                guard sameFamily || importedSibling else { return nil }
            case .easier:
                guard candidate.difficulty.rawValue <= original.difficulty.rawValue || candidate.isBeginnerFriendly else { return nil }
                guard rolesMatch(replacementRole(for: candidate), originalRole) else { return nil }
            case .harder:
                guard candidate.difficulty.rawValue >= original.difficulty.rawValue else { return nil }
                guard rolesMatch(replacementRole(for: candidate), originalRole) else { return nil }
            case .jointFriendly:
                guard candidate.isJointFriendly else { return nil }
                guard rolesMatch(replacementRole(for: candidate), originalRole) else { return nil }
            case .home:
                guard candidate.locationType == .anywhere ||
                      candidate.locationType == .homeNoEquipment ||
                      candidate.locationType == .homeGym else { return nil }
            }

            if candidate.id.hasPrefix("edb-") && !readiness.isEligibleForSubstitution(candidate.id) {
                return nil
            }

            var result = score(candidate: candidate, replacing: original, context: context, reason: baseReason)

            // Intent-specific bonuses — sharpen ranking per mode so the top
            // result feels intentional rather than generic.
            var bonus: Double = 0
            switch intent {
            case .closest:
                if candidate.primaryMuscle == original.primaryMuscle { bonus += 8 }
                if candidate.category == original.category { bonus += 4 }
            case .variation:
                if candidate.equipment != original.equipment { bonus += 6 }
            case .easier:
                let diff = difficultyRank(original.difficulty) - difficultyRank(candidate.difficulty)
                bonus += Double(max(0, diff)) * 6
                if candidate.isBeginnerFriendly { bonus += 4 }
            case .harder:
                let diff = difficultyRank(candidate.difficulty) - difficultyRank(original.difficulty)
                bonus += Double(max(0, diff)) * 6
            case .jointFriendly:
                bonus += 10
                if candidate.equipment.contains(.machine) || candidate.equipment.contains(.cable) { bonus += 4 }
            case .home:
                if candidate.locationType == .anywhere || candidate.locationType == .homeNoEquipment { bonus += 10 }
                if candidate.isBodyweight { bonus += 6 }
            }
            result = ScoredExercise(
                id: result.id,
                exercise: result.exercise,
                score: result.score + bonus,
                reasons: result.reasons,
                tags: result.tags
            )

            guard result.score > 0 else { return nil }
            return result
        }

        return Array(scored.sorted { $0.score > $1.score }.prefix(limit))
    }

    /// Build the candidate pool for an exercise — curated members across
    /// family + alternatives + muscle matches, plus imported family siblings
    /// that clear the substitution-readiness gate.
    private func candidatePool(for original: Exercise) -> [Exercise] {
        var pool: Set<String> = []
        if let family = familyService.family(forExercise: original.id) {
            pool.formUnion(family.memberIds)
            for imported in familyService.importedMembers(for: family.id) {
                if readiness.isEligibleForSubstitution(imported.id) {
                    pool.insert(imported.id)
                }
            }
        }
        for alt in library.alternatives(for: original) { pool.insert(alt.id) }
        for ex in library.exercises(forMuscle: original.primaryMuscle) { pool.insert(ex.id) }
        pool.remove(original.id)
        return pool.compactMap { library.exercise(byId: $0) }
    }

    func rankedSubstitutes(
        for exerciseId: String,
        context: ExerciseSelectionContext,
        reason: ReplacementReason = .general,
        limit: Int = 6
    ) -> [ScoredExercise] {
        guard let original = library.exercise(byId: exerciseId) else { return [] }

        var pool: Set<String> = []
        if let family = familyService.family(forExercise: exerciseId) {
            pool.formUnion(family.memberIds)
            // Imported family siblings are only eligible for coach-suggested
            // swaps when their readiness tier clears the substitution gate.
            for imported in familyService.importedMembers(for: family.id) {
                if readiness.isEligibleForSubstitution(imported.id) {
                    pool.insert(imported.id)
                }
            }
        }
        for alt in library.alternatives(for: original) {
            pool.insert(alt.id)
        }
        for ex in library.exercises(forMuscle: original.primaryMuscle) {
            pool.insert(ex.id)
        }
        pool.remove(original.id)

        let scored: [ScoredExercise] = pool.compactMap { id in
            // Gate imported ids by readiness so weak external rows never
            // surface as coach-suggested swaps. Curated ids are always allowed.
            if id.hasPrefix("edb-") && !readiness.isEligibleForSubstitution(id) {
                return nil
            }
            guard let ex = library.exercise(byId: id) else { return nil }
            let result = score(candidate: ex, replacing: original, context: context, reason: reason)
            guard result.score > 0 else { return nil }
            return result
        }
        return Array(scored.sorted { $0.score > $1.score }.prefix(limit))
    }

    // MARK: - Best anchor lift for a muscle

    func bestAnchorCandidate(
        forMuscle muscle: MuscleGroup,
        patterns: Set<MovementPattern> = [],
        context: ExerciseSelectionContext
    ) -> AnchorCandidate? {
        let candidates: [AnchorCandidate] = context.progressionStates.compactMap { state in
            guard state.sessionCount >= 3 else { return nil }
            guard state.plateauStatus == .progressing || state.plateauStatus == .stalling else { return nil }
            guard let ex = library.exercise(byId: state.exerciseId) else { return nil }
            guard ex.primaryMuscle == muscle || ex.secondaryMuscles.contains(muscle) else { return nil }
            if !patterns.isEmpty && !patterns.contains(ex.movementPattern) { return nil }

            var score = Double(state.sessionCount) * 3
            if state.plateauStatus == .progressing { score += 18 }
            if ex.category == .compound { score += 10 }
            if ex.equipment.contains(.barbell) { score += 2 }
            if ex.equipment.contains(.machine) || ex.equipment.contains(.cable) { score += 2 }
            if ex.primaryMuscle == muscle { score += 5 }
            return AnchorCandidate(exercise: ex, state: state, score: score)
        }
        return candidates.sorted { $0.score > $1.score }.first
    }

    // MARK: - Anchor swap (stalled anchor → progressing alternative)

    func anchorSwapSuggestion(
        currentAnchorId: String,
        context: ExerciseSelectionContext
    ) -> (current: Exercise, alternative: Exercise, confidence: PlanEvolutionConfidence)? {
        guard let current = library.exercise(byId: currentAnchorId),
              let currentState = context.progressionStates.first(where: { $0.exerciseId == currentAnchorId })
        else { return nil }

        guard (currentState.plateauStatus == .plateaued || currentState.plateauStatus == .regressing),
              currentState.sessionCount >= 4
        else { return nil }

        guard let candidate = bestAnchorCandidate(
            forMuscle: current.primaryMuscle,
            patterns: [current.movementPattern],
            context: context
        ), candidate.exercise.id != current.id
        else { return nil }

        let confidence: PlanEvolutionConfidence = {
            if candidate.state.sessionCount >= 6 && currentState.sessionCount >= 6 { return .high }
            if candidate.state.sessionCount >= 4 { return .moderate }
            return .low
        }()
        return (current, candidate.exercise, confidence)
    }

    // MARK: - Exercise-order optimization

    func reorderSuggestions(
        for plan: WorkoutPlan,
        context: ExerciseSelectionContext
    ) -> [ReorderSuggestion] {
        var suggestions: [ReorderSuggestion] = []
        for day in plan.days {
            guard day.exercises.count >= 3 else { continue }
            let ordered = day.exercises.sorted { $0.order < $1.order }

            for (idx, planned) in ordered.enumerated() where idx >= 2 {
                guard let ex = library.exercise(byId: planned.exerciseId),
                      ex.category == .compound
                else { continue }
                guard let state = context.progressionStates.first(where: { $0.exerciseId == ex.id }),
                      state.plateauStatus == .progressing,
                      state.sessionCount >= 3
                else { continue }
                let earlierAreAccessories = ordered.prefix(idx).allSatisfy {
                    (library.exercise(byId: $0.exerciseId)?.category ?? .isolation) != .compound
                }
                guard earlierAreAccessories else { continue }

                let confidence: PlanEvolutionConfidence = state.sessionCount >= 5 ? .moderate : .low
                suggestions.append(ReorderSuggestion(
                    dayId: day.id,
                    dayName: day.name,
                    exerciseIdToPromote: ex.id,
                    exerciseName: ex.name,
                    reason: "\(ex.name) is a progressing key lift placed late in \(day.name). Moving it earlier should let it benefit from fresh energy.",
                    confidence: confidence
                ))
                break
            }
        }
        return suggestions
    }

    // MARK: - Helpers

    private func isEquipmentAvailable(_ ex: Exercise, location: LocationType, profile: UserProfile) -> Bool {
        switch location {
        case .gym, .anywhere: break
        case .homeGym:
            if ex.locationType == .gym { return false }
        case .homeNoEquipment:
            if ex.locationType != .homeNoEquipment && ex.locationType != .anywhere { return false }
        }
        if !profile.availableEquipment.isEmpty && profile.trainingLocation != .gym {
            return ex.equipment.contains(.none) || ex.equipment.contains(where: { profile.availableEquipment.contains($0) })
        }
        return true
    }

    private func isRiskyGivenInjuries(_ ex: Exercise, profile: UserProfile) -> Bool {
        guard !profile.injuries.isEmpty else { return false }
        for injury in profile.injuries {
            let i = injury.lowercased()
            if i.contains("shoulder") && (ex.movementPattern == .verticalPush || ex.movementPattern == .horizontalPush) && !ex.isJointFriendly { return true }
            if i.contains("knee") && (ex.movementPattern == .squat || ex.movementPattern == .lunge || ex.movementPattern == .plyometric) && !ex.isJointFriendly { return true }
            if i.contains("back") && ex.movementPattern == .hipHinge && !ex.isJointFriendly { return true }
            if i.contains("elbow") && ex.movementPattern == .extension_ && !ex.isJointFriendly { return true }
            if i.contains("wrist") && (ex.movementPattern == .horizontalPush || ex.movementPattern == .verticalPush) && !ex.isJointFriendly { return true }
        }
        return false
    }

    private func historicalState(for ex: Exercise, in context: ExerciseSelectionContext) -> ExerciseProgressionState? {
        if let s = context.progressionStates.first(where: { $0.exerciseId == ex.id }) { return s }
        guard let family = familyService.family(forExercise: ex.id) else { return nil }
        let familyStates = context.progressionStates.filter { family.memberIds.contains($0.exerciseId) }
        if let progressing = familyStates.first(where: { $0.plateauStatus == .progressing }) {
            return progressing
        }
        return familyStates.first
    }

    // MARK: - Reason building

    private static func buildPrimaryReason(
        candidate: Exercise,
        original: Exercise,
        originalRole: ReplacementRole,
        candidateRole: ReplacementRole,
        reasons: [String],
        reason: ReplacementReason,
        profile: UserProfile
    ) -> String {
        if let r = reasons.first { return r }

        switch reason {
        case .injuryAvoidance:
            return "Lower joint stress \(candidateRole.displayName.lowercased())"
        case .equipmentUnavailable:
            if candidate.isBodyweight { return "No equipment needed" }
            if candidate.locationType == .anywhere || candidate.locationType == .homeNoEquipment {
                return "Works with your home setup"
            }
        case .easier:
            return "Easier \(candidateRole.displayName.lowercased()) on the same pattern"
        case .harder:
            return "Harder progression on the same pattern"
        case .samePattern, .general:
            break
        }

        if candidate.movementPattern == original.movementPattern && candidate.primaryMuscle == original.primaryMuscle {
            return "Same pattern, same target"
        }
        if candidate.movementPattern == original.movementPattern {
            return "Same \(original.movementPattern.displayName.lowercased()) pattern"
        }
        if candidate.primaryMuscle == original.primaryMuscle {
            return "Hits \(original.primaryMuscle.displayName.lowercased()) from a different angle"
        }
        if candidate.isJointFriendly && !original.isJointFriendly {
            return "Lower joint stress alternative"
        }
        return "Alternative for \(original.primaryMuscle.displayName.lowercased())"
    }

    // Adherence heuristic: how often the user actually logged this exercise
    // when it appeared in recent sessions. Low adherence on advanced/technical
    // movements is a soft negative signal.
    private func adherenceScore(for ex: Exercise, context: ExerciseSelectionContext) -> Double {
        let recent = context.workoutHistory.prefix(10)
        guard !recent.isEmpty else { return 1.0 }
        var logged = 0
        var planned = 0
        for session in recent {
            if session.exerciseLogs.contains(where: { $0.exerciseId == ex.id }) {
                planned += 1
                if session.exerciseLogs.first(where: { $0.exerciseId == ex.id })?.sets.contains(where: { $0.isCompleted }) == true {
                    logged += 1
                }
            }
        }
        guard planned > 0 else { return 1.0 }
        return Double(logged) / Double(planned)
    }
}
