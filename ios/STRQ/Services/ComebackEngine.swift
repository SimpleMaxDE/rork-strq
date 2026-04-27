import Foundation

/// Tier of lapse — how far out of rhythm the user currently is.
/// Calm, adult framing — never punitive.
nonisolated enum LapseTier: String, Sendable, Codable, Comparable {
    /// Fully in rhythm. Within expected cadence, no drift.
    case inRhythm
    /// Short drift — a single planned session slipped. One gap day past expected cadence.
    case shortDrift
    /// Multi-day pause — 3–6 days without training or check-in.
    case pause
    /// Extended break — 7–13 days without signal. Soft re-entry required.
    case extendedBreak
    /// Long absence — 14+ days. Rebuild mode.
    case longAbsence

    static func < (lhs: LapseTier, rhs: LapseTier) -> Bool {
        lhs.order < rhs.order
    }

    private var order: Int {
        switch self {
        case .inRhythm: return 0
        case .shortDrift: return 1
        case .pause: return 2
        case .extendedBreak: return 3
        case .longAbsence: return 4
        }
    }

    /// True when the user is out of rhythm enough to warrant comeback guidance.
    var needsComeback: Bool {
        self >= .pause
    }

    var eyebrow: String {
        switch self {
        case .inRhythm: return "IN RHYTHM"
        case .shortDrift: return "LIGHT DRIFT"
        case .pause: return "SHORT PAUSE"
        case .extendedBreak: return "COMING BACK"
        case .longAbsence: return "REBUILD MODE"
        }
    }
}

/// Concrete coach-grade comeback guidance for the user's current lapse state.
nonisolated struct ComebackGuidance: Sendable {
    enum Stance: String, Sendable {
        /// Resume as planned — minor drift, no load changes.
        case resume
        /// Soften re-entry — lighter first session back.
        case ease
        /// Full ramp — structured lighter session to rebuild.
        case ramp
        /// Rebuild — treat as a fresh week, conservative loads.
        case rebuild
    }

    let tier: LapseTier
    let daysSinceLastActivity: Int
    let daysSinceLastWorkout: Int
    let stance: Stance
    let headline: String
    let detail: String
    let steps: [String]
    let icon: String
    let colorName: String
    /// Whether the suggested re-entry path is a lighter session applied to the next scheduled day.
    let offersLighterSession: Bool
}

/// Lightweight projection of retention signals so the engine can learn over
/// time without needing to re-derive everything from the full VM each call.
nonisolated struct RetentionSignals: Sendable {
    let tier: LapseTier
    let daysSinceLastActivity: Int
    let daysSinceLastWorkout: Int
    let plannedGapDays: Int
    let streakBeforeLapse: Int
    let hasActiveWorkout: Bool
}

nonisolated struct ComebackEngine: Sendable {

    /// Derive the current lapse tier from cadence signals.
    /// `lastWorkoutDate` is the most recent completed session. `lastReadinessDate`
    /// is the most recent check-in. `plannedCadenceDays` is the user's typical
    /// gap between sessions based on `daysPerWeek` — short-drift fires one gap
    /// day beyond that, not at the first rest day.
    func evaluate(
        now: Date = Date(),
        lastWorkoutDate: Date?,
        lastReadinessDate: Date?,
        hasActiveWorkout: Bool,
        daysPerWeek: Int,
        hasCompletedOnboarding: Bool,
        totalCompletedWorkouts: Int
    ) -> RetentionSignals {
        // A user with no completed workouts is in activation, not comeback.
        guard hasCompletedOnboarding, totalCompletedWorkouts > 0 else {
            return RetentionSignals(
                tier: .inRhythm,
                daysSinceLastActivity: 0,
                daysSinceLastWorkout: 0,
                plannedGapDays: plannedCadence(daysPerWeek: daysPerWeek),
                streakBeforeLapse: 0,
                hasActiveWorkout: hasActiveWorkout
            )
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        let daysSinceWorkout: Int = {
            guard let d = lastWorkoutDate else { return 99 }
            return max(0, calendar.dateComponents([.day], from: calendar.startOfDay(for: d), to: today).day ?? 0)
        }()

        let daysSinceActivity: Int = {
            let candidates: [Date] = [lastWorkoutDate, lastReadinessDate].compactMap { $0 }
            guard let latest = candidates.max() else { return 99 }
            return max(0, calendar.dateComponents([.day], from: calendar.startOfDay(for: latest), to: today).day ?? 0)
        }()

        let planned = plannedCadence(daysPerWeek: daysPerWeek)

        let tier: LapseTier = {
            if hasActiveWorkout { return .inRhythm }
            if daysSinceWorkout >= 14 { return .longAbsence }
            if daysSinceWorkout >= 7 { return .extendedBreak }
            if daysSinceWorkout >= 3 { return .pause }
            // Light drift fires one day past the expected cadence, not on rest days.
            if daysSinceWorkout > planned { return .shortDrift }
            return .inRhythm
        }()

        return RetentionSignals(
            tier: tier,
            daysSinceLastActivity: daysSinceActivity,
            daysSinceLastWorkout: daysSinceWorkout,
            plannedGapDays: planned,
            streakBeforeLapse: 0,
            hasActiveWorkout: hasActiveWorkout
        )
    }

    /// Build full comeback guidance from retention signals. Returns nil when
    /// the user is in rhythm — no card should be shown.
    func guidance(
        signals: RetentionSignals,
        hasWorkoutToday: Bool,
        hasNextScheduledWorkout: Bool
    ) -> ComebackGuidance? {
        guard signals.tier.needsComeback else { return nil }

        let days = signals.daysSinceLastWorkout
        let tier = signals.tier

        switch tier {
        case .inRhythm, .shortDrift:
            return nil

        case .pause:
            let detail: String
            if hasWorkoutToday {
                detail = "You missed a couple of days. Today's workout is still the right move — run it as planned and let the rhythm rebuild itself."
            } else if hasNextScheduledWorkout {
                detail = "It's been \(days) days. No reset needed — your next scheduled workout picks the plan right back up."
            } else {
                detail = "It's been \(days) days. A short session or a check-in tonight is enough to keep the plan honest."
            }
            return ComebackGuidance(
                tier: tier,
                daysSinceLastActivity: signals.daysSinceLastActivity,
                daysSinceLastWorkout: days,
                stance: .resume,
                headline: hasWorkoutToday ? "Pick up where you left off" : "Back on the plan",
                detail: detail,
                steps: [
                    "Run the next session as written",
                    "Log a quick check-in tonight",
                    "No load changes needed"
                ],
                icon: "arrow.uturn.right.circle.fill",
                colorName: "blue",
                offersLighterSession: false
            )

        case .extendedBreak:
            return ComebackGuidance(
                tier: tier,
                daysSinceLastActivity: signals.daysSinceLastActivity,
                daysSinceLastWorkout: days,
                stance: .ease,
                headline: "Ease back in",
                detail: "It's been \(days) days. Your first session back should feel lighter on purpose — that's how comebacks hold. STRQ will ease the next session and rebuild from there.",
                steps: [
                    "Keep working loads ~10–15% under last time",
                    "Trim one accessory — quality over tonnage",
                    "Check in first so the plan can tune"
                ],
                icon: "leaf.arrow.triangle.circlepath",
                colorName: "orange",
                offersLighterSession: true
            )

        case .longAbsence:
            return ComebackGuidance(
                tier: tier,
                daysSinceLastActivity: signals.daysSinceLastActivity,
                daysSinceLastWorkout: days,
                stance: .rebuild,
                headline: "Rebuild, don't retest",
                detail: "It's been \(days)+ days. Treat this week like a rebuild block — lighter sessions, full ROM, clean reps. Strength comes back fast when you don't chase it on day one.",
                steps: [
                    "Cut working load 15–20% for session one",
                    "Shorten session to 35–45 min",
                    "Protect the first two sessions before pushing"
                ],
                icon: "arrow.triangle.2.circlepath",
                colorName: "red",
                offersLighterSession: true
            )
        }
    }

    // MARK: - Helpers

    /// Typical rest-day budget between sessions. Drift only fires past this
    /// number — a user on 3 days/week should not see a comeback card after one
    /// scheduled rest day.
    private func plannedCadence(daysPerWeek: Int) -> Int {
        switch max(1, min(7, daysPerWeek)) {
        case 7: return 1
        case 6: return 1
        case 5: return 2
        case 4: return 2
        case 3: return 3
        case 2: return 4
        default: return 5
        }
    }
}
