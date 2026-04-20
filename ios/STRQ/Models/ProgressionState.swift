import Foundation

nonisolated enum ProgressionStrategy: String, Codable, Sendable {
    case loadFirst
    case repFirst
    case doubleProgression
    case variationProgression
    case tempoProgression
    case holdAndConsolidate
    case deloadAndRebuild

    var displayName: String {
        switch self {
        case .loadFirst: "Increase Load"
        case .repFirst: "Increase Reps"
        case .doubleProgression: "Double Progression"
        case .variationProgression: "Progress Variation"
        case .tempoProgression: "Tempo Progression"
        case .holdAndConsolidate: "Hold & Consolidate"
        case .deloadAndRebuild: "Deload & Rebuild"
        }
    }

    var explanation: String {
        switch self {
        case .loadFirst: "Add a small weight increment while keeping reps the same."
        case .repFirst: "Keep the same weight and aim for more reps before increasing load."
        case .doubleProgression: "Hit the top of your rep range, then increase weight and drop back to the bottom."
        case .variationProgression: "Move to a harder exercise variation to continue progressing."
        case .tempoProgression: "Slow down the eccentric or add pauses for more tension without added load."
        case .holdAndConsolidate: "Repeat at the current weight until performance stabilizes."
        case .deloadAndRebuild: "Reduce weight by 10-15% and rebuild with better form and control."
        }
    }
}

nonisolated enum PlateauStatus: String, Codable, Sendable {
    case progressing
    case stalling
    case plateaued
    case regressing

    var displayName: String {
        switch self {
        case .progressing: "Progressing"
        case .stalling: "Stalling"
        case .plateaued: "Plateaued"
        case .regressing: "Regressing"
        }
    }

    var icon: String {
        switch self {
        case .progressing: "arrow.up.right"
        case .stalling: "arrow.right"
        case .plateaued: "pause.circle.fill"
        case .regressing: "arrow.down.right"
        }
    }

    var colorName: String {
        switch self {
        case .progressing: "green"
        case .stalling: "yellow"
        case .plateaued: "orange"
        case .regressing: "red"
        }
    }
}

nonisolated enum ExerciseFamily: String, Codable, Sendable {
    case heavyCompound
    case hypertrophyCompound
    case machineExercise
    case isolationLift
    case bodyweightExercise
    case calisthenicsProgression
    case mobilityCore

    var progressionPriority: ProgressionStrategy {
        switch self {
        case .heavyCompound: return .loadFirst
        case .hypertrophyCompound: return .doubleProgression
        case .machineExercise: return .repFirst
        case .isolationLift: return .repFirst
        case .bodyweightExercise: return .variationProgression
        case .calisthenicsProgression: return .variationProgression
        case .mobilityCore: return .tempoProgression
        }
    }

    var loadIncrementKg: Double {
        switch self {
        case .heavyCompound: return 2.5
        case .hypertrophyCompound: return 2.5
        case .machineExercise: return 2.5
        case .isolationLift: return 1.25
        case .bodyweightExercise: return 0
        case .calisthenicsProgression: return 0
        case .mobilityCore: return 0
        }
    }
}

nonisolated enum TrainingPhase: String, Codable, Sendable, CaseIterable {
    case build
    case push
    case fatigueManagement
    case deload
    case rebalance

    var displayName: String {
        switch self {
        case .build: "Build Phase"
        case .push: "Push Phase"
        case .fatigueManagement: "Recovery Phase"
        case .deload: "Deload Phase"
        case .rebalance: "Rebalance Phase"
        }
    }

    var description: String {
        switch self {
        case .build: "Establishing training rhythm and building work capacity."
        case .push: "Progressing load and volume toward new performance levels."
        case .fatigueManagement: "Managing accumulated fatigue while maintaining fitness."
        case .deload: "Reducing training stress to allow recovery and supercompensation."
        case .rebalance: "Adjusting focus to address muscle imbalances or weak points."
        }
    }

    var icon: String {
        switch self {
        case .build: "hammer.fill"
        case .push: "arrow.up.right.circle.fill"
        case .fatigueManagement: "heart.circle.fill"
        case .deload: "arrow.down.to.line"
        case .rebalance: "arrow.left.arrow.right"
        }
    }

    var colorName: String {
        switch self {
        case .build: "blue"
        case .push: "green"
        case .fatigueManagement: "orange"
        case .deload: "purple"
        case .rebalance: "cyan"
        }
    }

    var volumeMultiplier: Double {
        switch self {
        case .build: return 0.9
        case .push: return 1.05
        case .fatigueManagement: return 0.8
        case .deload: return 0.6
        case .rebalance: return 0.9
        }
    }

    var rpeAdjustment: Double {
        switch self {
        case .build: return 0
        case .push: return 0.5
        case .fatigueManagement: return -1.0
        case .deload: return -2.0
        case .rebalance: return -0.5
        }
    }

    /// Short coach-voice label for what this phase is optimizing.
    var optimizingFor: String {
        switch self {
        case .build: return "Work capacity & rhythm"
        case .push: return "Progressive overload"
        case .fatigueManagement: return "Protect recovery, hold fitness"
        case .deload: return "Supercompensate & reset"
        case .rebalance: return "Close weak-point gaps"
        }
    }

    /// How hard training should feel inside this phase.
    var expectedIntensityLabel: String {
        switch self {
        case .build: return "Moderate"
        case .push: return "Hard"
        case .fatigueManagement: return "Easier"
        case .deload: return "Light"
        case .rebalance: return "Moderate"
        }
    }

    /// Typical block length in weeks — used for week-in-block progress read.
    var typicalWeeks: Int {
        switch self {
        case .build: return 3
        case .push: return 4
        case .fatigueManagement: return 2
        case .deload: return 1
        case .rebalance: return 3
        }
    }

    /// The phase STRQ most commonly shifts into after a successful run here.
    var typicalNextPhase: TrainingPhase {
        switch self {
        case .build: return .push
        case .push: return .fatigueManagement
        case .fatigueManagement: return .push
        case .deload: return .build
        case .rebalance: return .build
        }
    }

    var shortLabel: String {
        displayName.replacingOccurrences(of: " Phase", with: "")
    }
}

nonisolated struct ExerciseProgressionState: Identifiable, Codable, Sendable {
    let id: String
    let exerciseId: String
    var lastWeight: Double
    var lastReps: Int
    var lastRPE: Double?
    var sessionCount: Int
    var consecutiveSamePerformance: Int
    var plateauStatus: PlateauStatus
    var recommendedStrategy: ProgressionStrategy
    var suggestedNextWeight: Double?
    var suggestedNextReps: String?
    var performanceTrend: [Double]
    var lastUpdated: Date
    var coachNote: String

    init(
        id: String = UUID().uuidString,
        exerciseId: String,
        lastWeight: Double = 0,
        lastReps: Int = 0,
        lastRPE: Double? = nil,
        sessionCount: Int = 0,
        consecutiveSamePerformance: Int = 0,
        plateauStatus: PlateauStatus = .progressing,
        recommendedStrategy: ProgressionStrategy = .loadFirst,
        suggestedNextWeight: Double? = nil,
        suggestedNextReps: String? = nil,
        performanceTrend: [Double] = [],
        lastUpdated: Date = Date(),
        coachNote: String = ""
    ) {
        self.id = id
        self.exerciseId = exerciseId
        self.lastWeight = lastWeight
        self.lastReps = lastReps
        self.lastRPE = lastRPE
        self.sessionCount = sessionCount
        self.consecutiveSamePerformance = consecutiveSamePerformance
        self.plateauStatus = plateauStatus
        self.recommendedStrategy = recommendedStrategy
        self.suggestedNextWeight = suggestedNextWeight
        self.suggestedNextReps = suggestedNextReps
        self.performanceTrend = performanceTrend
        self.lastUpdated = lastUpdated
        self.coachNote = coachNote
    }

    var estimatedOneRepMax: Double {
        guard lastReps > 0, lastWeight > 0 else { return 0 }
        return lastWeight * (1 + Double(lastReps) / 30.0)
    }
}

nonisolated struct TrainingPhaseState: Codable, Sendable {
    var currentPhase: TrainingPhase
    var weeksInPhase: Int
    var totalWeeksTrained: Int
    var lastPhaseChange: Date
    var phaseHistory: [PhaseEntry]

    init(
        currentPhase: TrainingPhase = .build,
        weeksInPhase: Int = 1,
        totalWeeksTrained: Int = 0,
        lastPhaseChange: Date = Date(),
        phaseHistory: [PhaseEntry] = []
    ) {
        self.currentPhase = currentPhase
        self.weeksInPhase = weeksInPhase
        self.totalWeeksTrained = totalWeeksTrained
        self.lastPhaseChange = lastPhaseChange
        self.phaseHistory = phaseHistory
    }
}

nonisolated struct PhaseEntry: Codable, Identifiable, Sendable {
    let id: String
    let phase: TrainingPhase
    let startDate: Date
    let endDate: Date?
    let reason: String

    init(id: String = UUID().uuidString, phase: TrainingPhase, startDate: Date = Date(), endDate: Date? = nil, reason: String = "") {
        self.id = id
        self.phase = phase
        self.startDate = startDate
        self.endDate = endDate
        self.reason = reason
    }
}

nonisolated struct PlanQualityScore: Sendable {
    let overall: Double
    let recoveryFit: QualityRating
    let timeFit: QualityRating
    let muscleBalance: QualityRating
    let equipmentFit: QualityRating
    let progressionReadiness: QualityRating
    let riskFlags: [String]
    let strengths: [String]
    let watchItems: [String]

    var overallLabel: String {
        switch overall {
        case 0.85...: return "Excellent"
        case 0.7..<0.85: return "Good"
        case 0.55..<0.7: return "Fair"
        default: return "Needs Adjustment"
        }
    }

    var overallColor: String {
        switch overall {
        case 0.85...: return "green"
        case 0.7..<0.85: return "blue"
        case 0.55..<0.7: return "yellow"
        default: return "orange"
        }
    }
}

nonisolated enum QualityRating: String, Sendable {
    case excellent
    case good
    case fair
    case poor

    var label: String {
        switch self {
        case .excellent: "Excellent"
        case .good: "Good"
        case .fair: "Fair"
        case .poor: "Needs Work"
        }
    }

    var icon: String {
        switch self {
        case .excellent: "checkmark.circle.fill"
        case .good: "checkmark.circle"
        case .fair: "exclamationmark.circle"
        case .poor: "xmark.circle"
        }
    }

    var colorName: String {
        switch self {
        case .excellent: "green"
        case .good: "blue"
        case .fair: "yellow"
        case .poor: "red"
        }
    }

    var score: Double {
        switch self {
        case .excellent: return 1.0
        case .good: return 0.75
        case .fair: return 0.5
        case .poor: return 0.25
        }
    }
}

nonisolated struct NextBestAction: Identifiable, Sendable {
    let id: String
    let title: String
    let explanation: String
    let icon: String
    let colorName: String
    let confidence: Double
    let actionType: CoachActionType

    init(id: String = UUID().uuidString, title: String, explanation: String, icon: String, colorName: String, confidence: Double, actionType: CoachActionType) {
        self.id = id
        self.title = title
        self.explanation = explanation
        self.icon = icon
        self.colorName = colorName
        self.confidence = confidence
        self.actionType = actionType
    }
}

nonisolated struct VolumeLandmark: Sendable {
    let muscleGroup: String
    let maintenanceVolume: Int
    let minimumEffectiveVolume: Int
    let maximumRecoverableVolume: Int
    let currentWeeklySets: Int

    var status: VolumeStatus {
        if currentWeeklySets < minimumEffectiveVolume { return .belowMEV }
        if currentWeeklySets <= maintenanceVolume { return .maintenance }
        if currentWeeklySets <= maximumRecoverableVolume { return .productive }
        return .aboveMRV
    }
}

nonisolated enum VolumeStatus: String, Sendable {
    case belowMEV
    case maintenance
    case productive
    case aboveMRV

    var displayName: String {
        switch self {
        case .belowMEV: "Below Minimum"
        case .maintenance: "Maintenance"
        case .productive: "Productive"
        case .aboveMRV: "Overreaching"
        }
    }

    var colorName: String {
        switch self {
        case .belowMEV: "red"
        case .maintenance: "yellow"
        case .productive: "green"
        case .aboveMRV: "orange"
        }
    }
}
