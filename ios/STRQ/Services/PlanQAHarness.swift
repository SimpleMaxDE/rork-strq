import Foundation

// Generator QA / scenario stress test.
//
// Runs `PlanGenerator` across a matrix of realistic user scenarios and
// produces a structured `PlanQAReport` describing output sanity per plan.
// This is an internal validation tool — it does not change user-facing
// behavior. When `PlanGenerator` or `ImportedExerciseReadinessService`
// changes, re-running the harness surfaces regressions (missing anchors,
// movement-pattern overload, imported pollution, weak home plans, etc.)
// without hand-eyeballing every profile.
@MainActor
struct PlanQAHarness: Sendable {
    private let library = ExerciseLibrary.shared

    func run() -> PlanQAReport {
        let scenarios = Self.scenarioMatrix()
        let generator = PlanGenerator()
        var diagnostics: [PlanScenarioDiagnostic] = []
        diagnostics.reserveCapacity(scenarios.count)

        for scenario in scenarios {
            let plan = generator.generate(
                for: scenario.profile,
                muscleBalance: scenario.muscleBalance,
                recentSessions: [],
                recoveryScore: scenario.recoveryScore,
                phase: scenario.phase
            )
            diagnostics.append(evaluate(plan: plan, scenario: scenario))
        }

        return PlanQAReport(scenarios: diagnostics, generatedAt: Date())
    }

    // MARK: - Scenario matrix

    nonisolated struct Scenario: Sendable {
        let label: String
        let profile: UserProfile
        let recoveryScore: Int
        let phase: TrainingPhase
        let muscleBalance: [MuscleBalanceEntry]
    }

    static func scenarioMatrix() -> [Scenario] {
        var out: [Scenario] = []

        // Core matrix: level × days × goal × location.
        let levels: [TrainingLevel] = [.beginner, .intermediate, .advanced]
        let dayCounts = [2, 3, 4, 5, 6]
        let goals: [FitnessGoal] = [.strength, .muscleGain, .fatLoss, .generalFitness, .athleticPerformance, .endurance, .flexibility, .rehabilitation]
        let locations: [TrainingLocation] = [.gym, .homeGym, .homeNoEquipment]

        for level in levels {
            for days in dayCounts {
                for goal in goals {
                    for location in locations {
                        // Trim the matrix: skip pairings that produce trivially
                        // redundant duplicates (endurance/flex/rehab on 5-6 days
                        // isn't how users actually configure those goals).
                        if (goal == .endurance || goal == .flexibility || goal == .rehabilitation) && days > 4 {
                            continue
                        }
                        let equipment: [Equipment] = {
                            switch location {
                            case .gym: return []
                            case .homeGym: return [.dumbbell, .bench, .pullUpBar, .resistanceBand]
                            case .homeNoEquipment: return [.none]
                            }
                        }()
                        let profile = UserProfile(
                            name: "",
                            age: 30,
                            gender: .preferNotToSay,
                            heightCm: 175,
                            weightKg: 75,
                            bodyFatPercentage: nil,
                            goal: goal,
                            trainingLevel: level,
                            trainingMonths: level == .beginner ? 3 : (level == .intermediate ? 18 : 60),
                            daysPerWeek: days,
                            minutesPerSession: 60,
                            splitPreference: .automatic,
                            trainingLocation: location,
                            availableEquipment: equipment,
                            injuries: [],
                            focusMuscles: [],
                            neglectMuscles: [],
                            preferredExercises: [],
                            avoidedExercises: [],
                            sleepQuality: .good,
                            stressLevel: .moderate,
                            activityLevel: .moderatelyActive,
                            recoveryCapacity: .moderate,
                            targetWeightKg: nil,
                            startWeightKg: nil,
                            hasCompletedOnboarding: true,
                            preferredTrainingDays: [],
                            nutritionTrackingEnabled: false,
                            coachingPreferences: CoachingPreferences()
                        )
                        out.append(Scenario(
                            label: "\(level.shortName) · \(days)d · \(goal.displayName) · \(location.displayName)",
                            profile: profile,
                            recoveryScore: 75,
                            phase: .build,
                            muscleBalance: []
                        ))
                    }
                }
            }
        }

        // Targeted edge cases — failure modes we explicitly want to catch.
        out.append(contentsOf: edgeCaseScenarios())

        return out
    }

    private static func edgeCaseScenarios() -> [Scenario] {
        var edge: [Scenario] = []

        // Low recovery.
        var p = baseProfile(.intermediate, goal: .muscleGain, days: 4, location: .gym)
        edge.append(Scenario(label: "Low recovery · 4d hypertrophy", profile: p, recoveryScore: 38, phase: .build, muscleBalance: []))

        // Push phase + high recovery.
        p = baseProfile(.advanced, goal: .strength, days: 4, location: .gym)
        edge.append(Scenario(label: "Push phase · advanced strength", profile: p, recoveryScore: 85, phase: .push, muscleBalance: []))

        // Deload.
        p = baseProfile(.intermediate, goal: .muscleGain, days: 4, location: .gym)
        edge.append(Scenario(label: "Deload · intermediate hypertrophy", profile: p, recoveryScore: 72, phase: .deload, muscleBalance: []))

        // Rebalance with lagging back.
        p = baseProfile(.intermediate, goal: .muscleGain, days: 5, location: .gym)
        let balance = [
            MuscleBalanceEntry(muscle: "Back", thisWeek: 4, average: 10),
            MuscleBalanceEntry(muscle: "Hamstrings", thisWeek: 3, average: 8),
        ]
        edge.append(Scenario(label: "Rebalance · lagging back + hamstrings", profile: p, recoveryScore: 72, phase: .rebalance, muscleBalance: balance))

        // Injury restriction — shoulder.
        p = baseProfile(.intermediate, goal: .muscleGain, days: 4, location: .gym)
        p.injuries = ["shoulder"]
        edge.append(Scenario(label: "Shoulder restriction · hypertrophy", profile: p, recoveryScore: 75, phase: .build, muscleBalance: []))

        // Injury restriction — knee + home no equipment.
        p = baseProfile(.beginner, goal: .generalFitness, days: 3, location: .homeNoEquipment)
        p.injuries = ["knee"]
        p.availableEquipment = [.none]
        edge.append(Scenario(label: "Knee restriction · home no-equipment", profile: p, recoveryScore: 75, phase: .build, muscleBalance: []))

        // Low recovery capacity (trait).
        p = baseProfile(.advanced, goal: .muscleGain, days: 6, location: .gym)
        p.recoveryCapacity = .low
        edge.append(Scenario(label: "Advanced · low recovery capacity", profile: p, recoveryScore: 70, phase: .build, muscleBalance: []))

        // High recovery capacity.
        p = baseProfile(.advanced, goal: .muscleGain, days: 6, location: .gym)
        p.recoveryCapacity = .high
        edge.append(Scenario(label: "Advanced · high recovery capacity", profile: p, recoveryScore: 85, phase: .push, muscleBalance: []))

        // Focus muscles — chest + back.
        p = baseProfile(.intermediate, goal: .muscleGain, days: 4, location: .gym)
        p.focusMuscles = [.chest, .back]
        edge.append(Scenario(label: "Focus chest + back · hypertrophy", profile: p, recoveryScore: 75, phase: .build, muscleBalance: []))

        // Neglect — no calves, no abs.
        p = baseProfile(.intermediate, goal: .muscleGain, days: 4, location: .gym)
        p.neglectMuscles = [.calves, .abs]
        edge.append(Scenario(label: "Neglect calves + abs", profile: p, recoveryScore: 75, phase: .build, muscleBalance: []))

        // Short session time.
        p = baseProfile(.intermediate, goal: .fatLoss, days: 3, location: .gym)
        p.minutesPerSession = 30
        edge.append(Scenario(label: "30-min fat-loss sessions", profile: p, recoveryScore: 72, phase: .build, muscleBalance: []))

        // Long session time.
        p = baseProfile(.advanced, goal: .muscleGain, days: 5, location: .gym)
        p.minutesPerSession = 90
        edge.append(Scenario(label: "90-min advanced hypertrophy", profile: p, recoveryScore: 78, phase: .build, muscleBalance: []))

        return edge
    }

    private static func baseProfile(
        _ level: TrainingLevel,
        goal: FitnessGoal,
        days: Int,
        location: TrainingLocation
    ) -> UserProfile {
        var p = UserProfile()
        p.goal = goal
        p.trainingLevel = level
        p.daysPerWeek = days
        p.minutesPerSession = 60
        p.splitPreference = .automatic
        p.trainingLocation = location
        switch location {
        case .gym: p.availableEquipment = []
        case .homeGym: p.availableEquipment = [.dumbbell, .bench, .pullUpBar, .resistanceBand]
        case .homeNoEquipment: p.availableEquipment = [.none]
        }
        p.hasCompletedOnboarding = true
        p.trainingMonths = level == .beginner ? 3 : (level == .intermediate ? 18 : 60)
        return p
    }

    // MARK: - Evaluation

    private func evaluate(plan: WorkoutPlan, scenario: Scenario) -> PlanScenarioDiagnostic {
        var dayDiagnostics: [PlanDayDiagnostic] = []
        dayDiagnostics.reserveCapacity(plan.days.count)

        var totalExercises = 0
        var totalSets = 0
        var totalImported = 0
        var weeklyVolume: [MuscleGroup: Int] = [:]

        for day in plan.days {
            var exerciseCount = 0
            var daySets = 0
            var anchor = 0
            var secondary = 0
            var accessory = 0
            var isolation = 0
            var imported = 0
            var patternCounts: [MovementPattern: Int] = [:]
            var musclePrimaryCounts: [MuscleGroup: Int] = [:]
            var warnings: [PlanWarning] = []

            for ex in day.exercises {
                guard let resolved = library.exercise(byId: ex.exerciseId) else {
                    warnings.append(PlanWarning(severity: .critical, message: "Unresolved exercise id \(ex.exerciseId)"))
                    continue
                }
                exerciseCount += 1
                daySets += ex.sets
                totalSets += ex.sets
                totalExercises += 1
                weeklyVolume[resolved.primaryMuscle, default: 0] += ex.sets
                musclePrimaryCounts[resolved.primaryMuscle, default: 0] += 1
                patternCounts[resolved.movementPattern, default: 0] += 1

                if resolved.id.hasPrefix("edb-") {
                    imported += 1
                    totalImported += 1
                }

                switch ex.plannedRole {
                case "Anchor": anchor += 1
                case "Secondary": secondary += 1
                case "Accessory": accessory += 1
                case "Isolation": isolation += 1
                default: break
                }
            }

            // Dominant patterns — more than 2 of the same pattern in one
            // session is usually redundancy.
            let dominant = patternCounts.filter { $0.value > 2 }.map { $0.key.displayName }

            let overloadedMuscles = musclePrimaryCounts.filter { $0.value >= 3 }.map(\.key)

            // Day-level warnings.
            if exerciseCount < 3 && scenario.profile.goal != .flexibility && scenario.profile.goal != .rehabilitation {
                warnings.append(PlanWarning(severity: .warning, message: "Sparse session (\(exerciseCount) exercises)"))
            }
            if exerciseCount > 10 {
                warnings.append(PlanWarning(severity: .warning, message: "Session density high (\(exerciseCount) exercises)"))
            }
            if !dominant.isEmpty {
                warnings.append(PlanWarning(severity: .warning, message: "Pattern overload: \(dominant.joined(separator: ", "))"))
            }
            if !overloadedMuscles.isEmpty {
                let names = overloadedMuscles.map(\.displayName).joined(separator: ", ")
                warnings.append(PlanWarning(severity: .info, message: "Muscle emphasis: \(names)"))
            }

            // Goal-aware role expectations.
            switch scenario.profile.goal {
            case .strength, .muscleGain, .athleticPerformance:
                if anchor == 0 && exerciseCount >= 4 {
                    warnings.append(PlanWarning(severity: .warning, message: "No anchor lift assigned"))
                }
            case .generalFitness, .fatLoss:
                break
            case .endurance, .flexibility, .rehabilitation:
                break
            }

            dayDiagnostics.append(PlanDayDiagnostic(
                id: day.id,
                dayName: day.name,
                focusMuscles: day.focusMuscles,
                exerciseCount: exerciseCount,
                totalSets: daySets,
                anchorCount: anchor,
                secondaryCount: secondary,
                accessoryCount: accessory,
                isolationCount: isolation,
                importedCount: imported,
                dominantPatterns: dominant,
                sameMuscleOverload: overloadedMuscles,
                estimatedMinutes: day.estimatedMinutes,
                warnings: warnings
            ))
        }

        // Scenario-level warnings.
        var scenarioWarnings: [PlanWarning] = []

        if plan.days.isEmpty {
            scenarioWarnings.append(PlanWarning(severity: .critical, message: "Plan produced no days"))
        }

        if totalExercises == 0 {
            scenarioWarnings.append(PlanWarning(severity: .critical, message: "Plan produced no exercises"))
        }

        // Imported ratio — anything above 40% signals canonical dilution.
        let importedRatio = totalExercises > 0 ? Double(totalImported) / Double(totalExercises) : 0
        if importedRatio > 0.40 {
            scenarioWarnings.append(PlanWarning(severity: .warning, message: "High imported ratio \(Int(importedRatio * 100))%"))
        }
        if scenario.profile.goal == .strength && totalImported > 0 {
            // Strength plans should keep curated compounds canonical; any
            // import above zero is worth flagging at info severity.
            let strengthImportedRatio = importedRatio
            if strengthImportedRatio > 0.25 {
                scenarioWarnings.append(PlanWarning(severity: .warning, message: "Strength plan carrying \(Int(strengthImportedRatio * 100))% imported exercises"))
            }
        }

        // Muscle coverage expectations by split type.
        let coveredMuscles = Set(plan.days.flatMap(\.focusMuscles))
        if coveredMuscles.count < 3 && scenario.profile.daysPerWeek >= 3 {
            scenarioWarnings.append(PlanWarning(severity: .warning, message: "Limited muscle coverage (\(coveredMuscles.count) muscles)"))
        }

        // Home no-equipment should never carry barbell movements.
        if scenario.profile.trainingLocation == .homeNoEquipment {
            for day in plan.days {
                for ex in day.exercises {
                    guard let resolved = library.exercise(byId: ex.exerciseId) else { continue }
                    if resolved.equipment.contains(.barbell) {
                        scenarioWarnings.append(PlanWarning(severity: .critical, message: "Barbell movement in no-equipment plan: \(resolved.name)"))
                    }
                }
            }
        }

        // Rehab / flexibility should avoid heavy compounds.
        if scenario.profile.goal == .rehabilitation || scenario.profile.goal == .flexibility {
            for day in plan.days {
                for ex in day.exercises {
                    guard let resolved = library.exercise(byId: ex.exerciseId) else { continue }
                    if resolved.category == .compound && !resolved.isJointFriendly {
                        scenarioWarnings.append(PlanWarning(severity: .warning, message: "Non-joint-friendly compound in \(scenario.profile.goal.displayName) plan: \(resolved.name)"))
                    }
                }
            }
        }

        // Duplicate exercises across the week — should be rare in short plans.
        var idCounts: [String: Int] = [:]
        for day in plan.days {
            for ex in day.exercises { idCounts[ex.exerciseId, default: 0] += 1 }
        }
        let duplicates = idCounts.filter { $0.value >= 3 }
        if !duplicates.isEmpty && plan.days.count <= 4 {
            scenarioWarnings.append(PlanWarning(severity: .info, message: "Exercise repeated \(duplicates.count)x across week"))
        }

        let summary = "\(scenario.profile.trainingLevel.shortName) · \(scenario.profile.daysPerWeek)d · \(scenario.profile.goal.displayName) · \(scenario.profile.trainingLocation.displayName) · phase \(scenario.phase.displayName)"

        return PlanScenarioDiagnostic(
            id: UUID().uuidString,
            label: scenario.label,
            splitName: plan.splitType,
            profileSummary: summary,
            totalExercises: totalExercises,
            totalSets: totalSets,
            importedRatio: importedRatio,
            weeklyVolume: weeklyVolume,
            days: dayDiagnostics,
            warnings: scenarioWarnings
        )
    }
}
