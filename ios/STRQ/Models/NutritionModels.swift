import Foundation

nonisolated enum NutritionGoal: String, Codable, CaseIterable, Identifiable, Sendable {
    case leanBulk
    case muscleGain
    case maintenance
    case fatLoss
    case aggressiveCut
    case recomp

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .leanBulk: "Lean Bulk"
        case .muscleGain: "Muscle Gain"
        case .maintenance: "Maintenance"
        case .fatLoss: "Fat Loss"
        case .aggressiveCut: "Aggressive Cut"
        case .recomp: "Body Recomposition"
        }
    }

    var surplusRange: String {
        switch self {
        case .leanBulk: "+200–300 kcal"
        case .muscleGain: "+300–500 kcal"
        case .maintenance: "±0 kcal"
        case .fatLoss: "−300–500 kcal"
        case .aggressiveCut: "−500–750 kcal"
        case .recomp: "±0 to slight deficit"
        }
    }

    var icon: String {
        switch self {
        case .leanBulk: "arrow.up.right"
        case .muscleGain: "arrow.up"
        case .maintenance: "equal"
        case .fatLoss: "arrow.down.right"
        case .aggressiveCut: "arrow.down"
        case .recomp: "arrow.left.arrow.right"
        }
    }

    var colorName: String {
        switch self {
        case .leanBulk, .muscleGain: "green"
        case .maintenance, .recomp: "blue"
        case .fatLoss, .aggressiveCut: "orange"
        }
    }
}

nonisolated enum WeightGoalDirection: String, Codable, CaseIterable, Identifiable, Sendable {
    case gaining
    case maintaining
    case losing

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gaining: "Gaining"
        case .maintaining: "Maintaining"
        case .losing: "Losing"
        }
    }
}

nonisolated struct NutritionTarget: Codable, Sendable {
    var calories: Int
    var proteinGrams: Int
    var carbsGrams: Int?
    var fatGrams: Int?
    var nutritionGoal: NutritionGoal
    var weightGoalDirection: WeightGoalDirection
    var targetWeeklyChangeKg: Double

    init(
        calories: Int = 2500,
        proteinGrams: Int = 160,
        carbsGrams: Int? = 280,
        fatGrams: Int? = 80,
        nutritionGoal: NutritionGoal = .leanBulk,
        weightGoalDirection: WeightGoalDirection = .gaining,
        targetWeeklyChangeKg: Double = 0.25
    ) {
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
        self.nutritionGoal = nutritionGoal
        self.weightGoalDirection = weightGoalDirection
        self.targetWeeklyChangeKg = targetWeeklyChangeKg
    }
}

nonisolated struct DailyNutritionLog: Codable, Identifiable, Sendable {
    let id: String
    let date: Date
    var calories: Int
    var proteinGrams: Int
    var carbsGrams: Int
    var fatGrams: Int
    var waterLiters: Double

    init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        calories: Int = 0,
        proteinGrams: Int = 0,
        carbsGrams: Int = 0,
        fatGrams: Int = 0,
        waterLiters: Double = 0
    ) {
        self.id = id
        self.date = date
        self.calories = calories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
        self.waterLiters = waterLiters
    }
}

nonisolated struct BodyWeightEntry: Codable, Identifiable, Sendable {
    let id: String
    let date: Date
    var weightKg: Double
    var bodyFatPercent: Double?
    var note: String

    init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        weightKg: Double,
        bodyFatPercent: Double? = nil,
        note: String = ""
    ) {
        self.id = id
        self.date = date
        self.weightKg = weightKg
        self.bodyFatPercent = bodyFatPercent
        self.note = note
    }
}

nonisolated struct SleepEntry: Codable, Identifiable, Sendable {
    let id: String
    let date: Date
    var hoursSlept: Double
    var quality: ReadinessLevel

    init(
        id: String = UUID().uuidString,
        date: Date = Date(),
        hoursSlept: Double = 7,
        quality: ReadinessLevel = .good
    ) {
        self.id = id
        self.date = date
        self.hoursSlept = hoursSlept
        self.quality = quality
    }
}

nonisolated struct NutritionCoachInsight: Identifiable, Sendable {
    let id: String
    let icon: String
    let colorName: String
    let title: String
    let message: String
    let category: NutritionInsightCategory

    init(
        id: String = UUID().uuidString,
        icon: String,
        colorName: String,
        title: String,
        message: String,
        category: NutritionInsightCategory = .general
    ) {
        self.id = id
        self.icon = icon
        self.colorName = colorName
        self.title = title
        self.message = message
        self.category = category
    }
}

nonisolated enum NutritionInsightCategory: String, Sendable {
    case protein
    case calories
    case goalPace
    case recovery
    case sleep
    case hydration
    case general
}

nonisolated struct GoalPaceStatus: Sendable {
    let headline: String
    let detail: String
    let icon: String
    let colorName: String
    let weeklyChangeKg: Double
    let targetChangeKg: Double
    let isOnTrack: Bool
}
