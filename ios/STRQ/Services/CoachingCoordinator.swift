import Foundation

/// Owns coaching / intelligence refresh logic.
///
/// This coordinator does not store state itself — state lives on
/// `AppViewModel` so SwiftUI views keep observing the same reactive
/// properties. It just moves the computation out of `AppViewModel` so the
/// root view-model becomes a composition layer instead of a giant
/// multi-domain owner.
@MainActor
final class CoachingCoordinator {
    private unowned let vm: AppViewModel

    private let coachingEngine = CoachingEngine()
    private let progressionEngine = ProgressionEngine()
    private let volumeEngine = SmartVolumeEngine()
    private let adaptiveEngine = AdaptivePrescriptionEngine()
    private let planEvolutionEngine = PlanEvolutionEngine()
    private let phaseOutlookEngine = PhaseOutlookEngine()
    private let toleranceEngine = ToleranceEngine()
    private let physiqueEngine = PhysiqueIntelligenceEngine()

    init(vm: AppViewModel) {
        self.vm = vm
    }

    // MARK: - Derived refresh pipeline

    func refreshIntelligence() {
        refreshProgressionStates()
        // Fold updated progression data into the adaptive family-response
        // profile before downstream insights / plan-quality reads run, so
        // swap ranking and plan quality see the latest personal response.
        vm.refreshFamilyResponseProfile()
        refreshVolumeLandmarks()
        refreshBalanceInsights()
        refreshNextBestAction()
        refreshCoachingInsights()
        refreshPlanQuality()
        refreshPhaseOutlook()
    }

    func refreshPhaseOutlook() {
        let trend = vm.recoveryTrendData.map(\.score)
        vm.phaseOutlook = phaseOutlookEngine.analyze(
            phaseState: vm.trainingPhaseState,
            progressionStates: vm.progressionStates,
            recoveryTrend: trend,
            recoveryScore: vm.recoveryScore,
            workoutHistory: vm.workoutHistory,
            muscleBalance: vm.muscleBalance,
            planEvolutionSignals: vm.planEvolutionSignals,
            profile: vm.profile
        )
    }

    func refreshCoachingInsights() {
        let confidence = vm.coachingConfidence
        var newInsights = coachingEngine.generateInsights(
            profile: vm.profile,
            workoutHistory: vm.workoutHistory,
            progressEntries: vm.progressEntries,
            personalRecords: vm.personalRecords,
            currentPlan: vm.currentPlan,
            muscleBalance: vm.muscleBalance,
            progressionStates: vm.progressionStates,
            phase: vm.trainingPhaseState.currentPhase,
            volumeLandmarks: vm.volumeLandmarks,
            confidence: confidence
        )

        var newRecs = coachingEngine.generateRecommendations(
            profile: vm.profile,
            workoutHistory: vm.workoutHistory,
            progressEntries: vm.progressEntries,
            personalRecords: vm.personalRecords,
            muscleBalance: vm.muscleBalance,
            progressionStates: vm.progressionStates,
            phase: vm.trainingPhaseState.currentPhase,
            confidence: confidence
        )

        let trend = vm.recoveryTrendData.map(\.score)
        let weeksTrained: Int = {
            guard let first = vm.workoutHistory.filter(\.isCompleted).last?.startTime else { return 0 }
            let days = Calendar.current.dateComponents([.day], from: first, to: Date()).day ?? 0
            return max(0, days / 7)
        }()
        let signals = planEvolutionEngine.analyze(
            profile: vm.profile,
            currentPlan: vm.currentPlan,
            workoutHistory: vm.workoutHistory,
            progressionStates: vm.progressionStates,
            muscleBalance: vm.muscleBalance,
            recoveryTrend: trend,
            weeksTrained: weeksTrained,
            phase: vm.trainingPhaseState.currentPhase,
            baseConfidence: confidence,
            recoveryScore: vm.recoveryScore
        )
        vm.planEvolutionSignals = signals

        let confidentSignals = signals.filter { $0.confidence != .low }
        var existingTitles = Set(newInsights.map(\.title))
        for signal in confidentSignals where !existingTitles.contains(signal.insight.title) {
            newInsights.append(signal.insight)
            existingTitles.insert(signal.insight.title)
        }
        var existingRecTitles = Set(newRecs.map(\.title))
        for signal in confidentSignals {
            if let rec = signal.recommendation, !existingRecTitles.contains(rec.title) {
                newRecs.append(rec)
                existingRecTitles.insert(rec.title)
            }
        }

        let tolerance = toleranceEngine.analyze(
            profile: vm.profile,
            workoutHistory: vm.workoutHistory,
            progressionStates: vm.progressionStates,
            recoveryScore: vm.recoveryScore,
            phase: vm.trainingPhaseState.currentPhase,
            baseConfidence: confidence
        )
        vm.toleranceSignals = tolerance
        let actionableTolerance = tolerance.filter { signal in
            switch signal.confidence {
            case .low: return false
            case .moderate, .high: return true
            }
        }
        for signal in actionableTolerance where !existingTitles.contains(signal.insight.title) {
            newInsights.append(signal.insight)
            existingTitles.insert(signal.insight.title)
        }
        for signal in actionableTolerance {
            if let rec = signal.recommendation, !existingRecTitles.contains(rec.title) {
                newRecs.append(rec)
                existingRecTitles.insert(rec.title)
            }
        }

        // Physique intelligence only feeds coaching when the user has opted
        // into nutrition / physique tracking. Missing logs are never treated
        // as negative signal for non-tracking users.
        if vm.profile.nutritionTrackingEnabled {
            let outcome = physiqueEngine.analyze(
                profile: vm.profile,
                target: vm.nutritionTarget,
                weightEntries: vm.bodyWeightEntries,
                nutritionLogs: vm.nutritionLogs,
                recoveryScore: vm.effectiveRecoveryScore,
                baseConfidence: confidence
            )
            vm.physiqueOutcome = outcome
            for insight in outcome.insights where !existingTitles.contains(insight.title) {
                newInsights.append(insight)
                existingTitles.insert(insight.title)
            }
            for rec in outcome.recommendations where !existingRecTitles.contains(rec.title) {
                newRecs.append(rec)
                existingRecTitles.insert(rec.title)
            }
        } else {
            vm.physiqueOutcome = nil
        }

        vm._dynamicInsights = newInsights.sorted { $0.severityRank > $1.severityRank }
        vm.recommendations = newRecs.sorted { $0.priority > $1.priority }
    }

    func refreshPlanQuality() {
        guard let plan = vm.currentPlan else { return }
        vm.planQuality = progressionEngine.assessPlanQuality(
            plan: plan,
            profile: vm.profile,
            muscleBalance: vm.muscleBalance,
            recoveryScore: vm.recoveryScore,
            progressionStates: vm.progressionStates,
            phase: vm.trainingPhaseState.currentPhase
        )
    }

    private func refreshProgressionStates() {
        var counts: [String: Int] = [:]
        for session in vm.workoutHistory where session.isCompleted {
            for log in session.exerciseLogs {
                counts[log.exerciseId, default: 0] += 1
            }
        }
        let plannedIds = Set(vm.currentPlan?.days.flatMap(\.exercises).map(\.exerciseId) ?? [])
        let historyIds = Set(counts.keys)
        let relevantIds = plannedIds.union(historyIds)
        let ordered = relevantIds.sorted { (counts[$0] ?? 0) > (counts[$1] ?? 0) }
        let cap = 60
        vm.progressionStates = ordered.prefix(cap).map { exId in
            progressionEngine.analyzeProgression(
                exerciseId: exId,
                sessions: vm.workoutHistory,
                profile: vm.profile,
                currentPhase: vm.trainingPhaseState.currentPhase
            )
        }
    }

    private func refreshVolumeLandmarks() {
        vm.volumeLandmarks = volumeEngine.volumeLandmarks(
            for: vm.profile,
            muscleBalance: vm.muscleBalance,
            sessions: vm.workoutHistory
        )
        vm.volumeGuidance = volumeEngine.weeklyVolumeGuidance(
            landmarks: vm.volumeLandmarks,
            profile: vm.profile,
            phase: vm.trainingPhaseState.currentPhase
        )
    }

    private func refreshBalanceInsights() {
        vm.balanceInsights = volumeEngine.analyzeBalance(
            muscleBalance: vm.muscleBalance,
            profile: vm.profile
        )
    }

    private func refreshNextBestAction() {
        vm.nextBestAction = progressionEngine.computeNextBestAction(
            profile: vm.profile,
            sessions: vm.workoutHistory,
            recoveryScore: vm.recoveryScore,
            muscleBalance: vm.muscleBalance,
            progressionStates: vm.progressionStates,
            phase: vm.trainingPhaseState.currentPhase
        )
    }

    // MARK: - Exposed engine helpers

    func exerciseReplacements(for exercise: Exercise, reason: ReplacementReason) -> [Exercise] {
        coachingEngine.suggestExerciseReplacement(for: exercise, profile: vm.profile, reason: reason)
    }

    func todayPrescription(for planned: PlannedExercise) -> TodayPrescription {
        let exercise = vm.library.exercise(byId: planned.exerciseId)
        let fallback = vm.loadSuggestion(for: planned.exerciseId, planned: planned)?.suggestedWeight
        return adaptiveEngine.prescribe(
            planned: planned,
            exercise: exercise,
            sessions: vm.workoutHistory,
            effectiveRecoveryScore: vm.effectiveRecoveryScore,
            phase: vm.currentPhase,
            fallbackSuggestedWeight: fallback
        )
    }
}
