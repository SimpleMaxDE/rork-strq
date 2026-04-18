import ActivityKit
import Foundation

nonisolated public struct WorkoutActivityAttributes: ActivityAttributes, Sendable {
    public typealias ContentState = WorkoutActivityState

    nonisolated public struct WorkoutActivityState: Codable, Hashable, Sendable {
        public var dayName: String
        public var exerciseName: String
        public var currentExerciseIndex: Int
        public var totalExercises: Int
        public var currentSetNumber: Int
        public var totalSets: Int
        public var completedSets: Int
        public var totalSessionSets: Int
        public var startedAt: Date
        public var restEndsAt: Date?
        public var nextExerciseName: String?
        public var isCompleted: Bool

        public init(
            dayName: String,
            exerciseName: String,
            currentExerciseIndex: Int,
            totalExercises: Int,
            currentSetNumber: Int,
            totalSets: Int,
            completedSets: Int,
            totalSessionSets: Int,
            startedAt: Date,
            restEndsAt: Date? = nil,
            nextExerciseName: String? = nil,
            isCompleted: Bool = false
        ) {
            self.dayName = dayName
            self.exerciseName = exerciseName
            self.currentExerciseIndex = currentExerciseIndex
            self.totalExercises = totalExercises
            self.currentSetNumber = currentSetNumber
            self.totalSets = totalSets
            self.completedSets = completedSets
            self.totalSessionSets = totalSessionSets
            self.startedAt = startedAt
            self.restEndsAt = restEndsAt
            self.nextExerciseName = nextExerciseName
            self.isCompleted = isCompleted
        }

        public var isResting: Bool {
            guard let restEndsAt else { return false }
            return restEndsAt > Date()
        }
    }

    public var workoutId: String

    public init(workoutId: String) {
        self.workoutId = workoutId
    }
}
