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
                    label: "Volumen ausgleichen",
                    icon: "arrow.left.arrow.right",
                    explanation: "Verschiebe in der nächsten passenden Einheit etwas Volumen von sehr stark zu wenig belasteten Bereichen.",
                    whyItMatters: "Ausgeglicheneres Volumen macht die Woche nachvollziehbarer und hält die Belastung kontrollierter.",
                    previewText: "Nächste Einheit: 1 Satz weniger im hohen Bereich, 2 Sätze mehr im niedrigen Bereich"
                )
            ]
        case .progressionSuggestion:
            return [
                CoachAction(
                    type: .progressWeight,
                    label: "Gewicht leicht erhöhen",
                    icon: "arrow.up.right",
                    explanation: "Plane etwas mehr Gewicht, wenn die Wiederholungen sauber bleiben.",
                    whyItMatters: "Kleine, saubere Steigerungen sind besser verwertbar als erzwungene Sprünge.",
                    previewText: "Nächste Einheit: +2,5 kg prüfen, Wiederholungsziel beibehalten"
                )
            ]
        case .recoveryConcern:
            return [
                CoachAction(
                    type: .restDay,
                    label: "Heute ruhiger trainieren",
                    icon: "bed.double.fill",
                    explanation: "Ersetze die nächste harte Einheit durch Pause, Spaziergang oder leichte Mobility.",
                    whyItMatters: "Bei vielen harten Einheiten ist ein ruhiger Tag oft die bessere Wahl.",
                    previewText: "Morgen: Pause oder 20 Min. leichte Mobility"
                ),
                CoachAction(
                    type: .lighterSession,
                    label: "Leichter trainieren",
                    icon: "arrow.down.circle",
                    explanation: "Reduziere Arbeitsgewichte um 15-20% und halte Tempo und Technik sauber.",
                    whyItMatters: "Eine leichtere Einheit hält den Rhythmus, ohne noch mehr Druck zu machen.",
                    previewText: "Nächste Einheit: ca. 20% weniger Gewicht, Fokus auf Kontrolle"
                )
            ]
        case .exerciseSwap:
            return [
                CoachAction(
                    type: .swapExercise,
                    label: "Variation prüfen",
                    icon: "arrow.triangle.2.circlepath",
                    explanation: "Prüfe eine ähnliche Variation, wenn die aktuelle Übung nicht mehr sauber vorankommt.",
                    whyItMatters: "Eine Variation trifft den Muskel etwas anders, ohne das Trainingsziel zu wechseln.",
                    previewText: "Nächste Einheit: vorgeschlagene Variation prüfen"
                )
            ]
        case .splitSuggestion:
            return [
                CoachAction(
                    type: .regenerateWeek,
                    label: "Nächste Woche planen",
                    icon: "arrow.triangle.2.circlepath.circle.fill",
                    explanation: "Plane die kommende Woche näher an dem, was du tatsächlich geloggt hast.",
                    whyItMatters: "Ein Plan, der zu deinem echten Rhythmus passt, verteilt Volumen besser.",
                    previewText: "Ganze Woche: an echte Frequenz angepasst"
                ),
                CoachAction(
                    type: .increaseFrequency,
                    label: "Frequenz prüfen",
                    icon: "calendar.badge.plus",
                    explanation: "Prüfe, ob die Planfrequenz noch zu deinen Logs passt.",
                    whyItMatters: "Eine realistische Frequenz hält die Wochenvorgabe glaubwürdiger.",
                    previewText: "Planfrequenz aus Logs prüfen"
                )
            ]
        case .prCongrats:
            return [
                CoachAction(
                    type: .celebrate,
                    label: "Kurs halten",
                    icon: "trophy.fill",
                    explanation: "Die Richtung stimmt. Bestätige den Fortschritt in der nächsten Einheit sauber.",
                    whyItMatters: "Bestleistungen zählen mehr, wenn der nächste Schritt kontrolliert bleibt.",
                    previewText: "Aktuelle Struktur beibehalten"
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
                    label: "Nächste Woche planen",
                    icon: "arrow.triangle.2.circlepath.circle.fill",
                    explanation: "Plane die kommende Woche neu, damit Volumen und Übungsauswahl sauberer verteilt sind.",
                    whyItMatters: "Eine Wochenanpassung ist klarer als mehrere kleine Einzelkorrekturen.",
                    previewText: "Ganze Woche: Volumen und Übungen neu verteilt"
                ),
                CoachAction(
                    type: .addWork,
                    label: "Sätze ergänzen",
                    icon: "plus.circle.fill",
                    explanation: "Ergänze 2-3 Sätze für den niedrig belasteten Bereich, wenn die nächste Einheit es hergibt.",
                    whyItMatters: "Niedriges Volumen über mehrere Wochen solltest du im Blick behalten.",
                    previewText: "Nächste Einheit: +2 Sätze für den laggenden Bereich"
                ),
                CoachAction(
                    type: .reduceVolume,
                    label: "Volumen senken",
                    icon: "minus.circle.fill",
                    explanation: "Streiche 1-2 Sätze aus dem sehr hoch belasteten Bereich.",
                    whyItMatters: "Zu viel Zusatzvolumen macht die Woche schwerer lesbar und kann andere Bereiche verdrängen.",
                    previewText: "Nächste Einheit: 1 Satz weniger im dominanten Bereich"
                )
            ]
        }
        return [
            CoachAction(
                type: .addWork,
                label: "Volumen beobachten",
                icon: "eye.fill",
                explanation: "Behalte den Trend im Blick. Wenn er nächste Woche bleibt, Anpassung prüfen.",
                whyItMatters: "Kleine Abweichungen sind normal; wiederholte Trends zählen mehr.",
                previewText: "Noch keine Änderung nötig - nächste Woche neu prüfen"
            )
        ]
    }

    private static func movementBalanceActions(_ insight: SmartInsight) -> [CoachAction] {
        [
            CoachAction(
                type: .addWork,
                label: "Ausgleich ergänzen",
                icon: "arrow.left.arrow.right",
                explanation: "Ergänze Sätze für die schwächere Seite am nächsten Oberkörpertag.",
                whyItMatters: "Ein klareres Push/Pull-Verhältnis macht die Woche besser steuerbar.",
                previewText: "Nächster Oberkörpertag: +2 Sätze für die schwächere Seite"
            )
        ]
    }

    private static func recoveryActions(_ insight: SmartInsight) -> [CoachAction] {
        if insight.severity == .high {
            return [
                CoachAction(
                    type: .deload,
                    label: "Deload-Woche starten",
                    icon: "arrow.down.to.line",
                    explanation: "Reduziere Volumen und Intensität über die Woche.",
                    whyItMatters: "Eine leichtere Woche macht den nächsten Block sauberer.",
                    previewText: "Diese Woche: weniger Sätze, niedrigere RPE, kürzere Einheiten"
                ),
                CoachAction(
                    type: .restDay,
                    label: "Ruhiger Tag",
                    icon: "bed.double.fill",
                    explanation: "Plane morgen ohne hartes Training.",
                    whyItMatters: "Wenn die Woche hart war, ist ein ruhiger Tag oft die bessere Wahl.",
                    previewText: "Morgen: kein hartes Training"
                )
            ]
        }
        return [
            CoachAction(
                type: .lighterSession,
                label: "Nächste Einheit leichter",
                icon: "arrow.down.circle",
                explanation: "Reduziere die Intensität in der nächsten Einheit und halte die Wiederholungen kontrolliert.",
                whyItMatters: "Eine leichtere Einheit hält den Rhythmus, ohne das Training weiter zu drücken.",
                previewText: "Nächste Einheit: ca. 15% weniger Gewicht, gleiche Übungen"
            )
        ]
    }

    private static func consistencyActions(_ insight: SmartInsight) -> [CoachAction] {
        if insight.severity == .positive {
            return [
                CoachAction(
                    type: .celebrate,
                    label: "Kurs halten",
                    icon: "star.fill",
                    explanation: "Die Konstanz sitzt. Behalte die aktuelle Struktur bei.",
                    whyItMatters: "Ein stabiler Rhythmus macht die nächsten Wochen planbarer.",
                    previewText: "Aktuelle Routine beibehalten"
                )
            ]
        }
        return [
            CoachAction(
                type: .increaseFrequency,
                label: "Einheiten planen",
                icon: "calendar.badge.plus",
                explanation: "Blocke konkrete Zeitfenster für die nächsten Trainingstage.",
                whyItMatters: "Konkrete Termine machen den Wochenrhythmus verlässlicher.",
                previewText: "Reminder für geplante Trainingstage setzen"
            )
        ]
    }

    private static func progressionActions(_ insight: SmartInsight) -> [CoachAction] {
        [
            CoachAction(
                type: .celebrate,
                label: "Bestleistung sichern",
                icon: "trophy.fill",
                explanation: "Neue Bestleistung geloggt. Nächste Einheit sauber bestätigen.",
                whyItMatters: "Ein PR zählt mehr, wenn der nächste Satz wieder sauber sitzt.",
                previewText: "Meilenstein geloggt - Struktur beibehalten"
            )
        ]
    }

    private static func bodyCompositionActions(_ insight: SmartInsight) -> [CoachAction] {
        if insight.title.contains("Up") && insight.severity != .positive {
            return [
                CoachAction(
                    type: .adjustNutrition,
                    label: "Ernährung prüfen",
                    icon: "fork.knife",
                    explanation: "Der Gewichtstrend passt nicht klar zum Ziel. Ernährung und Aktivität prüfen.",
                    whyItMatters: "Training und Ernährung sollten in dieselbe Richtung ziehen.",
                    previewText: "Kalorienziel und Trainingstage prüfen"
                )
            ]
        }
        return [
            CoachAction(
                type: .celebrate,
                label: "Auf Kurs",
                icon: "checkmark.circle.fill",
                explanation: "Der Gewichtstrend passt zum Ziel. Aktuelle Struktur beibehalten.",
                whyItMatters: "Ein passender Trend spricht dafür, nicht unnötig zu ändern.",
                previewText: "Keine Änderung nötig - Kurs halten"
            )
        ]
    }

    private static func generalActions(_ insight: SmartInsight?) -> [CoachAction] {
        [
            CoachAction(
                type: .lighterSession,
                label: "Nächste Einheit anpassen",
                icon: "slider.horizontal.3",
                explanation: "Nimm eine kleine Anpassung an der nächsten Einheit vor.",
                whyItMatters: "Tagesform ist nur ein Check. Eine kleine Anpassung reicht oft.",
                previewText: "Nächste Einheit: Intensität bewusst steuern"
            )
        ]
    }
}
