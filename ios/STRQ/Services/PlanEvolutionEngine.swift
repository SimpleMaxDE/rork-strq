import Foundation

// Plan-level adaptive intelligence. Looks across multiple weeks of real training
// behavior and decides whether the program itself should evolve — not just a single
// session's prescription. Outputs flow through the existing insights + recommendations
// streams so no new UI surface is required.

nonisolated enum PlanEvolutionConfidence: Sendable {
    case low
    case moderate
    case high
}

nonisolated enum PlanEvolutionKind: Sendable {
    case reduceFrequency
    case rebalanceMuscle(muscle: String)
    case swapAnchorLift(from: String, to: String, muscle: String)
    case triggerDeload
    case maintainPush
    case reduceDayVolume(dayHint: String)
    case reorderDayEmphasis(muscle: String)
}

nonisolated struct PlanEvolutionSignal: Sendable {
    let kind: PlanEvolutionKind
    let confidence: PlanEvolutionConfidence
    let insight: SmartInsight
    let recommendation: Recommendation?
}

struct PlanEvolutionEngine {
    private let library = ExerciseLibrary.shared

    func analyze(
        profile: UserProfile,
        currentPlan: WorkoutPlan?,
        workoutHistory: [WorkoutSession],
        progressionStates: [ExerciseProgressionState],
        muscleBalance: [MuscleBalanceEntry],
        recoveryTrend: [Int],
        weeksTrained: Int,
        phase: TrainingPhase,
        baseConfidence: CoachingConfidence
    ) -> [PlanEvolutionSignal] {
        // We need at least ~2 weeks of usage before reshaping the plan. Under that,
        // observe silently.
        guard weeksTrained >= 2, baseConfidence >= .moderate else { return [] }

        var signals: [PlanEvolutionSignal] = []

        if let s = analyzeFrequencyAdherence(profile: profile, workoutHistory: workoutHistory, weeksTrained: weeksTrained) {
            signals.append(s)
        }
        if let s = analyzeMuscleDrift(muscleBalance: muscleBalance, profile: profile, weeksTrained: weeksTrained) {
            signals.append(s)
        }
        if let s = analyzeStallVsProgress(progressionStates: progressionStates, weeksTrained: weeksTrained) {
            signals.append(s)
        }
        if let s = analyzeRecoveryTrend(recoveryTrend: recoveryTrend, workoutHistory: workoutHistory, weeksTrained: weeksTrained, phase: phase) {
            signals.append(s)
        }
        if let s = analyzeMaintainPush(recoveryTrend: recoveryTrend, progressionStates: progressionStates, weeksTrained: weeksTrained, phase: phase) {
            signals.append(s)
        }

        return signals
    }

    // MARK: - Adherence

    private func analyzeFrequencyAdherence(
        profile: UserProfile,
        workoutHistory: [WorkoutSession],
        weeksTrained: Int
    ) -> PlanEvolutionSignal? {
        guard profile.daysPerWeek >= 3 else { return nil }
        let calendar = Calendar.current
        let lookback = min(weeksTrained, 4)
        guard lookback >= 2 else { return nil }

        var completions: [Int] = []
        for weekOffset in 0..<lookback {
            let weekStart = calendar.date(byAdding: .day, value: -7 * (weekOffset + 1), to: Date()) ?? Date()
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? Date()
            let count = workoutHistory.filter { $0.isCompleted && $0.startTime >= weekStart && $0.startTime < weekEnd }.count
            completions.append(count)
        }

        let avg = Double(completions.reduce(0, +)) / Double(max(1, completions.count))
        let target = Double(profile.daysPerWeek)
        let ratio = avg / target

        // Consistent under-performance → suggest reducing frequency.
        let lowWeeks = completions.filter { Double($0) <= target - 1.5 }.count
        if ratio < 0.7 && lowWeeks >= lookback - 1 {
            let suggested = max(2, profile.daysPerWeek - 1)
            let confidence: PlanEvolutionConfidence = (lookback >= 3 && ratio < 0.55) ? .high : .moderate
            let insight = SmartInsight(
                icon: "calendar.badge.exclamationmark",
                color: "orange",
                title: "Frequency Not Sticking",
                message: "You've averaged \(String(format: "%.1f", avg)) of \(profile.daysPerWeek) planned sessions over \(lookback) weeks. A \(suggested)-day plan is likely to produce more consistent results.",
                severity: .medium,
                category: .consistency
            )
            let rec = Recommendation(
                type: .splitSuggestion,
                title: "Consider \(suggested)-Day Plan",
                message: "Adherence has been low for multiple weeks. Matching plan frequency to what you actually train is more productive than missing sessions on paper.",
                priority: 3
            )
            return PlanEvolutionSignal(kind: .reduceFrequency, confidence: confidence, insight: insight, recommendation: rec)
        }

        return nil
    }

    // MARK: - Muscle Drift

    private func analyzeMuscleDrift(
        muscleBalance: [MuscleBalanceEntry],
        profile: UserProfile,
        weeksTrained: Int
    ) -> PlanEvolutionSignal? {
        // Find a muscle that has been persistently low relative to its 4-week average.
        let lagging = muscleBalance
            .filter { $0.average > 0 && $0.percentOfAverage < 0.75 }
            .sorted { $0.percentOfAverage < $1.percentOfAverage }

        guard let weakest = lagging.first else { return nil }

        let focusNames = Set(profile.focusMuscles.map(\.displayName))
        let isFocus = focusNames.contains(weakest.muscle)
        // Extra caution if evidence is only from 2 weeks.
        let confidence: PlanEvolutionConfidence = weeksTrained >= 3 ? .high : .moderate

        let severity: InsightSeverity = isFocus ? .high : .medium
        let insight = SmartInsight(
            icon: "chart.bar.xaxis",
            color: isFocus ? "red" : "orange",
            title: "\(weakest.muscle) Lagging Across Weeks",
            message: "\(weakest.muscle) volume has sat at \(Int(weakest.percentOfAverage * 100))% of its recent average. Rebalance the plan next week to close the gap\(isFocus ? " — this is a focus muscle for you." : ".")",
            severity: severity,
            category: .volumeBalance
        )

        let rec = Recommendation(
            type: .volumeImbalance,
            title: "Rebalance \(weakest.muscle) Next Week",
            message: "Shift a set or two toward \(weakest.muscle.lowercased()) next week — persistent undertraining here will cap progress.",
            priority: isFocus ? 4 : 3
        )
        return PlanEvolutionSignal(kind: .rebalanceMuscle(muscle: weakest.muscle), confidence: confidence, insight: insight, recommendation: rec)
    }

    // MARK: - Anchor Lift Swap

    private func analyzeStallVsProgress(
        progressionStates: [ExerciseProgressionState],
        weeksTrained: Int
    ) -> PlanEvolutionSignal? {
        // Find a stalled lift whose muscle group has another exercise that is clearly progressing.
        let stalled = progressionStates.filter {
            ($0.plateauStatus == .plateaued || $0.plateauStatus == .regressing) && $0.sessionCount >= 4
        }
        guard !stalled.isEmpty else { return nil }

        for stall in stalled {
            guard let stalledEx = library.exercise(byId: stall.exerciseId) else { continue }
            // Look for a progressing exercise sharing the same primary muscle.
            let progressingSameMuscle = progressionStates.first { state in
                state.plateauStatus == .progressing &&
                state.sessionCount >= 3 &&
                state.exerciseId != stall.exerciseId &&
                (library.exercise(byId: state.exerciseId)?.primaryMuscle == stalledEx.primaryMuscle)
            }
            guard let alt = progressingSameMuscle, let altEx = library.exercise(byId: alt.exerciseId) else { continue }

            let confidence: PlanEvolutionConfidence = (stall.sessionCount >= 6 && weeksTrained >= 3) ? .high : .moderate
            let insight = SmartInsight(
                icon: "arrow.triangle.swap",
                color: "blue",
                title: "Shift Anchor: \(altEx.name) Over \(stalledEx.name)",
                message: "\(altEx.name) is progressing while \(stalledEx.name) has stalled for \(stall.sessionCount) sessions. Leading with \(altEx.name) next block should restart progress on \(stalledEx.primaryMuscle.displayName.lowercased()).",
                severity: .medium,
                category: .progression
            )
            let rec = Recommendation(
                type: .exerciseSwap,
                title: "Lead With \(altEx.name)",
                message: "Repeated stalls on \(stalledEx.name) while \(altEx.name) keeps progressing — reorder next week so the progressing lift is the anchor.",
                priority: 3
            )
            return PlanEvolutionSignal(
                kind: .swapAnchorLift(from: stalledEx.name, to: altEx.name, muscle: stalledEx.primaryMuscle.displayName),
                confidence: confidence,
                insight: insight,
                recommendation: rec
            )
        }

        return nil
    }

    // MARK: - Recovery Trend

    private func analyzeRecoveryTrend(
        recoveryTrend: [Int],
        workoutHistory: [WorkoutSession],
        weeksTrained: Int,
        phase: TrainingPhase
    ) -> PlanEvolutionSignal? {
        guard recoveryTrend.count >= 10 else { return nil }
        let recent = Array(recoveryTrend.suffix(7))
        let older = Array(recoveryTrend.prefix(max(3, recoveryTrend.count - 7)))
        let recentAvg = Double(recent.reduce(0, +)) / Double(recent.count)
        let olderAvg = Double(older.reduce(0, +)) / Double(older.count)
        let drop = olderAvg - recentAvg

        // Completion still high → earning a deload, not just drifting.
        let calendar = Calendar.current
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        let recentCompleted = workoutHistory.filter { $0.isCompleted && $0.startTime > twoWeeksAgo }.count

        if drop >= 12 && recentCompleted >= 5 && phase != .deload && phase != .fatigueManagement {
            let confidence: PlanEvolutionConfidence = drop >= 18 ? .high : .moderate
            let insight = SmartInsight(
                icon: "arrow.down.to.line",
                color: "purple",
                title: "Fatigue Trending Up Across Weeks",
                message: "Recovery has dropped ~\(Int(drop)) points while completion stayed high. A planned fatigue-management week now protects the next block.",
                severity: .medium,
                category: .recovery
            )
            let rec = Recommendation(
                type: .recoveryConcern,
                title: "Plan a Fatigue-Management Week",
                message: "Multi-week recovery trend is negative. A lighter block now preserves long-term progress better than pushing through.",
                priority: 4
            )
            return PlanEvolutionSignal(kind: .triggerDeload, confidence: confidence, insight: insight, recommendation: rec)
        }

        return nil
    }

    // MARK: - Maintain Push

    private func analyzeMaintainPush(
        recoveryTrend: [Int],
        progressionStates: [ExerciseProgressionState],
        weeksTrained: Int,
        phase: TrainingPhase
    ) -> PlanEvolutionSignal? {
        guard weeksTrained >= 3, recoveryTrend.count >= 7 else { return nil }
        let recentAvg = Double(recoveryTrend.suffix(7).reduce(0, +)) / 7.0
        guard recentAvg >= 72 else { return nil }

        let progressingCount = progressionStates.filter { $0.plateauStatus == .progressing }.count
        let total = max(1, progressionStates.count)
        let ratio = Double(progressingCount) / Double(total)
        guard ratio >= 0.55, progressingCount >= 3 else { return nil }

        let insight = SmartInsight(
            icon: "bolt.fill",
            color: "green",
            title: "Plan Is Working — Maintain Push",
            message: "Recovery is steady and \(progressingCount) lifts are progressing. Hold structure and continue progressive overload — no changes needed.",
            severity: .positive,
            category: .progression
        )
        return PlanEvolutionSignal(kind: .maintainPush, confidence: .high, insight: insight, recommendation: nil)
    }
}
