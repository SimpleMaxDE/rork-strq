import Foundation
import UserNotifications

@MainActor
final class NotificationScheduler {
    static let shared = NotificationScheduler()

    private let center = UNUserNotificationCenter.current()
    private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    // Identifier prefixes so we can rebuild each batch cleanly.
    private enum Category {
        static let workout = "strq.workout"
        static let readiness = "strq.readiness"
        static let weeklyReview = "strq.weekly_review"
        static let streak = "strq.streak"
        static let logging = "strq.logging"
        static let coach = "strq.coach"
    }

    private init() {}

    // MARK: - Permission

    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        self.authorizationStatus = settings.authorizationStatus
    }

    @discardableResult
    func requestAuthorizationIfNeeded() async -> Bool {
        await refreshAuthorizationStatus()
        switch authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                await refreshAuthorizationStatus()
                return granted
            } catch {
                ErrorReporter.shared.report(error)
                return false
            }
        case .authorized, .provisional, .ephemeral:
            return true
        default:
            return false
        }
    }

    // MARK: - Public API

    struct ScheduleInput {
        let settings: NotificationSettings
        let todaysWorkoutName: String?
        let todaysFocus: String?
        let nextScheduledDate: Date?
        let nextScheduledWorkoutName: String?
        let hasCheckedInToday: Bool
        let isWeeklyReviewReady: Bool
        let streak: Int
        let completedWorkoutsTotal: Int
        let isEarlyStage: Bool
        let isRestDay: Bool
        let lastActiveDate: Date?
        let missingBodyWeightDays: Int
        let missingSleepDays: Int
        let readinessBucket: String
        let weeklyReviewDay: Int
    }

    func reschedule(with input: ScheduleInput) async {
        await refreshAuthorizationStatus()
        guard authorizationStatus == .authorized || authorizationStatus == .provisional || authorizationStatus == .ephemeral else {
            await cancelAll()
            return
        }

        await cancelAll()

        let settings = input.settings
        if settings.workoutRemindersEnabled {
            scheduleWorkoutReminder(input: input)
        }
        if settings.readinessCheckInEnabled {
            scheduleReadinessCheckIn(input: input)
        }
        if settings.weeklyReviewEnabled {
            scheduleWeeklyReview(input: input)
        }
        if settings.streakReminderEnabled {
            scheduleStreakReminder(input: input)
        }
        if settings.coachNudgesEnabled {
            scheduleLoggingNudges(input: input)
            scheduleInactivityNudge(input: input)
        }
    }

    func cancelAll() async {
        let pending = await center.pendingNotificationRequests()
        let ids = pending.map(\.identifier).filter { $0.hasPrefix("strq.") }
        center.removePendingNotificationRequests(withIdentifiers: ids)
    }

    // MARK: - Scheduling

    private func scheduleWorkoutReminder(input: ScheduleInput) {
        let calendar = Calendar.current
        let settings = input.settings
        let reminderComponents = calendar.dateComponents([.hour, .minute], from: settings.workoutReminderTime)

        // Today's scheduled workout — only if we haven't passed the reminder time and today isn't a rest day.
        if let workoutName = input.todaysWorkoutName, !input.isRestDay {
            let now = Date()
            if let todaysReminder = calendar.nextDate(
                after: calendar.startOfDay(for: now),
                matching: reminderComponents,
                matchingPolicy: .nextTime
            ), todaysReminder > now, calendar.isDateInToday(todaysReminder) {
                let content = UNMutableNotificationContent()
                content.title = input.isEarlyStage ? "Your session is ready" : "Today: \(workoutName)"
                content.body = buildWorkoutBody(input: input, workoutName: workoutName)
                content.sound = .default

                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: todaysReminder),
                    repeats: false
                )
                add(id: "\(Category.workout).today", content: content, trigger: trigger)
            }
        }

        // Next scheduled session (if different day from today).
        if let nextDate = input.nextScheduledDate,
           let nextName = input.nextScheduledWorkoutName,
           !calendar.isDateInToday(nextDate) {
            var comps = calendar.dateComponents([.year, .month, .day], from: nextDate)
            comps.hour = reminderComponents.hour
            comps.minute = reminderComponents.minute

            guard let fireDate = calendar.date(from: comps), fireDate > Date() else { return }

            let content = UNMutableNotificationContent()
            content.title = "Tomorrow: \(nextName)"
            content.body = input.isEarlyStage
                ? "Your next session keeps your baseline honest. Small wins compound."
                : "Get ready for \(nextName). Sleep and fuel set the tone."
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
            add(id: "\(Category.workout).next", content: content, trigger: trigger)
        }
    }

    private func buildWorkoutBody(input: ScheduleInput, workoutName: String) -> String {
        if input.isEarlyStage {
            return "Your first session sets your baseline. Keep it simple today."
        }
        switch input.readinessBucket {
        case "peak", "high":
            if let focus = input.todaysFocus {
                return "Recovery is aligned — \(focus.lowercased()) day. Push clean reps."
            }
            return "Recovery and progression are aligned. Time to train."
        case "low", "very_low":
            return "Readiness is lower today. Stay honest — quality over load."
        default:
            if let focus = input.todaysFocus {
                return "\(focus) today. \(workoutName) is queued up."
            }
            return "\(workoutName) is queued up."
        }
    }

    private func scheduleReadinessCheckIn(input: ScheduleInput) {
        guard !input.hasCheckedInToday else { return }
        // Only if there's a real workout today — no need to pester on rest days.
        guard input.todaysWorkoutName != nil, !input.isRestDay else { return }

        let calendar = Calendar.current
        let timeComps = calendar.dateComponents([.hour, .minute], from: input.settings.readinessCheckInTime)
        guard let fireDate = calendar.nextDate(
            after: Date(),
            matching: timeComps,
            matchingPolicy: .nextTime
        ), calendar.isDateInToday(fireDate) else { return }

        let content = UNMutableNotificationContent()
        content.title = "Morning check-in"
        content.body = input.isEarlyStage
            ? "Tell STRQ how today feels. It calibrates everything."
            : "How's your body today? 30 seconds sharpens today's session."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate),
            repeats: false
        )
        add(id: "\(Category.readiness).today", content: content, trigger: trigger)
    }

    private func scheduleWeeklyReview(input: ScheduleInput) {
        // Only schedule if the user has enough signal to make a review meaningful.
        guard input.completedWorkoutsTotal >= 3 else { return }

        let calendar = Calendar.current
        let weekdayTarget = (input.weeklyReviewDay % 7) + 1 // weekdayDay 0..6 (Sun..Sat) -> 1..7
        var comps = DateComponents()
        comps.weekday = weekdayTarget
        comps.hour = 9
        comps.minute = 0

        guard let fireDate = calendar.nextDate(
            after: Date(),
            matching: comps,
            matchingPolicy: .nextTime
        ) else { return }

        let content = UNMutableNotificationContent()
        content.title = "Weekly review ready"
        content.body = input.isWeeklyReviewReady
            ? "Your week is in. See what moved — and what's next."
            : "Close the week with a clear-eyed review."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute, .weekday], from: fireDate),
            repeats: false
        )
        add(id: "\(Category.weeklyReview).next", content: content, trigger: trigger)
    }

    private func scheduleStreakReminder(input: ScheduleInput) {
        // Only relevant once a streak exists.
        guard input.streak >= 3 else { return }
        guard let last = input.lastActiveDate else { return }

        let calendar = Calendar.current
        // Fire at 7pm the day after last activity if they still haven't done anything.
        guard let targetDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: last)) else { return }
        var comps = calendar.dateComponents([.year, .month, .day], from: targetDay)
        comps.hour = 19
        comps.minute = 30

        guard let fireDate = calendar.date(from: comps), fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Keep your \(input.streak)-day streak"
        content.body = "A check-in or a short session is enough to hold the line."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate),
            repeats: false
        )
        add(id: "\(Category.streak).risk", content: content, trigger: trigger)
    }

    private func scheduleLoggingNudges(input: ScheduleInput) {
        // Established users only — keeps early experience calm.
        guard !input.isEarlyStage else { return }

        let calendar = Calendar.current

        if input.missingBodyWeightDays >= 7 {
            var comps = DateComponents()
            comps.hour = 8
            comps.minute = 15
            if let fireDate = calendar.nextDate(after: Date(), matching: comps, matchingPolicy: .nextTime) {
                let content = UNMutableNotificationContent()
                content.title = "Weekly weigh-in"
                content.body = "A quick log keeps your trend line honest."
                content.sound = .default
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate),
                    repeats: false
                )
                add(id: "\(Category.logging).weight", content: content, trigger: trigger)
            }
        }

        if input.missingSleepDays >= 3 {
            var comps = DateComponents()
            comps.hour = 9
            comps.minute = 30
            if let fireDate = calendar.nextDate(after: Date(), matching: comps, matchingPolicy: .nextTime) {
                let content = UNMutableNotificationContent()
                content.title = "Log last night's sleep"
                content.body = "Sleep is half of recovery. Takes a second."
                content.sound = .default
                let trigger = UNCalendarNotificationTrigger(
                    dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate),
                    repeats: false
                )
                add(id: "\(Category.logging).sleep", content: content, trigger: trigger)
            }
        }
    }

    private func scheduleInactivityNudge(input: ScheduleInput) {
        guard input.completedWorkoutsTotal >= 1 else { return }
        guard let last = input.lastActiveDate else { return }

        let calendar = Calendar.current
        let daysSince = calendar.dateComponents([.day], from: last, to: Date()).day ?? 0
        // Schedule a come-back nudge 4 days after last activity, only if we're approaching that.
        guard daysSince < 4 else { return }

        guard let targetDay = calendar.date(byAdding: .day, value: 4, to: calendar.startOfDay(for: last)) else { return }
        var comps = calendar.dateComponents([.year, .month, .day], from: targetDay)
        comps.hour = 18
        comps.minute = 0
        guard let fireDate = calendar.date(from: comps), fireDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Back when you're ready"
        content.body = input.isEarlyStage
            ? "A single clean session rebuilds momentum."
            : "One session back keeps your plan honest. No pressure."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate),
            repeats: false
        )
        add(id: "\(Category.coach).return", content: content, trigger: trigger)
    }

    // MARK: - Helpers

    private func add(id: String, content: UNMutableNotificationContent, trigger: UNNotificationTrigger) {
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        center.add(request) { error in
            if let error {
                ErrorReporter.shared.report(error)
            }
        }
    }
}
