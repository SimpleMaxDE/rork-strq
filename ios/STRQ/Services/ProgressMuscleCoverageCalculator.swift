import Foundation

nonisolated enum ProgressTrainingDistributionCategory: String, Codable, CaseIterable, Sendable {
    case push
    case pull
    case legs
    case core
    case posterior
}

nonisolated enum ProgressMuscleCoverageConfidenceState: String, Codable, CaseIterable, Sendable {
    case locked
    case baselineForming
    case earlySignal
    case readable
    case highConfidence
}

nonisolated struct ProgressMuscleCoverageResult: Sendable, Equatable {
    let muscleGroupVolume: [String: Double]
    let broadCategoryVolume: [String: Double]
    let unresolvedExerciseIds: [String]
    let completedExerciseCount: Int
    let completedSetCount: Int
    let loadedExerciseCount: Int
    let exposureFallbackExerciseCount: Int

    var hasCoverage: Bool {
        !muscleGroupVolume.isEmpty
    }
}

nonisolated enum ProgressMuscleCoverageCalculator {
    static let secondaryMuscleWeight: Double = 0.35
    static let progressDisplayMuscleNames = ["Chest", "Back", "Shoulders", "Quads", "Hamstrings", "Glutes", "Arms", "Abs"]

    static func calculate(
        for session: WorkoutSession,
        library: ExerciseLibrary = .shared
    ) -> ProgressMuscleCoverageResult {
        var muscleVolume: [String: Double] = [:]
        var categoryVolume: [String: Double] = [:]
        var unresolvedExerciseIds: Set<String> = []
        var completedExerciseCount = 0
        var completedSetCount = 0
        var loadedExerciseCount = 0
        var exposureFallbackExerciseCount = 0

        for log in session.exerciseLogs {
            let completedSets = log.sets.filter(\.isCompleted)
            guard !completedSets.isEmpty else { continue }

            completedExerciseCount += 1
            completedSetCount += completedSets.count

            guard let exercise = library.exercise(byId: log.exerciseId) else {
                unresolvedExerciseIds.insert(log.exerciseId)
                continue
            }

            let contribution = contributionValue(for: completedSets)
            if contribution.usedExposureFallback {
                exposureFallbackExerciseCount += 1
            } else {
                loadedExerciseCount += 1
            }

            add(
                contribution.value,
                for: exercise.primaryMuscle,
                weight: 1.0,
                muscleVolume: &muscleVolume,
                categoryVolume: &categoryVolume
            )

            let secondaryMuscles = Set(exercise.secondaryMuscles.filter { $0 != exercise.primaryMuscle })
            for muscle in secondaryMuscles {
                add(
                    contribution.value,
                    for: muscle,
                    weight: secondaryMuscleWeight,
                    muscleVolume: &muscleVolume,
                    categoryVolume: &categoryVolume
                )
            }
        }

        return ProgressMuscleCoverageResult(
            muscleGroupVolume: normalized(muscleVolume),
            broadCategoryVolume: normalized(categoryVolume),
            unresolvedExerciseIds: unresolvedExerciseIds.sorted(),
            completedExerciseCount: completedExerciseCount,
            completedSetCount: completedSetCount,
            loadedExerciseCount: loadedExerciseCount,
            exposureFallbackExerciseCount: exposureFallbackExerciseCount
        )
    }

    static func displayVolume(in muscleGroupVolume: [String: Double], displayName: String) -> Double {
        let keys = displayMuscleKeys[displayName] ?? [displayName.lowercased()]
        return keys.reduce(0.0) { total, key in
            total + (muscleGroupVolume[key] ?? 0)
        }
    }

    static func categoryVolume(from muscleGroupVolume: [String: Double]) -> [String: Double] {
        var categoryVolume: [String: Double] = [:]
        for (key, value) in muscleGroupVolume where value > 0 {
            guard let muscle = MuscleGroup(rawValue: key) else { continue }
            for category in categories(for: muscle) {
                categoryVolume[category.rawValue, default: 0] += value
            }
        }
        return normalized(categoryVolume)
    }

    static func confidenceState(
        completedSessions: Int,
        resolvedPrimaryMuscleCount: Int,
        resolvedCategoryCount: Int,
        observedWeeks: Int
    ) -> ProgressMuscleCoverageConfidenceState {
        guard completedSessions > 0 && resolvedPrimaryMuscleCount > 0 else { return .locked }
        if completedSessions <= 2 { return .baselineForming }
        if completedSessions >= 8 && observedWeeks >= 4 && resolvedCategoryCount >= ProgressTrainingDistributionCategory.allCases.count {
            return .highConfidence
        }
        if completedSessions >= 4 && observedWeeks >= 2 && resolvedCategoryCount >= 4 {
            return .readable
        }
        return .earlySignal
    }

    private static let displayMuscleKeys: [String: Set<String>] = [
        "Chest": ["chest"],
        "Back": ["back", "lats", "traps", "lowerBack"],
        "Shoulders": ["shoulders"],
        "Quads": ["quads"],
        "Hamstrings": ["hamstrings"],
        "Glutes": ["glutes"],
        "Arms": ["arms", "biceps", "triceps", "forearms"],
        "Abs": ["abs", "obliques", "coreStability", "rotationAntiRotation"]
    ]

    private static func contributionValue(for completedSets: [SetLog]) -> (value: Double, usedExposureFallback: Bool) {
        let loadedVolume = completedSets.reduce(0.0) { total, set in
            total + max(0, set.weight) * Double(max(0, set.reps))
        }

        if loadedVolume > 0 {
            return (loadedVolume, false)
        }

        // Bodyweight, mobility, and unloaded work use exposure points, not kg volume.
        return (Double(completedSets.count), true)
    }

    private static func add(
        _ contribution: Double,
        for muscle: MuscleGroup,
        weight: Double,
        muscleVolume: inout [String: Double],
        categoryVolume: inout [String: Double]
    ) {
        let weightedContribution = contribution * weight
        guard weightedContribution > 0 else { return }

        muscleVolume[muscle.rawValue, default: 0] += weightedContribution

        for category in categories(for: muscle) {
            categoryVolume[category.rawValue, default: 0] += weightedContribution
        }
    }

    private static func categories(for muscle: MuscleGroup) -> Set<ProgressTrainingDistributionCategory> {
        switch muscle {
        case .chest, .shoulders, .triceps:
            return [.push]
        case .back, .lats, .traps, .biceps, .forearms:
            return [.pull]
        case .arms:
            return [.push, .pull]
        case .quads, .calves, .adductors, .abductors, .hipFlexors, .tibialis:
            return [.legs]
        case .hamstrings, .glutes:
            return [.legs, .posterior]
        case .abs, .obliques, .coreStability, .rotationAntiRotation:
            return [.core]
        case .lowerBack:
            return [.core, .posterior]
        case .neck:
            return []
        }
    }

    private static func normalized(_ values: [String: Double]) -> [String: Double] {
        values.reduce(into: [:]) { result, item in
            let rounded = (item.value * 100).rounded() / 100
            if rounded > 0 {
                result[item.key] = rounded
            }
        }
    }
}
