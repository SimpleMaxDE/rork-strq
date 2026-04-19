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
        let noteFragment = readiness.painNote.isEmpty ? "" : " around \(readiness.painNote.lowercased())"
        let message = hasWorkout
            ? "You flagged something off\(noteFragment). Keep the session — but stay out of the pain path. Swap risky variations, drop load where needed, and end a set early if form breaks."
            : "You flagged something off\(noteFragment). Treat today as a recovery day: mobility, circulation, and sleep. Don't test it."

        return ReadinessCoachResponse(
            headline: hasWorkout ? "Train around it" : "Protect it today",
            message: message,
            icon: "shield.checkered",
            colorName: "orange",
            trainingAdvice: hasWorkout ? .useSaferVariations : .restDay,
            adjustments: hasWorkout
                ? [
                    "Swap to joint-friendly variations",
                    "Drop load ~15% on affected patterns",
                    "Stop a set the moment form slips"
                ]
                : [
                    "Mobility + light cardio only",
                    "Prioritize sleep and protein",
                    "Re-check tomorrow before training"
                ]
        )
    }

    // MARK: Peak

    private func highReadinessResponse(readiness: DailyReadiness, phase: TrainingPhase, hasWorkout: Bool) -> ReadinessCoachResponse {
        if !hasWorkout {
            return ReadinessCoachResponse(
                headline: "Bank the recovery",
                message: "You're fresh and firing — but no session is planned. Don't burn it on junk volume. Keep today active and easy so tomorrow's session gets the benefit.",
                icon: "bolt.fill",
                colorName: "mint",
                trainingAdvice: .trainAsPlanned,
                adjustments: [
                    "Walk, mobility, or light skill work",
                    "Hit protein + sleep targets",
                    "Prep tomorrow's lifts mentally"
                ]
            )
        }

        let phaseNote = phase == .push ? " You're in a push phase — this is a progression day." : ""
        return ReadinessCoachResponse(
            headline: "Green light — push",
            message: "Sleep, energy, and recovery are all stacked.\(phaseNote) Attack the top set and look for a real rep or load PR on the anchor lift.",
            icon: "bolt.fill",
            colorName: "mint",
            trainingAdvice: readiness.motivation.rawValue >= 4 ? .pushHard : .trainAsPlanned,
            adjustments: [
                "Warm up thoroughly — earn the intensity",
                "Push anchor lift: +1 rep or +2.5 kg",
                "Keep accessory quality, not just tonnage"
            ]
        )
    }

    // MARK: Good

    private func goodReadinessResponse(readiness: DailyReadiness, hasWorkout: Bool) -> ReadinessCoachResponse {
        if !hasWorkout {
            return ReadinessCoachResponse(
                headline: "Solid baseline",
                message: "Recovery is on track and no session is scheduled. Log your inputs and keep the signal clean for STRQ.",
                icon: "checkmark.circle.fill",
                colorName: "green",
                trainingAdvice: .trainAsPlanned,
                adjustments: [
                    "Log weight and sleep",
                    "Keep steps moving",
                    "Stay on nutrition"
                ]
            )
        }

        return ReadinessCoachResponse(
            headline: "Run the plan",
            message: "You're well-recovered. Follow today's prescription exactly — this is the kind of day progress is built on. Nothing fancy.",
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
                message: "You're not quite fresh and no session is planned — that's a fit. Use the day to rebuild: sleep, food, and light movement.",
                icon: "arrow.down.circle.fill",
                colorName: "yellow",
                trainingAdvice: .restDay,
                adjustments: [
                    "20–30 min walk or mobility",
                    "Hit protein target",
                    "Target 7h+ sleep tonight"
                ]
            )
        }

        var adjustments = ["Warm-up sets matter — don't rush them"]
        if readiness.soreness.rawValue >= 2 {
            adjustments.append("Cut last accessory set on sore muscles")
        }
        if readiness.energyLevel.rawValue <= 2 {
            adjustments.append("Cap session at ~45 min")
        }
        adjustments.append("Hold load, stay ~1 RIR lighter than usual")

        return ReadinessCoachResponse(
            headline: "Train, but tune it down",
            message: "Recovery is mixed. Don't chase a PR today — anchor lifts at planned load, accessories trimmed. Quality > tonnage.",
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
                headline: "Full recovery day",
                message: "Your body is telling you it needs time. Let it. Sleep, food, and walking will pay off more than anything else today.",
                icon: "bed.double.fill",
                colorName: "orange",
                trainingAdvice: .restDay,
                adjustments: [
                    "No training today",
                    "Extra hour of sleep if possible",
                    "Protein + water first",
                    "Re-check tomorrow"
                ]
            )
        }

        var adjustments = [
            "Drop working load ~15–20%",
            "Cut 1–2 accessory exercises",
            "Keep session under 40 min"
        ]
        if readiness.stressLevel.rawValue >= 4 {
            adjustments.append("If it still feels wrong — swap to mobility")
        }

        return ReadinessCoachResponse(
            headline: "Movement, not a grind",
            message: "Readiness is low. A short, lighter session beats skipping outright — but do not push through pain or form breakdown. Bank the rep quality, not the intensity.",
            icon: "heart.circle.fill",
            colorName: "orange",
            trainingAdvice: .shortenSession,
            adjustments: adjustments
        )
    }

    // MARK: Very low

    private func veryLowReadinessResponse(readiness: DailyReadiness, hasWorkout: Bool) -> ReadinessCoachResponse {
        return ReadinessCoachResponse(
            headline: hasWorkout ? "Skip today" : "Rest & rebuild",
            message: hasWorkout
                ? "Multiple systems are flagged. Training today costs more than it pays. Move the session — STRQ will rebalance the week."
                : "Multiple systems are flagged. Let today be about recovery. You'll come back measurably stronger.",
            icon: "bed.double.fill",
            colorName: "red",
            trainingAdvice: .restDay,
            adjustments: [
                "No lifting today",
                "Light walk, stretch, sunlight",
                "Eat well, sleep early",
                "Re-check tomorrow morning"
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
                    headline: "You're ready — let's train",
                    detail: "Readiness is high and today's session is waiting. Make it count.",
                    icon: "bolt.heart.fill",
                    colorName: "green"
                )
            } else if score < 50 {
                return DailyCoachMessage(
                    headline: "Recovery comes first today",
                    detail: "Your body is asking for rest. Light movement or a full rest day is the smart play.",
                    icon: "heart.circle.fill",
                    colorName: "orange"
                )
            }
        }

        if weeklySessionsCompleted >= weeklySessionsPlanned && weeklySessionsPlanned > 0 {
            return DailyCoachMessage(
                headline: "Weekly target hit",
                detail: "You've completed all planned sessions. Great discipline — enjoy the rest.",
                icon: "trophy.fill",
                colorName: "yellow"
            )
        }

        let remaining = weeklySessionsPlanned - weeklySessionsCompleted
        if remaining == 1 && hasWorkoutToday {
            return DailyCoachMessage(
                headline: "One session to go this week",
                detail: "Finish strong and you'll complete your weekly target.",
                icon: "flag.fill",
                colorName: "orange"
            )
        }

        if streak >= 7 {
            return DailyCoachMessage(
                headline: "Momentum is building",
                detail: "\(streak)-day streak. Consistency like this drives real results.",
                icon: "flame.fill",
                colorName: "orange"
            )
        }

        if hasWorkoutToday {
            return DailyCoachMessage(
                headline: "Training day",
                detail: "Today's session is ready. Warm up well and focus on quality.",
                icon: "figure.strengthtraining.traditional",
                colorName: "blue"
            )
        }

        return DailyCoachMessage(
            headline: "Active recovery day",
            detail: "No session planned. Light movement, stretching, or complete rest — you choose.",
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
            return "Incredible discipline. \(currentStreak) days and counting."
        } else if currentStreak >= 7 {
            return "Strong momentum. Keep the streak alive."
        } else if currentStreak >= 3 {
            return "Building consistency. Stay on track."
        } else if currentStreak > 0 {
            return "Getting started. Every session counts."
        } else {
            return "Start fresh today. One workout at a time."
        }
    }

    var paceMessage: String {
        switch weeklyPace {
        case .ahead: return "Ahead of schedule this week"
        case .onTrack: return "On track for your weekly target"
        case .behind: return "Behind this week — time to catch up"
        case .missed: return "No sessions yet this week"
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
