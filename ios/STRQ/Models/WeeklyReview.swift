import Foundation

nonisolated struct WeeklyReview: Identifiable, Sendable {
    let id: String
    let weekStartDate: Date
    let weekEndDate: Date
    let summary: WeekSummary
    let wins: [ReviewHighlight]
    let areasToImprove: [ReviewHighlight]
    let coachConclusion: CoachConclusion
    let suggestedActions: [ReviewAction]

    init(
        id: String = UUID().uuidString,
        weekStartDate: Date,
        weekEndDate: Date,
        summary: WeekSummary,
        wins: [ReviewHighlight],
        areasToImprove: [ReviewHighlight],
        coachConclusion: CoachConclusion,
        suggestedActions: [ReviewAction]
    ) {
        self.id = id
        self.weekStartDate = weekStartDate
        self.weekEndDate = weekEndDate
        self.summary = summary
        self.wins = wins
        self.areasToImprove = areasToImprove
        self.coachConclusion = coachConclusion
        self.suggestedActions = suggestedActions
    }
}

nonisolated struct WeekSummary: Sendable {
    let completedWorkouts: Int
    let plannedWorkouts: Int
    let totalVolume: Double
    let previousWeekVolume: Double
    let totalSets: Int
    let totalReps: Int
    let averageDuration: Int
    let recoveryTrend: RecoveryTrend
    let personalRecordsCount: Int
    let streakDays: Int
    let bodyweightChange: Double?
    let muscleBalanceScore: Double
    let pushPullRatio: (push: Double, pull: Double)?
    let upperLowerRatio: (upper: Double, lower: Double)?
}

nonisolated enum RecoveryTrend: Sendable {
    case improving
    case stable
    case declining
    case critical

    var label: String {
        switch self {
        case .improving: return "Improving"
        case .stable: return "Stable"
        case .declining: return "Declining"
        case .critical: return "Low"
        }
    }

    var icon: String {
        switch self {
        case .improving: return "arrow.up.heart.fill"
        case .stable: return "heart.fill"
        case .declining: return "arrow.down.heart.fill"
        case .critical: return "exclamationmark.heart.fill"
        }
    }

    var colorName: String {
        switch self {
        case .improving: return "green"
        case .stable: return "blue"
        case .declining: return "orange"
        case .critical: return "red"
        }
    }
}

nonisolated struct ReviewHighlight: Identifiable, Sendable {
    let id: String
    let icon: String
    let title: String
    let detail: String
    let color: String

    init(id: String = UUID().uuidString, icon: String, title: String, detail: String, color: String) {
        self.id = id
        self.icon = icon
        self.title = title
        self.detail = detail
        self.color = color
    }
}

nonisolated struct CoachConclusion: Sendable {
    let headline: String
    let message: String
    let tone: ConclusionTone
}

nonisolated enum ConclusionTone: Sendable {
    case positive
    case encouraging
    case cautious
    case urgent

    var icon: String {
        switch self {
        case .positive: return "hand.thumbsup.fill"
        case .encouraging: return "bolt.heart.fill"
        case .cautious: return "exclamationmark.triangle.fill"
        case .urgent: return "exclamationmark.octagon.fill"
        }
    }

    var colorName: String {
        switch self {
        case .positive: return "green"
        case .encouraging: return "orange"
        case .cautious: return "yellow"
        case .urgent: return "red"
        }
    }
}

nonisolated enum ReviewActionType: Sendable {
    case keepAsIs
    case regenerateWeek
    case deloadWeek
    case reduceVolume
    case rebalancePlan
    case increaseFrequency
}

nonisolated struct ReviewAction: Identifiable, Sendable {
    let id: String
    let type: ReviewActionType
    let label: String
    let icon: String
    let description: String
    let isPrimary: Bool

    init(id: String = UUID().uuidString, type: ReviewActionType, label: String, icon: String, description: String, isPrimary: Bool = false) {
        self.id = id
        self.type = type
        self.label = label
        self.icon = icon
        self.description = description
        self.isPrimary = isPrimary
    }
}
