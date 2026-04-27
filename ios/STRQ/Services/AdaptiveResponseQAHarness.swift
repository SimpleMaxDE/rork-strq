import Foundation

// Internal QA harness for the personal exercise-response / family-prior layer.
//
// Validates the conservatism rules the user can't see directly:
//  - low data must not swing generation
//  - single bad day must not poison family scores
//  - strong progression history must earn confident bias
//  - swap ranking must prefer better-tolerated / progressing families for the user
//
// Each scenario runs synthetically (no bundle I/O) so it can be invoked
// anywhere, including unit-test surfaces or development diagnostics.

nonisolated struct AdaptiveResponseQACase: Sendable {
    let label: String
    let detail: String
    let passed: Bool
}

nonisolated struct AdaptiveResponseQAReport: Sendable {
    let cases: [AdaptiveResponseQACase]
    var passedCount: Int { cases.filter(\.passed).count }
    var failedCount: Int { cases.count - passedCount }
    var allPassed: Bool { failedCount == 0 }
}

@MainActor
struct AdaptiveResponseQAHarness: Sendable {

    func run() -> AdaptiveResponseQAReport {
        var cases: [AdaptiveResponseQACase] = []

        cases.append(evaluateLowDataNeutrality())
        cases.append(evaluateSingleBadDayDoesNotDemote())
        cases.append(evaluateStrongProgressionBiasesUp())
        cases.append(evaluateBadToleranceDemotes())
        cases.append(evaluateDeloadAmpliesFatigue())
        cases.append(evaluateSwapPrefersProgressingFamily())
        cases.append(evaluatePriorIsNeutralWhenZeroData())
        cases.append(evaluatePreferredExerciseBoost())
        cases.append(evaluatePreferredSoftenedByNegativeResponse())
        cases.append(evaluateRecentRepetitionPenalty())
        cases.append(evaluateProgressingFamilySparedFromRepetitionPenalty())
        cases.append(evaluateNoteInterpretationKeywords())
        cases.append(evaluateSinglePainNoteDoesNotDemote())
        cases.append(evaluateCorroboratedPainNotesDemote())
        cases.append(evaluateProgressingButFatiguingRanksLower())
        cases.append(evaluateCanonicalIdentityStability())
        cases.append(evaluateCanonicalIdentityUnification())

        return AdaptiveResponseQAReport(cases: cases)
    }

    // MARK: - New Cases (preferred exercises + recent-session memory)

    private func evaluatePreferredExerciseBoost() -> AdaptiveResponseQACase {
        let profile = Self.sampleProfile(preferred: ["barbell-bench-press"])
        guard let bench = ExerciseLibrary.shared.exercise(byId: "barbell-bench-press") else {
            return AdaptiveResponseQACase(label: "preferred boost", detail: "missing exercise", passed: false)
        }
        let baseCtx = PlanContext(
            profile: Self.sampleProfile(preferred: []),
            muscleBalance: [],
            recentSessions: [],
            recoveryScore: 75,
            phase: .build,
            responseProfile: .empty
        )
        let boostedCtx = PlanContext(
            profile: profile,
            muscleBalance: [],
            recentSessions: [],
            recoveryScore: 75,
            phase: .build,
            responseProfile: .empty
        )
        let gen = PlanGenerator()
        let base = gen._score(bench, muscle: .chest, role: .anchor, context: baseCtx)
        let boosted = gen._score(bench, muscle: .chest, role: .anchor, context: boostedCtx)
        let delta = boosted - base
        return AdaptiveResponseQACase(
            label: "preferred boost",
            detail: "Δ=\(String(format: "%.2f", delta)) (expected 4...10)",
            passed: delta >= 4 && delta <= 10
        )
    }

    private func evaluatePreferredSoftenedByNegativeResponse() -> AdaptiveResponseQACase {
        let profile = Self.sampleProfile(preferred: ["barbell-bench-press"])
        guard let bench = ExerciseLibrary.shared.exercise(byId: "barbell-bench-press"),
              let familyId = ExerciseFamilyService.shared.family(forExercise: bench.id)?.id
        else {
            return AdaptiveResponseQACase(label: "preferred softened by bad response", detail: "missing exercise/family", passed: false)
        }
        let badResp = PersonalExerciseResponse(
            familyId: familyId,
            progressionSignal: -0.8, fatigueCost: 0.9,
            jointTolerance: -0.8, adherenceScore: 0.3,
            confidence: 1.0, sessionCount: 10
        )
        let respProfile = ExerciseFamilyResponseProfile(familyResponses: [familyId: badResp])

        let neutralPrefCtx = PlanContext(
            profile: Self.sampleProfile(preferred: []),
            muscleBalance: [], recentSessions: [],
            recoveryScore: 60, phase: .build,
            responseProfile: respProfile
        )
        let prefCtx = PlanContext(
            profile: profile,
            muscleBalance: [], recentSessions: [],
            recoveryScore: 60, phase: .build,
            responseProfile: respProfile
        )
        let gen = PlanGenerator()
        let base = gen._score(bench, muscle: .chest, role: .anchor, context: neutralPrefCtx)
        let boosted = gen._score(bench, muscle: .chest, role: .anchor, context: prefCtx)
        let delta = boosted - base
        // Preferred boost should be softened (≤ 4) when response is strongly negative.
        return AdaptiveResponseQACase(
            label: "preferred softened by bad response",
            detail: "Δ=\(String(format: "%.2f", delta)) (expected <= 4)",
            passed: delta <= 4
        )
    }

    private func evaluateRecentRepetitionPenalty() -> AdaptiveResponseQACase {
        guard let bench = ExerciseLibrary.shared.exercise(byId: "barbell-bench-press") else {
            return AdaptiveResponseQACase(label: "recent repetition penalty", detail: "missing exercise", passed: false)
        }
        let profile = Self.sampleProfile(preferred: [])
        let freshCtx = PlanContext(
            profile: profile,
            muscleBalance: [], recentSessions: [],
            recoveryScore: 75, phase: .build,
            responseProfile: .empty
        )
        let repeated = Self.syntheticRecentSessions(
            exerciseId: bench.id, repeats: 3
        )
        let repeatedCtx = PlanContext(
            profile: profile,
            muscleBalance: [], recentSessions: repeated,
            recoveryScore: 75, phase: .build,
            responseProfile: .empty
        )
        let gen = PlanGenerator()
        let base = gen._score(bench, muscle: .chest, role: .accessory, context: freshCtx)
        let penalized = gen._score(bench, muscle: .chest, role: .accessory, context: repeatedCtx)
        let drop = base - penalized
        return AdaptiveResponseQACase(
            label: "recent repetition penalty",
            detail: "drop=\(String(format: "%.2f", drop)) (expected >= 2)",
            passed: drop >= 2
        )
    }

    private func evaluateProgressingFamilySparedFromRepetitionPenalty() -> AdaptiveResponseQACase {
        guard let bench = ExerciseLibrary.shared.exercise(byId: "barbell-bench-press"),
              let familyId = ExerciseFamilyService.shared.family(forExercise: bench.id)?.id
        else {
            return AdaptiveResponseQACase(label: "progressing family spared", detail: "missing exercise/family", passed: false)
        }
        let progressing = PersonalExerciseResponse(
            familyId: familyId,
            progressionSignal: 0.8, fatigueCost: 0.45,
            jointTolerance: 0.5, adherenceScore: 0.95,
            confidence: 1.0, sessionCount: 10
        )
        let respProfile = ExerciseFamilyResponseProfile(familyResponses: [familyId: progressing])
        let profile = Self.sampleProfile(preferred: [])
        let freshCtx = PlanContext(
            profile: profile,
            muscleBalance: [], recentSessions: [],
            recoveryScore: 75, phase: .build,
            responseProfile: respProfile
        )
        let repeated = Self.syntheticRecentSessions(exerciseId: bench.id, repeats: 3)
        let repeatedCtx = PlanContext(
            profile: profile,
            muscleBalance: [], recentSessions: repeated,
            recoveryScore: 75, phase: .build,
            responseProfile: respProfile
        )
        let gen = PlanGenerator()
        let base = gen._score(bench, muscle: .chest, role: .accessory, context: freshCtx)
        let penalized = gen._score(bench, muscle: .chest, role: .accessory, context: repeatedCtx)
        let drop = base - penalized
        // Strong progression should spare the family — drop stays small.
        return AdaptiveResponseQACase(
            label: "progressing family spared",
            detail: "drop=\(String(format: "%.2f", drop)) (expected < 2)",
            passed: drop < 2
        )
    }

    // MARK: - Helpers

    private static func sampleProfile(preferred: [String]) -> UserProfile {
        var p = UserProfile()
        p.name = ""
        p.daysPerWeek = 4
        p.minutesPerSession = 60
        p.trainingLevel = .intermediate
        p.goal = .muscleGain
        p.trainingLocation = .gym
        p.preferredExercises = preferred
        return p
    }

    private static func syntheticRecentSessions(exerciseId: String, repeats: Int) -> [WorkoutSession] {
        let now = Date()
        return (0..<repeats).map { i in
            let date = Calendar.current.date(byAdding: .day, value: -i, to: now) ?? now
            let log = ExerciseLog(
                exerciseId: exerciseId,
                sets: [
                    SetLog(setNumber: 1, weight: 60, reps: 8, isCompleted: true, quality: .onTarget),
                    SetLog(setNumber: 2, weight: 60, reps: 8, isCompleted: true, quality: .onTarget)
                ],
                isCompleted: true
            )
            return WorkoutSession(
                planId: "plan",
                dayId: "day",
                dayName: "Day",
                startTime: date,
                endTime: date,
                exerciseLogs: [log],
                isCompleted: true
            )
        }
    }

    // MARK: - Cases

    private func evaluateLowDataNeutrality() -> AdaptiveResponseQACase {
        let response = PersonalExerciseResponse(
            familyId: "bench-press-family",
            progressionSignal: 1.0,
            fatigueCost: 0.4,
            jointTolerance: 0.5,
            adherenceScore: 1.0,
            confidence: 0.1,
            sessionCount: 1
        )
        let profile = ExerciseFamilyResponseProfile(familyResponses: [response.familyId: response])
        guard let bench = ExerciseLibrary.shared.exercise(byId: "barbell-bench-press") else {
            return AdaptiveResponseQACase(label: "low-data neutrality", detail: "missing exercise", passed: false)
        }
        let adj = ExerciseResponseEngine.personalAdjustment(
            for: bench, role: .anchor, profile: profile,
            phase: .build, recoveryScore: 75
        )
        // With sessionCount=1 (below threshold) hasUsableData is false → adj == 0.
        return AdaptiveResponseQACase(
            label: "low-data neutrality",
            detail: "adjustment=\(String(format: "%.2f", adj)) (expected 0)",
            passed: abs(adj) < 0.01
        )
    }

    private func evaluateSingleBadDayDoesNotDemote() -> AdaptiveResponseQACase {
        // Exactly at threshold, single grinder marker → jointTolerance mildly
        // negative but confidence is still low, so adjustment stays small.
        let response = PersonalExerciseResponse(
            familyId: "squat-family",
            progressionSignal: 0,
            fatigueCost: 0.5,
            jointTolerance: -0.4,
            adherenceScore: 1.0,
            confidence: 0.3,
            sessionCount: 3
        )
        let profile = ExerciseFamilyResponseProfile(familyResponses: [response.familyId: response])
        guard let squat = ExerciseLibrary.shared.exercise(byId: "barbell-squat") else {
            return AdaptiveResponseQACase(label: "single-bad-day stability", detail: "missing exercise", passed: false)
        }
        let adj = ExerciseResponseEngine.personalAdjustment(
            for: squat, role: .anchor, profile: profile,
            phase: .build, recoveryScore: 75
        )
        return AdaptiveResponseQACase(
            label: "single-bad-day stability",
            detail: "|adj|=\(String(format: "%.2f", adj)) (expected < 3)",
            passed: abs(adj) < 3
        )
    }

    private func evaluateStrongProgressionBiasesUp() -> AdaptiveResponseQACase {
        let response = PersonalExerciseResponse(
            familyId: "row-family",
            progressionSignal: 0.9,
            fatigueCost: 0.45,
            jointTolerance: 0.6,
            adherenceScore: 0.95,
            confidence: 1.0,
            sessionCount: 12
        )
        let profile = ExerciseFamilyResponseProfile(familyResponses: [response.familyId: response])
        guard let row = ExerciseLibrary.shared.exercise(byId: "barbell-row") else {
            return AdaptiveResponseQACase(label: "strong progression bias", detail: "missing exercise", passed: false)
        }
        let adj = ExerciseResponseEngine.personalAdjustment(
            for: row, role: .secondary, profile: profile,
            phase: .push, recoveryScore: 80
        )
        return AdaptiveResponseQACase(
            label: "strong progression bias",
            detail: "adj=\(String(format: "%.2f", adj)) (expected >= 6)",
            passed: adj >= 6
        )
    }

    private func evaluateBadToleranceDemotes() -> AdaptiveResponseQACase {
        let response = PersonalExerciseResponse(
            familyId: "shoulder-press-family",
            progressionSignal: 0,
            fatigueCost: 0.7,
            jointTolerance: -0.8,
            adherenceScore: 0.5,
            confidence: 1.0,
            sessionCount: 10
        )
        let profile = ExerciseFamilyResponseProfile(familyResponses: [response.familyId: response])
        guard let ohp = ExerciseLibrary.shared.exercise(byId: "overhead-press") else {
            return AdaptiveResponseQACase(label: "bad-tolerance demotes", detail: "missing exercise", passed: false)
        }
        let adj = ExerciseResponseEngine.personalAdjustment(
            for: ohp, role: .anchor, profile: profile,
            phase: .build, recoveryScore: 60
        )
        return AdaptiveResponseQACase(
            label: "bad-tolerance demotes",
            detail: "adj=\(String(format: "%.2f", adj)) (expected <= -4)",
            passed: adj <= -4
        )
    }

    private func evaluateDeloadAmpliesFatigue() -> AdaptiveResponseQACase {
        let response = PersonalExerciseResponse(
            familyId: "deadlift-family",
            progressionSignal: 0.2,
            fatigueCost: 0.9,
            jointTolerance: -0.1,
            adherenceScore: 0.9,
            confidence: 1.0,
            sessionCount: 10
        )
        let profile = ExerciseFamilyResponseProfile(familyResponses: [response.familyId: response])
        guard let dl = ExerciseLibrary.shared.exercise(byId: "deadlift") else {
            return AdaptiveResponseQACase(label: "deload amplifies fatigue", detail: "missing exercise", passed: false)
        }
        let build = ExerciseResponseEngine.personalAdjustment(
            for: dl, role: .anchor, profile: profile,
            phase: .build, recoveryScore: 70
        )
        let deload = ExerciseResponseEngine.personalAdjustment(
            for: dl, role: .anchor, profile: profile,
            phase: .deload, recoveryScore: 70
        )
        return AdaptiveResponseQACase(
            label: "deload amplifies fatigue",
            detail: "build=\(String(format: "%.2f", build)) deload=\(String(format: "%.2f", deload))",
            passed: deload < build
        )
    }

    private func evaluateSwapPrefersProgressingFamily() -> AdaptiveResponseQACase {
        let goodFamily = "lat-pulldown-family"
        let weakFamily = "pull-up-family"
        let responses: [String: PersonalExerciseResponse] = [
            goodFamily: PersonalExerciseResponse(
                familyId: goodFamily,
                progressionSignal: 0.8, fatigueCost: 0.4,
                jointTolerance: 0.5, adherenceScore: 0.95,
                confidence: 1.0, sessionCount: 10
            ),
            weakFamily: PersonalExerciseResponse(
                familyId: weakFamily,
                progressionSignal: -0.6, fatigueCost: 0.7,
                jointTolerance: -0.2, adherenceScore: 0.4,
                confidence: 1.0, sessionCount: 10
            ),
        ]
        let profile = ExerciseFamilyResponseProfile(familyResponses: responses)
        guard
            let pullup = ExerciseLibrary.shared.exercise(byId: "pull-up"),
            let pulldown = ExerciseLibrary.shared.exercise(byId: "lat-pulldown")
        else {
            return AdaptiveResponseQACase(label: "swap prefers progressing family", detail: "missing exercises", passed: false)
        }
        let pulldownAdj = ExerciseResponseEngine.swapAdjustment(
            for: pulldown, replacing: pullup,
            profile: profile, recoveryScore: 55
        )
        return AdaptiveResponseQACase(
            label: "swap prefers progressing family",
            detail: "pulldown swap adj=\(String(format: "%.2f", pulldownAdj)) (expected >= 4)",
            passed: pulldownAdj >= 4
        )
    }

    // MARK: - Phase 31 deeper learning cases

    private func evaluateNoteInterpretationKeywords() -> AdaptiveResponseQACase {
        let pain = ExerciseResponseEngine.interpretNote("shoulder pain on last set")
        let hard = ExerciseResponseEngine.interpretNote("Absolutely smoked me")
        let easy = ExerciseResponseEngine.interpretNote("felt too light today")
        let good = ExerciseResponseEngine.interpretNote("Felt strong and crisp")
        let neutral = ExerciseResponseEngine.interpretNote("regular session")

        let ok = pain == .pain && hard == .tooHard && easy == .tooEasy && good == .positive && neutral == nil
        return AdaptiveResponseQACase(
            label: "note keyword interpretation",
            detail: "pain=\(String(describing: pain)) hard=\(String(describing: hard)) easy=\(String(describing: easy)) good=\(String(describing: good)) neutral=\(String(describing: neutral))",
            passed: ok
        )
    }

    private func evaluateSinglePainNoteDoesNotDemote() -> AdaptiveResponseQACase {
        guard let ohp = ExerciseLibrary.shared.exercise(byId: "overhead-press") else {
            return AdaptiveResponseQACase(label: "single pain note stable", detail: "missing exercise", passed: false)
        }
        // One painful session among otherwise normal sessions — corroboration
        // threshold is 2, so response should stay near neutral.
        let sessions = Self.syntheticSessions(
            exerciseId: ohp.id,
            count: 5,
            notes: ["shoulder pain sharp", "", "", "", ""]
        )
        let engine = ExerciseResponseEngine()
        let profile = engine.compute(workoutHistory: sessions, progressionStates: [])
        let adj = ExerciseResponseEngine.personalAdjustment(
            for: ohp, role: .anchor, profile: profile,
            phase: .build, recoveryScore: 75
        )
        return AdaptiveResponseQACase(
            label: "single pain note stable",
            detail: "adj=\(String(format: "%.2f", adj)) (expected > -3)",
            passed: adj > -3
        )
    }

    private func evaluateCorroboratedPainNotesDemote() -> AdaptiveResponseQACase {
        guard let ohp = ExerciseLibrary.shared.exercise(byId: "overhead-press") else {
            return AdaptiveResponseQACase(label: "corroborated pain demotes", detail: "missing exercise", passed: false)
        }
        // Three painful sessions in a 10-session history — corroboration clears,
        // confidence is high, tolerance should shift negative enough to demote.
        let sessions = Self.syntheticSessions(
            exerciseId: ohp.id,
            count: 10,
            notes: ["shoulder pain", "sharp pinch", "hurt again", "", "", "", "", "", "", ""]
        )
        let engine = ExerciseResponseEngine()
        let profile = engine.compute(workoutHistory: sessions, progressionStates: [])
        let adj = ExerciseResponseEngine.personalAdjustment(
            for: ohp, role: .anchor, profile: profile,
            phase: .build, recoveryScore: 70
        )
        return AdaptiveResponseQACase(
            label: "corroborated pain demotes",
            detail: "adj=\(String(format: "%.2f", adj)) (expected <= -1.5)",
            passed: adj <= -1.5
        )
    }

    private func evaluateProgressingButFatiguingRanksLower() -> AdaptiveResponseQACase {
        // Two responses: one progressing + well tolerated, one progressing
        // but fatigue-heavy + poorly tolerated. Sweet-spot must rank higher.
        guard let dl = ExerciseLibrary.shared.exercise(byId: "deadlift"),
              let row = ExerciseLibrary.shared.exercise(byId: "barbell-row"),
              let dlFam = ExerciseFamilyService.shared.family(forExercise: dl.id)?.id,
              let rowFam = ExerciseFamilyService.shared.family(forExercise: row.id)?.id
        else {
            return AdaptiveResponseQACase(label: "stimulus-to-fatigue tempering", detail: "missing exercises", passed: false)
        }
        let sweetSpot = PersonalExerciseResponse(
            familyId: rowFam,
            progressionSignal: 0.7, fatigueCost: 0.4,
            jointTolerance: 0.5, adherenceScore: 0.95,
            confidence: 1.0, sessionCount: 10
        )
        let expensive = PersonalExerciseResponse(
            familyId: dlFam,
            progressionSignal: 0.7, fatigueCost: 0.85,
            jointTolerance: 0.0, adherenceScore: 0.9,
            confidence: 1.0, sessionCount: 10
        )
        let profile = ExerciseFamilyResponseProfile(familyResponses: [
            rowFam: sweetSpot, dlFam: expensive
        ])
        let sweetAdj = ExerciseResponseEngine.personalAdjustment(
            for: row, role: .secondary, profile: profile,
            phase: .build, recoveryScore: 60
        )
        let expensiveAdj = ExerciseResponseEngine.personalAdjustment(
            for: dl, role: .anchor, profile: profile,
            phase: .build, recoveryScore: 60
        )
        return AdaptiveResponseQACase(
            label: "stimulus-to-fatigue tempering",
            detail: "sweet=\(String(format: "%.2f", sweetAdj)) expensive=\(String(format: "%.2f", expensiveAdj))",
            passed: sweetAdj > expensiveAdj
        )
    }

    private static func syntheticSessions(
        exerciseId: String,
        count: Int,
        notes: [String]
    ) -> [WorkoutSession] {
        let now = Date()
        return (0..<count).map { i in
            let date = Calendar.current.date(byAdding: .day, value: -i * 2, to: now) ?? now
            let note = i < notes.count ? notes[i] : ""
            let log = ExerciseLog(
                exerciseId: exerciseId,
                sets: [
                    SetLog(setNumber: 1, weight: 60, reps: 8, isCompleted: true, quality: .onTarget),
                    SetLog(setNumber: 2, weight: 60, reps: 8, isCompleted: true, quality: .onTarget),
                    SetLog(setNumber: 3, weight: 60, reps: 8, isCompleted: true, quality: .onTarget)
                ],
                isCompleted: true
            )
            return WorkoutSession(
                planId: "plan",
                dayId: "day",
                dayName: "Day",
                startTime: date,
                endTime: date,
                exerciseLogs: [log],
                isCompleted: true,
                notes: note
            )
        }
    }

    // MARK: - Canonical identity cases

    /// Curated ids must pass through canonicalization unchanged — we should
    /// never accidentally rewrite STRQ's canonical exercise ids.
    private func evaluateCanonicalIdentityStability() -> AdaptiveResponseQACase {
        let curated = ["barbell-bench-press", "overhead-press", "deadlift", "lat-pulldown"]
        let allStable = curated.allSatisfy { ExerciseIdentity.canonical($0) == $0 }
        return AdaptiveResponseQACase(
            label: "canonical id stability (curated)",
            detail: curated.map { "\($0)->\(ExerciseIdentity.canonical($0))" }.joined(separator: ", "),
            passed: allStable
        )
    }

    /// An alias id and its canonical id must resolve to the same family so
    /// adaptive response, swaps, and media behave as one identity.
    private func evaluateCanonicalIdentityUnification() -> AdaptiveResponseQACase {
        let famService = ExerciseFamilyService.shared
        // Probe a handful of imported ids — any collapsed duplicate should
        // resolve to the same family as its canonical counterpart.
        let probes = ExerciseDBProImporter.shared.exercises.prefix(10).map(\.id)
        guard !probes.isEmpty else {
            return AdaptiveResponseQACase(
                label: "canonical id unification",
                detail: "no imported exercises in bundle",
                passed: true
            )
        }
        let ok = probes.allSatisfy { id in
            let canonical = ExerciseIdentity.canonical(id)
            let viaAlias = famService.family(forExercise: id)?.id
            let viaCanonical = famService.family(forExercise: canonical)?.id
            return viaAlias == viaCanonical
        }
        return AdaptiveResponseQACase(
            label: "canonical id unification",
            detail: "alias/canonical family lookup agrees across \(probes.count) probes",
            passed: ok
        )
    }

    private func evaluatePriorIsNeutralWhenZeroData() -> AdaptiveResponseQACase {
        let profile = ExerciseFamilyResponseProfile.empty
        guard let bench = ExerciseLibrary.shared.exercise(byId: "barbell-bench-press") else {
            return AdaptiveResponseQACase(label: "prior neutral when zero data", detail: "missing exercise", passed: false)
        }
        let adj = ExerciseResponseEngine.personalAdjustment(
            for: bench, role: .anchor, profile: profile,
            phase: .build, recoveryScore: 75
        )
        return AdaptiveResponseQACase(
            label: "prior neutral when zero data",
            detail: "adj=\(String(format: "%.2f", adj)) (expected 0)",
            passed: abs(adj) < 0.01
        )
    }
}
