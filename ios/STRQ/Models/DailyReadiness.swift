import Foundation

nonisolated enum ReadinessLevel: Int, Codable, Sendable, CaseIterable, Identifiable {
    case terrible = 1
    case poor = 2
    case okay = 3
    case good = 4
    case great = 5

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .terrible: "Terrible"
        case .poor: "Poor"
        case .okay: "Okay"
        case .good: "Good"
        case .great: "Great"
        }
    }

    var emoji: String {
        switch self {
        case .terrible: "😩"
        case .poor: "😔"
        case .okay: "😐"
        case .good: "😊"
        case .great: "🔥"
        }
    }

    var colorName: String {
        switch self {
        case .terrible: "red"
        case .poor: "orange"
        case .okay: "yellow"
        case .good: "green"
        case .great: "mint"
        }
    }
}

nonisolated enum SorenessLevel: Int, Codable, Sendable, CaseIterable, Identifiable {
    case none = 0
    case mild = 1
    case moderate = 2
    case significant = 3
    case severe = 4

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .none: "None"
        case .mild: "Mild"
        case .moderate: "Moderate"
        case .significant: "Significant"
        case .severe: "Severe"
        }
    }
}

nonisolated enum DailyMotivation: Int, Codable, Sendable, CaseIterable, Identifiable {
    case veryLow = 1
    case low = 2
    case neutral = 3
    case high = 4
    case veryHigh = 5

    var id: Int { rawValue }

    var label: String {
        switch self {
        case .veryLow: "Very Low"
        case .low: "Low"
        case .neutral: "Neutral"
        case .high: "High"
        case .veryHigh: "Fired Up"
        }
    }
}

nonisolated struct DailyReadiness: Codable, Identifiable, Sendable {
    let id: String
    let date: Date
    var sleepQuality: ReadinessLevel
    var energyLevel: ReadinessLevel
    var stressLevel: ReadinessLevel
    var soreness: SorenessLevel
    var motivation: DailyMotivation
    var painOrRestriction: Bool
    var painNote: String

    init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        sleepQuality: ReadinessLevel = .good,
        energyLevel: ReadinessLevel = .good,
        stressLevel: ReadinessLevel = .okay,
        soreness: SorenessLevel = .mild,
        motivation: DailyMotivation = .high,
        painOrRestriction: Bool = false,
        painNote: String = ""
    ) {
        self.id = id
        self.date = date
        self.sleepQuality = sleepQuality
        self.energyLevel = energyLevel
        self.stressLevel = stressLevel
        self.soreness = soreness
        self.motivation = motivation
        self.painOrRestriction = painOrRestriction
        self.painNote = painNote
    }

    var readinessScore: Int {
        let sleepW = Double(sleepQuality.rawValue) * 0.3
        let energyW = Double(energyLevel.rawValue) * 0.25
        let stressW = Double(6 - stressLevel.rawValue) * 0.2
        let sorenessW = Double(4 - min(soreness.rawValue, 4)) * 0.15
        let motivationW = Double(motivation.rawValue) * 0.1
        let raw = (sleepW + energyW + stressW + sorenessW + motivationW) / 5.0
        return min(100, max(0, Int(raw * 20)))
    }

    var readinessLabel: String {
        switch readinessScore {
        case 85...: return "Peak Readiness"
        case 70..<85: return "Well Prepared"
        case 55..<70: return "Moderate"
        case 40..<55: return "Low Readiness"
        default: return "Rest Recommended"
        }
    }

    var readinessColorName: String {
        switch readinessScore {
        case 85...: return "mint"
        case 70..<85: return "green"
        case 55..<70: return "yellow"
        case 40..<55: return "orange"
        default: return "red"
        }
    }
}

nonisolated struct ReadinessCoachResponse: Sendable {
    let headline: String
    let message: String
    let icon: String
    let colorName: String
    let trainingAdvice: TrainingAdvice
    let adjustments: [String]

    init(headline: String, message: String, icon: String, colorName: String, trainingAdvice: TrainingAdvice, adjustments: [String] = []) {
        self.headline = headline
        self.message = message
        self.icon = icon
        self.colorName = colorName
        self.trainingAdvice = trainingAdvice
        self.adjustments = adjustments
    }
}

nonisolated enum TrainingAdvice: String, Sendable {
    case trainAsPlanned
    case trainButLighter
    case shortenSession
    case reduceAccessories
    case useSaferVariations
    case restDay
    case pushHard

    var label: String {
        switch self {
        case .trainAsPlanned: "Train as Planned"
        case .trainButLighter: "Go Lighter Today"
        case .shortenSession: "Shorten Session"
        case .reduceAccessories: "Reduce Accessories"
        case .useSaferVariations: "Use Safer Variations"
        case .restDay: "Rest Day Recommended"
        case .pushHard: "Good Day to Push"
        }
    }

    var icon: String {
        switch self {
        case .trainAsPlanned: "checkmark.circle.fill"
        case .trainButLighter: "arrow.down.circle.fill"
        case .shortenSession: "clock.arrow.circlepath"
        case .reduceAccessories: "minus.circle.fill"
        case .useSaferVariations: "shield.checkered"
        case .restDay: "bed.double.fill"
        case .pushHard: "bolt.fill"
        }
    }
}
