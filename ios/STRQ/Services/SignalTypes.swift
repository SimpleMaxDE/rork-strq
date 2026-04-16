import Foundation

nonisolated enum InsightSeverity: String, Sendable, Comparable {
    case positive
    case low
    case medium
    case high

    var rank: Int {
        switch self {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        case .positive: return 0
        }
    }

    static func < (lhs: InsightSeverity, rhs: InsightSeverity) -> Bool {
        lhs.rank < rhs.rank
    }
}

nonisolated enum InsightCategory: String, Sendable {
    case volumeBalance
    case movementBalance
    case recovery
    case consistency
    case progression
    case bodyComposition
    case general

    var displayName: String {
        switch self {
        case .volumeBalance: return "Volume Balance"
        case .movementBalance: return "Movement Balance"
        case .recovery: return "Recovery"
        case .consistency: return "Consistency"
        case .progression: return "Progression"
        case .bodyComposition: return "Body Composition"
        case .general: return "General"
        }
    }

    var symbolName: String {
        switch self {
        case .volumeBalance: return "chart.bar.fill"
        case .movementBalance: return "arrow.left.arrow.right"
        case .recovery: return "heart.fill"
        case .consistency: return "calendar.badge.checkmark"
        case .progression: return "arrow.up.right"
        case .bodyComposition: return "figure.stand"
        case .general: return "lightbulb.fill"
        }
    }
}

nonisolated struct SmartInsight: Identifiable, Sendable {
    let id: String
    let icon: String
    let color: String
    let title: String
    let message: String
    let severity: InsightSeverity
    let category: InsightCategory

    var severityRank: Int { severity.rank }

    init(id: String = UUID().uuidString, icon: String, color: String, title: String, message: String, severity: InsightSeverity = .low, category: InsightCategory = .general) {
        self.id = id
        self.icon = icon
        self.color = color
        self.title = title
        self.message = message
        self.severity = severity
        self.category = category
    }
}

nonisolated struct DayActivity: Identifiable, Sendable {
    let id: String
    let label: String
    let date: Date
    let didTrain: Bool
    let volume: Double
    let duration: Int

    init(id: String = UUID().uuidString, label: String, date: Date, didTrain: Bool, volume: Double, duration: Int) {
        self.id = id
        self.label = label
        self.date = date
        self.didTrain = didTrain
        self.volume = volume
        self.duration = duration
    }
}

nonisolated struct MuscleBalanceEntry: Identifiable, Sendable {
    let id: String
    let muscle: String
    let thisWeek: Double
    let average: Double

    init(id: String = UUID().uuidString, muscle: String, thisWeek: Double, average: Double) {
        self.id = id
        self.muscle = muscle
        self.thisWeek = thisWeek
        self.average = average
    }

    var percentOfAverage: Double {
        guard average > 0 else { return 0 }
        return thisWeek / average
    }
}

nonisolated struct StrengthEntry: Identifiable, Sendable {
    let id: String
    let date: Date
    let bench: Double
    let squat: Double
    let deadlift: Double
    let ohp: Double

    init(id: String = UUID().uuidString, date: Date, bench: Double, squat: Double, deadlift: Double, ohp: Double) {
        self.id = id
        self.date = date
        self.bench = bench
        self.squat = squat
        self.deadlift = deadlift
        self.ohp = ohp
    }
}
