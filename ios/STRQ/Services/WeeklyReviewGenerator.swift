import Foundation

struct WeeklyReviewGenerator {
    private let library = ExerciseLibrary.shared
    private let calendar = Calendar.current

    private struct WeeklyTargetDisplay {
        let primary: String
        let overflowDetail: String?
        let isOverflow: Bool
    }

    private func weeklyTargetDisplay(completed rawCompleted: Int, target rawTarget: Int) -> WeeklyTargetDisplay {
        let completed = max(0, rawCompleted)
        guard rawTarget > 0 else {
            return WeeklyTargetDisplay(primary: "\(completed)", overflowDetail: nil, isOverflow: false)
        }

        let target = rawTarget
        let primary = "\(min(completed, target))/\(target)"
        guard completed > target else {
            return WeeklyTargetDisplay(primary: primary, overflowDetail: nil, isOverflow: false)
        }

        return WeeklyTargetDisplay(
            primary: primary,
            overflowDetail: "+\(completed - target) extra, \(completed) total",
            isOverflow: true
        )
    }

    func generate(
        profile: UserProfile,
        workoutHistory: [WorkoutSession],
        progressEntries: [ProgressEntry],
        personalRecords: [PersonalRecord],
        muscleBalance: [MuscleBalanceEntry],
        currentPlan: WorkoutPlan?,
        recoveryScore: Int,
        streak: Int
    ) -> WeeklyReview {
        let now = Date()
        let weekStart = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now) ?? now

        let thisWeekSessions = workoutHistory.filter { $0.startTime > weekStart && $0.isCompleted }
        let lastWeekSessions = workoutHistory.filter { $0.startTime > twoWeeksAgo && $0.startTime <= weekStart && $0.isCompleted }

        let thisWeekEntries = progressEntries.filter { $0.date > weekStart }
        let lastWeekEntries = progressEntries.filter { $0.date > twoWeeksAgo && $0.date <= weekStart }

        let recentPRs = personalRecords.filter { $0.date > weekStart }

        let summary = buildSummary(
            profile: profile,
            thisWeek: thisWeekSessions,
            lastWeek: lastWeekSessions,
            thisWeekEntries: thisWeekEntries,
            lastWeekEntries: lastWeekEntries,
            recentPRs: recentPRs,
            muscleBalance: muscleBalance,
            recoveryScore: recoveryScore,
            streak: streak
        )

        let wins = buildWins(summary: summary, recentPRs: recentPRs, muscleBalance: muscleBalance, profile: profile)
        let areas = buildAreasToImprove(summary: summary, muscleBalance: muscleBalance, profile: profile, recoveryScore: recoveryScore)
        let conclusion = buildConclusion(summary: summary, recoveryScore: recoveryScore, profile: profile)
        let actions = buildActions(summary: summary, recoveryScore: recoveryScore, muscleBalance: muscleBalance, profile: profile)

        return WeeklyReview(
            weekStartDate: weekStart,
            weekEndDate: now,
            summary: summary,
            wins: wins,
            areasToImprove: areas,
            coachConclusion: conclusion,
            suggestedActions: actions
        )
    }

    private func buildSummary(
        profile: UserProfile,
        thisWeek: [WorkoutSession],
        lastWeek: [WorkoutSession],
        thisWeekEntries: [ProgressEntry],
        lastWeekEntries: [ProgressEntry],
        recentPRs: [PersonalRecord],
        muscleBalance: [MuscleBalanceEntry],
        recoveryScore: Int,
        streak: Int
    ) -> WeekSummary {
        let totalVolume = thisWeek.reduce(0.0) { $0 + $1.totalVolume }
        let prevVolume = lastWeek.reduce(0.0) { $0 + $1.totalVolume }
        let totalSets = thisWeekEntries.reduce(0) { $0 + $1.totalSets }
        let totalReps = thisWeekEntries.reduce(0) { $0 + $1.totalReps }

        let durations = thisWeek.compactMap { session -> Int? in
            guard let end = session.endTime else { return nil }
            return Int(end.timeIntervalSince(session.startTime) / 60)
        }
        let avgDuration = durations.isEmpty ? 0 : durations.reduce(0, +) / durations.count

        let recoveryTrend: RecoveryTrend = {
            switch recoveryScore {
            case 85...: return .improving
            case 65..<85: return .stable
            case 45..<65: return .declining
            default: return .critical
            }
        }()

        let weightEntries = thisWeekEntries.compactMap(\.bodyWeight)
        let prevWeightEntries = lastWeekEntries.compactMap(\.bodyWeight)
        let bodyweightChange: Double? = {
            guard let recentAvg = weightEntries.isEmpty ? nil : weightEntries.reduce(0, +) / Double(weightEntries.count),
                  let prevAvg = prevWeightEntries.isEmpty ? nil : prevWeightEntries.reduce(0, +) / Double(prevWeightEntries.count)
            else { return nil }
            return recentAvg - prevAvg
        }()

        let balanceScore = computeBalanceScore(muscleBalance)

        let pushPullRatio = computePushPullRatio(sessions: thisWeek)
        let upperLowerRatio = computeUpperLowerRatio(muscleBalance: muscleBalance)

        return WeekSummary(
            completedWorkouts: thisWeek.count,
            plannedWorkouts: profile.daysPerWeek,
            totalVolume: totalVolume,
            previousWeekVolume: prevVolume,
            totalSets: totalSets,
            totalReps: totalReps,
            averageDuration: avgDuration,
            recoveryTrend: recoveryTrend,
            personalRecordsCount: recentPRs.count,
            streakDays: streak,
            bodyweightChange: bodyweightChange,
            muscleBalanceScore: balanceScore,
            pushPullRatio: pushPullRatio,
            upperLowerRatio: upperLowerRatio
        )
    }

    private func computeBalanceScore(_ muscleBalance: [MuscleBalanceEntry]) -> Double {
        guard !muscleBalance.isEmpty else { return 1.0 }
        let deviations = muscleBalance.map { abs($0.percentOfAverage - 1.0) }
        let avgDeviation = deviations.reduce(0, +) / Double(deviations.count)
        return max(0, 1.0 - avgDeviation)
    }

    private func computePushPullRatio(sessions: [WorkoutSession]) -> (push: Double, pull: Double)? {
        var pushVol: Double = 0
        var pullVol: Double = 0

        for session in sessions {
            for log in session.exerciseLogs {
                guard let exercise = library.exercise(byId: log.exerciseId) else { continue }
                let vol = log.sets.filter(\.isCompleted).reduce(0.0) { $0 + $1.weight * Double($1.reps) }
                switch exercise.movementPattern {
                case .horizontalPush, .verticalPush: pushVol += vol
                case .horizontalPull, .verticalPull: pullVol += vol
                default: break
                }
            }
        }

        let total = pushVol + pullVol
        guard total > 0 else { return nil }
        return (push: pushVol / total, pull: pullVol / total)
    }

    private func computeUpperLowerRatio(muscleBalance: [MuscleBalanceEntry]) -> (upper: Double, lower: Double)? {
        let upper: Set<String> = ["Chest", "Back", "Shoulders", "Arms"]
        let lower: Set<String> = ["Quads", "Hamstrings", "Glutes", "Calves"]

        let upperVol = muscleBalance.filter { upper.contains($0.muscle) }.reduce(0.0) { $0 + $1.thisWeek }
        let lowerVol = muscleBalance.filter { lower.contains($0.muscle) }.reduce(0.0) { $0 + $1.thisWeek }

        let total = upperVol + lowerVol
        guard total > 0 else { return nil }
        return (upper: upperVol / total, lower: lowerVol / total)
    }

    private func localizedMuscleName(_ displayName: String) -> String {
        displayName
    }

    private func localizedMuscleList(_ names: [String]) -> String {
        let localized = names.map(localizedMuscleName)
        guard localized.count == 2 else { return localized.joined(separator: ", ") }
        return localized.joined(separator: " and ")
    }

    private func streakTitle(_ days: Int) -> String {
        days == 1 ? "1 day in a row" : "\(days) days in a row"
    }

    private func personalRecordTitle(_ count: Int) -> String {
        count == 1 ? "1 new PR" : "\(count) new PRs"
    }

    private func personalRecordPhrase(_ count: Int) -> String {
        count == 1 ? "1 new PR" : "\(count) new PRs"
    }

    private func recoveryTrendTitle(_ trend: RecoveryTrend) -> String {
        switch trend {
        case .improving: return "Recovery signal improving"
        case .stable: return "Recovery signal steady"
        case .declining: return "Recovery signal dipping"
        case .critical: return "Recovery signal low"
        }
    }

    private func buildWins(summary: WeekSummary, recentPRs: [PersonalRecord], muscleBalance: [MuscleBalanceEntry], profile: UserProfile) -> [ReviewHighlight] {
        var wins: [ReviewHighlight] = []
        let targetDisplay = weeklyTargetDisplay(completed: summary.completedWorkouts, target: summary.plannedWorkouts)

        if summary.plannedWorkouts > 0 && summary.completedWorkouts >= summary.plannedWorkouts {
            wins.append(ReviewHighlight(
                icon: "checkmark.seal.fill",
                title: "Target hit",
                detail: targetDisplay.overflowDetail.map {
                    "Target hit: \(targetDisplay.primary), \($0)."
                } ?? "Target hit: \(targetDisplay.primary).",
                color: "green"
            ))
        } else if summary.plannedWorkouts > 0 && summary.completedWorkouts > 0 && Double(summary.completedWorkouts) / Double(max(1, summary.plannedWorkouts)) >= 0.75 {
            wins.append(ReviewHighlight(
                icon: "figure.strengthtraining.traditional",
                title: "Strong week",
                detail: "\(summary.completedWorkouts)/\(summary.plannedWorkouts) workouts closed. The rhythm is there.",
                color: "green"
            ))
        }

        if summary.personalRecordsCount > 0 {
            wins.append(ReviewHighlight(
                icon: "trophy.fill",
                title: personalRecordTitle(summary.personalRecordsCount),
                detail: "New best saved.",
                color: "yellow"
            ))
        }

        if summary.streakDays >= 7 {
            wins.append(ReviewHighlight(
                icon: "flame.fill",
                title: streakTitle(summary.streakDays),
                detail: "Consistency is showing. Hold the rhythm.",
                color: "orange"
            ))
        }

        if summary.previousWeekVolume > 0 {
            let volumeChange = (summary.totalVolume - summary.previousWeekVolume) / summary.previousWeekVolume
            if volumeChange > 0.05 && volumeChange < 0.2 {
                wins.append(ReviewHighlight(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Volume up",
                    detail: "Volume finished above last week.",
                    color: "blue"
                ))
            }
        }

        if summary.recoveryTrend == .improving || summary.recoveryTrend == .stable {
            wins.append(ReviewHighlight(
                icon: "heart.fill",
                title: recoveryTrendTitle(summary.recoveryTrend),
                detail: summary.recoveryTrend == .improving
                    ? "Recovery signal moved up."
                    : "Recovery signal stayed steady.",
                color: "green"
            ))
        }

        let strongMuscles = muscleBalance.filter { $0.percentOfAverage >= 1.0 && $0.percentOfAverage <= 1.2 }
        let focusNames = Set(profile.focusMuscles.map(\.displayName))
        let onTargetFocus = strongMuscles.filter { focusNames.contains($0.muscle) }
        if !onTargetFocus.isEmpty {
            let names = localizedMuscleList(onTargetFocus.prefix(2).map(\.muscle))
            wins.append(ReviewHighlight(
                icon: "target",
                title: "Focus work on track",
                detail: "\(names) stayed in range.",
                color: "blue"
            ))
        }

        return Array(wins.prefix(4))
    }

    private func buildAreasToImprove(summary: WeekSummary, muscleBalance: [MuscleBalanceEntry], profile: UserProfile, recoveryScore: Int) -> [ReviewHighlight] {
        var areas: [ReviewHighlight] = []

        if summary.completedWorkouts < summary.plannedWorkouts && summary.completedWorkouts > 0 {
            let missed = summary.plannedWorkouts - summary.completedWorkouts
            areas.append(ReviewHighlight(
                icon: "calendar.badge.exclamationmark",
                title: missed == 1 ? "1 workout open" : "\(missed) workouts open",
                detail: "\(summary.completedWorkouts)/\(summary.plannedWorkouts) planned workouts closed.",
                color: "yellow"
            ))
        }

        let undertrained = muscleBalance.filter { $0.percentOfAverage < 0.8 }
        if let weakest = undertrained.first {
            let muscle = localizedMuscleName(weakest.muscle)
            areas.append(ReviewHighlight(
                icon: "arrow.down.circle.fill",
                title: "\(muscle): Needs attention",
                detail: "Bring it up calmly next week.",
                color: "orange"
            ))
        }

        if summary.recoveryTrend == .declining || summary.recoveryTrend == .critical {
            areas.append(ReviewHighlight(
                icon: "heart.slash.fill",
                title: recoveryTrendTitle(summary.recoveryTrend),
                detail: recoveryScore < 50
                    ? "Keep next week lighter and readable."
                    : "Keep next week readable.",
                color: "red"
            ))
        }

        if let pp = summary.pushPullRatio, pp.push > 0.63 {
            areas.append(ReviewHighlight(
                icon: "arrow.left.arrow.right",
                title: "Push work leading",
                detail: "Add a little more pull work next week.",
                color: "orange"
            ))
        } else if let pp = summary.pushPullRatio, pp.pull > 0.63 {
            areas.append(ReviewHighlight(
                icon: "arrow.left.arrow.right",
                title: "Pull work leading",
                detail: "Add a little more push work next week.",
                color: "orange"
            ))
        }

        if summary.previousWeekVolume > 0 {
            let volumeChange = (summary.totalVolume - summary.previousWeekVolume) / summary.previousWeekVolume
            if volumeChange > 0.25 {
                areas.append(ReviewHighlight(
                    icon: "exclamationmark.triangle.fill",
                    title: "Volume jumped",
                    detail: "Keep next week readable.",
                    color: "red"
                ))
            } else if volumeChange < -0.2 {
                areas.append(ReviewHighlight(
                    icon: "chart.line.downtrend.xyaxis",
                    title: "Volume down",
                    detail: "Volume landed below last week. Check if that was planned.",
                    color: "yellow"
                ))
            }
        }

        return Array(areas.prefix(4))
    }

    private func buildConclusion(summary: WeekSummary, recoveryScore: Int, profile: UserProfile) -> CoachConclusion {
        let completionRate = Double(summary.completedWorkouts) / Double(max(1, summary.plannedWorkouts))
        let hasPlannedTarget = summary.plannedWorkouts > 0
        let hasGoodVolume = summary.previousWeekVolume > 0 ? (summary.totalVolume / summary.previousWeekVolume) >= 0.85 : true
        let targetDisplay = weeklyTargetDisplay(completed: summary.completedWorkouts, target: summary.plannedWorkouts)

        if recoveryScore < 45 {
            return CoachConclusion(
                headline: "Keep next week readable",
                message: "Training ran high. Plan next week lighter.",
                tone: .urgent
            )
        }

        if recoveryScore < 65 && completionRate >= 0.75 {
            return CoachConclusion(
                headline: "Strong work, keep it readable",
                message: !hasPlannedTarget
                    ? "Volume is logged and the recovery signal is dipping. Keep next week readable until the target is clearer."
                    : targetDisplay.isOverflow
                    ? "Target hit with extra sessions logged. Keep next week readable."
                    : "Good training rhythm, with the recovery signal dipping. Keep volume or intensity a little quieter next week.",
                tone: .cautious
            )
        }

        if hasPlannedTarget && completionRate >= 1.0 && summary.personalRecordsCount > 0 && recoveryScore >= 65 {
            return CoachConclusion(
                headline: targetDisplay.isOverflow ? "Target hit" : "Strong week",
                message: targetDisplay.isOverflow
                    ? "Target hit, \(personalRecordPhrase(summary.personalRecordsCount)), and \(targetDisplay.overflowDetail ?? "extra sessions logged"). Keep next week readable."
                    : "All sessions closed, \(personalRecordPhrase(summary.personalRecordsCount)). Good base for next week.",
                tone: .positive
            )
        }

        if hasPlannedTarget && completionRate >= 0.75 && hasGoodVolume && recoveryScore >= 65 {
            return CoachConclusion(
                headline: "Solid week",
                message: targetDisplay.isOverflow
                    ? "Target hit with extra sessions logged. Keep next week readable before adding more."
                    : "Good consistency and solid volume. Hold the rhythm next week.",
                tone: .positive
            )
        }

        if hasPlannedTarget && completionRate < 0.5 {
            return CoachConclusion(
                headline: "Return to rhythm",
                message: "This week ran lighter than planned. Next week starts with one clean session.",
                tone: .encouraging
            )
        }

        return CoachConclusion(
            headline: "Keep building",
            message: "Solid base. Next week is about a steadier training rhythm.",
            tone: .encouraging
        )
    }

    private func buildActions(summary: WeekSummary, recoveryScore: Int, muscleBalance: [MuscleBalanceEntry], profile: UserProfile) -> [ReviewAction] {
        var actions: [ReviewAction] = []

        let completionRate = Double(summary.completedWorkouts) / Double(max(1, summary.plannedWorkouts))
        let hasPlannedTarget = summary.plannedWorkouts > 0
        let targetDisplay = weeklyTargetDisplay(completed: summary.completedWorkouts, target: summary.plannedWorkouts)

        if recoveryScore < 50 {
            actions.append(ReviewAction(
                type: .deloadWeek,
                label: "Start deload week",
                icon: "arrow.down.to.line",
                description: "Reduce volume and intensity on purpose.",
                isPrimary: true
            ))
        }

        let undertrained = muscleBalance.filter { $0.percentOfAverage < 0.8 }
        if undertrained.count >= 2 || (recoveryScore >= 50 && recoveryScore < 70) {
            actions.append(ReviewAction(
                type: .regenerateWeek,
                label: "Rebuild next week",
                icon: "arrow.triangle.2.circlepath.circle.fill",
                description: "Rebuild the week so training and recovery fit better.",
                isPrimary: recoveryScore >= 50
            ))
        }

        if recoveryScore >= 60 && recoveryScore < 80 && summary.totalVolume > summary.previousWeekVolume * 1.1 {
            actions.append(ReviewAction(
                type: .reduceVolume,
                label: "Reduce volume",
                icon: "minus.circle.fill",
                description: "Trim accessory work and keep the main lifts steady."
            ))
        }

        if hasPlannedTarget && completionRate >= 0.75 && recoveryScore >= 65 && undertrained.count < 2 {
            actions.append(ReviewAction(
                type: .keepAsIs,
                label: "Hold the week",
                icon: "checkmark.circle.fill",
                description: targetDisplay.isOverflow
                    ? "Target hit with extra sessions logged. Hold a readable rhythm next week."
                    : "Hold the current structure. No change needed.",
                isPrimary: actions.filter(\.isPrimary).isEmpty
            ))
        }

        if let pp = summary.pushPullRatio, (pp.push > 0.6 || pp.pull > 0.6) || undertrained.count >= 3 {
            actions.append(ReviewAction(
                type: .rebalancePlan,
                label: "Adjust distribution",
                icon: "arrow.left.arrow.right",
                description: "Spread exercise selection and volume more evenly."
            ))
        }

        if hasPlannedTarget && completionRate < 0.5 && summary.plannedWorkouts > 3 {
            actions.append(ReviewAction(
                type: .increaseFrequency,
                label: "Adjust frequency",
                icon: "calendar.badge.plus",
                description: "Fit the plan to your real availability."
            ))
        }

        if actions.isEmpty {
            actions.append(ReviewAction(
                type: .keepAsIs,
                label: "Hold the week",
                icon: "checkmark.circle.fill",
                description: targetDisplay.isOverflow
                    ? "Target hit with extra sessions logged. Hold a steady rhythm next week."
                    : hasPlannedTarget
                    ? "Everything is in range. Hold the current structure."
                    : "Keep logging sessions so the review gets clearer.",
                isPrimary: true
            ))
        }

        return Array(actions.prefix(4))
    }
}
