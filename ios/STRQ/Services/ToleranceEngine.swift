import Foundation

// Tolerance & execution-adjustment layer.
//
// Reads repeated set-quality patterns per exercise (pain / form breakdown /
// grinder / too easy / on target) across recent sessions and converts them
// into earned, confidence-aware coaching actions. Signals route through the
// existing insights + recommendations streams — no new UI.
//
// The philosophy is simple: a set completed with pain, repeated grind, or form
// breakdown is not the same as a clean completed set. This layer lets STRQ act
// on that truth instead of only detecting it.

nonisolated enum ToleranceSignalKind: Sendable {
    case holdForPain(exerciseId: String)
    case swapForPain(exerciseId: String, alternativeId: String)
    case holdForBreakdown(exerciseId: String)
    case holdForGrind(exerciseId: String)
    case accelerateTooEasy(exerciseId: String)
    case promoteAlternative(stalledId: String, alternativeId: String)
}

nonisolated enum ToleranceConfidence: Sendable {
    case low, moderate, high
}

nonisolated struct ToleranceSignal: Sendable {
    let kind: ToleranceSignalKind
    let confidence: ToleranceConfidence
    let insight: SmartInsight
    let recommendation: Recommendation?
}

struct ToleranceEngine {
    private let library = ExerciseLibrary.shared
    private let selection = ExerciseSelectionEngine()

    func analyze(
        profile: UserProfile,
        workoutHistory: [WorkoutSession],
        progressionStates: [ExerciseProgressionState],
        recoveryScore: Int,
        phase: TrainingPhase,
        baseConfidence: CoachingConfidence
    ) -> [ToleranceSignal] {
        let recentByExercise = buildRecentLogs(workoutHistory: workoutHistory)
        guard !recentByExercise.isEmpty else { return [] }

        let context = ExerciseSelectionContext(
            profile: profile,
            progressionStates: progressionStates,
            workoutHistory: workoutHistory,
            recoveryScore: recoveryScore,
            phase: phase
        )

        var signals: [ToleranceSignal] = []

        for (exerciseId, logs) in recentByExercise {
            guard let exercise = library.exercise(byId: exerciseId) else { continue }
            let q = quality(for: logs)
            let window = logs.count

            // Pain outweighs raw completion — always allowed, even at low base confidence.
            if q.painSessions >= 2 {
                let confidence: ToleranceConfidence = q.painSessions >= 3 ? .high : .moderate
                if let alt = saferAlternative(for: exercise, context: context) {
                    let insight = SmartInsight(
                        icon: "cross.case.fill",
                        color: "red",
                        title: "Pain Pattern on \(exercise.name)",
                        message: "Pain has shown up in \(q.painSessions) of the last \(window) \(exercise.name.lowercased()) sessions. \(alt.name) trains the same pattern with less joint stress.",
                        severity: .high,
                        category: .recovery
                    )
                    let rec = Recommendation(
                        type: .exerciseSwap,
                        title: "Swap \(exercise.name) → \(alt.name)",
                        message: "Repeated pain outweighs completion. \(alt.name) preserves the \(exercise.primaryMuscle.displayName.lowercased()) stimulus without the pain pattern.",
                        priority: 5
                    )
                    signals.append(ToleranceSignal(
                        kind: .swapForPain(exerciseId: exercise.id, alternativeId: alt.id),
                        confidence: confidence,
                        insight: insight,
                        recommendation: rec
                    ))
                } else {
                    let insight = SmartInsight(
                        icon: "cross.case.fill",
                        color: "red",
                        title: "Pain Pattern on \(exercise.name)",
                        message: "Pain has shown up in \(q.painSessions) of the last \(window) sessions. Holding pressure here until quality is clean.",
                        severity: .high,
                        category: .recovery
                    )
                    let rec = Recommendation(
                        type: .recoveryConcern,
                        title: "Reduce Pressure on \(exercise.name)",
                        message: "Pain is a stronger signal than completion. Hold load — or rest this movement — until it feels clean.",
                        priority: 5
                    )
                    signals.append(ToleranceSignal(
                        kind: .holdForPain(exerciseId: exercise.id),
                        confidence: confidence,
                        insight: insight,
                        recommendation: rec
                    ))
                }
                continue
            }

            // Below base moderate confidence, only the pain branch fires.
            guard baseConfidence >= .moderate else { continue }

            // Repeated form breakdown → hold load and protect execution quality.
            if q.formSessions >= 2 {
                let confidence: ToleranceConfidence = q.formSessions >= 3 ? .high : .moderate
                let insight = SmartInsight(
                    icon: "exclamationmark.triangle.fill",
                    color: "orange",
                    title: "Form Breakdown on \(exercise.name)",
                    message: "Form has broken down in \(q.formSessions) of the last \(window) sessions. Holding load here is more productive than forcing progression.",
                    severity: .medium,
                    category: .progression
                )
                let rec = Recommendation(
                    type: .progressionSuggestion,
                    title: "Hold \(exercise.name) for Quality",
                    message: "Repeated form breakdown caps progression confidence. Rebuild clean reps at the same load before adding weight.",
                    priority: 3
                )
                signals.append(ToleranceSignal(
                    kind: .holdForBreakdown(exerciseId: exercise.id),
                    confidence: confidence,
                    insight: insight,
                    recommendation: rec
                ))
                continue
            }

            // Repeated grinders without breakdown → hold pressure, earn it back.
            if q.grindSessions >= 3 {
                let insight = SmartInsight(
                    icon: "flame.fill",
                    color: "orange",
                    title: "\(exercise.name) Grinding Every Session",
                    message: "Last 3 \(exercise.name.lowercased()) sessions have been near-max grinders. Consolidating current load protects the next block.",
                    severity: .medium,
                    category: .progression
                )
                let rec = Recommendation(
                    type: .progressionSuggestion,
                    title: "Hold Load on \(exercise.name)",
                    message: "Consistent grind suggests you're at the edge of this load. Repeat before pushing again.",
                    priority: 3
                )
                signals.append(ToleranceSignal(
                    kind: .holdForGrind(exerciseId: exercise.id),
                    confidence: .moderate,
                    insight: insight,
                    recommendation: rec
                ))
                continue
            }

            // Repeated clean "too easy" → earn a more assertive progression.
            if q.tooEasySessions >= 3, q.painSessions == 0, q.formSessions == 0 {
                let insight = SmartInsight(
                    icon: "arrow.up.circle.fill",
                    color: "green",
                    title: "\(exercise.name) Earning a Bigger Bump",
                    message: "Last 3 \(exercise.name.lowercased()) sessions felt too easy with clean form. Next session can step load up more assertively.",
                    severity: .positive,
                    category: .progression
                )
                let rec = Recommendation(
                    type: .progressionSuggestion,
                    title: "Step Up \(exercise.name) Load",
                    message: "Repeated too-easy clean work earns a stronger progression — move load up instead of just adding reps.",
                    priority: 3
                )
                signals.append(ToleranceSignal(
                    kind: .accelerateTooEasy(exerciseId: exercise.id),
                    confidence: .high,
                    insight: insight,
                    recommendation: rec
                ))
            }
        }

        // Alternative-outperforms-stalled-anchor pattern.
        if baseConfidence >= .moderate, let s = alternativeOutperformsSignal(context: context, progressionStates: progressionStates) {
            signals.append(s)
        }

        return signals
    }

    // MARK: - Helpers

    private struct QualitySummary {
        var painSessions: Int = 0
        var formSessions: Int = 0
        var grindSessions: Int = 0
        var tooEasySessions: Int = 0
        var onTargetSessions: Int = 0
    }

    private func quality(for logs: [ExerciseLog]) -> QualitySummary {
        var q = QualitySummary()
        for log in logs {
            let qualities = Set(log.sets.compactMap { $0.isCompleted ? $0.quality : nil })
            if qualities.contains(.pain) { q.painSessions += 1 }
            if qualities.contains(.formBreakdown) { q.formSessions += 1 }
            if qualities.contains(.grinder) { q.grindSessions += 1 }
            if qualities.contains(.tooEasy) { q.tooEasySessions += 1 }
            if qualities.contains(.onTarget) { q.onTargetSessions += 1 }
        }
        return q
    }

    // Last (up to) 3 completed logs per exercise, most recent first.
    // Only exercises with ≥2 recent sessions are kept — otherwise "repeated"
    // has no meaning.
    private func buildRecentLogs(workoutHistory: [WorkoutSession]) -> [String: [ExerciseLog]] {
        var bucket: [String: [ExerciseLog]] = [:]
        let completed = workoutHistory.filter(\.isCompleted).sorted { $0.startTime > $1.startTime }
        for session in completed {
            for log in session.exerciseLogs where log.isCompleted {
                var arr = bucket[log.exerciseId, default: []]
                if arr.count < 3 {
                    arr.append(log)
                    bucket[log.exerciseId] = arr
                }
            }
        }
        return bucket.filter { $0.value.count >= 2 }
    }

    private func saferAlternative(for exercise: Exercise, context: ExerciseSelectionContext) -> Exercise? {
        let ranked = selection.rankedSubstitutes(
            for: exercise.id,
            context: context,
            reason: .injuryAvoidance,
            limit: 4
        )
        return ranked.first(where: { $0.exercise.id != exercise.id && $0.exercise.isJointFriendly })?.exercise
    }

    private func alternativeOutperformsSignal(
        context: ExerciseSelectionContext,
        progressionStates: [ExerciseProgressionState]
    ) -> ToleranceSignal? {
        let stalled = progressionStates.filter {
            ($0.plateauStatus == .plateaued || $0.plateauStatus == .regressing) && $0.sessionCount >= 3
        }
        for stall in stalled {
            guard let result = selection.anchorSwapSuggestion(currentAnchorId: stall.exerciseId, context: context) else { continue }
            let confidence: ToleranceConfidence = {
                switch result.confidence {
                case .low: return .low
                case .moderate: return .moderate
                case .high: return .high
                }
            }()
            guard confidence != .low else { continue }

            let insight = SmartInsight(
                icon: "arrow.triangle.swap",
                color: "blue",
                title: "\(result.alternative.name) Outperforming \(result.current.name)",
                message: "\(result.alternative.name) keeps progressing with clean work while \(result.current.name) has stalled. Promote \(result.alternative.name) to the main \(result.current.primaryMuscle.displayName.lowercased()) lift.",
                severity: .medium,
                category: .progression
            )
            let rec = Recommendation(
                type: .exerciseSwap,
                title: "Promote \(result.alternative.name)",
                message: "Sustained clean progress on \(result.alternative.name) is a stronger signal than forcing \(result.current.name). Lead with it next block.",
                priority: 3
            )
            return ToleranceSignal(
                kind: .promoteAlternative(stalledId: result.current.id, alternativeId: result.alternative.id),
                confidence: confidence,
                insight: insight,
                recommendation: rec
            )
        }
        return nil
    }
}
