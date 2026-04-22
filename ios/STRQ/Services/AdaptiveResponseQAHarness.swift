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

nonisolated struct AdaptiveResponseQAHarness: Sendable {

    func run() -> AdaptiveResponseQAReport {
        var cases: [AdaptiveResponseQACase] = []

        cases.append(evaluateLowDataNeutrality())
        cases.append(evaluateSingleBadDayDoesNotDemote())
        cases.append(evaluateStrongProgressionBiasesUp())
        cases.append(evaluateBadToleranceDemotes())
        cases.append(evaluateDeloadAmpliesFatigue())
        cases.append(evaluateSwapPrefersProgressingFamily())
        cases.append(evaluatePriorIsNeutralWhenZeroData())

        return AdaptiveResponseQAReport(cases: cases)
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
