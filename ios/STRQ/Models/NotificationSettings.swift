import Foundation

nonisolated struct NotificationSettings: Codable, Sendable {
    var workoutRemindersEnabled: Bool
    var readinessCheckInEnabled: Bool
    var weeklyReviewEnabled: Bool
    var coachNudgesEnabled: Bool
    var streakReminderEnabled: Bool
    var healthKitSyncEnabled: Bool

    var workoutReminderTime: Date
    var readinessCheckInTime: Date
    var weeklyReviewDay: Int

    init(
        workoutRemindersEnabled: Bool = true,
        readinessCheckInEnabled: Bool = true,
        weeklyReviewEnabled: Bool = true,
        coachNudgesEnabled: Bool = true,
        streakReminderEnabled: Bool = true,
        healthKitSyncEnabled: Bool = false,
        workoutReminderTime: Date = Calendar.current.date(from: DateComponents(hour: 17, minute: 0)) ?? Date(),
        readinessCheckInTime: Date = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date(),
        weeklyReviewDay: Int = 1
    ) {
        self.workoutRemindersEnabled = workoutRemindersEnabled
        self.readinessCheckInEnabled = readinessCheckInEnabled
        self.weeklyReviewEnabled = weeklyReviewEnabled
        self.coachNudgesEnabled = coachNudgesEnabled
        self.streakReminderEnabled = streakReminderEnabled
        self.healthKitSyncEnabled = healthKitSyncEnabled
        self.workoutReminderTime = workoutReminderTime
        self.readinessCheckInTime = readinessCheckInTime
        self.weeklyReviewDay = weeklyReviewDay
    }
}
