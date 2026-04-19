import Foundation

/// Owns smart-reminder scheduling and widget-snapshot publishing.
/// Keeps the reminder signature cache and widget payload construction out
/// of `AppViewModel`.
@MainActor
final class ReminderWidgetCoordinator {
    private unowned let vm: AppViewModel
    private var lastScheduledSignature: String = ""

    init(vm: AppViewModel) {
        self.vm = vm
    }

    // MARK: - Widgets

    func refreshWidgetSnapshot() {
        let today = vm.todaysWorkout
        let isRestDay = today == nil
        let focus = today?.focusMuscles.prefix(2).map(\.displayName).joined(separator: " & ")
        let planned = max(1, vm.profile.daysPerWeek)
        let weeklyCompleted = vm.weeklyStats.sessions
        let nextTitle: String = {
            if let action = vm.nextBestAction { return action.title }
            if isRestDay { return "Recovery day" }
            return "Ready to train"
        }()
        let snapshot = WidgetBridge.Snapshot(
            todayWorkoutName: today?.name,
            todayFocus: focus,
            isRestDay: isRestDay,
            hasCheckedIn: vm.hasCheckedInToday,
            readinessScore: vm.effectiveRecoveryScore,
            readinessLabel: vm.readinessBasedRecoveryStatus,
            nextActionTitle: nextTitle,
            streak: vm.streak,
            weeklyCompleted: weeklyCompleted,
            weeklyTarget: planned,
            updatedAt: Date()
        )
        WidgetBridge.write(snapshot)
    }

    // MARK: - Reminders

    func scheduleIfNeeded(force: Bool = false) {
        guard vm.hasCompletedOnboarding else { return }
        let input = buildReminderInput()
        let signature = reminderSignature(input)
        if !force && signature == lastScheduledSignature { return }
        lastScheduledSignature = signature
        Task { await NotificationScheduler.shared.reschedule(with: input) }
    }

    private func buildReminderInput() -> NotificationScheduler.ScheduleInput {
        let calendar = Calendar.current
        let today = vm.todaysWorkout
        let next = vm.nextWorkout
        let nextDate = vm.nextScheduledWorkoutDate
        let lastWorkout = vm.workoutHistory.first(where: \.isCompleted)?.startTime
        let lastReadiness = vm.readinessHistory.first?.date
        let lastActive: Date? = [lastWorkout, lastReadiness].compactMap { $0 }.max()
        // Only nudge body-weight logging if the user opted into tracking.
        let missingWeightDays: Int = {
            guard vm.profile.nutritionTrackingEnabled else { return 0 }
            guard let last = vm.bodyWeightEntries.first?.date else { return 99 }
            return calendar.dateComponents([.day], from: last, to: Date()).day ?? 0
        }()
        let missingSleepDays: Int = {
            guard let last = vm.sleepEntries.first?.date else { return 99 }
            return calendar.dateComponents([.day], from: last, to: Date()).day ?? 0
        }()
        let totalCompleted = vm.totalCompletedWorkouts
        let isEarlyStage = totalCompleted < 4
        let isRestDay = today == nil

        return NotificationScheduler.ScheduleInput(
            settings: vm.notificationSettings,
            todaysWorkoutName: today?.name,
            todaysFocus: today?.focusMuscles.prefix(2).map(\.displayName).joined(separator: " & "),
            nextScheduledDate: nextDate,
            nextScheduledWorkoutName: next?.name,
            hasCheckedInToday: vm.hasCheckedInToday,
            isWeeklyReviewReady: vm.isWeeklyReviewReady,
            streak: vm.streak,
            completedWorkoutsTotal: totalCompleted,
            isEarlyStage: isEarlyStage,
            isRestDay: isRestDay,
            lastActiveDate: lastActive,
            missingBodyWeightDays: missingWeightDays,
            missingSleepDays: missingSleepDays,
            readinessBucket: vm.readinessBucket,
            weeklyReviewDay: vm.notificationSettings.weeklyReviewDay
        )
    }

    private func reminderSignature(_ input: NotificationScheduler.ScheduleInput) -> String {
        let s = input.settings
        let df = ISO8601DateFormatter()
        df.formatOptions = [.withFullDate]
        let today = df.string(from: Date())
        return [
            today,
            s.workoutRemindersEnabled ? "1" : "0",
            s.readinessCheckInEnabled ? "1" : "0",
            s.weeklyReviewEnabled ? "1" : "0",
            s.coachNudgesEnabled ? "1" : "0",
            s.streakReminderEnabled ? "1" : "0",
            String(Int(s.workoutReminderTime.timeIntervalSinceReferenceDate / 60).description.hashValue),
            String(Int(s.readinessCheckInTime.timeIntervalSinceReferenceDate / 60).description.hashValue),
            String(s.weeklyReviewDay),
            input.todaysWorkoutName ?? "-",
            input.nextScheduledWorkoutName ?? "-",
            input.nextScheduledDate.map { df.string(from: $0) } ?? "-",
            input.hasCheckedInToday ? "1" : "0",
            String(input.streak),
            String(input.completedWorkoutsTotal),
            input.isWeeklyReviewReady ? "1" : "0",
            input.readinessBucket,
            String(input.missingBodyWeightDays),
            String(input.missingSleepDays)
        ].joined(separator: "|")
    }
}
