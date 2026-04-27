import Foundation

struct DailyCoachEngine {

    func generateCoachResponse(
        readiness: DailyReadiness,
        recoveryScore: Int,
        todaysWorkout: WorkoutDay?,
        recentSessions: [WorkoutSession],
        phase: TrainingPhase
    ) -> ReadinessCoachResponse {
        let score = readiness.readinessScore
        let hasWorkout = todaysWorkout != nil

        if readiness.painOrRestriction {
            return painResponse(readiness: readiness, hasWorkout: hasWorkout)
        }

        if score >= 85 {
            return highReadinessResponse(readiness: readiness, phase: phase, hasWorkout: hasWorkout)
        } else if score >= 70 {
            return goodReadinessResponse(readiness: readiness, hasWorkout: hasWorkout)
        } else if score >= 55 {
            return moderateReadinessResponse(readiness: readiness, hasWorkout: hasWorkout)
        } else if score >= 40 {
            return lowReadinessResponse(readiness: readiness, hasWorkout: hasWorkout)
        } else {
            return veryLowReadinessResponse(readiness: readiness, hasWorkout: hasWorkout)
        }
    }

    // MARK: Pain

    private func painResponse(readiness: DailyReadiness, hasWorkout: Bool) -> ReadinessCoachResponse {
        let noteFragment = readiness.painNote.isEmpty ? "" : L10n.format(" around %@", readiness.painNote.lowercased())
        let message = hasWorkout
            ? L10n.format("You flagged something off%@. Keep the workout, but stay out of the pain path. Swap risky variations, drop load where needed, and end a set early if form breaks.", noteFragment)
            : L10n.format("You flagged something off%@. Treat today as a recovery day: mobility, circulation, and sleep. Don't test it.", noteFragment)

        return ReadinessCoachResponse(
            headline: hasWorkout ? L10n.tr("Train around it") : L10n.tr("Protect it today"),
            message: message,
            icon: "shield.checkered",
            colorName: "orange",
            trainingAdvice: hasWorkout ? .useSaferVariations : .restDay,
            adjustments: hasWorkout
                ? [
                    L10n.tr("Swap to joint-friendly variations"),
                    L10n.tr("Drop load ~15% on affected patterns"),
                    L10n.tr("Stop a set the moment form slips")
                ]
                : [
                    L10n.tr("Mobility + light cardio only"),
                    L10n.tr("Prioritize sleep and protein"),
                    L10n.tr("Re-check tomorrow before training")
                ]
        )
    }

    // MARK: Peak

    private func highReadinessResponse(readiness: DailyReadiness, phase: TrainingPhase, hasWorkout: Bool) -> ReadinessCoachResponse {
        if !hasWorkout {
            return ReadinessCoachResponse(
                headline: L10n.tr("Bank the recovery"),
                message: L10n.tr("You're fresh and firing, but no workout is planned. Don't burn it on junk volume. Keep today active and easy so tomorrow's workout gets the benefit."),
                icon: "bolt.fill",
                colorName: "mint",
                trainingAdvice: .trainAsPlanned,
                adjustments: [
                    L10n.tr("Walk, mobility, or light skill work"),
                    L10n.tr("Hit protein + sleep targets"),
                    L10n.tr("Prep tomorrow's lifts mentally")
                ]
            )
        }

        let phaseNote = phase == .push ? " " + L10n.tr("You're in a push phase - this is a progression day.") : ""
        return ReadinessCoachResponse(
            headline: L10n.tr("Green light - push"),
            message: L10n.format("Sleep, energy, and recovery are all stacked.%@ Attack the top set and look for a real rep or load PR on the anchor lift.", phaseNote),
            icon: "bolt.fill",
            colorName: "mint",
            trainingAdvice: readiness.motivation.rawValue >= 4 ? .pushHard : .trainAsPlanned,
            adjustments: [
                L10n.tr("Warm up thoroughly - earn the intensity"),
                L10n.tr("Push anchor lift: +1 rep or +2.5 kg"),
                L10n.tr("Keep accessory quality, not just tonnage")
            ]
        )
    }

    // MARK: Good

    private func goodReadinessResponse(readiness: DailyReadiness, hasWorkout: Bool) -> ReadinessCoachResponse {
        if !hasWorkout {
            return ReadinessCoachResponse(
                headline: L10n.tr("Solid baseline"),
                message: L10n.tr("Recovery is on track and no workout is scheduled. Log your inputs and keep the signal clean for STRQ."),
                icon: "checkmark.circle.fill",
                colorName: "green",
                trainingAdvice: .trainAsPlanned,
                adjustments: [
                    L10n.tr("Log weight and sleep"),
                    L10n.tr("Keep steps moving"),
                    L10n.tr("Stay on nutrition")
                ]
            )
        }

        return ReadinessCoachResponse(
            headline: L10n.tr("Run the plan"),
            message: L10n.tr("You're well-recovered. Follow today's prescription exactly - this is the kind of day progress is built on. Nothing fancy."),
            icon: "checkmark.circle.fill",
            colorName: "green",
            trainingAdvice: .trainAsPlanned,
            adjustments: [
                L10n.tr("Hit target reps at target RPE"),
                L10n.tr("Clean tempo, full ROM"),
                L10n.tr("Log every set honestly")
            ]
        )
    }

    // MARK: Moderate

    private func moderateReadinessResponse(readiness: DailyReadiness, hasWorkout: Bool) -> ReadinessCoachResponse {
        if !hasWorkout {
            return ReadinessCoachResponse(
                headline: L10n.tr("Stack recovery"),
                message: L10n.tr("You're not quite fresh and no workout is planned - that's a fit. Use the day to rebuild: sleep, food, and light movement."),
                icon: "arrow.down.circle.fill",
                colorName: "yellow",
                trainingAdvice: .restDay,
                adjustments: [
                    L10n.tr("20-30 min walk or mobility"),
                    L10n.tr("Hit protein target"),
                    L10n.tr("Target 7h+ sleep tonight")
                ]
            )
        }

        var adjustments = [L10n.tr("Warm-up sets matter - don't rush them")]
        if readiness.soreness.rawValue >= 2 {
            adjustments.append(L10n.tr("Cut last accessory set on sore muscles"))
        }
        if readiness.energyLevel.rawValue <= 2 {
            adjustments.append(L10n.tr("Cap workout at ~45 min"))
        }
        adjustments.append(L10n.tr("Hold load, stay ~1 RIR lighter than usual"))

        return ReadinessCoachResponse(
            headline: L10n.tr("Train, but tune it down"),
            message: L10n.tr("Recovery is mixed. Don't chase a PR today - anchor lifts at planned load, accessories trimmed. Quality > tonnage."),
            icon: "arrow.down.circle.fill",
            colorName: "yellow",
            trainingAdvice: readiness.soreness.rawValue >= 3 ? .reduceAccessories : .trainButLighter,
            adjustments: adjustments
        )
    }

    // MARK: Low

    private func lowReadinessResponse(readiness: DailyReadiness, hasWorkout: Bool) -> ReadinessCoachResponse {
        if !hasWorkout {
            return ReadinessCoachResponse(
                headline: L10n.tr("Full recovery day"),
                message: L10n.tr("Your body is telling you it needs time. Let it. Sleep, food, and walking will pay off more than anything else today."),
                icon: "bed.double.fill",
                colorName: "orange",
                trainingAdvice: .restDay,
                adjustments: [
                    L10n.tr("No training today"),
                    L10n.tr("Extra hour of sleep if possible"),
                    L10n.tr("Protein + water first"),
                    L10n.tr("Re-check tomorrow")
                ]
            )
        }

        var adjustments = [
            L10n.tr("Drop working load ~15-20%"),
            L10n.tr("Cut 1-2 accessory exercises"),
            L10n.tr("Keep workout under 40 min")
        ]
        if readiness.stressLevel.rawValue >= 4 {
            adjustments.append(L10n.tr("If it still feels wrong - swap to mobility"))
        }

        return ReadinessCoachResponse(
            headline: L10n.tr("Movement, not a grind"),
            message: L10n.tr("Readiness is low. A short, lighter workout beats skipping outright - but do not push through pain or form breakdown. Bank the rep quality, not the intensity."),
            icon: "heart.circle.fill",
            colorName: "orange",
            trainingAdvice: .shortenSession,
            adjustments: adjustments
        )
    }

    // MARK: Very low

    private func veryLowReadinessResponse(readiness: DailyReadiness, hasWorkout: Bool) -> ReadinessCoachResponse {
        return ReadinessCoachResponse(
            headline: hasWorkout ? L10n.tr("Skip today") : L10n.tr("Rest & rebuild"),
            message: hasWorkout
                ? L10n.tr("Multiple systems are flagged. Training today costs more than it pays. Move the workout - STRQ will rebalance the week.")
                : L10n.tr("Multiple systems are flagged. Let today be about recovery. You'll come back measurably stronger."),
            icon: "bed.double.fill",
            colorName: "red",
            trainingAdvice: .restDay,
            adjustments: [
                L10n.tr("No lifting today"),
                L10n.tr("Light walk, stretch, sunlight"),
                L10n.tr("Eat well, sleep early"),
                L10n.tr("Re-check tomorrow morning")
            ]
        )
    }

    // MARK: Today / Coach messaging (unchanged signatures)

    func dailyCoachMessage(
        readiness: DailyReadiness?,
        recoveryScore: Int,
        streak: Int,
        weeklySessionsCompleted: Int,
        weeklySessionsPlanned: Int,
        phase: TrainingPhase,
        hasWorkoutToday: Bool
    ) -> DailyCoachMessage {
        if let r = readiness {
            let score = r.readinessScore
            if score >= 80 && hasWorkoutToday {
                return DailyCoachMessage(
                    headline: L10n.tr("You're ready - let's train"),
                    detail: L10n.tr("Readiness is high and today's workout is waiting. Make it count."),
                    icon: "bolt.heart.fill",
                    colorName: "green"
                )
            } else if score < 50 {
                return DailyCoachMessage(
                    headline: L10n.tr("Recovery comes first today"),
                    detail: L10n.tr("Your body is asking for rest. Light movement or a full rest day is the smart play."),
                    icon: "heart.circle.fill",
                    colorName: "orange"
                )
            }
        }

        if weeklySessionsCompleted >= weeklySessionsPlanned && weeklySessionsPlanned > 0 {
            return DailyCoachMessage(
                headline: L10n.tr("Weekly target hit"),
                detail: L10n.tr("You've completed all planned workouts. Great discipline - enjoy the rest."),
                icon: "trophy.fill",
                colorName: "yellow"
            )
        }

        let remaining = weeklySessionsPlanned - weeklySessionsCompleted
        if remaining == 1 && hasWorkoutToday {
            return DailyCoachMessage(
                headline: L10n.tr("One workout to go this week"),
                detail: L10n.tr("Finish strong and you'll complete your weekly target."),
                icon: "flag.fill",
                colorName: "orange"
            )
        }

        if streak >= 7 {
            return DailyCoachMessage(
                headline: L10n.tr("Momentum is building"),
                detail: L10n.format("%d-day streak. Consistency like this drives real results.", streak),
                icon: "flame.fill",
                colorName: "orange"
            )
        }

        if hasWorkoutToday {
            return DailyCoachMessage(
                headline: L10n.tr("Training day"),
                detail: L10n.tr("Today's workout is ready. Warm up well and focus on quality."),
                icon: "figure.strengthtraining.traditional",
                colorName: "blue"
            )
        }

        return DailyCoachMessage(
            headline: L10n.tr("Active recovery day"),
            detail: L10n.tr("No workout planned. Light movement, stretching, or complete rest - you choose."),
            icon: "leaf.fill",
            colorName: "green"
        )
    }
}

nonisolated struct DailyCoachMessage: Sendable {
    let headline: String
    let detail: String
    let icon: String
    let colorName: String
}

nonisolated struct MomentumData: Sendable {
    let currentStreak: Int
    let longestStreak: Int
    let weeklyPace: WeeklyPace
    let weeklySessionsCompleted: Int
    let weeklySessionsPlanned: Int
    let consistencyPercent: Int
    let recentWins: [String]

    var streakMessage: String {
        if currentStreak >= 14 {
            return L10n.format("Incredible discipline. %d days and counting.", currentStreak)
        } else if currentStreak >= 7 {
            return L10n.tr("Strong momentum. Keep the streak alive.")
        } else if currentStreak >= 3 {
            return L10n.tr("Building consistency. Stay on track.")
        } else if currentStreak > 0 {
            return L10n.tr("Getting started. Every workout counts.")
        } else {
            return L10n.tr("Start fresh today. One workout at a time.")
        }
    }

    var paceMessage: String {
        switch weeklyPace {
        case .ahead: return L10n.tr("Ahead of schedule this week")
        case .onTrack: return L10n.tr("On track for your weekly target")
        case .behind: return L10n.tr("Behind this week - time to catch up")
        case .missed: return L10n.tr("No workouts yet this week")
        }
    }
}

nonisolated enum WeeklyPace: String, Sendable {
    case ahead
    case onTrack
    case behind
    case missed

    var colorName: String {
        switch self {
        case .ahead: return "green"
        case .onTrack: return "blue"
        case .behind: return "orange"
        case .missed: return "red"
        }
    }

    var icon: String {
        switch self {
        case .ahead: return "arrow.up.right.circle.fill"
        case .onTrack: return "checkmark.circle.fill"
        case .behind: return "exclamationmark.circle.fill"
        case .missed: return "xmark.circle.fill"
        }
    }
}
