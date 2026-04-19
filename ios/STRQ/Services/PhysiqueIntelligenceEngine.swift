import Foundation

// Physique-outcome intelligence layer.
//
// Reads real bodyweight history, nutrition adherence, recovery, and the user's
// declared goal and decides whether the user is actually moving toward the
// physique outcome — gaining, losing, maintaining, or recomposing.
//
// Outputs route through the existing SmartInsight + Recommendation streams so
// no new UI surface is required. The layer is deliberately calm:
// - low signal → gentle guidance only
// - moderate signal → small, directional adjustments
// - high signal → direct recommendations
//
// It does not build a meal planner, recipe catalog, or macro obsession UI.

nonisolated enum PhysiqueTrendDirection: Sendable {
    case rising
    case falling
    case stable
    case unknown
}

nonisolated enum PhysiqueSignalStrength: Sendable {
    case insufficient
    case weak
    case moderate
    case strong
}

nonisolated enum PhysiquePaceVerdict: Sendable {
    case onTrack
    case tooSlow
    case tooFast
    case drifting
    case aligned
    case noSignal
}

nonisolated struct BodyweightTrend: Sendable {
    let direction: PhysiqueTrendDirection
    let weeklyChangeKg: Double
    let spanDays: Int
    let entryCount: Int
    let noiseKg: Double
    let strength: PhysiqueSignalStrength
}

nonisolated struct NutritionAdherence: Sendable {
    let proteinHitRate: Double
    let calorieAdherence: Double
    let loggedDays: Int
    let avgProtein: Int
    let avgCalories: Int
    let strength: PhysiqueSignalStrength
}

nonisolated struct PhysiqueOutcome: Sendable {
    let trend: BodyweightTrend
    let nutrition: NutritionAdherence
    let paceVerdict: PhysiquePaceVerdict
    let insights: [SmartInsight]
    let recommendations: [Recommendation]
    let summary: String?
}

struct PhysiqueIntelligenceEngine {

    func analyze(
        profile: UserProfile,
        target: NutritionTarget,
        weightEntries: [BodyWeightEntry],
        nutritionLogs: [DailyNutritionLog],
        recoveryScore: Int,
        baseConfidence: CoachingConfidence
    ) -> PhysiqueOutcome {
        let trend = analyzeTrend(weightEntries: weightEntries)
        let nutrition = analyzeNutrition(target: target, logs: nutritionLogs)
        let verdict = verdict(for: target, trend: trend)

        let insights = buildInsights(
            profile: profile,
            target: target,
            trend: trend,
            nutrition: nutrition,
            verdict: verdict,
            recoveryScore: recoveryScore,
            baseConfidence: baseConfidence
        )

        let recs = buildRecommendations(
            target: target,
            trend: trend,
            nutrition: nutrition,
            verdict: verdict,
            recoveryScore: recoveryScore,
            baseConfidence: baseConfidence
        )

        let summary = buildSummary(
            target: target,
            trend: trend,
            nutrition: nutrition,
            verdict: verdict,
            recoveryScore: recoveryScore
        )

        return PhysiqueOutcome(
            trend: trend,
            nutrition: nutrition,
            paceVerdict: verdict,
            insights: insights,
            recommendations: recs,
            summary: summary
        )
    }

    // MARK: - Bodyweight Trend

    func analyzeTrend(weightEntries: [BodyWeightEntry]) -> BodyweightTrend {
        let calendar = Calendar.current
        let cutoff = calendar.date(byAdding: .day, value: -28, to: Date()) ?? Date()
        let recent = weightEntries.filter { $0.date >= cutoff }.sorted { $0.date < $1.date }

        guard recent.count >= 2, let first = recent.first, let last = recent.last else {
            return BodyweightTrend(
                direction: .unknown,
                weeklyChangeKg: 0,
                spanDays: 0,
                entryCount: recent.count,
                noiseKg: 0,
                strength: .insufficient
            )
        }

        let spanDays = max(1, calendar.dateComponents([.day], from: first.date, to: last.date).day ?? 0)
        let weights = recent.map(\.weightKg)
        let slope = linearSlopePerDay(dates: recent.map(\.date), values: weights)
        let weeklyChange = slope * 7.0

        let mean = weights.reduce(0, +) / Double(weights.count)
        let variance = weights.map { pow($0 - mean, 2) }.reduce(0, +) / Double(weights.count)
        let noise = sqrt(variance)

        let strength: PhysiqueSignalStrength = {
            if recent.count >= 6 && spanDays >= 14 { return .strong }
            if recent.count >= 4 && spanDays >= 10 { return .moderate }
            if recent.count >= 2 && spanDays >= 5 { return .weak }
            return .insufficient
        }()

        let direction: PhysiqueTrendDirection = {
            // Treat change as meaningful only if it clears noise and a minimum threshold.
            let threshold = max(0.08, noise * 0.4)
            if weeklyChange > threshold { return .rising }
            if weeklyChange < -threshold { return .falling }
            return .stable
        }()

        return BodyweightTrend(
            direction: direction,
            weeklyChangeKg: weeklyChange,
            spanDays: spanDays,
            entryCount: recent.count,
            noiseKg: noise,
            strength: strength
        )
    }

    private func linearSlopePerDay(dates: [Date], values: [Double]) -> Double {
        guard let first = dates.first else { return 0 }
        let xs = dates.map { $0.timeIntervalSince(first) / 86400.0 }
        let ys = values
        let n = Double(xs.count)
        guard n >= 2 else { return 0 }
        let sumX = xs.reduce(0, +)
        let sumY = ys.reduce(0, +)
        let meanX = sumX / n
        let meanY = sumY / n
        var num: Double = 0
        var den: Double = 0
        for i in 0..<xs.count {
            let dx = xs[i] - meanX
            num += dx * (ys[i] - meanY)
            den += dx * dx
        }
        guard den > 0 else { return 0 }
        return num / den
    }

    // MARK: - Nutrition Adherence

    func analyzeNutrition(target: NutritionTarget, logs: [DailyNutritionLog]) -> NutritionAdherence {
        let calendar = Calendar.current
        let cutoff = calendar.date(byAdding: .day, value: -14, to: Date()) ?? Date()
        let recent = logs.filter { $0.date >= cutoff }

        guard !recent.isEmpty, target.proteinGrams > 0, target.calories > 0 else {
            return NutritionAdherence(
                proteinHitRate: 0,
                calorieAdherence: 0,
                loggedDays: recent.count,
                avgProtein: 0,
                avgCalories: 0,
                strength: .insufficient
            )
        }

        let proteinHits = recent.filter {
            Double($0.proteinGrams) / Double(target.proteinGrams) >= 0.80
        }.count
        let proteinHitRate = Double(proteinHits) / Double(recent.count)

        let calorieRatios = recent.map { log -> Double in
            let deviation = abs(Double(log.calories - target.calories)) / Double(target.calories)
            return max(0, 1.0 - deviation)
        }
        let calorieAdherence = calorieRatios.reduce(0, +) / Double(recent.count)

        let avgProtein = recent.map(\.proteinGrams).reduce(0, +) / recent.count
        let avgCalories = recent.map(\.calories).reduce(0, +) / recent.count

        let strength: PhysiqueSignalStrength = {
            if recent.count >= 10 { return .strong }
            if recent.count >= 5 { return .moderate }
            if recent.count >= 2 { return .weak }
            return .insufficient
        }()

        return NutritionAdherence(
            proteinHitRate: proteinHitRate,
            calorieAdherence: calorieAdherence,
            loggedDays: recent.count,
            avgProtein: avgProtein,
            avgCalories: avgCalories,
            strength: strength
        )
    }

    // MARK: - Goal Pace Verdict

    func verdict(for target: NutritionTarget, trend: BodyweightTrend) -> PhysiquePaceVerdict {
        guard trend.strength != .insufficient else { return .noSignal }
        let w = trend.weeklyChangeKg

        switch target.nutritionGoal {
        case .leanBulk, .muscleGain:
            let targetRate = target.targetWeeklyChangeKg > 0 ? target.targetWeeklyChangeKg : 0.25
            if w < targetRate * 0.4 { return .tooSlow }
            if w > targetRate * 2.0 && w > 0.45 { return .tooFast }
            return .onTrack
        case .fatLoss, .aggressiveCut:
            let targetRate = target.targetWeeklyChangeKg < 0 ? target.targetWeeklyChangeKg : -0.4
            if w > targetRate * 0.3 { return .tooSlow }
            if w < targetRate * 1.6 && w < -0.7 { return .tooFast }
            return .onTrack
        case .maintenance, .recomp:
            if abs(w) <= 0.2 { return .aligned }
            return .drifting
        }
    }

    // MARK: - Insights

    private func buildInsights(
        profile: UserProfile,
        target: NutritionTarget,
        trend: BodyweightTrend,
        nutrition: NutritionAdherence,
        verdict: PhysiquePaceVerdict,
        recoveryScore: Int,
        baseConfidence: CoachingConfidence
    ) -> [SmartInsight] {
        var results: [SmartInsight] = []

        // Too little signal — one calm nudge to keep logging, nothing more.
        if trend.strength == .insufficient {
            if baseConfidence >= .moderate && nutrition.strength == .insufficient {
                results.append(SmartInsight(
                    icon: "waveform.path",
                    color: "blue",
                    title: "Physique Signal Calibrating",
                    message: "Not enough weigh-ins or nutrition logs yet to judge \(target.nutritionGoal.displayName.lowercased()) progress. Keep logging for clearer guidance.",
                    severity: .low,
                    category: .bodyComposition
                ))
            }
            return results
        }

        // Goal-pace verdict insight.
        switch (target.nutritionGoal, verdict) {
        case (.leanBulk, .tooSlow), (.muscleGain, .tooSlow):
            let sev: InsightSeverity = trend.strength == .strong ? .medium : .low
            results.append(SmartInsight(
                icon: "arrow.down.right.circle.fill",
                color: "yellow",
                title: "Gaining Slower Than Goal",
                message: "Weight is trending \(formatRate(trend.weeklyChangeKg))/wk versus your \(formatRate(target.targetWeeklyChangeKg))/wk muscle-gain target. Tighten nutrition consistency before adding training pressure.",
                severity: sev,
                category: .bodyComposition
            ))

        case (.leanBulk, .tooFast), (.muscleGain, .tooFast):
            results.append(SmartInsight(
                icon: "exclamationmark.triangle.fill",
                color: "orange",
                title: "Gaining Too Fast",
                message: "Weight is rising \(formatRate(trend.weeklyChangeKg))/wk — faster than your \(formatRate(target.targetWeeklyChangeKg))/wk target. Ease the surplus to stay lean while muscle catches up.",
                severity: .medium,
                category: .bodyComposition
            ))

        case (.fatLoss, .tooSlow), (.aggressiveCut, .tooSlow):
            let sev: InsightSeverity = trend.strength == .strong ? .medium : .low
            results.append(SmartInsight(
                icon: "arrow.right.circle.fill",
                color: "yellow",
                title: "Cut Stalling",
                message: "Weight is holding at \(formatRate(trend.weeklyChangeKg))/wk while your goal is \(formatRate(target.targetWeeklyChangeKg))/wk. The deficit isn't landing — audit calories and protein before pushing training harder.",
                severity: sev,
                category: .bodyComposition
            ))

        case (.fatLoss, .tooFast), (.aggressiveCut, .tooFast):
            let recoveryNote = recoveryScore < 60 ? " Recovery is already trending low — ease the deficit and protect performance." : " Ease the deficit slightly to preserve muscle and recovery."
            results.append(SmartInsight(
                icon: "flame.fill",
                color: "red",
                title: "Cutting Too Aggressively",
                message: "Weight is dropping \(formatRate(trend.weeklyChangeKg))/wk — faster than your \(formatRate(target.targetWeeklyChangeKg))/wk target.\(recoveryNote)",
                severity: .high,
                category: .bodyComposition
            ))

        case (.maintenance, .drifting), (.recomp, .drifting):
            let direction = trend.weeklyChangeKg > 0 ? "up" : "down"
            results.append(SmartInsight(
                icon: "arrow.left.arrow.right.circle.fill",
                color: "yellow",
                title: "Weight Drifting \(direction.capitalized)",
                message: "Trending \(formatRate(trend.weeklyChangeKg))/wk while targeting \(target.nutritionGoal.displayName.lowercased()). Adjust intake slightly to stabilize.",
                severity: .low,
                category: .bodyComposition
            ))

        case (_, .onTrack), (_, .aligned):
            if trend.strength == .strong {
                results.append(SmartInsight(
                    icon: "checkmark.seal.fill",
                    color: "green",
                    title: "\(target.nutritionGoal.displayName) On Track",
                    message: onTrackMessage(target: target, trend: trend),
                    severity: .positive,
                    category: .bodyComposition
                ))
            }

        default:
            break
        }

        // Nutrition-signal quality insights. These cap confidence in the goal verdict.
        if nutrition.strength != .insufficient {
            if nutrition.proteinHitRate < 0.5 && (target.nutritionGoal == .leanBulk || target.nutritionGoal == .muscleGain) {
                results.append(SmartInsight(
                    icon: "fork.knife",
                    color: "orange",
                    title: "Protein Limiting Muscle Gain",
                    message: "Only \(Int(nutrition.proteinHitRate * 100))% of your recent days hit the \(target.proteinGrams)g protein floor. Muscle-gain confidence is capped until protein gets consistent.",
                    severity: .medium,
                    category: .bodyComposition
                ))
            } else if nutrition.proteinHitRate < 0.6 {
                results.append(SmartInsight(
                    icon: "fork.knife",
                    color: "yellow",
                    title: "Protein Adherence Weak",
                    message: "\(nutrition.avgProtein)g average protein across \(nutrition.loggedDays) logged days — below your \(target.proteinGrams)g floor \(Int((1 - nutrition.proteinHitRate) * 100))% of the time.",
                    severity: .low,
                    category: .bodyComposition
                ))
            }

            // Calorie mismatch against goal direction — only if we have a trend to corroborate.
            if trend.strength != .insufficient {
                let calGap = nutrition.avgCalories - target.calories
                if (target.nutritionGoal == .fatLoss || target.nutritionGoal == .aggressiveCut) && calGap > 200 && verdict == .tooSlow {
                    results.append(SmartInsight(
                        icon: "chart.bar.xaxis",
                        color: "orange",
                        title: "Cut Explained",
                        message: "Average intake is \(calGap) kcal above target and weight isn't moving. The deficit isn't real yet — tighten calories before adjusting training.",
                        severity: .medium,
                        category: .bodyComposition
                    ))
                }
                if (target.nutritionGoal == .leanBulk || target.nutritionGoal == .muscleGain) && calGap < -200 && verdict == .tooSlow {
                    results.append(SmartInsight(
                        icon: "chart.bar.xaxis",
                        color: "yellow",
                        title: "Bulk Under-Fueled",
                        message: "Average intake is \(abs(calGap)) kcal under target while gain has stalled. Add a consistent 150–250 kcal before expecting muscle progress.",
                        severity: .medium,
                        category: .bodyComposition
                    ))
                }
            }
        }

        return results
    }

    // MARK: - Recommendations

    private func buildRecommendations(
        target: NutritionTarget,
        trend: BodyweightTrend,
        nutrition: NutritionAdherence,
        verdict: PhysiquePaceVerdict,
        recoveryScore: Int,
        baseConfidence: CoachingConfidence
    ) -> [Recommendation] {
        var recs: [Recommendation] = []

        // Only emit recommendations when we actually have a signal.
        guard trend.strength != .insufficient else { return recs }
        guard baseConfidence >= .moderate || verdict != .noSignal else { return recs }

        switch (target.nutritionGoal, verdict) {
        case (.leanBulk, .tooSlow), (.muscleGain, .tooSlow):
            recs.append(Recommendation(
                type: .general,
                title: "Tighten Nutrition for Gain",
                message: "Hold training pressure. Add a consistent 150–250 kcal and keep protein at \(target.proteinGrams)g daily for two weeks, then reassess.",
                priority: trend.strength == .strong ? 4 : 3
            ))

        case (.leanBulk, .tooFast), (.muscleGain, .tooFast):
            recs.append(Recommendation(
                type: .general,
                title: "Ease the Surplus",
                message: "You're gaining faster than needed. Trim ~200 kcal from intake to slow to \(formatRate(target.targetWeeklyChangeKg))/wk and protect leanness.",
                priority: 3
            ))

        case (.fatLoss, .tooSlow), (.aggressiveCut, .tooSlow):
            recs.append(Recommendation(
                type: .general,
                title: "Audit the Deficit",
                message: "Weight isn't moving. Before touching training, log a full week and see whether the deficit is actually being hit.",
                priority: 3
            ))

        case (.fatLoss, .tooFast), (.aggressiveCut, .tooFast):
            let msg: String
            if recoveryScore < 60 {
                msg = "Cut pace is aggressive and recovery is dropping. Add 150–250 kcal back to protect performance and muscle."
            } else {
                msg = "Slow the cut slightly — add ~150 kcal to land at \(formatRate(target.targetWeeklyChangeKg))/wk and preserve muscle."
            }
            recs.append(Recommendation(
                type: .general,
                title: "Ease the Deficit",
                message: msg,
                priority: 4
            ))

        case (.maintenance, .drifting), (.recomp, .drifting):
            let direction = trend.weeklyChangeKg > 0 ? "Trim" : "Add"
            recs.append(Recommendation(
                type: .general,
                title: "Stabilize Intake",
                message: "\(direction) ~150 kcal to return to maintenance. Stable weight is the goal right now.",
                priority: 2
            ))

        default:
            break
        }

        // Protein adherence when it's capping goal progress.
        if nutrition.strength != .insufficient && nutrition.proteinHitRate < 0.5 {
            if target.nutritionGoal == .leanBulk || target.nutritionGoal == .muscleGain {
                recs.append(Recommendation(
                    type: .general,
                    title: "Fix Protein First",
                    message: "Hit \(target.proteinGrams)g protein at least 5 of 7 days this week. Muscle-gain confidence stays capped until this is consistent.",
                    priority: 3
                ))
            } else if target.nutritionGoal == .fatLoss || target.nutritionGoal == .aggressiveCut {
                recs.append(Recommendation(
                    type: .general,
                    title: "Protect Muscle with Protein",
                    message: "Protein is hitting target only \(Int(nutrition.proteinHitRate * 100))% of days. Prioritize \(target.proteinGrams)g daily to preserve muscle through the cut.",
                    priority: 3
                ))
            }
        }

        return recs
    }

    // MARK: - Summary (for existing recoveryTrainingBridge / coach summaries)

    private func buildSummary(
        target: NutritionTarget,
        trend: BodyweightTrend,
        nutrition: NutritionAdherence,
        verdict: PhysiquePaceVerdict,
        recoveryScore: Int
    ) -> String? {
        guard trend.strength != .insufficient else { return nil }

        switch (target.nutritionGoal, verdict) {
        case (.leanBulk, .tooSlow), (.muscleGain, .tooSlow):
            return "Weight is rising slower than your gain goal — hold training pressure and tighten nutrition consistency."
        case (.leanBulk, .tooFast), (.muscleGain, .tooFast):
            return "Gaining faster than planned — ease the surplus to protect leanness."
        case (.fatLoss, .tooFast), (.aggressiveCut, .tooFast):
            if recoveryScore < 60 {
                return "Your cut is moving faster than planned while recovery is dropping — ease the deficit and protect performance."
            }
            return "Cut is moving too fast — ease the deficit to preserve muscle."
        case (.fatLoss, .tooSlow), (.aggressiveCut, .tooSlow):
            return "Cut has stalled — audit calorie adherence before pushing training harder."
        case (.maintenance, .aligned), (.recomp, .aligned):
            return "Bodyweight is stable and on plan — maintain current intake."
        case (_, .onTrack):
            if trend.strength == .strong {
                return "\(target.nutritionGoal.displayName) is tracking cleanly — maintain current intake."
            }
            return nil
        default:
            return nil
        }
    }

    private func onTrackMessage(target: NutritionTarget, trend: BodyweightTrend) -> String {
        switch target.nutritionGoal {
        case .leanBulk, .muscleGain:
            return "Gaining at \(formatRate(trend.weeklyChangeKg))/wk — right in the lean-gain window. Maintain intake."
        case .fatLoss, .aggressiveCut:
            return "Losing at \(formatRate(trend.weeklyChangeKg))/wk — sustainable pace for preserving muscle. Maintain the deficit."
        case .maintenance, .recomp:
            return "Bodyweight is stable — exactly where you want it for \(target.nutritionGoal.displayName.lowercased())."
        }
    }

    private func formatRate(_ kg: Double) -> String {
        if abs(kg) < 0.01 { return "0.00 kg" }
        return String(format: "%+.2f kg", kg)
    }
}
