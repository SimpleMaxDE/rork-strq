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
                    label: "Balance volume",
                    icon: "arrow.left.arrow.right",
                    explanation: "Move a little work in the next fitting session from over-covered areas to under-covered ones.",
                    whyItMatters: "Balanced volume keeps the week clearer and load controlled.",
                    previewText: "Next session: 1 set less for the high area, 2 more for the low area"
                )
            ]
        case .progressionSuggestion:
            return [
                CoachAction(
                    type: .progressWeight,
                    label: "Add a little load",
                    icon: "arrow.up.right",
                    explanation: "Plan a little more weight if reps stay clean.",
                    whyItMatters: "Small clean jumps beat forced jumps.",
                    previewText: "Next session: check +2.5 kg, keep the rep target"
                )
            ]
        case .recoveryConcern:
            return [
                CoachAction(
                    type: .restDay,
                    label: "Keep today lighter",
                    icon: "bed.double.fill",
                    explanation: "Swap the next hard session for rest, a walk, or light mobility.",
                    whyItMatters: "When hard sessions stack up, an easy day is often the better call.",
                    previewText: "Tomorrow: rest or 20 min light mobility"
                ),
                CoachAction(
                    type: .lighterSession,
                    label: "Train lighter",
                    icon: "arrow.down.circle",
                    explanation: "Reduce working weights by 15-20% and keep tempo and technique clean.",
                    whyItMatters: "A lighter session keeps rhythm without adding pressure.",
                    previewText: "Next session: about 20% less load, focus on control"
                )
            ]
        case .exerciseSwap:
            return [
                CoachAction(
                    type: .swapExercise,
                    label: "Check variation",
                    icon: "arrow.triangle.2.circlepath",
                    explanation: "Check a similar variation if the current lift is not moving cleanly.",
                    whyItMatters: "A variation hits the muscle a little differently without changing the goal.",
                    previewText: "Next session: check the suggested variation"
                )
            ]
        case .splitSuggestion:
            return [
                CoachAction(
                    type: .regenerateWeek,
                    label: "Plan next week",
                    icon: "arrow.triangle.2.circlepath.circle.fill",
                    explanation: "Plan the coming week closer to what you actually logged.",
                    whyItMatters: "Plans that match real rhythm distribute volume better.",
                    previewText: "Full week: adjusted to real frequency"
                ),
                CoachAction(
                    type: .increaseFrequency,
                    label: "Check frequency",
                    icon: "calendar.badge.plus",
                    explanation: "Check whether planned frequency still matches your logs.",
                    whyItMatters: "A realistic frequency keeps the weekly target believable.",
                    previewText: "Plan frequency checked against logs"
                )
            ]
        case .prCongrats:
            return [
                CoachAction(
                    type: .celebrate,
                    label: "Hold course",
                    icon: "trophy.fill",
                    explanation: "Direction is good. Confirm the progress cleanly next session.",
                    whyItMatters: "PRs count more when the next move stays controlled.",
                    previewText: "Keep current structure"
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
                    label: "Plan next week",
                    icon: "arrow.triangle.2.circlepath.circle.fill",
                    explanation: "Rebuild the coming week so volume and exercise choices are distributed more cleanly.",
                    whyItMatters: "A weekly adjustment is clearer than several small fixes.",
                    previewText: "Full week: volume and exercises redistributed"
                ),
                CoachAction(
                    type: .addWork,
                    label: "Add sets",
                    icon: "plus.circle.fill",
                    explanation: "Add 2-3 sets for the low-work area if the next session has room.",
                    whyItMatters: "Low volume across multiple weeks is worth watching.",
                    previewText: "Next session: +2 sets for the lagging area"
                ),
                CoachAction(
                    type: .reduceVolume,
                    label: "Lower volume",
                    icon: "minus.circle.fill",
                    explanation: "Remove 1-2 sets from the over-covered area.",
                    whyItMatters: "Too much extra volume makes the week harder to read and can crowd out other areas.",
                    previewText: "Next session: 1 set less for the dominant area"
                )
            ]
        }
        return [
            CoachAction(
                type: .addWork,
                label: "Watch volume",
                icon: "eye.fill",
                explanation: "Keep the trend in view. If it stays next week, check an adjustment.",
                whyItMatters: "Small swings are normal; repeated trends matter more.",
                previewText: "No change needed yet - check again next week"
            )
        ]
    }

    private static func movementBalanceActions(_ insight: SmartInsight) -> [CoachAction] {
        [
            CoachAction(
                type: .addWork,
                label: "Add balance work",
                icon: "arrow.left.arrow.right",
                explanation: "Add sets for the lighter side on the next upper-body day.",
                whyItMatters: "A clearer push/pull ratio makes the week easier to steer.",
                previewText: "Next upper-body day: +2 sets for the lighter side"
            )
        ]
    }

    private static func recoveryActions(_ insight: SmartInsight) -> [CoachAction] {
        if insight.severity == .high {
            return [
                CoachAction(
                    type: .deload,
                    label: "Start deload week",
                    icon: "arrow.down.to.line",
                    explanation: "Reduce volume and intensity across the week.",
                    whyItMatters: "A lighter week keeps the next block cleaner.",
                    previewText: "This week: fewer sets, lower RPE, shorter sessions"
                ),
                CoachAction(
                    type: .restDay,
                    label: "Easy day",
                    icon: "bed.double.fill",
                    explanation: "Plan tomorrow without hard training.",
                    whyItMatters: "If the week was hard, an easy day is often the better call.",
                    previewText: "Tomorrow: no hard training"
                )
            ]
        }
        return [
            CoachAction(
                type: .lighterSession,
                label: "Next session lighter",
                icon: "arrow.down.circle",
                explanation: "Reduce intensity in the next session and keep reps controlled.",
                whyItMatters: "A lighter session keeps rhythm without pressing harder.",
                previewText: "Next session: about 15% less load, same exercises"
            )
        ]
    }

    private static func consistencyActions(_ insight: SmartInsight) -> [CoachAction] {
        if insight.severity == .positive {
            return [
                CoachAction(
                    type: .celebrate,
                    label: "Hold course",
                    icon: "star.fill",
                    explanation: "Consistency is in place. Keep the current structure.",
                    whyItMatters: "A stable rhythm makes the next weeks easier to plan.",
                    previewText: "Keep current routine"
                )
            ]
        }
        return [
            CoachAction(
                type: .increaseFrequency,
                label: "Plan sessions",
                icon: "calendar.badge.plus",
                explanation: "Block concrete time windows for the next training days.",
                whyItMatters: "Concrete slots make weekly rhythm more reliable.",
                previewText: "Set reminders for planned training days"
            )
        ]
    }

    private static func progressionActions(_ insight: SmartInsight) -> [CoachAction] {
        [
            CoachAction(
                type: .celebrate,
                label: "Lock in the PR",
                icon: "trophy.fill",
                explanation: "New PR logged. Confirm it cleanly next session.",
                whyItMatters: "A PR matters more when the next set is clean too.",
                previewText: "Milestone logged - keep structure"
            )
        ]
    }

    private static func bodyCompositionActions(_ insight: SmartInsight) -> [CoachAction] {
        if insight.title.contains("Up") && insight.severity != .positive {
            return [
                CoachAction(
                    type: .adjustNutrition,
                    label: "Check nutrition",
                    icon: "fork.knife",
                    explanation: "The weight trend does not clearly match the goal. Check nutrition and activity.",
                    whyItMatters: "Training and nutrition should point the same direction.",
                    previewText: "Check calories and training days"
                )
            ]
        }
        return [
            CoachAction(
                type: .celebrate,
                label: "On track",
                icon: "checkmark.circle.fill",
                explanation: "The weight trend fits the goal. Keep current structure.",
                whyItMatters: "A matching trend means no extra change is needed.",
                previewText: "No change needed - hold course"
            )
        ]
    }

    private static func generalActions(_ insight: SmartInsight?) -> [CoachAction] {
        [
            CoachAction(
                type: .lighterSession,
                label: "Adjust next session",
                icon: "slider.horizontal.3",
                explanation: "Make one small adjustment to the next session.",
                whyItMatters: "Readiness is just a check. One small adjustment is often enough.",
                previewText: "Next session: steer intensity deliberately"
            )
        ]
    }
}
