import Foundation

nonisolated struct CoachAdjustment: Identifiable, Codable, Sendable {
    let id: String
    let type: CoachAdjustmentType
    let dayId: String
    let appliedAt: Date
    let description: String
    let details: [AdjustmentDetail]
    let originalState: AdjustmentSnapshot?
    // Phase 13 — explainability metadata. All optional for backward-compatible decode.
    let driver: String?          // the strongest reason this change happened
    let expectation: String?     // what the user should expect now / how training should feel
    let scope: AdjustmentScope?  // session / week / block — decides ordering in the log

    init(
        id: String = UUID().uuidString,
        type: CoachAdjustmentType,
        dayId: String,
        appliedAt: Date = Date(),
        description: String,
        details: [AdjustmentDetail],
        originalState: AdjustmentSnapshot? = nil,
        driver: String? = nil,
        expectation: String? = nil,
        scope: AdjustmentScope? = nil
    ) {
        self.id = id
        self.type = type
        self.dayId = dayId
        self.appliedAt = appliedAt
        self.description = description
        self.details = details
        self.originalState = originalState
        self.driver = driver
        self.expectation = expectation
        self.scope = scope
    }

    // Tolerant decode so snapshots persisted before Phase 13 (which lacked
    // driver / expectation / scope) still load cleanly.
    private enum CodingKeys: String, CodingKey {
        case id, type, dayId, appliedAt, description, details, originalState
        case driver, expectation, scope
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decode(String.self, forKey: .id)
        self.type = try c.decode(CoachAdjustmentType.self, forKey: .type)
        self.dayId = try c.decode(String.self, forKey: .dayId)
        self.appliedAt = try c.decode(Date.self, forKey: .appliedAt)
        self.description = try c.decode(String.self, forKey: .description)
        self.details = try c.decode([AdjustmentDetail].self, forKey: .details)
        self.originalState = try c.decodeIfPresent(AdjustmentSnapshot.self, forKey: .originalState)
        self.driver = try c.decodeIfPresent(String.self, forKey: .driver)
        self.expectation = try c.decodeIfPresent(String.self, forKey: .expectation)
        self.scope = try c.decodeIfPresent(AdjustmentScope.self, forKey: .scope)
    }
}

nonisolated enum AdjustmentScope: String, Codable, Sendable {
    case session   // one day edited
    case week      // whole-week action (regenerate / deload)
    case block     // phase-level
}

nonisolated enum CoachAdjustmentType: String, Codable, Sendable {
    case volumeReduced
    case exerciseSwapped
    case lighterSession
    case weekRegenerated
    case deloadWeek
}

nonisolated struct AdjustmentDetail: Identifiable, Codable, Sendable {
    let id: String
    let exerciseName: String
    let change: String

    init(id: String = UUID().uuidString, exerciseName: String, change: String) {
        self.id = id
        self.exerciseName = exerciseName
        self.change = change
    }
}

nonisolated struct AdjustmentSnapshot: Codable, Sendable {
    let exercises: [PlannedExercise]
}

struct VolumeReductionPreview: Sendable {
    let dayName: String
    let reductions: [ExerciseReduction]
    let originalTotalSets: Int
    let newTotalSets: Int
    let estimatedTimeSaved: Int
}

struct ExerciseReduction: Identifiable, Sendable {
    let id: String
    let exerciseName: String
    let exerciseId: String
    let originalSets: Int
    let newSets: Int
    let isAccessory: Bool

    init(id: String = UUID().uuidString, exerciseName: String, exerciseId: String, originalSets: Int, newSets: Int, isAccessory: Bool) {
        self.id = id
        self.exerciseName = exerciseName
        self.exerciseId = exerciseId
        self.originalSets = originalSets
        self.newSets = newSets
        self.isAccessory = isAccessory
    }
}

struct LighterSessionPreview: Sendable {
    let dayName: String
    let changes: [LighterChange]
    let rpeReduction: Double
    let estimatedTimeSaved: Int
}

struct LighterChange: Identifiable, Sendable {
    let id: String
    let exerciseName: String
    let change: String

    init(id: String = UUID().uuidString, exerciseName: String, change: String) {
        self.id = id
        self.exerciseName = exerciseName
        self.change = change
    }
}

struct WeekRegenerationPreview: Sendable {
    let originalDays: [DayPreviewSummary]
    let newDays: [DayPreviewSummary]
    let changes: [WeekChangeItem]
    let reason: String
}

struct DeloadWeekPreview: Sendable {
    let originalDays: [DayPreviewSummary]
    let deloadDays: [DayPreviewSummary]
    let volumeReductionPercent: Int
    let rpeReduction: Double
    let estimatedTimeSaved: Int
    let reason: String
}

struct DayPreviewSummary: Identifiable, Sendable {
    let id: String
    let name: String
    let exerciseCount: Int
    let totalSets: Int
    let estimatedMinutes: Int
    let muscles: [String]

    init(id: String = UUID().uuidString, name: String, exerciseCount: Int, totalSets: Int, estimatedMinutes: Int, muscles: [String]) {
        self.id = id
        self.name = name
        self.exerciseCount = exerciseCount
        self.totalSets = totalSets
        self.estimatedMinutes = estimatedMinutes
        self.muscles = muscles
    }
}

struct WeekChangeItem: Identifiable, Sendable {
    let id: String
    let dayName: String
    let change: String
    let type: WeekChangeType

    init(id: String = UUID().uuidString, dayName: String, change: String, type: WeekChangeType) {
        self.id = id
        self.dayName = dayName
        self.change = change
        self.type = type
    }
}

nonisolated enum WeekChangeType: Sendable {
    case exerciseChanged
    case volumeChanged
    case emphasisChanged
    case removed
    case added
}

struct ExerciseSwapOption: Identifiable, Sendable {
    let id: String
    let exercise: Exercise
    let reason: String
    let tags: [String]

    init(id: String = UUID().uuidString, exercise: Exercise, reason: String, tags: [String]) {
        self.id = id
        self.exercise = exercise
        self.reason = reason
        self.tags = tags
    }
}

struct CoachActionManager {
    private let library = ExerciseLibrary.shared

    func previewVolumeReduction(plan: WorkoutPlan, dayId: String, recoveryScore: Int) -> VolumeReductionPreview? {
        guard let dayIndex = plan.days.firstIndex(where: { $0.id == dayId }) else { return nil }
        let day = plan.days[dayIndex]

        var reductions: [ExerciseReduction] = []
        var totalRemoved = 0

        let classified = day.exercises.map { planned -> (PlannedExercise, Bool) in
            let exercise = library.exercise(byId: planned.exerciseId)
            let isCompound = exercise?.category == .compound
            return (planned, !isCompound)
        }

        let accessories = classified.filter(\.1).map(\.0)
        let maxReductions = recoveryScore < 50 ? 3 : 2

        for accessory in accessories.suffix(maxReductions) {
            let exercise = library.exercise(byId: accessory.exerciseId)
            let setsToRemove = accessory.sets > 2 ? 1 : 0
            if setsToRemove > 0 {
                reductions.append(ExerciseReduction(
                    exerciseName: exercise?.name ?? accessory.exerciseId,
                    exerciseId: accessory.exerciseId,
                    originalSets: accessory.sets,
                    newSets: accessory.sets - setsToRemove,
                    isAccessory: true
                ))
                totalRemoved += setsToRemove
            }
        }

        if reductions.isEmpty { return nil }

        let originalTotal = day.exercises.reduce(0) { $0 + $1.sets }
        return VolumeReductionPreview(
            dayName: day.name,
            reductions: reductions,
            originalTotalSets: originalTotal,
            newTotalSets: originalTotal - totalRemoved,
            estimatedTimeSaved: totalRemoved * 3
        )
    }

    func applyVolumeReduction(plan: inout WorkoutPlan, dayId: String, preview: VolumeReductionPreview) -> CoachAdjustment? {
        guard let dayIndex = plan.days.firstIndex(where: { $0.id == dayId }) else { return nil }
        let snapshot = AdjustmentSnapshot(exercises: plan.days[dayIndex].exercises)

        var details: [AdjustmentDetail] = []
        for reduction in preview.reductions {
            if let exIdx = plan.days[dayIndex].exercises.firstIndex(where: { $0.exerciseId == reduction.exerciseId }) {
                plan.days[dayIndex].exercises[exIdx].sets = reduction.newSets
                details.append(AdjustmentDetail(
                    exerciseName: reduction.exerciseName,
                    change: "\(reduction.originalSets) → \(reduction.newSets) sets"
                ))
            }
        }

        let dayName = plan.days[dayIndex].name
        return CoachAdjustment(
            type: .volumeReduced,
            dayId: dayId,
            description: "Volume reduced on \(dayName): \(preview.originalTotalSets) → \(preview.newTotalSets) sets",
            details: details,
            originalState: snapshot,
            driver: "Recovery was trending low — less accessory work protects the compound work that matters.",
            expectation: "\(dayName) should feel noticeably easier. Quality over quantity on the remaining sets.",
            scope: .session
        )
    }

    func previewLighterSession(plan: WorkoutPlan, dayId: String) -> LighterSessionPreview? {
        guard let dayIndex = plan.days.firstIndex(where: { $0.id == dayId }) else { return nil }
        let day = plan.days[dayIndex]

        var changes: [LighterChange] = []
        var accessoryReduction = 0

        for planned in day.exercises {
            let exercise = library.exercise(byId: planned.exerciseId)
            let name = exercise?.name ?? planned.exerciseId
            let isCompound = exercise?.category == .compound

            if isCompound {
                if let rpe = planned.rpe, rpe > 6 {
                    changes.append(LighterChange(exerciseName: name, change: "RPE \(Int(rpe)) → \(Int(rpe - 1))"))
                } else {
                    changes.append(LighterChange(exerciseName: name, change: "Reduce load ~15%"))
                }
            } else {
                if planned.sets > 2 {
                    changes.append(LighterChange(exerciseName: name, change: "\(planned.sets) → \(planned.sets - 1) sets"))
                    accessoryReduction += 1
                }
            }
        }

        if changes.isEmpty { return nil }

        return LighterSessionPreview(
            dayName: day.name,
            changes: changes,
            rpeReduction: 1.0,
            estimatedTimeSaved: accessoryReduction * 3 + 5
        )
    }

    func applyLighterSession(plan: inout WorkoutPlan, dayId: String) -> CoachAdjustment? {
        guard let dayIndex = plan.days.firstIndex(where: { $0.id == dayId }) else { return nil }
        let snapshot = AdjustmentSnapshot(exercises: plan.days[dayIndex].exercises)

        var details: [AdjustmentDetail] = []

        for i in plan.days[dayIndex].exercises.indices {
            let exercise = library.exercise(byId: plan.days[dayIndex].exercises[i].exerciseId)
            let name = exercise?.name ?? plan.days[dayIndex].exercises[i].exerciseId
            let isCompound = exercise?.category == .compound

            if isCompound {
                if let rpe = plan.days[dayIndex].exercises[i].rpe, rpe > 6 {
                    let newRpe = rpe - 1
                    plan.days[dayIndex].exercises[i].rpe = newRpe
                    details.append(AdjustmentDetail(exerciseName: name, change: "RPE \(Int(rpe)) → \(Int(newRpe))"))
                } else {
                    plan.days[dayIndex].exercises[i].notes = "Coach: reduce load ~15%"
                    details.append(AdjustmentDetail(exerciseName: name, change: "Reduce load ~15%"))
                }
            } else {
                if plan.days[dayIndex].exercises[i].sets > 2 {
                    let oldSets = plan.days[dayIndex].exercises[i].sets
                    plan.days[dayIndex].exercises[i].sets = oldSets - 1
                    details.append(AdjustmentDetail(exerciseName: name, change: "\(oldSets) → \(oldSets - 1) sets"))
                }
            }
        }

        let dayName = plan.days[dayIndex].name
        return CoachAdjustment(
            type: .lighterSession,
            dayId: dayId,
            description: "Lighter session staged for \(dayName)",
            details: details,
            originalState: snapshot,
            driver: "Fatigue signals were stacking — one deliberately lighter session protects the week.",
            expectation: "\(dayName) should feel 1–2 RPE easier. Expect to leave the gym with reps in reserve.",
            scope: .session
        )
    }

    func swapExerciseOptions(
        for exerciseId: String,
        in plan: WorkoutPlan,
        dayId: String,
        profile: UserProfile,
        progressionStates: [ExerciseProgressionState] = [],
        workoutHistory: [WorkoutSession] = [],
        recoveryScore: Int = 75,
        phase: TrainingPhase = .build
    ) -> [ExerciseSwapOption] {
        guard library.exercise(byId: exerciseId) != nil else { return [] }

        let selection = ExerciseSelectionEngine()
        let context = ExerciseSelectionContext(
            profile: profile,
            progressionStates: progressionStates,
            workoutHistory: workoutHistory,
            recoveryScore: recoveryScore,
            phase: phase
        )
        let ranked = selection.rankedSubstitutes(for: exerciseId, context: context, reason: .general, limit: 6)

        return ranked.map { scored in
            ExerciseSwapOption(
                exercise: scored.exercise,
                reason: scored.reasons.first ?? "Alternative",
                tags: scored.tags
            )
        }
    }

    func applyExerciseSwap(plan: inout WorkoutPlan, dayId: String, oldExerciseId: String, newExercise: Exercise) -> CoachAdjustment? {
        guard let dayIndex = plan.days.firstIndex(where: { $0.id == dayId }) else { return nil }
        guard let exIndex = plan.days[dayIndex].exercises.firstIndex(where: { $0.exerciseId == oldExerciseId }) else { return nil }

        let snapshot = AdjustmentSnapshot(exercises: plan.days[dayIndex].exercises)
        let oldName = library.exercise(byId: oldExerciseId)?.name ?? oldExerciseId

        plan.days[dayIndex].exercises[exIndex].exerciseId = newExercise.id

        return CoachAdjustment(
            type: .exerciseSwapped,
            dayId: dayId,
            description: "Swapped \(oldName) → \(newExercise.name)",
            details: [AdjustmentDetail(exerciseName: newExercise.name, change: "Replaced \(oldName)")],
            originalState: snapshot,
            driver: "\(oldName) wasn't moving — \(newExercise.name) opens a fresher stimulus on the same pattern.",
            expectation: "Start lighter on \(newExercise.name) to calibrate, then rebuild load from there.",
            scope: .session
        )
    }

    func undoAdjustment(plan: inout WorkoutPlan, adjustment: CoachAdjustment) -> Bool {
        guard let snapshot = adjustment.originalState else { return false }
        guard let dayIndex = plan.days.firstIndex(where: { $0.id == adjustment.dayId }) else { return false }
        plan.days[dayIndex].exercises = snapshot.exercises
        return true
    }

    // MARK: - Week-Level Actions

    func previewWeekRegeneration(plan: WorkoutPlan, profile: UserProfile, muscleBalance: [MuscleBalanceEntry], recentSessions: [WorkoutSession], recoveryScore: Int) -> WeekRegenerationPreview {
        let generator = PlanGenerator()
        let newPlan = generator.generate(for: profile, muscleBalance: muscleBalance, recentSessions: recentSessions, recoveryScore: recoveryScore)

        let originalSummaries = plan.days.map { daySummary($0) }
        let newSummaries = newPlan.days.map { daySummary($0) }

        var changes: [WeekChangeItem] = []

        for (index, newDay) in newPlan.days.enumerated() {
            if index < plan.days.count {
                let oldDay = plan.days[index]
                let oldSets = oldDay.exercises.reduce(0) { $0 + $1.sets }
                let newSets = newDay.exercises.reduce(0) { $0 + $1.sets }
                if oldSets != newSets {
                    changes.append(WeekChangeItem(dayName: newDay.name, change: "\(oldSets) → \(newSets) sets", type: .volumeChanged))
                }
                let oldIds = Set(oldDay.exercises.map(\.exerciseId))
                let newIds = Set(newDay.exercises.map(\.exerciseId))
                let swapped = newIds.subtracting(oldIds)
                for exId in swapped.prefix(2) {
                    let name = library.exercise(byId: exId)?.name ?? exId
                    changes.append(WeekChangeItem(dayName: newDay.name, change: "Added \(name)", type: .exerciseChanged))
                }
                let oldMuscles = Set(oldDay.focusMuscles.map(\.displayName))
                let newMuscles = Set(newDay.focusMuscles.map(\.displayName))
                if oldMuscles != newMuscles {
                    let added = newMuscles.subtracting(oldMuscles)
                    if !added.isEmpty {
                        changes.append(WeekChangeItem(dayName: newDay.name, change: "+\(added.joined(separator: ", "))", type: .emphasisChanged))
                    }
                }
            }
        }

        if changes.isEmpty {
            changes.append(WeekChangeItem(dayName: "Overall", change: "Optimized exercise selection and volume", type: .volumeChanged))
        }

        var reasons: [String] = []
        let undertrained = muscleBalance.filter { $0.percentOfAverage < 0.8 }
        if !undertrained.isEmpty {
            reasons.append("\(undertrained.first!.muscle) volume is below average")
        }
        if recoveryScore < 60 {
            reasons.append("recovery score is low (\(recoveryScore)%)")
        }
        if reasons.isEmpty {
            reasons.append("optimizing for your current progress and balance")
        }

        return WeekRegenerationPreview(
            originalDays: originalSummaries,
            newDays: newSummaries,
            changes: changes,
            reason: "Regenerating because " + reasons.joined(separator: " and ") + "."
        )
    }

    func applyWeekRegeneration(plan: inout WorkoutPlan, profile: UserProfile, muscleBalance: [MuscleBalanceEntry], recentSessions: [WorkoutSession], recoveryScore: Int) -> (CoachAdjustment, WorkoutPlan)? {
        let generator = PlanGenerator()
        let oldPlan = plan
        let newPlan = generator.generate(for: profile, muscleBalance: muscleBalance, recentSessions: recentSessions, recoveryScore: recoveryScore)

        var details: [AdjustmentDetail] = []
        for (index, newDay) in newPlan.days.enumerated() {
            if index < oldPlan.days.count {
                let oldSets = oldPlan.days[index].exercises.reduce(0) { $0 + $1.sets }
                let newSets = newDay.exercises.reduce(0) { $0 + $1.sets }
                if oldSets != newSets {
                    details.append(AdjustmentDetail(exerciseName: newDay.name, change: "\(oldSets) → \(newSets) sets"))
                }
            }
        }
        if details.isEmpty {
            details.append(AdjustmentDetail(exerciseName: "Week", change: "Regenerated with updated intelligence"))
        }

        plan = newPlan

        let adjustment = CoachAdjustment(
            type: .weekRegenerated,
            dayId: "week-all",
            description: "Week regenerated by Coach",
            details: details,
            originalState: nil,
            driver: "Coach rebalanced volume and selection around your recent signal — not a reset, a recalibration.",
            expectation: "Expect sharper focus on lagging muscles and a cleaner distribution across your days.",
            scope: .week
        )

        return (adjustment, oldPlan)
    }

    func previewDeloadWeek(plan: WorkoutPlan) -> DeloadWeekPreview {
        let originalSummaries = plan.days.map { daySummary($0) }
        var deloadSummaries: [DayPreviewSummary] = []
        var totalOriginalSets = 0
        var totalDeloadSets = 0

        for day in plan.days {
            let origSets = day.exercises.reduce(0) { $0 + $1.sets }
            totalOriginalSets += origSets

            var deloadExCount = day.exercises.count
            var deloadSetCount = 0
            for ex in day.exercises {
                let isCompound = library.exercise(byId: ex.exerciseId)?.category == .compound
                if isCompound {
                    deloadSetCount += max(2, ex.sets - 1)
                } else {
                    let newSets = max(1, ex.sets - 1)
                    if newSets <= 1 && ex.sets > 2 {
                        deloadExCount -= 1
                    } else {
                        deloadSetCount += newSets
                    }
                }
            }
            totalDeloadSets += deloadSetCount

            deloadSummaries.append(DayPreviewSummary(
                name: day.name,
                exerciseCount: deloadExCount,
                totalSets: deloadSetCount,
                estimatedMinutes: max(20, day.estimatedMinutes - 15),
                muscles: day.focusMuscles.map(\.displayName)
            ))
        }

        let reductionPercent = totalOriginalSets > 0 ? Int(Double(totalOriginalSets - totalDeloadSets) / Double(totalOriginalSets) * 100) : 40
        let timeSaved = plan.days.count * 12

        return DeloadWeekPreview(
            originalDays: originalSummaries,
            deloadDays: deloadSummaries,
            volumeReductionPercent: reductionPercent,
            rpeReduction: 1.5,
            estimatedTimeSaved: timeSaved,
            reason: "A deload week reduces accumulated fatigue and lets your body supercompensate for stronger performance next week."
        )
    }

    func applyDeloadWeek(plan: inout WorkoutPlan) -> (CoachAdjustment, WorkoutPlan)? {
        let oldPlan = plan
        var details: [AdjustmentDetail] = []

        for dayIndex in plan.days.indices {
            var indicesToRemove: [Int] = []
            for exIndex in plan.days[dayIndex].exercises.indices {
                let ex = plan.days[dayIndex].exercises[exIndex]
                let exercise = library.exercise(byId: ex.exerciseId)
                let isCompound = exercise?.category == .compound

                if isCompound {
                    let oldSets = plan.days[dayIndex].exercises[exIndex].sets
                    plan.days[dayIndex].exercises[exIndex].sets = max(2, oldSets - 1)
                    if let rpe = plan.days[dayIndex].exercises[exIndex].rpe, rpe > 5 {
                        plan.days[dayIndex].exercises[exIndex].rpe = rpe - 1.5
                    }
                    let name = exercise?.name ?? ex.exerciseId
                    details.append(AdjustmentDetail(exerciseName: name, change: "\(oldSets) → \(max(2, oldSets - 1)) sets, lower effort"))
                } else {
                    let oldSets = plan.days[dayIndex].exercises[exIndex].sets
                    let newSets = max(1, oldSets - 1)
                    if newSets <= 1 && oldSets > 2 {
                        indicesToRemove.append(exIndex)
                    } else {
                        plan.days[dayIndex].exercises[exIndex].sets = newSets
                        if let rpe = plan.days[dayIndex].exercises[exIndex].rpe, rpe > 5 {
                            plan.days[dayIndex].exercises[exIndex].rpe = rpe - 1.5
                        }
                    }
                }
            }

            for idx in indicesToRemove.sorted().reversed() {
                let name = library.exercise(byId: plan.days[dayIndex].exercises[idx].exerciseId)?.name ?? "Accessory"
                details.append(AdjustmentDetail(exerciseName: name, change: "Removed for deload"))
                plan.days[dayIndex].exercises.remove(at: idx)
            }

            plan.days[dayIndex].estimatedMinutes = max(20, plan.days[dayIndex].estimatedMinutes - 15)
        }

        let adjustment = CoachAdjustment(
            type: .deloadWeek,
            dayId: "week-all",
            description: "Deload week applied",
            details: details,
            originalState: nil,
            driver: "Accumulated fatigue earned a deload — lower stress now sets up the next push block.",
            expectation: "Training should feel clearly lighter this week. Leave reps in reserve everywhere.",
            scope: .block
        )

        return (adjustment, oldPlan)
    }

    private func daySummary(_ day: WorkoutDay) -> DayPreviewSummary {
        DayPreviewSummary(
            name: day.name,
            exerciseCount: day.exercises.count,
            totalSets: day.exercises.reduce(0) { $0 + $1.sets },
            estimatedMinutes: day.estimatedMinutes,
            muscles: day.focusMuscles.map(\.displayName)
        )
    }
}
