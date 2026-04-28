import Foundation

struct NutritionCoachEngine {

    func computeTargets(profile: UserProfile) -> NutritionTarget {
        let bmr = harrisBenedictBMR(profile: profile)
        let activityMultiplier = activityFactor(profile.activityLevel)
        let tdee = Int(bmr * activityMultiplier)

        let nutritionGoal = mapGoal(profile.goal)
        let weightDirection = weightGoalDirection(for: nutritionGoal)

        let calorieOffset: Int
        let weeklyChange: Double
        switch nutritionGoal {
        case .leanBulk:
            calorieOffset = 250
            weeklyChange = 0.25
        case .muscleGain:
            calorieOffset = 400
            weeklyChange = 0.35
        case .maintenance:
            calorieOffset = 0
            weeklyChange = 0
        case .fatLoss:
            calorieOffset = -400
            weeklyChange = -0.4
        case .aggressiveCut:
            calorieOffset = -600
            weeklyChange = -0.6
        case .recomp:
            calorieOffset = -100
            weeklyChange = 0
        }

        let calories = tdee + calorieOffset
        let proteinGrams = Int(profile.weightKg * proteinMultiplier(for: nutritionGoal, level: profile.trainingLevel))
        let fatGrams = Int(profile.weightKg * 0.9)
        let fatCalories = fatGrams * 9
        let proteinCalories = proteinGrams * 4
        let carbCalories = max(0, calories - proteinCalories - fatCalories)
        let carbGrams = carbCalories / 4

        return NutritionTarget(
            calories: calories,
            proteinGrams: proteinGrams,
            carbsGrams: carbGrams,
            fatGrams: fatGrams,
            nutritionGoal: nutritionGoal,
            weightGoalDirection: weightDirection,
            targetWeeklyChangeKg: weeklyChange
        )
    }

    func generateInsights(
        target: NutritionTarget,
        recentLogs: [DailyNutritionLog],
        weightEntries: [BodyWeightEntry],
        sleepEntries: [SleepEntry],
        profile: UserProfile,
        recoveryScore: Int
    ) -> [NutritionCoachInsight] {
        var insights: [NutritionCoachInsight] = []

        let last7Logs = recentLogs.filter { daysSince($0.date) <= 7 }

        if !last7Logs.isEmpty {
            let avgProtein = last7Logs.map(\.proteinGrams).reduce(0, +) / last7Logs.count
            let proteinRatio = Double(avgProtein) / Double(target.proteinGrams)

            if proteinRatio < 0.75 {
                insights.append(NutritionCoachInsight(
                    icon: "exclamationmark.triangle.fill",
                    colorName: "orange",
                    title: "Protein Intake Low",
                    message: "Averaging \(avgProtein)g vs \(target.proteinGrams)g target. This may limit muscle recovery and growth. Prioritize protein at every meal.",
                    category: .protein
                ))
            } else if proteinRatio >= 0.9 && proteinRatio <= 1.1 {
                insights.append(NutritionCoachInsight(
                    icon: "checkmark.circle.fill",
                    colorName: "green",
                    title: "Protein On Track",
                    message: "Averaging \(avgProtein)g protein — right in line with your \(target.proteinGrams)g target. Keep it up.",
                    category: .protein
                ))
            }

            let avgCalories = last7Logs.map(\.calories).reduce(0, +) / last7Logs.count
            let calDiff = avgCalories - target.calories

            if abs(calDiff) > 300 {
                let direction = calDiff > 0 ? "over" : "under"
                let impact: String
                switch target.nutritionGoal {
                case .fatLoss, .aggressiveCut:
                    impact = calDiff > 0 ? "This may slow your fat loss progress." : "Deficit may be too aggressive — watch energy levels."
                case .leanBulk, .muscleGain:
                    impact = calDiff > 0 ? "Surplus may be too high — risking excess fat gain." : "You're not eating enough to support muscle growth."
                default:
                    impact = calDiff > 0 ? "Consistently over target." : "Consistently under target."
                }

                insights.append(NutritionCoachInsight(
                    icon: calDiff > 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                    colorName: calDiff > 0 ? "orange" : "yellow",
                    title: "Calories \(abs(calDiff)) \(direction) target",
                    message: "Averaging \(avgCalories) kcal vs \(target.calories) target. \(impact)",
                    category: .calories
                ))
            }
        }

        let last14Weights = weightEntries.filter { daysSince($0.date) <= 14 }.sorted { $0.date < $1.date }
        if last14Weights.count >= 3 {
            let first3Avg = last14Weights.prefix(3).map(\.weightKg).reduce(0, +) / 3.0
            let last3Avg = last14Weights.suffix(3).map(\.weightKg).reduce(0, +) / 3.0
            let weeklyChange = (last3Avg - first3Avg) / 2.0

            let pace = goalPaceStatus(target: target, weeklyChange: weeklyChange)
            if !pace.isOnTrack {
                insights.append(NutritionCoachInsight(
                    icon: pace.icon,
                    colorName: pace.colorName,
                    title: pace.headline,
                    message: pace.detail,
                    category: .goalPace
                ))
            }
        }

        let last7Sleep = sleepEntries.filter { daysSince($0.date) <= 7 }
        if !last7Sleep.isEmpty {
            let avgHours = last7Sleep.map(\.hoursSlept).reduce(0, +) / Double(last7Sleep.count)
            let avgQuality = Double(last7Sleep.map { $0.quality.rawValue }.reduce(0, +)) / Double(last7Sleep.count)

            if avgHours < 6.5 {
                insights.append(NutritionCoachInsight(
                    icon: "moon.zzz.fill",
                    colorName: "purple",
                    title: "Sleep Below Threshold",
                    message: "Averaging \(String(format: "%.1f", avgHours))h sleep. Under 7h limits recovery, muscle growth, and fat loss. Prioritize sleep quality.",
                    category: .sleep
                ))
            } else if avgHours >= 7.5 && avgQuality >= 3.5 {
                insights.append(NutritionCoachInsight(
                    icon: "moon.fill",
                    colorName: "mint",
                    title: "Sleep Supporting Recovery",
                    message: "Averaging \(String(format: "%.1f", avgHours))h of quality sleep. This supports your training recovery well.",
                    category: .sleep
                ))
            }
        }

        if recoveryScore < 50 && !last7Sleep.isEmpty {
            let avgSleepQuality = Double(last7Sleep.map { $0.quality.rawValue }.reduce(0, +)) / Double(last7Sleep.count)
            if avgSleepQuality < 3.0 {
                insights.append(NutritionCoachInsight(
                    icon: "heart.circle.fill",
                    colorName: "red",
                    title: "Recovery Suffering",
                    message: "Low recovery score combined with poor sleep. Consider lighter training this week and focus on sleep hygiene.",
                    category: .recovery
                ))
            }
        }

        if !last7Logs.isEmpty && !last7Sleep.isEmpty {
            let avgProtein = last7Logs.map(\.proteinGrams).reduce(0, +) / last7Logs.count
            let proteinRatio = Double(avgProtein) / Double(max(1, target.proteinGrams))
            let avgHours = last7Sleep.map(\.hoursSlept).reduce(0, +) / Double(last7Sleep.count)

            if proteinRatio < 0.8 && avgHours < 7.0 {
                insights.append(NutritionCoachInsight(
                    icon: "figure.strengthtraining.traditional",
                    colorName: "orange",
                    title: "Training Recovery at Risk",
                    message: "Low protein (\(avgProtein)g) combined with poor sleep (\(String(format: "%.1f", avgHours))h) is limiting your muscle recovery. Fix protein first — it's the easier win.",
                    category: .recovery
                ))
            }

            if proteinRatio < 0.8 && (target.nutritionGoal == .leanBulk || target.nutritionGoal == .muscleGain) {
                insights.append(NutritionCoachInsight(
                    icon: "arrow.up.right.circle.fill",
                    colorName: "blue",
                    title: "Protein Limiting Muscle Gain",
                    message: "Your goal is \(target.nutritionGoal.displayName) but protein intake is only \(Int(proteinRatio * 100))% of target. Without adequate protein, your training stimulus can't fully convert to muscle.",
                    category: .protein
                ))
            }

            if proteinRatio >= 0.9 && avgHours >= 7.5 && recoveryScore >= 75 {
                insights.append(NutritionCoachInsight(
                    icon: "bolt.fill",
                    colorName: "green",
                    title: "Recovery Fully Optimized",
                    message: "Protein on target, sleep quality solid, recovery score high. Your body is in an ideal state to handle progressive overload.",
                    category: .recovery
                ))
            }
        }

        if !last7Sleep.isEmpty {
            let avgHours = last7Sleep.map(\.hoursSlept).reduce(0, +) / Double(last7Sleep.count)
            if avgHours < 6.5 && (target.nutritionGoal == .fatLoss || target.nutritionGoal == .aggressiveCut) {
                insights.append(NutritionCoachInsight(
                    icon: "flame.fill",
                    colorName: "red",
                    title: "Sleep Undermining Fat Loss",
                    message: "Poor sleep increases cortisol and hunger hormones, making fat loss harder even in a deficit. Prioritize 7+ hours for better results.",
                    category: .sleep
                ))
            }
        }

        if !last7Logs.isEmpty {
            let avgCalories = last7Logs.map(\.calories).reduce(0, +) / last7Logs.count
            let calDiff = avgCalories - target.calories

            if calDiff < -500 && recoveryScore < 60 {
                insights.append(NutritionCoachInsight(
                    icon: "battery.25percent",
                    colorName: "red",
                    title: "Under-Fueled + Low Recovery",
                    message: "Eating \(abs(calDiff)) kcal under target with low recovery. This combination increases injury risk and performance decline. Eat closer to target on training days.",
                    category: .calories
                ))
            }

            let weeklyWater = last7Logs.map(\.waterLiters).reduce(0, +) / Double(last7Logs.count)
            if weeklyWater > 0 && weeklyWater < 2.0 {
                insights.append(NutritionCoachInsight(
                    icon: "drop.fill",
                    colorName: "cyan",
                    title: "Hydration Below Optimal",
                    message: "Averaging \(String(format: "%.1f", weeklyWater))L water daily. Aim for 2.5-3L to support training performance and recovery.",
                    category: .hydration
                ))
            }
        }

        return insights
    }

    func goalPaceStatus(target: NutritionTarget, weeklyChange: Double) -> GoalPaceStatus {
        let targetChange = target.targetWeeklyChangeKg

        switch target.nutritionGoal {
        case .leanBulk, .muscleGain:
            if weeklyChange < 0.05 {
                return GoalPaceStatus(
                    headline: "Gaining Too Slowly",
                    detail: "Weight change is minimal (\(String(format: "%+.2f", weeklyChange)) kg/wk). You may need to increase calories by 100-200 to support muscle growth.",
                    icon: "arrow.down.right",
                    colorName: "yellow",
                    weeklyChangeKg: weeklyChange,
                    targetChangeKg: targetChange,
                    isOnTrack: false
                )
            } else if weeklyChange > 0.5 {
                return GoalPaceStatus(
                    headline: "Gaining Too Fast",
                    detail: "Weight is increasing at \(String(format: "+%.2f", weeklyChange)) kg/wk — faster than optimal. Reduce surplus slightly to minimize fat gain.",
                    icon: "exclamationmark.triangle.fill",
                    colorName: "orange",
                    weeklyChangeKg: weeklyChange,
                    targetChangeKg: targetChange,
                    isOnTrack: false
                )
            } else {
                return GoalPaceStatus(
                    headline: "Gaining On Track",
                    detail: "Weight trend is \(String(format: "+%.2f", weeklyChange)) kg/wk — ideal for lean muscle gain.",
                    icon: "checkmark.circle.fill",
                    colorName: "green",
                    weeklyChangeKg: weeklyChange,
                    targetChangeKg: targetChange,
                    isOnTrack: true
                )
            }
        case .fatLoss, .aggressiveCut:
            if weeklyChange > -0.1 {
                return GoalPaceStatus(
                    headline: "Not Losing Fast Enough",
                    detail: "Weight is barely changing (\(String(format: "%+.2f", weeklyChange)) kg/wk). Ensure you're in a consistent calorie deficit.",
                    icon: "arrow.right",
                    colorName: "yellow",
                    weeklyChangeKg: weeklyChange,
                    targetChangeKg: targetChange,
                    isOnTrack: false
                )
            } else if weeklyChange < -0.8 {
                return GoalPaceStatus(
                    headline: "Losing Too Quickly",
                    detail: "Weight dropping at \(String(format: "%.2f", abs(weeklyChange))) kg/wk — too aggressive. Risk of muscle loss. Increase calories slightly.",
                    icon: "exclamationmark.triangle.fill",
                    colorName: "red",
                    weeklyChangeKg: weeklyChange,
                    targetChangeKg: targetChange,
                    isOnTrack: false
                )
            } else {
                return GoalPaceStatus(
                    headline: "Fat Loss On Track",
                    detail: "Losing \(String(format: "%.2f", abs(weeklyChange))) kg/wk — sustainable pace for preserving muscle.",
                    icon: "checkmark.circle.fill",
                    colorName: "green",
                    weeklyChangeKg: weeklyChange,
                    targetChangeKg: targetChange,
                    isOnTrack: true
                )
            }
        case .maintenance, .recomp:
            if abs(weeklyChange) > 0.3 {
                let direction = weeklyChange > 0 ? "gaining" : "losing"
                return GoalPaceStatus(
                    headline: "Weight Drifting",
                    detail: "You're \(direction) \(String(format: "%.2f", abs(weeklyChange))) kg/wk while targeting maintenance. Adjust intake to stabilize.",
                    icon: "exclamationmark.circle.fill",
                    colorName: "yellow",
                    weeklyChangeKg: weeklyChange,
                    targetChangeKg: targetChange,
                    isOnTrack: false
                )
            } else {
                return GoalPaceStatus(
                    headline: "Weight Stable",
                    detail: "Weight is holding steady — right on target for \(target.nutritionGoal.displayName.lowercased()).",
                    icon: "checkmark.circle.fill",
                    colorName: "green",
                    weeklyChangeKg: weeklyChange,
                    targetChangeKg: targetChange,
                    isOnTrack: true
                )
            }
        }
    }

    func dailyNutritionSummary(
        todayLog: DailyNutritionLog?,
        target: NutritionTarget
    ) -> String {
        guard let log = todayLog else {
            return "No nutrition logged today. Track your meals to get personalized guidance."
        }
        let proteinPct = target.proteinGrams > 0 ? (log.proteinGrams * 100) / target.proteinGrams : 0
        let calPct = target.calories > 0 ? (log.calories * 100) / target.calories : 0

        if proteinPct >= 80 && calPct >= 70 {
            return "Nutrition looking solid today — \(log.proteinGrams)g protein, \(log.calories) kcal."
        } else if proteinPct < 50 {
            return "Protein is at \(proteinPct)% of target. Try to get more protein in your next meal."
        } else {
            return "\(log.calories) kcal logged (\(calPct)% of target). \(log.proteinGrams)g protein (\(proteinPct)%)."
        }
    }

    private func harrisBenedictBMR(profile: UserProfile) -> Double {
        let weight = profile.weightKg
        let height = profile.heightCm
        let age = Double(profile.age)

        switch profile.gender {
        case .male, .other, .preferNotToSay:
            return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * age)
        case .female:
            return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * age)
        }
    }

    private func activityFactor(_ level: ActivityLevel) -> Double {
        switch level {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .extremelyActive: return 1.9
        }
    }

    private func mapGoal(_ fitnessGoal: FitnessGoal) -> NutritionGoal {
        switch fitnessGoal {
        case .muscleGain: return .leanBulk
        case .strength: return .muscleGain
        case .fatLoss: return .fatLoss
        case .generalFitness: return .maintenance
        case .endurance: return .maintenance
        case .flexibility: return .maintenance
        case .athleticPerformance: return .leanBulk
        case .rehabilitation: return .maintenance
        }
    }

    private func proteinMultiplier(for goal: NutritionGoal, level: TrainingLevel) -> Double {
        let base: Double
        switch goal {
        case .leanBulk, .muscleGain: base = 2.0
        case .fatLoss, .aggressiveCut: base = 2.2
        case .maintenance, .recomp: base = 1.8
        }
        switch level {
        case .beginner: return base * 0.9
        case .intermediate: return base
        case .advanced: return base * 1.05
        }
    }

    private func weightGoalDirection(for goal: NutritionGoal) -> WeightGoalDirection {
        switch goal {
        case .leanBulk, .muscleGain: return .gaining
        case .fatLoss, .aggressiveCut: return .losing
        case .maintenance, .recomp: return .maintaining
        }
    }

    private func daysSince(_ date: Date) -> Int {
        Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
    }
}
