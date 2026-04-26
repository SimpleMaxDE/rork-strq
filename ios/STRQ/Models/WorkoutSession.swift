import Foundation

nonisolated struct WorkoutSession: Codable, Identifiable, Sendable {
    let id: String
    var planId: String
    var dayId: String
    var dayName: String
    var startTime: Date
    var endTime: Date?
    var exerciseLogs: [ExerciseLog]
    var isCompleted: Bool
    var totalVolume: Double
    var notes: String

    init(id: String = UUID().uuidString, planId: String, dayId: String, dayName: String, startTime: Date = Date(), endTime: Date? = nil, exerciseLogs: [ExerciseLog] = [], isCompleted: Bool = false, totalVolume: Double = 0, notes: String = "") {
        self.id = id
        self.planId = planId
        self.dayId = dayId
        self.dayName = dayName
        self.startTime = startTime
        self.endTime = endTime
        self.exerciseLogs = exerciseLogs
        self.isCompleted = isCompleted
        self.totalVolume = totalVolume
        self.notes = notes
    }

    enum CodingKeys: String, CodingKey {
        case id, planId, dayId, dayName, startTime, endTime, exerciseLogs
        case isCompleted, totalVolume, notes
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.planId = try c.decodeIfPresent(String.self, forKey: .planId) ?? ""
        self.dayId = try c.decodeIfPresent(String.self, forKey: .dayId) ?? ""
        self.dayName = try c.decodeIfPresent(String.self, forKey: .dayName) ?? ""
        self.startTime = try c.decodeIfPresent(Date.self, forKey: .startTime) ?? Date()
        self.endTime = try c.decodeIfPresent(Date.self, forKey: .endTime)
        self.exerciseLogs = try c.decodeIfPresent([ExerciseLog].self, forKey: .exerciseLogs) ?? []
        self.isCompleted = try c.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        self.totalVolume = try c.decodeIfPresent(Double.self, forKey: .totalVolume) ?? 0
        self.notes = try c.decodeIfPresent(String.self, forKey: .notes) ?? ""
    }
}

nonisolated struct ExerciseLog: Codable, Identifiable, Sendable {
    let id: String
    var exerciseId: String
    var sets: [SetLog]
    var isCompleted: Bool

    init(id: String = UUID().uuidString, exerciseId: String, sets: [SetLog] = [], isCompleted: Bool = false) {
        self.id = id
        self.exerciseId = exerciseId
        self.sets = sets
        self.isCompleted = isCompleted
    }

    enum CodingKeys: String, CodingKey {
        case id, exerciseId, sets, isCompleted
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.exerciseId = try c.decodeIfPresent(String.self, forKey: .exerciseId) ?? ""
        self.sets = try c.decodeIfPresent([SetLog].self, forKey: .sets) ?? []
        self.isCompleted = try c.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
    }
}

nonisolated struct SetLog: Codable, Identifiable, Sendable {
    let id: String
    var setNumber: Int
    var weight: Double
    var reps: Int
    var isCompleted: Bool
    var isPR: Bool
    var rpe: Double?
    var quality: SetQuality?

    init(id: String = UUID().uuidString, setNumber: Int, weight: Double = 0, reps: Int = 0, isCompleted: Bool = false, isPR: Bool = false, rpe: Double? = nil, quality: SetQuality? = nil) {
        self.id = id
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
        self.isPR = isPR
        self.rpe = rpe
        self.quality = quality
    }

    enum CodingKeys: String, CodingKey {
        case id, setNumber, weight, reps, isCompleted, isPR, rpe, quality
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.setNumber = try c.decodeIfPresent(Int.self, forKey: .setNumber) ?? 1
        self.weight = try c.decodeIfPresent(Double.self, forKey: .weight) ?? 0
        self.reps = try c.decodeIfPresent(Int.self, forKey: .reps) ?? 0
        self.isCompleted = try c.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? false
        self.isPR = try c.decodeIfPresent(Bool.self, forKey: .isPR) ?? false
        self.rpe = try c.decodeIfPresent(Double.self, forKey: .rpe)
        self.quality = try c.decodeIfPresent(SetQuality.self, forKey: .quality)
    }
}

nonisolated enum SetQuality: String, Codable, Sendable, CaseIterable {
    case tooEasy
    case onTarget
    case grinder
    case formBreakdown
    case pain

    var label: String {
        switch self {
        case .tooEasy: "Too easy"
        case .onTarget: "On target"
        case .grinder: "Grinder"
        case .formBreakdown: "Form broke"
        case .pain: "Pain"
        }
    }

    var shortLabel: String {
        switch self {
        case .tooEasy: "Easy"
        case .onTarget: "Clean"
        case .grinder: "Grind"
        case .formBreakdown: "Form"
        case .pain: "Pain"
        }
    }

    var icon: String {
        switch self {
        case .tooEasy: "arrow.up.circle"
        case .onTarget: "checkmark.circle.fill"
        case .grinder: "flame.fill"
        case .formBreakdown: "exclamationmark.triangle.fill"
        case .pain: "cross.case.fill"
        }
    }

    var colorName: String {
        switch self {
        case .tooEasy: "blue"
        case .onTarget: "green"
        case .grinder: "orange"
        case .formBreakdown: "yellow"
        case .pain: "red"
        }
    }

    /// Approximate reps in reserve — used as a soft signal into progression.
    var rirEstimate: Double? {
        switch self {
        case .tooEasy: 3.5
        case .onTarget: 1.5
        case .grinder: 0
        case .formBreakdown: 0
        case .pain: nil
        }
    }

    var isNegative: Bool {
        self == .grinder || self == .formBreakdown || self == .pain
    }
}

nonisolated struct PersonalRecord: Codable, Identifiable, Sendable {
    let id: String
    var exerciseId: String
    var weight: Double
    var reps: Int
    var date: Date
    var estimatedOneRepMax: Double

    init(id: String = UUID().uuidString, exerciseId: String, weight: Double, reps: Int, date: Date = Date(), estimatedOneRepMax: Double = 0) {
        self.id = id
        self.exerciseId = exerciseId
        self.weight = weight
        self.reps = reps
        self.date = date
        self.estimatedOneRepMax = estimatedOneRepMax
    }

    enum CodingKeys: String, CodingKey {
        case id, exerciseId, weight, reps, date, estimatedOneRepMax
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.exerciseId = try c.decodeIfPresent(String.self, forKey: .exerciseId) ?? ""
        self.weight = try c.decodeIfPresent(Double.self, forKey: .weight) ?? 0
        self.reps = try c.decodeIfPresent(Int.self, forKey: .reps) ?? 0
        self.date = try c.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        self.estimatedOneRepMax = try c.decodeIfPresent(Double.self, forKey: .estimatedOneRepMax) ?? 0
    }
}

nonisolated struct ProgressEntry: Codable, Identifiable, Sendable {
    let id: String
    var date: Date
    var bodyWeight: Double?
    var muscleGroupVolume: [String: Double]
    var totalSets: Int
    var totalReps: Int
    var totalVolume: Double
    var workoutDuration: Int

    init(id: String = UUID().uuidString, date: Date = Date(), bodyWeight: Double? = nil, muscleGroupVolume: [String: Double] = [:], totalSets: Int = 0, totalReps: Int = 0, totalVolume: Double = 0, workoutDuration: Int = 0) {
        self.id = id
        self.date = date
        self.bodyWeight = bodyWeight
        self.muscleGroupVolume = muscleGroupVolume
        self.totalSets = totalSets
        self.totalReps = totalReps
        self.totalVolume = totalVolume
        self.workoutDuration = workoutDuration
    }

    enum CodingKeys: String, CodingKey {
        case id, date, bodyWeight, muscleGroupVolume, totalSets, totalReps
        case totalVolume, workoutDuration
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.date = try c.decodeIfPresent(Date.self, forKey: .date) ?? Date()
        self.bodyWeight = try c.decodeIfPresent(Double.self, forKey: .bodyWeight)
        self.muscleGroupVolume = try c.decodeIfPresent([String: Double].self, forKey: .muscleGroupVolume) ?? [:]
        self.totalSets = try c.decodeIfPresent(Int.self, forKey: .totalSets) ?? 0
        self.totalReps = try c.decodeIfPresent(Int.self, forKey: .totalReps) ?? 0
        self.totalVolume = try c.decodeIfPresent(Double.self, forKey: .totalVolume) ?? 0
        self.workoutDuration = try c.decodeIfPresent(Int.self, forKey: .workoutDuration) ?? 0
    }
}

nonisolated struct Recommendation: Codable, Identifiable, Sendable {
    let id: String
    var type: RecommendationType
    var title: String
    var message: String
    var priority: Int
    var date: Date

    init(id: String = UUID().uuidString, type: RecommendationType, title: String, message: String, priority: Int = 0, date: Date = Date()) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.priority = priority
        self.date = date
    }
}

nonisolated enum RecommendationType: String, Codable, Sendable {
    case volumeImbalance
    case progressionSuggestion
    case recoveryConcern
    case exerciseSwap
    case splitSuggestion
    case prCongrats
    case general
}
