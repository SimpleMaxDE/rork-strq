import Foundation

nonisolated struct ActiveWorkoutDraft: Codable, Sendable {
    var session: WorkoutSession
    var currentExerciseIndex: Int
    var currentSetIndex: Int
    var plannedExercises: [PlannedExercise]
}

nonisolated struct PersistedAppState: Codable, Sendable {
    var version: Int
    var hasCompletedOnboarding: Bool
    var profile: UserProfile
    var currentPlan: WorkoutPlan?
    var workoutHistory: [WorkoutSession]
    var personalRecords: [PersonalRecord]
    var progressEntries: [ProgressEntry]
    var favoriteExerciseIds: [String]
    var progressionStates: [ExerciseProgressionState]
    var trainingPhaseState: TrainingPhaseState
    var coachAdjustments: [CoachAdjustment]
    var appliedActionIds: [String]
    var weekAdjustmentActive: CoachAdjustmentType?
    var previousPlanBeforeWeekAction: WorkoutPlan?
    var weeklyReviewDismissed: Bool
    var todaysReadiness: DailyReadiness?
    var readinessHistory: [DailyReadiness]
    var notificationSettings: NotificationSettings
    var nutritionTarget: NutritionTarget
    var nutritionLogs: [DailyNutritionLog]
    var bodyWeightEntries: [BodyWeightEntry]
    var sleepEntries: [SleepEntry]
    var activeWorkoutDraft: ActiveWorkoutDraft?
}

nonisolated final class PersistenceStore: Sendable {
    static let shared = PersistenceStore()

    private let stateFilename = "strq_state_v1.json"
    private let currentVersion = 1

    private var stateURL: URL {
        let dir = (try? FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )) ?? FileManager.default.temporaryDirectory
        return dir.appendingPathComponent(stateFilename)
    }

    func load() -> PersistedAppState? {
        let url = stateURL
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(PersistedAppState.self, from: data)
        } catch {
            print("[STRQ] Persistence load failed — using defaults: \(error)")
            try? FileManager.default.removeItem(at: url)
            return nil
        }
    }

    func save(_ state: PersistedAppState) {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(state)
            try data.write(to: stateURL, options: [.atomic])
        } catch {
            print("[STRQ] Persistence save failed: \(error)")
        }
    }

    func clear() {
        let url = stateURL
        try? FileManager.default.removeItem(at: url)
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
    }

    var version: Int { currentVersion }
}
