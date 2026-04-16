import Foundation

nonisolated enum FitnessGoal: String, Codable, CaseIterable, Identifiable, Sendable {
    case muscleGain
    case strength
    case fatLoss
    case generalFitness
    case endurance
    case flexibility
    case athleticPerformance
    case rehabilitation

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .muscleGain: "Build Muscle"
        case .strength: "Get Stronger"
        case .fatLoss: "Lose Fat"
        case .generalFitness: "General Fitness"
        case .endurance: "Endurance"
        case .flexibility: "Flexibility"
        case .athleticPerformance: "Athletic Performance"
        case .rehabilitation: "Rehabilitation"
        }
    }

    var symbolName: String {
        switch self {
        case .muscleGain: "figure.strengthtraining.traditional"
        case .strength: "dumbbell.fill"
        case .fatLoss: "flame.fill"
        case .generalFitness: "heart.fill"
        case .endurance: "figure.run"
        case .flexibility: "figure.flexibility"
        case .athleticPerformance: "figure.highintensity.intervaltraining"
        case .rehabilitation: "cross.circle.fill"
        }
    }
}

nonisolated enum TrainingLevel: String, Codable, CaseIterable, Identifiable, Sendable {
    case beginner
    case intermediate
    case advanced

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .beginner: "Beginner (0-1 year)"
        case .intermediate: "Intermediate (1-3 years)"
        case .advanced: "Advanced (3+ years)"
        }
    }

    var shortName: String {
        switch self {
        case .beginner: "Beginner"
        case .intermediate: "Intermediate"
        case .advanced: "Advanced"
        }
    }
}

nonisolated enum Gender: String, Codable, CaseIterable, Identifiable, Sendable {
    case male
    case female
    case other
    case preferNotToSay

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .male: "Male"
        case .female: "Female"
        case .other: "Other"
        case .preferNotToSay: "Prefer not to say"
        }
    }
}

nonisolated enum TrainingLocation: String, Codable, CaseIterable, Identifiable, Sendable {
    case gym
    case homeGym
    case homeNoEquipment

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .gym: "Full Gym"
        case .homeGym: "Home Gym"
        case .homeNoEquipment: "Home (No Equipment)"
        }
    }

    var symbolName: String {
        switch self {
        case .gym: "building.2.fill"
        case .homeGym: "dumbbell.fill"
        case .homeNoEquipment: "house.fill"
        }
    }
}

nonisolated enum SplitPreference: String, Codable, CaseIterable, Identifiable, Sendable {
    case automatic
    case fullBody
    case upperLower
    case pushPullLegs
    case bodyPart
    case muscleGroup

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .automatic: "Let AI Decide"
        case .fullBody: "Full Body"
        case .upperLower: "Upper / Lower"
        case .pushPullLegs: "Push / Pull / Legs"
        case .bodyPart: "Body Part Split"
        case .muscleGroup: "Muscle Group"
        }
    }
}

nonisolated enum ActivityLevel: String, Codable, CaseIterable, Identifiable, Sendable {
    case sedentary
    case lightlyActive
    case moderatelyActive
    case veryActive
    case extremelyActive

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .sedentary: "Sedentary"
        case .lightlyActive: "Lightly Active"
        case .moderatelyActive: "Moderately Active"
        case .veryActive: "Very Active"
        case .extremelyActive: "Extremely Active"
        }
    }
}

nonisolated enum StressLevel: String, Codable, CaseIterable, Identifiable, Sendable {
    case low
    case moderate
    case high
    case veryHigh

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .low: "Low"
        case .moderate: "Moderate"
        case .high: "High"
        case .veryHigh: "Very High"
        }
    }
}

nonisolated enum SleepQuality: String, Codable, CaseIterable, Identifiable, Sendable {
    case poor
    case fair
    case good
    case excellent

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .poor: "Poor (< 5h)"
        case .fair: "Fair (5-6h)"
        case .good: "Good (7-8h)"
        case .excellent: "Excellent (8+h)"
        }
    }
}

nonisolated enum RecoveryCapacity: String, Codable, CaseIterable, Identifiable, Sendable {
    case low
    case moderate
    case high

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .low: "Low"
        case .moderate: "Moderate"
        case .high: "High"
        }
    }
}

nonisolated struct UserProfile: Codable, Sendable {
    var name: String = ""
    var age: Int = 25
    var gender: Gender = .preferNotToSay
    var heightCm: Double = 175
    var weightKg: Double = 75
    var bodyFatPercentage: Double?
    var goal: FitnessGoal = .generalFitness
    var trainingLevel: TrainingLevel = .beginner
    var trainingMonths: Int = 0
    var daysPerWeek: Int = 3
    var minutesPerSession: Int = 60
    var splitPreference: SplitPreference = .automatic
    var trainingLocation: TrainingLocation = .gym
    var availableEquipment: [Equipment] = []
    var injuries: [String] = []
    var focusMuscles: [MuscleGroup] = []
    var neglectMuscles: [MuscleGroup] = []
    var preferredExercises: [String] = []
    var avoidedExercises: [String] = []
    var sleepQuality: SleepQuality = .good
    var stressLevel: StressLevel = .moderate
    var activityLevel: ActivityLevel = .moderatelyActive
    var recoveryCapacity: RecoveryCapacity = .moderate
    var targetWeightKg: Double?
    var startWeightKg: Double?
    var hasCompletedOnboarding: Bool = false
    var preferredTrainingDays: [Int] = []
}
