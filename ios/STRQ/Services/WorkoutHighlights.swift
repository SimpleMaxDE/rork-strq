import Foundation

nonisolated struct WorkoutHighlight: Identifiable, Sendable {
    enum Kind: Sendable {
        case personalRecord
        case bestSet
        case volumeUp
        case volumeDown
        case firstTime
        case consolidation
        case longestSession
        case streakMilestone
        case setsMilestone
    }

    let id: String
    let kind: Kind
    let title: String
    let subtitle: String?
    let valuePrimary: String
    let valueSecondary: String?
    let score: Double
    let isPrimary: Bool
    /// Short, specific line answering "what improved?"
    let improvedLine: String?

    init(
        id: String = UUID().uuidString,
        kind: Kind,
        title: String,
        subtitle: String? = nil,
        valuePrimary: String,
        valueSecondary: String? = nil,
        score: Double,
        isPrimary: Bool = false,
        improvedLine: String? = nil
    ) {
        self.id = id
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.valuePrimary = valuePrimary
        self.valueSecondary = valueSecondary
        self.score = score
        self.isPrimary = isPrimary
        self.improvedLine = improvedLine
    }
}

nonisolated struct SessionVerdict: Sendable {
    enum Kind: Sendable {
        case personalRecord
        case bestSet
        case volumeUp
        case volumeDown
        case firstSession
        case consolidated
    }
    let kind: Kind
    /// Short eyebrow headline, e.g. "NEW PERSONAL RECORD"
    let eyebrow: String
    /// Single line summarizing what improved.
    let summary: String
}

nonisolated enum WorkoutHighlightBuilder {

    struct Result: Sendable {
        let highlights: [WorkoutHighlight]
        let verdict: SessionVerdict
    }

    static func buildResult(
        session: WorkoutSession,
        history: [WorkoutSession],
        streak: Int,
        exerciseName: (String) -> String
    ) -> Result {
        let highlights = build(session: session, history: history, streak: streak, exerciseName: exerciseName)
        let verdict = makeVerdict(session: session, history: history, highlights: highlights)
        return Result(highlights: highlights, verdict: verdict)
    }

    static func build(
        session: WorkoutSession,
        history: [WorkoutSession],
        streak: Int,
        exerciseName: (String) -> String
    ) -> [WorkoutHighlight] {
        var out: [WorkoutHighlight] = []

        let completed = session.exerciseLogs.flatMap(\.sets).filter(\.isCompleted)
        guard !completed.isEmpty else { return [] }

        let previous: WorkoutSession? = history
            .filter { $0.id != session.id && $0.isCompleted }
            .sorted(by: { $0.startTime > $1.startTime })
            .first

        // MARK: PR sets
        let prSets = session.exerciseLogs.flatMap { log in
            log.sets.filter { $0.isCompleted && $0.isPR }.map { (log.exerciseId, $0) }
        }
        let rankedPRs = prSets.sorted { a, b in
            estimatedOneRM(a.1) > estimatedOneRM(b.1)
        }
        for (idx, pair) in rankedPRs.prefix(3).enumerated() {
            let (exerciseId, set) = pair
            let name = exerciseName(exerciseId)
            // PRs score very high; primary PR gets the highest score.
            let score = 1000.0 + estimatedOneRM(set) - Double(idx) * 1.0
            out.append(WorkoutHighlight(
                kind: .personalRecord,
                title: L10n.tr("Personal Record"),
                subtitle: name,
                valuePrimary: formatWeightReps(set.weight, set.reps),
                valueSecondary: L10n.format("e1RM %.0f", estimatedOneRM(set)),
                score: score,
                improvedLine: L10n.format("New PR on %@", name)
            ))
        }

        // MARK: Best set improvements vs previous session
        if let previous {
            var improvements: [(name: String, now: SetLog, before: SetLog, delta: Double)] = []
            for log in session.exerciseLogs {
                guard let prevLog = previous.exerciseLogs.first(where: { $0.exerciseId == log.exerciseId }) else { continue }
                let now = log.sets.filter(\.isCompleted).max(by: { estimatedOneRM($0) < estimatedOneRM($1) })
                let before = prevLog.sets.filter(\.isCompleted).max(by: { estimatedOneRM($0) < estimatedOneRM($1) })
                if let now, let before {
                    let delta = estimatedOneRM(now) - estimatedOneRM(before)
                    if delta > 0.5 {
                        improvements.append((exerciseName(log.exerciseId), now, before, delta))
                    }
                }
            }
            improvements.sort { $0.delta > $1.delta }
            for (idx, imp) in improvements.prefix(2).enumerated() {
                if prSets.contains(where: { _, s in s.id == imp.now.id }) { continue }
                // Best set score: 600 + delta, slightly lower than PR.
                let score = 600.0 + imp.delta - Double(idx) * 1.0
                out.append(WorkoutHighlight(
                    kind: .bestSet,
                    title: L10n.tr("Best Set"),
                    subtitle: imp.name,
                    valuePrimary: formatWeightReps(imp.now.weight, imp.now.reps),
                    valueSecondary: L10n.format("vs %@", formatWeightReps(imp.before.weight, imp.before.reps)),
                    score: score,
                    improvedLine: L10n.format("Beat last %@", imp.name)
                ))
            }
        }

        // MARK: Volume delta vs previous
        if let previous, previous.totalVolume > 0, session.totalVolume > 0 {
            let delta = session.totalVolume - previous.totalVolume
            let pct = delta / previous.totalVolume
            if abs(pct) >= 0.05 {
                let positive = delta > 0
                // Volume up ranks above generic context but below best set.
                // Volume down scores low — it's still useful info but not a win.
                let score = positive ? 400.0 + abs(pct) * 100 : 150.0 - abs(pct) * 100
                out.append(WorkoutHighlight(
                    kind: positive ? .volumeUp : .volumeDown,
                    title: positive ? L10n.tr("Volume Up") : L10n.tr("Volume Down"),
                    subtitle: L10n.tr("vs last session"),
                    valuePrimary: L10n.format("%@%.0f kg", positive ? "+" : "", delta),
                    valueSecondary: L10n.format("%@%.0f%%", positive ? "+" : "", pct * 100),
                    score: score,
                    improvedLine: positive ? L10n.tr("Most volume in recent sessions") : nil
                ))
            }
        } else if previous == nil {
            // First session — meaningful baseline, score high to be the verdict.
            out.append(WorkoutHighlight(
                kind: .firstTime,
                title: L10n.tr("Baseline Set"),
                subtitle: session.dayName,
                valuePrimary: L10n.format("%.0f kg", session.totalVolume),
                valueSecondary: L10n.tr("total volume"),
                score: 700,
                improvedLine: L10n.tr("First session logged — baseline set")
            ))
        }

        // MARK: Consolidation — repeated session at same/near load with clean quality
        if let previous, out.filter({ $0.kind == .personalRecord || $0.kind == .bestSet }).isEmpty {
            let allClean = completed.allSatisfy { ($0.quality ?? .onTarget) != .formBreakdown && $0.quality != .pain }
            let matchedOrBetter = sessionMatchedOrBeat(session: session, previous: previous)
            if allClean && matchedOrBetter {
                out.append(WorkoutHighlight(
                    kind: .consolidation,
                    title: L10n.tr("Consolidated"),
                    subtitle: L10n.tr("clean execution"),
                    valuePrimary: L10n.tr("HOLD"),
                    valueSecondary: L10n.tr("ready to push"),
                    score: 350,
                    improvedLine: L10n.tr("Technique held — ready to push next time")
                ))
            }
        }

        // MARK: Longest session
        if let duration = sessionMinutes(session) {
            let previousLongest = history
                .filter { $0.id != session.id && $0.isCompleted }
                .compactMap(sessionMinutes)
                .max() ?? 0
            if duration >= previousLongest && duration > 30 && previousLongest > 0 {
                out.append(WorkoutHighlight(
                    kind: .longestSession,
                    title: L10n.tr("Longest Session"),
                    subtitle: L10n.tr("new personal best"),
                    valuePrimary: L10n.format("%d min", duration),
                    valueSecondary: L10n.format("prev %d min", previousLongest),
                    score: 220
                ))
            }
        }

        // MARK: Streak milestone — context, not achievement
        if [3, 5, 7, 10, 14, 21, 30, 50, 100].contains(streak) {
            out.append(WorkoutHighlight(
                kind: .streakMilestone,
                title: L10n.tr("Streak"),
                subtitle: L10n.tr("consecutive days"),
                valuePrimary: L10n.format("%d", streak),
                valueSecondary: L10n.tr("days"),
                score: 120 + Double(streak)
            ))
        }

        // MARK: Sets milestone — lifetime context
        let totalHistorySets = history.filter(\.isCompleted).flatMap(\.exerciseLogs).flatMap(\.sets).filter(\.isCompleted).count
        if [50, 100, 250, 500, 1000, 2500, 5000].contains(totalHistorySets) {
            out.append(WorkoutHighlight(
                kind: .setsMilestone,
                title: L10n.tr("Sets Milestone"),
                subtitle: L10n.tr("lifetime"),
                valuePrimary: L10n.format("%d", totalHistorySets),
                valueSecondary: L10n.tr("total sets"),
                score: 100
            ))
        }

        // Sort by score descending and mark the first as primary.
        let sorted = out.sorted { $0.score > $1.score }
        guard !sorted.isEmpty else { return [] }
        let primary = sorted[0]
        var ranked: [WorkoutHighlight] = [WorkoutHighlight(
            id: primary.id,
            kind: primary.kind,
            title: primary.title,
            subtitle: primary.subtitle,
            valuePrimary: primary.valuePrimary,
            valueSecondary: primary.valueSecondary,
            score: primary.score,
            isPrimary: true,
            improvedLine: primary.improvedLine
        )]
        ranked.append(contentsOf: sorted.dropFirst())
        return ranked
    }

    // MARK: - Verdict

    private static func makeVerdict(
        session: WorkoutSession,
        history: [WorkoutSession],
        highlights: [WorkoutHighlight]
    ) -> SessionVerdict {
        if let top = highlights.first {
            switch top.kind {
            case .personalRecord:
                return SessionVerdict(kind: .personalRecord, eyebrow: L10n.tr("NEW PERSONAL RECORD"), summary: top.improvedLine ?? L10n.tr("New PR set"))
            case .bestSet:
                return SessionVerdict(kind: .bestSet, eyebrow: L10n.tr("BEST SET"), summary: top.improvedLine ?? L10n.tr("Beat your last session"))
            case .volumeUp:
                return SessionVerdict(kind: .volumeUp, eyebrow: L10n.tr("VOLUME UP"), summary: top.improvedLine ?? L10n.tr("More work than last time"))
            case .volumeDown:
                return SessionVerdict(kind: .volumeDown, eyebrow: L10n.tr("SESSION LOGGED"), summary: L10n.tr("Lighter day — quality over load"))
            case .firstTime:
                return SessionVerdict(kind: .firstSession, eyebrow: L10n.tr("FIRST SESSION"), summary: top.improvedLine ?? L10n.tr("Baseline set"))
            case .consolidation:
                return SessionVerdict(kind: .consolidated, eyebrow: L10n.tr("CONSOLIDATED"), summary: top.improvedLine ?? L10n.tr("Technique held"))
            case .longestSession, .streakMilestone, .setsMilestone:
                return SessionVerdict(kind: .bestSet, eyebrow: L10n.tr("SESSION LOGGED"), summary: L10n.tr("Work put in"))
            }
        }
        // No highlights — still reasonable summary
        let previous = history.filter { $0.id != session.id && $0.isCompleted }.first
        if previous == nil {
            return SessionVerdict(kind: .firstSession, eyebrow: L10n.tr("FIRST SESSION"), summary: L10n.tr("Baseline set"))
        }
        return SessionVerdict(kind: .consolidated, eyebrow: L10n.tr("SESSION LOGGED"), summary: L10n.tr("Session in the bank"))
    }

    // MARK: - Helpers

    private static func sessionMatchedOrBeat(session: WorkoutSession, previous: WorkoutSession) -> Bool {
        var matchedOrBetter = 0
        var total = 0
        for log in session.exerciseLogs {
            guard let prevLog = previous.exerciseLogs.first(where: { $0.exerciseId == log.exerciseId }) else { continue }
            let now = log.sets.filter(\.isCompleted).max(by: { estimatedOneRM($0) < estimatedOneRM($1) })
            let before = prevLog.sets.filter(\.isCompleted).max(by: { estimatedOneRM($0) < estimatedOneRM($1) })
            if let now, let before {
                total += 1
                if estimatedOneRM(now) + 0.1 >= estimatedOneRM(before) {
                    matchedOrBetter += 1
                }
            }
        }
        return total > 0 && matchedOrBetter >= max(1, total - 1)
    }

    private static func estimatedOneRM(_ set: SetLog) -> Double {
        guard set.reps > 0 else { return 0 }
        return set.weight * (1.0 + Double(set.reps) / 30.0)
    }

    private static func formatWeightReps(_ weight: Double, _ reps: Int) -> String {
        if weight <= 0 { return "\(reps) reps" }
        let w = weight.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", weight) : String(format: "%.1f", weight)
        return "\(w) kg × \(reps)"
    }

    private static func sessionMinutes(_ session: WorkoutSession) -> Int? {
        guard let end = session.endTime else { return nil }
        return max(0, Int(end.timeIntervalSince(session.startTime) / 60))
    }
}
