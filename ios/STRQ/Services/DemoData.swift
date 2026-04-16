import Foundation

struct DemoData {
    static let profile: UserProfile = {
        var p = UserProfile()
        p.name = "Alex"
        p.age = 28
        p.gender = .male
        p.heightCm = 180
        p.weightKg = 82
        p.bodyFatPercentage = 16
        p.goal = .muscleGain
        p.trainingLevel = .intermediate
        p.trainingMonths = 24
        p.daysPerWeek = 4
        p.minutesPerSession = 60
        p.splitPreference = .automatic
        p.trainingLocation = .gym
        p.availableEquipment = Equipment.allCases
        p.injuries = []
        p.focusMuscles = [.chest, .back, .glutes]
        p.sleepQuality = .good
        p.stressLevel = .moderate
        p.activityLevel = .moderatelyActive
        p.recoveryCapacity = .moderate
        p.hasCompletedOnboarding = true
        return p
    }()

    static let workoutHistory: [WorkoutSession] = {
        let calendar = Calendar.current
        var sessions: [WorkoutSession] = []
        let dayNames = ["Upper A", "Lower A", "Upper B", "Lower B"]

        for weekOffset in 0..<6 {
            for dayIdx in 0..<4 {
                let daysBack = weekOffset * 7 + (dayIdx * 2)
                guard let date = calendar.date(byAdding: .day, value: -daysBack, to: Date()) else { continue }
                let duration = Int.random(in: 45...75)
                let volume = Double.random(in: 8000...16000)

                var session = WorkoutSession(
                    planId: "demo-plan",
                    dayId: "day-\(dayIdx)",
                    dayName: dayNames[dayIdx % dayNames.count],
                    startTime: date,
                    endTime: calendar.date(byAdding: .minute, value: duration, to: date),
                    isCompleted: true,
                    totalVolume: volume
                )

                let exerciseIds = ["barbell-bench-press", "dumbbell-row", "barbell-squat", "romanian-deadlift", "lateral-raise", "tricep-pushdown"]
                session.exerciseLogs = exerciseIds.prefix(Int.random(in: 4...6)).enumerated().map { idx, exId in
                    ExerciseLog(
                        exerciseId: exId,
                        sets: (1...4).map { setNum in
                            SetLog(setNumber: setNum, weight: Double.random(in: 40...100), reps: Int.random(in: 6...12), isCompleted: true)
                        },
                        isCompleted: true
                    )
                }
                sessions.append(session)
            }
        }
        return sessions.sorted { $0.startTime > $1.startTime }
    }()

    static let personalRecords: [PersonalRecord] = [
        PersonalRecord(exerciseId: "barbell-bench-press", weight: 100, reps: 5, date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!, estimatedOneRepMax: 112),
        PersonalRecord(exerciseId: "barbell-squat", weight: 130, reps: 5, date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!, estimatedOneRepMax: 146),
        PersonalRecord(exerciseId: "deadlift", weight: 150, reps: 3, date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, estimatedOneRepMax: 159),
        PersonalRecord(exerciseId: "overhead-press", weight: 60, reps: 6, date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!, estimatedOneRepMax: 70),
        PersonalRecord(exerciseId: "dumbbell-row", weight: 40, reps: 10, date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!, estimatedOneRepMax: 53),
        PersonalRecord(exerciseId: "barbell-bench-press", weight: 95, reps: 6, date: Calendar.current.date(byAdding: .day, value: -14, to: Date())!, estimatedOneRepMax: 110),
        PersonalRecord(exerciseId: "barbell-squat", weight: 125, reps: 5, date: Calendar.current.date(byAdding: .day, value: -18, to: Date())!, estimatedOneRepMax: 141),
    ]

    static let progressEntries: [ProgressEntry] = {
        let calendar = Calendar.current
        return (0..<42).compactMap { dayOffset -> ProgressEntry? in
            guard dayOffset % 2 == 0 else { return nil }
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { return nil }
            let baseWeight = 82.0
            let trend = Double(dayOffset) * 0.02
            return ProgressEntry(
                date: date,
                bodyWeight: baseWeight - trend + Double.random(in: -0.3...0.3),
                muscleGroupVolume: [
                    "chest": Double.random(in: 3000...6000),
                    "back": Double.random(in: 3500...7000),
                    "shoulders": Double.random(in: 1500...3000),
                    "quads": Double.random(in: 4000...8000),
                    "hamstrings": Double.random(in: 2000...4500),
                    "glutes": Double.random(in: 2500...5000),
                    "arms": Double.random(in: 1500...3500),
                    "abs": Double.random(in: 800...2000),
                ],
                totalSets: Int.random(in: 16...28),
                totalReps: Int.random(in: 100...250),
                totalVolume: Double.random(in: 8000...18000),
                workoutDuration: Int.random(in: 45...75)
            )
        }
    }()

    static let recommendations: [Recommendation] = {
        let engine = CoachingEngine()
        let generated = engine.generateRecommendations(
            profile: profile,
            workoutHistory: workoutHistory,
            progressEntries: progressEntries,
            personalRecords: personalRecords,
            muscleBalance: muscleBalance
        )
        if generated.isEmpty {
            return [
                Recommendation(type: .volumeImbalance, title: "Balance Your Back Training", message: "Your chest volume is 20% higher than back volume this week. Consider adding an extra set of rows to maintain balance.", priority: 2),
                Recommendation(type: .progressionSuggestion, title: "Ready to Progress", message: "You've hit 100kg for 5 reps on Bench Press consistently. Consider progressing to 102.5kg next session.", priority: 1),
                Recommendation(type: .recoveryConcern, title: "Watch Your Recovery", message: "You've trained 4 consecutive days. Consider a rest day to optimize muscle recovery and growth.", priority: 2),
            ]
        }
        return generated
    }()

    static let insights: [SmartInsight] = {
        let engine = CoachingEngine()
        let generated = engine.generateInsights(
            profile: profile,
            workoutHistory: workoutHistory,
            progressEntries: progressEntries,
            personalRecords: personalRecords,
            currentPlan: nil,
            muscleBalance: muscleBalance
        )
        if generated.isEmpty {
            return [
                SmartInsight(icon: "chart.bar.fill", color: "orange", title: "Chest > Back This Week", message: "You trained chest 20% more than back. Add a rowing set to balance.", severity: .medium, category: .volumeBalance),
                SmartInsight(icon: "arrow.up.forward.circle.fill", color: "green", title: "Frequency Improved", message: "You trained 4 times this week vs 3 last week. Great consistency!", severity: .positive, category: .consistency),
                SmartInsight(icon: "trophy.fill", color: "yellow", title: "New Best Set", message: "Bench Press: 100kg × 5 — a 5kg improvement over last month.", severity: .positive, category: .progression),
                SmartInsight(icon: "calendar.badge.checkmark", color: "blue", title: "Most Consistent On Mondays", message: "You've trained every Monday for the past 6 weeks. Strong habit!", severity: .positive, category: .consistency),
            ]
        }
        return generated
    }()

    static var streak: Int { 12 }

    static let weeklyActivity: [DayActivity] = {
        let calendar = Calendar.current
        let weekdaySymbols = ["S", "M", "T", "W", "T", "F", "S"]
        return (0..<7).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: Date())!
            let weekday = calendar.component(.weekday, from: date) - 1
            let trained = offset != 3 && offset != 6
            return DayActivity(
                label: weekdaySymbols[weekday],
                date: date,
                didTrain: trained,
                volume: trained ? Double.random(in: 8000...16000) : 0,
                duration: trained ? Int.random(in: 45...70) : 0
            )
        }
    }()

    static let muscleBalance: [MuscleBalanceEntry] = [
        MuscleBalanceEntry(muscle: "Chest", thisWeek: 5200, average: 4800),
        MuscleBalanceEntry(muscle: "Back", thisWeek: 4100, average: 5000),
        MuscleBalanceEntry(muscle: "Shoulders", thisWeek: 2400, average: 2200),
        MuscleBalanceEntry(muscle: "Quads", thisWeek: 5500, average: 6200),
        MuscleBalanceEntry(muscle: "Hamstrings", thisWeek: 3200, average: 3500),
        MuscleBalanceEntry(muscle: "Glutes", thisWeek: 3800, average: 3600),
        MuscleBalanceEntry(muscle: "Arms", thisWeek: 2600, average: 2400),
        MuscleBalanceEntry(muscle: "Abs", thisWeek: 1200, average: 1400),
    ]

    static let strengthProgress: [StrengthEntry] = {
        let calendar = Calendar.current
        return (0..<8).reversed().map { weekOffset in
            let date = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: Date())!
            let base = 100.0 - Double(weekOffset) * 1.8
            return StrengthEntry(
                date: date,
                bench: base + Double.random(in: -2...2),
                squat: base * 1.3 + Double.random(in: -3...3),
                deadlift: base * 1.5 + Double.random(in: -3...3),
                ohp: base * 0.6 + Double.random(in: -1...1)
            )
        }
    }()

    static let progressionStates: [ExerciseProgressionState] = [
        ExerciseProgressionState(
            exerciseId: "barbell-bench-press",
            lastWeight: 100,
            lastReps: 5,
            lastRPE: 8.5,
            sessionCount: 12,
            consecutiveSamePerformance: 0,
            plateauStatus: .progressing,
            recommendedStrategy: .loadFirst,
            suggestedNextWeight: 102.5,
            suggestedNextReps: "5",
            performanceTrend: [5000, 4800, 4600, 4400, 4200, 4000],
            coachNote: "Making good progress. Add a small increment next session while maintaining rep quality."
        ),
        ExerciseProgressionState(
            exerciseId: "barbell-squat",
            lastWeight: 130,
            lastReps: 5,
            lastRPE: 9.0,
            sessionCount: 10,
            consecutiveSamePerformance: 0,
            plateauStatus: .progressing,
            recommendedStrategy: .loadFirst,
            suggestedNextWeight: 132.5,
            suggestedNextReps: "5",
            performanceTrend: [6500, 6300, 6100, 5900, 5700],
            coachNote: "Strong squat progress. Recovery supports another small increase."
        ),
        ExerciseProgressionState(
            exerciseId: "lateral-raise",
            lastWeight: 12,
            lastReps: 12,
            lastRPE: 8.0,
            sessionCount: 8,
            consecutiveSamePerformance: 3,
            plateauStatus: .plateaued,
            recommendedStrategy: .doubleProgression,
            suggestedNextWeight: 12,
            suggestedNextReps: "13-15",
            performanceTrend: [1440, 1440, 1440, 1380],
            coachNote: "Performance has plateaued. Try adding 1-2 reps before increasing weight, or switch to a similar exercise for fresh stimulus."
        ),
        ExerciseProgressionState(
            exerciseId: "dumbbell-row",
            lastWeight: 40,
            lastReps: 10,
            lastRPE: 7.5,
            sessionCount: 9,
            consecutiveSamePerformance: 0,
            plateauStatus: .progressing,
            recommendedStrategy: .doubleProgression,
            suggestedNextWeight: 40,
            suggestedNextReps: "11-12",
            performanceTrend: [4000, 3800, 3600, 3400],
            coachNote: "Working toward the top of your rep range. Once you hit it consistently, bump up the weight."
        ),
        ExerciseProgressionState(
            exerciseId: "tricep-pushdown",
            lastWeight: 30,
            lastReps: 12,
            lastRPE: 8.5,
            sessionCount: 7,
            consecutiveSamePerformance: 2,
            plateauStatus: .stalling,
            recommendedStrategy: .repFirst,
            suggestedNextWeight: 30,
            suggestedNextReps: "13-14",
            performanceTrend: [3600, 3600, 3500, 3400],
            coachNote: "Progress is slowing slightly. Focus on rep quality and controlled tempo. Progression will come."
        ),
        ExerciseProgressionState(
            exerciseId: "romanian-deadlift",
            lastWeight: 100,
            lastReps: 8,
            lastRPE: 9.0,
            sessionCount: 11,
            consecutiveSamePerformance: 4,
            plateauStatus: .regressing,
            recommendedStrategy: .deloadAndRebuild,
            suggestedNextWeight: 85,
            suggestedNextReps: "8",
            performanceTrend: [7600, 7800, 8000, 8200, 8400],
            coachNote: "Performance is declining. Reduce load by 10-15% and rebuild with strict form. This is normal — it means you pushed hard."
        ),
    ]

    static let nutritionTarget: NutritionTarget = {
        let engine = NutritionCoachEngine()
        return engine.computeTargets(profile: profile)
    }()

    static let nutritionLogs: [DailyNutritionLog] = {
        let calendar = Calendar.current
        let target = nutritionTarget
        let scenarios: [(calOff: Int, proOff: Int, water: Double)] = [
            (0, 5, 2.8),
            (-150, -20, 2.2),
            (100, 10, 3.0),
            (-400, -50, 1.5),
            (50, 0, 2.5),
            (-100, -10, 2.0),
            (200, 15, 2.7),
            (-50, 5, 2.4),
            (-200, -35, 1.8),
            (0, -5, 2.6),
            (150, 10, 3.1),
            (-300, -40, 1.6),
            (50, 0, 2.3),
            (-100, -15, 2.0),
        ]
        return (0..<14).compactMap { dayOffset -> DailyNutritionLog? in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { return nil }
            let s = scenarios[dayOffset % scenarios.count]
            return DailyNutritionLog(
                date: date,
                calories: max(1200, target.calories + s.calOff),
                proteinGrams: max(60, target.proteinGrams + s.proOff),
                carbsGrams: max(80, (target.carbsGrams ?? 250) + s.calOff / 8),
                fatGrams: max(30, (target.fatGrams ?? 70) + s.calOff / 20),
                waterLiters: s.water
            )
        }
    }()

    static let bodyWeightEntries: [BodyWeightEntry] = {
        let calendar = Calendar.current
        let baseWeight = 82.0
        return (0..<28).compactMap { dayOffset -> BodyWeightEntry? in
            guard dayOffset % 2 == 0 else { return nil }
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { return nil }
            let trend = Double(dayOffset) * 0.015
            let weight = baseWeight - trend + Double.random(in: -0.3...0.3)
            let bf: Double? = dayOffset % 6 == 0 ? 16.0 - Double(dayOffset) * 0.03 + Double.random(in: -0.3...0.3) : nil
            return BodyWeightEntry(weightKg: weight, bodyFatPercent: bf)
        }.reversed().map { entry in
            var e = entry
            return e
        }
    }()

    static let sleepEntries: [SleepEntry] = {
        let calendar = Calendar.current
        let sleepPattern: [(Double, ReadinessLevel)] = [
            (7.5, .good), (6.0, .okay), (8.0, .great), (5.5, .poor),
            (7.0, .good), (7.5, .good), (6.5, .okay), (8.5, .great),
            (6.0, .poor), (7.0, .good), (7.5, .great), (5.0, .terrible),
            (7.0, .good), (8.0, .great)
        ]
        return (0..<14).compactMap { dayOffset -> SleepEntry? in
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { return nil }
            let pattern = sleepPattern[dayOffset % sleepPattern.count]
            return SleepEntry(date: date, hoursSlept: pattern.0, quality: pattern.1)
        }
    }()

    static let trainingPhaseState: TrainingPhaseState = {
        let calendar = Calendar.current
        return TrainingPhaseState(
            currentPhase: .push,
            weeksInPhase: 3,
            totalWeeksTrained: 12,
            lastPhaseChange: calendar.date(byAdding: .weekOfYear, value: -3, to: Date()) ?? Date(),
            phaseHistory: [
                PhaseEntry(phase: .build, startDate: calendar.date(byAdding: .weekOfYear, value: -12, to: Date())!, endDate: calendar.date(byAdding: .weekOfYear, value: -9, to: Date())!, reason: "Initial training block"),
                PhaseEntry(phase: .push, startDate: calendar.date(byAdding: .weekOfYear, value: -9, to: Date())!, endDate: calendar.date(byAdding: .weekOfYear, value: -5, to: Date())!, reason: "Work capacity established"),
                PhaseEntry(phase: .deload, startDate: calendar.date(byAdding: .weekOfYear, value: -5, to: Date())!, endDate: calendar.date(byAdding: .weekOfYear, value: -4, to: Date())!, reason: "Planned recovery after 4-week push"),
                PhaseEntry(phase: .build, startDate: calendar.date(byAdding: .weekOfYear, value: -4, to: Date())!, endDate: calendar.date(byAdding: .weekOfYear, value: -3, to: Date())!, reason: "Post-deload rebuild"),
                PhaseEntry(phase: .push, startDate: calendar.date(byAdding: .weekOfYear, value: -3, to: Date())!, reason: "Recovery strong, pushing for new PRs"),
            ]
        )
    }()
}

nonisolated enum InsightSeverity: String, Sendable, Comparable {
    case positive
    case low
    case medium
    case high

    var rank: Int {
        switch self {
        case .high: return 3
        case .medium: return 2
        case .low: return 1
        case .positive: return 0
        }
    }

    static func < (lhs: InsightSeverity, rhs: InsightSeverity) -> Bool {
        lhs.rank < rhs.rank
    }
}

nonisolated enum InsightCategory: String, Sendable {
    case volumeBalance
    case movementBalance
    case recovery
    case consistency
    case progression
    case bodyComposition
    case general

    var displayName: String {
        switch self {
        case .volumeBalance: return "Volume Balance"
        case .movementBalance: return "Movement Balance"
        case .recovery: return "Recovery"
        case .consistency: return "Consistency"
        case .progression: return "Progression"
        case .bodyComposition: return "Body Composition"
        case .general: return "General"
        }
    }

    var symbolName: String {
        switch self {
        case .volumeBalance: return "chart.bar.fill"
        case .movementBalance: return "arrow.left.arrow.right"
        case .recovery: return "heart.fill"
        case .consistency: return "calendar.badge.checkmark"
        case .progression: return "arrow.up.right"
        case .bodyComposition: return "figure.stand"
        case .general: return "lightbulb.fill"
        }
    }
}

nonisolated struct SmartInsight: Identifiable, Sendable {
    let id: String
    let icon: String
    let color: String
    let title: String
    let message: String
    let severity: InsightSeverity
    let category: InsightCategory

    var severityRank: Int { severity.rank }

    init(id: String = UUID().uuidString, icon: String, color: String, title: String, message: String, severity: InsightSeverity = .low, category: InsightCategory = .general) {
        self.id = id
        self.icon = icon
        self.color = color
        self.title = title
        self.message = message
        self.severity = severity
        self.category = category
    }
}

nonisolated struct DayActivity: Identifiable, Sendable {
    let id: String
    let label: String
    let date: Date
    let didTrain: Bool
    let volume: Double
    let duration: Int

    init(id: String = UUID().uuidString, label: String, date: Date, didTrain: Bool, volume: Double, duration: Int) {
        self.id = id
        self.label = label
        self.date = date
        self.didTrain = didTrain
        self.volume = volume
        self.duration = duration
    }
}

nonisolated struct MuscleBalanceEntry: Identifiable, Sendable {
    let id: String
    let muscle: String
    let thisWeek: Double
    let average: Double

    init(id: String = UUID().uuidString, muscle: String, thisWeek: Double, average: Double) {
        self.id = id
        self.muscle = muscle
        self.thisWeek = thisWeek
        self.average = average
    }

    var percentOfAverage: Double {
        guard average > 0 else { return 0 }
        return thisWeek / average
    }
}

nonisolated struct StrengthEntry: Identifiable, Sendable {
    let id: String
    let date: Date
    let bench: Double
    let squat: Double
    let deadlift: Double
    let ohp: Double

    init(id: String = UUID().uuidString, date: Date, bench: Double, squat: Double, deadlift: Double, ohp: Double) {
        self.id = id
        self.date = date
        self.bench = bench
        self.squat = squat
        self.deadlift = deadlift
        self.ohp = ohp
    }
}
