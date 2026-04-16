import Foundation

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
        let days = generateDays(split: split, context: context)
        let explanation = generateExplanation(split: split, context: context)

        return WorkoutPlan(
            name: "\(profile.name.isEmpty ? "Your" : profile.name + "'s") \(profile.goal.displayName) Plan",
            description: "\(split.name) • \(profile.daysPerWeek) days/week • \(profile.minutesPerSession) min",
            days: days,
            splitType: split.name,
            explanation: explanation
        )
    }

    private func determineSplit(_ profile: UserProfile) -> SplitConfig {
        if profile.splitPreference != .automatic {
            return splitConfig(for: profile.splitPreference, days: profile.daysPerWeek)
        }

        switch profile.daysPerWeek {
        case 1...2: return SplitConfig(name: "Full Body", days: generateFullBodySplit(profile.daysPerWeek))
        case 3: return profile.trainingLevel == .beginner
            ? SplitConfig(name: "Full Body", days: generateFullBodySplit(3))
            : SplitConfig(name: "Push/Pull/Legs", days: generatePPLSplit())
        case 4: return SplitConfig(name: "Upper/Lower", days: generateUpperLowerSplit())
        case 5...6: return SplitConfig(name: "Push/Pull/Legs", days: generatePPL6Day(profile.daysPerWeek))
        default: return SplitConfig(name: "Full Body", days: generateFullBodySplit(3))
        }
    }

    private func splitConfig(for pref: SplitPreference, days: Int) -> SplitConfig {
        switch pref {
        case .fullBody: return SplitConfig(name: "Full Body", days: generateFullBodySplit(days))
        case .upperLower: return SplitConfig(name: "Upper/Lower", days: generateUpperLowerSplit())
        case .pushPullLegs: return SplitConfig(name: "Push/Pull/Legs", days: days >= 6 ? generatePPL6Day(days) : generatePPLSplit())
        case .bodyPart, .muscleGroup: return SplitConfig(name: "Body Part", days: generateBodyPartSplit(days))
        case .automatic: return SplitConfig(name: "Full Body", days: generateFullBodySplit(days))
        }
    }

    private func generateFullBodySplit(_ days: Int) -> [DayConfig] {
        (0..<days).map { i in
            DayConfig(name: "Full Body \(["A", "B", "C", "D"][i % 4])", muscles: [.chest, .back, .shoulders, .quads, .hamstrings, .abs], index: i)
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
            DayConfig(name: "Legs B & Core", muscles: [.quads, .glutes, .hamstrings, .abs, .obliques], index: 5),
        ]
        return Array(base.prefix(days))
    }

    private func generateUpperLowerSplit() -> [DayConfig] {
        [
            DayConfig(name: "Upper A", muscles: [.chest, .back, .shoulders, .biceps, .triceps], index: 0),
            DayConfig(name: "Lower A", muscles: [.quads, .hamstrings, .glutes, .calves, .abs], index: 1),
            DayConfig(name: "Upper B", muscles: [.back, .chest, .shoulders, .biceps, .triceps], index: 2),
            DayConfig(name: "Lower B", muscles: [.glutes, .quads, .hamstrings, .calves, .obliques], index: 3),
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

    private func generateDays(split: SplitConfig, context: PlanContext) -> [WorkoutDay] {
        split.days.map { dayConfig in
            let adjustedMuscles = adjustMusclesForBalance(dayConfig.muscles, context: context)
            let exercises = selectExercises(for: DayConfig(name: dayConfig.name, muscles: adjustedMuscles, index: dayConfig.index), context: context)
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

    private func adjustMusclesForBalance(_ muscles: [MuscleGroup], context: PlanContext) -> [MuscleGroup] {
        guard !context.muscleBalance.isEmpty else { return muscles }

        var adjusted = muscles
        let undertrainedMuscles = context.muscleBalance
            .filter { $0.percentOfAverage < 0.8 }
            .compactMap { entry -> MuscleGroup? in
                MuscleGroup.allCases.first { $0.displayName == entry.muscle }
            }

        for muscle in undertrainedMuscles.prefix(2) {
            if !adjusted.contains(muscle) && muscle.region == muscles.first?.region {
                adjusted.append(muscle)
            }
        }

        return adjusted
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

    private func selectExercises(for day: DayConfig, context: PlanContext) -> [PlannedExercise] {
        let profile = context.profile
        let maxExercises = exerciseCount(for: profile)
        let volumeMultiplier = volumeAdjustment(context: context)
        var selected: [PlannedExercise] = []
        var usedMuscles: Set<MuscleGroup> = []

        let sortedMuscles = day.muscles.sorted { m1, m2 in
            let b1 = muscleBalanceRatio(for: m1, context: context)
            let b2 = muscleBalanceRatio(for: m2, context: context)
            return b1 < b2
        }

        for muscle in sortedMuscles {
            let candidates = scoredExercises(muscle: muscle, profile: profile)
                .filter { ex in !selected.contains(where: { $0.exerciseId == ex.id }) }

            let balanceRatio = muscleBalanceRatio(for: muscle, context: context)
            let isFocus = profile.focusMuscles.contains(muscle)
            let count: Int
            if isFocus || balanceRatio < 0.8 {
                count = muscle == sortedMuscles.first ? 2 : 2
            } else {
                count = muscle == sortedMuscles.first ? 2 : 1
            }

            for ex in candidates.prefix(count) {
                guard selected.count < maxExercises else { break }
                let (baseSets, reps, rest) = setsRepsRest(for: ex, profile: profile)
                let adjustedSets = max(2, Int(Double(baseSets) * volumeMultiplier))
                let rpe = rpeForContext(exercise: ex, context: context)
                selected.append(PlannedExercise(
                    exerciseId: ex.id,
                    sets: adjustedSets,
                    reps: reps,
                    restSeconds: rest,
                    rpe: rpe,
                    order: selected.count
                ))
                usedMuscles.insert(muscle)
            }
        }

        return selected
    }

    private func muscleBalanceRatio(for muscle: MuscleGroup, context: PlanContext) -> Double {
        guard let entry = context.muscleBalance.first(where: { $0.muscle == muscle.displayName }) else {
            return 1.0
        }
        return entry.percentOfAverage
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

    private func rpeForContext(exercise: Exercise, context: PlanContext) -> Double? {
        let profile = context.profile
        guard profile.trainingLevel != .beginner else { return nil }

        var baseRPE: Double = profile.trainingLevel == .advanced ? 8.0 : 7.5

        baseRPE += context.phase.rpeAdjustment

        if context.recoveryScore < 50 {
            baseRPE -= 1.5
        } else if context.recoveryScore < 70 {
            baseRPE -= 0.5
        }

        if exercise.category == .isolation {
            baseRPE = min(baseRPE + 0.5, 9.0)
        }

        return max(5.0, min(9.5, baseRPE))
    }

    private func scoredExercises(muscle: MuscleGroup, profile: UserProfile) -> [Exercise] {
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
                let risky = profile.injuries.contains(where: { injury in
                    let i = injury.lowercased()
                    if i.contains("shoulder") && (ex.movementPattern == .verticalPush || ex.movementPattern == .horizontalPush) && !ex.isJointFriendly { return true }
                    if i.contains("knee") && (ex.movementPattern == .squat || ex.movementPattern == .lunge || ex.movementPattern == .plyometric) && !ex.isJointFriendly { return true }
                    if i.contains("back") && (ex.movementPattern == .hipHinge) && !ex.isJointFriendly { return true }
                    return false
                })
                return !risky
            }
        }

        return candidates.sorted { a, b in
            score(a, profile: profile) > score(b, profile: profile)
        }
    }

    private func score(_ ex: Exercise, profile: UserProfile) -> Double {
        var s: Double = 50

        if profile.focusMuscles.contains(ex.primaryMuscle) { s += 20 }

        switch profile.trainingLevel {
        case .beginner:
            if ex.isBeginnerFriendly { s += 15 }
            if ex.difficulty == .advanced { s -= 30 }
            if ex.category == .compound { s += 10 }
        case .intermediate:
            if ex.difficulty == .intermediate { s += 10 }
            if ex.category == .compound { s += 5 }
        case .advanced:
            if ex.difficulty == .advanced { s += 10 }
            if ex.progressionLevel == .progression { s += 5 }
        }

        switch profile.goal {
        case .strength:
            if ex.category == .compound { s += 15 }
            if ex.tags.contains("strength") { s += 10 }
        case .muscleGain:
            if ex.tags.contains("mass") || ex.tags.contains("hypertrophy") { s += 10 }
        case .fatLoss:
            if ex.category == .compound { s += 10 }
        case .flexibility:
            if ex.category == .mobility || ex.category == .pilates { s += 20 }
        default: break
        }

        if ex.isJointFriendly { s += 3 }

        if profile.recoveryCapacity == .low && ex.category == .compound { s -= 5 }

        return s
    }

    private func exerciseCount(for profile: UserProfile) -> Int {
        let base: Int
        switch profile.trainingLevel {
        case .beginner: base = 4
        case .intermediate: base = 6
        case .advanced: base = 7
        }

        if profile.minutesPerSession <= 30 { return max(3, base - 2) }
        if profile.minutesPerSession <= 45 { return max(4, base - 1) }
        return base
    }

    private func setsRepsRest(for exercise: Exercise, profile: UserProfile) -> (Int, String, Int) {
        let level = profile.trainingLevel
        let goal = profile.goal

        switch goal {
        case .strength:
            if exercise.category == .compound {
                return (level == .beginner ? 3 : 4, level == .beginner ? "5" : "3-5", 180)
            }
            return (3, "6-8", 120)
        case .muscleGain:
            if exercise.category == .compound {
                return (level == .beginner ? 3 : 4, "8-12", 120)
            }
            return (3, "10-15", 90)
        case .fatLoss:
            return (3, "12-15", 60)
        case .endurance:
            return (2, "15-20", 45)
        default:
            return (3, "10-12", 90)
        }
    }

    private func generateWarmupHint(for muscles: [MuscleGroup], context: PlanContext) -> String {
        let areas = muscles.prefix(3).map { $0.displayName }.joined(separator: ", ")
        var hint = "5 min light cardio, then dynamic stretches targeting \(areas)."
        if context.recoveryScore < 60 {
            hint += " Recovery is lower than usual — take extra time warming up and use lighter warmup sets."
        } else {
            hint += " Start with 1-2 light warmup sets."
        }
        return hint
    }

    private func generateExplanation(split: SplitConfig, context: PlanContext) -> String {
        let profile = context.profile
        var parts: [String] = []

        parts.append("This \(split.name) split is designed for your \(profile.goal.displayName.lowercased()) goal.")

        if context.phase != .build {
            parts.append("Currently in \(context.phase.displayName.lowercased()): \(context.phase.description.lowercased())")
        }

        parts.append("As a \(profile.trainingLevel.shortName.lowercased()) with \(profile.daysPerWeek) training days, this structure balances stimulus and recovery.")

        if !profile.focusMuscles.isEmpty {
            let focus = profile.focusMuscles.prefix(3).map { $0.displayName }.joined(separator: ", ")
            parts.append("Extra emphasis on \(focus) as requested.")
        }

        if !profile.injuries.isEmpty {
            parts.append("Exercises are filtered to avoid movements that may aggravate your noted restrictions.")
        }

        switch context.phase {
        case .deload:
            parts.append("Volume and intensity are significantly reduced this week. Focus on movement quality and recovery.")
        case .fatigueManagement:
            parts.append("Volume is reduced to manage accumulated fatigue. Maintain training consistency at lower intensity.")
        case .push:
            if context.recoveryScore >= 70 {
                parts.append("Recovery supports progression. Push for small improvements on key lifts this week.")
            } else {
                parts.append("Volume is managed carefully during this push phase given current recovery.")
            }
        case .rebalance:
            let undertrained = context.muscleBalance.filter { $0.percentOfAverage < 0.8 }
            if !undertrained.isEmpty {
                let names = undertrained.prefix(2).map(\.muscle).joined(separator: " and ")
                parts.append("Prioritizing \(names) to correct imbalances before the next progression block.")
            }
        case .build:
            if context.recoveryScore < 60 {
                parts.append("Volume is reduced this cycle due to accumulated fatigue. Focus on quality reps.")
            } else if profile.recoveryCapacity == .low {
                parts.append("Volume is managed conservatively given your recovery capacity.")
            }
        }

        let undertrained = context.muscleBalance.filter { $0.percentOfAverage < 0.8 }
        if !undertrained.isEmpty && context.phase != .rebalance {
            let names = undertrained.prefix(2).map(\.muscle).joined(separator: " and ")
            parts.append("\(names) volume was below average recently — this plan adds extra work there.")
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
