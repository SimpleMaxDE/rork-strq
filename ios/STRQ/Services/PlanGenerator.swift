import Foundation

// Plan generator.
//
// This generator is driven by a weekly volume budget per muscle, not by fixed
// per-day templates. The split names the skeleton, but what actually fills each
// session is the amount of work a muscle needs for the week given the user's
// goal, level, focus muscles, recovery, and phase — then translated into
// role-based slots (anchor, secondary, accessory, isolation) with prescriptions
// shaped by the goal.
//
// The output is still a standard WorkoutPlan — no new fields on the model —
// so editing, progression, and evolution engines stay compatible.

nonisolated enum PlanExerciseRole: Sendable {
    case anchor
    case secondary
    case accessory
    case isolation

    var label: String {
        switch self {
        case .anchor: "Anchor"
        case .secondary: "Secondary"
        case .accessory: "Accessory"
        case .isolation: "Isolation"
        }
    }
}

struct PlanGenerator {
    let library = ExerciseLibrary.shared

    func generate(
        for profile: UserProfile,
        muscleBalance: [MuscleBalanceEntry] = [],
        recentSessions: [WorkoutSession] = [],
        recoveryScore: Int = 75,
        phase: TrainingPhase = .build
    ) -> WorkoutPlan {
        let split = determineSplit(profile)
        let context = PlanContext(
            profile: profile,
            muscleBalance: muscleBalance,
            recentSessions: recentSessions,
            recoveryScore: recoveryScore,
            phase: phase
        )
        let budgets = weeklyVolumeBudgets(context: context, split: split)
        let days = generateDays(split: split, context: context, budgets: budgets)
        let explanation = generateExplanation(split: split, context: context, budgets: budgets, days: days)

        return WorkoutPlan(
            name: "\(profile.name.isEmpty ? "Your" : profile.name + "'s") \(profile.goal.displayName) Plan",
            description: "\(split.name) • \(profile.daysPerWeek) days/week • \(profile.minutesPerSession) min",
            days: days,
            splitType: split.name,
            explanation: explanation
        )
    }

    // MARK: - Split selection

    private func determineSplit(_ profile: UserProfile) -> SplitConfig {
        if profile.splitPreference != .automatic {
            return splitConfig(for: profile.splitPreference, days: profile.daysPerWeek)
        }

        switch profile.daysPerWeek {
        case 1...2:
            return SplitConfig(name: "Full Body", days: generateFullBodySplit(profile.daysPerWeek))
        case 3:
            if profile.trainingLevel == .beginner {
                return SplitConfig(name: "Full Body", days: generateFullBodySplit(3))
            }
            if profile.goal == .strength {
                return SplitConfig(name: "Full Body", days: generateFullBodySplit(3))
            }
            return SplitConfig(name: "Push/Pull/Legs", days: generatePPLSplit())
        case 4:
            return SplitConfig(name: "Upper/Lower", days: generateUpperLowerSplit())
        case 5:
            if profile.trainingLevel == .beginner {
                return SplitConfig(name: "Upper/Lower", days: generateUpperLowerFiveDay())
            }
            return SplitConfig(name: "Push/Pull/Legs", days: generatePPL6Day(5))
        case 6...:
            return SplitConfig(name: "Push/Pull/Legs", days: generatePPL6Day(profile.daysPerWeek))
        default:
            return SplitConfig(name: "Full Body", days: generateFullBodySplit(3))
        }
    }

    private func splitConfig(for pref: SplitPreference, days: Int) -> SplitConfig {
        switch pref {
        case .fullBody: return SplitConfig(name: "Full Body", days: generateFullBodySplit(days))
        case .upperLower: return SplitConfig(name: "Upper/Lower", days: days >= 5 ? generateUpperLowerFiveDay() : generateUpperLowerSplit())
        case .pushPullLegs: return SplitConfig(name: "Push/Pull/Legs", days: days >= 6 ? generatePPL6Day(days) : generatePPLSplit())
        case .bodyPart, .muscleGroup: return SplitConfig(name: "Body Part", days: generateBodyPartSplit(days))
        case .automatic: return SplitConfig(name: "Full Body", days: generateFullBodySplit(days))
        }
    }

    private func generateFullBodySplit(_ days: Int) -> [DayConfig] {
        let rotations: [[MuscleGroup]] = [
            [.quads, .chest, .back, .hamstrings, .shoulders, .abs],
            [.hamstrings, .back, .chest, .glutes, .shoulders, .biceps, .triceps],
            [.quads, .chest, .back, .shoulders, .abs, .calves],
            [.glutes, .back, .shoulders, .chest, .biceps, .triceps]
        ]
        return (0..<days).map { i in
            DayConfig(name: "Full Body \(["A", "B", "C", "D"][i % 4])", muscles: rotations[i % rotations.count], index: i)
        }
    }

    private func generatePPLSplit() -> [DayConfig] {
        [
            DayConfig(name: "Push", muscles: [.chest, .shoulders, .triceps], index: 0),
            DayConfig(name: "Pull", muscles: [.back, .lats, .biceps, .forearms], index: 1),
            DayConfig(name: "Legs & Core", muscles: [.quads, .hamstrings, .glutes, .calves, .abs], index: 2),
        ]
    }

    private func generatePPL6Day(_ days: Int) -> [DayConfig] {
        let base = [
            DayConfig(name: "Push A", muscles: [.chest, .shoulders, .triceps], index: 0),
            DayConfig(name: "Pull A", muscles: [.back, .lats, .biceps], index: 1),
            DayConfig(name: "Legs A", muscles: [.quads, .hamstrings, .glutes, .calves], index: 2),
            DayConfig(name: "Push B", muscles: [.chest, .shoulders, .triceps], index: 3),
            DayConfig(name: "Pull B", muscles: [.back, .lats, .biceps, .forearms], index: 4),
            DayConfig(name: "Legs B & Core", muscles: [.glutes, .hamstrings, .quads, .abs, .obliques], index: 5),
        ]
        return Array(base.prefix(days))
    }

    private func generateUpperLowerSplit() -> [DayConfig] {
        [
            DayConfig(name: "Upper A", muscles: [.chest, .back, .shoulders, .biceps, .triceps], index: 0),
            DayConfig(name: "Lower A", muscles: [.quads, .hamstrings, .glutes, .calves, .abs], index: 1),
            DayConfig(name: "Upper B", muscles: [.back, .shoulders, .chest, .triceps, .biceps], index: 2),
            DayConfig(name: "Lower B", muscles: [.hamstrings, .glutes, .quads, .calves, .obliques], index: 3),
        ]
    }

    private func generateUpperLowerFiveDay() -> [DayConfig] {
        [
            DayConfig(name: "Upper A", muscles: [.chest, .back, .shoulders, .triceps, .biceps], index: 0),
            DayConfig(name: "Lower A", muscles: [.quads, .hamstrings, .glutes, .calves], index: 1),
            DayConfig(name: "Upper B", muscles: [.back, .shoulders, .chest, .biceps, .triceps], index: 2),
            DayConfig(name: "Lower B", muscles: [.hamstrings, .glutes, .quads, .calves, .abs], index: 3),
            DayConfig(name: "Upper C", muscles: [.shoulders, .chest, .back, .biceps, .triceps], index: 4),
        ]
    }

    private func generateBodyPartSplit(_ days: Int) -> [DayConfig] {
        let configs: [DayConfig] = [
            DayConfig(name: "Chest & Triceps", muscles: [.chest, .triceps], index: 0),
            DayConfig(name: "Back & Biceps", muscles: [.back, .lats, .biceps], index: 1),
            DayConfig(name: "Legs", muscles: [.quads, .hamstrings, .glutes, .calves], index: 2),
            DayConfig(name: "Shoulders & Arms", muscles: [.shoulders, .biceps, .triceps], index: 3),
            DayConfig(name: "Glutes & Core", muscles: [.glutes, .abs, .obliques], index: 4),
        ]
        return Array(configs.prefix(days))
    }

    // MARK: - Weekly volume budget

    /// Weekly target set count per muscle group, goal- / level- / focus- /
    /// recovery- / phase-aware. This is what makes plans feel engineered
    /// instead of stamped from a template.
    private func weeklyVolumeBudgets(context: PlanContext, split: SplitConfig) -> [MuscleGroup: Int] {
        let profile = context.profile
        var budgets: [MuscleGroup: Int] = [:]

        let targetedMuscles = Set(split.days.flatMap(\.muscles))
        for muscle in targetedMuscles {
            budgets[muscle] = weeklyTarget(for: muscle, context: context)
        }
        return budgets
    }

    private func weeklyTarget(for muscle: MuscleGroup, context: PlanContext) -> Int {
        let profile = context.profile

        // Base MEV / MV / MRV anchors (hypertrophy literature ballpark).
        let base: (mev: Int, mv: Int, mrv: Int) = {
            switch muscle {
            case .chest: return (8, 14, 20)
            case .back, .lats: return (10, 16, 22)
            case .shoulders: return (8, 12, 20)
            case .traps: return (4, 8, 14)
            case .quads: return (8, 14, 20)
            case .hamstrings: return (6, 10, 16)
            case .glutes: return (6, 12, 20)
            case .calves: return (6, 10, 16)
            case .biceps, .triceps, .arms: return (6, 10, 16)
            case .forearms: return (3, 6, 10)
            case .abs, .obliques, .coreStability, .rotationAntiRotation: return (4, 8, 12)
            case .lowerBack: return (4, 6, 10)
            case .adductors, .abductors: return (3, 6, 10)
            case .hipFlexors, .tibialis, .neck: return (2, 4, 8)
            }
        }()

        // Level scaling.
        let levelMult: Double
        switch profile.trainingLevel {
        case .beginner: levelMult = 0.80
        case .intermediate: levelMult = 1.00
        case .advanced: levelMult = 1.15
        }

        // Goal scaling — goals shape *where* in MEV…MRV we aim.
        let goalMult: Double
        switch profile.goal {
        case .muscleGain: goalMult = 1.15
        case .strength: goalMult = 0.90
        case .fatLoss: goalMult = 0.95
        case .athleticPerformance: goalMult = 1.00
        case .generalFitness: goalMult = 1.00
        case .endurance: goalMult = 0.80
        case .flexibility: goalMult = 0.60
        case .rehabilitation: goalMult = 0.60
        }

        // Recovery scaling.
        let recoveryMult: Double
        if context.recoveryScore < 45 { recoveryMult = 0.70 }
        else if context.recoveryScore < 60 { recoveryMult = 0.85 }
        else if context.recoveryScore < 75 { recoveryMult = 0.95 }
        else { recoveryMult = 1.00 }

        // Recovery capacity (trait).
        let capacityMult: Double
        switch profile.recoveryCapacity {
        case .low: capacityMult = 0.90
        case .moderate: capacityMult = 1.00
        case .high: capacityMult = 1.05
        }

        // Phase scaling.
        let phaseMult = context.phase.volumeMultiplier

        // Start between MV and MRV depending on goal.
        var target: Double
        switch profile.goal {
        case .muscleGain:
            target = Double(base.mv) + Double(base.mrv - base.mv) * 0.35
        case .strength:
            target = Double(base.mev) + Double(base.mv - base.mev) * 0.70
        case .fatLoss, .generalFitness, .athleticPerformance:
            target = Double(base.mv)
        case .endurance, .flexibility, .rehabilitation:
            target = Double(base.mev) + 1
        }

        target *= levelMult * goalMult * recoveryMult * capacityMult * phaseMult

        // Focus / neglect tuning.
        if profile.focusMuscles.contains(muscle) {
            target += 3
        }
        if profile.neglectMuscles.contains(muscle) {
            target = max(Double(base.mev), target - 4)
        }

        // Muscle-balance lag → bias up.
        if let entry = context.muscleBalance.first(where: { $0.muscle == muscle.displayName }) {
            if entry.percentOfAverage < 0.7 {
                target += 3
            } else if entry.percentOfAverage < 0.85 {
                target += 2
            }
        }

        // Clamp to physiological window.
        let mevFloor = Double(base.mev)
        let mrvCeiling = Double(base.mrv)
        let clamped = min(mrvCeiling, max(mevFloor, target))

        return Int(clamped.rounded())
    }

    // MARK: - Day construction

    private func generateDays(split: SplitConfig, context: PlanContext, budgets: [MuscleGroup: Int]) -> [WorkoutDay] {
        // Count how many days each muscle appears across the week.
        var occurrences: [MuscleGroup: Int] = [:]
        for day in split.days {
            for muscle in day.muscles {
                occurrences[muscle, default: 0] += 1
            }
        }

        var remainingBudget: [MuscleGroup: Int] = budgets

        return split.days.enumerated().map { (dayIdx, dayConfig) in
            let adjustedMuscles = prioritizeMuscles(dayConfig.muscles, context: context)
            let exercises = buildSession(
                dayConfig: DayConfig(name: dayConfig.name, muscles: adjustedMuscles, index: dayConfig.index),
                context: context,
                weeklyBudgets: budgets,
                remainingBudget: &remainingBudget,
                occurrences: occurrences,
                daysLeft: split.days.count - dayIdx
            )
            let warmup = generateWarmupHint(for: adjustedMuscles, context: context)
            let minutes = adjustedSessionTime(context: context)
            return WorkoutDay(
                name: dayConfig.name,
                focusMuscles: adjustedMuscles,
                exercises: exercises,
                dayIndex: dayConfig.index,
                warmupHint: warmup,
                estimatedMinutes: minutes
            )
        }
    }

    private func prioritizeMuscles(_ muscles: [MuscleGroup], context: PlanContext) -> [MuscleGroup] {
        // Order within a day: focus / lagging muscles first so they anchor the session.
        let focus = Set(context.profile.focusMuscles)
        let lagging: Set<MuscleGroup> = {
            let laggingNames = context.muscleBalance
                .filter { $0.percentOfAverage < 0.8 }
                .map(\.muscle)
            return Set(MuscleGroup.allCases.filter { laggingNames.contains($0.displayName) })
        }()

        return muscles.sorted { lhs, rhs in
            let lScore = (focus.contains(lhs) ? 2 : 0) + (lagging.contains(lhs) ? 1 : 0)
            let rScore = (focus.contains(rhs) ? 2 : 0) + (lagging.contains(rhs) ? 1 : 0)
            if lScore != rScore { return lScore > rScore }
            return muscles.firstIndex(of: lhs)! < muscles.firstIndex(of: rhs)!
        }
    }

    private func adjustedSessionTime(context: PlanContext) -> Int {
        var minutes = context.profile.minutesPerSession
        if context.recoveryScore < 50 {
            minutes = max(30, minutes - 15)
        } else if context.recoveryScore < 70 {
            minutes = max(35, minutes - 10)
        }
        return minutes
    }

    // MARK: - Session construction (role-based)

    private func buildSession(
        dayConfig: DayConfig,
        context: PlanContext,
        weeklyBudgets: [MuscleGroup: Int],
        remainingBudget: inout [MuscleGroup: Int],
        occurrences: [MuscleGroup: Int],
        daysLeft: Int
    ) -> [PlannedExercise] {
        let profile = context.profile
        let slotCount = exerciseCount(for: profile)

        // Compute today's allocation per muscle = remaining / days that still include this muscle.
        // This evens out distribution across the week even if some muscles appear on more days.
        var perMuscleSetsToday: [MuscleGroup: Int] = [:]
        for muscle in dayConfig.muscles {
            let remaining = remainingBudget[muscle] ?? weeklyBudgets[muscle] ?? 0
            let occ = max(1, occurrences[muscle] ?? 1)
            let perDay = max(0, Int((Double(remaining) / Double(occ)).rounded()))
            perMuscleSetsToday[muscle] = perDay
        }

        // Build role plan per muscle: anchor → secondary → accessory/isolation.
        var planned: [PlannedExercise] = []
        var usedExerciseIds: Set<String> = []
        var usedPatterns: [MovementPattern: Int] = [:]
        var order = 0

        // Determine anchor muscles: first 1-2 prioritized muscles with enough sets budgeted.
        let anchorEligible = dayConfig.muscles.prefix(2).filter { (perMuscleSetsToday[$0] ?? 0) >= 3 }

        // Pass 1: anchor lifts (one per top muscle).
        for muscle in anchorEligible {
            guard planned.count < slotCount else { break }
            guard let ex = pickExercise(
                muscle: muscle,
                role: .anchor,
                profile: profile,
                used: usedExerciseIds,
                usedPatterns: usedPatterns
            ) else { continue }
            let prescription = prescription(for: ex, role: .anchor, context: context)
            planned.append(makePlanned(exercise: ex, prescription: prescription, role: .anchor, order: order))
            usedExerciseIds.insert(ex.id)
            usedPatterns[ex.movementPattern, default: 0] += 1
            perMuscleSetsToday[muscle, default: 0] -= prescription.sets
            order += 1
        }

        // Pass 2: secondary compound per remaining primary muscles.
        for muscle in dayConfig.muscles where (perMuscleSetsToday[muscle] ?? 0) >= 3 {
            guard planned.count < slotCount else { break }
            guard let ex = pickExercise(
                muscle: muscle,
                role: .secondary,
                profile: profile,
                used: usedExerciseIds,
                usedPatterns: usedPatterns
            ) else { continue }
            let prescription = prescription(for: ex, role: .secondary, context: context)
            planned.append(makePlanned(exercise: ex, prescription: prescription, role: .secondary, order: order))
            usedExerciseIds.insert(ex.id)
            usedPatterns[ex.movementPattern, default: 0] += 1
            perMuscleSetsToday[muscle, default: 0] -= prescription.sets
            order += 1
        }

        // Pass 3: accessory / isolation to mop up remaining budget.
        // Sort muscles by remaining set hunger so undertrained budgets get filled first.
        let hungerSorted = dayConfig.muscles.sorted {
            (perMuscleSetsToday[$0] ?? 0) > (perMuscleSetsToday[$1] ?? 0)
        }
        for muscle in hungerSorted {
            guard planned.count < slotCount else { break }
            while (perMuscleSetsToday[muscle] ?? 0) >= 2 && planned.count < slotCount {
                let role: PlanExerciseRole = preferIsolation(for: muscle, profile: profile) ? .isolation : .accessory
                guard let ex = pickExercise(
                    muscle: muscle,
                    role: role,
                    profile: profile,
                    used: usedExerciseIds,
                    usedPatterns: usedPatterns
                ) else { break }
                let prescription = prescription(for: ex, role: role, context: context)
                planned.append(makePlanned(exercise: ex, prescription: prescription, role: role, order: order))
                usedExerciseIds.insert(ex.id)
                usedPatterns[ex.movementPattern, default: 0] += 1
                perMuscleSetsToday[muscle, default: 0] -= prescription.sets
                order += 1
            }
        }

        // Pass 4: if session is sparse, fill with isolations for lagging/focus muscles even
        // when budget is already near zero (keeps sessions substantial for new users).
        let minSlots = minimumSlotsForCredibility(profile: profile)
        if planned.count < minSlots {
            for muscle in dayConfig.muscles {
                guard planned.count < slotCount, planned.count < minSlots else { break }
                guard let ex = pickExercise(
                    muscle: muscle,
                    role: .isolation,
                    profile: profile,
                    used: usedExerciseIds,
                    usedPatterns: usedPatterns
                ) else { continue }
                let prescription = prescription(for: ex, role: .isolation, context: context)
                planned.append(makePlanned(exercise: ex, prescription: prescription, role: .isolation, order: order))
                usedExerciseIds.insert(ex.id)
                usedPatterns[ex.movementPattern, default: 0] += 1
                order += 1
            }
        }

        // Subtract allocated work from remaining weekly budget.
        for ex in planned {
            guard let exercise = library.exercise(byId: ex.exerciseId) else { continue }
            remainingBudget[exercise.primaryMuscle, default: 0] -= ex.sets
            for secondary in exercise.secondaryMuscles {
                remainingBudget[secondary, default: 0] -= ex.sets / 2
            }
        }

        return planned
    }

    private func minimumSlotsForCredibility(profile: UserProfile) -> Int {
        switch profile.goal {
        case .muscleGain, .strength, .generalFitness, .athleticPerformance, .fatLoss:
            switch profile.trainingLevel {
            case .beginner: return 4
            case .intermediate: return 5
            case .advanced: return 5
            }
        case .endurance, .flexibility, .rehabilitation:
            return 3
        }
    }

    private func preferIsolation(for muscle: MuscleGroup, profile: UserProfile) -> Bool {
        switch muscle {
        case .biceps, .triceps, .forearms, .calves, .abs, .obliques, .traps, .hamstrings:
            return true
        case .chest, .back, .lats, .shoulders, .quads, .glutes:
            return profile.focusMuscles.contains(muscle)
        default:
            return false
        }
    }

    private func makePlanned(exercise: Exercise, prescription: Prescription, role: PlanExerciseRole, order: Int) -> PlannedExercise {
        PlannedExercise(
            exerciseId: exercise.id,
            sets: prescription.sets,
            reps: prescription.reps,
            restSeconds: prescription.rest,
            rpe: prescription.rpe,
            notes: "",
            order: order
        )
    }

    // MARK: - Exercise selection with role

    private func pickExercise(
        muscle: MuscleGroup,
        role: PlanExerciseRole,
        profile: UserProfile,
        used: Set<String>,
        usedPatterns: [MovementPattern: Int]
    ) -> Exercise? {
        let candidates = scoredExercises(muscle: muscle, role: role, profile: profile)
            .filter { !used.contains($0.id) }
            .filter { ex in
                // Limit repetition of a single movement pattern per day.
                (usedPatterns[ex.movementPattern] ?? 0) < 2
            }

        return candidates.first ?? scoredExercises(muscle: muscle, role: role, profile: profile)
            .first { !used.contains($0.id) }
    }

    private func scoredExercises(muscle: MuscleGroup, role: PlanExerciseRole, profile: UserProfile) -> [Exercise] {
        let location: LocationType = {
            switch profile.trainingLocation {
            case .gym: return .gym
            case .homeGym: return .homeGym
            case .homeNoEquipment: return .homeNoEquipment
            }
        }()

        var candidates = library.filtered(muscle: muscle, location: location)

        if !profile.availableEquipment.isEmpty && profile.trainingLocation != .gym {
            candidates = candidates.filter { ex in
                ex.equipment.contains(.none) || ex.equipment.contains(where: { profile.availableEquipment.contains($0) })
            }
        }

        let avoided = Set(profile.avoidedExercises.map { $0.lowercased() })
        candidates = candidates.filter { !avoided.contains($0.name.lowercased()) }

        if !profile.injuries.isEmpty {
            candidates = candidates.filter { ex in
                !isRiskyForInjuries(ex, profile: profile)
            }
        }

        return candidates.sorted {
            score($0, muscle: muscle, role: role, profile: profile) >
            score($1, muscle: muscle, role: role, profile: profile)
        }
    }

    private func isRiskyForInjuries(_ ex: Exercise, profile: UserProfile) -> Bool {
        for injury in profile.injuries {
            let i = injury.lowercased()
            if i.contains("shoulder") && (ex.movementPattern == .verticalPush || ex.movementPattern == .horizontalPush) && !ex.isJointFriendly { return true }
            if i.contains("knee") && (ex.movementPattern == .squat || ex.movementPattern == .lunge || ex.movementPattern == .plyometric) && !ex.isJointFriendly { return true }
            if i.contains("back") && (ex.movementPattern == .hipHinge) && !ex.isJointFriendly { return true }
        }
        return false
    }

    private func score(_ ex: Exercise, muscle: MuscleGroup, role: PlanExerciseRole, profile: UserProfile) -> Double {
        var s: Double = 50

        // Role fit — the most important single factor.
        switch role {
        case .anchor:
            if ex.category == .compound { s += 30 } else { s -= 15 }
            if ex.primaryMuscle == muscle { s += 15 } else { s -= 4 }
            if ex.equipment.contains(.barbell) { s += 6 }
            if ex.equipment.contains(.dumbbell) { s += 3 }
            if ex.progressionLevel == .progression { s += 4 }
            if ex.difficulty == .beginner && profile.trainingLevel != .beginner { s -= 2 }
        case .secondary:
            if ex.category == .compound { s += 15 }
            if ex.primaryMuscle == muscle { s += 12 }
            if ex.secondaryMuscles.contains(muscle) { s += 3 }
        case .accessory:
            if ex.category == .isolation || ex.category == .bodyweight { s += 10 }
            if ex.primaryMuscle == muscle { s += 14 }
            if ex.isJointFriendly { s += 3 }
        case .isolation:
            if ex.category == .isolation { s += 20 } else if ex.category == .compound { s -= 10 }
            if ex.primaryMuscle == muscle { s += 14 }
        }

        // Level fit.
        switch profile.trainingLevel {
        case .beginner:
            if ex.isBeginnerFriendly { s += 14 }
            if ex.difficulty == .advanced { s -= 25 }
        case .intermediate:
            if ex.difficulty == .intermediate { s += 8 }
            if ex.difficulty == .advanced { s -= 4 }
        case .advanced:
            if ex.difficulty == .advanced { s += 8 }
            if ex.progressionLevel == .progression { s += 4 }
        }

        // Goal fit.
        switch profile.goal {
        case .strength:
            if ex.category == .compound { s += 10 }
            if ex.tags.contains("strength") { s += 6 }
        case .muscleGain:
            if ex.tags.contains("mass") || ex.tags.contains("hypertrophy") { s += 6 }
            if role == .accessory && ex.isJointFriendly { s += 3 }
        case .fatLoss:
            if ex.category == .compound { s += 6 }
        case .athleticPerformance:
            if ex.tags.contains("explosive") || ex.movementPattern == .plyometric { s += 6 }
        case .endurance:
            if ex.category == .cardio { s += 10 }
        case .flexibility:
            if ex.category == .mobility { s += 20 }
        case .rehabilitation:
            if ex.isJointFriendly { s += 10 }
            if ex.difficulty == .beginner { s += 6 }
        case .generalFitness:
            if ex.category == .compound { s += 4 }
        }

        // Focus muscles get extra pull.
        if profile.focusMuscles.contains(ex.primaryMuscle) { s += 6 }

        // Recovery-capacity nuance.
        if profile.recoveryCapacity == .low && ex.category == .compound && role != .anchor { s -= 3 }

        return s
    }

    // MARK: - Prescription (sets / reps / rest / rpe)

    private struct Prescription: Sendable {
        let sets: Int
        let reps: String
        let rest: Int
        let rpe: Double?
    }

    private func prescription(for ex: Exercise, role: PlanExerciseRole, context: PlanContext) -> Prescription {
        let profile = context.profile
        let goal = profile.goal

        // Base prescription from (goal × role).
        var sets: Int
        var reps: String
        var rest: Int

        switch (goal, role) {
        // Strength
        case (.strength, .anchor):
            sets = profile.trainingLevel == .beginner ? 3 : 5
            reps = profile.trainingLevel == .beginner ? "5" : "3-5"
            rest = 210
        case (.strength, .secondary):
            sets = 4; reps = "5-6"; rest = 180
        case (.strength, .accessory):
            sets = 3; reps = "8-10"; rest = 90
        case (.strength, .isolation):
            sets = 3; reps = "10-12"; rest = 75

        // Muscle gain
        case (.muscleGain, .anchor):
            sets = profile.trainingLevel == .beginner ? 3 : 4
            reps = profile.trainingLevel == .beginner ? "8-10" : "6-8"
            rest = 150
        case (.muscleGain, .secondary):
            sets = 3; reps = "8-10"; rest = 120
        case (.muscleGain, .accessory):
            sets = 3; reps = "10-12"; rest = 90
        case (.muscleGain, .isolation):
            sets = 3; reps = "12-15"; rest = 60

        // Fat loss
        case (.fatLoss, .anchor):
            sets = 3; reps = "8-10"; rest = 90
        case (.fatLoss, .secondary):
            sets = 3; reps = "10-12"; rest = 75
        case (.fatLoss, .accessory):
            sets = 3; reps = "12-15"; rest = 60
        case (.fatLoss, .isolation):
            sets = 3; reps = "15-20"; rest = 45

        // Athletic performance
        case (.athleticPerformance, .anchor):
            sets = 4; reps = "4-6"; rest = 180
        case (.athleticPerformance, .secondary):
            sets = 3; reps = "6-8"; rest = 120
        case (.athleticPerformance, .accessory):
            sets = 3; reps = "8-12"; rest = 75
        case (.athleticPerformance, .isolation):
            sets = 3; reps = "10-12"; rest = 60

        // General fitness
        case (.generalFitness, .anchor):
            sets = profile.trainingLevel == .beginner ? 3 : 4
            reps = "6-10"; rest = 120
        case (.generalFitness, .secondary):
            sets = 3; reps = "8-12"; rest = 90
        case (.generalFitness, .accessory):
            sets = 3; reps = "10-15"; rest = 75
        case (.generalFitness, .isolation):
            sets = 2; reps = "12-15"; rest = 60

        // Endurance
        case (.endurance, _):
            sets = 2; reps = "15-20"; rest = 45

        // Flexibility
        case (.flexibility, _):
            sets = 2; reps = "8-10"; rest = 30

        // Rehab
        case (.rehabilitation, _):
            sets = 2; reps = "10-12"; rest = 60
        }

        // Phase / recovery modulation on volume.
        let volumeMult = volumeAdjustment(context: context)
        if volumeMult < 1.0 {
            sets = max(minimumSets(for: profile, phase: context.phase, role: role), Int((Double(sets) * volumeMult).rounded()))
        }

        // Volume floor — prevents the "always 2 sets" feeling on fresh hypertrophy-ish profiles.
        let floor = minimumSets(for: profile, phase: context.phase, role: role)
        if sets < floor { sets = floor }

        // RPE.
        let rpe = rpeForContext(exercise: ex, role: role, context: context)

        return Prescription(sets: sets, reps: reps, rest: rest, rpe: rpe)
    }

    private func minimumSets(for profile: UserProfile, phase: TrainingPhase, role: PlanExerciseRole) -> Int {
        // Deload / fatigue-management phases legitimately run at 2 sets.
        switch phase {
        case .deload, .fatigueManagement:
            return 2
        case .build, .push, .rebalance:
            break
        }

        switch profile.goal {
        case .endurance, .flexibility, .rehabilitation:
            return 2
        case .muscleGain, .strength, .athleticPerformance, .generalFitness, .fatLoss:
            switch role {
            case .anchor, .secondary, .accessory: return 3
            case .isolation: return profile.goal == .generalFitness ? 2 : 3
            }
        }
    }

    private func volumeAdjustment(context: PlanContext) -> Double {
        let phaseMultiplier = context.phase.volumeMultiplier
        let recoveryMultiplier: Double
        if context.recoveryScore < 40 { recoveryMultiplier = 0.7 }
        else if context.recoveryScore < 60 { recoveryMultiplier = 0.85 }
        else if context.recoveryScore < 75 { recoveryMultiplier = 0.95 }
        else { recoveryMultiplier = 1.0 }
        return min(recoveryMultiplier, phaseMultiplier)
    }

    private func rpeForContext(exercise: Exercise, role: PlanExerciseRole, context: PlanContext) -> Double? {
        let profile = context.profile
        guard profile.trainingLevel != .beginner else { return nil }

        var baseRPE: Double = profile.trainingLevel == .advanced ? 8.0 : 7.5
        baseRPE += context.phase.rpeAdjustment

        switch role {
        case .anchor: baseRPE += 0.0
        case .secondary: baseRPE += 0.0
        case .accessory: baseRPE += 0.5
        case .isolation: baseRPE += 1.0
        }

        if context.recoveryScore < 50 { baseRPE -= 1.5 }
        else if context.recoveryScore < 70 { baseRPE -= 0.5 }

        return max(5.0, min(9.5, baseRPE))
    }

    // MARK: - Session sizing

    private func exerciseCount(for profile: UserProfile) -> Int {
        let base: Int
        switch profile.trainingLevel {
        case .beginner: base = 5
        case .intermediate: base = 6
        case .advanced: base = 7
        }

        if profile.minutesPerSession <= 30 { return max(3, base - 2) }
        if profile.minutesPerSession <= 45 { return max(4, base - 1) }
        if profile.minutesPerSession >= 75 { return base + 1 }
        return base
    }

    // MARK: - Warmup / explanation

    private func generateWarmupHint(for muscles: [MuscleGroup], context: PlanContext) -> String {
        let areas = muscles.prefix(3).map { $0.displayName }.joined(separator: ", ")
        var hint = "5 min light cardio, then dynamic stretches for \(areas)."
        if context.recoveryScore < 60 {
            hint += " Recovery is lower than usual — take extra warmup time and use lighter warmup sets."
        } else {
            hint += " 1–2 light warmup sets before your anchor lift."
        }
        return hint
    }

    private func generateExplanation(split: SplitConfig, context: PlanContext, budgets: [MuscleGroup: Int], days: [WorkoutDay]) -> String {
        let profile = context.profile
        var parts: [String] = []

        parts.append("This \(split.name) plan is built around a weekly volume target for each muscle you're training — tuned for your \(profile.goal.displayName.lowercased()) goal as a \(profile.trainingLevel.shortName.lowercased()).")

        // Anchor summary — what's carrying progression.
        let anchorIds = days.compactMap { $0.exercises.first?.exerciseId }
        let anchorNames = anchorIds.compactMap { library.exercise(byId: $0)?.name }
        if !anchorNames.isEmpty {
            let list = Array(Set(anchorNames)).prefix(3).joined(separator: ", ")
            parts.append("Anchor lifts — \(list) — are where progression happens each week. Everything else supports them.")
        }

        // Weekly volume callouts for the top 3 targeted muscles.
        let topBudgets = budgets
            .filter { $0.value > 0 }
            .sorted { $0.value > $1.value }
            .prefix(3)
        if !topBudgets.isEmpty {
            let summary = topBudgets.map { "\($0.key.displayName) \($0.value) sets" }.joined(separator: ", ")
            parts.append("Weekly volume targets: \(summary).")
        }

        // Focus muscles.
        if !profile.focusMuscles.isEmpty {
            let focus = profile.focusMuscles.prefix(3).map { $0.displayName }.joined(separator: ", ")
            parts.append("Extra sets are routed to \(focus) as priority muscles.")
        }

        // Neglect muscles.
        if !profile.neglectMuscles.isEmpty {
            let skip = profile.neglectMuscles.prefix(2).map { $0.displayName }.joined(separator: ", ")
            parts.append("Volume on \(skip) is kept minimal per your preference.")
        }

        // Phase context.
        switch context.phase {
        case .deload:
            parts.append("Deload week: volume and intensity are reduced — move well, stay fresh.")
        case .fatigueManagement:
            parts.append("Fatigue-management block: volume is pulled back to preserve progress.")
        case .push:
            if context.recoveryScore >= 70 {
                parts.append("Push phase with recovery on your side — expect small PRs if you stay consistent.")
            } else {
                parts.append("Push phase, but volume is kept honest given current recovery.")
            }
        case .rebalance:
            let undertrained = context.muscleBalance.filter { $0.percentOfAverage < 0.8 }
            if !undertrained.isEmpty {
                let names = undertrained.prefix(2).map(\.muscle).joined(separator: " and ")
                parts.append("Rebalance phase: prioritizing \(names) to close volume gaps.")
            }
        case .build:
            if context.recoveryScore < 60 {
                parts.append("Volume is trimmed this cycle due to lower recovery — quality over quantity.")
            } else if profile.recoveryCapacity == .low {
                parts.append("Volume is set conservatively to match your recovery capacity.")
            }
        }

        // Injuries.
        if !profile.injuries.isEmpty {
            parts.append("Exercise selection avoids movements that could aggravate your noted restrictions.")
        }

        // Muscle-balance drift.
        let undertrained = context.muscleBalance.filter { $0.percentOfAverage < 0.8 }
        if !undertrained.isEmpty && context.phase != .rebalance {
            let names = undertrained.prefix(2).map(\.muscle).joined(separator: " and ")
            parts.append("\(names) has been lagging lately — this plan adds extra work there.")
        }

        return parts.joined(separator: " ")
    }
}

nonisolated struct PlanContext: Sendable {
    let profile: UserProfile
    let muscleBalance: [MuscleBalanceEntry]
    let recentSessions: [WorkoutSession]
    let recoveryScore: Int
    let phase: TrainingPhase

    init(profile: UserProfile, muscleBalance: [MuscleBalanceEntry], recentSessions: [WorkoutSession], recoveryScore: Int, phase: TrainingPhase = .build) {
        self.profile = profile
        self.muscleBalance = muscleBalance
        self.recentSessions = recentSessions
        self.recoveryScore = recoveryScore
        self.phase = phase
    }
}

nonisolated struct SplitConfig: Sendable {
    let name: String
    let days: [DayConfig]
}

nonisolated struct DayConfig: Sendable {
    let name: String
    let muscles: [MuscleGroup]
    let index: Int
}
