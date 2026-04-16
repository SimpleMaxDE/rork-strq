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
}

nonisolated struct SetLog: Codable, Identifiable, Sendable {
    let id: String
    var setNumber: Int
    var weight: Double
    var reps: Int
    var isCompleted: Bool
    var isPR: Bool
    var rpe: Double?

    init(id: String = UUID().uuidString, setNumber: Int, weight: Double = 0, reps: Int = 0, isCompleted: Bool = false, isPR: Bool = false, rpe: Double? = nil) {
        self.id = id
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
        self.isPR = isPR
        self.rpe = rpe
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
