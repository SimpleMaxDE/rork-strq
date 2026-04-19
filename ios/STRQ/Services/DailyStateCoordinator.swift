import Foundation

/// Owns daily-state refresh logic — coach response, momentum, and the
/// daily message. State still lives on `AppViewModel` so views keep their
/// reactive bindings.
@MainActor
final class DailyStateCoordinator {
    private unowned let vm: AppViewModel
    private let dailyCoachEngine = DailyCoachEngine()
    private let briefingEngine = DailyBriefingEngine()

    init(vm: AppViewModel) {
        self.vm = vm
    }

    func refresh() {
        let weeklyCompleted = vm.weeklyStats.sessions
        vm.dailyCoachMessage = dailyCoachEngine.dailyCoachMessage(
            readiness: vm.todaysReadiness,
            recoveryScore: vm.recoveryScore,
            streak: vm.streak,
            weeklySessionsCompleted: weeklyCompleted,
            weeklySessionsPlanned: vm.profile.daysPerWeek,
            phase: vm.currentPhase,
            hasWorkoutToday: vm.todaysWorkout != nil
        )
        refreshMomentum()
        refreshBriefing()
    }

    func makeCoachResponse(for readiness: DailyReadiness) -> ReadinessCoachResponse {
        dailyCoachEngine.generateCoachResponse(
            readiness: readiness,
            recoveryScore: vm.recoveryScore,
            todaysWorkout: vm.todaysWorkout,
            recentSessions: vm.workoutHistory,
            phase: vm.currentPhase
        )
    }

    private func refreshMomentum() {
        let weeklyCompleted = vm.weeklyStats.sessions
        let planned = vm.profile.daysPerWeek
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        let daysIntoWeek = max(1, weekday - 1)
        let expectedByNow = (planned * daysIntoWeek) / 7

        let pace: WeeklyPace = {
            if weeklyCompleted == 0 { return .missed }
            if weeklyCompleted >= planned { return .ahead }
            if weeklyCompleted >= expectedByNow { return .onTrack }
            return .behind
        }()

        let fourWeeksAgo = calendar.date(byAdding: .day, value: -28, to: Date()) ?? Date()
        let monthSessions = vm.workoutHistory.filter { $0.startTime > fourWeeksAgo && $0.isCompleted }.count
        let possibleSessions = planned * 4
        let consistency = possibleSessions > 0 ? min(100, (monthSessions * 100) / possibleSessions) : 0

        var recentWins: [String] = []
        let recentPRs = vm.personalRecords.filter { $0.date > (calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()) }
        if !recentPRs.isEmpty {
            recentWins.append("\(recentPRs.count) new PR\(recentPRs.count == 1 ? "" : "s") this week")
        }
        if weeklyCompleted >= planned {
            recentWins.append("Weekly target completed")
        }
        if vm.streak >= 7 {
            recentWins.append("\(vm.streak)-day streak")
        }
        let progressing = vm.progressionStates.filter { $0.plateauStatus == .progressing }.count
        if progressing >= 3 {
            recentWins.append("\(progressing) exercises progressing")
        }

        vm.momentumData = MomentumData(
            currentStreak: vm.streak,
            longestStreak: max(vm.streak, 14),
            weeklyPace: pace,
            weeklySessionsCompleted: weeklyCompleted,
            weeklySessionsPlanned: planned,
            consistencyPercent: consistency,
            recentWins: recentWins
        )
    }

    private func refreshBriefing() {
        let calendar = Calendar.current
        let now = Date()

        let lastCompleted = vm.workoutHistory.first(where: \.isCompleted)
        let lastHoursAgo: Int? = lastCompleted.map {
            max(0, Int(now.timeIntervalSince($0.startTime) / 3600))
        }

        var verdictEyebrow: String? = nil
        var verdictSummary: String? = nil
        if let session = lastCompleted, let hours = lastHoursAgo, hours <= 36 {
            let result = WorkoutHighlightBuilder.buildResult(
                session: session,
                history: vm.workoutHistory,
                streak: vm.streak,
                exerciseName: { id in vm.library.exercise(byId: id)?.name ?? "Exercise" }
            )
            verdictEyebrow = result.verdict.eyebrow
            verdictSummary = result.verdict.summary
        }

        let nextDate = vm.nextScheduledWorkoutDate
        let nextInDays: Int? = nextDate.map {
            let start = calendar.startOfDay(for: now)
            let target = calendar.startOfDay(for: $0)
            return max(0, calendar.dateComponents([.day], from: start, to: target).day ?? 0)
        }

        // When nutrition/physique tracking is off, never surface a weight-log
        // prompt — missing logs must not create negative signal.
        let missingWeight: Int = {
            guard vm.profile.nutritionTrackingEnabled else { return 0 }
            guard let last = vm.bodyWeightEntries.first?.date else { return 99 }
            return calendar.dateComponents([.day], from: last, to: now).day ?? 0
        }()
        let missingSleep: Int = {
            guard let last = vm.sleepEntries.first?.date else { return 99 }
            return calendar.dateComponents([.day], from: last, to: now).day ?? 0
        }()

        let topInsight = vm.highPriorityInsights.first
        let topMomentum = vm.positiveInsights.first

        let input = DailyBriefingInput(
            hasPlan: vm.currentPlan != nil,
            hasCompletedOnboarding: vm.hasCompletedOnboarding,
            hasActiveWorkout: vm.activeWorkout != nil,
            todaysWorkoutName: vm.todaysWorkout?.name,
            todaysFocus: vm.todaysWorkout?.focusMuscles.prefix(2).map(\.displayName).joined(separator: " & "),
            nextWorkoutName: vm.nextWorkout?.name,
            nextWorkoutInDays: nextInDays,
            hasCheckedInToday: vm.hasCheckedInToday,
            painOrRestriction: vm.todaysReadiness?.painOrRestriction ?? false,
            readinessScore: vm.todaysReadiness?.readinessScore ?? 0,
            effectiveRecoveryScore: vm.effectiveRecoveryScore,
            streak: vm.streak,
            weeklyCompleted: vm.weeklyStats.sessions,
            weeklyPlanned: max(1, vm.profile.daysPerWeek),
            lastCompletedSessionName: lastCompleted?.dayName,
            lastCompletedHoursAgo: lastHoursAgo,
            lastSessionVerdictEyebrow: verdictEyebrow,
            lastSessionVerdictSummary: verdictSummary,
            topInsightTitle: topInsight?.title,
            topInsightMessage: topInsight?.message,
            topInsightIcon: topInsight?.icon,
            topInsightColor: topInsight?.color,
            topMomentumTitle: topMomentum?.title,
            topMomentumIcon: topMomentum?.icon,
            missingWeightDays: missingWeight,
            missingSleepDays: missingSleep,
            totalInsightsCount: vm.insights.count,
            totalRecommendationsCount: vm.recommendations.count,
            hour: calendar.component(.hour, from: now),
            isEarlyStage: vm.isEarlyStage
        )
        vm.dailyBriefing = briefingEngine.build(input)
    }
}
