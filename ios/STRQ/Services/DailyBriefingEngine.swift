import Foundation

nonisolated struct DailyBriefing: Sendable {

    enum PrimaryKind: Sendable {
        case startFirstSession
        case resumeWorkout
        case checkInBeforeTraining
        case trainToday
        case recoverToday
        case recoveryDay
        case prepNextSession
        case logCompletion
        case logBodyWeight
    }

    nonisolated struct Primary: Sendable {
        let kind: PrimaryKind
        let eyebrow: String
        let title: String
        let detail: String
        let icon: String
        let colorName: String
        let ctaTitle: String
    }

    nonisolated struct Watch: Sendable {
        let title: String
        let detail: String
        let icon: String
        let colorName: String
    }

    nonisolated struct Momentum: Sendable {
        let title: String
        let icon: String
    }

    nonisolated struct SinceLast: Sendable {
        let eyebrow: String
        let summary: String
        let sessionName: String
        let hoursAgo: Int
    }

    nonisolated struct RestPrep: Sendable {
        let title: String
        let detail: String
        let icon: String
    }

    let primary: Primary
    let watch: Watch?
    let momentum: Momentum?
    let sinceLast: SinceLast?
    let restPrep: RestPrep?
    let moreSignalsCount: Int
}

nonisolated enum BriefingTone: String, Sendable {
    case supportive
    case balanced
    case direct
}

nonisolated enum BriefingEmphasis: String, Sendable {
    case performance
    case physique
    case recovery
    case consistency
    case simplicity
}

nonisolated struct DailyBriefingInput: Sendable {
    let hasPlan: Bool
    let hasCompletedOnboarding: Bool
    let hasActiveWorkout: Bool
    let todaysWorkoutName: String?
    let todaysFocus: String?
    let nextWorkoutName: String?
    let nextWorkoutInDays: Int?
    let hasCheckedInToday: Bool
    let painOrRestriction: Bool
    let readinessScore: Int
    let effectiveRecoveryScore: Int
    let streak: Int
    let weeklyCompleted: Int
    let weeklyPlanned: Int
    let lastCompletedSessionName: String?
    let lastCompletedHoursAgo: Int?
    let lastSessionVerdictEyebrow: String?
    let lastSessionVerdictSummary: String?
    let topInsightTitle: String?
    let topInsightMessage: String?
    let topInsightIcon: String?
    let topInsightColor: String?
    let topMomentumTitle: String?
    let topMomentumIcon: String?
    let missingWeightDays: Int
    let missingSleepDays: Int
    let totalInsightsCount: Int
    let totalRecommendationsCount: Int
    let hour: Int
    let isEarlyStage: Bool
    let tone: BriefingTone
    let emphasis: BriefingEmphasis
}

nonisolated struct DailyBriefingEngine: Sendable {

    func build(_ input: DailyBriefingInput) -> DailyBriefing {
        let rawPrimary = resolvePrimary(input)
        let primary = applyToneAndEmphasis(rawPrimary, input: input)
        let watch = resolveWatch(input, primaryKind: primary.kind)
        let momentum = resolveMomentum(input)
        let sinceLast = resolveSinceLast(input)
        let restPrep = resolveRestPrep(input, primaryKind: primary.kind)
        let extra = max(0, input.totalInsightsCount + input.totalRecommendationsCount - (watch == nil ? 0 : 1))
        return DailyBriefing(
            primary: primary,
            watch: watch,
            momentum: momentum,
            sinceLast: sinceLast,
            restPrep: restPrep,
            moreSignalsCount: extra
        )
    }

    // MARK: - Tone / Emphasis

    private func applyToneAndEmphasis(_ p: DailyBriefing.Primary, input: DailyBriefingInput) -> DailyBriefing.Primary {
        var title = p.title
        var detail = p.detail

        switch input.tone {
        case .direct:
            // Strip softeners for a sharper read.
            detail = detail
                .replacingOccurrences(of: "Let's ", with: "")
                .replacingOccurrences(of: "let's ", with: "")
        case .supportive:
            // Only prepend a soft lead when it reads naturally.
            if p.kind == .trainToday || p.kind == .startFirstSession {
                detail = "You’ve got this. " + detail
            }
        case .balanced:
            break
        }

        // Emphasis-tuned framing on the primary title for rest-day guidance.
        switch input.emphasis {
        case .recovery where p.kind == .recoveryDay:
            title = "Recover with intent"
        case .physique where p.kind == .logBodyWeight:
            title = "Weigh-in keeps physique honest"
        case .consistency where p.kind == .recoveryDay && input.streak >= 3:
            title = "Protect the streak"
        case .simplicity:
            // Trim supporting detail to a single clear sentence.
            if let first = detail.split(separator: ".").first {
                detail = String(first).trimmingCharacters(in: .whitespaces) + "."
            }
        default:
            break
        }

        return DailyBriefing.Primary(
            kind: p.kind,
            eyebrow: p.eyebrow,
            title: title,
            detail: detail,
            icon: p.icon,
            colorName: p.colorName,
            ctaTitle: p.ctaTitle
        )
    }

    // MARK: - Primary

    private func resolvePrimary(_ i: DailyBriefingInput) -> DailyBriefing.Primary {
        if i.hasActiveWorkout {
            return .init(
                kind: .resumeWorkout,
                eyebrow: "IN PROGRESS",
                title: "Resume your workout",
                detail: "Pick up where you left off. Your logged sets are saved.",
                icon: "play.circle.fill",
                colorName: "blue",
                ctaTitle: "Resume"
            )
        }

        if !i.hasPlan || !i.hasCompletedOnboarding {
            return .init(
                kind: .startFirstSession,
                eyebrow: "LET'S BEGIN",
                title: "Start your first session",
                detail: "STRQ calibrates from what you actually lift. Log session one to unlock real coaching.",
                icon: "sparkles",
                colorName: "green",
                ctaTitle: "Begin"
            )
        }

        // Training day path
        if let name = i.todaysWorkoutName {
            if i.painOrRestriction {
                return .init(
                    kind: .recoverToday,
                    eyebrow: "PROTECT YOURSELF",
                    title: "Recover today",
                    detail: "You flagged pain or restriction. Skip heavy work and focus on movement quality.",
                    icon: "shield.checkered",
                    colorName: "orange",
                    ctaTitle: "Adjust today"
                )
            }
            if i.hasCheckedInToday && i.effectiveRecoveryScore < 45 {
                return .init(
                    kind: .recoverToday,
                    eyebrow: "RECOVERY FIRST",
                    title: "Keep it light today",
                    detail: "Readiness is low. A shorter, lighter session beats a grind you can't absorb.",
                    icon: "heart.circle.fill",
                    colorName: "orange",
                    ctaTitle: "Open lighter session"
                )
            }
            if !i.hasCheckedInToday && i.hour < 12 {
                return .init(
                    kind: .checkInBeforeTraining,
                    eyebrow: "TRAINING DAY",
                    title: "Check in, then train",
                    detail: "A 20-second readiness check lets STRQ tune \(name) to where your body actually is.",
                    icon: "heart.text.clipboard",
                    colorName: "blue",
                    ctaTitle: "Check in"
                )
            }
            let focusBit = i.todaysFocus.map { " — \($0.lowercased())" } ?? ""
            return .init(
                kind: .trainToday,
                eyebrow: "TRAINING DAY",
                title: "Train \(name)",
                detail: "Today's session is ready\(focusBit). Warm up well, lead with the anchor lifts.",
                icon: "bolt.fill",
                colorName: "green",
                ctaTitle: "Start session"
            )
        }

        // Rest day path
        if i.missingWeightDays >= 4 {
            return .init(
                kind: .logBodyWeight,
                eyebrow: "RECOVERY DAY",
                title: "Log your body weight",
                detail: "It's been \(i.missingWeightDays) days. A quick log keeps your trend line honest.",
                icon: "scalemass.fill",
                colorName: "blue",
                ctaTitle: "Log weight"
            )
        }

        if let next = i.nextWorkoutName, let days = i.nextWorkoutInDays, days <= 2 {
            let when = days == 0 ? "later today" : days == 1 ? "tomorrow" : "in \(days) days"
            return .init(
                kind: .prepNextSession,
                eyebrow: "RECOVERY DAY",
                title: "Prep for \(next)",
                detail: "Next session is \(when). Sleep, protein, and a short walk set you up to push.",
                icon: "calendar.badge.clock",
                colorName: "blue",
                ctaTitle: "Preview session"
            )
        }

        return .init(
            kind: .recoveryDay,
            eyebrow: "RECOVERY DAY",
            title: "Let recovery do its job",
            detail: "No session planned. Light movement, protein, and sleep will compound everything you've already banked.",
            icon: "leaf.fill",
            colorName: "green",
            ctaTitle: nil != i.lastCompletedSessionName ? "Review last session" : "View plan"
        )
    }

    // MARK: - Watch

    private func resolveWatch(_ i: DailyBriefingInput, primaryKind: DailyBriefing.PrimaryKind) -> DailyBriefing.Watch? {
        // Don't surface watch if primary already communicates a recovery/pain signal.
        if primaryKind == .recoverToday { return nil }
        guard let title = i.topInsightTitle, let message = i.topInsightMessage else { return nil }
        return DailyBriefing.Watch(
            title: title,
            detail: message,
            icon: i.topInsightIcon ?? "exclamationmark.circle.fill",
            colorName: i.topInsightColor ?? "orange"
        )
    }

    // MARK: - Momentum

    private func resolveMomentum(_ i: DailyBriefingInput) -> DailyBriefing.Momentum? {
        if let title = i.topMomentumTitle {
            return DailyBriefing.Momentum(title: title, icon: i.topMomentumIcon ?? "arrow.up.right.circle.fill")
        }
        if i.streak >= 3 {
            return DailyBriefing.Momentum(title: "\(i.streak)-day streak holding", icon: "flame.fill")
        }
        if i.weeklyPlanned > 0, i.weeklyCompleted >= i.weeklyPlanned {
            return DailyBriefing.Momentum(title: "Weekly target hit — \(i.weeklyCompleted)/\(i.weeklyPlanned)", icon: "checkmark.seal.fill")
        }
        return nil
    }

    // MARK: - Since Last

    private func resolveSinceLast(_ i: DailyBriefingInput) -> DailyBriefing.SinceLast? {
        guard let name = i.lastCompletedSessionName,
              let hours = i.lastCompletedHoursAgo,
              hours <= 36,
              let eyebrow = i.lastSessionVerdictEyebrow,
              let summary = i.lastSessionVerdictSummary else { return nil }
        return DailyBriefing.SinceLast(
            eyebrow: eyebrow,
            summary: summary,
            sessionName: name,
            hoursAgo: hours
        )
    }

    // MARK: - Rest prep

    private func resolveRestPrep(_ i: DailyBriefingInput, primaryKind: DailyBriefing.PrimaryKind) -> DailyBriefing.RestPrep? {
        guard primaryKind == .recoveryDay || primaryKind == .prepNextSession || primaryKind == .logBodyWeight else { return nil }
        var lines: [(String, String, String)] = []
        if i.missingSleepDays >= 2 {
            lines.append(("moon.zzz.fill", "Log last night's sleep", "Sleep drives recovery. A quick log sharpens STRQ's next call."))
        }
        if i.effectiveRecoveryScore < 60 {
            lines.append(("heart.fill", "Protect recovery", "Stay hydrated, eat protein, keep movement light today."))
        } else if let days = i.nextWorkoutInDays, days <= 1 {
            lines.append(("bolt.fill", "Prime for the next push", "Good sleep and a full protein day today = a stronger session."))
        }
        guard let first = lines.first else { return nil }
        return DailyBriefing.RestPrep(title: first.1, detail: first.2, icon: first.0)
    }
}
