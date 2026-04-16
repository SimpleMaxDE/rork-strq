import Foundation

nonisolated enum ProgressionDecision: String, Codable, Sendable {
    case baseline
    case increaseLoad
    case increaseReps
    case hold
    case reduceLoad
    case reduceSets
    case holdRecovery
    case rebuild

    var label: String {
        switch self {
        case .baseline: "Start Smart"
        case .increaseLoad: "Increase Load"
        case .increaseReps: "Add Reps"
        case .hold: "Hold & Rebuild"
        case .reduceLoad: "Reduce Load"
        case .reduceSets: "Drop a Set"
        case .holdRecovery: "Hold — Low Readiness"
        case .rebuild: "Rebuild"
        }
    }

    var icon: String {
        switch self {
        case .baseline: "sparkles"
        case .increaseLoad: "arrow.up.circle.fill"
        case .increaseReps: "plus.circle.fill"
        case .hold: "equal.circle.fill"
        case .reduceLoad: "arrow.down.circle.fill"
        case .reduceSets: "minus.circle.fill"
        case .holdRecovery: "heart.circle.fill"
        case .rebuild: "arrow.counterclockwise.circle.fill"
        }
    }

    var colorName: String {
        switch self {
        case .increaseLoad, .increaseReps: "green"
        case .hold, .baseline: "steel"
        case .reduceLoad, .reduceSets, .rebuild: "red"
        case .holdRecovery: "yellow"
        }
    }
}

nonisolated struct TodayPrescription: Sendable {
    let exerciseId: String
    let suggestedWeight: Double
    let plannedSets: Int
    let suggestedSets: Int
    let suggestedRepRange: String
    let targetRPE: Double?
    let decision: ProgressionDecision
    let reasoning: String
    let rule: String
    let readinessNote: String?
    let weightDelta: Double
    let lastWeight: Double
    let lastRepsSummary: String?

    var weightChanged: Bool { abs(weightDelta) >= 0.01 }
    var setsReduced: Bool { suggestedSets < plannedSets }

    var formattedWeight: String {
        if suggestedWeight <= 0 { return "BW" }
        if suggestedWeight.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(suggestedWeight)) kg"
        }
        return String(format: "%.1f kg", suggestedWeight)
    }

    var formattedDelta: String? {
        guard weightChanged else { return nil }
        let sign = weightDelta > 0 ? "+" : ""
        if weightDelta.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(sign)\(Int(weightDelta)) kg"
        }
        return "\(sign)\(String(format: "%.1f", weightDelta)) kg"
    }
}

struct AdaptivePrescriptionEngine {
    private let library = ExerciseLibrary.shared
    private let progressionEngine = ProgressionEngine()

    func prescribe(
        planned: PlannedExercise,
        exercise: Exercise?,
        sessions: [WorkoutSession],
        effectiveRecoveryScore: Int,
        phase: TrainingPhase,
        fallbackSuggestedWeight: Double?
    ) -> TodayPrescription {
        let ex = exercise
        let (lower, upper) = parseRepRange(planned.reps)
        let family = ex.map { progressionEngine.classifyExerciseFamily($0) } ?? .isolationLift
        let increment = loadIncrement(family: family, exercise: ex)
        let logs = recentLogs(for: planned.exerciseId, sessions: sessions)

        guard let last = logs.first, let lastCompletedSets = completedSets(last), !lastCompletedSets.isEmpty else {
            return baseline(planned: planned, lower: lower, upper: upper, fallback: fallbackSuggestedWeight, recovery: effectiveRecoveryScore)
        }

        let lastWeight = modeWeight(lastCompletedSets)
        let minReps = lastCompletedSets.map(\.reps).min() ?? 0
        let maxReps = lastCompletedSets.map(\.reps).max() ?? 0
        let completedCount = lastCompletedSets.count
        let stalls = countStalls(logs: logs, lowerBound: lower)

        var decision: ProgressionDecision
        var nextWeight: Double
        var nextRange = "\(lower)-\(upper)"

        if stalls >= 3 && lastWeight > 0 {
            decision = .rebuild
            nextWeight = roundTo(lastWeight * 0.9, increment: increment)
        } else if minReps >= upper && completedCount >= planned.sets {
            decision = .increaseLoad
            nextWeight = lastWeight + increment
            nextRange = "\(max(lower - 1, max(1, upper - 3)))-\(upper)"
        } else if minReps < lower && stalls >= 2 {
            decision = .reduceLoad
            nextWeight = max(0, lastWeight - increment)
        } else if minReps < lower {
            decision = .hold
            nextWeight = lastWeight
        } else {
            decision = .increaseReps
            nextWeight = lastWeight
        }

        var suggestedSets = planned.sets
        var readinessNote: String? = nil

        if effectiveRecoveryScore < 50 {
            if decision == .increaseLoad || decision == .increaseReps {
                decision = .holdRecovery
                nextWeight = lastWeight
            }
            if planned.sets >= 3 {
                suggestedSets = planned.sets - 1
            }
            readinessNote = "Readiness \(effectiveRecoveryScore)% — holding load and dropping a set to protect recovery."
        } else if effectiveRecoveryScore < 65 && decision == .increaseLoad {
            decision = .holdRecovery
            nextWeight = lastWeight
            readinessNote = "Readiness \(effectiveRecoveryScore)% — holding last session's load instead of pushing."
        } else if phase == .deload {
            if decision == .increaseLoad || decision == .increaseReps {
                decision = .hold
                nextWeight = lastWeight
            }
            suggestedSets = max(2, planned.sets - 1)
            readinessNote = "Deload week — reduced volume and held load."
        } else if phase == .fatigueManagement && decision == .increaseLoad {
            decision = .hold
            nextWeight = lastWeight
            readinessNote = "Fatigue management phase — consolidating instead of pushing."
        }

        let weightDelta = nextWeight - lastWeight
        let lastSummary = "Last: \(formatKg(lastWeight)) × \(minReps)\(minReps == maxReps ? "" : "–\(maxReps)")"

        return TodayPrescription(
            exerciseId: planned.exerciseId,
            suggestedWeight: nextWeight,
            plannedSets: planned.sets,
            suggestedSets: suggestedSets,
            suggestedRepRange: nextRange,
            targetRPE: planned.rpe,
            decision: decision,
            reasoning: buildReasoning(
                decision: decision,
                lastWeight: lastWeight,
                nextWeight: nextWeight,
                lower: lower,
                upper: upper,
                minReps: minReps,
                maxReps: maxReps,
                stalls: stalls,
                increment: increment
            ),
            rule: buildRule(decision: decision, lower: lower, upper: upper, increment: increment),
            readinessNote: readinessNote,
            weightDelta: weightDelta,
            lastWeight: lastWeight,
            lastRepsSummary: lastSummary
        )
    }

    // MARK: - Baseline

    private func baseline(planned: PlannedExercise, lower: Int, upper: Int, fallback: Double?, recovery: Int) -> TodayPrescription {
        let weight = fallback ?? 0
        var suggestedSets = planned.sets
        var decision: ProgressionDecision = .baseline
        var readinessNote: String? = nil

        if recovery < 50 && planned.sets >= 3 {
            suggestedSets = planned.sets - 1
            decision = .holdRecovery
            readinessNote = "Readiness \(recovery)% — starting one set lighter."
        }

        return TodayPrescription(
            exerciseId: planned.exerciseId,
            suggestedWeight: weight,
            plannedSets: planned.sets,
            suggestedSets: suggestedSets,
            suggestedRepRange: "\(lower)-\(upper)",
            targetRPE: planned.rpe,
            decision: decision,
            reasoning: weight > 0
                ? "No history yet. Start at \(formatKg(weight)) and leave 2 reps in reserve — next session adapts to how this goes."
                : "No history yet. Start conservative and leave 2 reps in reserve.",
            rule: "Hit \(upper) reps on every set to unlock a load increase next session.",
            readinessNote: readinessNote,
            weightDelta: 0,
            lastWeight: 0,
            lastRepsSummary: nil
        )
    }

    // MARK: - Helpers

    private func parseRepRange(_ s: String) -> (Int, Int) {
        let cleaned = s.replacingOccurrences(of: " ", with: "")
        let parts = cleaned.split(separator: "-").compactMap { Int($0) }
        if parts.count >= 2 { return (min(parts[0], parts[1]), max(parts[0], parts[1])) }
        if parts.count == 1 { return (parts[0], parts[0]) }
        return (8, 12)
    }

    private func loadIncrement(family: ExerciseFamily, exercise: Exercise?) -> Double {
        if family.loadIncrementKg > 0 { return family.loadIncrementKg }
        guard let ex = exercise else { return 2.5 }
        if ex.equipment.contains(.barbell) { return 2.5 }
        if ex.equipment.contains(.dumbbell) { return 2.0 }
        if ex.equipment.contains(.cable) || ex.equipment.contains(.machine) { return 2.5 }
        if ex.equipment.contains(.kettlebell) { return 4.0 }
        return 2.5
    }

    private func recentLogs(for exerciseId: String, sessions: [WorkoutSession]) -> [ExerciseLog] {
        sessions
            .filter(\.isCompleted)
            .sorted { $0.startTime > $1.startTime }
            .compactMap { session in
                session.exerciseLogs.first { $0.exerciseId == exerciseId && $0.isCompleted }
            }
    }

    private func completedSets(_ log: ExerciseLog) -> [SetLog]? {
        let sets = log.sets.filter(\.isCompleted)
        return sets.isEmpty ? nil : sets
    }

    private func modeWeight(_ sets: [SetLog]) -> Double {
        let weights = sets.map(\.weight).filter { $0 > 0 }
        guard !weights.isEmpty else { return 0 }
        var counts: [Double: Int] = [:]
        for w in weights { counts[w, default: 0] += 1 }
        return counts.max(by: { $0.value < $1.value })?.key ?? weights.first ?? 0
    }

    private func countStalls(logs: [ExerciseLog], lowerBound: Int) -> Int {
        let recent = logs.prefix(5).compactMap { log -> (weight: Double, minReps: Int)? in
            guard let sets = completedSets(log) else { return nil }
            let w = modeWeight(sets)
            let r = sets.map(\.reps).min() ?? 0
            return (w, r)
        }
        guard recent.count >= 2 else { return 0 }
        let first = recent[0]
        var count = 0
        for entry in recent.dropFirst() {
            let weightClose = abs(entry.weight - first.weight) < 0.1
            let notImproving = entry.minReps >= first.minReps - 1 && first.minReps < lowerBound + 2
            if weightClose && notImproving {
                count += 1
            } else {
                break
            }
        }
        return count
    }

    private func roundTo(_ value: Double, increment: Double) -> Double {
        guard increment > 0 else { return value }
        return (value / increment).rounded() * increment
    }

    private func formatKg(_ w: Double) -> String {
        if w <= 0 { return "BW" }
        if w.truncatingRemainder(dividingBy: 1) == 0 { return "\(Int(w)) kg" }
        return String(format: "%.1f kg", w)
    }

    private func buildReasoning(
        decision: ProgressionDecision,
        lastWeight: Double,
        nextWeight: Double,
        lower: Int,
        upper: Int,
        minReps: Int,
        maxReps: Int,
        stalls: Int,
        increment: Double
    ) -> String {
        switch decision {
        case .increaseLoad:
            return "Every set hit \(upper) reps last session. Add \(formatKg(increment).replacingOccurrences(of: " kg", with: "")) kg to \(formatKg(nextWeight))."
        case .increaseReps:
            return "Last session landed in range at \(minReps)\(minReps == maxReps ? "" : "–\(maxReps)") reps. Hold \(formatKg(lastWeight)) and aim for \(upper) across all sets."
        case .hold:
            return "Last session fell below the \(lower)-rep floor. Repeat \(formatKg(lastWeight)) and rebuild reps first."
        case .reduceLoad:
            return "Stalled for \(stalls) sessions at \(formatKg(lastWeight)). Drop to \(formatKg(nextWeight)) and rebuild."
        case .holdRecovery:
            return "Performance allowed progression, but readiness is low. Holding \(formatKg(lastWeight)) today."
        case .rebuild:
            return "Three sessions without progress. Reset to \(formatKg(nextWeight)) and rebuild cleanly."
        case .reduceSets:
            return "Reducing volume today to match recovery."
        case .baseline:
            return "No history yet. Start conservative."
        }
    }

    private func buildRule(decision: ProgressionDecision, lower: Int, upper: Int, increment: Double) -> String {
        let incText = increment.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(increment))" : String(format: "%.1f", increment)
        switch decision {
        case .increaseLoad, .baseline:
            return "If every set reaches \(upper) reps, increase by \(incText) kg next session."
        case .increaseReps:
            return "Once every set hits \(upper) reps, increase weight by \(incText) kg."
        case .hold:
            return "Rebuild to at least \(lower) reps before progressing."
        case .reduceLoad, .rebuild:
            return "Build back to \(upper) reps cleanly, then increase by \(incText) kg."
        case .holdRecovery:
            return "Resume progression when readiness returns above 65%."
        case .reduceSets:
            return "Return to full volume once readiness recovers."
        }
    }
}
