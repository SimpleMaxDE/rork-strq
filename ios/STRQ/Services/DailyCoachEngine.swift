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

        if readiness.painOrRestriction {
            return ReadinessCoachResponse(
                headline: "Protect Yourself Today",
                message: "You reported pain or restriction. Use safer exercise variations and avoid aggravating movements. Listen to your body — consistency matters more than one hard session.",
                icon: "shield.checkered",
                colorName: "orange",
                trainingAdvice: .useSaferVariations,
                adjustments: [
                    "Swap to joint-friendly alternatives",
                    "Reduce load on affected area",
                    "Skip exercises that cause discomfort"
                ]
            )
        }

        if score >= 85 {
            return highReadinessResponse(readiness: readiness, phase: phase, todaysWorkout: todaysWorkout)
        } else if score >= 70 {
            return goodReadinessResponse(readiness: readiness, todaysWorkout: todaysWorkout)
        } else if score >= 55 {
            return moderateReadinessResponse(readiness: readiness, todaysWorkout: todaysWorkout)
        } else if score >= 40 {
            return lowReadinessResponse(readiness: readiness, todaysWorkout: todaysWorkout)
        } else {
            return veryLowReadinessResponse(readiness: readiness)
        }
    }

    private func highReadinessResponse(readiness: DailyReadiness, phase: TrainingPhase, todaysWorkout: WorkoutDay?) -> ReadinessCoachResponse {
        let pushPhrase = phase == .push ? " You're in a push phase — take advantage." : ""
        return ReadinessCoachResponse(
            headline: "You're Ready to Go",
            message: "Sleep, energy, and recovery are all strong. Train as planned and push for progress.\(pushPhrase)",
            icon: "bolt.fill",
            colorName: "mint",
            trainingAdvice: readiness.motivation.rawValue >= 4 ? .pushHard : .trainAsPlanned,
            adjustments: [
                "Train at full intensity",
                "Good day to test progression",
                "Push for an extra rep or small weight increase"
            ]
        )
    }

    private func goodReadinessResponse(readiness: DailyReadiness, todaysWorkout: WorkoutDay?) -> ReadinessCoachResponse {
        return ReadinessCoachResponse(
            headline: "Solid Day Ahead",
            message: "You're well-recovered and ready to train. Follow your planned session and focus on quality reps.",
            icon: "checkmark.circle.fill",
            colorName: "green",
            trainingAdvice: .trainAsPlanned,
            adjustments: [
                "Follow planned session",
                "Maintain current intensity",
                "Focus on technique and control"
            ]
        )
    }

    private func moderateReadinessResponse(readiness: DailyReadiness, todaysWorkout: WorkoutDay?) -> ReadinessCoachResponse {
        var adjustments = ["Lower RPE targets by ~1 point"]
        if readiness.soreness.rawValue >= 2 {
            adjustments.append("Reduce accessories by 1 set each")
        }
        if readiness.energyLevel.rawValue <= 2 {
            adjustments.append("Shorten session by 10–15 min")
        }
        adjustments.append("Prioritize compound movements")

        return ReadinessCoachResponse(
            headline: "Take It Steady Today",
            message: "Recovery is moderate. You can still train productively, but dial back the intensity slightly. Focus on the main lifts and cut accessories if needed.",
            icon: "arrow.down.circle.fill",
            colorName: "yellow",
            trainingAdvice: readiness.soreness.rawValue >= 3 ? .reduceAccessories : .trainButLighter,
            adjustments: adjustments
        )
    }

    private func lowReadinessResponse(readiness: DailyReadiness, todaysWorkout: WorkoutDay?) -> ReadinessCoachResponse {
        var adjustments = [
            "Reduce load by 15–20%",
            "Cut 1–2 accessory exercises",
            "Keep session under 40 min"
        ]
        if readiness.stressLevel.rawValue >= 4 {
            adjustments.append("Consider light cardio or mobility instead")
        }

        return ReadinessCoachResponse(
            headline: "Easy Does It",
            message: "Your body is signaling it needs a break. If you train, keep it light and short. A movement session is better than a hard grind today.",
            icon: "heart.circle.fill",
            colorName: "orange",
            trainingAdvice: .shortenSession,
            adjustments: adjustments
        )
    }

    private func veryLowReadinessResponse(readiness: DailyReadiness) -> ReadinessCoachResponse {
        return ReadinessCoachResponse(
            headline: "Rest & Recover",
            message: "Multiple signals suggest your body needs recovery. Take today off or do light stretching. You'll come back stronger tomorrow.",
            icon: "bed.double.fill",
            colorName: "red",
            trainingAdvice: .restDay,
            adjustments: [
                "Skip today's workout",
                "Light walk or stretching only",
                "Prioritize sleep and nutrition",
                "Check in again tomorrow"
            ]
        )
    }

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
