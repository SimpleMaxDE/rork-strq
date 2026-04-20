import Foundation

// Phase 13 — Trust / Explainability / Change Log.
//
// CoachingMemoryService is a pure, read-only interpretive layer that turns
// the app's existing state (coach adjustments, phase history, plan-evolution
// signals, physique/tolerance verdicts) into a single, ordered, human-readable
// timeline of coaching changes — STRQ's coaching memory.
//
// It owns no state of its own. Views read it through AppViewModel.

nonisolated enum CoachMemoryKind: Sendable {
    case adjustment(CoachAdjustmentType)
    case phaseShift(from: TrainingPhase, to: TrainingPhase)
    case planEvolution
    case physiqueShift
}

nonisolated enum CoachMemoryScope: String, Sendable {
    case session
    case week
    case block

    var label: String {
        switch self {
        case .session: "Session"
        case .week:    "Week"
        case .block:   "Block"
        }
    }
}

nonisolated struct CoachMemoryEntry: Identifiable, Sendable {
    let id: String
    let appliedAt: Date
    let kind: CoachMemoryKind
    let scope: CoachMemoryScope
    let icon: String
    let state: STRQPalette.State
    let title: String           // what changed
    let driver: String          // why it changed
    let expectation: String?    // what it means now
    let status: String?         // current-status line (e.g. "Active this week")
    let details: [String]       // compact secondary lines
}

struct CoachingMemoryService {
    func buildTimeline(
        adjustments: [CoachAdjustment],
        phaseState: TrainingPhaseState,
        planEvolutionSignals: [PlanEvolutionSignal],
        outlook: PhaseOutlook?,
        physique: PhysiqueOutcome?,
        activeWeekAdjustment: CoachAdjustmentType?,
        nutritionTrackingEnabled: Bool,
        limit: Int = 12
    ) -> [CoachMemoryEntry] {
        var entries: [CoachMemoryEntry] = []

        // 1. Coach adjustments (session / week / block)
        for adj in adjustments {
            entries.append(entry(from: adj, activeWeekAdjustment: activeWeekAdjustment, outlook: outlook))
        }

        // 2. Phase transitions (skip the initial .build seed)
        let transitions = phaseState.phaseHistory
            .filter { $0.endDate != nil || $0.phase != phaseState.currentPhase }
        for (idx, entry0) in transitions.enumerated() {
            let prev: TrainingPhase = {
                if idx == 0 { return .build }
                return transitions[idx - 1].phase
            }()
            entries.append(phaseEntry(from: prev, to: entry0.phase, at: entry0.startDate, reason: entry0.reason))
        }

        // 3. High-confidence plan-evolution signals not yet represented as a
        //    concrete adjustment — these are the "coach is thinking about…" items.
        let existingSignalTitles = Set(adjustments.map(\.description))
        for signal in planEvolutionSignals where signal.confidence == .high {
            let title = signal.insight.title
            if existingSignalTitles.contains(where: { $0.contains(title) }) { continue }
            entries.append(planEvolutionEntry(signal: signal))
        }

        // 4. Physique shifts — only when user has opted in and verdict is decisive.
        if nutritionTrackingEnabled, let physique, let verdict = physiqueVerdictEntry(outcome: physique) {
            entries.append(verdict)
        }

        // Order: newest first.
        let sorted = entries.sorted { $0.appliedAt > $1.appliedAt }
        return Array(sorted.prefix(limit))
    }

    // MARK: - Builders

    private func entry(
        from adj: CoachAdjustment,
        activeWeekAdjustment: CoachAdjustmentType?,
        outlook: PhaseOutlook?
    ) -> CoachMemoryEntry {
        let scope: CoachMemoryScope = {
            if let s = adj.scope {
                switch s {
                case .session: return .session
                case .week:    return .week
                case .block:   return .block
                }
            }
            if adj.dayId == "week-all" { return adj.type == .deloadWeek ? .block : .week }
            return .session
        }()

        let state: STRQPalette.State = {
            switch adj.type {
            case .volumeReduced, .lighterSession: return .warning
            case .exerciseSwapped:                return .info
            case .weekRegenerated:                return .info
            case .deloadWeek:                     return .warning
            }
        }()

        let icon: String = {
            switch adj.type {
            case .volumeReduced:   return "minus.circle"
            case .exerciseSwapped: return "arrow.triangle.swap"
            case .lighterSession:  return "arrow.down.circle"
            case .weekRegenerated: return "arrow.triangle.2.circlepath.circle"
            case .deloadWeek:      return "arrow.down.to.line"
            }
        }()

        let status: String? = {
            if scope == .week || scope == .block {
                if activeWeekAdjustment == adj.type {
                    return "Active this week"
                }
                return "Applied"
            }
            return "Staged for next session"
        }()

        let driver = adj.driver ?? defaultDriver(for: adj.type)
        let expectation = adj.expectation ?? defaultExpectation(for: adj.type)
        let details = adj.details.prefix(3).map { "\($0.exerciseName): \($0.change)" }

        return CoachMemoryEntry(
            id: "adj-\(adj.id)",
            appliedAt: adj.appliedAt,
            kind: .adjustment(adj.type),
            scope: scope,
            icon: icon,
            state: state,
            title: adj.description,
            driver: driver,
            expectation: expectation,
            status: status,
            details: Array(details)
        )
    }

    private func phaseEntry(from prev: TrainingPhase, to next: TrainingPhase, at date: Date, reason: String) -> CoachMemoryEntry {
        let state: STRQPalette.State = {
            switch next {
            case .push:              return .info
            case .build:             return .info
            case .deload:            return .warning
            case .fatigueManagement: return .warning
            case .rebalance:         return .info
            }
        }()
        let driver = reason.isEmpty ? "Earned by your recent training signal." : reason
        return CoachMemoryEntry(
            id: "phase-\(date.timeIntervalSince1970)",
            appliedAt: date,
            kind: .phaseShift(from: prev, to: next),
            scope: .block,
            icon: next.icon,
            state: state,
            title: "\(prev.shortLabel) → \(next.shortLabel)",
            driver: driver,
            expectation: "Expect training to feel \(next.expectedIntensityLabel.lowercased()) while the block runs.",
            status: "Block entered",
            details: []
        )
    }

    private func planEvolutionEntry(signal: PlanEvolutionSignal) -> CoachMemoryEntry {
        let state: STRQPalette.State = {
            switch signal.insight.severity {
            case .high:     return .danger
            case .medium:   return .warning
            case .low:      return .info
            case .positive: return .success
            }
        }()
        return CoachMemoryEntry(
            id: "evo-\(signal.insight.id)",
            appliedAt: Date(),
            kind: .planEvolution,
            scope: .week,
            icon: signal.insight.icon,
            state: state,
            title: signal.insight.title,
            driver: signal.insight.message,
            expectation: signal.recommendation?.message,
            status: "Pending adjustment",
            details: []
        )
    }

    private func physiqueVerdictEntry(outcome: PhysiqueOutcome) -> CoachMemoryEntry? {
        guard let priority = outcome.priority else { return nil }
        let state: STRQPalette.State = {
            switch outcome.paceVerdict {
            case .onTrack, .aligned: return .success
            case .tooSlow:           return .warning
            case .tooFast:           return .warning
            case .drifting:          return .danger
            case .noSignal:          return .neutral
            }
        }()
        let confidenceLabel: String = {
            switch outcome.confidence {
            case .calibrating: return "Calibrating"
            case .directional: return "Directional"
            case .confident:   return "Confident"
            }
        }()
        return CoachMemoryEntry(
            id: "phys-\(priority.headline)",
            appliedAt: Date(),
            kind: .physiqueShift,
            scope: .week,
            icon: priority.icon,
            state: state,
            title: priority.headline,
            driver: outcome.summary ?? priority.detail,
            expectation: outcome.trainingBridge,
            status: confidenceLabel,
            details: []
        )
    }

    // MARK: - Defaults for legacy adjustments without driver/expectation

    private func defaultDriver(for type: CoachAdjustmentType) -> String {
        switch type {
        case .volumeReduced:   return "Recent recovery signal called for less accessory work."
        case .exerciseSwapped: return "The previous movement was not progressing on its own."
        case .lighterSession:  return "One deliberately easier session was the right protection."
        case .weekRegenerated: return "Coach rebalanced the week around your latest signal."
        case .deloadWeek:      return "Multi-week fatigue trend earned a structured back-off."
        }
    }

    private func defaultExpectation(for type: CoachAdjustmentType) -> String {
        switch type {
        case .volumeReduced:   return "Session should feel slightly easier with the same compound work intact."
        case .exerciseSwapped: return "Start lighter on the new movement, then rebuild load."
        case .lighterSession:  return "Leave reps in reserve everywhere — save the push for the next one."
        case .weekRegenerated: return "Expect cleaner volume distribution across your days."
        case .deloadWeek:      return "Training should feel clearly lighter this week."
        }
    }
}
