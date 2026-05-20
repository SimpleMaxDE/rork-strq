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
            overflowDetail: "+\(completed - target) zusätzlich, \(completed) gesamt",
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
        MuscleGroup.localizedDisplayName(forDisplayName: displayName)
    }

    private func localizedMuscleList(_ names: [String]) -> String {
        let localized = names.map(localizedMuscleName)
        guard localized.count == 2 else { return localized.joined(separator: ", ") }
        return localized.joined(separator: " und ")
    }

    private func streakTitle(_ days: Int) -> String {
        days == 1 ? "1 Tag am Stück" : "\(days) Tage am Stück"
    }

    private func personalRecordTitle(_ count: Int) -> String {
        count == 1 ? "1 neuer PR" : "\(count) neue PRs"
    }

    private func personalRecordPhrase(_ count: Int) -> String {
        count == 1 ? "1 neuer PR" : "\(count) neue PRs"
    }

    private func recoveryTrendTitle(_ trend: RecoveryTrend) -> String {
        switch trend {
        case .improving: return "Erholung steigt"
        case .stable: return "Erholung stabil"
        case .declining: return "Erholung sinkt"
        case .critical: return "Erholung niedrig"
        }
    }

    private func buildWins(summary: WeekSummary, recentPRs: [PersonalRecord], muscleBalance: [MuscleBalanceEntry], profile: UserProfile) -> [ReviewHighlight] {
        var wins: [ReviewHighlight] = []
        let targetDisplay = weeklyTargetDisplay(completed: summary.completedWorkouts, target: summary.plannedWorkouts)

        if summary.plannedWorkouts > 0 && summary.completedWorkouts >= summary.plannedWorkouts {
            wins.append(ReviewHighlight(
                icon: "checkmark.seal.fill",
                title: "Wochenziel erreicht",
                detail: targetDisplay.overflowDetail.map {
                    "Wochenziel erreicht: \(targetDisplay.primary), \($0)."
                } ?? "Wochenziel erreicht: \(targetDisplay.primary).",
                color: "green"
            ))
        } else if summary.plannedWorkouts > 0 && summary.completedWorkouts > 0 && Double(summary.completedWorkouts) / Double(max(1, summary.plannedWorkouts)) >= 0.75 {
            wins.append(ReviewHighlight(
                icon: "figure.strengthtraining.traditional",
                title: "Starke Woche",
                detail: "\(summary.completedWorkouts)/\(summary.plannedWorkouts) Einheiten abgeschlossen. Der Rhythmus passt.",
                color: "green"
            ))
        }

        if summary.personalRecordsCount > 0 {
            wins.append(ReviewHighlight(
                icon: "trophy.fill",
                title: personalRecordTitle(summary.personalRecordsCount),
                detail: "Neue Bestleistung gespeichert.",
                color: "yellow"
            ))
        }

        if summary.streakDays >= 7 {
            wins.append(ReviewHighlight(
                icon: "flame.fill",
                title: streakTitle(summary.streakDays),
                detail: "Konstanz sichtbar. Halte den Rhythmus.",
                color: "orange"
            ))
        }

        if summary.previousWeekVolume > 0 {
            let volumeChange = (summary.totalVolume - summary.previousWeekVolume) / summary.previousWeekVolume
            if volumeChange > 0.05 && volumeChange < 0.2 {
                wins.append(ReviewHighlight(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Volumen gestiegen",
                    detail: "Gesamtvolumen \(Int(volumeChange * 100))% über der Vorwoche.",
                    color: "blue"
                ))
            }
        }

        if summary.recoveryTrend == .improving || summary.recoveryTrend == .stable {
            wins.append(ReviewHighlight(
                icon: "heart.fill",
                title: recoveryTrendTitle(summary.recoveryTrend),
                detail: summary.recoveryTrend == .improving
                    ? "Das Erholungssignal verbessert sich."
                    : "Belastung und Erholung wirken im Rahmen.",
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
                title: "Fokusmuskeln im Plan",
                detail: "\(names) liegen im Zielbereich.",
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
                title: missed == 1 ? "1 Einheit offen" : "\(missed) Einheiten offen",
                detail: "\(summary.completedWorkouts)/\(summary.plannedWorkouts) geplante Einheiten abgeschlossen.",
                color: "yellow"
            ))
        }

        let undertrained = muscleBalance.filter { $0.percentOfAverage < 0.8 }
        if let weakest = undertrained.first {
            let muscle = localizedMuscleName(weakest.muscle)
            areas.append(ReviewHighlight(
                icon: "arrow.down.circle.fill",
                title: "\(muscle): Volumen niedrig",
                detail: "\(muscle) liegt \(Int((1.0 - weakest.percentOfAverage) * 100))% unter deinem letzten Schnitt.",
                color: "orange"
            ))
        }

        if summary.recoveryTrend == .declining || summary.recoveryTrend == .critical {
            areas.append(ReviewHighlight(
                icon: "heart.slash.fill",
                title: recoveryTrendTitle(summary.recoveryTrend),
                detail: recoveryScore < 50
                    ? "Nächste Woche leichter und ruhiger planen."
                    : "Belastung nächste Woche dosiert halten.",
                color: "red"
            ))
        }

        if let pp = summary.pushPullRatio, pp.push > 0.63 {
            areas.append(ReviewHighlight(
                icon: "arrow.left.arrow.right",
                title: "Push dominiert",
                detail: "Push:Pull \(Int(pp.push * 100)):\(Int(pp.pull * 100)). Etwas mehr Pull einplanen.",
                color: "orange"
            ))
        } else if let pp = summary.pushPullRatio, pp.pull > 0.63 {
            areas.append(ReviewHighlight(
                icon: "arrow.left.arrow.right",
                title: "Pull dominiert",
                detail: "Pull:Push \(Int(pp.pull * 100)):\(Int(pp.push * 100)). Etwas mehr Push einplanen.",
                color: "orange"
            ))
        }

        if summary.previousWeekVolume > 0 {
            let volumeChange = (summary.totalVolume - summary.previousWeekVolume) / summary.previousWeekVolume
            if volumeChange > 0.25 {
                areas.append(ReviewHighlight(
                    icon: "exclamationmark.triangle.fill",
                    title: "Volumen stark gestiegen",
                    detail: "Gesamtvolumen \(Int(volumeChange * 100))% über der Vorwoche. Nächste Woche dosiert halten.",
                    color: "red"
                ))
            } else if volumeChange < -0.2 {
                areas.append(ReviewHighlight(
                    icon: "chart.line.downtrend.xyaxis",
                    title: "Volumen gesunken",
                    detail: "\(Int(abs(volumeChange) * 100))% unter der Vorwoche. Prüfe, ob das geplant war.",
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
                headline: "Erholung braucht Fokus",
                message: "Die Belastung war hoch. Plane die nächste Woche ruhiger.",
                tone: .urgent
            )
        }

        if recoveryScore < 65 && completionRate >= 0.75 {
            return CoachConclusion(
                headline: "Starke Arbeit, Erholung im Blick",
                message: !hasPlannedTarget
                    ? "Volumen ist protokolliert, die Erholung sinkt. Halte die nächste Woche dosiert, bis das Wochenziel klarer ist."
                    : targetDisplay.isOverflow
                    ? "Wochenziel erreicht, zusätzliche Einheiten protokolliert. Die Erholung sinkt - nächste Woche dosiert halten."
                    : "Gute Trainingskonstanz, aber die Erholung sinkt. Nächste Woche Volumen oder Intensität etwas ruhiger halten.",
                tone: .cautious
            )
        }

        if hasPlannedTarget && completionRate >= 1.0 && summary.personalRecordsCount > 0 && recoveryScore >= 65 {
            return CoachConclusion(
                headline: targetDisplay.isOverflow ? "Wochenziel erreicht" : "Sehr starke Woche",
                message: targetDisplay.isOverflow
                    ? "Wochenziel erreicht, \(personalRecordPhrase(summary.personalRecordsCount)) und \(targetDisplay.overflowDetail ?? "zusätzliche Einheiten protokolliert"). Nächste Woche dosiert weiter."
                    : "Alle Einheiten abgeschlossen, \(personalRecordPhrase(summary.personalRecordsCount)). Erholung stabil - gute Basis für die nächste Woche.",
                tone: .positive
            )
        }

        if hasPlannedTarget && completionRate >= 0.75 && hasGoodVolume && recoveryScore >= 65 {
            return CoachConclusion(
                headline: "Solide Woche",
                message: targetDisplay.isOverflow
                    ? "Wochenziel erreicht, zusätzliche Einheiten sind protokolliert. Behalte die Erholung im Blick, bevor du mehr ergänzt."
                    : "Gute Konstanz und solides Volumen. Nächste Woche den Rhythmus halten.",
                tone: .positive
            )
        }

        if hasPlannedTarget && completionRate < 0.5 {
            return CoachConclusion(
                headline: "Rhythmus wieder aufnehmen",
                message: "Diese Woche war leichter als geplant. Nächste Woche zählt zuerst der Einstieg: Einheiten kurz halten, aber abschließen.",
                tone: .encouraging
            )
        }

        return CoachConclusion(
            headline: "Weiter aufbauen",
            message: "Solide Basis mit Luft nach oben. Nächste Woche zählt ein konstanterer Trainingsrhythmus.",
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
                label: "Deload-Woche starten",
                icon: "arrow.down.to.line",
                description: "Volumen und Intensität bewusst reduzieren.",
                isPrimary: true
            ))
        }

        let undertrained = muscleBalance.filter { $0.percentOfAverage < 0.8 }
        if undertrained.count >= 2 || (recoveryScore >= 50 && recoveryScore < 70) {
            actions.append(ReviewAction(
                type: .regenerateWeek,
                label: "Nächste Woche neu planen",
                icon: "arrow.triangle.2.circlepath.circle.fill",
                description: "Woche neu aufbauen, damit Balance und Erholung besser zusammenpassen.",
                isPrimary: recoveryScore >= 50
            ))
        }

        if recoveryScore >= 60 && recoveryScore < 80 && summary.totalVolume > summary.previousWeekVolume * 1.1 {
            actions.append(ReviewAction(
                type: .reduceVolume,
                label: "Volumen senken",
                icon: "minus.circle.fill",
                description: "Nebenübungen etwas reduzieren und Hauptübungen stabil halten."
            ))
        }

        if hasPlannedTarget && completionRate >= 0.75 && recoveryScore >= 65 && undertrained.count < 2 {
            actions.append(ReviewAction(
                type: .keepAsIs,
                label: "Woche beibehalten",
                icon: "checkmark.circle.fill",
                description: targetDisplay.isOverflow
                    ? "Wochenziel erreicht, zusätzliche Einheiten protokolliert. Nächste Woche dosiert weiterführen."
                    : "Aktuelle Struktur beibehalten. Keine Änderung nötig.",
                isPrimary: actions.filter(\.isPrimary).isEmpty
            ))
        }

        if let pp = summary.pushPullRatio, (pp.push > 0.6 || pp.pull > 0.6) || undertrained.count >= 3 {
            actions.append(ReviewAction(
                type: .rebalancePlan,
                label: "Verteilung anpassen",
                icon: "arrow.left.arrow.right",
                description: "Übungsauswahl und Volumen ruhiger zwischen Muskelgruppen verteilen."
            ))
        }

        if hasPlannedTarget && completionRate < 0.5 && summary.plannedWorkouts > 3 {
            actions.append(ReviewAction(
                type: .increaseFrequency,
                label: "Frequenz anpassen",
                icon: "calendar.badge.plus",
                description: "Plan an deine echte Verfügbarkeit anpassen."
            ))
        }

        if actions.isEmpty {
            actions.append(ReviewAction(
                type: .keepAsIs,
                label: "Woche beibehalten",
                icon: "checkmark.circle.fill",
                description: targetDisplay.isOverflow
                    ? "Wochenziel erreicht, zusätzliche Einheiten protokolliert. Nächste Woche stabil halten."
                    : hasPlannedTarget
                    ? "Alles im Rahmen. Aktuelle Struktur beibehalten."
                    : "Wochenziel ist offen. Weiter Einheiten protokollieren, damit der Rückblick klarer wird.",
                isPrimary: true
            ))
        }

        return Array(actions.prefix(4))
    }
}
