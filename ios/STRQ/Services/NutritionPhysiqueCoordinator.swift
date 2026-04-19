import Foundation

/// Owns nutrition + physique insight refresh logic.
///
/// State lives on `AppViewModel` so SwiftUI keeps its reactive bindings —
/// this coordinator just moves the calculations out of the root view-model.
@MainActor
final class NutritionPhysiqueCoordinator {
    private unowned let vm: AppViewModel
    private let nutritionEngine = NutritionCoachEngine()
    private let physiqueEngine = PhysiqueIntelligenceEngine()

    init(vm: AppViewModel) {
        self.vm = vm
    }

    func computeTargets() -> NutritionTarget {
        nutritionEngine.computeTargets(profile: vm.profile)
    }

    func refresh() {
        // Nutrition / physique intelligence is strictly opt-in.
        // When tracking is off, missing data must never be interpreted
        // as poor adherence or an "off-track" verdict.
        guard vm.profile.nutritionTrackingEnabled else {
            vm.nutritionInsights = []
            vm.goalPace = nil
            vm.physiqueOutcome = nil
            return
        }

        vm.nutritionInsights = nutritionEngine.generateInsights(
            target: vm.nutritionTarget,
            recentLogs: vm.nutritionLogs,
            weightEntries: vm.bodyWeightEntries,
            sleepEntries: vm.sleepEntries,
            profile: vm.profile,
            recoveryScore: vm.recoveryScore
        )

        let last14Weights = vm.bodyWeightEntries.filter {
            let days = Calendar.current.dateComponents([.day], from: $0.date, to: Date()).day ?? 0
            return days <= 14
        }.sorted { $0.date < $1.date }

        if last14Weights.count >= 3 {
            let first3Avg = last14Weights.prefix(3).map(\.weightKg).reduce(0, +) / 3.0
            let last3Avg = last14Weights.suffix(3).map(\.weightKg).reduce(0, +) / 3.0
            let weeklyChange = (last3Avg - first3Avg) / 2.0
            vm.goalPace = nutritionEngine.goalPaceStatus(target: vm.nutritionTarget, weeklyChange: weeklyChange)
        } else {
            vm.goalPace = nil
        }

        vm.physiqueOutcome = physiqueEngine.analyze(
            profile: vm.profile,
            target: vm.nutritionTarget,
            weightEntries: vm.bodyWeightEntries,
            nutritionLogs: vm.nutritionLogs,
            recoveryScore: vm.effectiveRecoveryScore,
            baseConfidence: vm.coachingConfidence
        )
    }

    func dailyNutritionSummary() -> String {
        nutritionEngine.dailyNutritionSummary(todayLog: vm.todaysNutritionLog, target: vm.nutritionTarget)
    }
}
