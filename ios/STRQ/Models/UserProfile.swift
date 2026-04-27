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
        case .muscleGain: L10n.tr("Build Muscle")
        case .strength: L10n.tr("Get Stronger")
        case .fatLoss: L10n.tr("Lose Fat")
        case .generalFitness: L10n.tr("General Fitness")
        case .endurance: L10n.tr("Endurance")
        case .flexibility: L10n.tr("Flexibility")
        case .athleticPerformance: L10n.tr("Athletic Performance")
        case .rehabilitation: L10n.tr("Rehabilitation")
        }
    }

    var localizedDisplayName: String { displayName }

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
        case .beginner: L10n.tr("Beginner (0-1 year)")
        case .intermediate: L10n.tr("Intermediate (1-3 years)")
        case .advanced: L10n.tr("Advanced (3+ years)")
        }
    }

    var localizedDisplayName: String { displayName }

    var shortName: String {
        switch self {
        case .beginner: L10n.tr("Beginner")
        case .intermediate: L10n.tr("Intermediate")
        case .advanced: L10n.tr("Advanced")
        }
    }

    var localizedShortName: String { shortName }
}

nonisolated enum Gender: String, Codable, CaseIterable, Identifiable, Sendable {
    case male
    case female
    case other
    case preferNotToSay

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .male: L10n.tr("Male")
        case .female: L10n.tr("Female")
        case .other: L10n.tr("Other")
        case .preferNotToSay: L10n.tr("Prefer not to say")
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
        case .gym: L10n.tr("Full Gym")
        case .homeGym: L10n.tr("Home Gym")
        case .homeNoEquipment: L10n.tr("Home (No Equipment)")
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
        case .automatic: L10n.tr("Let AI Decide")
        case .fullBody: L10n.tr("Full Body")
        case .upperLower: L10n.tr("Upper / Lower")
        case .pushPullLegs: L10n.tr("Push / Pull / Legs")
        case .bodyPart: L10n.tr("Body Part Split")
        case .muscleGroup: L10n.tr("Muscle Group")
        }
    }

    var localizedDisplayName: String { displayName }
}

nonisolated enum InjuryRestriction: String, CaseIterable, Identifiable, Sendable {
    case shoulder = "Shoulder"
    case knee = "Knee"
    case lowerBack = "Lower Back"
    case wrist = "Wrist"
    case neck = "Neck"
    case hip = "Hip"
    case ankle = "Ankle"
    case elbow = "Elbow"

    var id: String { rawValue }

    var localizedDisplayName: String {
        switch self {
        case .shoulder: L10n.tr("injury.shoulder", fallback: rawValue)
        case .knee: L10n.tr("injury.knee", fallback: rawValue)
        case .lowerBack: L10n.tr("injury.lowerBack", fallback: rawValue)
        case .wrist: L10n.tr("injury.wrist", fallback: rawValue)
        case .neck: L10n.tr("injury.neck", fallback: rawValue)
        case .hip: L10n.tr("injury.hip", fallback: rawValue)
        case .ankle: L10n.tr("injury.ankle", fallback: rawValue)
        case .elbow: L10n.tr("injury.elbow", fallback: rawValue)
        }
    }

    static func localizedDisplayName(for rawValue: String) -> String {
        allCases.first { $0.rawValue == rawValue }?.localizedDisplayName ?? rawValue
    }
}

nonisolated enum SplitDisplayName {
    static func localizedDisplayName(for rawName: String) -> String {
        switch rawName {
        case "Full Body": L10n.tr("split.fullBody", fallback: "Full Body")
        case "Upper/Lower": L10n.tr("split.upperLower", fallback: "Upper/Lower")
        case "Push/Pull/Legs": L10n.tr("split.pushPullLegs", fallback: "Push/Pull/Legs")
        case "Body Part": L10n.tr("split.bodyPart", fallback: "Body Part")
        default: L10n.tr(rawName, fallback: rawName)
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
        case .sedentary: L10n.tr("Sedentary")
        case .lightlyActive: L10n.tr("Lightly Active")
        case .moderatelyActive: L10n.tr("Moderately Active")
        case .veryActive: L10n.tr("Very Active")
        case .extremelyActive: L10n.tr("Extremely Active")
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
        case .low: L10n.tr("Low")
        case .moderate: L10n.tr("Moderate")
        case .high: L10n.tr("High")
        case .veryHigh: L10n.tr("Very High")
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
        case .poor: L10n.tr("Poor (< 5h)")
        case .fair: L10n.tr("Fair (5-6h)")
        case .good: L10n.tr("Good (7-8h)")
        case .excellent: L10n.tr("Excellent (8+h)")
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
        case .low: L10n.tr("Low")
        case .moderate: L10n.tr("Moderate")
        case .high: L10n.tr("High")
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
    var nutritionTrackingEnabled: Bool = false
    var coachingPreferences: CoachingPreferences = CoachingPreferences()
}

// MARK: - Coaching Preferences

nonisolated enum CoachingTone: String, Codable, CaseIterable, Identifiable, Sendable {
    case supportive
    case balanced
    case direct

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .supportive: L10n.tr("Supportive")
        case .balanced: L10n.tr("Balanced")
        case .direct: L10n.tr("Direct")
        }
    }

    var detail: String {
        switch self {
        case .supportive: L10n.tr("Encouraging, patient, softer language.")
        case .balanced: L10n.tr("Clear and honest — STRQ's default voice.")
        case .direct: L10n.tr("Sharp, no-nonsense. Straight to the call.")
        }
    }

    var symbolName: String {
        switch self {
        case .supportive: "hand.raised.fill"
        case .balanced: "bubble.left.and.bubble.right.fill"
        case .direct: "bolt.fill"
        }
    }
}

nonisolated enum CoachingDensity: String, Codable, CaseIterable, Identifiable, Sendable {
    case focused
    case standard
    case detailed

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .focused: L10n.tr("Focused")
        case .standard: L10n.tr("Standard")
        case .detailed: L10n.tr("Detailed")
        }
    }

    var detail: String {
        switch self {
        case .focused: L10n.tr("One call at a time. Maximum signal, minimum noise.")
        case .standard: L10n.tr("Primary + watch + momentum. The coach default.")
        case .detailed: L10n.tr("Show more of what STRQ is seeing.")
        }
    }

    var symbolName: String {
        switch self {
        case .focused: "circle.grid.cross.fill"
        case .standard: "square.grid.2x2.fill"
        case .detailed: "square.grid.3x3.fill"
        }
    }

    /// How many side-cards (watch, momentum) to show below the primary move.
    var sideSignalsLimit: Int {
        switch self {
        case .focused: 0
        case .standard: 2
        case .detailed: 4
        }
    }
}

nonisolated enum CoachingEmphasis: String, Codable, CaseIterable, Identifiable, Sendable {
    case performance
    case physique
    case recovery
    case consistency
    case simplicity

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .performance: L10n.tr("Performance")
        case .physique: L10n.tr("Physique")
        case .recovery: L10n.tr("Recovery")
        case .consistency: L10n.tr("Consistency")
        case .simplicity: L10n.tr("Simplicity")
        }
    }

    var detail: String {
        switch self {
        case .performance: L10n.tr("Strength, PRs, progression.")
        case .physique: L10n.tr("Body composition and nutrition pace.")
        case .recovery: L10n.tr("Sleep, readiness, fatigue protection.")
        case .consistency: L10n.tr("Showing up. Streaks and adherence.")
        case .simplicity: L10n.tr("Just tell me what to do today.")
        }
    }

    var symbolName: String {
        switch self {
        case .performance: "bolt.fill"
        case .physique: "figure.stand"
        case .recovery: "heart.fill"
        case .consistency: "calendar.badge.checkmark"
        case .simplicity: "target"
        }
    }
}

nonisolated enum CoachingAutomation: String, Codable, CaseIterable, Identifiable, Sendable {
    case manual
    case guided
    case adaptive

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .manual: L10n.tr("Manual")
        case .guided: L10n.tr("Guided")
        case .adaptive: L10n.tr("Adaptive")
        }
    }

    var detail: String {
        switch self {
        case .manual: L10n.tr("STRQ suggests. You decide every change.")
        case .guided: L10n.tr("STRQ proposes adjustments. You approve them.")
        case .adaptive: L10n.tr("STRQ adjusts load and volume as signal comes in.")
        }
    }

    var symbolName: String {
        switch self {
        case .manual: "hand.point.up.left.fill"
        case .guided: "signpost.right.fill"
        case .adaptive: "sparkles"
        }
    }
}

nonisolated struct CoachingPreferences: Codable, Sendable {
    var tone: CoachingTone = .balanced
    var density: CoachingDensity = .standard
    var emphasis: CoachingEmphasis = .performance
    var automation: CoachingAutomation = .guided

    init(
        tone: CoachingTone = .balanced,
        density: CoachingDensity = .standard,
        emphasis: CoachingEmphasis = .performance,
        automation: CoachingAutomation = .guided
    ) {
        self.tone = tone
        self.density = density
        self.emphasis = emphasis
        self.automation = automation
    }

    // Tolerate missing keys so older persisted profiles decode cleanly.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.tone = (try? c.decode(CoachingTone.self, forKey: .tone)) ?? .balanced
        self.density = (try? c.decode(CoachingDensity.self, forKey: .density)) ?? .standard
        self.emphasis = (try? c.decode(CoachingEmphasis.self, forKey: .emphasis)) ?? .performance
        self.automation = (try? c.decode(CoachingAutomation.self, forKey: .automation)) ?? .guided
    }
}

nonisolated extension UserProfile {
    enum CodingKeys: String, CodingKey {
        case name, age, gender, heightCm, weightKg, bodyFatPercentage
        case goal, trainingLevel, trainingMonths, daysPerWeek, minutesPerSession
        case splitPreference, trainingLocation, availableEquipment, injuries
        case focusMuscles, neglectMuscles, preferredExercises, avoidedExercises
        case sleepQuality, stressLevel, activityLevel, recoveryCapacity
        case targetWeightKg, startWeightKg, hasCompletedOnboarding
        case preferredTrainingDays, nutritionTrackingEnabled, coachingPreferences
    }

    init(from decoder: Decoder) throws {
        self.init()
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try c.decodeIfPresent(String.self, forKey: .name) ?? name
        self.age = try c.decodeIfPresent(Int.self, forKey: .age) ?? age
        self.gender = try c.decodeIfPresent(Gender.self, forKey: .gender) ?? gender
        self.heightCm = try c.decodeIfPresent(Double.self, forKey: .heightCm) ?? heightCm
        self.weightKg = try c.decodeIfPresent(Double.self, forKey: .weightKg) ?? weightKg
        self.bodyFatPercentage = try c.decodeIfPresent(Double.self, forKey: .bodyFatPercentage)
        self.goal = try c.decodeIfPresent(FitnessGoal.self, forKey: .goal) ?? goal
        self.trainingLevel = try c.decodeIfPresent(TrainingLevel.self, forKey: .trainingLevel) ?? trainingLevel
        self.trainingMonths = try c.decodeIfPresent(Int.self, forKey: .trainingMonths) ?? trainingMonths
        self.daysPerWeek = try c.decodeIfPresent(Int.self, forKey: .daysPerWeek) ?? daysPerWeek
        self.minutesPerSession = try c.decodeIfPresent(Int.self, forKey: .minutesPerSession) ?? minutesPerSession
        self.splitPreference = try c.decodeIfPresent(SplitPreference.self, forKey: .splitPreference) ?? splitPreference
        self.trainingLocation = try c.decodeIfPresent(TrainingLocation.self, forKey: .trainingLocation) ?? trainingLocation
        self.availableEquipment = try c.decodeIfPresent([Equipment].self, forKey: .availableEquipment) ?? availableEquipment
        self.injuries = try c.decodeIfPresent([String].self, forKey: .injuries) ?? injuries
        self.focusMuscles = try c.decodeIfPresent([MuscleGroup].self, forKey: .focusMuscles) ?? focusMuscles
        self.neglectMuscles = try c.decodeIfPresent([MuscleGroup].self, forKey: .neglectMuscles) ?? neglectMuscles
        self.preferredExercises = try c.decodeIfPresent([String].self, forKey: .preferredExercises) ?? preferredExercises
        self.avoidedExercises = try c.decodeIfPresent([String].self, forKey: .avoidedExercises) ?? avoidedExercises
        self.sleepQuality = try c.decodeIfPresent(SleepQuality.self, forKey: .sleepQuality) ?? sleepQuality
        self.stressLevel = try c.decodeIfPresent(StressLevel.self, forKey: .stressLevel) ?? stressLevel
        self.activityLevel = try c.decodeIfPresent(ActivityLevel.self, forKey: .activityLevel) ?? activityLevel
        self.recoveryCapacity = try c.decodeIfPresent(RecoveryCapacity.self, forKey: .recoveryCapacity) ?? recoveryCapacity
        self.targetWeightKg = try c.decodeIfPresent(Double.self, forKey: .targetWeightKg)
        self.startWeightKg = try c.decodeIfPresent(Double.self, forKey: .startWeightKg)
        self.hasCompletedOnboarding = try c.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? hasCompletedOnboarding
        self.preferredTrainingDays = try c.decodeIfPresent([Int].self, forKey: .preferredTrainingDays) ?? preferredTrainingDays
        self.nutritionTrackingEnabled = try c.decodeIfPresent(Bool.self, forKey: .nutritionTrackingEnabled) ?? nutritionTrackingEnabled
        self.coachingPreferences = try c.decodeIfPresent(CoachingPreferences.self, forKey: .coachingPreferences) ?? coachingPreferences
    }
}
