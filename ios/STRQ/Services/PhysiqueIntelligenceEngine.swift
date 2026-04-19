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

nonisolated enum PhysiqueConfidenceTier: Sendable {
    case calibrating
    case directional
    case confident
}

nonisolated struct BodyweightTrend: Sendable {
    let direction: PhysiqueTrendDirection
    let weeklyChangeKg: Double
    let spanDays: Int
    let entryCount: Int
    let noiseKg: Double
    let strength: PhysiqueSignalStrength
    // Projected change in kg if current slope persists 4 weeks.
    let projected4wKg: Double
    // Smoothed latest weight (3-point trailing mean), for visualization anchors.
    let smoothedLatestKg: Double?
}

nonisolated struct NutritionAdherence: Sendable {
    let proteinHitRate: Double
    let calorieAdherence: Double
    let loggedDays: Int
    let avgProtein: Int
    let avgCalories: Int
    let strength: PhysiqueSignalStrength
}

/// A single explanatory driver behind the verdict. Ordered by weight.
nonisolated struct PhysiqueDriver: Identifiable, Sendable {
    let id: String
    let icon: String
    let label: String       // short label, e.g. "Protein"
    let detail: String      // compact explanation, e.g. "42% of days hit floor"
    let weight: Int         // relative contribution (higher = more dominant)
    let polarity: Polarity  // supports / limits / neutral
    let state: DriverState  // palette state for color

    nonisolated enum Polarity: Sendable { case supports, limits, neutral }
    nonisolated enum DriverState: Sendable { case success, warning, danger, info, neutral }

    init(
        id: String = UUID().uuidString,
        icon: String,
        label: String,
        detail: String,
        weight: Int,
        polarity: Polarity,
        state: DriverState
    ) {
        self.id = id
        self.icon = icon
        self.label = label
        self.detail = detail
        self.weight = weight
        self.polarity = polarity
        self.state = state
    }
}

/// The single highest-leverage next step for the user this week.
nonisolated struct PhysiquePriority: Sendable {
    enum Kind: Sendable {
        case tightenCalories, easeDeficit, addCalories, easeSurplus
        case fixProtein, holdPattern, logMoreData, logWeight, logNutrition
        case protectRecovery
    }
    let kind: Kind
    let headline: String   // ~28 chars, imperative
    let detail: String     // one line, concrete
    let icon: String
}

nonisolated struct PhysiqueOutcome: Sendable {
    let trend: BodyweightTrend
    let nutrition: NutritionAdherence
    let paceVerdict: PhysiquePaceVerdict
    let confidence: PhysiqueConfidenceTier
    let drivers: [PhysiqueDriver]
    let priority: PhysiquePriority?
    let trainingBridge: String?
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
        let confidence = confidenceTier(trend: trend, nutrition: nutrition, verdict: verdict)

        let drivers = buildDrivers(
            target: target,
            trend: trend,
            nutrition: nutrition,
            verdict: verdict,
            recoveryScore: recoveryScore
        )

        let priority = buildPriority(
            target: target,
            trend: trend,
            nutrition: nutrition,
            verdict: verdict,
            recoveryScore: recoveryScore,
            confidence: confidence
        )

        let trainingBridge = buildTrainingBridge(
            target: target,
            trend: trend,
            nutrition: nutrition,
            verdict: verdict,
            recoveryScore: recoveryScore,
            confidence: confidence
        )

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
            confidence: confidence,
            drivers: drivers,
            priority: priority,
            trainingBridge: trainingBridge,
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
                strength: .insufficient,
                projected4wKg: 0,
                smoothedLatestKg: recent.last?.weightKg
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
            let threshold = max(0.08, noise * 0.4)
            if weeklyChange > threshold { return .rising }
            if weeklyChange < -threshold { return .falling }
            return .stable
        }()

        let smoothed: Double? = {
            guard recent.count >= 3 else { return recent.last?.weightKg }
            let tail = recent.suffix(3).map(\.weightKg)
            return tail.reduce(0, +) / Double(tail.count)
        }()

        return BodyweightTrend(
            direction: direction,
            weeklyChangeKg: weeklyChange,
            spanDays: spanDays,
            entryCount: recent.count,
            noiseKg: noise,
            strength: strength,
            projected4wKg: weeklyChange * 4.0,
            smoothedLatestKg: smoothed
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

    // MARK: - Confidence tier

    private func confidenceTier(
        trend: BodyweightTrend,
        nutrition: NutritionAdherence,
        verdict: PhysiquePaceVerdict
    ) -> PhysiqueConfidenceTier {
        if verdict == .noSignal { return .calibrating }
        if trend.strength == .strong && nutrition.strength != .insufficient {
            return .confident
        }
        if trend.strength == .moderate || trend.strength == .strong {
            return .directional
        }
        return .calibrating
    }

    // MARK: - Drivers

    private func buildDrivers(
        target: NutritionTarget,
        trend: BodyweightTrend,
        nutrition: NutritionAdherence,
        verdict: PhysiquePaceVerdict,
        recoveryScore: Int
    ) -> [PhysiqueDriver] {
        var drivers: [PhysiqueDriver] = []

        // Bodyweight slope
        if trend.strength != .insufficient {
            let rate = trend.weeklyChangeKg
            let targetRate = target.targetWeeklyChangeKg
            let delta = rate - targetRate
            let slopeState: PhysiqueDriver.DriverState
            let polarity: PhysiqueDriver.Polarity
            switch verdict {
            case .onTrack, .aligned:
                slopeState = .success; polarity = .supports
            case .drifting:
                slopeState = .warning; polarity = .limits
            case .tooSlow:
                slopeState = .warning; polarity = .limits
            case .tooFast:
                slopeState = .danger; polarity = .limits
            case .noSignal:
                slopeState = .info; polarity = .neutral
            }
            drivers.append(PhysiqueDriver(
                icon: "chart.line.uptrend.xyaxis",
                label: "Bodyweight slope",
                detail: String(format: "%+.2f kg/wk vs %+.2f target", rate, targetRate) + (abs(delta) >= 0.15 ? " · \(delta > 0 ? "above" : "below")" : ""),
                weight: abs(delta) > 0.15 ? 90 : 60,
                polarity: polarity,
                state: slopeState
            ))
        } else {
            drivers.append(PhysiqueDriver(
                icon: "scalemass",
                label: "Weigh-in signal",
                detail: "\(trend.entryCount) entries · need a week of data",
                weight: 40,
                polarity: .neutral,
                state: .info
            ))
        }

        // Protein
        if nutrition.strength != .insufficient {
            let rate = nutrition.proteinHitRate
            let state: PhysiqueDriver.DriverState
            let polarity: PhysiqueDriver.Polarity
            if rate >= 0.75 { state = .success; polarity = .supports }
            else if rate >= 0.5 { state = .warning; polarity = .limits }
            else { state = .danger; polarity = .limits }

            let contextSuffix: String
            switch target.nutritionGoal {
            case .leanBulk, .muscleGain: contextSuffix = "· limits muscle gain"
            case .fatLoss, .aggressiveCut: contextSuffix = "· protects muscle in cut"
            default: contextSuffix = ""
            }

            drivers.append(PhysiqueDriver(
                icon: "fork.knife",
                label: "Protein",
                detail: "\(Int(rate * 100))% of \(nutrition.loggedDays) days hit floor \(rate < 0.5 ? contextSuffix : "")".trimmingCharacters(in: .whitespaces),
                weight: rate < 0.5 ? 85 : (rate >= 0.8 ? 50 : 60),
                polarity: polarity,
                state: state
            ))
        } else {
            drivers.append(PhysiqueDriver(
                icon: "fork.knife",
                label: "Protein",
                detail: "No logs yet",
                weight: 30,
                polarity: .neutral,
                state: .info
            ))
        }

        // Calorie adherence vs direction
        if nutrition.strength != .insufficient && target.calories > 0 {
            let gap = nutrition.avgCalories - target.calories
            let absGap = abs(gap)
            let mismatched: Bool
            switch target.nutritionGoal {
            case .fatLoss, .aggressiveCut: mismatched = gap > 150
            case .leanBulk, .muscleGain: mismatched = gap < -150
            case .maintenance, .recomp: mismatched = absGap > 200
            }
            let state: PhysiqueDriver.DriverState
            let polarity: PhysiqueDriver.Polarity
            if mismatched { state = .warning; polarity = .limits }
            else if absGap <= 120 { state = .success; polarity = .supports }
            else { state = .neutral; polarity = .neutral }

            let dir = gap >= 0 ? "+" : "−"
            drivers.append(PhysiqueDriver(
                icon: "flame",
                label: "Calories",
                detail: "\(nutrition.avgCalories) kcal avg (\(dir)\(absGap) vs \(target.calories))",
                weight: mismatched ? 75 : 45,
                polarity: polarity,
                state: state
            ))
        }

        // Recovery (how the body is responding to nutrition)
        let recState: PhysiqueDriver.DriverState
        let recPolarity: PhysiqueDriver.Polarity
        switch recoveryScore {
        case 80...: recState = .success; recPolarity = .supports
        case 60..<80: recState = .warning; recPolarity = .neutral
        default: recState = .danger; recPolarity = .limits
        }
        let recContext: String = {
            switch (target.nutritionGoal, verdict) {
            case (.fatLoss, _), (.aggressiveCut, _):
                return recoveryScore < 60 ? "low · cut may be too aggressive" : "sustaining the cut"
            case (.leanBulk, _), (.muscleGain, _):
                return recoveryScore < 60 ? "low · under-fueled risk" : "supports overload"
            default:
                return "\(recoveryScore) score"
            }
        }()
        drivers.append(PhysiqueDriver(
            icon: "heart.fill",
            label: "Recovery",
            detail: recContext,
            weight: recoveryScore < 55 ? 70 : 40,
            polarity: recPolarity,
            state: recState
        ))

        // Sort by relative weight — strongest drivers first
        return drivers.sorted { $0.weight > $1.weight }
    }

    // MARK: - Priority focus

    private func buildPriority(
        target: NutritionTarget,
        trend: BodyweightTrend,
        nutrition: NutritionAdherence,
        verdict: PhysiquePaceVerdict,
        recoveryScore: Int,
        confidence: PhysiqueConfidenceTier
    ) -> PhysiquePriority? {
        // Data gaps first — these are the limiting factor before verdict quality.
        if trend.strength == .insufficient && nutrition.strength == .insufficient {
            return PhysiquePriority(
                kind: .logMoreData,
                headline: "Start the signal",
                detail: "Log a weigh-in and a few nutrition days — verdict unlocks in about a week.",
                icon: "waveform.path"
            )
        }
        if trend.strength == .insufficient {
            return PhysiquePriority(
                kind: .logWeight,
                headline: "Weigh in this week",
                detail: "Three weigh-ins across the week gives STRQ a real trend line.",
                icon: "scalemass"
            )
        }
        if nutrition.strength == .insufficient {
            return PhysiquePriority(
                kind: .logNutrition,
                headline: "Log a few days",
                detail: "A handful of nutrition days lets STRQ tell calorie drift from bodyweight noise.",
                icon: "square.and.pencil"
            )
        }

        // Aggressive cut with low recovery — protect performance before anything else.
        if (target.nutritionGoal == .fatLoss || target.nutritionGoal == .aggressiveCut) &&
            verdict == .tooFast && recoveryScore < 60 {
            return PhysiquePriority(
                kind: .protectRecovery,
                headline: "Protect recovery first",
                detail: "Cut is outpacing plan and recovery is dropping. Add ~200 kcal back this week.",
                icon: "shield.lefthalf.filled"
            )
        }

        // Protein is limiting
        if nutrition.proteinHitRate < 0.5 {
            return PhysiquePriority(
                kind: .fixProtein,
                headline: "Fix protein first",
                detail: "Only \(Int(nutrition.proteinHitRate * 100))% of days hit \(target.proteinGrams)g. Hit it 5 of 7 this week.",
                icon: "fork.knife"
            )
        }

        // Verdict-driven priority
        switch (target.nutritionGoal, verdict) {
        case (.leanBulk, .tooSlow), (.muscleGain, .tooSlow):
            return PhysiquePriority(
                kind: .addCalories,
                headline: "Add 150–200 kcal",
                detail: "Gain has stalled — nudge intake up and hold for two weeks before reassessing.",
                icon: "plus.circle"
            )
        case (.leanBulk, .tooFast), (.muscleGain, .tooFast):
            return PhysiquePriority(
                kind: .easeSurplus,
                headline: "Trim the surplus",
                detail: "Gaining too fast. Pull ~200 kcal to land near \(formatRate(target.targetWeeklyChangeKg))/wk.",
                icon: "minus.circle"
            )
        case (.fatLoss, .tooSlow), (.aggressiveCut, .tooSlow):
            return PhysiquePriority(
                kind: .tightenCalories,
                headline: "Tighten the deficit",
                detail: "Weight isn't moving. Audit a full week of logs before adjusting training.",
                icon: "gauge.with.dots.needle.33percent"
            )
        case (.fatLoss, .tooFast), (.aggressiveCut, .tooFast):
            return PhysiquePriority(
                kind: .easeDeficit,
                headline: "Ease the deficit",
                detail: "Add ~150 kcal to land at \(formatRate(target.targetWeeklyChangeKg))/wk and preserve muscle.",
                icon: "tortoise.fill"
            )
        case (.maintenance, .drifting), (.recomp, .drifting):
            let dir = trend.weeklyChangeKg > 0 ? "Trim" : "Add"
            return PhysiquePriority(
                kind: dir == "Trim" ? .easeSurplus : .addCalories,
                headline: "\(dir) ~150 kcal",
                detail: "Bring intake back to maintenance to hold the line.",
                icon: "equal.circle"
            )
        case (_, .onTrack), (_, .aligned):
            if confidence == .confident {
                return PhysiquePriority(
                    kind: .holdPattern,
                    headline: "Hold the pattern",
                    detail: "Intake and trend are aligned. Keep this week identical and let training compound.",
                    icon: "checkmark.seal.fill"
                )
            }
            return nil
        default:
            return nil
        }
    }

    // MARK: - Training bridge

    private func buildTrainingBridge(
        target: NutritionTarget,
        trend: BodyweightTrend,
        nutrition: NutritionAdherence,
        verdict: PhysiquePaceVerdict,
        recoveryScore: Int,
        confidence: PhysiqueConfidenceTier
    ) -> String? {
        guard confidence != .calibrating else { return nil }

        switch (target.nutritionGoal, verdict) {
        case (.leanBulk, .tooSlow), (.muscleGain, .tooSlow):
            if nutrition.avgCalories < target.calories - 150 {
                return "Under-fuelled gain — progression confidence will stay capped until intake lands."
            }
            return "Gain has stalled — expect STRQ to hold training pressure instead of pushing load."
        case (.leanBulk, .tooFast), (.muscleGain, .tooFast):
            return "Gaining fast — training can push, but weight is outpacing lean-gain range."
        case (.fatLoss, .tooFast), (.aggressiveCut, .tooFast):
            if recoveryScore < 60 {
                return "Aggressive cut is eroding recovery — session quality and PR odds will suffer this week."
            }
            return "Cut is moving fast — expect heavier sets to feel harder; ease intensity if bar speed drops."
        case (.fatLoss, .tooSlow), (.aggressiveCut, .tooSlow):
            return "Deficit isn't landing — training won't drive visible change until intake tightens."
        case (_, .onTrack) where nutrition.proteinHitRate >= 0.8 && recoveryScore >= 75:
            return "Nutrition and recovery are aligned — a strong week to push progression."
        case (.leanBulk, .onTrack), (.muscleGain, .onTrack):
            if nutrition.proteinHitRate < 0.6 {
                return "Gaining on plan, but protein consistency is the next lever for muscle conversion."
            }
            return nil
        default:
            return nil
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

    // MARK: - Summary

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
