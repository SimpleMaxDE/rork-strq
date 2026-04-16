import Foundation

struct StartingLoadEngine {
    private let library = ExerciseLibrary.shared
    private let progressionEngine = ProgressionEngine()

    struct LoadSuggestion: Sendable {
        let suggestedWeight: Double
        let repTarget: String
        let confidence: LoadConfidence
        let basis: String
        let isEditable: Bool

        var formattedWeight: String {
            if suggestedWeight == 0 { return "BW" }
            if suggestedWeight.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(suggestedWeight)) kg"
            }
            return String(format: "%.1f kg", suggestedWeight)
        }
    }

    enum LoadConfidence: String, Sendable {
        case high
        case medium
        case low

        var label: String {
            switch self {
            case .high: "Based on history"
            case .medium: "Estimated"
            case .low: "Suggested start"
            }
        }
    }

    func suggestStartingLoad(
        exerciseId: String,
        profile: UserProfile,
        sessions: [WorkoutSession],
        progressionStates: [ExerciseProgressionState],
        planned: PlannedExercise? = nil
    ) -> LoadSuggestion? {
        guard let exercise = library.exercise(byId: exerciseId) else { return nil }

        if let state = progressionStates.first(where: { $0.exerciseId == exerciseId }),
           state.sessionCount > 0, state.lastWeight > 0 {
            return fromProgression(state: state, exercise: exercise, planned: planned)
        }

        if let directHistory = findDirectHistory(exerciseId: exerciseId, sessions: sessions) {
            return directHistory
        }

        if let transferred = transferFromSimilar(exercise: exercise, profile: profile, sessions: sessions, progressionStates: progressionStates) {
            return transferred
        }

        return estimateFromProfile(exercise: exercise, profile: profile, planned: planned)
    }

    func nextSessionSuggestion(
        exerciseId: String,
        profile: UserProfile,
        sessions: [WorkoutSession],
        progressionStates: [ExerciseProgressionState],
        phase: TrainingPhase
    ) -> NextSessionGuidance? {
        guard let exercise = library.exercise(byId: exerciseId) else { return nil }
        let family = progressionEngine.classifyExerciseFamily(exercise)

        if let state = progressionStates.first(where: { $0.exerciseId == exerciseId }),
           state.sessionCount >= 1 {
            return buildGuidance(state: state, family: family, exercise: exercise, phase: phase, profile: profile)
        }

        return nil
    }

    private func fromProgression(state: ExerciseProgressionState, exercise: Exercise, planned: PlannedExercise?) -> LoadSuggestion {
        let weight = state.suggestedNextWeight ?? state.lastWeight
        let reps = state.suggestedNextReps ?? planned?.reps ?? "\(state.lastReps)"
        return LoadSuggestion(
            suggestedWeight: weight,
            repTarget: reps,
            confidence: .high,
            basis: "Based on \(state.sessionCount) sessions",
            isEditable: true
        )
    }

    private func findDirectHistory(exerciseId: String, sessions: [WorkoutSession]) -> LoadSuggestion? {
        let logs = sessions
            .filter(\.isCompleted)
            .sorted { $0.startTime > $1.startTime }
            .compactMap { $0.exerciseLogs.first { $0.exerciseId == exerciseId && $0.isCompleted } }

        guard let last = logs.first else { return nil }
        let bestSet = last.sets.filter(\.isCompleted).max(by: { $0.weight * Double($0.reps) < $1.weight * Double($1.reps) })
        guard let best = bestSet, best.weight > 0 else { return nil }

        return LoadSuggestion(
            suggestedWeight: best.weight,
            repTarget: "\(best.reps)",
            confidence: .high,
            basis: "Last session performance",
            isEditable: true
        )
    }

    private func transferFromSimilar(
        exercise: Exercise,
        profile: UserProfile,
        sessions: [WorkoutSession],
        progressionStates: [ExerciseProgressionState]
    ) -> LoadSuggestion? {
        let similar = progressionStates.filter { state in
            guard let ex = library.exercise(byId: state.exerciseId) else { return false }
            return ex.primaryMuscle == exercise.primaryMuscle &&
                   ex.movementPattern == exercise.movementPattern &&
                   state.lastWeight > 0
        }

        guard let best = similar.max(by: { $0.lastWeight < $1.lastWeight }) else { return nil }
        guard let sourceEx = library.exercise(byId: best.exerciseId) else { return nil }

        let ratio = transferRatio(from: sourceEx, to: exercise)
        let transferred = roundToNearest(best.lastWeight * ratio, increment: incrementFor(exercise))

        guard transferred > 0 else { return nil }

        return LoadSuggestion(
            suggestedWeight: transferred,
            repTarget: "\(best.lastReps)",
            confidence: .medium,
            basis: "Estimated from \(sourceEx.name)",
            isEditable: true
        )
    }

    private func estimateFromProfile(exercise: Exercise, profile: UserProfile, planned: PlannedExercise?) -> LoadSuggestion? {
        if exercise.isBodyweight || exercise.category == .bodyweight {
            return LoadSuggestion(
                suggestedWeight: 0,
                repTarget: planned?.reps ?? bodyweightRepTarget(exercise: exercise, profile: profile),
                confidence: .low,
                basis: "Bodyweight exercise",
                isEditable: true
            )
        }

        if exercise.category == .mobility || exercise.category == .warmup || exercise.category == .recovery || exercise.category == .pilates {
            return nil
        }

        let baseWeight = estimateBaseWeight(exercise: exercise, profile: profile)
        guard baseWeight > 0 else { return nil }

        let reps = planned?.reps ?? defaultRepTarget(exercise: exercise, profile: profile)

        return LoadSuggestion(
            suggestedWeight: baseWeight,
            repTarget: reps,
            confidence: .low,
            basis: "Suggested for \(profile.trainingLevel.shortName.lowercased()) level",
            isEditable: true
        )
    }

    private func estimateBaseWeight(exercise: Exercise, profile: UserProfile) -> Double {
        let bw = profile.weightKg
        let genderFactor: Double = profile.gender == .female ? 0.55 : 1.0
        let levelFactor: Double = {
            switch profile.trainingLevel {
            case .beginner: return 0.6
            case .intermediate: return 0.85
            case .advanced: return 1.1
            }
        }()

        let family = progressionEngine.classifyExerciseFamily(exercise)
        let baseFraction: Double = {
            switch family {
            case .heavyCompound:
                switch exercise.movementPattern {
                case .squat: return 0.7
                case .hipHinge: return 0.8
                case .horizontalPush: return 0.5
                case .verticalPush: return 0.35
                default: return 0.5
                }
            case .hypertrophyCompound: return 0.35
            case .machineExercise: return 0.4
            case .isolationLift: return 0.12
            case .bodyweightExercise, .calisthenicsProgression: return 0
            case .mobilityCore: return 0
            }
        }()

        let raw = bw * baseFraction * genderFactor * levelFactor
        let increment = incrementFor(exercise)
        return roundToNearest(raw, increment: increment)
    }

    private func incrementFor(_ exercise: Exercise) -> Double {
        if exercise.equipment.contains(.barbell) { return 2.5 }
        if exercise.equipment.contains(.dumbbell) { return 2.0 }
        if exercise.equipment.contains(.cable) || exercise.equipment.contains(.machine) { return 2.5 }
        if exercise.equipment.contains(.kettlebell) { return 4.0 }
        return 2.5
    }

    private func roundToNearest(_ value: Double, increment: Double) -> Double {
        guard increment > 0 else { return value }
        return (value / increment).rounded() * increment
    }

    private func transferRatio(from source: Exercise, to target: Exercise) -> Double {
        if source.equipment.contains(.barbell) && target.equipment.contains(.dumbbell) { return 0.35 }
        if source.equipment.contains(.dumbbell) && target.equipment.contains(.barbell) { return 2.5 }
        if source.equipment.contains(.barbell) && target.equipment.contains(.machine) { return 0.85 }
        if source.equipment.contains(.machine) && target.equipment.contains(.barbell) { return 1.1 }
        return 0.85
    }

    private func bodyweightRepTarget(exercise: Exercise, profile: UserProfile) -> String {
        switch profile.trainingLevel {
        case .beginner: return "6-8"
        case .intermediate: return "8-12"
        case .advanced: return "12-15"
        }
    }

    private func defaultRepTarget(exercise: Exercise, profile: UserProfile) -> String {
        switch profile.goal {
        case .strength: return exercise.category == .compound ? "3-5" : "6-8"
        case .muscleGain: return exercise.category == .compound ? "6-10" : "10-15"
        case .fatLoss: return "10-15"
        case .endurance: return "15-20"
        default: return exercise.category == .compound ? "8-10" : "10-12"
        }
    }

    private func buildGuidance(
        state: ExerciseProgressionState,
        family: ExerciseFamily,
        exercise: Exercise,
        phase: TrainingPhase,
        profile: UserProfile
    ) -> NextSessionGuidance {
        let action: String
        let detail: String
        let icon: String
        let color: String

        switch state.recommendedStrategy {
        case .loadFirst:
            let increment = family.loadIncrementKg > 0 ? family.loadIncrementKg : 2.5
            action = "Increase weight to \(String(format: "%.1f", state.lastWeight + increment)) kg"
            detail = "Keep reps at \(state.lastReps). Strong enough to progress."
            icon = "arrow.up.circle.fill"
            color = "green"
        case .repFirst:
            action = "Stay at \(String(format: "%.1f", state.lastWeight)) kg, aim for \(state.lastReps + 1)-\(state.lastReps + 2) reps"
            detail = "Build rep strength before adding load."
            icon = "plus.circle.fill"
            color = "blue"
        case .doubleProgression:
            let topRep = exercise.category == .compound ? 12 : 15
            if state.lastReps >= topRep {
                action = "Increase weight, drop to \(max(6, topRep - 4)) reps"
                detail = "You hit the top of the range. Time to add load."
                icon = "arrow.up.circle.fill"
                color = "green"
            } else {
                action = "Stay at \(String(format: "%.1f", state.lastWeight)) kg, target \(state.lastReps + 1)-\(min(state.lastReps + 3, topRep)) reps"
                detail = "Work toward top of rep range before increasing."
                icon = "arrow.right.circle.fill"
                color = "blue"
            }
        case .variationProgression:
            action = "Progress to a harder variation"
            detail = "You've mastered this movement. Time to level up."
            icon = "arrow.up.forward.circle.fill"
            color = "purple"
        case .tempoProgression:
            action = "Same weight, slower tempo or add pauses"
            detail = "Increase time under tension for new stimulus."
            icon = "clock.circle.fill"
            color = "teal"
        case .holdAndConsolidate:
            action = "Repeat at \(String(format: "%.1f", state.lastWeight)) kg × \(state.lastReps)"
            detail = phase == .deload ? "Deload phase — maintain, don't push." : "Consolidate before progressing."
            icon = "pause.circle.fill"
            color = "orange"
        case .deloadAndRebuild:
            let deloadWeight = state.lastWeight * 0.85
            action = "Reduce to \(String(format: "%.1f", deloadWeight)) kg and rebuild"
            detail = "Performance dropped. Reset with better form."
            icon = "arrow.down.circle.fill"
            color = "red"
        }

        return NextSessionGuidance(
            exerciseId: state.exerciseId,
            action: action,
            detail: detail,
            icon: icon,
            color: color,
            strategy: state.recommendedStrategy,
            plateauStatus: state.plateauStatus
        )
    }
}

nonisolated struct NextSessionGuidance: Identifiable, Sendable {
    let id: String
    let exerciseId: String
    let action: String
    let detail: String
    let icon: String
    let color: String
    let strategy: ProgressionStrategy
    let plateauStatus: PlateauStatus

    init(
        id: String = UUID().uuidString,
        exerciseId: String,
        action: String,
        detail: String,
        icon: String,
        color: String,
        strategy: ProgressionStrategy,
        plateauStatus: PlateauStatus
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.action = action
        self.detail = detail
        self.icon = icon
        self.color = color
        self.strategy = strategy
        self.plateauStatus = plateauStatus
    }
}
