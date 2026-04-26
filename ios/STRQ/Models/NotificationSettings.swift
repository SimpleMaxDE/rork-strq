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

    enum CodingKeys: String, CodingKey {
        case workoutRemindersEnabled, readinessCheckInEnabled, weeklyReviewEnabled
        case coachNudgesEnabled, streakReminderEnabled, healthKitSyncEnabled
        case workoutReminderTime, readinessCheckInTime, weeklyReviewDay
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let defaults = NotificationSettings()
        self.workoutRemindersEnabled = try c.decodeIfPresent(Bool.self, forKey: .workoutRemindersEnabled) ?? defaults.workoutRemindersEnabled
        self.readinessCheckInEnabled = try c.decodeIfPresent(Bool.self, forKey: .readinessCheckInEnabled) ?? defaults.readinessCheckInEnabled
        self.weeklyReviewEnabled = try c.decodeIfPresent(Bool.self, forKey: .weeklyReviewEnabled) ?? defaults.weeklyReviewEnabled
        self.coachNudgesEnabled = try c.decodeIfPresent(Bool.self, forKey: .coachNudgesEnabled) ?? defaults.coachNudgesEnabled
        self.streakReminderEnabled = try c.decodeIfPresent(Bool.self, forKey: .streakReminderEnabled) ?? defaults.streakReminderEnabled
        self.healthKitSyncEnabled = try c.decodeIfPresent(Bool.self, forKey: .healthKitSyncEnabled) ?? defaults.healthKitSyncEnabled
        self.workoutReminderTime = try c.decodeIfPresent(Date.self, forKey: .workoutReminderTime) ?? defaults.workoutReminderTime
        self.readinessCheckInTime = try c.decodeIfPresent(Date.self, forKey: .readinessCheckInTime) ?? defaults.readinessCheckInTime
        self.weeklyReviewDay = try c.decodeIfPresent(Int.self, forKey: .weeklyReviewDay) ?? defaults.weeklyReviewDay
    }
}
