import Foundation

nonisolated struct WorkoutPlan: Codable, Identifiable, Sendable {
    let id: String
    var name: String
    var description: String
    var days: [WorkoutDay]
    var createdAt: Date
    var splitType: String
    var durationWeeks: Int
    var explanation: String

    init(id: String = UUID().uuidString, name: String, description: String, days: [WorkoutDay], createdAt: Date = Date(), splitType: String, durationWeeks: Int = 8, explanation: String = "") {
        self.id = id
        self.name = name
        self.description = description
        self.days = days
        self.createdAt = createdAt
        self.splitType = splitType
        self.durationWeeks = durationWeeks
        self.explanation = explanation
    }
}

nonisolated struct WorkoutDay: Codable, Identifiable, Sendable {
    let id: String
    var name: String
    var focusMuscles: [MuscleGroup]
    var exercises: [PlannedExercise]
    var dayIndex: Int
    var warmupHint: String
    var estimatedMinutes: Int
    var scheduledWeekday: Int?
    var isSkipped: Bool

    init(id: String = UUID().uuidString, name: String, focusMuscles: [MuscleGroup], exercises: [PlannedExercise], dayIndex: Int, warmupHint: String = "", estimatedMinutes: Int = 60, scheduledWeekday: Int? = nil, isSkipped: Bool = false) {
        self.id = id
        self.name = name
        self.focusMuscles = focusMuscles
        self.exercises = exercises
        self.dayIndex = dayIndex
        self.warmupHint = warmupHint
        self.estimatedMinutes = estimatedMinutes
        self.scheduledWeekday = scheduledWeekday
        self.isSkipped = isSkipped
    }
}

nonisolated struct PlannedExercise: Codable, Identifiable, Sendable {
    let id: String
    var exerciseId: String
    var sets: Int
    var reps: String
    var restSeconds: Int
    var rpe: Double?
    var notes: String
    var order: Int

    init(id: String = UUID().uuidString, exerciseId: String, sets: Int, reps: String, restSeconds: Int, rpe: Double? = nil, notes: String = "", order: Int = 0) {
        self.id = id
        self.exerciseId = exerciseId
        self.sets = sets
        self.reps = reps
        self.restSeconds = restSeconds
        self.rpe = rpe
        self.notes = notes
        self.order = order
    }
}
