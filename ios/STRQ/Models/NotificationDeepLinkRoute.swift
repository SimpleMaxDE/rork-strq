import Foundation

nonisolated enum NotificationDeepLinkRoute: String, Sendable {
    case resumeWorkout = "resume_workout"
    case readinessCheckIn = "readiness_check_in"
    case sleepLog = "sleep_log"

    static let userInfoKey: String = "deep_link_route"

    init?(requestIdentifier: String, userInfo: [AnyHashable: Any]) {
        if let rawValue = userInfo[Self.userInfoKey] as? String,
           let route = Self(rawValue: rawValue) {
            self = route
            return
        }

        if requestIdentifier.hasPrefix("strq.workout.") || requestIdentifier.hasPrefix("strq.coach.") {
            self = .resumeWorkout
        } else if requestIdentifier.hasPrefix("strq.readiness.") {
            self = .readinessCheckIn
        } else if requestIdentifier == "strq.logging.sleep" {
            self = .sleepLog
        } else {
            return nil
        }
    }

    var userInfo: [AnyHashable: Any] {
        [Self.userInfoKey: rawValue]
    }
}
