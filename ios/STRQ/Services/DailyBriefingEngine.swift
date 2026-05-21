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

    private struct WeeklyTargetDisplay {
        let primary: String
        let inlinePrimary: String
    }

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

    private func weeklyTargetDisplay(completed rawCompleted: Int, target rawTarget: Int) -> WeeklyTargetDisplay {
        let completed = max(0, rawCompleted)
        guard rawTarget > 0 else {
            return WeeklyTargetDisplay(primary: "\(completed)", inlinePrimary: "\(completed)")
        }

        let target = rawTarget
        let shown = min(completed, target)
        let primary = "\(shown)/\(target)"

        guard completed > target else {
            return WeeklyTargetDisplay(primary: primary, inlinePrimary: primary)
        }

        return WeeklyTargetDisplay(
            primary: primary,
            inlinePrimary: L10n.format("%@ · +%d zusätzlich", primary, completed - target)
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
                .replacingOccurrences(of: L10n.tr("Lass uns "), with: "")
                .replacingOccurrences(of: L10n.tr("lass uns "), with: "")
        case .supportive:
            // Only prepend a soft lead when it reads naturally.
            if p.kind == .trainToday || p.kind == .startFirstSession {
                detail = L10n.tr("Du hast das im Griff. ") + detail
            }
        case .balanced:
            break
        }

        // Emphasis-tuned framing on the primary title for rest-day guidance.
        switch input.emphasis {
        case .recovery where p.kind == .recoveryDay:
            title = L10n.tr("Erholung bewusst planen")
        case .physique where p.kind == .logBodyWeight:
            title = L10n.tr("Wiegen hält den Trend sauber")
        case .consistency where p.kind == .recoveryDay && input.streak >= 3:
            title = L10n.tr("Serie ruhig halten")
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
                eyebrow: L10n.tr("AKTIV"),
                title: L10n.tr("Workout fortsetzen"),
                detail: L10n.tr("Mach dort weiter, wo du aufgehört hast. Deine geloggten Sätze sind gespeichert."),
                icon: "play.circle.fill",
                colorName: "blue",
                ctaTitle: L10n.tr("Fortsetzen")
            )
        }

        if !i.hasPlan || !i.hasCompletedOnboarding {
            return .init(
                kind: .startFirstSession,
                eyebrow: L10n.tr("START"),
                title: L10n.tr("Erstes Workout starten"),
                detail: L10n.tr("STRQ kalibriert sich über deine geloggten Sätze. Nach dem ersten Workout wird der Coach konkreter."),
                icon: "sparkles",
                colorName: "green",
                ctaTitle: L10n.tr("Beginnen")
            )
        }

        // Training day path
        if let name = i.todaysWorkoutName {
            if i.painOrRestriction {
                return .init(
                    kind: .recoverToday,
                    eyebrow: L10n.tr("RUHIGER PLANEN"),
                    title: L10n.tr("Heute schonen"),
                    detail: L10n.tr("Du hast Schmerz oder Einschränkung markiert. Schwere Sätze auslassen und Bewegungsqualität priorisieren."),
                    icon: "shield.checkered",
                    colorName: "orange",
                    ctaTitle: L10n.tr("Heute anpassen")
                )
            }
            if i.hasCheckedInToday && i.effectiveRecoveryScore < 45 {
                return .init(
                    kind: .recoverToday,
                    eyebrow: L10n.tr("ERHOLUNG ZUERST"),
                    title: L10n.tr("Heute leichter"),
                    detail: L10n.tr("Tagesform ist niedrig. Eine kürzere, leichtere Einheit passt besser als heute hart zu erzwingen."),
                    icon: "heart.circle.fill",
                    colorName: "orange",
                    ctaTitle: L10n.tr("Leichtere Einheit öffnen")
                )
            }
            if !i.hasCheckedInToday && i.hour < 12 {
                return .init(
                    kind: .checkInBeforeTraining,
                    eyebrow: L10n.tr("TRAININGSTAG"),
                    title: L10n.tr("Check-in, dann Training"),
                    detail: L10n.format("Ein kurzer Readiness-Check hilft STRQ, %@ an die heutige Lage anzupassen.", name),
                    icon: "heart.text.clipboard",
                    colorName: "blue",
                    ctaTitle: L10n.tr("Check-in")
                )
            }
            let focusBit = i.todaysFocus.map { L10n.format(" — %@", $0.lowercased()) } ?? ""
            return .init(
                kind: .trainToday,
                eyebrow: L10n.tr("TRAININGSTAG"),
                title: L10n.format("%@ trainieren", name),
                detail: L10n.format("Die heutige Einheit ist bereit%@. Gut aufwärmen und mit den Hauptlifts starten.", focusBit),
                icon: "bolt.fill",
                colorName: "green",
                ctaTitle: L10n.tr("Workout starten")
            )
        }

        // Rest day path
        if i.missingWeightDays >= 4 {
            return .init(
                kind: .logBodyWeight,
                eyebrow: L10n.tr("ERHOLUNGSTAG"),
                title: L10n.tr("Körpergewicht loggen"),
                detail: L10n.format("Seit %d Tagen fehlt ein Log. Ein kurzer Eintrag hält die Trendlinie sauber.", i.missingWeightDays),
                icon: "scalemass.fill",
                colorName: "blue",
                ctaTitle: L10n.tr("Gewicht loggen")
            )
        }

        if let next = i.nextWorkoutName, let days = i.nextWorkoutInDays, days <= 2 {
            let when = days == 0 ? L10n.tr("später heute") : days == 1 ? L10n.tr("morgen") : L10n.format("in %d Tagen", days)
            return .init(
                kind: .prepNextSession,
                eyebrow: L10n.tr("ERHOLUNGSTAG"),
                title: L10n.format("%@ vorbereiten", next),
                detail: L10n.format("Nächste Einheit: %@. Schlaf, Protein und ein kurzer Spaziergang machen das Workout planbarer.", when),
                icon: "calendar.badge.clock",
                colorName: "blue",
                ctaTitle: L10n.tr("Workout ansehen")
            )
        }

        return .init(
            kind: .recoveryDay,
            eyebrow: L10n.tr("ERHOLUNGSTAG"),
            title: L10n.tr("Erholung arbeiten lassen"),
                detail: L10n.tr("Keine Einheit geplant. Leichte Bewegung, Protein und Schlaf stützen das nächste Workout."),
            icon: "leaf.fill",
            colorName: "green",
            ctaTitle: nil != i.lastCompletedSessionName ? L10n.tr("Letztes Workout prüfen") : L10n.tr("Plan ansehen")
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
            return DailyBriefing.Momentum(title: L10n.format("%d-Tage-Serie hält", i.streak), icon: "flame.fill")
        }
        if i.weeklyPlanned > 0, i.weeklyCompleted >= i.weeklyPlanned {
            let display = weeklyTargetDisplay(completed: i.weeklyCompleted, target: i.weeklyPlanned)
            return DailyBriefing.Momentum(title: L10n.format("Wochenziel erreicht - %@", display.inlinePrimary), icon: "checkmark.seal.fill")
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
            eyebrow: localizedSinceLastEyebrow(eyebrow),
            summary: localizedSinceLastSummary(summary),
            sessionName: name,
            hoursAgo: hours
        )
    }

    private func localizedSinceLastEyebrow(_ raw: String) -> String {
        let normalized = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if normalized.contains("frequency improved") { return L10n.tr("Rhythmus verbessert") }
        if normalized.contains("workout logged") || normalized.contains("workout geloggt") { return L10n.tr("Workout geloggt") }
        if normalized.contains("first workout") { return L10n.tr("Erstes Workout") }
        if normalized.contains("volume up") { return L10n.tr("Volumen höher") }
        if normalized.contains("volume down") { return L10n.tr("Volumen niedriger") }
        if normalized.contains("personal record") || normalized.contains("persönlicher rekord") || normalized.contains("pr") { return L10n.tr("Neuer PR") }
        if normalized.contains("baseline") { return L10n.tr("Ausgangswert") }
        return raw
            .replacingOccurrences(of: "Frequency Improved", with: L10n.tr("Rhythmus verbessert"))
            .replacingOccurrences(of: "WORKOUT LOGGED", with: L10n.tr("Workout geloggt"))
            .replacingOccurrences(of: "Workout Logged", with: L10n.tr("Workout geloggt"))
    }

    private func localizedSinceLastSummary(_ raw: String) -> String {
        let normalized = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let liftName = prLiftName(from: raw) { return liftName }
        if normalized.contains("arbeit erledigt") { return L10n.tr("Plan erledigt.") }
        if normalized.contains("frequency improved") { return L10n.tr("Wochenrhythmus wirkt stabiler.") }
        if normalized.contains("workout logged") { return L10n.tr("Workout geloggt, Plan erledigt.") }
        if normalized.contains("baseline set") { return L10n.tr("Ausgangswert gesetzt.") }
        if normalized.contains("quality over load") { return L10n.tr("Leichterer Tag, Technik vor Gewicht.") }
        if normalized.contains("ready to push") { return L10n.tr("Technik sauber. Gewicht prüfen.") }
        return raw
            .replacingOccurrences(of: "Frequency Improved", with: L10n.tr("Rhythmus verbessert"))
            .replacingOccurrences(of: "Workout Logged", with: L10n.tr("Workout geloggt"))
            .replacingOccurrences(of: "workout logged", with: L10n.tr("Workout geloggt"))
            .replacingOccurrences(of: "baseline set", with: L10n.tr("Ausgangswert gesetzt"))
            .replacingOccurrences(of: "quality over load", with: L10n.tr("Technik vor Gewicht"))
    }

    private func prLiftName(from raw: String) -> String? {
        let prefixes = [
            "New PR on ",
            "Neuer PR " + "bei ",
            "Neuer PR · "
        ]
        for prefix in prefixes {
            if let range = raw.range(of: prefix, options: [.caseInsensitive]) {
                let liftName = raw[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
                if !liftName.isEmpty { return liftName }
            }
        }
        return nil
    }

    // MARK: - Rest prep

    private func resolveRestPrep(_ i: DailyBriefingInput, primaryKind: DailyBriefing.PrimaryKind) -> DailyBriefing.RestPrep? {
        guard primaryKind == .recoveryDay || primaryKind == .prepNextSession || primaryKind == .logBodyWeight else { return nil }
        var lines: [(String, String, String)] = []
        if i.missingSleepDays >= 2 {
            lines.append(("moon.zzz.fill", L10n.tr("Schlaf von letzter Nacht loggen"), L10n.tr("Ein kurzer Schlaf-Log macht das nächste Workout sauberer.")))
        }
        if i.effectiveRecoveryScore < 60 {
            lines.append(("heart.fill", L10n.tr("Erholung schützen"), L10n.tr("Trinken, Protein treffen und Bewegung heute leicht halten.")))
        } else if let days = i.nextWorkoutInDays, days <= 1 {
            lines.append(("bolt.fill", L10n.tr("Nächste Einheit vorbereiten"), L10n.tr("Guter Schlaf und Protein heute machen die nächste Einheit planbarer.")))
        }
        guard let first = lines.first else { return nil }
        return DailyBriefing.RestPrep(title: first.1, detail: first.2, icon: first.0)
    }
}
