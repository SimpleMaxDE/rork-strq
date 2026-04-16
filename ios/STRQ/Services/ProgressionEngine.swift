import Foundation

struct ProgressionEngine {
    private let library = ExerciseLibrary.shared

    func classifyExerciseFamily(_ exercise: Exercise) -> ExerciseFamily {
        switch exercise.category {
        case .compound:
            let heavyPatterns: Set<MovementPattern> = [.squat, .hipHinge, .horizontalPush, .verticalPush]
            if heavyPatterns.contains(exercise.movementPattern) && exercise.equipment.contains(where: { $0 == .barbell }) {
                return .heavyCompound
            }
            return .hypertrophyCompound
        case .isolation:
            if exercise.equipment.contains(.machine) || exercise.equipment.contains(.cable) {
                return .machineExercise
            }
            return .isolationLift
        case .bodyweight:
            if exercise.progressionOf != nil || exercise.regressionOf != nil {
                return .calisthenicsProgression
            }
            return .bodyweightExercise
        case .mobility, .pilates, .recovery, .warmup:
            return .mobilityCore
        case .cardio:
            return .mobilityCore
        }
    }

    func analyzeProgression(
        exerciseId: String,
        sessions: [WorkoutSession],
        profile: UserProfile,
        currentPhase: TrainingPhase
    ) -> ExerciseProgressionState {
        guard let exercise = library.exercise(byId: exerciseId) else {
            return ExerciseProgressionState(exerciseId: exerciseId)
        }

        let family = classifyExerciseFamily(exercise)
        let relevantLogs = extractLogs(for: exerciseId, from: sessions)

        guard relevantLogs.count >= 2 else {
            return ExerciseProgressionState(
                exerciseId: exerciseId,
                sessionCount: relevantLogs.count,
                plateauStatus: .progressing,
                recommendedStrategy: family.progressionPriority,
                coachNote: relevantLogs.isEmpty ? "Not enough data yet." : "Keep training — building baseline data."
            )
        }

        let trend = computePerformanceTrend(relevantLogs)
        let plateauStatus = detectPlateau(trend: trend, logs: relevantLogs)
        let strategy = determineStrategy(
            family: family,
            plateau: plateauStatus,
            profile: profile,
            phase: currentPhase,
            exercise: exercise,
            recentLogs: relevantLogs
        )

        let lastLog = relevantLogs.first!
        let bestSet = lastLog.sets.filter(\.isCompleted).max(by: { $0.weight * Double($0.reps) < $1.weight * Double($1.reps) })

        let (nextWeight, nextReps) = suggestNext(
            strategy: strategy,
            family: family,
            lastWeight: bestSet?.weight ?? 0,
            lastReps: bestSet?.reps ?? 0,
            exercise: exercise,
            profile: profile
        )

        let note = generateCoachNote(
            plateau: plateauStatus,
            strategy: strategy,
            family: family,
            exercise: exercise,
            phase: currentPhase
        )

        let consecutiveSame = countConsecutiveSamePerformance(relevantLogs)

        return ExerciseProgressionState(
            exerciseId: exerciseId,
            lastWeight: bestSet?.weight ?? 0,
            lastReps: bestSet?.reps ?? 0,
            lastRPE: bestSet?.rpe,
            sessionCount: relevantLogs.count,
            consecutiveSamePerformance: consecutiveSame,
            plateauStatus: plateauStatus,
            recommendedStrategy: strategy,
            suggestedNextWeight: nextWeight,
            suggestedNextReps: nextReps,
            performanceTrend: trend,
            coachNote: note
        )
    }

    func determineTrainingPhase(
        profile: UserProfile,
        sessions: [WorkoutSession],
        progressEntries: [ProgressEntry],
        recoveryScore: Int,
        currentPhase: TrainingPhaseState,
        muscleBalance: [MuscleBalanceEntry]
    ) -> (TrainingPhase, String) {
        let weeksInPhase = currentPhase.weeksInPhase
        let totalWeeks = currentPhase.totalWeeksTrained

        if recoveryScore < 40 {
            return (.deload, "Recovery is critically low. A deload week will help your body recover and come back stronger.")
        }

        if recoveryScore < 55 && weeksInPhase >= 2 && currentPhase.currentPhase == .push {
            return (.fatigueManagement, "Accumulated fatigue from the push phase is high. Backing off to protect long-term progress.")
        }

        if currentPhase.currentPhase == .deload && weeksInPhase >= 1 {
            let undertrained = muscleBalance.filter { $0.percentOfAverage < 0.75 }
            if undertrained.count >= 2 {
                return (.rebalance, "Post-deload is a good time to address muscle imbalances before pushing again.")
            }
            return (.build, "Deload complete. Rebuilding work capacity before the next progression push.")
        }

        if currentPhase.currentPhase == .fatigueManagement && weeksInPhase >= 2 {
            if recoveryScore >= 70 {
                return (.push, "Recovery has improved. Time to push for new progress.")
            }
            return (.deload, "Recovery hasn't improved enough. A structured deload is needed.")
        }

        if currentPhase.currentPhase == .build && weeksInPhase >= 3 && recoveryScore >= 65 {
            return (.push, "Work capacity is established. Time to push intensity and volume for progress.")
        }

        if currentPhase.currentPhase == .push && weeksInPhase >= 4 {
            if recoveryScore < 65 {
                return (.fatigueManagement, "After \(weeksInPhase) weeks of pushing, fatigue signals suggest backing off.")
            }
            if weeksInPhase >= 6 {
                return (.fatigueManagement, "Extended push phase complete. Managing fatigue before the next block.")
            }
        }

        if currentPhase.currentPhase == .rebalance && weeksInPhase >= 3 {
            return (.build, "Rebalance phase complete. Moving to build phase.")
        }

        if totalWeeks > 0 && totalWeeks % 4 == 0 && currentPhase.currentPhase != .deload && recoveryScore < 70 {
            return (.deload, "Every 4 weeks of consistent training benefits from a planned deload.")
        }

        return (currentPhase.currentPhase, "Continuing current \(currentPhase.currentPhase.displayName.lowercased()).")
    }

    func assessPlanQuality(
        plan: WorkoutPlan,
        profile: UserProfile,
        muscleBalance: [MuscleBalanceEntry],
        recoveryScore: Int,
        progressionStates: [ExerciseProgressionState],
        phase: TrainingPhase
    ) -> PlanQualityScore {
        let recoveryFit = assessRecoveryFit(plan: plan, recoveryScore: recoveryScore, phase: phase)
        let timeFit = assessTimeFit(plan: plan, profile: profile)
        let balance = assessMuscleBalance(plan: plan, muscleBalance: muscleBalance, profile: profile)
        let equipmentFit = assessEquipmentFit(plan: plan, profile: profile)
        let progressionReady = assessProgressionReadiness(progressionStates: progressionStates, phase: phase)

        let overall = (recoveryFit.score + timeFit.score + balance.score + equipmentFit.score + progressionReady.score) / 5.0

        var strengths: [String] = []
        var watchItems: [String] = []
        var riskFlags: [String] = []

        if recoveryFit == .excellent || recoveryFit == .good {
            strengths.append("Training load matches your recovery capacity")
        }
        if balance == .excellent || balance == .good {
            strengths.append("Good muscle group coverage and balance")
        }
        if equipmentFit == .excellent {
            strengths.append("All exercises match your available equipment")
        }
        if progressionReady == .excellent || progressionReady == .good {
            strengths.append("Multiple exercises ready for progression")
        }

        if recoveryFit == .poor {
            riskFlags.append("Training volume may exceed recovery capacity")
        }
        if balance == .poor {
            riskFlags.append("Significant muscle group imbalances detected")
        }

        let plateaued = progressionStates.filter { $0.plateauStatus == .plateaued || $0.plateauStatus == .regressing }
        if plateaued.count >= 2 {
            watchItems.append("\(plateaued.count) exercises showing stalled progress")
        }

        let undertrained = muscleBalance.filter { $0.percentOfAverage < 0.75 }
        if !undertrained.isEmpty {
            watchItems.append("\(undertrained.map(\.muscle).joined(separator: ", ")) volume below target")
        }

        if phase == .push && recoveryScore < 65 {
            watchItems.append("Recovery trending low during push phase")
        }

        return PlanQualityScore(
            overall: overall,
            recoveryFit: recoveryFit,
            timeFit: timeFit,
            muscleBalance: balance,
            equipmentFit: equipmentFit,
            progressionReadiness: progressionReady,
            riskFlags: riskFlags,
            strengths: strengths,
            watchItems: watchItems
        )
    }

    func computeNextBestAction(
        profile: UserProfile,
        sessions: [WorkoutSession],
        recoveryScore: Int,
        muscleBalance: [MuscleBalanceEntry],
        progressionStates: [ExerciseProgressionState],
        phase: TrainingPhase
    ) -> NextBestAction {
        if recoveryScore < 40 {
            return NextBestAction(
                title: "Start Deload Week",
                explanation: "Your recovery is critically low. A deload week will prevent overtraining and help you come back stronger.",
                icon: "arrow.down.to.line",
                colorName: "purple",
                confidence: 0.95,
                actionType: .deload
            )
        }

        if recoveryScore < 55 {
            return NextBestAction(
                title: "Go Lighter Next Session",
                explanation: "Fatigue is accumulating. A lighter session maintains your training rhythm while protecting recovery.",
                icon: "arrow.down.circle",
                colorName: "orange",
                confidence: 0.85,
                actionType: .lighterSession
            )
        }

        let plateaued = progressionStates.filter { $0.plateauStatus == .plateaued || $0.plateauStatus == .regressing }
        if plateaued.count >= 2 {
            let names = plateaued.prefix(2).compactMap { library.exercise(byId: $0.exerciseId)?.name }
            return NextBestAction(
                title: "Swap Stalled Exercises",
                explanation: "\(names.joined(separator: " and ")) have plateaued. Fresh exercise selection can restart progress.",
                icon: "arrow.triangle.2.circlepath",
                colorName: "blue",
                confidence: 0.8,
                actionType: .swapExercise
            )
        }

        let severeImbalance = muscleBalance.filter { $0.percentOfAverage < 0.7 }
        if severeImbalance.count >= 2 {
            return NextBestAction(
                title: "Regenerate Next Week",
                explanation: "Multiple muscle groups are significantly undertrained. A regenerated week can rebalance your training.",
                icon: "arrow.triangle.2.circlepath.circle.fill",
                colorName: "cyan",
                confidence: 0.8,
                actionType: .regenerateWeek
            )
        }

        let undertrained = muscleBalance.filter { $0.percentOfAverage < 0.8 }
        if !undertrained.isEmpty {
            return NextBestAction(
                title: "Add \(undertrained.first!.muscle) Work",
                explanation: "\(undertrained.first!.muscle) volume is below your recent average. Adding sets will improve balance.",
                icon: "plus.circle.fill",
                colorName: "orange",
                confidence: 0.7,
                actionType: .addWork
            )
        }

        let progressing = progressionStates.filter { $0.plateauStatus == .progressing }
        if !progressing.isEmpty && recoveryScore >= 70 && phase == .push {
            return NextBestAction(
                title: "Keep Pushing — Progress is Strong",
                explanation: "Recovery is good and you're making progress. Stay the course and keep building.",
                icon: "arrow.up.right.circle.fill",
                colorName: "green",
                confidence: 0.85,
                actionType: .celebrate
            )
        }

        return NextBestAction(
            title: "Continue As Planned",
            explanation: "Your training is on track. Keep showing up and executing with intent.",
            icon: "checkmark.circle.fill",
            colorName: "green",
            confidence: 0.7,
            actionType: .celebrate
        )
    }

    // MARK: - Private Helpers

    private func extractLogs(for exerciseId: String, from sessions: [WorkoutSession]) -> [ExerciseLog] {
        sessions
            .filter(\.isCompleted)
            .sorted { $0.startTime > $1.startTime }
            .compactMap { session in
                session.exerciseLogs.first { $0.exerciseId == exerciseId && $0.isCompleted }
            }
    }

    private func computePerformanceTrend(_ logs: [ExerciseLog]) -> [Double] {
        logs.prefix(8).map { log in
            log.sets.filter(\.isCompleted).reduce(0.0) { $0 + $1.weight * Double($1.reps) }
        }
    }

    private func detectPlateau(trend: [Double], logs: [ExerciseLog]) -> PlateauStatus {
        guard trend.count >= 3 else { return .progressing }

        let recent = Array(trend.prefix(3))
        let older = trend.count >= 6 ? Array(trend[3..<min(6, trend.count)]) : Array(trend.suffix(max(1, trend.count - 3)))

        let recentAvg = recent.reduce(0, +) / Double(recent.count)
        let olderAvg = older.reduce(0, +) / Double(older.count)

        guard olderAvg > 0 else { return .progressing }

        let changeRate = (recentAvg - olderAvg) / olderAvg

        if changeRate > 0.03 { return .progressing }
        if changeRate > -0.02 {
            let variance = recent.map { abs($0 - recentAvg) }.reduce(0, +) / Double(recent.count)
            let normalizedVariance = variance / max(recentAvg, 1)
            return normalizedVariance < 0.05 ? .plateaued : .stalling
        }
        return .regressing
    }

    private func countConsecutiveSamePerformance(_ logs: [ExerciseLog]) -> Int {
        guard logs.count >= 2 else { return 0 }

        let volumes = logs.prefix(6).map { log in
            log.sets.filter(\.isCompleted).reduce(0.0) { $0 + $1.weight * Double($1.reps) }
        }

        guard let first = volumes.first, first > 0 else { return 0 }
        var count = 0
        for vol in volumes.dropFirst() {
            let diff = abs(vol - first) / first
            if diff < 0.05 {
                count += 1
            } else {
                break
            }
        }
        return count
    }

    private func determineStrategy(
        family: ExerciseFamily,
        plateau: PlateauStatus,
        profile: UserProfile,
        phase: TrainingPhase,
        exercise: Exercise,
        recentLogs: [ExerciseLog]
    ) -> ProgressionStrategy {
        if plateau == .regressing {
            return .deloadAndRebuild
        }

        if plateau == .plateaued {
            switch family {
            case .heavyCompound:
                return .holdAndConsolidate
            case .bodyweightExercise, .calisthenicsProgression:
                return .variationProgression
            default:
                return .doubleProgression
            }
        }

        if phase == .deload || phase == .fatigueManagement {
            return .holdAndConsolidate
        }

        if profile.trainingLevel == .beginner {
            return family == .heavyCompound ? .loadFirst : .repFirst
        }

        return family.progressionPriority
    }

    private func suggestNext(
        strategy: ProgressionStrategy,
        family: ExerciseFamily,
        lastWeight: Double,
        lastReps: Int,
        exercise: Exercise,
        profile: UserProfile
    ) -> (Double?, String?) {
        guard lastWeight > 0 || lastReps > 0 else { return (nil, nil) }

        switch strategy {
        case .loadFirst:
            let increment = family.loadIncrementKg > 0 ? family.loadIncrementKg : 2.5
            let lower = profile.goal == .strength && exercise.category == .compound
            return (lastWeight + increment, lower ? "\(max(1, lastReps - 1))-\(lastReps)" : "\(lastReps)")
        case .repFirst:
            return (lastWeight, "\(lastReps + 1)-\(lastReps + 2)")
        case .doubleProgression:
            let topRep = exercise.category == .compound ? 12 : 15
            if lastReps >= topRep {
                let increment = family.loadIncrementKg > 0 ? family.loadIncrementKg : 1.25
                return (lastWeight + increment, "\(max(6, topRep - 4))-\(topRep)")
            }
            return (lastWeight, "\(lastReps + 1)-\(min(lastReps + 3, topRep))")
        case .variationProgression:
            return (nil, "Progress to harder variation")
        case .tempoProgression:
            return (lastWeight, "\(lastReps) with slower tempo")
        case .holdAndConsolidate:
            return (lastWeight, "\(lastReps)")
        case .deloadAndRebuild:
            return (lastWeight * 0.85, "\(lastReps)")
        }
    }

    private func generateCoachNote(
        plateau: PlateauStatus,
        strategy: ProgressionStrategy,
        family: ExerciseFamily,
        exercise: Exercise,
        phase: TrainingPhase
    ) -> String {
        switch plateau {
        case .regressing:
            return "Performance is declining. Reduce load by 10-15% and rebuild with strict form. This is normal — it means you pushed hard."
        case .plateaued:
            switch family {
            case .heavyCompound:
                return "This lift has stalled. Hold the current weight for another session, then try a small increase. If it persists, consider a variation swap."
            case .bodyweightExercise, .calisthenicsProgression:
                return "You've maxed out this variation. Progress to a harder version or add tempo/pause work to increase difficulty."
            default:
                return "Performance has plateaued. Try adding 1-2 reps before increasing weight, or switch to a similar exercise for fresh stimulus."
            }
        case .stalling:
            if phase == .push {
                return "Progress is slowing. This is expected late in a push phase. Keep quality high and don't force weight increases."
            }
            return "Progress is slowing slightly. Focus on rep quality and controlled tempo. Progression will come."
        case .progressing:
            switch strategy {
            case .loadFirst:
                return "Making good progress. Add a small increment next session while maintaining rep quality."
            case .repFirst:
                return "Building well. Add another rep or two at the same weight before increasing load."
            case .doubleProgression:
                return "Working toward the top of your rep range. Once you hit it consistently, bump up the weight."
            default:
                return "On track. Keep training with intent and progression will follow."
            }
        }
    }

    // MARK: - Plan Quality Assessments

    private func assessRecoveryFit(plan: WorkoutPlan, recoveryScore: Int, phase: TrainingPhase) -> QualityRating {
        let totalSets = plan.days.reduce(0) { $0 + $1.exercises.reduce(0) { $0 + $1.sets } }
        let setsPerDay = plan.days.isEmpty ? 0 : totalSets / plan.days.count

        if recoveryScore >= 75 {
            return setsPerDay <= 24 ? .excellent : .good
        }
        if recoveryScore >= 55 {
            if phase == .deload || phase == .fatigueManagement { return setsPerDay <= 16 ? .good : .fair }
            return setsPerDay <= 20 ? .good : .fair
        }
        return setsPerDay <= 14 ? .fair : .poor
    }

    private func assessTimeFit(plan: WorkoutPlan, profile: UserProfile) -> QualityRating {
        let overTime = plan.days.filter { $0.estimatedMinutes > profile.minutesPerSession + 10 }
        if overTime.isEmpty { return .excellent }
        if overTime.count <= 1 { return .good }
        if overTime.count <= plan.days.count / 2 { return .fair }
        return .poor
    }

    private func assessMuscleBalance(plan: WorkoutPlan, muscleBalance: [MuscleBalanceEntry], profile: UserProfile) -> QualityRating {
        let severelyUndertrained = muscleBalance.filter { $0.percentOfAverage < 0.7 }
        let mildlyUndertrained = muscleBalance.filter { $0.percentOfAverage < 0.85 }
        let focusUndertrained = muscleBalance.filter { entry in
            profile.focusMuscles.contains(where: { $0.displayName == entry.muscle }) && entry.percentOfAverage < 0.85
        }

        if severelyUndertrained.isEmpty && focusUndertrained.isEmpty { return .excellent }
        if severelyUndertrained.isEmpty && mildlyUndertrained.count <= 2 { return .good }
        if severelyUndertrained.count <= 1 { return .fair }
        return .poor
    }

    private func assessEquipmentFit(plan: WorkoutPlan, profile: UserProfile) -> QualityRating {
        if profile.trainingLocation == .gym { return .excellent }
        var mismatches = 0
        for day in plan.days {
            for planned in day.exercises {
                guard let exercise = library.exercise(byId: planned.exerciseId) else { continue }
                if exercise.locationType == .gym && profile.trainingLocation != .gym {
                    mismatches += 1
                }
            }
        }
        if mismatches == 0 { return .excellent }
        if mismatches <= 1 { return .good }
        if mismatches <= 3 { return .fair }
        return .poor
    }

    private func assessProgressionReadiness(progressionStates: [ExerciseProgressionState], phase: TrainingPhase) -> QualityRating {
        guard !progressionStates.isEmpty else { return .good }
        let progressing = progressionStates.filter { $0.plateauStatus == .progressing }.count
        let total = progressionStates.count
        let ratio = Double(progressing) / Double(total)

        if ratio >= 0.7 { return .excellent }
        if ratio >= 0.5 { return .good }
        if ratio >= 0.3 { return .fair }
        return .poor
    }
}
