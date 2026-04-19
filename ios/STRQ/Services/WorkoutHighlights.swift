import Foundation

nonisolated struct WorkoutHighlight: Identifiable, Sendable {
    enum Kind: Sendable {
        case personalRecord
        case bestSet
        case volumeUp
        case volumeDown
        case firstTime
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

    init(id: String = UUID().uuidString, kind: Kind, title: String, subtitle: String? = nil, valuePrimary: String, valueSecondary: String? = nil) {
        self.id = id
        self.kind = kind
        self.title = title
        self.subtitle = subtitle
        self.valuePrimary = valuePrimary
        self.valueSecondary = valueSecondary
    }
}

nonisolated enum WorkoutHighlightBuilder {

    static func build(
        session: WorkoutSession,
        history: [WorkoutSession],
        streak: Int,
        exerciseName: (String) -> String
    ) -> [WorkoutHighlight] {
        var out: [WorkoutHighlight] = []

        let completed = session.exerciseLogs.flatMap(\.sets).filter(\.isCompleted)
        guard !completed.isEmpty else { return [] }

        // Previous completed session (excluding the current one).
        let previous: WorkoutSession? = history
            .filter { $0.id != session.id && $0.isCompleted }
            .sorted(by: { $0.startTime > $1.startTime })
            .first

        // MARK: PR sets (explicit isPR flag)
        let prSets = session.exerciseLogs.flatMap { log in
            log.sets.filter { $0.isCompleted && $0.isPR }.map { (log.exerciseId, $0) }
        }
        for (exerciseId, set) in prSets.prefix(3) {
            let name = exerciseName(exerciseId)
            out.append(WorkoutHighlight(
                kind: .personalRecord,
                title: "Personal Record",
                subtitle: name,
                valuePrimary: formatWeightReps(set.weight, set.reps),
                valueSecondary: nil
            ))
        }

        // MARK: Best set vs previous session per exercise — top 2 improvements
        if let previous {
            var improvements: [(name: String, now: SetLog, before: SetLog)] = []
            for log in session.exerciseLogs {
                guard let prevLog = previous.exerciseLogs.first(where: { $0.exerciseId == log.exerciseId }) else { continue }
                let now = log.sets.filter(\.isCompleted).max(by: { estimatedOneRM($0) < estimatedOneRM($1) })
                let before = prevLog.sets.filter(\.isCompleted).max(by: { estimatedOneRM($0) < estimatedOneRM($1) })
                if let now, let before, estimatedOneRM(now) > estimatedOneRM(before) + 0.5 {
                    improvements.append((exerciseName(log.exerciseId), now, before))
                }
            }
            improvements.sort { (estimatedOneRM($0.now) - estimatedOneRM($0.before)) > (estimatedOneRM($1.now) - estimatedOneRM($1.before)) }
            for imp in improvements.prefix(2) {
                // Skip if already captured as PR
                if prSets.contains(where: { _, s in s.id == imp.now.id }) { continue }
                out.append(WorkoutHighlight(
                    kind: .bestSet,
                    title: "Best Set",
                    subtitle: imp.name,
                    valuePrimary: formatWeightReps(imp.now.weight, imp.now.reps),
                    valueSecondary: "vs \(formatWeightReps(imp.before.weight, imp.before.reps))"
                ))
            }
        }

        // MARK: Volume vs previous session
        if let previous, previous.totalVolume > 0, session.totalVolume > 0 {
            let delta = session.totalVolume - previous.totalVolume
            let pct = delta / previous.totalVolume
            if abs(pct) >= 0.05 {
                let positive = delta > 0
                out.append(WorkoutHighlight(
                    kind: positive ? .volumeUp : .volumeDown,
                    title: positive ? "Volume Up" : "Volume Down",
                    subtitle: "vs last session",
                    valuePrimary: String(format: "%@%.0f kg", positive ? "+" : "", delta),
                    valueSecondary: String(format: "%@%.0f%%", positive ? "+" : "", pct * 100)
                ))
            }
        } else if previous == nil {
            out.append(WorkoutHighlight(
                kind: .firstTime,
                title: "First Session",
                subtitle: session.dayName,
                valuePrimary: String(format: "%.0f kg", session.totalVolume),
                valueSecondary: "total volume"
            ))
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
                    title: "Longest Session",
                    subtitle: "new personal best",
                    valuePrimary: "\(duration) min",
                    valueSecondary: "prev \(previousLongest) min"
                ))
            }
        }

        // MARK: Streak milestone
        if [3, 5, 7, 10, 14, 21, 30, 50, 100].contains(streak) {
            out.append(WorkoutHighlight(
                kind: .streakMilestone,
                title: "Streak",
                subtitle: "consecutive days",
                valuePrimary: "\(streak)",
                valueSecondary: "days"
            ))
        }

        // MARK: Sets milestone (total completed sets across history)
        let totalHistorySets = history.filter(\.isCompleted).flatMap(\.exerciseLogs).flatMap(\.sets).filter(\.isCompleted).count
        if [50, 100, 250, 500, 1000, 2500, 5000].contains(totalHistorySets) {
            out.append(WorkoutHighlight(
                kind: .setsMilestone,
                title: "Sets Milestone",
                subtitle: "lifetime",
                valuePrimary: "\(totalHistorySets)",
                valueSecondary: "total sets"
            ))
        }

        return out
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
