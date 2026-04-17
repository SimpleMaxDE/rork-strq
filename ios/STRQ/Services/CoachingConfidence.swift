import Foundation

nonisolated enum CoachingConfidence: Int, Sendable, Comparable {
    case low = 0
    case moderate = 1
    case high = 2

    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

    var label: String {
        switch self {
        case .low: return "Still calibrating"
        case .moderate: return "Building signal"
        case .high: return "Strong signal"
        }
    }

    var hedge: String {
        switch self {
        case .low: return " STRQ is still calibrating — treat this as directional."
        case .moderate: return ""
        case .high: return ""
        }
    }
}

nonisolated struct ConfidenceAssessor: Sendable {
    func assess(
        completedWorkouts: Int,
        readinessCheckIns: Int,
        sleepLogs: Int,
        weeksTrained: Int,
        weightLogs: Int
    ) -> CoachingConfidence {
        var points = 0
        if completedWorkouts >= 8 { points += 3 }
        else if completedWorkouts >= 4 { points += 2 }
        else if completedWorkouts >= 2 { points += 1 }

        if readinessCheckIns >= 5 { points += 2 }
        else if readinessCheckIns >= 2 { points += 1 }

        if sleepLogs >= 4 { points += 1 }
        if weightLogs >= 3 { points += 1 }
        if weeksTrained >= 3 { points += 1 }

        if points >= 5 { return .high }
        if points >= 2 { return .moderate }
        return .low
    }
}
