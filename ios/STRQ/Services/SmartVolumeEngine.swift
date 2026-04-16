import Foundation

struct SmartVolumeEngine {
    func volumeLandmarks(
        for profile: UserProfile,
        muscleBalance: [MuscleBalanceEntry],
        sessions: [WorkoutSession]
    ) -> [VolumeLandmark] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let thisWeekSessions = sessions.filter { $0.startTime > weekAgo && $0.isCompleted }

        let weeklySets = countWeeklySetsByMuscle(sessions: thisWeekSessions)

        let majorMuscles: [(String, MuscleGroup)] = [
            ("Chest", .chest), ("Back", .back), ("Shoulders", .shoulders),
            ("Quads", .quads), ("Hamstrings", .hamstrings), ("Glutes", .glutes),
            ("Arms", .arms), ("Abs", .abs)
        ]

        return majorMuscles.map { (name, muscle) in
            let (mev, mv, mrv) = volumeTargets(for: muscle, profile: profile)
            let current = weeklySets[name] ?? 0
            return VolumeLandmark(
                muscleGroup: name,
                maintenanceVolume: mv,
                minimumEffectiveVolume: mev,
                maximumRecoverableVolume: mrv,
                currentWeeklySets: current
            )
        }
    }

    func analyzeBalance(
        muscleBalance: [MuscleBalanceEntry],
        profile: UserProfile
    ) -> [BalanceInsight] {
        var insights: [BalanceInsight] = []

        let pushMuscles: Set<String> = ["Chest", "Shoulders"]
        let pullMuscles: Set<String> = ["Back"]
        let pushVol = muscleBalance.filter { pushMuscles.contains($0.muscle) }.reduce(0.0) { $0 + $1.thisWeek }
        let pullVol = muscleBalance.filter { pullMuscles.contains($0.muscle) }.reduce(0.0) { $0 + $1.thisWeek }

        if pushVol > 0 && pullVol > 0 {
            let ratio = pushVol / pullVol
            if ratio > 1.4 {
                insights.append(BalanceInsight(
                    category: .pushPull,
                    status: .imbalanced,
                    detail: "Push volume is \(Int((ratio - 1) * 100))% higher than pull. Add more rowing and pull-up work for shoulder health.",
                    dominant: "Push",
                    weak: "Pull",
                    ratio: ratio
                ))
            } else if ratio < 0.7 {
                insights.append(BalanceInsight(
                    category: .pushPull,
                    status: .imbalanced,
                    detail: "Pull volume significantly exceeds push. Consider adding pressing movements.",
                    dominant: "Pull",
                    weak: "Push",
                    ratio: 1.0 / ratio
                ))
            } else {
                insights.append(BalanceInsight(
                    category: .pushPull,
                    status: .balanced,
                    detail: "Push and pull volume are well balanced.",
                    dominant: nil,
                    weak: nil,
                    ratio: ratio
                ))
            }
        }

        let upperMuscles: Set<String> = ["Chest", "Back", "Shoulders", "Arms"]
        let lowerMuscles: Set<String> = ["Quads", "Hamstrings", "Glutes"]
        let upperVol = muscleBalance.filter { upperMuscles.contains($0.muscle) }.reduce(0.0) { $0 + $1.thisWeek }
        let lowerVol = muscleBalance.filter { lowerMuscles.contains($0.muscle) }.reduce(0.0) { $0 + $1.thisWeek }

        if upperVol > 0 && lowerVol > 0 {
            let ratio = upperVol / lowerVol
            if ratio > 1.6 {
                insights.append(BalanceInsight(
                    category: .upperLower,
                    status: .imbalanced,
                    detail: "Upper body volume is \(String(format: "%.1f", ratio))x your lower body. Add more leg work.",
                    dominant: "Upper",
                    weak: "Lower",
                    ratio: ratio
                ))
            } else if ratio < 0.6 {
                insights.append(BalanceInsight(
                    category: .upperLower,
                    status: .imbalanced,
                    detail: "Lower body dominates training. Consider more upper body pressing and pulling.",
                    dominant: "Lower",
                    weak: "Upper",
                    ratio: 1.0 / ratio
                ))
            } else {
                insights.append(BalanceInsight(
                    category: .upperLower,
                    status: .balanced,
                    detail: "Upper and lower body volume are well proportioned.",
                    dominant: nil,
                    weak: nil,
                    ratio: ratio
                ))
            }
        }

        let quadVol = muscleBalance.first(where: { $0.muscle == "Quads" })?.thisWeek ?? 0
        let hamVol = muscleBalance.first(where: { $0.muscle == "Hamstrings" })?.thisWeek ?? 0
        if quadVol > 0 && hamVol > 0 {
            let ratio = quadVol / hamVol
            if ratio > 2.0 {
                insights.append(BalanceInsight(
                    category: .quadPosterior,
                    status: .imbalanced,
                    detail: "Quad-dominant lower body. Hamstrings need more volume for knee health and performance.",
                    dominant: "Quads",
                    weak: "Hamstrings",
                    ratio: ratio
                ))
            }
        }

        let chestVol = muscleBalance.first(where: { $0.muscle == "Chest" })?.thisWeek ?? 0
        let backVol = muscleBalance.first(where: { $0.muscle == "Back" })?.thisWeek ?? 0
        if chestVol > 0 && backVol > 0 {
            let ratio = chestVol / backVol
            if ratio > 1.5 {
                insights.append(BalanceInsight(
                    category: .chestBack,
                    status: .imbalanced,
                    detail: "Chest volume is significantly ahead of back. This creates postural imbalance over time.",
                    dominant: "Chest",
                    weak: "Back",
                    ratio: ratio
                ))
            }
        }

        let focusMuscleNames = Set(profile.focusMuscles.map(\.displayName))
        let undertrainedFocus = muscleBalance.filter { focusMuscleNames.contains($0.muscle) && $0.percentOfAverage < 0.8 }
        for entry in undertrainedFocus {
            insights.append(BalanceInsight(
                category: .focusMuscle,
                status: .imbalanced,
                detail: "\(entry.muscle) is a priority muscle but volume is \(Int((1.0 - entry.percentOfAverage) * 100))% below your average.",
                dominant: nil,
                weak: entry.muscle,
                ratio: entry.percentOfAverage
            ))
        }

        return insights
    }

    func weeklyVolumeGuidance(
        landmarks: [VolumeLandmark],
        profile: UserProfile,
        phase: TrainingPhase
    ) -> [VolumeGuidance] {
        landmarks.compactMap { landmark -> VolumeGuidance? in
            let target: Int
            switch phase {
            case .build:
                target = landmark.minimumEffectiveVolume + (landmark.maintenanceVolume - landmark.minimumEffectiveVolume) / 2
            case .push:
                target = landmark.maintenanceVolume + (landmark.maximumRecoverableVolume - landmark.maintenanceVolume) / 3
            case .fatigueManagement:
                target = landmark.maintenanceVolume
            case .deload:
                target = landmark.minimumEffectiveVolume
            case .rebalance:
                let isFocus = profile.focusMuscles.contains(where: { $0.displayName == landmark.muscleGroup })
                target = isFocus ? landmark.maintenanceVolume + 2 : landmark.maintenanceVolume
            }

            let diff = landmark.currentWeeklySets - target
            let action: VolumeAction
            if diff > 3 {
                action = .reduce
            } else if diff < -3 {
                action = .increase
            } else if diff < -1 {
                action = .slightIncrease
            } else if diff > 1 {
                action = .slightReduce
            } else {
                action = .maintain
            }

            guard action != .maintain else { return nil }

            return VolumeGuidance(
                muscleGroup: landmark.muscleGroup,
                currentSets: landmark.currentWeeklySets,
                targetSets: target,
                action: action,
                explanation: volumeExplanation(landmark: landmark, target: target, action: action, phase: phase)
            )
        }
    }

    // MARK: - Private

    private func volumeTargets(for muscle: MuscleGroup, profile: UserProfile) -> (mev: Int, mv: Int, mrv: Int) {
        let levelMultiplier: Double
        switch profile.trainingLevel {
        case .beginner: levelMultiplier = 0.75
        case .intermediate: levelMultiplier = 1.0
        case .advanced: levelMultiplier = 1.2
        }

        let goalMultiplier: Double
        switch profile.goal {
        case .muscleGain: goalMultiplier = 1.15
        case .strength: goalMultiplier = 0.95
        case .fatLoss: goalMultiplier = 0.85
        default: goalMultiplier = 1.0
        }

        let isFocus = profile.focusMuscles.contains(muscle) || profile.focusMuscles.contains(where: { $0.displayName == muscle.displayName })

        let baseMEV: Int
        let baseMV: Int
        let baseMRV: Int

        switch muscle {
        case .chest:
            baseMEV = 8; baseMV = 12; baseMRV = 20
        case .back, .lats:
            baseMEV = 8; baseMV = 14; baseMRV = 22
        case .shoulders:
            baseMEV = 6; baseMV = 10; baseMRV = 18
        case .quads:
            baseMEV = 8; baseMV = 12; baseMRV = 20
        case .hamstrings:
            baseMEV = 6; baseMV = 10; baseMRV = 16
        case .glutes:
            baseMEV = 6; baseMV = 10; baseMRV = 18
        case .biceps, .triceps, .arms:
            baseMEV = 4; baseMV = 8; baseMRV = 16
        case .abs, .obliques, .coreStability:
            baseMEV = 4; baseMV = 8; baseMRV = 14
        case .calves:
            baseMEV = 6; baseMV = 10; baseMRV = 16
        default:
            baseMEV = 4; baseMV = 8; baseMRV = 14
        }

        let focusBonus = isFocus ? 2 : 0
        let mult = levelMultiplier * goalMultiplier

        return (
            mev: max(2, Int(Double(baseMEV) * mult)),
            mv: Int(Double(baseMV) * mult) + focusBonus,
            mrv: Int(Double(baseMRV) * mult) + focusBonus
        )
    }

    private func countWeeklySetsByMuscle(sessions: [WorkoutSession]) -> [String: Int] {
        let library = ExerciseLibrary.shared
        var counts: [String: Int] = [:]

        for session in sessions {
            for log in session.exerciseLogs {
                guard let exercise = library.exercise(byId: log.exerciseId) else { continue }
                let completedSets = log.sets.filter(\.isCompleted).count
                let primary = exercise.primaryMuscle.displayName
                let mappedPrimary = mapToMajorGroup(primary)
                counts[mappedPrimary, default: 0] += completedSets

                for secondary in exercise.secondaryMuscles {
                    let mappedSecondary = mapToMajorGroup(secondary.displayName)
                    counts[mappedSecondary, default: 0] += completedSets / 2
                }
            }
        }

        return counts
    }

    private func mapToMajorGroup(_ muscle: String) -> String {
        switch muscle {
        case "Biceps", "Triceps", "Forearms": return "Arms"
        case "Lats": return "Back"
        case "Obliques", "Core Stability", "Rotation": return "Abs"
        default: return muscle
        }
    }

    private func volumeExplanation(landmark: VolumeLandmark, target: Int, action: VolumeAction, phase: TrainingPhase) -> String {
        let muscle = landmark.muscleGroup.lowercased()
        switch action {
        case .increase:
            return "\(landmark.muscleGroup) is at \(landmark.currentWeeklySets) sets — target is \(target). Add \(target - landmark.currentWeeklySets) sets to reach productive volume."
        case .slightIncrease:
            return "\(landmark.muscleGroup) could use \(target - landmark.currentWeeklySets) more sets to optimize \(muscle) growth."
        case .reduce:
            return "\(landmark.muscleGroup) is at \(landmark.currentWeeklySets) sets — above the \(landmark.maximumRecoverableVolume)-set recovery limit. Cut \(landmark.currentWeeklySets - target) sets to avoid overreaching."
        case .slightReduce:
            return "Slightly reduce \(muscle) volume for better recovery during this \(phase.displayName.lowercased())."
        case .maintain:
            return "\(landmark.muscleGroup) volume is right on target."
        }
    }
}

nonisolated enum BalanceCategory: String, Sendable {
    case pushPull
    case upperLower
    case quadPosterior
    case chestBack
    case focusMuscle

    var displayName: String {
        switch self {
        case .pushPull: "Push vs Pull"
        case .upperLower: "Upper vs Lower"
        case .quadPosterior: "Quad vs Posterior"
        case .chestBack: "Chest vs Back"
        case .focusMuscle: "Focus Muscle"
        }
    }
}

nonisolated enum BalanceStatus: String, Sendable {
    case balanced
    case imbalanced
}

nonisolated struct BalanceInsight: Identifiable, Sendable {
    let id: String
    let category: BalanceCategory
    let status: BalanceStatus
    let detail: String
    let dominant: String?
    let weak: String?
    let ratio: Double

    init(id: String = UUID().uuidString, category: BalanceCategory, status: BalanceStatus, detail: String, dominant: String?, weak: String?, ratio: Double) {
        self.id = id
        self.category = category
        self.status = status
        self.detail = detail
        self.dominant = dominant
        self.weak = weak
        self.ratio = ratio
    }
}

nonisolated enum VolumeAction: String, Sendable {
    case increase
    case slightIncrease
    case maintain
    case slightReduce
    case reduce
}

nonisolated struct VolumeGuidance: Identifiable, Sendable {
    let id: String
    let muscleGroup: String
    let currentSets: Int
    let targetSets: Int
    let action: VolumeAction
    let explanation: String

    init(id: String = UUID().uuidString, muscleGroup: String, currentSets: Int, targetSets: Int, action: VolumeAction, explanation: String) {
        self.id = id
        self.muscleGroup = muscleGroup
        self.currentSets = currentSets
        self.targetSets = targetSets
        self.action = action
        self.explanation = explanation
    }
}
