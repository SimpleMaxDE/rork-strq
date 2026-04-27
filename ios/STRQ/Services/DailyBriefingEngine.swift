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
                .replacingOccurrences(of: L10n.tr("Let's "), with: "")
                .replacingOccurrences(of: L10n.tr("let's "), with: "")
        case .supportive:
            // Only prepend a soft lead when it reads naturally.
            if p.kind == .trainToday || p.kind == .startFirstSession {
                detail = L10n.tr("You’ve got this. ") + detail
            }
        case .balanced:
            break
        }

        // Emphasis-tuned framing on the primary title for rest-day guidance.
        switch input.emphasis {
        case .recovery where p.kind == .recoveryDay:
            title = L10n.tr("Recover with intent")
        case .physique where p.kind == .logBodyWeight:
            title = L10n.tr("Weigh-in keeps physique honest")
        case .consistency where p.kind == .recoveryDay && input.streak >= 3:
            title = L10n.tr("Protect the streak")
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
                eyebrow: L10n.tr("IN PROGRESS"),
                title: L10n.tr("Resume your workout"),
                detail: L10n.tr("Pick up where you left off. Your logged sets are saved."),
                icon: "play.circle.fill",
                colorName: "blue",
                ctaTitle: L10n.tr("Resume")
            )
        }

        if !i.hasPlan || !i.hasCompletedOnboarding {
            return .init(
                kind: .startFirstSession,
                eyebrow: L10n.tr("LET'S BEGIN"),
                title: L10n.tr("Start your first workout"),
                detail: L10n.tr("STRQ calibrates from what you actually lift. Log workout one to unlock real coaching."),
                icon: "sparkles",
                colorName: "green",
                ctaTitle: L10n.tr("Begin")
            )
        }

        // Training day path
        if let name = i.todaysWorkoutName {
            if i.painOrRestriction {
                return .init(
                    kind: .recoverToday,
                    eyebrow: L10n.tr("PROTECT YOURSELF"),
                    title: L10n.tr("Recover today"),
                    detail: L10n.tr("You flagged pain or restriction. Skip heavy work and focus on movement quality."),
                    icon: "shield.checkered",
                    colorName: "orange",
                    ctaTitle: L10n.tr("Adjust today")
                )
            }
            if i.hasCheckedInToday && i.effectiveRecoveryScore < 45 {
                return .init(
                    kind: .recoverToday,
                    eyebrow: L10n.tr("RECOVERY FIRST"),
                    title: L10n.tr("Keep it light today"),
                    detail: L10n.tr("Readiness is low. A shorter, lighter workout beats a grind you can't absorb."),
                    icon: "heart.circle.fill",
                    colorName: "orange",
                    ctaTitle: L10n.tr("Open lighter workout")
                )
            }
            if !i.hasCheckedInToday && i.hour < 12 {
                return .init(
                    kind: .checkInBeforeTraining,
                    eyebrow: L10n.tr("TRAINING DAY"),
                    title: L10n.tr("Check in, then train"),
                    detail: L10n.format("A 20-second readiness check lets STRQ tune %@ to where your body actually is.", name),
                    icon: "heart.text.clipboard",
                    colorName: "blue",
                    ctaTitle: L10n.tr("Check in")
                )
            }
            let focusBit = i.todaysFocus.map { L10n.format(" — %@", $0.lowercased()) } ?? ""
            return .init(
                kind: .trainToday,
                eyebrow: L10n.tr("TRAINING DAY"),
                title: L10n.format("Train %@", name),
                detail: L10n.format("Today's workout is ready%@. Warm up well, lead with the anchor lifts.", focusBit),
                icon: "bolt.fill",
                colorName: "green",
                ctaTitle: L10n.tr("Start workout")
            )
        }

        // Rest day path
        if i.missingWeightDays >= 4 {
            return .init(
                kind: .logBodyWeight,
                eyebrow: L10n.tr("RECOVERY DAY"),
                title: L10n.tr("Log your body weight"),
                detail: L10n.format("It's been %d days. A quick log keeps your trend line honest.", i.missingWeightDays),
                icon: "scalemass.fill",
                colorName: "blue",
                ctaTitle: L10n.tr("Log weight")
            )
        }

        if let next = i.nextWorkoutName, let days = i.nextWorkoutInDays, days <= 2 {
            let when = days == 0 ? L10n.tr("later today") : days == 1 ? L10n.tr("tomorrow") : L10n.format("in %d days", days)
            return .init(
                kind: .prepNextSession,
                eyebrow: L10n.tr("RECOVERY DAY"),
                title: L10n.format("Prep for %@", next),
                detail: L10n.format("Next workout is %@. Sleep, protein, and a short walk set you up to push.", when),
                icon: "calendar.badge.clock",
                colorName: "blue",
                ctaTitle: L10n.tr("Preview workout")
            )
        }

        return .init(
            kind: .recoveryDay,
            eyebrow: L10n.tr("RECOVERY DAY"),
            title: L10n.tr("Let recovery do its job"),
            detail: L10n.tr("No workout planned. Light movement, protein, and sleep will compound everything you've already banked."),
            icon: "leaf.fill",
            colorName: "green",
            ctaTitle: nil != i.lastCompletedSessionName ? L10n.tr("Review last workout") : L10n.tr("View plan")
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
            return DailyBriefing.Momentum(title: L10n.format("%d-day streak holding", i.streak), icon: "flame.fill")
        }
        if i.weeklyPlanned > 0, i.weeklyCompleted >= i.weeklyPlanned {
            return DailyBriefing.Momentum(title: L10n.format("Weekly target hit — %d/%d", i.weeklyCompleted, i.weeklyPlanned), icon: "checkmark.seal.fill")
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
            lines.append(("moon.zzz.fill", L10n.tr("Log last night's sleep"), L10n.tr("Sleep drives recovery. A quick log sharpens STRQ's next call.")))
        }
        if i.effectiveRecoveryScore < 60 {
            lines.append(("heart.fill", L10n.tr("Protect recovery"), L10n.tr("Stay hydrated, eat protein, keep movement light today.")))
        } else if let days = i.nextWorkoutInDays, days <= 1 {
            lines.append(("bolt.fill", L10n.tr("Prime for the next push"), L10n.tr("Good sleep and a full protein day today = a stronger workout.")))
        }
        guard let first = lines.first else { return nil }
        return DailyBriefing.RestPrep(title: first.1, detail: first.2, icon: first.0)
    }
}
