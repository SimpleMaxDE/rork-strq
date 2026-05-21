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
        let noteFragment = readiness.painNote.isEmpty ? "" : L10n.format(" bei %@", readiness.painNote.lowercased())
        let message = hasWorkout
            ? L10n.format("Du hast eine Einschränkung%@ markiert. Einheit behalten, aber riskante Varianten tauschen, Gewicht reduzieren und Sätze früher beenden, wenn die Technik kippt.", noteFragment)
            : L10n.format("Du hast eine Einschränkung%@ markiert. Heute ruhiger planen: Mobility, leichte Bewegung und Schlaf priorisieren.", noteFragment)

        return ReadinessCoachResponse(
            headline: hasWorkout ? L10n.tr("Schonend trainieren") : L10n.tr("Heute schützen"),
            message: message,
            icon: "shield.checkered",
            colorName: "orange",
            trainingAdvice: hasWorkout ? .useSaferVariations : .restDay,
            adjustments: hasWorkout
                ? [
                    L10n.tr("Gelenkfreundliche Varianten wählen"),
                    L10n.tr("Gewicht bei betroffenen Übungen um ca. 15% senken"),
                    L10n.tr("Satz beenden, sobald die Technik kippt")
                ]
                : [
                    L10n.tr("Nur Mobility und leichte Bewegung"),
                    L10n.tr("Schlaf und Protein priorisieren"),
                    L10n.tr("Morgen vor dem Training neu prüfen")
                ]
        )
    }

    // MARK: Peak

    private func highReadinessResponse(readiness: DailyReadiness, phase: TrainingPhase, hasWorkout: Bool) -> ReadinessCoachResponse {
        if !hasWorkout {
            return ReadinessCoachResponse(
                headline: L10n.tr("Erholung nutzen"),
                message: L10n.tr("Readiness wirkt hoch, aber heute ist keine Einheit geplant. Aktiv und leicht bleiben, damit die nächste Einheit sauber sitzt."),
                icon: "bolt.fill",
                colorName: "mint",
                trainingAdvice: .trainAsPlanned,
                adjustments: [
                    L10n.tr("Spaziergang, Mobility oder leichte Technikarbeit"),
                    L10n.tr("Protein- und Schlafziel treffen"),
                    L10n.tr("Lifts für morgen kurz vorbereiten")
                ]
            )
        }

        let phaseNote = phase == .push ? " " + L10n.tr("Push-Phase: Progression vorsichtig prüfen.") : ""
        return ReadinessCoachResponse(
            headline: L10n.tr("Grünes Licht"),
            message: L10n.format("Schlaf, Energie und Erholung wirken gut.%@ Top-Set sauber ausführen und bei den Hauptlifts nur verdiente Steigerungen nehmen.", phaseNote),
            icon: "bolt.fill",
            colorName: "mint",
            trainingAdvice: readiness.motivation.rawValue >= 4 ? .pushHard : .trainAsPlanned,
            adjustments: [
                L10n.tr("Gründlich aufwärmen"),
                L10n.tr("Hauptlift prüfen: +1 Wdh. oder +2,5 kg"),
                L10n.tr("Accessory-Qualität vor Tonnage")
            ]
        )
    }

    // MARK: Good

    private func goodReadinessResponse(readiness: DailyReadiness, hasWorkout: Bool) -> ReadinessCoachResponse {
        if !hasWorkout {
            return ReadinessCoachResponse(
                headline: L10n.tr("Solide Basis"),
                message: L10n.tr("Erholung wirkt stabil und heute ist keine Einheit geplant. Inputs loggen, damit STRQ die nächsten Workouts sauber einordnet."),
                icon: "checkmark.circle.fill",
                colorName: "green",
                trainingAdvice: .trainAsPlanned,
                adjustments: [
                    L10n.tr("Gewicht und Schlaf loggen"),
                    L10n.tr("Schritte locker halten"),
                    L10n.tr("Ernährung im Ziel halten")
                ]
            )
        }

        return ReadinessCoachResponse(
            headline: L10n.tr("Plan ausführen"),
            message: L10n.tr("Readiness wirkt gut. Heutiges Workout sauber treffen: Ziel-Wiederholungen, Ziel-RPE, keine Extras erzwingen."),
            icon: "checkmark.circle.fill",
            colorName: "green",
            trainingAdvice: .trainAsPlanned,
            adjustments: [
                L10n.tr("Ziel-Wdh. bei Ziel-RPE treffen"),
                L10n.tr("Sauberes Tempo, volle ROM"),
                L10n.tr("Jeden Satz ehrlich loggen")
            ]
        )
    }

    // MARK: Moderate

    private func moderateReadinessResponse(readiness: DailyReadiness, hasWorkout: Bool) -> ReadinessCoachResponse {
        if !hasWorkout {
            return ReadinessCoachResponse(
                headline: L10n.tr("Erholung stapeln"),
                message: L10n.tr("Du wirkst nicht ganz frisch und heute ist keine Einheit geplant. Passt: Schlaf, Essen und leichte Bewegung priorisieren."),
                icon: "arrow.down.circle.fill",
                colorName: "yellow",
                trainingAdvice: .restDay,
                adjustments: [
                    L10n.tr("20-30 Min. Spaziergang oder Mobility"),
                    L10n.tr("Proteinziel treffen"),
                    L10n.tr("Heute 7+ Std. Schlaf anpeilen")
                ]
            )
        }

        var adjustments = [L10n.tr("Warm-up-Sätze ernst nehmen")]
        if readiness.soreness.rawValue >= 2 {
            adjustments.append(L10n.tr("Letzten Accessory-Satz bei müden Muskeln streichen"))
        }
        if readiness.energyLevel.rawValue <= 2 {
            adjustments.append(L10n.tr("Einheit auf ca. 45 Min. deckeln"))
        }
        adjustments.append(L10n.tr("Gewicht halten, 1 Wdh. im Tank lassen"))

        return ReadinessCoachResponse(
            headline: L10n.tr("Trainieren, aber ruhiger"),
            message: L10n.tr("Erholung wirkt gemischt. Heute keinen PR jagen: Hauptlifts nach Plan, Zubehör gekürzt. Qualität vor Tonnage."),
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
                headline: L10n.tr("Ruhiger Tag"),
                message: L10n.tr("Erholung wirkt niedrig. Heute Schlaf, Essen und lockere Bewegung priorisieren."),
                icon: "bed.double.fill",
                colorName: "orange",
                trainingAdvice: .restDay,
                adjustments: [
                    L10n.tr("Heute kein hartes Training"),
                    L10n.tr("Wenn möglich: mehr Schlaf"),
                    L10n.tr("Protein und Wasser zuerst"),
                    L10n.tr("Morgen neu prüfen")
                ]
            )
        }

        var adjustments = [
            L10n.tr("Arbeitslast um ca. 15-20% senken"),
            L10n.tr("1-2 Accessory-Übungen streichen"),
            L10n.tr("Einheit unter 40 Min. halten")
        ]
        if readiness.stressLevel.rawValue >= 4 {
            adjustments.append(L10n.tr("Wenn es weiter falsch wirkt: auf Mobility wechseln"))
        }

        return ReadinessCoachResponse(
            headline: L10n.tr("Bewegung, kein Grind"),
            message: L10n.tr("Readiness ist niedrig. Eine kurze, leichtere Einheit ist okay, aber nicht durch Schmerz oder Technikverlust drücken. Wiederholungsqualität zählt."),
            icon: "heart.circle.fill",
            colorName: "orange",
            trainingAdvice: .shortenSession,
            adjustments: adjustments
        )
    }

    // MARK: Very low

    private func veryLowReadinessResponse(readiness: DailyReadiness, hasWorkout: Bool) -> ReadinessCoachResponse {
        return ReadinessCoachResponse(
            headline: hasWorkout ? L10n.tr("Heute aussetzen") : L10n.tr("Erholen und neu prüfen"),
            message: hasWorkout
                ? L10n.tr("Mehrere Werte stehen niedrig. Einheit verschieben und die nächste Einheit leichter angehen.")
                : L10n.tr("Mehrere Werte stehen niedrig. Heute Erholung priorisieren und morgen neu prüfen."),
            icon: "bed.double.fill",
            colorName: "red",
            trainingAdvice: .restDay,
            adjustments: [
                L10n.tr("Heute kein Lifting"),
                L10n.tr("Leichter Spaziergang, Stretching, Tageslicht"),
                L10n.tr("Gut essen, früh schlafen"),
                L10n.tr("Morgen früh neu prüfen")
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
                    headline: L10n.tr("Bereit fürs Training"),
                    detail: L10n.tr("Readiness ist hoch und die heutige Einheit wartet. Sauber ausführen."),
                    icon: "bolt.heart.fill",
                    colorName: "green"
                )
            } else if score < 50 {
                return DailyCoachMessage(
                    headline: L10n.tr("Heute Erholung zuerst"),
                    detail: L10n.tr("Erholung wirkt niedrig. Leichte Bewegung oder ein ruhiger Tag ist sinnvoll."),
                    icon: "heart.circle.fill",
                    colorName: "orange"
                )
            }
        }

        if weeklySessionsCompleted >= weeklySessionsPlanned && weeklySessionsPlanned > 0 {
            let overflow = weeklyOverflow(completed: weeklySessionsCompleted, planned: weeklySessionsPlanned)
            return DailyCoachMessage(
                headline: L10n.tr("Wochenziel erreicht"),
                detail: overflow > 0
                    ? L10n.format("Wochenziel erreicht, +%d zusätzlich protokolliert. Erholung ehrlich halten, bevor du mehr machst.", overflow)
                    : L10n.tr("Alle geplanten Einheiten sind erledigt. Rest der Woche ruhig einordnen."),
                icon: "trophy.fill",
                colorName: "yellow"
            )
        }

        let remaining = weeklySessionsPlanned - weeklySessionsCompleted
        if remaining == 1 && hasWorkoutToday {
            return DailyCoachMessage(
                headline: L10n.tr("Noch eine Einheit diese Woche"),
                detail: L10n.tr("Sauber abschließen, dann ist das Wochenziel erfüllt."),
                icon: "flag.fill",
                colorName: "orange"
            )
        }

        if streak >= 7 {
            return DailyCoachMessage(
                headline: L10n.tr("Momentum baut sich auf"),
                detail: L10n.format("%d-Tage-Serie. Konstanz bleibt der stärkste Hebel.", streak),
                icon: "flame.fill",
                colorName: "orange"
            )
        }

        if hasWorkoutToday {
            return DailyCoachMessage(
                headline: L10n.tr("Trainingstag"),
                detail: L10n.tr("Die heutige Einheit ist bereit. Gut aufwärmen und Qualität priorisieren."),
                icon: "figure.strengthtraining.traditional",
                colorName: "blue"
            )
        }

        return DailyCoachMessage(
            headline: L10n.tr("Aktiver Erholungstag"),
            detail: L10n.tr("Keine Einheit geplant. Leichte Bewegung, Stretching oder komplette Ruhe - du entscheidest."),
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
            return L10n.format("Starke Disziplin. %d Tage in Folge.", currentStreak)
        } else if currentStreak >= 7 {
            return L10n.tr("Starkes Momentum. Serie halten.")
        } else if currentStreak >= 3 {
            return L10n.tr("Konstanz baut sich auf. Dranbleiben.")
        } else if currentStreak > 0 {
            return L10n.tr("Guter Start. Jede Einheit zählt.")
        } else {
            return L10n.tr("Heute neu starten. Eine Einheit nach der anderen.")
        }
    }

    var paceMessage: String {
        switch weeklyPace {
        case .ahead:
            if weeklySessionsPlanned > 0 && weeklySessionsCompleted > weeklySessionsPlanned {
                return L10n.format("Ziel erreicht · +%d zusätzlich", weeklySessionsCompleted - weeklySessionsPlanned)
            }
            return L10n.tr("Diese Woche vor dem Plan")
        case .onTrack:
            if weeklySessionsPlanned > 0 && weeklySessionsCompleted == weeklySessionsPlanned {
                return L10n.tr("Wochenziel erreicht")
            }
            return L10n.tr("Auf Kurs fürs Wochenziel")
        case .behind: return L10n.tr("Diese Woche hinter dem Plan")
        case .missed: return L10n.tr("Diese Woche noch keine Einheit")
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
