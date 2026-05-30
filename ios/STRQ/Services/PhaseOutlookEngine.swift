import Foundation

// Long-term adaptation / mesocycle clarity.
//
// PhaseOutlookEngine interprets the current TrainingPhaseState plus recent
// signals (recovery, progression, muscle balance, plan evolution) to produce
// a single, readable outlook:
//   - what phase we're in and what it's optimizing for
//   - how far into its typical block we are
//   - the most likely next shift, with a short, earned reason
//   - a compact, coach-voice "this week's intent" line
//
// This is a read-only interpretive layer — it never mutates phase state.
// It sits next to PlanEvolutionEngine rather than replacing it.

nonisolated enum PhaseShiftDirection: Sendable {
    case hold
    case advance      // progress forward (e.g. build -> push)
    case consolidate  // deload / fatigue management
    case rebalance    // address imbalance
}

nonisolated enum PhaseShiftLikelihood: Sendable {
    case settled      // just started, stay the course
    case building     // mid-block, evidence forming
    case likelySoon   // near typical length + supporting signal
    case overdue      // past typical length or strong signal to shift
}

nonisolated struct PhaseOutlook: Sendable {
    let currentPhase: TrainingPhase
    let weekInBlock: Int          // 1-based
    let typicalWeeks: Int         // from phase.typicalWeeks
    let progressFraction: Double  // 0...1, clamped
    let blockIntent: String       // "This block is building progressive overload on your anchor lifts."
    let weekIntent: String        // "This week: push top sets, protect rest between."
    let nextPhase: TrainingPhase
    let nextShiftDirection: PhaseShiftDirection
    let nextShiftLikelihood: PhaseShiftLikelihood
    let nextShiftReason: String   // earned, data-driven, never vague
    let driverLine: String?       // optional "Why": e.g. "Recovery steady, 3 lifts progressing."
}

struct PhaseOutlookEngine {
    func analyze(
        phaseState: TrainingPhaseState,
        progressionStates: [ExerciseProgressionState],
        recoveryTrend: [Int],
        recoveryScore: Int,
        workoutHistory: [WorkoutSession],
        muscleBalance: [MuscleBalanceEntry],
        planEvolutionSignals: [PlanEvolutionSignal],
        profile: UserProfile
    ) -> PhaseOutlook {
        let phase = phaseState.currentPhase
        let week = max(1, phaseState.weeksInPhase)
        let typical = max(1, phase.typicalWeeks)
        let fraction = min(1.0, Double(week) / Double(typical))

        let progressing = progressionStates.filter { $0.plateauStatus == .progressing }.count
        let stalled = progressionStates.filter { $0.plateauStatus == .plateaued || $0.plateauStatus == .regressing }.count
        let total = max(1, progressionStates.count)
        let progressingRatio = Double(progressing) / Double(total)

        let recentRecoveryAvg: Double = {
            guard !recoveryTrend.isEmpty else { return Double(recoveryScore) }
            let slice = recoveryTrend.suffix(7)
            return Double(slice.reduce(0, +)) / Double(slice.count)
        }()

        // Next phase + direction + likelihood.
        let (nextPhase, direction, likelihood, reason) = resolveNextShift(
            phase: phase,
            week: week,
            typical: typical,
            progressingRatio: progressingRatio,
            stalledCount: stalled,
            recentRecoveryAvg: recentRecoveryAvg,
            recoveryScore: recoveryScore,
            muscleBalance: muscleBalance,
            planEvolutionSignals: planEvolutionSignals
        )

        let blockIntent = buildBlockIntent(phase: phase, profile: profile)
        let weekIntent = buildWeekIntent(phase: phase, week: week, typical: typical, recoveryScore: recoveryScore)
        let driverLine = buildDriverLine(
            progressing: progressing,
            stalled: stalled,
            recentRecoveryAvg: recentRecoveryAvg,
            planEvolutionSignals: planEvolutionSignals
        )

        return PhaseOutlook(
            currentPhase: phase,
            weekInBlock: week,
            typicalWeeks: typical,
            progressFraction: fraction,
            blockIntent: blockIntent,
            weekIntent: weekIntent,
            nextPhase: nextPhase,
            nextShiftDirection: direction,
            nextShiftLikelihood: likelihood,
            nextShiftReason: reason,
            driverLine: driverLine
        )
    }

    private func muscleDisplayName(_ raw: String) -> String {
        switch raw.lowercased() {
        case "back": return "Back"
        case "chest": return "Chest"
        case "shoulders": return "Shoulders"
        case "arms": return "Arms"
        case "quads": return "Quads"
        case "hamstrings": return "Hamstrings"
        case "glutes": return "Glutes"
        case "calves": return "Calves"
        default: return raw
        }
    }

    // MARK: - Shift resolution

    private func resolveNextShift(
        phase: TrainingPhase,
        week: Int,
        typical: Int,
        progressingRatio: Double,
        stalledCount: Int,
        recentRecoveryAvg: Double,
        recoveryScore: Int,
        muscleBalance: [MuscleBalanceEntry],
        planEvolutionSignals: [PlanEvolutionSignal]
    ) -> (TrainingPhase, PhaseShiftDirection, PhaseShiftLikelihood, String) {
        // Evolution-engine opinions override heuristics when confident.
        for signal in planEvolutionSignals where signal.confidence == .high {
            switch signal.kind {
            case .triggerDeload:
                return (.deload, .consolidate, .overdue, "Recent weeks were dense. Check deload.")
            case .maintainPush:
                return (phase.typicalNextPhase, .hold, .settled, "Plan looks stable. Keep the structure.")
            case .rebalanceMuscle(let muscle):
                return (.rebalance, .rebalance, .likelySoon, "\(muscleDisplayName(muscle)) is below average. Check rebalance.")
            default: break
            }
        }

        // Critical recovery always dominates.
        if recoveryScore < 45 && phase != .deload {
            return (.deload, .consolidate, .overdue, "Recovery is low. Check deload for the next block.")
        }

        switch phase {
        case .build:
            if week >= typical && recentRecoveryAvg >= 65 && progressingRatio >= 0.4 {
                return (.push, .advance, .likelySoon, "Rhythm is in place and lifts are moving. Check push phase.")
            }
            if week < typical {
                return (.push, .advance, week >= max(1, typical - 1) ? .building : .settled,
                        "Keep building rhythm. Push phase gets more relevant around week \(typical).")
            }
            return (.push, .advance, .overdue, "Build window is complete. Check push.")

        case .push:
            if week >= typical || recentRecoveryAvg < 60 {
                return (.fatigueManagement, .consolidate, .overdue, "Push block is full. Check a lighter week.")
            }
            if stalledCount >= 2 && week >= max(2, typical - 1) {
                return (.fatigueManagement, .consolidate, .likelySoon, "\(stalledCount) lifts are stuck. Check a lighter week.")
            }
            if week >= max(2, typical - 1) {
                return (.fatigueManagement, .consolidate, .building, "Late in the push phase. Plan lighter soon.")
            }
            return (.fatigueManagement, .consolidate, .settled, "Keep pushing. Check back-off around week \(typical).")

        case .fatigueManagement:
            if week >= typical && recentRecoveryAvg >= 70 {
                return (.push, .advance, .likelySoon, "Recovery is stabilizing. The next block can push again.")
            }
            if week >= typical && recentRecoveryAvg < 65 {
                return (.deload, .consolidate, .likelySoon, "Recovery stays low. Check a structured deload.")
            }
            return (.push, .advance, .building, "This week is lighter. Check push for the next block.")

        case .deload:
            let undertrained = muscleBalance.filter { $0.percentOfAverage < 0.75 }.count
            if undertrained >= 2 {
                return (.rebalance, .rebalance, .likelySoon, "After deload, check \(undertrained) volume gaps.")
            }
            return (.build, .advance, .likelySoon, "Deload is done. Build rhythm before the next push.")

        case .rebalance:
            if week >= typical {
                return (.build, .advance, .likelySoon, "Rebalance window is done. Back to build.")
            }
            return (.build, .advance, .building, "Close weak spots before the next build starts.")
        }
    }

    // MARK: - Copy builders

    private func buildBlockIntent(phase: TrainingPhase, profile: UserProfile) -> String {
        switch phase {
        case .build:
            return "This block builds training rhythm before the next push."
        case .push:
            return "This block checks small jumps on the main lifts."
        case .fatigueManagement:
            return "This block keeps fitness while lowering intensity."
        case .deload:
            return "This block takes pressure down so the next push starts clean."
        case .rebalance:
            return "This block moves volume toward areas that have had less work."
        }
    }

    private func buildWeekIntent(phase: TrainingPhase, week: Int, typical: Int, recoveryScore: Int) -> String {
        let progressTag = week >= typical ? "late" : (week == 1 ? "first" : "mid")
        switch phase {
        case .build:
            if progressTag == "first" { return "Anchor the week. Hit planned sessions, no forced PRs." }
            if progressTag == "late"  { return "Hold capacity. Clean sets, honest RPE, no grind." }
            return "Add a rep or set only when it is earned. Technique first."
        case .push:
            if progressTag == "first" { return "Open the push. Small load jumps, real rest between sets." }
            if progressTag == "late"  { return "Protect top sets. Quality before more reps." }
            return "Hard top sets, controlled back-off sets."
        case .fatigueManagement:
            return recoveryScore < 60 ? "Drop RPE by 1. Sessions should feel lighter than last block." : "Cap effort around RPE 7. Recover into the next push."
        case .deload:
            return "Lighter loads, shorter sessions, reps in reserve everywhere."
        case .rebalance:
            return "Start sessions with the lagging area. Do not overdo what already works."
        }
    }

    private func buildDriverLine(
        progressing: Int,
        stalled: Int,
        recentRecoveryAvg: Double,
        planEvolutionSignals: [PlanEvolutionSignal]
    ) -> String? {
        var parts: [String] = []
        if progressing >= 2 { parts.append("\(progressing) lifts rising") }
        if stalled >= 2 { parts.append("\(stalled) stalled") }
        if recentRecoveryAvg >= 75 { parts.append("recovery stable") }
        else if recentRecoveryAvg < 60 { parts.append("recovery dipping") }
        if !planEvolutionSignals.isEmpty {
            let high = planEvolutionSignals.filter { $0.confidence == .high }.count
            if high > 0 { parts.append("\(high) plan signal\(high == 1 ? "" : "s")") }
        }
        guard !parts.isEmpty else { return nil }
        return parts.prefix(3).joined(separator: " · ").capitalizedFirst
    }
}

// MARK: - Shift display helpers

extension PhaseShiftDirection {
    var icon: String {
        switch self {
        case .hold: "equal.circle.fill"
        case .advance: "arrow.up.right.circle.fill"
        case .consolidate: "arrow.down.to.line"
        case .rebalance: "arrow.left.arrow.right.circle.fill"
        }
    }

    var paletteState: STRQPalette.State {
        switch self {
        case .hold: .success
        case .advance: .info
        case .consolidate: .warning
        case .rebalance: .info
        }
    }
}

extension PhaseShiftLikelihood {
    var label: String {
        switch self {
        case .settled: "Stable"
        case .building: "Building"
        case .likelySoon: "Soon"
        case .overdue: "Ready"
        }
    }
}

private extension String {
    var capitalizedFirst: String {
        guard let first = first else { return self }
        return first.uppercased() + dropFirst()
    }
}
