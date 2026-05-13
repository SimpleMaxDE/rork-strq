#if DEBUG
import Foundation

@MainActor
extension AppViewModel {
    @discardableResult
    func installUITestFixtureIfRequested() -> Bool {
        let args = ProcessInfo.processInfo.arguments
        guard let flagIndex = args.firstIndex(of: "-STRQUIFixture"),
              args.indices.contains(flagIndex + 1),
              args[flagIndex + 1] == "coreFlow" else {
            return false
        }

        installCoreFlowFixture()
        return true
    }

    private func installCoreFlowFixture() {
        let calendar = Calendar.current
        let now = Date()
        let todayWeekday = calendar.component(.weekday, from: now)

        var testProfile = UserProfile()
        testProfile.name = "Max"
        testProfile.gender = .male
        testProfile.age = 31
        testProfile.heightCm = 183
        testProfile.weightKg = 86
        testProfile.goal = .muscleGain
        testProfile.trainingLevel = .intermediate
        testProfile.trainingMonths = 42
        testProfile.daysPerWeek = 4
        testProfile.minutesPerSession = 55
        testProfile.splitPreference = .upperLower
        testProfile.trainingLocation = .gym
        testProfile.availableEquipment = [.barbell, .dumbbell, .cable, .machine, .bench, .pullUpBar]
        testProfile.focusMuscles = [.chest, .back, .shoulders]
        testProfile.sleepQuality = .good
        testProfile.stressLevel = .moderate
        testProfile.activityLevel = .moderatelyActive
        testProfile.recoveryCapacity = .high
        testProfile.hasCompletedOnboarding = true
        testProfile.preferredTrainingDays = [
            todayWeekday,
            calendar.weekdayOffset(from: todayWeekday, by: 2),
            calendar.weekdayOffset(from: todayWeekday, by: 4),
            calendar.weekdayOffset(from: todayWeekday, by: 6)
        ]
        testProfile.coachingPreferences = CoachingPreferences(
            tone: .balanced,
            density: .standard,
            emphasis: .performance,
            automation: .guided
        )

        let upperStrength = WorkoutDay(
            id: "ui-core-upper-strength",
            name: "Upper Strength",
            focusMuscles: [.chest, .back, .shoulders],
            exercises: [
                PlannedExercise(exerciseId: "barbell-bench-press", sets: 3, reps: "6-8", restSeconds: 0, rpe: 8, notes: "Keep the last rep clean.", order: 0, coachDefault: CoachDefault(sets: 3, reps: "6-8", restSeconds: 0, rpe: 8, role: "Anchor")),
                PlannedExercise(exerciseId: "lat-pulldown", sets: 3, reps: "8-10", restSeconds: 0, rpe: 8, order: 1, coachDefault: CoachDefault(sets: 3, reps: "8-10", restSeconds: 0, rpe: 8, role: "Volume")),
                PlannedExercise(exerciseId: "dumbbell-row", sets: 3, reps: "10-12", restSeconds: 0, rpe: 7, order: 2),
                PlannedExercise(exerciseId: "dumbbell-shoulder-press", sets: 2, reps: "8-10", restSeconds: 0, rpe: 7, order: 3),
                PlannedExercise(exerciseId: "tricep-pushdown", sets: 2, reps: "12-15", restSeconds: 0, rpe: 7, order: 4)
            ],
            dayIndex: 0,
            warmupHint: "5 min incline walk, band pull-aparts, then two bench ramp sets.",
            estimatedMinutes: 54,
            scheduledWeekday: todayWeekday
        )

        let lowerPower = WorkoutDay(
            id: "ui-core-lower-power",
            name: "Lower Power",
            focusMuscles: [.quads, .hamstrings, .glutes],
            exercises: [
                PlannedExercise(exerciseId: "barbell-squat", sets: 3, reps: "5-6", restSeconds: 0, rpe: 8, order: 0),
                PlannedExercise(exerciseId: "romanian-deadlift", sets: 3, reps: "8-10", restSeconds: 0, rpe: 8, order: 1),
                PlannedExercise(exerciseId: "leg-press", sets: 2, reps: "10-12", restSeconds: 0, rpe: 7, order: 2)
            ],
            dayIndex: 1,
            warmupHint: "Bike easy, hip airplanes, then squat ramp sets.",
            estimatedMinutes: 58,
            scheduledWeekday: calendar.weekdayOffset(from: todayWeekday, by: 2)
        )

        let pullVolume = WorkoutDay(
            id: "ui-core-pull-volume",
            name: "Pull Volume",
            focusMuscles: [.back, .lats, .biceps],
            exercises: [
                PlannedExercise(exerciseId: "pull-up", sets: 3, reps: "6-8", restSeconds: 0, rpe: 8, order: 0),
                PlannedExercise(exerciseId: "seated-cable-row", sets: 3, reps: "10-12", restSeconds: 0, rpe: 7, order: 1),
                PlannedExercise(exerciseId: "hammer-curl", sets: 2, reps: "12-15", restSeconds: 0, rpe: 7, order: 2)
            ],
            dayIndex: 2,
            warmupHint: "Scap pull-ups, pulldown ramp sets, and light curls.",
            estimatedMinutes: 48,
            scheduledWeekday: calendar.weekdayOffset(from: todayWeekday, by: 4)
        )

        let sessions = [
            Self.completedSession(
                planId: "ui-core-plan",
                dayId: "ui-history-upper-1",
                dayName: "Upper Strength",
                daysAgo: 2,
                durationMinutes: 57,
                logs: [
                    Self.log("barbell-bench-press", [(80, 8), (82.5, 7), (82.5, 6)]),
                    Self.log("lat-pulldown", [(70, 10), (72.5, 9), (72.5, 8)]),
                    Self.log("dumbbell-row", [(34, 12), (34, 11), (34, 10)])
                ]
            ),
            Self.completedSession(
                planId: "ui-core-plan",
                dayId: "ui-history-lower-1",
                dayName: "Lower Power",
                daysAgo: 5,
                durationMinutes: 61,
                logs: [
                    Self.log("barbell-squat", [(105, 6), (107.5, 5), (107.5, 5)]),
                    Self.log("romanian-deadlift", [(95, 9), (95, 8), (95, 8)]),
                    Self.log("leg-press", [(180, 12), (185, 10)])
                ]
            ),
            Self.completedSession(
                planId: "ui-core-plan",
                dayId: "ui-history-pull-1",
                dayName: "Pull Volume",
                daysAgo: 8,
                durationMinutes: 50,
                logs: [
                    Self.log("pull-up", [(0, 8), (0, 7), (0, 6)]),
                    Self.log("seated-cable-row", [(75, 12), (77.5, 10), (77.5, 10)]),
                    Self.log("hammer-curl", [(18, 12), (18, 11)])
                ]
            )
        ]

        let readiness = DailyReadiness(
            date: now,
            sleepQuality: .good,
            energyLevel: .great,
            stressLevel: .okay,
            soreness: .mild,
            motivation: .veryHigh
        )

        profile = testProfile
        hasCompletedOnboarding = true
        currentPlan = WorkoutPlan(
            id: "ui-core-plan",
            name: "STRQ Upper/Lower",
            description: "A deterministic UI snapshot plan for the core product flow.",
            days: [upperStrength, lowerPower, pullVolume],
            createdAt: calendar.date(byAdding: .day, value: -21, to: now) ?? now,
            splitType: "Upper/Lower",
            durationWeeks: 8,
            explanation: "Built for stable Core Flow UI snapshots."
        )
        workoutHistory = sessions
        personalRecords = [
            PersonalRecord(exerciseId: "barbell-bench-press", weight: 82.5, reps: 8, date: sessions[0].startTime, estimatedOneRepMax: 104.5),
            PersonalRecord(exerciseId: "barbell-squat", weight: 107.5, reps: 6, date: sessions[1].startTime, estimatedOneRepMax: 129.0)
        ]
        progressEntries = sessions.map { session in
            let coverage = ProgressMuscleCoverageCalculator.calculate(for: session, library: library)
            return ProgressEntry(
                date: session.startTime,
                muscleGroupVolume: coverage.muscleGroupVolume,
                totalSets: session.completedSetCount,
                totalReps: session.completedRepCount,
                totalVolume: session.totalVolume,
                workoutDuration: max(1, Int((session.endTime ?? session.startTime).timeIntervalSince(session.startTime) / 60))
            )
        }
        recommendations = []
        favoriteExerciseIds = ["barbell-bench-press", "lat-pulldown"]
        activeWorkout = nil
        workoutMinimized = false
        completedWorkoutHandoff = nil
        showPreWorkoutHandoff = false
        handoffDay = nil
        todaysReadiness = readiness
        readinessHistory = [
            readiness,
            DailyReadiness(date: calendar.date(byAdding: .day, value: -1, to: now) ?? now, sleepQuality: .good, energyLevel: .good),
            DailyReadiness(date: calendar.date(byAdding: .day, value: -3, to: now) ?? now, sleepQuality: .great, energyLevel: .good)
        ]
        trainingPhaseState = TrainingPhaseState()
        coachAdjustments = []
        appliedActionIds = []
        weekAdjustmentActive = nil
        previousPlanBeforeWeekAction = nil
        weeklyReviewDismissed = false
        notificationSettings = NotificationSettings()
        nutritionTarget = NutritionTarget()
        nutritionLogs = []
        bodyWeightEntries = []
        sleepEntries = [
            SleepEntry(date: calendar.date(byAdding: .day, value: -1, to: now) ?? now, hoursSlept: 7.6, quality: .good),
            SleepEntry(date: calendar.date(byAdding: .day, value: -2, to: now) ?? now, hoursSlept: 7.2, quality: .good)
        ]
        familyResponseProfile = .empty

        refreshFamilyResponseProfile()
        refreshIntelligence()
        refreshNutritionInsights()
        refreshDailyState()
    }

    private static func completedSession(
        planId: String,
        dayId: String,
        dayName: String,
        daysAgo: Int,
        durationMinutes: Int,
        logs: [ExerciseLog]
    ) -> WorkoutSession {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        let end = calendar.date(byAdding: .minute, value: durationMinutes, to: start)
        let totalVolume = logs.reduce(0.0) { total, log in
            total + log.sets.filter(\.isCompleted).reduce(0.0) { $0 + $1.weight * Double($1.reps) }
        }
        return WorkoutSession(
            planId: planId,
            dayId: dayId,
            dayName: dayName,
            startTime: start,
            endTime: end,
            exerciseLogs: logs,
            isCompleted: true,
            totalVolume: totalVolume
        )
    }

    private static func log(_ exerciseId: String, _ sets: [(Double, Int)]) -> ExerciseLog {
        ExerciseLog(
            exerciseId: exerciseId,
            sets: sets.enumerated().map { index, set in
                SetLog(
                    setNumber: index + 1,
                    weight: set.0,
                    reps: set.1,
                    isCompleted: true,
                    rpe: index == sets.count - 1 ? 8 : 7.5,
                    quality: index == sets.count - 1 ? .onTarget : nil
                )
            },
            isCompleted: true
        )
    }
}

private extension Calendar {
    func weekdayOffset(from weekday: Int, by offset: Int) -> Int {
        ((weekday - 1 + offset) % 7) + 1
    }
}
#endif
