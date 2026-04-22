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
    var familyResponseProfile: ExerciseFamilyResponseProfile?

    enum CodingKeys: String, CodingKey {
        case version, hasCompletedOnboarding, profile, currentPlan, workoutHistory
        case personalRecords, progressEntries, favoriteExerciseIds, progressionStates
        case trainingPhaseState, coachAdjustments, appliedActionIds, weekAdjustmentActive
        case previousPlanBeforeWeekAction, weeklyReviewDismissed, todaysReadiness
        case readinessHistory, notificationSettings, nutritionTarget, nutritionLogs
        case bodyWeightEntries, sleepEntries, activeWorkoutDraft, familyResponseProfile
    }

    init(
        version: Int,
        hasCompletedOnboarding: Bool,
        profile: UserProfile,
        currentPlan: WorkoutPlan?,
        workoutHistory: [WorkoutSession],
        personalRecords: [PersonalRecord],
        progressEntries: [ProgressEntry],
        favoriteExerciseIds: [String],
        progressionStates: [ExerciseProgressionState],
        trainingPhaseState: TrainingPhaseState,
        coachAdjustments: [CoachAdjustment],
        appliedActionIds: [String],
        weekAdjustmentActive: CoachAdjustmentType?,
        previousPlanBeforeWeekAction: WorkoutPlan?,
        weeklyReviewDismissed: Bool,
        todaysReadiness: DailyReadiness?,
        readinessHistory: [DailyReadiness],
        notificationSettings: NotificationSettings,
        nutritionTarget: NutritionTarget,
        nutritionLogs: [DailyNutritionLog],
        bodyWeightEntries: [BodyWeightEntry],
        sleepEntries: [SleepEntry],
        activeWorkoutDraft: ActiveWorkoutDraft?,
        familyResponseProfile: ExerciseFamilyResponseProfile? = nil
    ) {
        self.version = version
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.profile = profile
        self.currentPlan = currentPlan
        self.workoutHistory = workoutHistory
        self.personalRecords = personalRecords
        self.progressEntries = progressEntries
        self.favoriteExerciseIds = favoriteExerciseIds
        self.progressionStates = progressionStates
        self.trainingPhaseState = trainingPhaseState
        self.coachAdjustments = coachAdjustments
        self.appliedActionIds = appliedActionIds
        self.weekAdjustmentActive = weekAdjustmentActive
        self.previousPlanBeforeWeekAction = previousPlanBeforeWeekAction
        self.weeklyReviewDismissed = weeklyReviewDismissed
        self.todaysReadiness = todaysReadiness
        self.readinessHistory = readinessHistory
        self.notificationSettings = notificationSettings
        self.nutritionTarget = nutritionTarget
        self.nutritionLogs = nutritionLogs
        self.bodyWeightEntries = bodyWeightEntries
        self.sleepEntries = sleepEntries
        self.activeWorkoutDraft = activeWorkoutDraft
        self.familyResponseProfile = familyResponseProfile
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try c.decode(Int.self, forKey: .version)
        self.hasCompletedOnboarding = try c.decode(Bool.self, forKey: .hasCompletedOnboarding)
        self.profile = try c.decode(UserProfile.self, forKey: .profile)
        self.currentPlan = try c.decodeIfPresent(WorkoutPlan.self, forKey: .currentPlan)
        self.workoutHistory = try c.decode([WorkoutSession].self, forKey: .workoutHistory)
        self.personalRecords = try c.decode([PersonalRecord].self, forKey: .personalRecords)
        self.progressEntries = try c.decode([ProgressEntry].self, forKey: .progressEntries)
        self.favoriteExerciseIds = try c.decode([String].self, forKey: .favoriteExerciseIds)
        self.progressionStates = try c.decode([ExerciseProgressionState].self, forKey: .progressionStates)
        self.trainingPhaseState = try c.decode(TrainingPhaseState.self, forKey: .trainingPhaseState)
        self.coachAdjustments = try c.decode([CoachAdjustment].self, forKey: .coachAdjustments)
        self.appliedActionIds = try c.decode([String].self, forKey: .appliedActionIds)
        self.weekAdjustmentActive = try c.decodeIfPresent(CoachAdjustmentType.self, forKey: .weekAdjustmentActive)
        self.previousPlanBeforeWeekAction = try c.decodeIfPresent(WorkoutPlan.self, forKey: .previousPlanBeforeWeekAction)
        self.weeklyReviewDismissed = try c.decode(Bool.self, forKey: .weeklyReviewDismissed)
        self.todaysReadiness = try c.decodeIfPresent(DailyReadiness.self, forKey: .todaysReadiness)
        self.readinessHistory = try c.decode([DailyReadiness].self, forKey: .readinessHistory)
        self.notificationSettings = try c.decode(NotificationSettings.self, forKey: .notificationSettings)
        self.nutritionTarget = try c.decode(NutritionTarget.self, forKey: .nutritionTarget)
        self.nutritionLogs = try c.decode([DailyNutritionLog].self, forKey: .nutritionLogs)
        self.bodyWeightEntries = try c.decode([BodyWeightEntry].self, forKey: .bodyWeightEntries)
        self.sleepEntries = try c.decode([SleepEntry].self, forKey: .sleepEntries)
        self.activeWorkoutDraft = try c.decodeIfPresent(ActiveWorkoutDraft.self, forKey: .activeWorkoutDraft)
        // Tolerant: pre-existing snapshots will be missing this; fall back to nil.
        self.familyResponseProfile = try c.decodeIfPresent(ExerciseFamilyResponseProfile.self, forKey: .familyResponseProfile)
    }
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
