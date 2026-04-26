import Foundation

nonisolated struct ActiveWorkoutDraft: Codable, Sendable {
    var session: WorkoutSession
    var currentExerciseIndex: Int
    var currentSetIndex: Int
    var plannedExercises: [PlannedExercise]

    enum CodingKeys: String, CodingKey {
        case session, currentExerciseIndex, currentSetIndex, plannedExercises
    }

    init(
        session: WorkoutSession,
        currentExerciseIndex: Int,
        currentSetIndex: Int,
        plannedExercises: [PlannedExercise]
    ) {
        self.session = session
        self.currentExerciseIndex = currentExerciseIndex
        self.currentSetIndex = currentSetIndex
        self.plannedExercises = plannedExercises
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.session = try c.decode(WorkoutSession.self, forKey: .session)
        self.currentExerciseIndex = try c.decodeIfPresent(Int.self, forKey: .currentExerciseIndex) ?? 0
        self.currentSetIndex = try c.decodeIfPresent(Int.self, forKey: .currentSetIndex) ?? 0
        self.plannedExercises = try c.decodeIfPresent([PlannedExercise].self, forKey: .plannedExercises) ?? []
    }
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
        self.version = try c.decodeIfPresent(Int.self, forKey: .version) ?? 0
        self.hasCompletedOnboarding = try c.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
        self.profile = try c.decodeIfPresent(UserProfile.self, forKey: .profile) ?? UserProfile()
        self.currentPlan = try c.decodeIfPresent(WorkoutPlan.self, forKey: .currentPlan)
        self.workoutHistory = try c.decodeIfPresent([WorkoutSession].self, forKey: .workoutHistory) ?? []
        self.personalRecords = try c.decodeIfPresent([PersonalRecord].self, forKey: .personalRecords) ?? []
        self.progressEntries = try c.decodeIfPresent([ProgressEntry].self, forKey: .progressEntries) ?? []
        self.favoriteExerciseIds = try c.decodeIfPresent([String].self, forKey: .favoriteExerciseIds) ?? []
        self.progressionStates = try c.decodeIfPresent([ExerciseProgressionState].self, forKey: .progressionStates) ?? []
        self.trainingPhaseState = try c.decodeIfPresent(TrainingPhaseState.self, forKey: .trainingPhaseState) ?? TrainingPhaseState()
        self.coachAdjustments = try c.decodeIfPresent([CoachAdjustment].self, forKey: .coachAdjustments) ?? []
        self.appliedActionIds = try c.decodeIfPresent([String].self, forKey: .appliedActionIds) ?? []
        self.weekAdjustmentActive = try c.decodeIfPresent(CoachAdjustmentType.self, forKey: .weekAdjustmentActive)
        self.previousPlanBeforeWeekAction = try c.decodeIfPresent(WorkoutPlan.self, forKey: .previousPlanBeforeWeekAction)
        self.weeklyReviewDismissed = try c.decodeIfPresent(Bool.self, forKey: .weeklyReviewDismissed) ?? false
        self.todaysReadiness = try c.decodeIfPresent(DailyReadiness.self, forKey: .todaysReadiness)
        self.readinessHistory = try c.decodeIfPresent([DailyReadiness].self, forKey: .readinessHistory) ?? []
        self.notificationSettings = try c.decodeIfPresent(NotificationSettings.self, forKey: .notificationSettings) ?? NotificationSettings()
        self.nutritionTarget = try c.decodeIfPresent(NutritionTarget.self, forKey: .nutritionTarget) ?? NutritionTarget()
        self.nutritionLogs = try c.decodeIfPresent([DailyNutritionLog].self, forKey: .nutritionLogs) ?? []
        self.bodyWeightEntries = try c.decodeIfPresent([BodyWeightEntry].self, forKey: .bodyWeightEntries) ?? []
        self.sleepEntries = try c.decodeIfPresent([SleepEntry].self, forKey: .sleepEntries) ?? []
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
            let preservedURL = quarantineUnreadableState(at: url, error: error)
            print("[STRQ] Persistence load failed - using defaults: \(error)")
            if let preservedURL {
                print("[STRQ] Unreadable local state preserved at \(preservedURL.lastPathComponent)")
            }
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

    private func quarantineUnreadableState(at url: URL, error: Error) -> URL? {
        let backupURL = backupURL(for: url)
        let loadError = error.localizedDescription
        do {
            try FileManager.default.moveItem(at: url, to: backupURL)
            let backupName = backupURL.lastPathComponent
            Task { @MainActor in
                ErrorReporter.shared.reportMessage("Local persistence decode failed: \(loadError)", level: .error, context: [
                    "source": "local_persistence",
                    "state": "quarantined",
                    "backup": backupName
                ])
            }
            return backupURL
        } catch {
            let quarantineError = error.localizedDescription
            Task { @MainActor in
                ErrorReporter.shared.reportMessage("Local persistence quarantine failed: \(quarantineError)", level: .error, context: [
                    "source": "local_persistence",
                    "state": "quarantine_failed"
                ])
            }
            print("[STRQ] Persistence quarantine failed: \(error)")
            return nil
        }
    }

    private func backupURL(for url: URL) -> URL {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let stamp = formatter.string(from: Date())
        let name = "strq_state_v1.corrupt-\(stamp)-\(UUID().uuidString).json"
        return url.deletingLastPathComponent().appendingPathComponent(name)
    }
}
