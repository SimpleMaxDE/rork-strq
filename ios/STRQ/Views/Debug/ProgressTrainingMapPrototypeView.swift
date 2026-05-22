import SwiftUI

#if DEBUG
struct ProgressTrainingMapPrototypeView: View {
    let isFullscreen: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedState: ProgressPathDemoState
    @State private var presentationMode: Bool
    @State private var appeared = false

    init(isFullscreen: Bool = false) {
        self.isFullscreen = isFullscreen
        _selectedState = State(initialValue: ProgressPathDemoState.launchArgumentState ?? .targetOverhit)
        _presentationMode = State(initialValue: ProcessInfo.processInfo.arguments.contains("-STRQProgressPathPresentation"))
    }

    private var scenario: ProgressPathScenario {
        selectedState.scenario
    }

    private var revealAnimation: Animation {
        reduceMotion ? .easeOut(duration: 0.08) : .spring(response: 0.42, dampingFraction: 0.86)
    }

    var body: some View {
        ZStack {
            ProgressPathStyle.background.ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        header
                            .id(ProgressPathScrollTarget.top)
                        firstViewport
                        lowerScroll
                            .id(ProgressPathScrollTarget.lower)
                    }
                    .frame(maxWidth: 430)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 14)
                    .padding(.top, isFullscreen ? 18 : 14)
                    .padding(.bottom, isFullscreen ? 34 : 18)
                }
                .scrollContentBackground(.hidden)
                .onChange(of: selectedState) { _, _ in
                    if reduceMotion {
                        proxy.scrollTo(ProgressPathScrollTarget.top, anchor: .top)
                    } else {
                        withAnimation(.easeInOut(duration: 0.22)) {
                            proxy.scrollTo(ProgressPathScrollTarget.top, anchor: .top)
                        }
                    }
                    reveal()
                }
            }

            if isFullscreen {
                topStatusScrim
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            guard !appeared else { return }
            reveal()
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Progress")
                    .font(.system(size: 26, weight: .black, design: .rounded))
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)

                Text("Training Path")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(ProgressPathStyle.steel)
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            headerControls
        }
        .padding(.top, isFullscreen ? 6 : 0)
        .accessibilityIdentifier("progress-path-header")
    }

    private var headerControls: some View {
        HStack(spacing: 7) {
            if !presentationMode {
                debugStateMenu
            }

            Button {
                if reduceMotion {
                    presentationMode.toggle()
                } else {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        presentationMode.toggle()
                    }
                }
            } label: {
                Image(systemName: presentationMode ? "slider.horizontal.3" : "eye")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(presentationMode ? STRQColors.secondaryText : STRQColors.mutedText)
                    .frame(width: 30, height: 30)
                    .background(STRQColors.white.opacity(presentationMode ? 0.045 : 0.035), in: Circle())
                    .overlay(Circle().strokeBorder(STRQColors.white.opacity(0.08), lineWidth: 1))
            }
            .buttonStyle(.plain)
            .accessibilityLabel(presentationMode ? "Show debug controls" : "Hide debug controls")
            .accessibilityIdentifier("progress-path-presentation-toggle")

            if isFullscreen {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(STRQColors.primaryText)
                        .frame(width: 32, height: 32)
                        .background(STRQColors.white.opacity(0.08), in: Circle())
                        .overlay(Circle().strokeBorder(STRQColors.white.opacity(0.14), lineWidth: 1))
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("progress-training-map-close")
            }
        }
        .accessibilityIdentifier("progress-path-debug-controls")
    }

    private var debugStateMenu: some View {
        Menu {
            ForEach(ProgressPathDemoState.allCases) { state in
                Button {
                    selectState(state)
                } label: {
                    if selectedState == state {
                        Label(state.switcherTitle, systemImage: "checkmark")
                    } else {
                        Text(state.switcherTitle)
                    }
                }
            }
        } label: {
            Image(systemName: "list.bullet")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(scenario.accent.readableText)
                .frame(width: 30, height: 30)
                .background(scenario.accent.color.opacity(0.1), in: Circle())
                .overlay(Circle().strokeBorder(scenario.accent.color.opacity(0.24), lineWidth: 1))
        }
        .accessibilityLabel("Debug state: \(selectedState.switcherTitle)")
        .accessibilityIdentifier("progress-path-state-switcher")
    }

    private func selectState(_ state: ProgressPathDemoState) {
        if reduceMotion {
            selectedState = state
        } else {
            withAnimation(.easeInOut(duration: 0.18)) {
                selectedState = state
            }
        }
    }

    private var firstViewport: some View {
        VStack(alignment: .leading, spacing: 10) {
            hero
            ProgressPathVisual(scenario: scenario, appeared: appeared, reduceMotion: reduceMotion)
            proofStrip
            ProgressPathNextMoveCard(scenario: scenario, compact: true)
        }
        .padding(12)
        .background(ProgressPathStyle.heroSurface, in: .rect(cornerRadius: 22))
        .overlay(alignment: .topLeading) {
            Rectangle()
                .fill(scenario.accent.color)
                .frame(width: 96, height: 3)
                .padding(.leading, 18)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(scenario.accent.color.opacity(0.18), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0.9)
        .scaleEffect(appeared || reduceMotion ? 1 : 0.985)
        .animation(revealAnimation, value: appeared)
        .accessibilityIdentifier("progress-path-first-viewport")
    }

    private var hero: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(scenario.headline)
                .font(.system(size: 27, weight: .black, design: .rounded))
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.68)
                .fixedSize(horizontal: false, vertical: true)

            Text(scenario.subline)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(STRQColors.secondaryText)
                .lineSpacing(2)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var proofStrip: some View {
        HStack(spacing: 7) {
            ForEach(scenario.proofItems) { item in
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.value)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(item.tone.color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                    Text(item.label)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(STRQColors.mutedText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.68)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(ProgressPathStyle.tileSurface, in: .rect(cornerRadius: 11))
                .overlay(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .strokeBorder(item.tone.color.opacity(0.15), lineWidth: 1)
                )
            }
        }
        .accessibilityIdentifier("progress-path-proof-strip")
    }

    private var lowerScroll: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProgressPathSection(title: "Confirmed", items: scenario.confirmed, defaultTone: .green)
            ProgressPathSection(title: "Building", items: scenario.building, defaultTone: .amber)
            ProgressPathSection(title: "Needs More", items: scenario.needsMore, defaultTone: .gray)
            ProgressPathRecentWorkSection(items: scenario.recentWork)
            ProgressPathNextMoveDetail(scenario: scenario)
        }
        .accessibilityIdentifier("progress-path-lower-scroll")
    }

    private var topStatusScrim: some View {
        VStack {
            LinearGradient(
                colors: [
                    ProgressPathStyle.background,
                    ProgressPathStyle.background.opacity(0.96),
                    ProgressPathStyle.background.opacity(0)
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

    private func reveal() {
        if reduceMotion {
            appeared = true
            return
        }

        appeared = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            withAnimation(revealAnimation) {
                appeared = true
            }
        }
    }
}

private enum ProgressPathScrollTarget {
    case top
    case lower
}

private struct ProgressPathVisual: View {
    let scenario: ProgressPathScenario
    let appeared: Bool
    let reduceMotion: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(scenario.path.title)
                        .font(.system(size: 14, weight: .black, design: .rounded))
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(1)
                    Text(scenario.path.summary)
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 6)

                Text(scenario.path.window)
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(scenario.accent.readableText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(scenario.accent.color.opacity(0.11), in: Capsule())
                    .overlay(Capsule().strokeBorder(scenario.accent.color.opacity(0.2), lineWidth: 1))
            }

            ZStack {
                GeometryReader { proxy in
                    let midY = max(proxy.size.height * 0.42, 26)
                    Path { path in
                        path.move(to: CGPoint(x: 20, y: midY))
                        path.addLine(to: CGPoint(x: max(proxy.size.width - 20, 20), y: midY))
                    }
                    .trim(from: 0, to: appeared || reduceMotion ? 1 : 0.08)
                    .stroke(STRQColors.white.opacity(0.1), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.34), value: appeared)
                }

                HStack(alignment: .top, spacing: 0) {
                    ForEach(Array(scenario.path.items.enumerated()), id: \.element.id) { index, item in
                        ProgressPathDotView(
                            item: item,
                            appeared: appeared,
                            reduceMotion: reduceMotion,
                            delay: Double(index) * 0.035
                        )
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(height: scenario.path.items.count > 4 ? 94 : 84)
        }
        .padding(11)
        .background(ProgressPathStyle.pathSurface, in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(STRQColors.white.opacity(0.08), lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(scenario.path.accessibilitySummary))
    }
}

private struct ProgressPathDotView: View {
    let item: ProgressPathItem
    let appeared: Bool
    let reduceMotion: Bool
    let delay: Double

    private var dotSize: CGFloat {
        item.emphasized ? 30 : 25
    }

    var body: some View {
        VStack(spacing: 5) {
            Text(item.topLabel)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.64)

            ZStack {
                Circle()
                    .fill(item.filled ? item.tone.color.opacity(0.18) : ProgressPathStyle.emptyDot)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                item.tone.color.opacity(item.filled ? 0.78 : 0.34),
                                style: StrokeStyle(lineWidth: item.emphasized ? 2 : 1.2, dash: item.filled ? [] : [4, 4])
                            )
                    )

                Image(systemName: item.symbol)
                    .font(.system(size: item.emphasized ? 12 : 10, weight: .black))
                    .foregroundStyle(item.filled ? item.tone.color : item.tone.color.opacity(0.82))
                    .accessibilityHidden(true)

                if item.tone == .gold && !reduceMotion {
                    Circle()
                        .stroke(ProgressPathStyle.gold.opacity(0.38), lineWidth: 1)
                        .scaleEffect(appeared ? 1.28 : 0.88)
                        .opacity(appeared ? 0 : 0.7)
                        .animation(.easeOut(duration: 0.55).delay(delay + 0.12), value: appeared)
                }
            }
            .frame(width: dotSize, height: dotSize)
            .scaleEffect(appeared || reduceMotion ? 1 : 0.72)
            .opacity(appeared || reduceMotion ? 1 : 0.35)
            .shadow(color: item.tone.color.opacity(item.emphasized ? 0.2 : 0), radius: 8, y: 4)
            .animation(reduceMotion ? nil : .spring(response: 0.34, dampingFraction: 0.76).delay(delay), value: appeared)

            Text(item.bottomLabel)
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(item.tone == .gray ? STRQColors.mutedText : STRQColors.secondaryText)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.62)
                .frame(minHeight: 22, alignment: .top)
        }
        .padding(.horizontal, 1)
    }
}

private struct ProgressPathNextMoveCard: View {
    let scenario: ProgressPathScenario
    let compact: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: scenario.nextMoveSymbol)
                .font(.system(size: compact ? 16 : 17, weight: .black))
                .foregroundStyle(scenario.accent.color)
                .frame(width: compact ? 40 : 44, height: compact ? 40 : 44)
                .background(scenario.accent.color.opacity(0.13), in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text("Next Move")
                    .font(.system(size: 10, weight: .black, design: .rounded))
                    .foregroundStyle(STRQColors.mutedText)
                    .lineLimit(1)

                Text(scenario.nextMove)
                    .font(.system(size: compact ? 15 : 16, weight: .black, design: .rounded))
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.76)
                    .fixedSize(horizontal: false, vertical: true)

                if !compact {
                    Text(scenario.nextMoveDetail)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(ProgressPathStyle.nextMoveSurface, in: .rect(cornerRadius: 15))
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .strokeBorder(scenario.accent.color.opacity(0.2), lineWidth: 1)
        )
        .accessibilityIdentifier("progress-path-next-move")
    }
}

private struct ProgressPathSection: View {
    let title: String
    let items: [ProgressPathDetailItem]
    let defaultTone: ProgressPathTone

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProgressPathSectionTitle(title: title, tone: defaultTone)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: 8)], alignment: .leading, spacing: 8) {
                ForEach(items) { item in
                    ProgressPathDetailCard(item: item)
                }
            }
        }
        .accessibilityIdentifier("progress-path-section-\(title.lowercased().replacingOccurrences(of: " ", with: "-"))")
    }
}

private struct ProgressPathSectionTitle: View {
    let title: String
    let tone: ProgressPathTone

    var body: some View {
        HStack(spacing: 7) {
            Circle()
                .fill(tone.color)
                .frame(width: 7, height: 7)
            Text(title)
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 2)
    }
}

private struct ProgressPathDetailCard: View {
    let item: ProgressPathDetailItem

    var body: some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: item.symbol)
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(item.tone.color)
                .frame(width: 28, height: 28)
                .background(item.tone.color.opacity(0.12), in: .rect(cornerRadius: 8))

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
        .frame(maxWidth: .infinity, minHeight: 64, alignment: .topLeading)
        .background(ProgressPathStyle.sectionSurface, in: .rect(cornerRadius: 13))
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .strokeBorder(STRQColors.white.opacity(0.07), lineWidth: 1)
        )
    }
}

private struct ProgressPathRecentWorkSection: View {
    let items: [ProgressPathDetailItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProgressPathSectionTitle(title: "Recent Work", tone: .steel)

            VStack(spacing: 7) {
                ForEach(items) { item in
                    HStack(spacing: 9) {
                        Image(systemName: item.symbol)
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(item.tone.color)
                            .frame(width: 28, height: 28)
                            .background(item.tone.color.opacity(0.12), in: .rect(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 1) {
                            Text(item.title)
                                .font(.system(size: 13, weight: .black, design: .rounded))
                                .foregroundStyle(STRQColors.primaryText)
                                .lineLimit(1)
                            Text(item.detail)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundStyle(STRQColors.secondaryText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.74)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(9)
                    .background(ProgressPathStyle.sectionSurface, in: .rect(cornerRadius: 13))
                    .overlay(
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .strokeBorder(STRQColors.white.opacity(0.07), lineWidth: 1)
                    )
                }
            }
        }
        .accessibilityIdentifier("progress-path-section-recent-work")
    }
}

private struct ProgressPathNextMoveDetail: View {
    let scenario: ProgressPathScenario

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProgressPathSectionTitle(title: "Next Move", tone: scenario.accent)
            ProgressPathNextMoveCard(scenario: scenario, compact: false)
        }
        .accessibilityIdentifier("progress-path-section-next-move")
    }
}

private enum ProgressPathDemoState: String, CaseIterable, Identifiable {
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
        case .lowData: return "Low Data"
        case .normalWeek: return "Normal"
        case .targetHit: return "Hit"
        case .targetOverhit: return "Clustered"
        case .volumeUp: return "Volume"
        case .bestSet: return "Best Set"
        case .recoveryLow: return "Recovery"
        case .deloadWeek: return "Deload"
        case .plateau: return "Plateau"
        case .comebackWeek: return "Comeback"
        case .consistentRhythm: return "Rhythm"
        case .muscleCoverageForming: return "Coverage"
        }
    }

    static var launchArgumentState: ProgressPathDemoState? {
        let arguments = ProcessInfo.processInfo.arguments
        guard let flagIndex = arguments.firstIndex(of: "-STRQProgressPathState"),
              arguments.indices.contains(arguments.index(after: flagIndex)) else {
            return nil
        }

        let value = arguments[arguments.index(after: flagIndex)]
        return ProgressPathDemoState(rawValue: value)
    }

    var scenario: ProgressPathScenario {
        ProgressPathScenarioFactory.scenario(for: self)
    }
}

private struct ProgressPathScenario: Identifiable {
    let state: ProgressPathDemoState
    let headline: String
    let subline: String
    let accent: ProgressPathTone
    let path: ProgressPathData
    let proofItems: [ProgressPathProofItem]
    let nextMove: String
    let nextMoveDetail: String
    let nextMoveSymbol: String
    let confirmed: [ProgressPathDetailItem]
    let building: [ProgressPathDetailItem]
    let needsMore: [ProgressPathDetailItem]
    let recentWork: [ProgressPathDetailItem]

    var id: String { state.rawValue }
}

private struct ProgressPathData {
    let title: String
    let summary: String
    let window: String
    let items: [ProgressPathItem]

    var accessibilitySummary: String {
        ([title, summary] + items.map { "\($0.topLabel), \($0.bottomLabel)" }).joined(separator: ", ")
    }
}

private struct ProgressPathItem: Identifiable {
    let id = UUID()
    let topLabel: String
    let bottomLabel: String
    let symbol: String
    let tone: ProgressPathTone
    let filled: Bool
    let emphasized: Bool
}

private struct ProgressPathProofItem: Identifiable {
    let id = UUID()
    let value: String
    let label: String
    let tone: ProgressPathTone
}

private struct ProgressPathDetailItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let symbol: String
    let tone: ProgressPathTone
}

private enum ProgressPathTone: Equatable {
    case green
    case amber
    case gold
    case red
    case steel
    case gray

    var color: Color {
        switch self {
        case .green: return ProgressPathStyle.green
        case .amber: return ProgressPathStyle.amber
        case .gold: return ProgressPathStyle.gold
        case .red: return ProgressPathStyle.red
        case .steel: return ProgressPathStyle.steel
        case .gray: return ProgressPathStyle.gray
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

private enum ProgressPathStyle {
    static let background = Color(red: 0.018, green: 0.019, blue: 0.023)
    static let heroSurface = Color(red: 0.052, green: 0.055, blue: 0.064)
    static let sectionSurface = Color(red: 0.047, green: 0.050, blue: 0.058)
    static let pathSurface = Color(red: 0.028, green: 0.031, blue: 0.038)
    static let tileSurface = Color.white.opacity(0.045)
    static let nextMoveSurface = Color.white.opacity(0.06)
    static let emptyDot = Color.white.opacity(0.055)
    static let green = STRQPalette.signalGreen
    static let amber = STRQPalette.warningAmber
    static let gold = STRQPalette.gold
    static let red = STRQPalette.dangerRed
    static let steel = Color(red: 0.56, green: 0.68, blue: 0.78)
    static let gray = STRQColors.gray500
}

private enum ProgressPathScenarioFactory {
    static func scenario(for state: ProgressPathDemoState) -> ProgressPathScenario {
        switch state {
        case .lowData:
            return make(
                state: state,
                headline: "Progress starts here.",
                subline: "One workout is in. Keep logging to build a clearer trend.",
                accent: .gray,
                path: weekPath(
                    summary: "One workout starts the week.",
                    window: "Week 1",
                    items: [
                        day("Mon", "Logged", "checkmark", .green, true, true),
                        day("Tue", "Rest", "moon.fill", .gray, false),
                        day("Wed", "Open", "circle", .gray, false),
                        day("Thu", "Open", "circle", .gray, false),
                        day("Fri", "Next", "plus", .amber, false, true),
                        day("Sat", "Open", "circle", .gray, false),
                        day("Sun", "Open", "circle", .gray, false)
                    ]
                ),
                proof: [
                    proof("1", "Workout", .green),
                    proof("First", "Log", .green),
                    proof("More", "Logs", .gray),
                    proof("Next", "Workout", .amber)
                ],
                nextMove: "Log the next workout.",
                nextMoveDetail: "One more clean log gives Progress something to compare.",
                nextMoveSymbol: "plus.circle.fill",
                confirmed: [
                    item("First workout", "A real session is in.", "checkmark.circle.fill", .green)
                ],
                building: [
                    item("Weekly rhythm", "Too early, but started.", "calendar", .amber),
                    item("Exercise history", "Comparable sets come next.", "dumbbell.fill", .amber)
                ],
                needsMore: [
                    item("Best sets", "No fair comparison yet.", "star.slash.fill", .gray),
                    item("Coverage", "More areas need work.", "circle.dashed", .gray)
                ],
                recent: [
                    item("Mon", "Full body logged.", "figure.strengthtraining.traditional", .green)
                ]
            )

        case .normalWeek:
            return make(
                state: state,
                headline: "Rhythm is building.",
                subline: "Two sessions are spaced well. One workout is still open.",
                accent: .amber,
                path: weekPath(
                    summary: "Good spacing, one session left.",
                    window: "This week",
                    items: [
                        day("Mon", "Push", "checkmark", .green, true),
                        day("Tue", "Rest", "moon.fill", .gray, false),
                        day("Wed", "Legs", "checkmark", .green, true),
                        day("Thu", "Rest", "moon.fill", .gray, false),
                        day("Fri", "Next", "arrow.right", .amber, false, true),
                        day("Sat", "Open", "circle", .gray, false),
                        day("Sun", "Open", "circle", .gray, false)
                    ]
                ),
                proof: [
                    proof("2", "Workouts", .green),
                    proof("1", "Left", .amber),
                    proof("Good", "Spacing", .steel),
                    proof("Building", "Coverage", .amber)
                ],
                nextMove: "Hold the planned session.",
                nextMoveDetail: "No extra work needed. Finish the week clean.",
                nextMoveSymbol: "arrow.right.circle.fill",
                confirmed: [
                    item("Work done", "Two sessions are logged.", "checkmark.circle.fill", .green)
                ],
                building: [
                    item("Rhythm", "Spacing looks useful.", "calendar", .amber),
                    item("Coverage", "The next session rounds it out.", "scope", .amber)
                ],
                needsMore: [
                    item("Week close", "One planned session remains.", "circle.dashed", .gray)
                ],
                recent: [
                    item("Mon", "Push logged.", "checkmark.circle.fill", .green),
                    item("Wed", "Legs logged.", "checkmark.circle.fill", .green)
                ]
            )

        case .targetHit:
            return make(
                state: state,
                headline: "You hit the week.",
                subline: "All planned workouts are done. Now repeat the spacing.",
                accent: .green,
                path: weekPath(
                    summary: "Three planned sessions landed cleanly.",
                    window: "3 of 3",
                    items: [
                        day("Mon", "Push", "checkmark", .green, true),
                        day("Tue", "Rest", "moon.fill", .gray, false),
                        day("Wed", "Pull", "checkmark", .green, true),
                        day("Thu", "Rest", "moon.fill", .gray, false),
                        day("Fri", "Legs", "checkmark", .green, true, true),
                        day("Sat", "Rest", "moon.fill", .gray, false),
                        day("Sun", "Open", "circle", .gray, false)
                    ]
                ),
                proof: [
                    proof("3", "Workouts", .green),
                    proof("3/3", "Target", .green),
                    proof("Good", "Spacing", .green),
                    proof("Repeat", "Next", .steel)
                ],
                nextMove: "Repeat the week with the same spacing.",
                nextMoveDetail: "Do not add more just to add more.",
                nextMoveSymbol: "repeat.circle.fill",
                confirmed: [
                    item("Target hit", "All planned sessions are done.", "checkmark.seal.fill", .green),
                    item("Spacing held", "The week was not rushed.", "calendar", .green)
                ],
                building: [
                    item("Repeatability", "One clean week needs another.", "repeat.circle.fill", .amber)
                ],
                needsMore: [
                    item("No extra proof", "More work is not required now.", "minus.circle.fill", .gray)
                ],
                recent: [
                    item("Fri", "Third session finished.", "checkmark.circle.fill", .green)
                ]
            )

        case .targetOverhit:
            return make(
                state: state,
                headline: "More work than planned.",
                subline: "You cleared the target, but two sessions landed close together.",
                accent: .amber,
                path: weekPath(
                    summary: "Four sessions, with a tight cluster.",
                    window: "3/3 +1",
                    items: [
                        day("Mon", "Push", "checkmark", .green, true),
                        day("Tue", "Extra", "checkmark", .green, true, true),
                        day("Wed", "Rest", "moon.fill", .gray, false),
                        day("Thu", "Pull", "checkmark", .green, true),
                        day("Fri", "Extra", "checkmark", .green, true, true),
                        day("Sat", "Open", "circle", .gray, false),
                        day("Sun", "Open", "circle", .gray, false)
                    ]
                ),
                proof: [
                    proof("4", "Workouts", .green),
                    proof("3/3 +1", "Target", .green),
                    proof("Tight", "Spacing", .amber),
                    proof("Watch", "Next Week", .amber)
                ],
                nextMove: "Space the sessions next week.",
                nextMoveDetail: "Keep the work. Spread it better.",
                nextMoveSymbol: "calendar.badge.clock",
                confirmed: [
                    item("Target cleared", "The planned week is done.", "checkmark.seal.fill", .green),
                    item("Extra work", "One more session was logged.", "plus.circle.fill", .green)
                ],
                building: [
                    item("Spacing", "Two sessions sat close together.", "calendar.badge.exclamationmark", .amber),
                    item("Recovery space", "Give next week more room.", "arrow.left.and.right", .amber)
                ],
                needsMore: [
                    item("Stable rhythm", "Repeat the week first.", "circle.dashed", .gray)
                ],
                recent: [
                    item("Mon", "Push logged.", "checkmark.circle.fill", .green),
                    item("Tue", "Extra work logged.", "plus.circle.fill", .green),
                    item("Fri", "Target passed.", "checkmark.circle.fill", .green)
                ]
            )

        case .volumeUp:
            return make(
                state: state,
                headline: "Volume moved up.",
                subline: "More work is logged. Keep the next session controlled.",
                accent: .amber,
                path: weekPath(
                    summary: "Workload rose across the week.",
                    window: "7 days",
                    items: [
                        day("Mon", "Push", "checkmark", .green, true),
                        day("Tue", "Rest", "moon.fill", .gray, false),
                        day("Wed", "Pull", "checkmark", .green, true),
                        day("Thu", "More", "arrow.up", .amber, true, true),
                        day("Fri", "Check", "gauge.with.needle.fill", .amber, false),
                        day("Sat", "Open", "circle", .gray, false),
                        day("Sun", "Open", "circle", .gray, false)
                    ]
                ),
                proof: [
                    proof("Up", "Volume", .green),
                    proof("3", "Sessions", .green),
                    proof("2", "Areas", .steel),
                    proof("Watch", "Load", .amber)
                ],
                nextMove: "Keep one variable steady.",
                nextMoveDetail: "Do not raise load and volume at the same time.",
                nextMoveSymbol: "equal.circle.fill",
                confirmed: [
                    item("More work", "Volume is higher than last week.", "arrow.up.circle.fill", .green)
                ],
                building: [
                    item("Load choice", "Next session should stay controlled.", "gauge.with.needle.fill", .amber),
                    item("Coverage", "Push and pull are both in.", "scope", .steel)
                ],
                needsMore: [
                    item("Strength jump", "More work is not the same as stronger.", "dumbbell.fill", .gray)
                ],
                recent: [
                    item("7 days", "Three sessions completed.", "checkmark.circle.fill", .green),
                    item("Thu", "Extra sets added.", "square.stack.3d.up.fill", .amber)
                ]
            )

        case .bestSet:
            return make(
                state: state,
                headline: "Best set logged.",
                subline: "One set beat the recent mark. Repeat it before chasing more.",
                accent: .gold,
                path: weekPath(
                    summary: "Best set this week.",
                    window: "Today",
                    items: [
                        day("Mon", "Push", "checkmark", .green, true),
                        day("Tue", "Rest", "moon.fill", .gray, false),
                        day("Wed", "Best", "star.fill", .gold, true, true),
                        day("Thu", "Rest", "moon.fill", .gray, false),
                        day("Fri", "Repeat", "arrow.right", .steel, false),
                        day("Sat", "Open", "circle", .gray, false),
                        day("Sun", "Open", "circle", .gray, false)
                    ]
                ),
                proof: [
                    proof("1", "Best Set", .gold),
                    proof("80 x 6", "Bench", .gold),
                    proof("Clean", "Quality", .green),
                    proof("Confirm", "Next", .steel)
                ],
                nextMove: "Keep the weight and repeat clean reps.",
                nextMoveDetail: "A best set matters more when it shows up again.",
                nextMoveSymbol: "star.circle.fill",
                confirmed: [
                    item("Best set", "Bench press moved up.", "star.circle.fill", .gold)
                ],
                building: [
                    item("Strength trend", "One best set needs a repeat.", "dumbbell.fill", .steel)
                ],
                needsMore: [
                    item("No max yet", "Repeat it first.", "lock.fill", .gray)
                ],
                recent: [
                    item("Today", "Bench press 80 kg x 6.", "star.circle.fill", .gold)
                ]
            )

        case .recoveryLow:
            return make(
                state: state,
                headline: "Recovery shaped the week.",
                subline: "The next session should be lighter, not skipped.",
                accent: .red,
                path: weekPath(
                    summary: "Train today, but take the edge off.",
                    window: "Today",
                    items: [
                        day("Mon", "Heavy", "checkmark", .green, true),
                        day("Tue", "Rest", "moon.fill", .gray, false),
                        day("Wed", "Short", "moon.zzz.fill", .amber, true),
                        day("Thu", "Light", "arrow.down", .red, false, true),
                        day("Fri", "No PR", "star.slash.fill", .gray, false),
                        day("Sat", "Open", "circle", .gray, false),
                        day("Sun", "Open", "circle", .gray, false)
                    ]
                ),
                proof: [
                    proof("Low", "Recovery", .red),
                    proof("Heavy", "Last Lift", .amber),
                    proof("No PR", "Today", .gray),
                    proof("Lighter", "Session", .red)
                ],
                nextMove: "Take the lighter session today.",
                nextMoveDetail: "Lower the load and keep the reps clean.",
                nextMoveSymbol: "arrow.down.circle.fill",
                confirmed: [
                    item("Training stays", "You can still move.", "checkmark.circle.fill", .green)
                ],
                building: [
                    item("Caution", "Hard pushing gets capped.", "gauge.with.needle.fill", .red),
                    item("Recent load", "Last lift was heavy.", "dumbbell.fill", .amber)
                ],
                needsMore: [
                    item("No PR push", "Keep it lighter today.", "star.slash.fill", .gray)
                ],
                recent: [
                    item("Last lift", "Heavy bench work logged.", "dumbbell.fill", .amber),
                    item("Today", "Short sleep in the log.", "moon.zzz.fill", .amber)
                ]
            )

        case .deloadWeek:
            return make(
                state: state,
                headline: "Take the lighter week.",
                subline: "Less volume is the plan. Keep movement clean.",
                accent: .steel,
                path: weekPath(
                    summary: "Rhythm stays, pressure drops.",
                    window: "Deload",
                    items: [
                        day("Mon", "Light", "checkmark", .green, true),
                        day("Tue", "Rest", "moon.fill", .gray, false),
                        day("Wed", "Light", "checkmark", .green, true),
                        day("Thu", "Rest", "moon.fill", .gray, false),
                        day("Fri", "Easy", "pause.fill", .steel, false, true),
                        day("Sat", "Open", "circle", .gray, false),
                        day("Sun", "Open", "circle", .gray, false)
                    ]
                ),
                proof: [
                    proof("Down", "Volume", .amber),
                    proof("Held", "Rhythm", .green),
                    proof("Clean", "Movement", .steel),
                    proof("No", "PR Hunt", .gray)
                ],
                nextMove: "Keep volume down this week.",
                nextMoveDetail: "Move well and leave the hard push for later.",
                nextMoveSymbol: "pause.circle.fill",
                confirmed: [
                    item("Rhythm held", "Training continues.", "calendar", .green)
                ],
                building: [
                    item("Freshness", "The lighter week creates room.", "arrow.down.circle.fill", .steel)
                ],
                needsMore: [
                    item("No best set", "This week is not for records.", "star.slash.fill", .gray)
                ],
                recent: [
                    item("This week", "Volume intentionally lower.", "arrow.down.circle.fill", .amber)
                ]
            )

        case .plateau:
            return make(
                state: state,
                headline: "The lift is flat.",
                subline: "Three tries look similar. Change one small lever.",
                accent: .amber,
                path: ProgressPathData(
                    title: "Bench attempts",
                    summary: "Same area, three straight tries.",
                    window: "3 tries",
                    items: [
                        day("Try 1", "Same", "equal", .amber, true),
                        day("Try 2", "Same", "equal", .amber, true),
                        day("Try 3", "Same", "equal", .amber, true, true),
                        day("Next", "Adjust", "slider.horizontal.3", .steel, false, true)
                    ]
                ),
                proof: [
                    proof("3", "Tries", .amber),
                    proof("Same", "Load", .steel),
                    proof("No", "Jump", .amber),
                    proof("Small", "Change", .steel)
                ],
                nextMove: "Adjust reps, load, or rest.",
                nextMoveDetail: "Change one lever. Do not force all three.",
                nextMoveSymbol: "slider.horizontal.3",
                confirmed: [
                    item("Lift repeated", "The same lift has enough tries.", "repeat.circle.fill", .green)
                ],
                building: [
                    item("Plateau watch", "The last tries stayed flat.", "equal.circle.fill", .amber)
                ],
                needsMore: [
                    item("Cause unknown", "Do not guess the reason yet.", "questionmark.circle.fill", .gray)
                ],
                recent: [
                    item("3 attempts", "Similar load and reps.", "equal.circle.fill", .amber)
                ]
            )

        case .comebackWeek:
            return make(
                state: state,
                headline: "You're back in motion.",
                subline: "First session after the break is logged. Build from there.",
                accent: .amber,
                path: weekPath(
                    summary: "The return session is in.",
                    window: "Comeback",
                    items: [
                        day("Mon", "Break", "circle", .gray, false),
                        day("Tue", "Break", "circle", .gray, false),
                        day("Wed", "Return", "checkmark", .green, true, true),
                        day("Thu", "Rest", "moon.fill", .gray, false),
                        day("Fri", "Next", "arrow.uturn.forward", .amber, false, true),
                        day("Sat", "Open", "circle", .gray, false),
                        day("Sun", "Open", "circle", .gray, false)
                    ]
                ),
                proof: [
                    proof("1", "Workout", .green),
                    proof("Break", "Ended", .green),
                    proof("Light", "Start", .steel),
                    proof("Building", "Rhythm", .amber)
                ],
                nextMove: "Set the second session calmly.",
                nextMoveDetail: "First rhythm, then pressure.",
                nextMoveSymbol: "arrow.uturn.forward.circle.fill",
                confirmed: [
                    item("Back in", "The return session is logged.", "checkmark.circle.fill", .green)
                ],
                building: [
                    item("Rhythm", "The second session matters.", "calendar", .amber)
                ],
                needsMore: [
                    item("Old numbers", "Strength needs fresh logs.", "lock.fill", .gray)
                ],
                recent: [
                    item("Today", "First session after the break.", "figure.strengthtraining.traditional", .green)
                ]
            )

        case .consistentRhythm:
            return make(
                state: state,
                headline: "Rhythm is confirmed.",
                subline: "The same rhythm has repeated. Push one lever at a time.",
                accent: .green,
                path: ProgressPathData(
                    title: "Four-week path",
                    summary: "The rhythm has repeated.",
                    window: "4 weeks",
                    items: [
                        day("W1", "3/3", "checkmark", .green, true),
                        day("W2", "3/3", "checkmark", .green, true),
                        day("W3", "2/3", "checkmark", .green, true),
                        day("W4", "3/3", "checkmark.seal.fill", .green, true, true)
                    ]
                ),
                proof: [
                    proof("4", "Weeks", .green),
                    proof("Often", "3/3", .green),
                    proof("Good", "Spacing", .green),
                    proof("One", "Lever", .steel)
                ],
                nextMove: "Push one lever, keep the rest stable.",
                nextMoveDetail: "Choose load, reps, or coverage. Not all three.",
                nextMoveSymbol: "arrow.up.circle.fill",
                confirmed: [
                    item("Rhythm", "The week repeated.", "checkmark.seal.fill", .green),
                    item("Target habit", "Three-workout weeks are normal now.", "calendar", .green)
                ],
                building: [
                    item("Next push", "One lever can move up.", "arrow.up.circle.fill", .steel)
                ],
                needsMore: [
                    item("Do not pile on", "Keep the other levers steady.", "minus.circle.fill", .gray)
                ],
                recent: [
                    item("4 weeks", "Training cadence held.", "repeat.circle.fill", .green)
                ]
            )

        case .muscleCoverageForming:
            return make(
                state: state,
                headline: "Coverage is forming.",
                subline: "Push is covered. Pull is building. Legs still need work.",
                accent: .amber,
                path: weekPath(
                    summary: "Areas are filling in, one stays open.",
                    window: "This week",
                    items: [
                        day("Mon", "Push", "checkmark", .green, true, true),
                        day("Tue", "Rest", "moon.fill", .gray, false),
                        day("Wed", "Pull", "circle.lefthalf.filled", .amber, true, true),
                        day("Thu", "Rest", "moon.fill", .gray, false),
                        day("Fri", "Legs", "circle", .gray, false, true),
                        day("Sat", "Open", "circle", .gray, false),
                        day("Sun", "Open", "circle", .gray, false)
                    ]
                ),
                proof: [
                    proof("Push", "Confirmed", .green),
                    proof("Pull", "Building", .amber),
                    proof("Legs", "Open", .gray),
                    proof("Plan", "Legs", .amber)
                ],
                nextMove: "Plan the open area.",
                nextMoveDetail: "Add legs before chasing more push work.",
                nextMoveSymbol: "scope",
                confirmed: [
                    item("Push covered", "Enough work landed there.", "checkmark.circle.fill", .green)
                ],
                building: [
                    item("Pull", "Started, not locked in.", "circle.lefthalf.filled", .amber)
                ],
                needsMore: [
                    item("Legs", "Still open this week.", "circle.dashed", .gray),
                    item("Open area", "Add legs before more push.", "number.circle.fill", .gray)
                ],
                recent: [
                    item("Mon", "Push covered.", "checkmark.circle.fill", .green),
                    item("Wed", "Pull started.", "circle.lefthalf.filled", .amber)
                ]
            )
        }
    }

    private static func make(
        state: ProgressPathDemoState,
        headline: String,
        subline: String,
        accent: ProgressPathTone,
        path: ProgressPathData,
        proof: [ProgressPathProofItem],
        nextMove: String,
        nextMoveDetail: String,
        nextMoveSymbol: String,
        confirmed: [ProgressPathDetailItem],
        building: [ProgressPathDetailItem],
        needsMore: [ProgressPathDetailItem],
        recent: [ProgressPathDetailItem]
    ) -> ProgressPathScenario {
        ProgressPathScenario(
            state: state,
            headline: headline,
            subline: subline,
            accent: accent,
            path: path,
            proofItems: proof,
            nextMove: nextMove,
            nextMoveDetail: nextMoveDetail,
            nextMoveSymbol: nextMoveSymbol,
            confirmed: confirmed,
            building: building,
            needsMore: needsMore,
            recentWork: recent
        )
    }

    private static func weekPath(summary: String, window: String, items: [ProgressPathItem]) -> ProgressPathData {
        ProgressPathData(title: "This week", summary: summary, window: window, items: items)
    }

    private static func day(
        _ topLabel: String,
        _ bottomLabel: String,
        _ symbol: String,
        _ tone: ProgressPathTone,
        _ filled: Bool,
        _ emphasized: Bool = false
    ) -> ProgressPathItem {
        ProgressPathItem(
            topLabel: topLabel,
            bottomLabel: bottomLabel,
            symbol: symbol,
            tone: tone,
            filled: filled,
            emphasized: emphasized
        )
    }

    private static func proof(_ value: String, _ label: String, _ tone: ProgressPathTone) -> ProgressPathProofItem {
        ProgressPathProofItem(value: value, label: label, tone: tone)
    }

    private static func item(
        _ title: String,
        _ detail: String,
        _ symbol: String,
        _ tone: ProgressPathTone
    ) -> ProgressPathDetailItem {
        ProgressPathDetailItem(title: title, detail: detail, symbol: symbol, tone: tone)
    }
}

private struct ProgressTrainingMapPrototypeView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressTrainingMapPrototypeView(isFullscreen: true)
            .previewDisplayName("Progress Path V0.3")
    }
}
#endif
