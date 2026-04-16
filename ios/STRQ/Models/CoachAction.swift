import Foundation

nonisolated enum CoachActionType: String, Sendable {
    case reduceVolume
    case addWork
    case swapExercise
    case lighterSession
    case restDay
    case deload
    case regenerateWeek
    case increaseFrequency
    case progressWeight
    case adjustNutrition
    case celebrate
}

nonisolated struct CoachAction: Identifiable, Sendable {
    let id: String
    let type: CoachActionType
    let label: String
    let icon: String
    let explanation: String
    let whyItMatters: String
    let previewText: String

    init(id: String = UUID().uuidString, type: CoachActionType, label: String, icon: String, explanation: String, whyItMatters: String, previewText: String) {
        self.id = id
        self.type = type
        self.label = label
        self.icon = icon
        self.explanation = explanation
        self.whyItMatters = whyItMatters
        self.previewText = previewText
    }
}

struct CoachActionMapper {
    static func actions(for insight: SmartInsight) -> [CoachAction] {
        switch insight.category {
        case .volumeBalance:
            return volumeBalanceActions(insight)
        case .movementBalance:
            return movementBalanceActions(insight)
        case .recovery:
            return recoveryActions(insight)
        case .consistency:
            return consistencyActions(insight)
        case .progression:
            return progressionActions(insight)
        case .bodyComposition:
            return bodyCompositionActions(insight)
        case .general:
            return generalActions(insight)
        }
    }

    static func actions(for recommendation: Recommendation) -> [CoachAction] {
        switch recommendation.type {
        case .volumeImbalance:
            return [
                CoachAction(
                    type: .addWork,
                    label: "Rebalance Volume",
                    icon: "arrow.left.arrow.right",
                    explanation: "Shift sets from overtrained to undertrained muscle groups in your next session.",
                    whyItMatters: "Balanced volume across muscle groups reduces injury risk and builds a more proportional physique.",
                    previewText: "Next session: −1 set overtrained group, +2 sets undertrained group"
                )
            ]
        case .progressionSuggestion:
            return [
                CoachAction(
                    type: .progressWeight,
                    label: "Increase Weight",
                    icon: "arrow.up.right",
                    explanation: "Add a small increment to your working weight next session while maintaining rep quality.",
                    whyItMatters: "Progressive overload is the primary driver of strength and muscle gain over time.",
                    previewText: "Next session: +2.5kg on working sets, same rep target"
                )
            ]
        case .recoveryConcern:
            return [
                CoachAction(
                    type: .restDay,
                    label: "Take a Rest Day",
                    icon: "bed.double.fill",
                    explanation: "Skip your next planned session or replace it with light mobility work.",
                    whyItMatters: "Muscles grow during recovery, not during training. Adequate rest prevents overtraining.",
                    previewText: "Tomorrow: rest day or 20 min light stretching"
                ),
                CoachAction(
                    type: .lighterSession,
                    label: "Go Lighter",
                    icon: "arrow.down.circle",
                    explanation: "Reduce working weights by 15-20% and focus on form and controlled tempo.",
                    whyItMatters: "A lighter session maintains the training habit while allowing your body to recover.",
                    previewText: "Next session: −20% load, focus on mind-muscle connection"
                )
            ]
        case .exerciseSwap:
            return [
                CoachAction(
                    type: .swapExercise,
                    label: "Swap Exercise",
                    icon: "arrow.triangle.2.circlepath",
                    explanation: "Replace a stale movement with the suggested alternative to provide new stimulus.",
                    whyItMatters: "Exercise variety prevents plateaus and targets muscles from different angles.",
                    previewText: "Swap in the suggested exercise for your next session"
                )
            ]
        case .splitSuggestion:
            return [
                CoachAction(
                    type: .regenerateWeek,
                    label: "Regenerate Next Week",
                    icon: "arrow.triangle.2.circlepath.circle.fill",
                    explanation: "Regenerate the upcoming week to match your actual training frequency and optimize volume distribution.",
                    whyItMatters: "A plan that matches your real schedule distributes volume better and prevents overtraining.",
                    previewText: "Full week: adjusted for your real frequency"
                ),
                CoachAction(
                    type: .increaseFrequency,
                    label: "Update Plan Frequency",
                    icon: "calendar.badge.plus",
                    explanation: "Adjust your training plan to match your actual workout frequency for better volume distribution.",
                    whyItMatters: "Matching your plan to reality ensures volume is properly distributed across sessions.",
                    previewText: "Regenerate plan with updated session count"
                )
            ]
        case .prCongrats:
            return [
                CoachAction(
                    type: .celebrate,
                    label: "Keep Pushing",
                    icon: "trophy.fill",
                    explanation: "You're making great progress. Stay consistent and the gains will keep coming.",
                    whyItMatters: "Celebrating wins reinforces positive habits and keeps motivation high.",
                    previewText: "Continue current program — momentum is on your side"
                )
            ]
        case .general:
            return generalActions(nil)
        }
    }

    private static func volumeBalanceActions(_ insight: SmartInsight) -> [CoachAction] {
        if insight.severity == .high || insight.severity == .medium {
            return [
                CoachAction(
                    type: .regenerateWeek,
                    label: "Regenerate Next Week",
                    icon: "arrow.triangle.2.circlepath.circle.fill",
                    explanation: "Regenerate your entire upcoming week to rebalance muscle volume, improve exercise selection, and optimize recovery.",
                    whyItMatters: "A full week regeneration addresses multiple imbalances at once instead of patching one session at a time.",
                    previewText: "Full week: rebalanced volume, optimized exercises"
                ),
                CoachAction(
                    type: .addWork,
                    label: "Add Extra Sets",
                    icon: "plus.circle.fill",
                    explanation: "Add 2-3 sets for the undertrained muscle group in your next session.",
                    whyItMatters: "Consistently low volume on a muscle group leads to imbalances and slows overall progress.",
                    previewText: "Next session: +2 sets for the lagging group"
                ),
                CoachAction(
                    type: .reduceVolume,
                    label: "Reduce Overworked Sets",
                    icon: "minus.circle.fill",
                    explanation: "Drop 1-2 sets from the overtrained group to redistribute effort.",
                    whyItMatters: "Excess volume has diminishing returns and steals recovery capacity from other muscles.",
                    previewText: "Next session: −1 set from dominant group"
                )
            ]
        }
        return [
            CoachAction(
                type: .addWork,
                label: "Monitor Volume",
                icon: "eye.fill",
                explanation: "Keep an eye on this trend. If it persists next week, consider adjusting.",
                whyItMatters: "Small imbalances are normal week-to-week, but persistent ones should be addressed.",
                previewText: "No change needed yet — reassess next week"
            )
        ]
    }

    private static func movementBalanceActions(_ insight: SmartInsight) -> [CoachAction] {
        [
            CoachAction(
                type: .addWork,
                label: "Add Balancing Work",
                icon: "arrow.left.arrow.right",
                explanation: "Add sets of the underrepresented movement pattern to your next upper body day.",
                whyItMatters: "Push/pull imbalance increases shoulder injury risk and limits pressing strength.",
                previewText: "Next upper day: +2 sets of the weaker pattern"
            )
        ]
    }

    private static func recoveryActions(_ insight: SmartInsight) -> [CoachAction] {
        if insight.severity == .high {
            return [
                CoachAction(
                    type: .deload,
                    label: "Start Deload Week",
                    icon: "arrow.down.to.line",
                    explanation: "Reduce volume and intensity across all sessions this week to let accumulated fatigue dissipate.",
                    whyItMatters: "A deload week allows accumulated fatigue to dissipate, leading to a performance rebound. Training through high fatigue increases injury risk.",
                    previewText: "This week: reduced sets, lower RPE, shorter sessions"
                ),
                CoachAction(
                    type: .restDay,
                    label: "Rest Day",
                    icon: "bed.double.fill",
                    explanation: "Your body needs time to recover. Take tomorrow off from training entirely.",
                    whyItMatters: "Training through significant fatigue increases injury risk and impairs muscle growth.",
                    previewText: "Tomorrow: full rest day"
                )
            ]
        }
        return [
            CoachAction(
                type: .lighterSession,
                label: "Lighter Next Session",
                icon: "arrow.down.circle",
                explanation: "Reduce intensity on your next workout. Focus on technique and controlled reps.",
                whyItMatters: "Managing fatigue proactively prevents burnout and keeps you training consistently.",
                previewText: "Next session: −15% load, same exercises"
            )
        ]
    }

    private static func consistencyActions(_ insight: SmartInsight) -> [CoachAction] {
        if insight.severity == .positive {
            return [
                CoachAction(
                    type: .celebrate,
                    label: "Keep It Up",
                    icon: "star.fill",
                    explanation: "Your consistency is paying off. Stay on this trajectory.",
                    whyItMatters: "Consistency is the single most important factor for long-term results.",
                    previewText: "Continue current routine — you're on track"
                )
            ]
        }
        return [
            CoachAction(
                type: .increaseFrequency,
                label: "Schedule Sessions",
                icon: "calendar.badge.plus",
                explanation: "Block out specific times in your week for training to build the habit.",
                whyItMatters: "Scheduled sessions are far more likely to happen than 'whenever I feel like it'.",
                previewText: "Set reminders for your planned training days"
            )
        ]
    }

    private static func progressionActions(_ insight: SmartInsight) -> [CoachAction] {
        [
            CoachAction(
                type: .celebrate,
                label: "Celebrate This Win",
                icon: "trophy.fill",
                explanation: "You set a new personal record. Take a moment to appreciate your progress.",
                whyItMatters: "Recognizing progress keeps motivation high and reinforces the training habit.",
                previewText: "Log this milestone and keep pushing forward"
            )
        ]
    }

    private static func bodyCompositionActions(_ insight: SmartInsight) -> [CoachAction] {
        if insight.title.contains("Up") && insight.severity != .positive {
            return [
                CoachAction(
                    type: .adjustNutrition,
                    label: "Review Nutrition",
                    icon: "fork.knife",
                    explanation: "Your weight trend suggests a caloric adjustment may be needed to match your goal.",
                    whyItMatters: "Training drives the stimulus, but nutrition determines whether you gain or lose weight.",
                    previewText: "Consider reducing daily intake by 200-300 calories"
                )
            ]
        }
        return [
            CoachAction(
                type: .celebrate,
                label: "On Track",
                icon: "checkmark.circle.fill",
                explanation: "Your weight trend aligns with your goal. Keep doing what you're doing.",
                whyItMatters: "Consistent progress in the right direction means your plan is working.",
                previewText: "No changes needed — stay the course"
            )
        ]
    }

    private static func generalActions(_ insight: SmartInsight?) -> [CoachAction] {
        [
            CoachAction(
                type: .lighterSession,
                label: "Adjust Next Session",
                icon: "slider.horizontal.3",
                explanation: "Make a small adjustment to your next session based on how you're feeling.",
                whyItMatters: "Autoregulation — adjusting training to your daily readiness — is key to sustainable progress.",
                previewText: "Next session: listen to your body and adjust intensity"
            )
        ]
    }
}
