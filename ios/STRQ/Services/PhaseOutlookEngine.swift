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
        case "back": return "Rücken"
        case "chest": return "Brust"
        case "shoulders": return "Schultern"
        case "arms": return "Arme"
        case "quads": return "Quads"
        case "hamstrings": return "Hamstrings"
        case "glutes": return "Glutes"
        case "calves": return "Waden"
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
                return (.deload, .consolidate, .overdue, "Die letzten Wochen waren dicht - Deload prüfen.")
            case .maintainPush:
                return (phase.typicalNextPhase, .hold, .settled, "Plan wirkt stabil - Struktur beibehalten.")
            case .rebalanceMuscle(let muscle):
                return (.rebalance, .rebalance, .likelySoon, "\(muscleDisplayName(muscle)) liegt unter dem Durchschnitt - Rebalance prüfen.")
            default: break
            }
        }

        // Critical recovery always dominates.
        if recoveryScore < 45 && phase != .deload {
            return (.deload, .consolidate, .overdue, "Erholung niedrig - Deload für den nächsten Block prüfen.")
        }

        switch phase {
        case .build:
            if week >= typical && recentRecoveryAvg >= 65 && progressingRatio >= 0.4 {
                return (.push, .advance, .likelySoon, "Rhythmus sitzt und Lifts bewegen sich - Push-Phase prüfen.")
            }
            if week < typical {
                return (.push, .advance, week >= max(1, typical - 1) ? .building : .settled,
                        "Rhythmus weiter aufbauen - Push-Phase wird um Woche \(typical) relevanter.")
            }
            return (.push, .advance, .overdue, "Aufbau-Fenster ist komplett - Push prüfen.")

        case .push:
            if week >= typical || recentRecoveryAvg < 60 {
                return (.fatigueManagement, .consolidate, .overdue, "Push-Block ist voll - leichtere Woche prüfen.")
            }
            if stalledCount >= 2 && week >= max(2, typical - 1) {
                return (.fatigueManagement, .consolidate, .likelySoon, "\(stalledCount) Lifts stocken - leichtere Woche prüfen.")
            }
            if week >= max(2, typical - 1) {
                return (.fatigueManagement, .consolidate, .building, "Spät in der Push-Phase - bald leichter planen.")
            }
            return (.fatigueManagement, .consolidate, .settled, "Push beibehalten - Back-off um Woche \(typical) prüfen.")

        case .fatigueManagement:
            if week >= typical && recentRecoveryAvg >= 70 {
                return (.push, .advance, .likelySoon, "Erholung stabilisiert sich - nächster Block kann wieder pushen.")
            }
            if week >= typical && recentRecoveryAvg < 65 {
                return (.deload, .consolidate, .likelySoon, "Erholung bleibt niedrig - strukturierten Deload prüfen.")
            }
            return (.push, .advance, .building, "Woche läuft leichter - Push im nächsten Block prüfen.")

        case .deload:
            let undertrained = muscleBalance.filter { $0.percentOfAverage < 0.75 }.count
            if undertrained >= 2 {
                return (.rebalance, .rebalance, .likelySoon, "Nach dem Deload \(undertrained)-Volumenlücke prüfen.")
            }
            return (.build, .advance, .likelySoon, "Deload abgeschlossen - Rhythmus vor dem nächsten Push aufbauen.")

        case .rebalance:
            if week >= typical {
                return (.build, .advance, .likelySoon, "Rebalance-Fenster abgeschlossen - zurück in den Aufbau.")
            }
            return (.build, .advance, .building, "Schwachstellen schließen, bevor der nächste Aufbau startet.")
        }
    }

    // MARK: - Copy builders

    private func buildBlockIntent(phase: TrainingPhase, profile: UserProfile) -> String {
        switch phase {
        case .build:
            return "Dieser Block baut Trainingsrhythmus vor dem nächsten Push auf."
        case .push:
            return "Dieser Block prüft progressive Steigerungen bei den Hauptlifts."
        case .fatigueManagement:
            return "Dieser Block hält Fitness und senkt vor allem die Intensität."
        case .deload:
            return "Dieser Block nimmt Druck raus, damit der nächste Push sauber startet."
        case .rebalance:
            return "Dieser Block verschiebt Volumen zu Bereichen, die zuletzt weniger abbekommen haben."
        }
    }

    private func buildWeekIntent(phase: TrainingPhase, week: Int, typical: Int, recoveryScore: Int) -> String {
        let progressTag = week >= typical ? "late" : (week == 1 ? "first" : "mid")
        switch phase {
        case .build:
            if progressTag == "first" { return "Woche verankern - geplante Einheiten treffen, keine PRs erzwingen." }
            if progressTag == "late"  { return "Kapazität sichern - saubere Sätze, ehrliche RPE, kein Grind." }
            return "Eine Wiederholung oder einen Satz ergänzen, wenn es verdient wirkt - Technik zuerst."
        case .push:
            if progressTag == "first" { return "Push öffnen - kleine Gewichtssprünge, Pausen zwischen Sätzen ernst nehmen." }
            if progressTag == "late"  { return "Top-Sätze schützen - Qualität vor mehr Wiederholungen." }
            return "Top-Sätze hart, Back-off-Sätze kontrolliert."
        case .fatigueManagement:
            return recoveryScore < 60 ? "RPE um 1 senken - Einheiten sollen leichter wirken als im letzten Block." : "Aufwand um RPE 7 deckeln - in den nächsten Push hinein erholen."
        case .deload:
            return "Leichtere Gewichte, kürzere Einheiten, überall Wiederholungen im Tank lassen."
        case .rebalance:
            return "Einheiten mit dem laggenden Bereich starten - was läuft, nicht unnötig überziehen."
        }
    }

    private func buildDriverLine(
        progressing: Int,
        stalled: Int,
        recentRecoveryAvg: Double,
        planEvolutionSignals: [PlanEvolutionSignal]
    ) -> String? {
        var parts: [String] = []
        if progressing >= 2 { parts.append("\(progressing) Lifts steigen") }
        if stalled >= 2 { parts.append("\(stalled) stocken") }
        if recentRecoveryAvg >= 75 { parts.append("Erholung stabil") }
        else if recentRecoveryAvg < 60 { parts.append("Erholung sinkt") }
        if !planEvolutionSignals.isEmpty {
            let high = planEvolutionSignals.filter { $0.confidence == .high }.count
            if high > 0 { parts.append("\(high) Plansignal\(high == 1 ? "" : "e")") }
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
        case .settled: "Stabil"
        case .building: "Baut auf"
        case .likelySoon: "Bald"
        case .overdue: "Bereit"
        }
    }
}

private extension String {
    var capitalizedFirst: String {
        guard let first = first else { return self }
        return first.uppercased() + dropFirst()
    }
}
