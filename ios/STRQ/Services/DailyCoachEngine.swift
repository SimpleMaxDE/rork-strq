import Foundation

struct DailyCoachEngine {

    private func weeklyOverflow(completed: Int, planned: Int) -> Int {
        guard planned > 0 else { return 0 }
        return max(0, completed - planned)
    }

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
        let noteFragment = readiness.painNote.isEmpty ? "" : String(format: " around %@", readiness.painNote.lowercased())
        let message = hasWorkout
            ? String(format: "Restriction noted%@. Keep the session, swap risky variations, reduce load, and end sets before form breaks.", noteFragment)
            : String(format: "Restriction noted%@. Keep today easy: mobility, light movement, and sleep first.", noteFragment)

        return ReadinessCoachResponse(
            headline: hasWorkout ? "Train controlled" : "Protect today",
            message: message,
            icon: "shield.checkered",
            colorName: "orange",
            trainingAdvice: hasWorkout ? .useSaferVariations : .restDay,
            adjustments: hasWorkout
                ? [
                    "Choose joint-friendly variations",
                    "Reduce affected lifts by about 15%",
                    "End the set when form breaks"
                ]
                : [
                    "Mobility and easy movement only",
                    "Prioritize sleep and protein",
                    "Check again before training tomorrow"
                ]
        )
    }

    // MARK: Peak

    private func highReadinessResponse(readiness: DailyReadiness, phase: TrainingPhase, hasWorkout: Bool) -> ReadinessCoachResponse {
        if !hasWorkout {
            return ReadinessCoachResponse(
                headline: "Use recovery",
                message: "Readiness is high, but no workout is planned. Stay active and easy so the next session lands clean.",
                icon: "bolt.fill",
                colorName: "mint",
                trainingAdvice: .trainAsPlanned,
                adjustments: [
                    "Walk, mobility, or light technique work",
                    "Hit protein and sleep targets",
                    "Prep tomorrow's lifts"
                ]
            )
        }

        let phaseNote = phase == .push ? " Push phase: check progress carefully." : ""
        return ReadinessCoachResponse(
            headline: "Green light",
            message: String(format: "Sleep, energy, and recovery look good.%@ Execute the top set cleanly and take only earned jumps on main lifts.", phaseNote),
            icon: "bolt.fill",
            colorName: "mint",
            trainingAdvice: readiness.motivation.rawValue >= 4 ? .pushHard : .trainAsPlanned,
            adjustments: [
                "Warm up well",
                "Main lift: check +1 rep or +2.5 kg",
                "Accessory quality before tonnage"
            ]
        )
    }

    // MARK: Good

    private func goodReadinessResponse(readiness: DailyReadiness, hasWorkout: Bool) -> ReadinessCoachResponse {
        if !hasWorkout {
            return ReadinessCoachResponse(
                headline: "Solid base",
                message: "Recovery looks stable and no workout is planned. Log inputs so STRQ reads the next workouts cleanly.",
                icon: "checkmark.circle.fill",
                colorName: "green",
                trainingAdvice: .trainAsPlanned,
                adjustments: [
                    "Log weight and sleep",
                    "Keep steps easy",
                    "Keep nutrition on target"
                ]
            )
        }

        return ReadinessCoachResponse(
            headline: "Run the plan",
            message: "Readiness looks good. Hit today's workout clean: target reps, target RPE, no forced extras.",
            icon: "checkmark.circle.fill",
            colorName: "green",
            trainingAdvice: .trainAsPlanned,
            adjustments: [
                "Hit target reps at target RPE",
                "Clean tempo, full ROM",
                "Log every set honestly"
            ]
        )
    }

    // MARK: Moderate

    private func moderateReadinessResponse(readiness: DailyReadiness, hasWorkout: Bool) -> ReadinessCoachResponse {
        if !hasWorkout {
            return ReadinessCoachResponse(
                headline: "Stack recovery",
                message: "You do not look fully fresh and no workout is planned. Good: prioritize sleep, food, and easy movement.",
                icon: "arrow.down.circle.fill",
                colorName: "yellow",
                trainingAdvice: .restDay,
                adjustments: [
                    "20-30 min walk or mobility",
                    "Hit protein target",
                    "Aim for 7+ hours of sleep tonight"
                ]
            )
        }

        var adjustments = ["Take warm-up sets seriously"]
        if readiness.soreness.rawValue >= 2 {
            adjustments.append("Cut the last accessory set if muscles are tired")
        }
        if readiness.energyLevel.rawValue <= 2 {
            adjustments.append("Cap the session around 45 min")
        }
        adjustments.append("Hold load, leave 1 rep in reserve")

        return ReadinessCoachResponse(
            headline: "Train, but lighter",
            message: "Recovery is mixed. Do not chase a PR today: main lifts to plan, accessories trimmed. Quality before tonnage.",
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
                headline: "Easy day",
                message: "Recovery reads low. Prioritize sleep, food, and easy movement today.",
                icon: "bed.double.fill",
                colorName: "orange",
                trainingAdvice: .restDay,
                adjustments: [
                    "No hard training today",
                    "If possible, get more sleep",
                    "Protein and water first",
                    "Check again tomorrow"
                ]
            )
        }

        var adjustments = [
            "Reduce working load by about 15-20%",
            "Cut 1-2 accessory exercises",
            "Keep the session under 40 min"
        ]
        if readiness.stressLevel.rawValue >= 4 {
            adjustments.append("If it still feels off: switch to mobility")
        }

        return ReadinessCoachResponse(
            headline: "Move, do not grind",
            message: "Readiness is low. A short, lighter session is okay, but do not push through pain or form loss. Rep quality counts.",
            icon: "heart.circle.fill",
            colorName: "orange",
            trainingAdvice: .shortenSession,
            adjustments: adjustments
        )
    }

    // MARK: Very low

    private func veryLowReadinessResponse(readiness: DailyReadiness, hasWorkout: Bool) -> ReadinessCoachResponse {
        return ReadinessCoachResponse(
            headline: hasWorkout ? "Skip today" : "Recover and check again",
            message: hasWorkout
                ? "Several signals are low. Move the session and make the next one lighter."
                : "Several signals are low. Prioritize recovery today and check again tomorrow.",
            icon: "bed.double.fill",
            colorName: "red",
            trainingAdvice: .restDay,
            adjustments: [
                "No lifting today",
                "Easy walk, stretching, daylight",
                "Eat well, sleep early",
                "Check again tomorrow morning"
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
                    headline: "Ready to train",
                    detail: "Readiness is high and today's workout is waiting. Execute cleanly.",
                    icon: "bolt.heart.fill",
                    colorName: "green"
                )
            } else if score < 50 {
                return DailyCoachMessage(
                    headline: "Recovery first today",
                    detail: "Recovery reads low. Easy movement or a quiet day makes sense.",
                    icon: "heart.circle.fill",
                    colorName: "orange"
                )
            }
        }

        if weeklySessionsCompleted >= weeklySessionsPlanned && weeklySessionsPlanned > 0 {
            let overflow = weeklyOverflow(completed: weeklySessionsCompleted, planned: weeklySessionsPlanned)
            return DailyCoachMessage(
                headline: "Weekly target hit",
                detail: overflow > 0
                    ? String(format: "Weekly target hit, +%d extra logged. Keep recovery honest before adding more.", overflow)
                    : "All planned sessions are done. Keep the rest of the week calm.",
                icon: "trophy.fill",
                colorName: "yellow"
            )
        }

        let remaining = weeklySessionsPlanned - weeklySessionsCompleted
        if remaining == 1 && hasWorkoutToday {
            return DailyCoachMessage(
                headline: "One more session this week",
                detail: "Finish clean and the weekly target is done.",
                icon: "flag.fill",
                colorName: "orange"
            )
        }

        if streak >= 7 {
            return DailyCoachMessage(
                headline: "Momentum is building",
                detail: String(format: "%d-day streak. Consistency is still the strongest lever.", streak),
                icon: "flame.fill",
                colorName: "orange"
            )
        }

        if hasWorkoutToday {
            return DailyCoachMessage(
                headline: "Training day",
                detail: "Today's workout is ready. Warm up well and prioritize quality.",
                icon: "figure.strengthtraining.traditional",
                colorName: "blue"
            )
        }

        return DailyCoachMessage(
            headline: "Active recovery day",
            detail: "No session planned. Easy movement, stretching, or full rest - your call.",
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
            return String(format: "Strong discipline. %d days in a row.", currentStreak)
        } else if currentStreak >= 7 {
            return "Strong momentum. Hold the streak."
        } else if currentStreak >= 3 {
            return "Consistency is building. Keep going."
        } else if currentStreak > 0 {
            return "Good start. Every session counts."
        } else {
            return "Start fresh today. One session at a time."
        }
    }

    var paceMessage: String {
        switch weeklyPace {
        case .ahead:
            if weeklySessionsPlanned > 0 && weeklySessionsCompleted > weeklySessionsPlanned {
                return String(format: "Target hit · +%d extra", weeklySessionsCompleted - weeklySessionsPlanned)
            }
            return "This week ahead of plan"
        case .onTrack:
            if weeklySessionsPlanned > 0 && weeklySessionsCompleted == weeklySessionsPlanned {
                return "Weekly target hit"
            }
            return "On track for weekly target"
        case .behind: return "This week behind plan"
        case .missed: return "No session yet this week"
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
