import SwiftUI

#if DEBUG
struct ProgressTrainingMapPrototypeView: View {
    let isFullscreen: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedState: ProgressTrainingMapDemoState = .normalWeek
    @State private var appeared = false

    init(isFullscreen: Bool = false) {
        self.isFullscreen = isFullscreen
    }

    private var scenario: ProgressTrainingMapScenario {
        selectedState.scenario
    }

    private var revealAnimation: Animation {
        reduceMotion ? .easeOut(duration: 0.08) : .spring(response: 0.42, dampingFraction: 0.88)
    }

    var body: some View {
        ZStack {
            ProgressTrainingMapStyle.background.ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        header
                            .id(ProgressTrainingMapScrollTarget.top)
                        stateSwitcher
                        firstViewport
                        lowerScroll
                            .id(ProgressTrainingMapScrollTarget.lower)
                    }
                    .frame(maxWidth: 430)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 14)
                    .padding(.top, isFullscreen ? 18 : 14)
                    .padding(.bottom, isFullscreen ? 34 : 18)
                }
                .scrollContentBackground(.hidden)
                .onChange(of: selectedState) { _, _ in
                    DispatchQueue.main.async {
                        if reduceMotion {
                            proxy.scrollTo(ProgressTrainingMapScrollTarget.top, anchor: .top)
                        } else {
                            withAnimation(.easeInOut(duration: 0.22)) {
                                proxy.scrollTo(ProgressTrainingMapScrollTarget.top, anchor: .top)
                            }
                        }
                    }
                }
            }

            if isFullscreen {
                topStatusScrim
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            guard !appeared else { return }
            if reduceMotion {
                appeared = true
            } else {
                withAnimation(revealAnimation.delay(0.08)) {
                    appeared = true
                }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Progress")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("Training Read")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(ProgressTrainingMapStyle.steel)
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            HStack(spacing: 9) {
                Text("DEBUG")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(STRQColors.primaryText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(STRQColors.white.opacity(0.08), in: Capsule())
                    .overlay(Capsule().strokeBorder(STRQColors.white.opacity(0.12), lineWidth: 1))

                if isFullscreen {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .black))
                            .foregroundStyle(STRQColors.primaryText)
                            .frame(width: 34, height: 34)
                            .background(STRQColors.white.opacity(0.08), in: Circle())
                            .overlay(Circle().strokeBorder(STRQColors.white.opacity(0.14), lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("progress-training-map-close")
                }
            }
        }
        .padding(.top, isFullscreen ? 6 : 0)
        .accessibilityIdentifier("progress-training-map-prototype-header")
    }

    private var stateSwitcher: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 7) {
                ForEach(ProgressTrainingMapDemoState.allCases) { state in
                    Button {
                        if reduceMotion {
                            selectedState = state
                        } else {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                selectedState = state
                            }
                        }
                    } label: {
                        Text(state.switcherTitle)
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(selectedState == state ? state.scenario.accent.readableText : STRQColors.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                            .padding(.horizontal, 10)
                            .frame(height: 32)
                            .background(
                                selectedState == state ? state.scenario.accent.color.opacity(0.18) : STRQColors.white.opacity(0.045),
                                in: Capsule()
                            )
                            .overlay(
                                Capsule()
                                    .strokeBorder(selectedState == state ? state.scenario.accent.color.opacity(0.48) : STRQColors.white.opacity(0.08), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("progress-training-map-state-\(state.rawValue)")
                }
            }
            .padding(.horizontal, 1)
            .padding(.vertical, 2)
        }
        .accessibilityIdentifier("progress-training-map-state-switcher")
    }

    private var firstViewport: some View {
        VStack(alignment: .leading, spacing: 10) {
            heroState
            TrainingPathVisual(scenario: scenario, appeared: appeared, reduceMotion: reduceMotion)
            proofRow
            nextMoveCard
        }
        .padding(12)
        .background {
            ZStack(alignment: .topTrailing) {
                ProgressTrainingMapStyle.heroSurface
                scenario.accent.color.opacity(0.09)
                    .frame(width: 180, height: 180)
                    .blur(radius: 70)
                    .offset(x: 84, y: -92)
            }
            .clipShape(.rect(cornerRadius: 24))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(scenario.accent.color.opacity(0.2), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0.86)
        .scaleEffect(appeared || reduceMotion ? 1 : 0.985)
        .animation(revealAnimation, value: appeared)
        .accessibilityIdentifier("progress-training-map-first-viewport")
    }

    private var heroState: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(spacing: 8) {
                ProgressTrainingMapPill(text: scenario.stateLabel, accent: scenario.accent)
                Spacer(minLength: 0)
                ProgressTrainingMapPill(text: scenario.windowLabel, accent: .steel)
            }

            Text(scenario.headline)
                .font(.system(size: 25, weight: .black, design: .rounded))
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.72)
                .fixedSize(horizontal: false, vertical: true)

            Text(scenario.explanation)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(STRQColors.secondaryText)
                .lineSpacing(2)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var proofRow: some View {
        HStack(spacing: 7) {
            ForEach(scenario.proofItems) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.label)
                        .font(.system(size: 9, weight: .bold, design: .rounded))
                        .foregroundStyle(STRQColors.mutedText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.66)
                    Text(item.value)
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(item.accent.color)
                        .lineLimit(2)
                        .minimumScaleFactor(0.74)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .frame(height: 56)
                .background(ProgressTrainingMapStyle.panel, in: .rect(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(item.accent.color.opacity(0.18), lineWidth: 1)
                )
            }
        }
        .accessibilityIdentifier("progress-training-map-proof-row")
    }

    private var nextMoveCard: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(scenario.accent.color.opacity(0.16))
                Image(systemName: scenario.nextMoveSymbol)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(scenario.accent.color)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 5) {
                Text(scenario.nextMoveTitle)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
                    .fixedSize(horizontal: false, vertical: true)

                Text(scenario.nextMoveDetail)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(10)
        .background(ProgressTrainingMapStyle.nextMoveSurface, in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(scenario.accent.color.opacity(0.24), lineWidth: 1)
        )
        .accessibilityIdentifier("progress-training-map-next-move")
    }

    private var lowerScroll: some View {
        VStack(alignment: .leading, spacing: 10) {
            ProgressTrainingMapEvidenceSection(title: "Was steht", items: scenario.provenItems, defaultAccent: .green)
            ProgressTrainingMapEvidenceSection(title: "Was sich bildet", items: scenario.formingItems, defaultAccent: .amber)
            ProgressTrainingMapEvidenceSection(title: "Was fehlt", items: scenario.missingItems, defaultAccent: .gray)
            ProgressTrainingMapEvidenceSection(title: "Letzte Beweise", items: scenario.recentEvidence, defaultAccent: .steel)
            ProgressTrainingMapNextStepDetail(scenario: scenario)
        }
        .accessibilityIdentifier("progress-training-map-lower-scroll")
    }

    private var topStatusScrim: some View {
        VStack {
            LinearGradient(
                colors: [
                    ProgressTrainingMapStyle.background,
                    ProgressTrainingMapStyle.background.opacity(0.96),
                    ProgressTrainingMapStyle.background.opacity(0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 54)
            .ignoresSafeArea(edges: .top)
            .allowsHitTesting(false)
            Spacer()
        }
    }
}

private enum ProgressTrainingMapScrollTarget {
    case top
    case lower
}

private struct TrainingPathVisual: View {
    let scenario: ProgressTrainingMapScenario
    let appeared: Bool
    let reduceMotion: Bool

    private var path: TrainingPathData {
        TrainingPathData.make(for: scenario.state)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(path.title)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(1)
                    Text(path.summary)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Text(path.badge)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(path.accent.readableText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(path.accent.color.opacity(0.12), in: Capsule())
                    .overlay(Capsule().strokeBorder(path.accent.color.opacity(0.22), lineWidth: 1))
            }

            ZStack {
                Rectangle()
                    .fill(STRQColors.white.opacity(0.08))
                    .frame(height: 2)
                    .padding(.horizontal, 20)
                    .offset(y: -15)

                HStack(alignment: .top, spacing: 0) {
                    ForEach(path.steps) { step in
                        TrainingPathStepView(step: step, reduceMotion: reduceMotion)
                            .frame(maxWidth: .infinity)
                    }
                }
            }

            Text(path.nextRead)
                .font(.system(size: 12, weight: .black, design: .rounded))
                .foregroundStyle(path.accent.color)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 10)
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(path.accent.color.opacity(0.1), in: .rect(cornerRadius: 13))
        }
        .padding(12)
        .background(ProgressTrainingMapStyle.mapSurface, in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(path.accent.color.opacity(0.18), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0.9)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.22), value: appeared)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(path.accessibilitySummary))
    }
}

private struct TrainingPathStepView: View {
    let step: TrainingPathStep
    let reduceMotion: Bool

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(step.accent.color.opacity(step.filled ? 0.2 : 0.08))
                    .overlay(
                        Circle()
                            .strokeBorder(step.accent.color.opacity(step.filled ? 0.72 : 0.22), lineWidth: step.filled ? 1.4 : 1)
                    )

                Image(systemName: step.symbol)
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(step.accent.color)
            }
            .frame(width: 31, height: 31)
            .scaleEffect(step.emphasized && !reduceMotion ? 1.06 : 1)
            .shadow(color: step.accent.color.opacity(step.emphasized ? 0.24 : 0), radius: 8, y: 4)

            Text(step.topLabel)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(step.bottomLabel)
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(STRQColors.mutedText)
                .lineLimit(1)
                .minimumScaleFactor(0.62)
        }
        .padding(.horizontal, 1)
    }
}

private struct TrainingPathData {
    let title: String
    let badge: String
    let summary: String
    let nextRead: String
    let accent: ProgressTrainingMapAccent
    let steps: [TrainingPathStep]

    var accessibilitySummary: String {
        ([summary] + steps.map { "\($0.topLabel): \($0.bottomLabel)" } + [nextRead]).joined(separator: ", ")
    }

    static func make(for state: ProgressTrainingMapDemoState) -> TrainingPathData {
        switch state {
        case .lowData:
            return data(
                title: "Wochenpfad",
                badge: "Woche 1",
                summary: "1 Einheit ist drin. Für echte Muster fehlen noch weitere Logs.",
                nextRead: "Noch nichts erzwingen: nächste Einheit sauber loggen.",
                accent: .gray,
                steps: [
                    step("Mo", "Log", "checkmark", .green, true, true),
                    step("Di", "offen", "circle", .gray, false),
                    step("Mi", "offen", "circle", .gray, false),
                    step("Do", "offen", "circle", .gray, false),
                    step("Fr", "Plan", "plus", .steel, false, true),
                    step("Sa", "offen", "circle", .gray, false),
                    step("So", "offen", "circle", .gray, false)
                ]
            )

        case .normalWeek:
            return data(
                title: "Wochenpfad",
                badge: "2 von 3",
                summary: "Die Woche läuft im Plan. Eine Einheit bleibt offen.",
                nextRead: "Kein Extra nötig: geplante Einheit halten.",
                accent: .steel,
                steps: [
                    step("Mo", "Push", "checkmark", .green, true),
                    step("Di", "Pause", "moon.fill", .gray, false),
                    step("Mi", "Beine", "checkmark", .green, true),
                    step("Do", "Pause", "moon.fill", .gray, false),
                    step("Fr", "Plan", "arrow.right", .steel, false, true),
                    step("Sa", "frei", "circle", .gray, false),
                    step("So", "frei", "circle", .gray, false)
                ]
            )

        case .targetHit:
            return data(
                title: "Wochenpfad",
                badge: "3 von 3",
                summary: "Alle geplanten Einheiten sind erledigt. Jetzt zählt Wiederholung.",
                nextRead: "Nicht nachlegen: nächste Woche denselben Rhythmus setzen.",
                accent: .green,
                steps: [
                    step("Mo", "Push", "checkmark", .green, true),
                    step("Di", "Pause", "moon.fill", .gray, false),
                    step("Mi", "Pull", "checkmark", .green, true),
                    step("Do", "Pause", "moon.fill", .gray, false),
                    step("Fr", "Beine", "checkmark", .green, true, true),
                    step("Sa", "frei", "circle", .gray, false),
                    step("So", "frei", "circle", .gray, false)
                ]
            )

        case .targetOverhit:
            return data(
                title: "Wochenpfad",
                badge: "4 Einheiten",
                summary: "Ziel geschafft, aber eng gebündelt. Abstand bleibt offen.",
                nextRead: "Nächste Woche gleichmäßiger verteilen.",
                accent: .amber,
                steps: [
                    step("Mo", "Log", "checkmark", .green, true),
                    step("Di", "Extra", "plus", .amber, true, true),
                    step("Mi", "Pause", "moon.fill", .gray, false),
                    step("Do", "Log", "checkmark", .green, true),
                    step("Fr", "Extra", "plus", .amber, true, true),
                    step("Sa", "frei", "circle", .gray, false),
                    step("So", "frei", "circle", .gray, false)
                ]
            )

        case .volumeUp:
            return data(
                title: "Wochenpfad",
                badge: "Volumen rauf",
                summary: "Mehr Arbeit ist geloggt. Der nächste schwere Schritt braucht Kontext.",
                nextRead: "Schwer nur, wenn Erholung und Technik passen.",
                accent: .amber,
                steps: [
                    step("Mo", "Log", "checkmark", .green, true),
                    step("Di", "Pause", "moon.fill", .gray, false),
                    step("Mi", "Log", "checkmark", .green, true),
                    step("Do", "Mehr", "plus", .amber, true, true),
                    step("Fr", "Check", "gauge.with.needle.fill", .amber, false, true),
                    step("Sa", "frei", "circle", .gray, false),
                    step("So", "frei", "circle", .gray, false)
                ]
            )

        case .bestSet:
            return data(
                title: "Session-Pfad",
                badge: "Bestset",
                summary: "Ein Satz sticht heraus. Gold bleibt nur für echte Bestmarken.",
                nextRead: "Qualität halten und den Satz später bestätigen.",
                accent: .gold,
                steps: [
                    step("Warm", "sauber", "checkmark", .steel, true),
                    step("Satz 1", "ok", "checkmark", .steel, true),
                    step("Satz 2", "Best", "star.fill", .gold, true, true),
                    step("Satz 3", "halten", "equal", .steel, true),
                    step("Weiter", "ruhig", "arrow.right", .steel, false)
                ]
            )

        case .recoveryLow:
            return data(
                title: "Heute",
                badge: "Ruhiger",
                summary: "Training geht. Der harte Push ist heute nicht die beste Wahl.",
                nextRead: "Gewicht runter, Technik sauber.",
                accent: .red,
                steps: [
                    step("Zuletzt", "schwer", "dumbbell.fill", .amber, true),
                    step("Schlaf", "kurz", "moon.zzz.fill", .amber, true),
                    step("Heute", "leicht", "arrow.down", .red, true, true),
                    step("PR", "nein", "star.slash.fill", .gray, false),
                    step("Log", "sauber", "checkmark", .green, false)
                ]
            )

        case .deloadWeek:
            return data(
                title: "Wochenpfad",
                badge: "Deload",
                summary: "Weniger Druck ist diese Woche Absicht, kein Rückschritt.",
                nextRead: "Sauber bewegen, Volumen unten lassen.",
                accent: .steel,
                steps: [
                    step("Mo", "leicht", "checkmark", .steel, true),
                    step("Di", "Pause", "moon.fill", .gray, false),
                    step("Mi", "leicht", "checkmark", .steel, true),
                    step("Do", "Pause", "moon.fill", .gray, false),
                    step("Fr", "Qualität", "pause.fill", .steel, false, true),
                    step("Sa", "frei", "circle", .gray, false),
                    step("So", "frei", "circle", .gray, false)
                ]
            )

        case .plateau:
            return data(
                title: "Lift-Pfad",
                badge: "3 Versuche",
                summary: "Drei ähnliche Versuche, kein klarer Sprung. Der Hebel wird kleiner.",
                nextRead: "Wdh., Gewicht oder Pause fein anpassen.",
                accent: .amber,
                steps: [
                    step("V1", "gleich", "equal", .amber, true),
                    step("V2", "gleich", "equal", .amber, true),
                    step("V3", "gleich", "equal", .amber, true),
                    step("Next", "drehen", "slider.horizontal.3", .amber, false, true)
                ]
            )

        case .comebackWeek:
            return data(
                title: "Comeback-Pfad",
                badge: "1 drin",
                summary: "Nach der Pause zählt Einstieg vor Druck.",
                nextRead: "Zweite Einheit ruhig setzen.",
                accent: .amber,
                steps: [
                    step("Pause", "beendet", "checkmark", .green, true),
                    step("Heute", "Log", "figure.strengthtraining.traditional", .green, true, true),
                    step("Next", "ruhig", "arrow.uturn.forward", .amber, false, true),
                    step("Druck", "später", "clock", .gray, false)
                ]
            )

        case .consistentRhythm:
            return data(
                title: "4-Wochen-Pfad",
                badge: "stabil",
                summary: "Der Rhythmus wiederholt sich. Jetzt darf ein Hebel gezielt hoch.",
                nextRead: "Einen Hebel pushen, den Rest stabil halten.",
                accent: .green,
                steps: [
                    step("W1", "3/3", "checkmark", .green, true),
                    step("W2", "3/3", "checkmark", .green, true),
                    step("W3", "2/3", "checkmark", .green, true),
                    step("W4", "3/3", "checkmark.seal.fill", .green, true, true)
                ]
            )

        case .muscleCoverageForming:
            return data(
                title: "Bereichs-Pfad",
                badge: "Abdeckung",
                summary: "Push ist drin, Pull bildet sich. Ein Bereich bleibt offen.",
                nextRead: "Offenen Bereich einplanen, keine Prozentjagd.",
                accent: .amber,
                steps: [
                    step("Mo", "Push", "checkmark", .green, true),
                    step("Mi", "Pull", "circle.lefthalf.filled", .amber, true, true),
                    step("Fr", "Beine", "circle", .gray, false, true),
                    step("Balance", "keine %", "number", .gray, false)
                ]
            )
        }
    }

    private static func data(
        title: String,
        badge: String,
        summary: String,
        nextRead: String,
        accent: ProgressTrainingMapAccent,
        steps: [TrainingPathStep]
    ) -> TrainingPathData {
        TrainingPathData(title: title, badge: badge, summary: summary, nextRead: nextRead, accent: accent, steps: steps)
    }

    private static func step(
        _ topLabel: String,
        _ bottomLabel: String,
        _ symbol: String,
        _ accent: ProgressTrainingMapAccent,
        _ filled: Bool,
        _ emphasized: Bool = false
    ) -> TrainingPathStep {
        TrainingPathStep(topLabel: topLabel, bottomLabel: bottomLabel, symbol: symbol, accent: accent, filled: filled, emphasized: emphasized)
    }
}

private struct TrainingPathStep: Identifiable {
    let id = UUID()
    let topLabel: String
    let bottomLabel: String
    let symbol: String
    let accent: ProgressTrainingMapAccent
    let filled: Bool
    let emphasized: Bool
}

private struct TrainingMapVisual: View {
    let scenario: ProgressTrainingMapScenario
    let appeared: Bool
    let reduceMotion: Bool

    private var mapAnimation: Animation {
        reduceMotion ? .easeOut(duration: 0.08) : .spring(response: 0.5, dampingFraction: 0.82)
    }

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)
            let positions = TrainingMapNodePosition.positions(width: width, height: height)

            ZStack {
                mapBackdrop

                ForEach(TrainingMapNodePosition.routes, id: \.0) { route in
                    TrainingMapRouteLine(
                        start: positions[route.0] ?? .zero,
                        end: positions[route.1] ?? .zero,
                        accent: scenario.routeAccent(from: route.0, to: route.1),
                        reduceMotion: reduceMotion
                    )
                }

                ForEach(scenario.nodes) { node in
                    TrainingMapNodeView(node: node, reduceMotion: reduceMotion)
                        .frame(width: node.size, height: node.size)
                        .position(positions[node.kind] ?? .zero)
                        .scaleEffect(appeared ? 1 : 0.92)
                        .animation(mapAnimation.delay(node.delay), value: appeared)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Training Path")
                        .font(.system(size: 12, weight: .black, design: .rounded))
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(1)
                    Text(scenario.mapCaption)
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(STRQColors.mutedText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: min(172, width * 0.52), alignment: .leading)
                .padding(9)
                .background(ProgressTrainingMapStyle.mapLabelSurface, in: .rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(STRQColors.white.opacity(0.08), lineWidth: 1)
                )
                .position(x: width * 0.28, y: height * 0.18)
            }
        }
        .frame(height: 245)
        .background(ProgressTrainingMapStyle.mapSurface, in: .rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(STRQColors.white.opacity(0.08), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(scenario.accessibilityMapSummary))
    }

    private var mapBackdrop: some View {
        ZStack {
            LinearGradient(
                colors: [
                    scenario.accent.color.opacity(0.08),
                    ProgressTrainingMapStyle.mapSurface,
                    STRQColors.gray950.opacity(0.66)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            GeometryReader { proxy in
                let width = max(proxy.size.width, 1)
                let height = max(proxy.size.height, 1)
                Path { path in
                    path.addEllipse(in: CGRect(x: width * 0.14, y: height * 0.12, width: width * 0.72, height: height * 0.68))
                    path.addEllipse(in: CGRect(x: width * 0.3, y: height * 0.27, width: width * 0.4, height: height * 0.34))
                }
                .stroke(STRQColors.white.opacity(0.06), style: StrokeStyle(lineWidth: 1, dash: [6, 10]))

                Path { path in
                    path.move(to: CGPoint(x: width * 0.1, y: height * 0.68))
                    path.addCurve(
                        to: CGPoint(x: width * 0.88, y: height * 0.34),
                        control1: CGPoint(x: width * 0.28, y: height * 0.2),
                        control2: CGPoint(x: width * 0.64, y: height * 0.92)
                    )
                }
                .stroke(scenario.accent.color.opacity(0.12), style: StrokeStyle(lineWidth: 1, dash: [3, 8]))
            }
        }
    }
}

private struct TrainingMapRouteLine: View {
    let start: CGPoint
    let end: CGPoint
    let accent: ProgressTrainingMapAccent
    let reduceMotion: Bool

    var body: some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
        .stroke(
            accent.color.opacity(accent == .gray ? 0.22 : 0.48),
            style: StrokeStyle(lineWidth: accent == .gray ? 1 : 2, lineCap: .round, dash: accent == .gray ? [5, 7] : [])
        )
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: accent)
    }
}

private struct TrainingMapNodeView: View {
    let node: TrainingMapNode
    let reduceMotion: Bool

    private var revealScale: CGFloat {
        node.accent == .gold && !reduceMotion ? 1.06 : 1
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(node.nodeState.fill)
                .overlay(
                    Circle()
                        .strokeBorder(node.accent.color.opacity(node.nodeState == .locked ? 0.25 : 0.72), style: StrokeStyle(lineWidth: node.accent == .gold ? 2 : 1, dash: node.nodeState == .locked ? [4, 5] : []))
                )
                .shadow(color: node.accent.color.opacity(node.nodeState.shadowOpacity), radius: node.nodeState == .locked ? 0 : 12, y: 5)

            Circle()
                .trim(from: 0, to: node.progress)
                .stroke(node.accent.color, style: StrokeStyle(lineWidth: node.accent == .gold ? 4 : 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(4)
                .opacity(node.nodeState == .locked ? 0.2 : 0.95)

            VStack(spacing: 3) {
                Image(systemName: node.symbol)
                    .font(.system(size: node.primary ? 17 : 14, weight: .black))
                    .foregroundStyle(node.accent.color)
                Text(node.title)
                    .font(.system(size: node.primary ? 9 : 8, weight: .black, design: .rounded))
                    .foregroundStyle(node.nodeState == .locked ? STRQColors.mutedText : STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }
            .padding(.horizontal, 4)

            if node.accent == .gold {
                Circle()
                    .stroke(ProgressTrainingMapStyle.gold.opacity(0.42), lineWidth: 1)
                    .scaleEffect(reduceMotion ? 1 : 1.18)
                    .opacity(reduceMotion ? 0.65 : 0.3)
            }
        }
        .scaleEffect(revealScale)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.28), value: node.accent)
        .accessibilityLabel(Text("\(node.title), \(node.nodeState.accessibilityLabel)"))
    }
}

private struct ProgressTrainingMapPill: View {
    let text: String
    let accent: ProgressTrainingMapAccent

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .foregroundStyle(accent.readableText)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(accent.color.opacity(0.12), in: Capsule())
            .overlay(Capsule().strokeBorder(accent.color.opacity(0.22), lineWidth: 1))
    }
}

private struct ProgressTrainingMapEvidenceSection: View {
    let title: String
    let items: [ProgressTrainingMapEvidenceItem]
    let defaultAccent: ProgressTrainingMapAccent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 7) {
                Circle()
                    .fill(defaultAccent.color)
                    .frame(width: 7, height: 7)
                Text(title)
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }

            VStack(spacing: 7) {
                ForEach(items) { item in
                    HStack(alignment: .top, spacing: 9) {
                        Image(systemName: item.symbol)
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(item.accent.color)
                            .frame(width: 26, height: 26)
                            .background(item.accent.color.opacity(0.12), in: .rect(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(STRQColors.primaryText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                            Text(item.detail)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(STRQColors.secondaryText)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(9)
                    .background(ProgressTrainingMapStyle.panel, in: .rect(cornerRadius: 13))
                    .overlay(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .strokeBorder(STRQColors.white.opacity(0.07), lineWidth: 1)
                    )
                }
            }
        }
        .padding(11)
        .background(ProgressTrainingMapStyle.sectionSurface, in: .rect(cornerRadius: 17))
        .overlay(
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .strokeBorder(STRQColors.white.opacity(0.07), lineWidth: 1)
        )
    }
}

private struct ProgressTrainingMapNextStepDetail: View {
    let scenario: ProgressTrainingMapScenario

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 7) {
                Circle()
                    .fill(scenario.accent.color)
                    .frame(width: 7, height: 7)
                Text("Nächster Schritt")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(STRQColors.primaryText)
                Spacer(minLength: 0)
            }

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: scenario.nextMoveSymbol)
                    .font(.system(size: 15, weight: .black))
                    .foregroundStyle(scenario.accent.color)
                    .frame(width: 34, height: 34)
                    .background(scenario.accent.color.opacity(0.12), in: .rect(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 4) {
                    Text(scenario.nextMoveTitle)
                        .font(.system(size: 16, weight: .black, design: .rounded))
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.78)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(scenario.nextMoveLongDetail)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(10)
            .background(ProgressTrainingMapStyle.nextMoveSurface, in: .rect(cornerRadius: 15))
        }
        .padding(11)
        .background(ProgressTrainingMapStyle.sectionSurface, in: .rect(cornerRadius: 17))
        .overlay(
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .strokeBorder(scenario.accent.color.opacity(0.18), lineWidth: 1)
        )
    }
}

private enum ProgressTrainingMapDemoState: String, CaseIterable, Identifiable {
    case lowData
    case normalWeek
    case targetHit
    case targetOverhit
    case volumeUp
    case bestSet
    case recoveryLow
    case deloadWeek
    case plateau
    case comebackWeek
    case consistentRhythm
    case muscleCoverageForming

    var id: String { rawValue }

    var switcherTitle: String {
        switch self {
        case .lowData: return "Start"
        case .normalWeek: return "Normal"
        case .targetHit: return "Ziel"
        case .targetOverhit: return "Gebündelt"
        case .volumeUp: return "Volumen"
        case .bestSet: return "Bestset"
        case .recoveryLow: return "Ruhiger"
        case .deloadWeek: return "Deload"
        case .plateau: return "Plateau"
        case .comebackWeek: return "Comeback"
        case .consistentRhythm: return "Rhythm"
        case .muscleCoverageForming: return "Abdeckung"
        }
    }

    var scenario: ProgressTrainingMapScenario {
        ProgressTrainingMapScenarioFactory.scenario(for: self)
    }
}

private struct ProgressTrainingMapScenario: Identifiable {
    let state: ProgressTrainingMapDemoState
    let stateLabel: String
    let windowLabel: String
    let headline: String
    let explanation: String
    let mapCaption: String
    let accent: ProgressTrainingMapAccent
    let nodes: [TrainingMapNode]
    let proofItems: [ProgressTrainingMapProofItem]
    let nextMoveTitle: String
    let nextMoveDetail: String
    let nextMoveLongDetail: String
    let nextMoveScope: String
    let nextMoveSymbol: String
    let provenItems: [ProgressTrainingMapEvidenceItem]
    let formingItems: [ProgressTrainingMapEvidenceItem]
    let missingItems: [ProgressTrainingMapEvidenceItem]
    let recentEvidence: [ProgressTrainingMapEvidenceItem]

    var id: String { state.rawValue }

    var accessibilityMapSummary: String {
        nodes.map { "\($0.title) \($0.nodeState.accessibilityLabel)" }.joined(separator: ", ")
    }

    func routeAccent(from: TrainingMapNodeKind, to: TrainingMapNodeKind) -> ProgressTrainingMapAccent {
        let start = nodes.first { $0.kind == from }?.accent ?? .gray
        let end = nodes.first { $0.kind == to }?.accent ?? .gray
        if start == .gray || end == .gray { return .gray }
        if start == .red || end == .red { return .red }
        if start == .gold || end == .gold { return .gold }
        if start == .amber || end == .amber { return .amber }
        if start == .green || end == .green { return .green }
        return .steel
    }
}

private struct TrainingMapNode: Identifiable {
    let kind: TrainingMapNodeKind
    let title: String
    let symbol: String
    let nodeState: TrainingMapNodeState
    let accent: ProgressTrainingMapAccent
    let progress: CGFloat
    let primary: Bool
    let delay: Double

    var id: TrainingMapNodeKind { kind }
    var size: CGFloat { primary ? 80 : 68 }
}

private enum TrainingMapNodeKind: CaseIterable {
    case rhythm
    case volume
    case strength
    case coverage
    case recovery
}

private enum TrainingMapNodeState {
    case proven
    case forming
    case missing
    case locked
    case pr

    var fill: Color {
        switch self {
        case .proven:
            return ProgressTrainingMapStyle.green.opacity(0.16)
        case .forming:
            return ProgressTrainingMapStyle.amber.opacity(0.14)
        case .missing:
            return STRQColors.gray800.opacity(0.78)
        case .locked:
            return STRQColors.gray900.opacity(0.82)
        case .pr:
            return ProgressTrainingMapStyle.gold.opacity(0.18)
        }
    }

    var shadowOpacity: Double {
        switch self {
        case .proven: return 0.28
        case .forming: return 0.2
        case .missing: return 0.05
        case .locked: return 0
        case .pr: return 0.38
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .proven: return "steht"
        case .forming: return "bildet sich"
        case .missing: return "offen"
        case .locked: return "noch offen"
        case .pr: return "Bestmarke"
        }
    }
}

private struct ProgressTrainingMapProofItem: Identifiable {
    let id = UUID()
    let label: String
    let value: String
    let accent: ProgressTrainingMapAccent
}

private struct ProgressTrainingMapEvidenceItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let symbol: String
    let accent: ProgressTrainingMapAccent
}

private enum ProgressTrainingMapAccent: Equatable {
    case green
    case amber
    case gold
    case red
    case steel
    case gray

    var color: Color {
        switch self {
        case .green: return ProgressTrainingMapStyle.green
        case .amber: return ProgressTrainingMapStyle.amber
        case .gold: return ProgressTrainingMapStyle.gold
        case .red: return ProgressTrainingMapStyle.red
        case .steel: return ProgressTrainingMapStyle.steel
        case .gray: return ProgressTrainingMapStyle.gray
        }
    }

    var readableText: Color {
        switch self {
        case .gray:
            return STRQColors.secondaryText
        default:
            return color
        }
    }
}

private enum TrainingMapNodePosition {
    static let routes: [(TrainingMapNodeKind, TrainingMapNodeKind)] = [
        (.rhythm, .volume),
        (.volume, .strength),
        (.strength, .coverage),
        (.coverage, .recovery),
        (.recovery, .rhythm)
    ]

    static func positions(width: CGFloat, height: CGFloat) -> [TrainingMapNodeKind: CGPoint] {
        [
            .rhythm: CGPoint(x: width * 0.24, y: height * 0.5),
            .volume: CGPoint(x: width * 0.46, y: height * 0.78),
            .strength: CGPoint(x: width * 0.78, y: height * 0.61),
            .coverage: CGPoint(x: width * 0.7, y: height * 0.27),
            .recovery: CGPoint(x: width * 0.42, y: height * 0.31)
        ]
    }
}

private enum ProgressTrainingMapStyle {
    static let background = Color(red: 0.018, green: 0.019, blue: 0.023)
    static let heroSurface = Color(red: 0.055, green: 0.058, blue: 0.067)
    static let sectionSurface = Color(red: 0.047, green: 0.050, blue: 0.058)
    static let panel = Color.white.opacity(0.045)
    static let nextMoveSurface = Color.white.opacity(0.06)
    static let mapSurface = Color(red: 0.028, green: 0.031, blue: 0.038)
    static let mapLabelSurface = Color.black.opacity(0.28)
    static let green = STRQPalette.signalGreen
    static let amber = STRQPalette.warningAmber
    static let gold = STRQPalette.gold
    static let red = STRQPalette.dangerRed
    static let steel = Color(red: 0.56, green: 0.68, blue: 0.78)
    static let gray = STRQColors.gray500
}

private enum ProgressTrainingMapScenarioFactory {
    static func scenario(for state: ProgressTrainingMapDemoState) -> ProgressTrainingMapScenario {
        switch state {
        case .lowData:
            return make(
                state: state,
                stateLabel: "Start",
                windowLabel: "Woche 1",
                headline: "Der Read startet.",
                explanation: "Ein paar Sätze sind drin. Für echte Muster braucht STRQ noch mehr Training.",
                mapCaption: "Erste Arbeit ist sichtbar. Die meisten Bereiche bleiben offen.",
                accent: .gray,
                nodeSpecs: [
                    (.rhythm, "Rhythmus", "calendar", .locked, .gray, 0.18, false),
                    (.volume, "Volumen", "square.stack.3d.up.fill", .forming, .amber, 0.34, true),
                    (.strength, "Kraft", "dumbbell.fill", .locked, .gray, 0.12, false),
                    (.coverage, "Abdeckung", "scope", .locked, .gray, 0.08, false),
                    (.recovery, "Kontext", "gauge.with.needle.fill", .forming, .steel, 0.28, false)
                ],
                proofItems: [
                    ("Einheiten", "1 Einheit", .green),
                    ("Ziel", "Ziel offen", .gray),
                    ("Kraft", "Kraft offen", .gray),
                    ("Abdeckung", "Abdeckung offen", .gray)
                ],
                nextMoveTitle: "Nächste Einheit sauber loggen.",
                nextMoveDetail: "Mehr echte Sätze machen den Read klarer.",
                nextMoveLongDetail: "Keine Trends erzwingen. Eine weitere sauber geloggte Einheit reicht, damit Rhythmus und Abdeckung anfangen zu zählen.",
                nextMoveScope: "Nächste Einheit",
                nextMoveSymbol: "plus.circle.fill",
                proven: [
                    item("Eine Einheit drin", "Der erste abgeschlossene Log steht in der Woche.", "checkmark.circle.fill", .green)
                ],
                forming: [
                    item("Volumen bildet sich", "STRQ sieht Arbeit, aber noch kein Muster.", "square.stack.3d.up.fill", .amber)
                ],
                missing: [
                    item("Kraft noch offen", "Für Bestmarken fehlt vergleichbare Historie.", "lock.fill", .gray),
                    item("Abdeckung offen", "Zu wenige Bereiche wurden bisher trainiert.", "circle.dashed", .gray)
                ],
                recent: [
                    item("Heute", "Erste Einheit abgeschlossen.", "figure.strengthtraining.traditional", .green)
                ]
            )

        case .normalWeek:
            return make(
                state: state,
                stateLabel: "Im Plan",
                windowLabel: "Diese Woche",
                headline: "Die Woche läuft.",
                explanation: "Du bist im Plan. Die nächste Einheit hält die Woche sauber in Bewegung.",
                mapCaption: "Ziel und Rhythmus laufen, ein Bereich bleibt noch offen.",
                accent: .steel,
                nodeSpecs: [
                    (.rhythm, "Rhythmus", "calendar", .forming, .amber, 0.56, true),
                    (.volume, "Volumen", "square.stack.3d.up.fill", .proven, .green, 0.68, false),
                    (.strength, "Kraft", "dumbbell.fill", .forming, .steel, 0.48, false),
                    (.coverage, "Abdeckung", "scope", .forming, .amber, 0.44, false),
                    (.recovery, "Erholung", "gauge.with.needle.fill", .forming, .steel, 0.58, false)
                ],
                proofItems: [
                    ("Einheiten", "2 von 3", .green),
                    ("Abstand", "passt", .steel),
                    ("Volumen", "normal", .steel),
                    ("Offen", "1 Bereich", .amber)
                ],
                nextMoveTitle: "Nächste geplante Einheit halten.",
                nextMoveDetail: "Kein Extra nötig, nur sauber weiter.",
                nextMoveLongDetail: "Dein Read braucht jetzt keinen harten Sprung. Die geplante Einheit hält Ziel, Rhythmus und Abdeckung sauber beisammen.",
                nextMoveScope: "Diese Woche",
                nextMoveSymbol: "arrow.right.circle.fill",
                proven: [
                    item("Volumen steht", "Die erledigte Arbeit passt zur Woche.", "checkmark.circle.fill", .green)
                ],
                forming: [
                    item("Rhythmus bildet sich", "Die Abstände sehen gut aus, brauchen aber Wiederholung.", "calendar", .amber),
                    item("Kraft bleibt Kontext", "Sätze sind da, aber noch keine Bestmarke.", "dumbbell.fill", .steel)
                ],
                missing: [
                    item("Ein Bereich offen", "Die nächste Einheit kann die Abdeckung runder machen.", "circle.dashed", .gray)
                ],
                recent: [
                    item("Mo", "Oberkörper geloggt.", "checkmark.circle.fill", .green),
                    item("Mi", "Unterkörper geloggt.", "checkmark.circle.fill", .green)
                ]
            )

        case .targetHit:
            return make(
                state: state,
                stateLabel: "Ziel erreicht",
                windowLabel: "Woche",
                headline: "Wochenziel getroffen.",
                explanation: "Die geplante Arbeit ist erledigt. Jetzt zählt, ob der Rhythmus wiederholbar bleibt.",
                mapCaption: "Das Ziel steht. Der nächste Beweis ist Wiederholung.",
                accent: .green,
                nodeSpecs: [
                    (.rhythm, "Rhythmus", "calendar", .forming, .amber, 0.72, true),
                    (.volume, "Volumen", "square.stack.3d.up.fill", .proven, .green, 0.86, false),
                    (.strength, "Kraft", "dumbbell.fill", .forming, .steel, 0.54, false),
                    (.coverage, "Abdeckung", "scope", .forming, .amber, 0.58, false),
                    (.recovery, "Erholung", "gauge.with.needle.fill", .forming, .steel, 0.64, false)
                ],
                proofItems: [
                    ("Einheiten", "3 von 3", .green),
                    ("Ziel", "erreicht", .green),
                    ("Volumen", "steht", .green),
                    ("Rhythmus", "prüfen", .amber)
                ],
                nextMoveTitle: "Rhythmus nächste Woche wiederholen.",
                nextMoveDetail: "Ein gutes Ziel wird stark, wenn es wiederkommt.",
                nextMoveLongDetail: "Nicht noch mehr in diese Woche drücken. Der starke Beweis ist, die gleiche Kadenz nächste Woche wieder sauber zu setzen.",
                nextMoveScope: "Nächste Woche",
                nextMoveSymbol: "repeat.circle.fill",
                proven: [
                    item("Wochenziel steht", "Die geplanten Einheiten sind abgeschlossen.", "checkmark.seal.fill", .green),
                    item("Volumen erledigt", "Die Arbeit reicht für diese Woche.", "square.stack.3d.up.fill", .green)
                ],
                forming: [
                    item("Rhythmus braucht Wiederholung", "Eine gute Woche ist noch kein Langzeitmuster.", "calendar", .amber)
                ],
                missing: [
                    item("Keine Bestmarke nötig", "Diese Woche beweist Zieltreue, nicht Maximalleistung.", "minus.circle.fill", .gray)
                ],
                recent: [
                    item("Fr", "Dritte Einheit abgeschlossen.", "checkmark.circle.fill", .green)
                ]
            )

        case .targetOverhit:
            return make(
                state: state,
                stateLabel: "Eng gebündelt",
                windowLabel: "Woche",
                headline: "Ziel getroffen. Rhythmus noch nicht.",
                explanation: "Du hast mehr geschafft als geplant. Die Einheiten lagen eng beieinander, deshalb bleibt der Rhythmus offen.",
                mapCaption: "Mehr Arbeit ist drin. Die Verteilung bleibt im Blick.",
                accent: .amber,
                nodeSpecs: [
                    (.rhythm, "Rhythmus", "calendar", .forming, .amber, 0.58, true),
                    (.volume, "Volumen", "square.stack.3d.up.fill", .proven, .green, 0.92, false),
                    (.strength, "Kraft", "dumbbell.fill", .forming, .steel, 0.52, false),
                    (.coverage, "Abdeckung", "scope", .forming, .amber, 0.56, false),
                    (.recovery, "Erholung", "gauge.with.needle.fill", .forming, .amber, 0.45, false)
                ],
                proofItems: [
                    ("Einheiten", "4 Einheiten", .green),
                    ("Ziel", "3/3 Ziel", .green),
                    ("Abstand", "eng", .amber),
                    ("Arbeit", "mehr", .amber)
                ],
                nextMoveTitle: "Nächste Woche gleichmäßiger setzen.",
                nextMoveDetail: "Mehr ist drin, aber Rhythmus braucht Abstand.",
                nextMoveLongDetail: "STRQ soll nicht nur Fleiß sehen, sondern eine Kadenz, die wiederholbar bleibt. Nächste Woche die Einheiten besser verteilen.",
                nextMoveScope: "Nächste Woche",
                nextMoveSymbol: "calendar.badge.clock",
                proven: [
                    item("Ziel erledigt", "Die geplante Woche wurde geschafft.", "checkmark.circle.fill", .green),
                    item("Mehr Arbeit drin", "Eine Extra-Einheit liegt in der Woche.", "plus.circle.fill", .green)
                ],
                forming: [
                    item("Rhythmus noch offen", "Die Einheiten lagen zu nah beieinander.", "calendar.badge.exclamationmark", .amber),
                    item("Erholung im Blick", "Nach der Bündelung nicht blind schwer drücken.", "gauge.with.needle.fill", .amber)
                ],
                missing: [
                    item("Keine stabile Kadenz", "Eine gebündelte Woche ist noch kein Wochenrhythmus.", "circle.dashed", .gray)
                ],
                recent: [
                    item("Mo", "Einheit abgeschlossen.", "checkmark.circle.fill", .green),
                    item("Di", "Extra-Arbeit geloggt.", "plus.circle.fill", .amber),
                    item("Do", "Ziel voll gemacht.", "checkmark.seal.fill", .green)
                ]
            )

        case .volumeUp:
            return make(
                state: state,
                stateLabel: "Mehr Arbeit",
                windowLabel: "7 Tage",
                headline: "Mehr Arbeit drin.",
                explanation: "Dein geloggtes Volumen ist hochgegangen. Vor dem nächsten Push zählt Erholung.",
                mapCaption: "Volumen leuchtet. Der nächste schwere Schritt braucht Kontext.",
                accent: .amber,
                nodeSpecs: [
                    (.rhythm, "Rhythmus", "calendar", .forming, .steel, 0.6, false),
                    (.volume, "Volumen", "square.stack.3d.up.fill", .proven, .green, 0.94, true),
                    (.strength, "Kraft", "dumbbell.fill", .forming, .steel, 0.58, false),
                    (.coverage, "Abdeckung", "scope", .forming, .amber, 0.64, false),
                    (.recovery, "Erholung", "gauge.with.needle.fill", .forming, .amber, 0.42, false)
                ],
                proofItems: [
                    ("Volumen", "rauf", .green),
                    ("Einheiten", "3", .green),
                    ("Bereiche", "Push/Pull", .steel),
                    ("Check", "Erholung", .amber)
                ],
                nextMoveTitle: "Schwer nur, wenn du frisch bist.",
                nextMoveDetail: "Mehr Arbeit ist kein Freifahrtschein.",
                nextMoveLongDetail: "Wenn Erholung und Technik passen, kann ein schwererer Satz kommen. Wenn nicht, bleibt die nächste Einheit kontrolliert.",
                nextMoveScope: "Nächste Einheit",
                nextMoveSymbol: "gauge.with.needle.fill",
                proven: [
                    item("Volumen rauf", "Mehr abgeschlossene Arbeit als zuletzt.", "arrow.up.circle.fill", .green)
                ],
                forming: [
                    item("Abdeckung bildet sich", "Push und Pull sind drin, Beine bleiben im Blick.", "scope", .amber),
                    item("Kraft noch Kontext", "Mehr Arbeit heißt nicht automatisch stärker.", "dumbbell.fill", .steel)
                ],
                missing: [
                    item("Kein Versprechen", "STRQ zeigt Arbeit, keine Garantie.", "minus.circle.fill", .gray)
                ],
                recent: [
                    item("7 Tage", "Drei Einheiten abgeschlossen.", "checkmark.circle.fill", .green),
                    item("Gestern", "Mehr Gesamtarbeit geloggt.", "square.stack.3d.up.fill", .amber)
                ]
            )

        case .bestSet:
            return make(
                state: state,
                stateLabel: "Bestmarke",
                windowLabel: "Heute",
                headline: "Bestes Set geloggt.",
                explanation: "Ein Satz sticht sauber heraus. Gold bleibt für echte Bestmarken reserviert.",
                mapCaption: "Gold gehört nur auf den Satz, der wirklich zählt.",
                accent: .gold,
                nodeSpecs: [
                    (.rhythm, "Rhythmus", "calendar", .forming, .steel, 0.62, false),
                    (.volume, "Volumen", "square.stack.3d.up.fill", .forming, .steel, 0.58, false),
                    (.strength, "Kraft", "dumbbell.fill", .pr, .gold, 0.96, true),
                    (.coverage, "Abdeckung", "scope", .forming, .steel, 0.48, false),
                    (.recovery, "Erholung", "gauge.with.needle.fill", .forming, .steel, 0.55, false)
                ],
                proofItems: [
                    ("Lift", "Bankdrücken", .gold),
                    ("Set", "80 kg x 6", .gold),
                    ("Vergleich", "besser", .green),
                    ("Status", "Bestmarke", .gold)
                ],
                nextMoveTitle: "Qualität halten, dann bestätigen.",
                nextMoveDetail: "Ein starkes Set wird wertvoller, wenn es wiederkommt.",
                nextMoveLongDetail: "Nicht jeden Satz vergolden. Halte Technik und Wiederholungen stabil, dann kann die Bestmarke zur echten Stärke-Story werden.",
                nextMoveScope: "Nächste Einheit",
                nextMoveSymbol: "star.circle.fill",
                proven: [
                    item("Bestes Set steht", "Der Satz ist besser als die passende Historie.", "star.circle.fill", .gold)
                ],
                forming: [
                    item("Kraft bildet sich", "Ein Satz ist stark, der Trend braucht Wiederholung.", "dumbbell.fill", .steel)
                ],
                missing: [
                    item("Keine 1RM-Sicherheit", "STRQ macht daraus keinen sicheren Max-Wert.", "lock.fill", .gray)
                ],
                recent: [
                    item("Heute", "Bankdrücken 80 kg x 6 geloggt.", "star.circle.fill", .gold)
                ]
            )

        case .recoveryLow:
            return make(
                state: state,
                stateLabel: "Leichter",
                windowLabel: "Heute",
                headline: "Heute leichter.",
                explanation: "Der Kontext spricht gegen einen harten Push. Training geht, aber nicht auf Anschlag.",
                mapCaption: "Rot bleibt lokal: nur Erholung begrenzt den Push.",
                accent: .red,
                nodeSpecs: [
                    (.rhythm, "Rhythmus", "calendar", .forming, .steel, 0.6, false),
                    (.volume, "Volumen", "square.stack.3d.up.fill", .forming, .amber, 0.5, false),
                    (.strength, "Kraft", "dumbbell.fill", .locked, .gray, 0.24, false),
                    (.coverage, "Abdeckung", "scope", .forming, .steel, 0.48, false),
                    (.recovery, "Erholung", "gauge.with.needle.fill", .forming, .red, 0.34, true)
                ],
                proofItems: [
                    ("Erholung", "niedrig", .red),
                    ("Gewicht", "zuletzt hoch", .amber),
                    ("Schlaf", "kurz", .amber),
                    ("Push", "begrenzen", .red)
                ],
                nextMoveTitle: "Gewicht runter, Technik sauber.",
                nextMoveDetail: "Trainieren ja, Anschlag nein.",
                nextMoveLongDetail: "STRQ sagt nicht, dass etwas medizinisch falsch ist. Es schützt nur den nächsten harten Push vor schlechtem Kontext.",
                nextMoveScope: "Heute",
                nextMoveSymbol: "arrow.down.circle.fill",
                proven: [
                    item("Training möglich", "Die Einheit muss nicht ausfallen.", "checkmark.circle.fill", .green)
                ],
                forming: [
                    item("Push begrenzen", "Erholung und letzte Arbeit sprechen für leichter.", "gauge.with.needle.fill", .red)
                ],
                missing: [
                    item("Keine Diagnose", "STRQ bewertet keinen Körperzustand medizinisch.", "cross.case.fill", .gray),
                    item("Keine Bestmarke heute", "Gold bleibt aus dem Fokus.", "star.slash.fill", .gray)
                ],
                recent: [
                    item("Zuletzt", "Hohes Gewicht geloggt.", "dumbbell.fill", .amber),
                    item("Heute", "Schlaf kurz im Kontext.", "moon.zzz.fill", .amber)
                ]
            )

        case .deloadWeek:
            return make(
                state: state,
                stateLabel: "Deload",
                windowLabel: "Woche",
                headline: "Absichtlich rausnehmen.",
                explanation: "Diese Woche soll Arbeit ankommen, nicht neue Härte beweisen.",
                mapCaption: "Weniger Druck ist hier der Plan, nicht ein Rückschritt.",
                accent: .steel,
                nodeSpecs: [
                    (.rhythm, "Rhythmus", "calendar", .proven, .green, 0.74, true),
                    (.volume, "Volumen", "square.stack.3d.up.fill", .forming, .amber, 0.42, false),
                    (.strength, "Kraft", "dumbbell.fill", .locked, .gray, 0.22, false),
                    (.coverage, "Abdeckung", "scope", .forming, .steel, 0.5, false),
                    (.recovery, "Erholung", "gauge.with.needle.fill", .proven, .steel, 0.72, false)
                ],
                proofItems: [
                    ("Volumen", "runter", .amber),
                    ("Rhythmus", "bleibt", .green),
                    ("Fokus", "Qualität", .steel),
                    ("PR", "kein Fokus", .gray)
                ],
                nextMoveTitle: "Sauber bewegen, Druck raus.",
                nextMoveDetail: "Deload ist Arbeit mit Absicht.",
                nextMoveLongDetail: "Halte Bewegungen sauber und lass das Volumen unten. Diese Woche muss nichts bewiesen werden.",
                nextMoveScope: "Diese Woche",
                nextMoveSymbol: "pause.circle.fill",
                proven: [
                    item("Rhythmus bleibt", "Du trainierst weiter, nur kontrollierter.", "calendar", .green)
                ],
                forming: [
                    item("Erholung bekommt Platz", "Weniger Volumen ist diese Woche gewollt.", "gauge.with.needle.fill", .steel)
                ],
                missing: [
                    item("Keine Bestmarken-Jagd", "Starke Sets sind nicht Ziel dieser Woche.", "star.slash.fill", .gray)
                ],
                recent: [
                    item("Diese Woche", "Volumen bewusst gesenkt.", "arrow.down.circle.fill", .amber)
                ]
            )

        case .plateau:
            return make(
                state: state,
                stateLabel: "Hängt",
                windowLabel: "3 Versuche",
                headline: "Der Lift hängt.",
                explanation: "Der gleiche Bereich wiederholt sich. Der nächste Schritt ist kleiner, nicht härter.",
                mapCaption: "Die Kraft-Node wartet auf eine feinere Anpassung.",
                accent: .amber,
                nodeSpecs: [
                    (.rhythm, "Rhythmus", "calendar", .proven, .green, 0.72, false),
                    (.volume, "Volumen", "square.stack.3d.up.fill", .forming, .steel, 0.58, false),
                    (.strength, "Kraft", "dumbbell.fill", .forming, .amber, 0.48, true),
                    (.coverage, "Abdeckung", "scope", .forming, .amber, 0.52, false),
                    (.recovery, "Erholung", "gauge.with.needle.fill", .forming, .steel, 0.6, false)
                ],
                proofItems: [
                    ("Versuche", "3", .amber),
                    ("Gewicht", "gehalten", .steel),
                    ("Sprung", "unklar", .amber),
                    ("Hebel", "ändern", .amber)
                ],
                nextMoveTitle: "Wdh., Gewicht oder Pause fein anpassen.",
                nextMoveDetail: "Nicht härter erzwingen, kleiner drehen.",
                nextMoveLongDetail: "Ein Plateau braucht keinen Schuldtext. Passe einen Hebel an und gib STRQ einen saubereren Vergleich.",
                nextMoveScope: "Nächste Einheit",
                nextMoveSymbol: "slider.horizontal.3",
                proven: [
                    item("Rhythmus steht", "Du hast den Lift wiederholt.", "calendar", .green)
                ],
                forming: [
                    item("Kraft hängt", "Drei ähnliche Versuche ohne klaren Sprung.", "dumbbell.fill", .amber)
                ],
                missing: [
                    item("Keine Ursache behaupten", "STRQ kennt nicht automatisch den Grund.", "questionmark.circle.fill", .gray)
                ],
                recent: [
                    item("3 Versuche", "Gewicht gehalten, kein klarer Sprung.", "equal.circle.fill", .amber)
                ]
            )

        case .comebackWeek:
            return make(
                state: state,
                stateLabel: "Comeback",
                windowLabel: "Nach Pause",
                headline: "Wieder drin.",
                explanation: "Nach der Pause zählt ein sauberer Einstieg mehr als ein harter Sprung.",
                mapCaption: "Der Read baut neu auf. Der Einstieg zählt.",
                accent: .amber,
                nodeSpecs: [
                    (.rhythm, "Rhythmus", "calendar", .forming, .amber, 0.36, true),
                    (.volume, "Volumen", "square.stack.3d.up.fill", .forming, .steel, 0.34, false),
                    (.strength, "Kraft", "dumbbell.fill", .locked, .gray, 0.2, false),
                    (.coverage, "Abdeckung", "scope", .forming, .amber, 0.3, false),
                    (.recovery, "Erholung", "gauge.with.needle.fill", .forming, .steel, 0.58, false)
                ],
                proofItems: [
                    ("Pause", "beendet", .green),
                    ("Einheiten", "1 drin", .green),
                    ("Gewicht", "vorsichtig", .steel),
                    ("Read", "baut auf", .amber)
                ],
                nextMoveTitle: "Zweite Einheit ruhig setzen.",
                nextMoveDetail: "Erst Rhythmus, dann Druck.",
                nextMoveLongDetail: "Die Pause wird nicht bewertet. Jetzt zählt, dass eine zweite Einheit den Wiedereinstieg stabil macht.",
                nextMoveScope: "Diese Woche",
                nextMoveSymbol: "arrow.uturn.forward.circle.fill",
                proven: [
                    item("Pause beendet", "Eine Einheit ist wieder im Log.", "checkmark.circle.fill", .green)
                ],
                forming: [
                    item("Rhythmus baut neu auf", "Der zweite Termin macht das Comeback stabiler.", "calendar", .amber)
                ],
                missing: [
                    item("Alte Stärke nicht behaupten", "Nach der Pause braucht Kraft neue Belege.", "lock.fill", .gray)
                ],
                recent: [
                    item("Heute", "Erste Einheit nach Pause abgeschlossen.", "figure.strengthtraining.traditional", .green)
                ]
            )

        case .consistentRhythm:
            return make(
                state: state,
                stateLabel: "Rhythmus",
                windowLabel: "4 Wochen",
                headline: "Der Rhythmus steht.",
                explanation: "Die Einheiten wiederholen sich über mehrere Wochen. Jetzt kannst du gezielt drücken.",
                mapCaption: "Der Rhythmus ist grün. Jetzt darf ein Hebel nach oben.",
                accent: .green,
                nodeSpecs: [
                    (.rhythm, "Rhythmus", "calendar", .proven, .green, 0.96, true),
                    (.volume, "Volumen", "square.stack.3d.up.fill", .proven, .green, 0.78, false),
                    (.strength, "Kraft", "dumbbell.fill", .forming, .steel, 0.64, false),
                    (.coverage, "Abdeckung", "scope", .forming, .amber, 0.68, false),
                    (.recovery, "Erholung", "gauge.with.needle.fill", .forming, .steel, 0.62, false)
                ],
                proofItems: [
                    ("Fenster", "4 Wochen", .green),
                    ("Ziel", "oft getroffen", .green),
                    ("Abstand", "sauber", .green),
                    ("Push", "gezielt", .steel)
                ],
                nextMoveTitle: "Einen Hebel gezielt pushen.",
                nextMoveDetail: "Rhythmus steht, jetzt nicht alles auf einmal.",
                nextMoveLongDetail: "Wähle einen Trainingshebel: mehr Gewicht, mehr Wiederholungen oder bessere Abdeckung. Der Rest bleibt stabil.",
                nextMoveScope: "Nächste Einheit",
                nextMoveSymbol: "arrow.up.circle.fill",
                proven: [
                    item("Rhythmus steht", "Mehrere Wochen wiederholt geloggt.", "checkmark.seal.fill", .green),
                    item("Ziel oft getroffen", "Die Woche ist keine Ausnahme mehr.", "calendar", .green)
                ],
                forming: [
                    item("Kraft kann folgen", "Ein gezielter Push ist sinnvoll, aber nicht garantiert.", "dumbbell.fill", .steel)
                ],
                missing: [
                    item("Abdeckung noch nicht komplett", "Einige Bereiche bleiben im Blick.", "scope", .gray)
                ],
                recent: [
                    item("4 Wochen", "Kadenz sauber wiederholt.", "repeat.circle.fill", .green)
                ]
            )

        case .muscleCoverageForming:
            return make(
                state: state,
                stateLabel: "Abdeckung",
                windowLabel: "Woche",
                headline: "Abdeckung bildet sich.",
                explanation: "Einige Bereiche haben genug Arbeit gesehen. Andere brauchen noch die nächste Einheit.",
                mapCaption: "Breite Bereiche, keine Prozentwerte und keine Balance-Behauptung.",
                accent: .amber,
                nodeSpecs: [
                    (.rhythm, "Rhythmus", "calendar", .forming, .steel, 0.58, false),
                    (.volume, "Volumen", "square.stack.3d.up.fill", .forming, .steel, 0.56, false),
                    (.strength, "Kraft", "dumbbell.fill", .forming, .steel, 0.42, false),
                    (.coverage, "Abdeckung", "scope", .forming, .amber, 0.66, true),
                    (.recovery, "Erholung", "gauge.with.needle.fill", .forming, .steel, 0.58, false)
                ],
                proofItems: [
                    ("Push", "steht", .green),
                    ("Pull", "bildet sich", .amber),
                    ("Beine", "offen", .gray),
                    ("Balance", "keine %", .gray)
                ],
                nextMoveTitle: "Offenen Bereich einplanen.",
                nextMoveDetail: "Breiter trainieren, nicht Prozenten jagen.",
                nextMoveLongDetail: "STRQ zeigt nur grobe Abdeckung. Plane den offenen Bereich ein, ohne daraus eine exakte Balance-Zahl zu machen.",
                nextMoveScope: "Nächste Einheit",
                nextMoveSymbol: "scope",
                proven: [
                    item("Push steht", "Genug Arbeit für diesen Bereich in der Woche.", "checkmark.circle.fill", .green)
                ],
                forming: [
                    item("Pull bildet sich", "Eine weitere Zug-Einheit macht die Abdeckung runder.", "arrow.left.arrow.right.circle.fill", .amber)
                ],
                missing: [
                    item("Beine offen", "Noch nicht genug abgeschlossene Arbeit.", "circle.dashed", .gray),
                    item("Keine Prozentwerte", "STRQ macht daraus keine Prozent-Zahl.", "number.circle.fill", .gray)
                ],
                recent: [
                    item("Mo", "Push-Bereich abgedeckt.", "checkmark.circle.fill", .green),
                    item("Mi", "Pull gestartet.", "circle.lefthalf.filled", .amber)
                ]
            )
        }
    }

    private static func make(
        state: ProgressTrainingMapDemoState,
        stateLabel: String,
        windowLabel: String,
        headline: String,
        explanation: String,
        mapCaption: String,
        accent: ProgressTrainingMapAccent,
        nodeSpecs: [(TrainingMapNodeKind, String, String, TrainingMapNodeState, ProgressTrainingMapAccent, CGFloat, Bool)],
        proofItems: [(String, String, ProgressTrainingMapAccent)],
        nextMoveTitle: String,
        nextMoveDetail: String,
        nextMoveLongDetail: String,
        nextMoveScope: String,
        nextMoveSymbol: String,
        proven: [ProgressTrainingMapEvidenceItem],
        forming: [ProgressTrainingMapEvidenceItem],
        missing: [ProgressTrainingMapEvidenceItem],
        recent: [ProgressTrainingMapEvidenceItem]
    ) -> ProgressTrainingMapScenario {
        ProgressTrainingMapScenario(
            state: state,
            stateLabel: stateLabel,
            windowLabel: windowLabel,
            headline: headline,
            explanation: explanation,
            mapCaption: mapCaption,
            accent: accent,
            nodes: nodeSpecs.enumerated().map { index, spec in
                TrainingMapNode(
                    kind: spec.0,
                    title: spec.1,
                    symbol: spec.2,
                    nodeState: spec.3,
                    accent: spec.4,
                    progress: spec.5,
                    primary: spec.6,
                    delay: Double(index) * 0.035
                )
            },
            proofItems: proofItems.map { ProgressTrainingMapProofItem(label: $0.0, value: $0.1, accent: $0.2) },
            nextMoveTitle: nextMoveTitle,
            nextMoveDetail: nextMoveDetail,
            nextMoveLongDetail: nextMoveLongDetail,
            nextMoveScope: nextMoveScope,
            nextMoveSymbol: nextMoveSymbol,
            provenItems: proven,
            formingItems: forming,
            missingItems: missing,
            recentEvidence: recent
        )
    }

    private static func item(
        _ title: String,
        _ detail: String,
        _ symbol: String,
        _ accent: ProgressTrainingMapAccent
    ) -> ProgressTrainingMapEvidenceItem {
        ProgressTrainingMapEvidenceItem(title: title, detail: detail, symbol: symbol, accent: accent)
    }
}

private struct ProgressTrainingMapPrototypeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProgressTrainingMapPrototypeView(isFullscreen: true)
                .previewDisplayName("Progress Training Map Prototype")
        }
    }
}
#endif
