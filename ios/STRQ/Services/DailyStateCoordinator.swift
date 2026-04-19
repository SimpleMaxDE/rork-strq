import Foundation

/// Owns daily-state refresh logic — coach response, momentum, and the
/// daily message. State still lives on `AppViewModel` so views keep their
/// reactive bindings.
@MainActor
final class DailyStateCoordinator {
    private unowned let vm: AppViewModel
    private let dailyCoachEngine = DailyCoachEngine()

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
}
