import Foundation

struct WeeklyReviewGenerator {
    private let library = ExerciseLibrary.shared
    private let calendar = Calendar.current

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

    private func buildWins(summary: WeekSummary, recentPRs: [PersonalRecord], muscleBalance: [MuscleBalanceEntry], profile: UserProfile) -> [ReviewHighlight] {
        var wins: [ReviewHighlight] = []

        if summary.completedWorkouts >= summary.plannedWorkouts {
            wins.append(ReviewHighlight(
                icon: "checkmark.seal.fill",
                title: "All Sessions Completed",
                detail: "You hit \(summary.completedWorkouts)/\(summary.plannedWorkouts) planned workouts this week.",
                color: "green"
            ))
        } else if summary.completedWorkouts > 0 && Double(summary.completedWorkouts) / Double(max(1, summary.plannedWorkouts)) >= 0.75 {
            wins.append(ReviewHighlight(
                icon: "figure.strengthtraining.traditional",
                title: "Strong Week",
                detail: "\(summary.completedWorkouts) of \(summary.plannedWorkouts) sessions completed — solid consistency.",
                color: "green"
            ))
        }

        if summary.personalRecordsCount > 0 {
            let prNames = recentPRs.prefix(2).compactMap { library.exercise(byId: $0.exerciseId)?.name }
            let namesText = prNames.isEmpty ? "" : " on \(prNames.joined(separator: " and "))"
            wins.append(ReviewHighlight(
                icon: "trophy.fill",
                title: "\(summary.personalRecordsCount) Personal Record\(summary.personalRecordsCount > 1 ? "s" : "")",
                detail: "New best\(summary.personalRecordsCount > 1 ? "s" : "")\(namesText). Your training is paying off.",
                color: "yellow"
            ))
        }

        if summary.streakDays >= 7 {
            wins.append(ReviewHighlight(
                icon: "flame.fill",
                title: "\(summary.streakDays)-Day Streak",
                detail: "Consistency is the key to progress. Keep this momentum going.",
                color: "orange"
            ))
        }

        if summary.previousWeekVolume > 0 {
            let volumeChange = (summary.totalVolume - summary.previousWeekVolume) / summary.previousWeekVolume
            if volumeChange > 0.05 && volumeChange < 0.2 {
                wins.append(ReviewHighlight(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Volume Increased",
                    detail: "Total volume up \(Int(volumeChange * 100))% vs last week. Progressive overload in action.",
                    color: "blue"
                ))
            }
        }

        if summary.recoveryTrend == .improving || summary.recoveryTrend == .stable {
            wins.append(ReviewHighlight(
                icon: "heart.fill",
                title: "Recovery \(summary.recoveryTrend.label)",
                detail: "Your body is handling the current training load well.",
                color: "green"
            ))
        }

        let strongMuscles = muscleBalance.filter { $0.percentOfAverage >= 1.0 && $0.percentOfAverage <= 1.2 }
        let focusNames = Set(profile.focusMuscles.map(\.displayName))
        let onTargetFocus = strongMuscles.filter { focusNames.contains($0.muscle) }
        if !onTargetFocus.isEmpty {
            let names = onTargetFocus.prefix(2).map(\.muscle).joined(separator: " and ")
            wins.append(ReviewHighlight(
                icon: "target",
                title: "Focus Muscles On Track",
                detail: "\(names) volume is right where it should be.",
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
                title: "\(missed) Missed Session\(missed > 1 ? "s" : "")",
                detail: "You completed \(summary.completedWorkouts) of \(summary.plannedWorkouts) planned. Try to stay consistent next week.",
                color: "yellow"
            ))
        }

        let undertrained = muscleBalance.filter { $0.percentOfAverage < 0.8 }
        if let weakest = undertrained.first {
            areas.append(ReviewHighlight(
                icon: "arrow.down.circle.fill",
                title: "\(weakest.muscle) Volume Low",
                detail: "\(weakest.muscle) is \(Int((1.0 - weakest.percentOfAverage) * 100))% below your recent average. Prioritize it next week.",
                color: "orange"
            ))
        }

        if summary.recoveryTrend == .declining || summary.recoveryTrend == .critical {
            areas.append(ReviewHighlight(
                icon: "heart.slash.fill",
                title: "Recovery \(summary.recoveryTrend.label)",
                detail: recoveryScore < 50
                    ? "Your body needs more rest. Consider a deload or lighter week."
                    : "Watch your fatigue. Sustained high training density can lead to burnout.",
                color: "red"
            ))
        }

        if let pp = summary.pushPullRatio, pp.push > 0.63 {
            areas.append(ReviewHighlight(
                icon: "arrow.left.arrow.right",
                title: "Push-Heavy Balance",
                detail: "Push:Pull ratio is \(Int(pp.push * 100)):\(Int(pp.pull * 100)). Add more pulling work for shoulder health.",
                color: "orange"
            ))
        } else if let pp = summary.pushPullRatio, pp.pull > 0.63 {
            areas.append(ReviewHighlight(
                icon: "arrow.left.arrow.right",
                title: "Pull-Heavy Balance",
                detail: "Pull:Push ratio is \(Int(pp.pull * 100)):\(Int(pp.push * 100)). Add more pressing movements.",
                color: "orange"
            ))
        }

        if summary.previousWeekVolume > 0 {
            let volumeChange = (summary.totalVolume - summary.previousWeekVolume) / summary.previousWeekVolume
            if volumeChange > 0.25 {
                areas.append(ReviewHighlight(
                    icon: "exclamationmark.triangle.fill",
                    title: "Volume Spike",
                    detail: "Volume jumped \(Int(volumeChange * 100))% vs last week. Sharp increases raise injury risk.",
                    color: "red"
                ))
            } else if volumeChange < -0.2 {
                areas.append(ReviewHighlight(
                    icon: "chart.line.downtrend.xyaxis",
                    title: "Volume Drop",
                    detail: "Volume decreased \(Int(abs(volumeChange) * 100))% vs last week. Ensure this was intentional.",
                    color: "yellow"
                ))
            }
        }

        return Array(areas.prefix(4))
    }

    private func buildConclusion(summary: WeekSummary, recoveryScore: Int, profile: UserProfile) -> CoachConclusion {
        let completionRate = Double(summary.completedWorkouts) / Double(max(1, summary.plannedWorkouts))
        let hasGoodVolume = summary.previousWeekVolume > 0 ? (summary.totalVolume / summary.previousWeekVolume) >= 0.85 : true

        if recoveryScore < 45 {
            return CoachConclusion(
                headline: "Recovery Needs Attention",
                message: "Your fatigue signals are elevated. Consider a deload week or significantly lighter sessions. Training through high fatigue increases injury risk and slows progress.",
                tone: .urgent
            )
        }

        if recoveryScore < 65 && completionRate >= 0.75 {
            return CoachConclusion(
                headline: "Good Work, But Watch Fatigue",
                message: "Strong training consistency this week, but recovery is trending down. Consider reducing volume or going lighter next week to let your body catch up.",
                tone: .cautious
            )
        }

        if completionRate >= 1.0 && summary.personalRecordsCount > 0 && recoveryScore >= 65 {
            return CoachConclusion(
                headline: "Outstanding Week",
                message: "All sessions completed, \(summary.personalRecordsCount) new PR\(summary.personalRecordsCount > 1 ? "s" : ""), and recovery looks good. Continue with your current plan — momentum is on your side.",
                tone: .positive
            )
        }

        if completionRate >= 0.75 && hasGoodVolume && recoveryScore >= 65 {
            return CoachConclusion(
                headline: "Solid Week Overall",
                message: "Good consistency and volume this week. Keep training with intent and the results will follow. Your plan is working.",
                tone: .positive
            )
        }

        if completionRate < 0.5 {
            return CoachConclusion(
                headline: "Let's Get Back on Track",
                message: "This week was lighter than planned. That's okay — consistency has ups and downs. Focus on hitting your sessions next week. Even partial workouts count.",
                tone: .encouraging
            )
        }

        return CoachConclusion(
            headline: "Keep Building",
            message: "Decent week with room for improvement. Stay focused on your \(profile.goal.displayName.lowercased()) goal and aim for more consistent sessions next week.",
            tone: .encouraging
        )
    }

    private func buildActions(summary: WeekSummary, recoveryScore: Int, muscleBalance: [MuscleBalanceEntry], profile: UserProfile) -> [ReviewAction] {
        var actions: [ReviewAction] = []

        let completionRate = Double(summary.completedWorkouts) / Double(max(1, summary.plannedWorkouts))

        if recoveryScore < 50 {
            actions.append(ReviewAction(
                type: .deloadWeek,
                label: "Start Deload Week",
                icon: "arrow.down.to.line",
                description: "Reduce volume and intensity to let your body recover and supercompensate.",
                isPrimary: true
            ))
        }

        let undertrained = muscleBalance.filter { $0.percentOfAverage < 0.8 }
        if undertrained.count >= 2 || (recoveryScore >= 50 && recoveryScore < 70) {
            actions.append(ReviewAction(
                type: .regenerateWeek,
                label: "Regenerate Next Week",
                icon: "arrow.triangle.2.circlepath.circle.fill",
                description: "Rebuild your week to improve muscle balance and match your current recovery state.",
                isPrimary: recoveryScore >= 50
            ))
        }

        if recoveryScore >= 60 && recoveryScore < 80 && summary.totalVolume > summary.previousWeekVolume * 1.1 {
            actions.append(ReviewAction(
                type: .reduceVolume,
                label: "Reduce Volume Next Week",
                icon: "minus.circle.fill",
                description: "Lower accessory sets to manage fatigue while keeping main lifts on track."
            ))
        }

        if completionRate >= 0.75 && recoveryScore >= 65 && undertrained.count < 2 {
            actions.append(ReviewAction(
                type: .keepAsIs,
                label: "Keep Next Week As Is",
                icon: "checkmark.circle.fill",
                description: "Your current plan is working well. No changes needed.",
                isPrimary: actions.filter(\.isPrimary).isEmpty
            ))
        }

        if let pp = summary.pushPullRatio, (pp.push > 0.6 || pp.pull > 0.6) || undertrained.count >= 3 {
            actions.append(ReviewAction(
                type: .rebalancePlan,
                label: "Rebalance Plan",
                icon: "arrow.left.arrow.right",
                description: "Adjust exercise selection and volume to improve muscle and movement balance."
            ))
        }

        if completionRate < 0.5 && summary.plannedWorkouts > 3 {
            actions.append(ReviewAction(
                type: .increaseFrequency,
                label: "Adjust Frequency",
                icon: "calendar.badge.plus",
                description: "Update your plan to match your actual availability for better results."
            ))
        }

        if actions.isEmpty {
            actions.append(ReviewAction(
                type: .keepAsIs,
                label: "Keep Next Week As Is",
                icon: "checkmark.circle.fill",
                description: "Everything looks good. Continue with your current plan.",
                isPrimary: true
            ))
        }

        return Array(actions.prefix(4))
    }
}
