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
                return (.deload, .consolidate, .overdue, "Multi-week fatigue trend earned a deload.")
            case .maintainPush:
                return (phase.typicalNextPhase, .hold, .settled, "Plan is working — hold structure.")
            case .rebalanceMuscle(let muscle):
                return (.rebalance, .rebalance, .likelySoon, "\(muscle) has sat below its average — rebalance next.")
            default: break
            }
        }

        // Critical recovery always dominates.
        if recoveryScore < 45 && phase != .deload {
            return (.deload, .consolidate, .overdue, "Recovery is critically low — a deload protects the next block.")
        }

        switch phase {
        case .build:
            if week >= typical && recentRecoveryAvg >= 65 && progressingRatio >= 0.4 {
                return (.push, .advance, .likelySoon, "Work capacity is established and lifts are moving — push phase next.")
            }
            if week < typical {
                return (.push, .advance, week >= max(1, typical - 1) ? .building : .settled,
                        "Keep building rhythm — push phase unlocks around week \(typical).")
            }
            return (.push, .advance, .overdue, "Build window is complete — ready to push.")

        case .push:
            if week >= typical || recentRecoveryAvg < 60 {
                return (.fatigueManagement, .consolidate, .overdue, "Push window earned — fatigue management protects gains.")
            }
            if stalledCount >= 2 && week >= max(2, typical - 1) {
                return (.fatigueManagement, .consolidate, .likelySoon, "\(stalledCount) lifts stalling — a fatigue-management week is due.")
            }
            if week >= max(2, typical - 1) {
                return (.fatigueManagement, .consolidate, .building, "Late in the push — fatigue management likely next.")
            }
            return (.fatigueManagement, .consolidate, .settled, "Keep pushing — back-off earns itself around week \(typical).")

        case .fatigueManagement:
            if week >= typical && recentRecoveryAvg >= 70 {
                return (.push, .advance, .likelySoon, "Recovery rebounding — next block can push again.")
            }
            if week >= typical && recentRecoveryAvg < 65 {
                return (.deload, .consolidate, .likelySoon, "Recovery hasn't climbed — a structured deload is next.")
            }
            return (.push, .advance, .building, "Easing fatigue — aim to push again next block.")

        case .deload:
            let undertrained = muscleBalance.filter { $0.percentOfAverage < 0.75 }.count
            if undertrained >= 2 {
                return (.rebalance, .rebalance, .likelySoon, "Post-deload is the right window to close \(undertrained) volume gaps.")
            }
            return (.build, .advance, .likelySoon, "Deload complete — rebuild capacity before pushing again.")

        case .rebalance:
            if week >= typical {
                return (.build, .advance, .likelySoon, "Rebalance window done — back to building.")
            }
            return (.build, .advance, .building, "Closing weak-point gaps before the next build block.")
        }
    }

    // MARK: - Copy builders

    private func buildBlockIntent(phase: TrainingPhase, profile: UserProfile) -> String {
        switch phase {
        case .build:
            return "This block is rebuilding training rhythm and work capacity before the next push."
        case .push:
            return "This block is chasing progressive overload on your anchor lifts."
        case .fatigueManagement:
            return "This block protects recovery while holding fitness — intensity, not volume, takes the hit."
        case .deload:
            return "This block lowers stress so the next push lands on fresher tissue."
        case .rebalance:
            return "This block shifts volume toward lagging muscles to close weak-point gaps."
        }
    }

    private func buildWeekIntent(phase: TrainingPhase, week: Int, typical: Int, recoveryScore: Int) -> String {
        let progressTag = week >= typical ? "late" : (week == 1 ? "first" : "mid")
        switch phase {
        case .build:
            if progressTag == "first" { return "Anchor the week — hit planned sessions, don't chase PRs yet." }
            if progressTag == "late"  { return "Lock in capacity — clean sets, honest RPE, no grinding." }
            return "Add one rep or one set where it feels earned — form first."
        case .push:
            if progressTag == "first" { return "Open the push — small load bumps, protect rest between sets." }
            if progressTag == "late"  { return "Protect top sets — quality reps beat more reps this week." }
            return "Push top sets hard, back-off sets controlled."
        case .fatigueManagement:
            return recoveryScore < 60 ? "Back off RPE by 1 — sessions should feel easier than last block." : "Cap effort around RPE 7 — recover into next push."
        case .deload:
            return "Lighter weights, shorter sessions, leave reps in reserve everywhere."
        case .rebalance:
            return "Lead sessions with the lagging muscle — protect the work that's already moving."
        }
    }

    private func buildDriverLine(
        progressing: Int,
        stalled: Int,
        recentRecoveryAvg: Double,
        planEvolutionSignals: [PlanEvolutionSignal]
    ) -> String? {
        var parts: [String] = []
        if progressing >= 2 { parts.append("\(progressing) lifts progressing") }
        if stalled >= 2 { parts.append("\(stalled) stalling") }
        if recentRecoveryAvg >= 75 { parts.append("recovery steady") }
        else if recentRecoveryAvg < 60 { parts.append("recovery drifting") }
        if !planEvolutionSignals.isEmpty {
            let high = planEvolutionSignals.filter { $0.confidence == .high }.count
            if high > 0 { parts.append("\(high) plan-level signal\(high == 1 ? "" : "s")") }
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
        case .settled: "Settled"
        case .building: "Building"
        case .likelySoon: "Likely soon"
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
