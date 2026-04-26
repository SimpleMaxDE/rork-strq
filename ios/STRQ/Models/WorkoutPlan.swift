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

    enum CodingKeys: String, CodingKey {
        case id, name, description, days, createdAt, splitType, durationWeeks, explanation
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.description = try c.decodeIfPresent(String.self, forKey: .description) ?? ""
        self.days = try c.decodeIfPresent([WorkoutDay].self, forKey: .days) ?? []
        self.createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        self.splitType = try c.decodeIfPresent(String.self, forKey: .splitType) ?? ""
        self.durationWeeks = try c.decodeIfPresent(Int.self, forKey: .durationWeeks) ?? 8
        self.explanation = try c.decodeIfPresent(String.self, forKey: .explanation) ?? ""
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

    enum CodingKeys: String, CodingKey {
        case id, name, focusMuscles, exercises, dayIndex, warmupHint
        case estimatedMinutes, scheduledWeekday, isSkipped
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.name = try c.decodeIfPresent(String.self, forKey: .name) ?? ""
        self.focusMuscles = try c.decodeIfPresent([MuscleGroup].self, forKey: .focusMuscles) ?? []
        self.exercises = try c.decodeIfPresent([PlannedExercise].self, forKey: .exercises) ?? []
        self.dayIndex = try c.decodeIfPresent(Int.self, forKey: .dayIndex) ?? 0
        self.warmupHint = try c.decodeIfPresent(String.self, forKey: .warmupHint) ?? ""
        self.estimatedMinutes = try c.decodeIfPresent(Int.self, forKey: .estimatedMinutes) ?? 60
        self.scheduledWeekday = try c.decodeIfPresent(Int.self, forKey: .scheduledWeekday)
        self.isSkipped = try c.decodeIfPresent(Bool.self, forKey: .isSkipped) ?? false
    }
}

nonisolated struct CoachDefault: Codable, Sendable, Equatable {
    var sets: Int
    var reps: String
    var restSeconds: Int
    var rpe: Double?
    var role: String

    enum CodingKeys: String, CodingKey {
        case sets, reps, restSeconds, rpe, role
    }

    init(sets: Int, reps: String, restSeconds: Int, rpe: Double? = nil, role: String = "") {
        self.sets = sets
        self.reps = reps
        self.restSeconds = restSeconds
        self.rpe = rpe
        self.role = role
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.sets = try c.decodeIfPresent(Int.self, forKey: .sets) ?? 0
        self.reps = try c.decodeIfPresent(String.self, forKey: .reps) ?? ""
        self.restSeconds = try c.decodeIfPresent(Int.self, forKey: .restSeconds) ?? 90
        self.rpe = try c.decodeIfPresent(Double.self, forKey: .rpe)
        self.role = try c.decodeIfPresent(String.self, forKey: .role) ?? ""
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
    var coachDefault: CoachDefault?

    init(id: String = UUID().uuidString, exerciseId: String, sets: Int, reps: String, restSeconds: Int, rpe: Double? = nil, notes: String = "", order: Int = 0, coachDefault: CoachDefault? = nil) {
        self.id = id
        self.exerciseId = exerciseId
        self.sets = sets
        self.reps = reps
        self.restSeconds = restSeconds
        self.rpe = rpe
        self.notes = notes
        self.order = order
        self.coachDefault = coachDefault
    }

    enum CodingKeys: String, CodingKey {
        case id, exerciseId, sets, reps, restSeconds, rpe, notes, order, coachDefault
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
        self.exerciseId = try c.decodeIfPresent(String.self, forKey: .exerciseId) ?? ""
        self.sets = try c.decodeIfPresent(Int.self, forKey: .sets) ?? 1
        self.reps = try c.decodeIfPresent(String.self, forKey: .reps) ?? ""
        self.restSeconds = try c.decodeIfPresent(Int.self, forKey: .restSeconds) ?? 90
        self.rpe = try c.decodeIfPresent(Double.self, forKey: .rpe)
        self.notes = try c.decodeIfPresent(String.self, forKey: .notes) ?? ""
        self.order = try c.decodeIfPresent(Int.self, forKey: .order) ?? 0
        self.coachDefault = try c.decodeIfPresent(CoachDefault.self, forKey: .coachDefault)
    }

    var isCustomized: Bool {
        guard let cd = coachDefault else { return false }
        return cd.sets != sets || cd.reps != reps || cd.restSeconds != restSeconds || cd.rpe != rpe
    }

    var plannedRole: String? { coachDefault?.role }
}
