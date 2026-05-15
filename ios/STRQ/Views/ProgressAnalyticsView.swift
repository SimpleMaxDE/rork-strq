import SwiftUI
import Charts

enum ProgressRoute: Hashable {
    case history
}

struct ProgressAnalyticsView: View {
    let vm: AppViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedTab: Int = 0
    @State private var appeared: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headlineHero
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                whatsImprovingCard
                    .padding(.horizontal, 16)

                signalStrip
                    .padding(.horizontal, 16)

                if !vm.isEarlyStage {
                    recentImprovementCard
                        .padding(.horizontal, 16)
                }

                if !vm.isEarlyStage {
                    momentumBreakdown
                        .padding(.horizontal, 16)
                }

                tabSelector
                    .padding(.horizontal, 16)

                Group {
                    switch selectedTab {
                    case 0: strengthSignals
                    case 1: bodySignals
                    case 2: volumeSignals
                    default: strengthSignals
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle(L10n.tr("Progress"))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5)) { appeared = true }
            Analytics.shared.track(.progress_viewed)
        }
    }

    // MARK: - Headline Hero

    private struct ProofMaturityCopy {
        let eyebrow: String
        let title: String
        let detail: String
        let meterLabel: String
        let icon: String
        let progress: Double
        let state: STRQPalette.State
    }

    private struct ProofTrustItem: Identifiable {
        let title: String
        let value: String
        let detail: String
        let icon: String
        let state: STRQPalette.State

        var id: String { title }
    }

    private struct ProofAxisItem: Identifiable {
        let title: String
        let value: String
        let detail: String
        let icon: String
        let progress: Double
        let state: STRQPalette.State

        var id: String { title }
    }

    private enum TrainingMapHeroStyle {
        static let signal = Color(red: 0.412, green: 0.843, blue: 0.808)
        static let amber = Color(red: 0.831, green: 0.722, blue: 0.416)
        static let steel = STRQBrand.steel
        static let plot = Color(red: 0.027, green: 0.039, blue: 0.059)
        static let stage = Color(red: 0.035, green: 0.067, blue: 0.086)
        static let surface = Color(red: 0.055, green: 0.066, blue: 0.082)
        static let panel = Color.white.opacity(0.045)
        static let track = Color(red: 0.153, green: 0.192, blue: 0.231)
        static let border = Color.white.opacity(0.08)
        static let grid = Color.white.opacity(0.06)
    }

    private enum TrainingMapHeroState: Equatable {
        case locked
        case forming
        case readable

        var tint: Color {
            switch self {
            case .locked:
                return TrainingMapHeroStyle.steel
            case .forming:
                return TrainingMapHeroStyle.amber
            case .readable:
                return TrainingMapHeroStyle.signal
            }
        }

        var background: Color {
            switch self {
            case .locked:
                return TrainingMapHeroStyle.surface.opacity(0.72)
            case .forming:
                return TrainingMapHeroStyle.amber.opacity(0.16)
            case .readable:
                return TrainingMapHeroStyle.signal.opacity(0.16)
            }
        }

        var border: Color {
            switch self {
            case .locked:
                return TrainingMapHeroStyle.steel.opacity(0.22)
            case .forming:
                return TrainingMapHeroStyle.amber.opacity(0.50)
            case .readable:
                return TrainingMapHeroStyle.signal.opacity(0.54)
            }
        }

        var iconTint: Color {
            switch self {
            case .locked:
                return TrainingMapHeroStyle.steel.opacity(0.72)
            default:
                return tint
            }
        }

        var ringProgress: CGFloat {
            switch self {
            case .locked:
                return 0.10
            case .forming:
                return 0.42
            case .readable:
                return 0.82
            }
        }

        var shadow: Color {
            switch self {
            case .locked:
                return .clear
            default:
                return tint.opacity(0.24)
            }
        }
    }

    private struct TrainingMapHeroNode: Identifiable {
        let title: String
        let statusLabel: String
        let icon: String
        let state: TrainingMapHeroState
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let isPrimary: Bool

        var id: String { title }
    }

    private struct TrainingMapHeroLink: Identifiable {
        let start: String
        let end: String

        var id: String { "\(start)-\(end)" }

        static let standard = [
            TrainingMapHeroLink(start: "Sessions", end: "Rhythm"),
            TrainingMapHeroLink(start: "Rhythm", end: "Evidence"),
            TrainingMapHeroLink(start: "Evidence", end: "Strength"),
            TrainingMapHeroLink(start: "Strength", end: "Detail"),
            TrainingMapHeroLink(start: "Detail", end: "Sessions")
        ]
    }

    private struct TrainingMapHeroSnapshot {
        let completedWorkouts: Int
        let sessionsInWindow: Int
        let activeWeeks: Int
        let currentWeekSessions: Int
        let weeklyTarget: Int
        let overallState: TrainingMapHeroState
        let stateLabel: String
        let headline: String
        let detail: String
        let mapCaption: String
        let nextUnlockTitle: String
        let nextUnlockDetail: String
        let nextUnlockIcon: String
        let nextUnlockState: TrainingMapHeroState
        let mapNodes: [TrainingMapHeroNode]
        let mapLinks: [TrainingMapHeroLink]

        var accessibilityMapSummary: String {
            mapNodes.map { "\($0.title) \($0.statusLabel)" }.joined(separator: ", ")
        }

        func node(named name: String) -> TrainingMapHeroNode {
            mapNodes.first { $0.title == name } ?? mapNodes[0]
        }
    }

    private var trainingMapHeroSnapshot: TrainingMapHeroSnapshot {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? Date()
        let windowStart = calendar.date(byAdding: .day, value: -27, to: today) ?? today
        let completedSessions = vm.workoutHistory
            .filter(\.isCompleted)
            .sorted { $0.startTime > $1.startTime }
        let sessionsInWindow = completedSessions.filter { session in
            session.startTime >= windowStart && session.startTime < tomorrow
        }
        let activeWeekStarts = Set(sessionsInWindow.map {
            calendar.dateInterval(of: .weekOfYear, for: $0.startTime)?.start ?? calendar.startOfDay(for: $0.startTime)
        })
        let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let currentWeekSessions = sessionsInWindow.filter { $0.startTime >= currentWeekStart }.count
        let weeklyTarget = max(1, min(vm.profile.daysPerWeek, 7))
        let completedWorkouts = vm.totalCompletedWorkouts
        let activeWeeks = activeWeekStarts.count

        let overallState: TrainingMapHeroState
        if completedWorkouts == 0 {
            overallState = .locked
        } else if completedWorkouts >= 4 && activeWeeks >= 2 {
            overallState = .readable
        } else {
            overallState = .forming
        }

        let rhythmState: TrainingMapHeroState
        if sessionsInWindow.isEmpty {
            rhythmState = .locked
        } else if (sessionsInWindow.count >= 4 && activeWeeks >= 2) || (currentWeekSessions >= weeklyTarget && sessionsInWindow.count >= weeklyTarget) {
            rhythmState = .readable
        } else {
            rhythmState = .forming
        }

        let evidenceState: TrainingMapHeroState
        if sessionsInWindow.isEmpty {
            evidenceState = .locked
        } else if sessionsInWindow.count >= 3 && activeWeeks >= 2 {
            evidenceState = .readable
        } else {
            evidenceState = .forming
        }

        let strengthState: TrainingMapHeroState = vm.hasEnoughDataForStrengthChart
            ? .readable
            : (vm.strengthProgress.isEmpty ? .locked : .forming)
        let detailState: TrainingMapHeroState = completedWorkouts >= 4
            ? .readable
            : (completedWorkouts > 0 ? .forming : .locked)

        let stateLabel: String
        let headline: String
        let detail: String
        let mapCaption: String
        switch overallState {
        case .locked:
            stateLabel = L10n.tr("No claims yet")
            headline = L10n.tr("Complete your first workout to start the map.")
            detail = L10n.tr("The map fills from completed workouts only.")
            mapCaption = L10n.tr("Complete your first workout to start the map. No claims yet.")
        case .forming:
            stateLabel = L10n.tr("Starting")
            headline = completedWorkouts == 1 ? L10n.tr("One workout has started the record.") : L10n.tr("The map is taking shape.")
            detail = L10n.tr("STRQ is using completed sessions only, keeping deeper reads quiet until repeats exist.")
            mapCaption = L10n.tr("Early signals are visible. Detailed area reads stay quiet.")
        case .readable:
            stateLabel = L10n.tr("Readable")
            headline = L10n.tr("Your recent training has a readable structure.")
            detail = L10n.format("%d completed workouts across %d recent active weeks power this view.", completedWorkouts, activeWeeks)
            mapCaption = L10n.tr("The structure is readable; detailed area claims stay conservative.")
        }

        let nextUnlock: (title: String, detail: String, icon: String, state: TrainingMapHeroState) = {
            if completedWorkouts == 0 {
                return (
                    L10n.tr("One completed workout starts the map."),
                    L10n.tr("Finish a workout so Progress can begin filling from real training history."),
                    "play.fill",
                    .locked
                )
            }
            if completedWorkouts == 1 {
                return (
                    L10n.tr("One more session gives the map a repeat."),
                    L10n.tr("Complete workout 2 to give STRQ the first real pattern to compare."),
                    "repeat",
                    .forming
                )
            }
            if completedWorkouts == 2 {
                return (
                    L10n.tr("One more session steadies the rhythm."),
                    L10n.tr("Complete workout 3 to make the weekly story easier to read."),
                    "calendar.badge.plus",
                    .forming
                )
            }
            if currentWeekSessions < weeklyTarget {
                let remaining = max(1, weeklyTarget - currentWeekSessions)
                return (
                    remaining == 1 ? L10n.tr("1 session left to steady this week.") : L10n.format("%d sessions left to steady this week.", remaining),
                    remaining == 1 ? L10n.tr("Complete one more session to make this week easier to read.") : L10n.format("Complete %d more sessions to make this week easier to read.", remaining),
                    "target",
                    .forming
                )
            }
            if !vm.hasEnoughDataForStrengthChart {
                return (
                    L10n.tr("Repeat one anchor to make strength readable."),
                    L10n.tr("Repeated logged sets help the deeper trend view become easier to trust."),
                    "chart.line.uptrend.xyaxis",
                    .forming
                )
            }
            return (
                L10n.tr("Repeat the cadence next week."),
                L10n.tr("A similar week keeps the structure easy to read without adding extra claims."),
                "checkmark.seal.fill",
                .readable
            )
        }()

        func nodeLabel(for state: TrainingMapHeroState, locked: String, forming: String, readable: String) -> String {
            switch state {
            case .locked: return locked
            case .forming: return forming
            case .readable: return readable
            }
        }

        let nodes = [
            TrainingMapHeroNode(title: L10n.tr("Sessions"), statusLabel: nodeLabel(for: overallState, locked: L10n.tr("Start here"), forming: L10n.tr("Started"), readable: L10n.tr("Readable")), icon: "figure.strengthtraining.traditional", state: overallState, x: 0.28, y: 0.44, size: 86, isPrimary: true),
            TrainingMapHeroNode(title: L10n.tr("Rhythm"), statusLabel: nodeLabel(for: rhythmState, locked: L10n.tr("Waiting"), forming: L10n.tr("Forming"), readable: L10n.tr("Readable")), icon: "calendar.badge.clock", state: rhythmState, x: 0.58, y: 0.24, size: 76, isPrimary: false),
            TrainingMapHeroNode(title: L10n.tr("Evidence"), statusLabel: nodeLabel(for: evidenceState, locked: L10n.tr("Quiet"), forming: L10n.tr("Starting"), readable: L10n.tr("Readable")), icon: "list.bullet.rectangle.portrait.fill", state: evidenceState, x: 0.74, y: 0.52, size: 78, isPrimary: false),
            TrainingMapHeroNode(title: L10n.tr("Strength"), statusLabel: nodeLabel(for: strengthState, locked: L10n.tr("Needs reps"), forming: L10n.tr("Forming"), readable: L10n.tr("Readable")), icon: "chart.line.uptrend.xyaxis", state: strengthState, x: 0.42, y: 0.72, size: 78, isPrimary: false),
            TrainingMapHeroNode(title: L10n.tr("Detail"), statusLabel: nodeLabel(for: detailState, locked: L10n.tr("Later"), forming: L10n.tr("Opening"), readable: L10n.tr("Below")), icon: "rectangle.stack.fill", state: detailState, x: 0.22, y: 0.72, size: 70, isPrimary: false)
        ]
        let links = [
            TrainingMapHeroLink(start: nodes[0].title, end: nodes[1].title),
            TrainingMapHeroLink(start: nodes[1].title, end: nodes[2].title),
            TrainingMapHeroLink(start: nodes[2].title, end: nodes[3].title),
            TrainingMapHeroLink(start: nodes[3].title, end: nodes[4].title),
            TrainingMapHeroLink(start: nodes[4].title, end: nodes[0].title)
        ]

        return TrainingMapHeroSnapshot(
            completedWorkouts: completedWorkouts,
            sessionsInWindow: sessionsInWindow.count,
            activeWeeks: activeWeeks,
            currentWeekSessions: currentWeekSessions,
            weeklyTarget: weeklyTarget,
            overallState: overallState,
            stateLabel: stateLabel,
            headline: headline,
            detail: detail,
            mapCaption: mapCaption,
            nextUnlockTitle: nextUnlock.title,
            nextUnlockDetail: nextUnlock.detail,
            nextUnlockIcon: nextUnlock.icon,
            nextUnlockState: nextUnlock.state,
            mapNodes: nodes,
            mapLinks: links
        )
    }

    private var headlineHero: some View {
        let snapshot = trainingMapHeroSnapshot
        let tint = snapshot.overallState.tint

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 10) {
                    trainingMapStateCapsule(snapshot.stateLabel, state: snapshot.overallState)

                    Text(L10n.tr("Training Map"))
                        .font(.system(size: 10, weight: .black))
                        .tracking(1.1)
                        .foregroundStyle(.white.opacity(0.48))
                        .textCase(.uppercase)

                    Text(snapshot.headline)
                        .font(.system(size: 23, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white.opacity(0.96))
                        .lineLimit(3)
                        .minimumScaleFactor(0.82)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(snapshot.detail)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.62))
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                VStack(spacing: 3) {
                    STRQCountUpText(value: Double(snapshot.completedWorkouts), duration: 0.7)
                        .font(.system(size: 31, weight: .heavy, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white)
                    Text(snapshot.completedWorkouts == 1 ? L10n.tr("workout") : L10n.tr("workouts"))
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.44))
                        .lineLimit(1)
                }
                .frame(width: 76, height: 76)
                .background(Color.white.opacity(0.04), in: Circle())
                .overlay(Circle().strokeBorder(tint.opacity(0.2), lineWidth: 1))
            }

            trainingMapCanvas(snapshot)
                .frame(height: 286)

            HStack(spacing: 0) {
                trainingMapStat(title: L10n.tr("Window"), value: "\(snapshot.sessionsInWindow)", detail: L10n.tr("in 28d"))
                Rectangle().fill(TrainingMapHeroStyle.border).frame(width: 1, height: 38)
                trainingMapStat(title: L10n.tr("Weeks"), value: "\(snapshot.activeWeeks)/4", detail: L10n.tr("active"))
                Rectangle().fill(TrainingMapHeroStyle.border).frame(width: 1, height: 38)
                trainingMapStat(title: L10n.tr("Target"), value: "\(snapshot.currentWeekSessions)/\(snapshot.weeklyTarget)", detail: L10n.tr("this week"))
            }
            .padding(.vertical, 11)
            .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(TrainingMapHeroStyle.border, lineWidth: 1)
            )

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: snapshot.nextUnlockIcon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(snapshot.nextUnlockState.tint)
                    .frame(width: 30, height: 30)
                    .background(snapshot.nextUnlockState.tint.opacity(0.12), in: .rect(cornerRadius: 9))

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.tr("Next Unlock"))
                        .font(.system(size: 9, weight: .black))
                        .tracking(0.7)
                        .foregroundStyle(.white.opacity(0.42))
                        .textCase(.uppercase)
                    Text(snapshot.nextUnlockTitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.92))
                        .fixedSize(horizontal: false, vertical: true)
                    Text(snapshot.nextUnlockDetail)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.56))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(12)
            .background(Color.white.opacity(0.028), in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(snapshot.nextUnlockState.tint.opacity(0.14), lineWidth: 1)
            )

        }
        .padding(16)
        .background {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.058, green: 0.069, blue: 0.085), Color(red: 0.025, green: 0.029, blue: 0.036)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
            }
            .clipShape(.rect(cornerRadius: 24))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(tint.opacity(0.22), lineWidth: 1)
        )
        .overlay(alignment: .topLeading) {
            LinearGradient(colors: [tint.opacity(0.50), .clear], startPoint: .leading, endPoint: .trailing)
                .frame(height: 2)
                .clipShape(.rect(cornerRadii: .init(topLeading: 24, bottomLeading: 0, bottomTrailing: 0, topTrailing: 24)))
        }
        .shadow(color: .black.opacity(0.24), radius: 20, y: 7)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5), value: appeared)
    }

    private func trainingMapCanvas(_ snapshot: TrainingMapHeroSnapshot) -> some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)

            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [TrainingMapHeroStyle.stage, TrainingMapHeroStyle.plot],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Path { path in
                    path.addEllipse(in: CGRect(x: width * 0.12, y: height * 0.10, width: width * 0.76, height: height * 0.72))
                    path.addEllipse(in: CGRect(x: width * 0.28, y: height * 0.23, width: width * 0.44, height: height * 0.42))
                }
                .stroke(snapshot.overallState.tint.opacity(snapshot.overallState == .locked ? 0.08 : 0.13), style: StrokeStyle(lineWidth: 1, dash: [6, 9]))

                Path { path in
                    path.move(to: CGPoint(x: width * 0.5, y: height * 0.08))
                    path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.88))
                    path.move(to: CGPoint(x: width * 0.12, y: height * 0.5))
                    path.addLine(to: CGPoint(x: width * 0.88, y: height * 0.5))
                }
                .stroke(TrainingMapHeroStyle.grid, style: StrokeStyle(lineWidth: 1, dash: [3, 8]))

                ForEach(snapshot.mapLinks) { link in
                    let start = snapshot.node(named: link.start)
                    let end = snapshot.node(named: link.end)
                    let isQuiet = start.state == .locked || end.state == .locked

                    Path { path in
                        path.move(to: CGPoint(x: width * start.x, y: height * start.y))
                        path.addLine(to: CGPoint(x: width * end.x, y: height * end.y))
                    }
                    .trim(from: 0, to: appeared || reduceMotion ? 1 : 0)
                    .stroke(
                        (isQuiet ? TrainingMapHeroStyle.steel : end.state.tint).opacity(isQuiet ? 0.24 : 0.56),
                        style: StrokeStyle(lineWidth: isQuiet ? 1.25 : 2.25, lineCap: .round, dash: isQuiet ? [5, 7] : [])
                    )
                    .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.6), value: appeared)
                }

                ForEach(snapshot.mapNodes) { node in
                    trainingMapNode(node)
                        .frame(width: node.size, height: node.size)
                        .position(x: width * node.x, y: height * node.y)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.tr("Training Map"))
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white.opacity(0.9))
                    Text(snapshot.mapCaption)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.white.opacity(0.52))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: min(190, width * 0.58), alignment: .leading)
                .padding(10)
                .background(Color(red: 0.067, green: 0.086, blue: 0.106).opacity(0.90), in: .rect(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(TrainingMapHeroStyle.border, lineWidth: 1)
                )
                .position(x: width * 0.31, y: height * 0.17)
            }
        }
        .padding(5)
        .background(TrainingMapHeroStyle.plot, in: .rect(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(TrainingMapHeroStyle.border, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(L10n.tr("Training Map")), \(snapshot.accessibilityMapSummary)"))
    }

    private func trainingMapNode(_ node: TrainingMapHeroNode) -> some View {
        ZStack {
            Circle()
                .fill(node.state.background)
                .overlay(
                    Circle()
                        .strokeBorder(node.state.border, style: StrokeStyle(lineWidth: 1, dash: node.state == .locked ? [4, 5] : []))
                )
                .shadow(color: node.state.shadow, radius: node.state == .locked ? 0 : 11, y: 4)

            Circle()
                .trim(from: 0, to: appeared || reduceMotion ? node.state.ringProgress : 0.1)
                .stroke(node.state.tint.opacity(node.state == .locked ? 0.24 : 0.92), style: StrokeStyle(lineWidth: node.isPrimary ? 3 : 2.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(4)
                .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.6), value: appeared)

            VStack(spacing: 4) {
                Image(systemName: node.icon)
                    .font(.system(size: node.isPrimary ? 16 : 14, weight: .bold))
                    .foregroundStyle(node.state.iconTint)

                Text(node.title)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(node.state == .locked ? .white.opacity(0.62) : .white.opacity(0.92))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)

                Text(node.statusLabel)
                    .font(.system(size: 8, weight: .black))
                    .foregroundStyle(node.state.tint.opacity(node.state == .locked ? 0.70 : 0.94))
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
            }
            .padding(6)
        }
        .accessibilityLabel(Text("\(node.title), \(node.statusLabel)"))
    }

    private func trainingMapStat(title: String, value: String, detail: String) -> some View {
        VStack(spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 8, weight: .black))
                .foregroundStyle(.white.opacity(0.42))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(value)
                .font(.system(size: 18, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundStyle(.white.opacity(0.94))
                .lineLimit(1)
            Text(detail)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.white.opacity(0.48))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
    }

    private func trainingMapStateCapsule(_ text: String, state: TrainingMapHeroState) -> some View {
        Text(text.uppercased())
            .font(.system(size: 9, weight: .black))
            .foregroundStyle(state.tint)
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(state.tint.opacity(0.10), in: Capsule())
            .overlay(Capsule().strokeBorder(state.tint.opacity(0.18), lineWidth: 1))
    }

    private var achievementChipsIsEmpty: Bool {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        let prsThisMonth = vm.personalRecords.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }.count
        let thisWeek = vm.workoutHistory.filter { $0.startTime > weekAgo && $0.isCompleted }
        let lastWeek = vm.workoutHistory.filter { $0.startTime > twoWeeksAgo && $0.startTime <= weekAgo && $0.isCompleted }
        let volumeThis = thisWeek.reduce(0.0) { $0 + $1.totalVolume }
        let volumeLast = lastWeek.reduce(0.0) { $0 + $1.totalVolume }
        let consistencyTarget = max(1, min(vm.profile.daysPerWeek, 4))
        return prsThisMonth == 0 && vm.streak <= 1 && !(volumeLast > 0 && volumeThis > volumeLast) && vm.weeklyStats.sessions < consistencyTarget
    }

    private var proofAxisItems: [ProofAxisItem] {
        let target = max(1, min(3, vm.profile.daysPerWeek))
        let workoutProgress = min(Double(vm.totalCompletedWorkouts) / 4.0, 1)
        let consistencyProgress = min(Double(vm.weeklyStats.sessions) / Double(target), 1)
        let recoveryProgress = min(Double(vm.effectiveRecoveryScore) / 100.0, 1)
        let strengthProgress = vm.hasEnoughDataForStrengthChart ? min(Double(vm.strengthProgress.count) / 8.0, 1) : min(Double(vm.strengthProgress.count) / 4.0, 0.72)

        return [
            ProofAxisItem(
                title: L10n.tr("Baseline"),
                value: "\(vm.totalCompletedWorkouts)",
                detail: vm.totalCompletedWorkouts == 1 ? L10n.tr("session") : L10n.tr("sessions"),
                icon: "figure.strengthtraining.traditional",
                progress: workoutProgress,
                state: vm.totalCompletedWorkouts >= 4 ? .success : (vm.totalCompletedWorkouts > 0 ? .info : .neutral)
            ),
            ProofAxisItem(
                title: L10n.tr("Strength"),
                value: "\(vm.strengthProgress.count)",
                detail: vm.hasEnoughDataForStrengthChart ? L10n.tr("anchors") : L10n.tr("forming"),
                icon: "chart.line.uptrend.xyaxis",
                progress: strengthProgress,
                state: vm.hasEnoughDataForStrengthChart ? .info : .warning
            ),
            ProofAxisItem(
                title: L10n.tr("Rhythm"),
                value: "\(vm.weeklyStats.sessions)/\(target)",
                detail: L10n.tr("this week"),
                icon: "calendar.badge.clock",
                progress: consistencyProgress,
                state: vm.weeklyStats.sessions >= target ? .success : (vm.weeklyStats.sessions > 0 ? .warning : .neutral)
            ),
            ProofAxisItem(
                title: L10n.tr("Context"),
                value: "\(vm.effectiveRecoveryScore)%",
                detail: L10n.tr("recovery"),
                icon: "heart.fill",
                progress: recoveryProgress,
                state: vm.totalCompletedWorkouts == 0 ? .neutral : (vm.effectiveRecoveryScore >= 70 ? .success : (vm.effectiveRecoveryScore >= 55 ? .warning : .danger))
            )
        ]
    }

    private func heroSignalPlot(items: [ProofAxisItem], tint: Color) -> some View {
        let values = items.map { max(0.04, min($0.progress, 1.0)) }

        return GeometryReader { geo in
            let width = max(1, geo.size.width)
            let height = max(1, geo.size.height)
            let step = width / CGFloat(max(values.count - 1, 1))

            ZStack {
                VStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.white.opacity(0.055))
                            .frame(height: 1)
                        Spacer(minLength: 0)
                    }
                }

                Path { path in
                    for index in values.indices {
                        let x = CGFloat(index) * step
                        let y = 10 + (1 - CGFloat(values[index])) * (height - 20)
                        if index == values.startIndex {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .trim(from: 0, to: appeared || reduceMotion ? 1 : 0)
                .stroke(tint.gradient, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .shadow(color: tint.opacity(0.28), radius: 10, y: 3)
                .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.65), value: appeared)

                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    let value = max(0.04, min(item.progress, 1.0))
                    let x = CGFloat(index) * step
                    let y = 10 + (1 - CGFloat(value)) * (height - 20)
                    Circle()
                        .fill(STRQPalette.color(for: item.state))
                        .frame(width: 8, height: 8)
                        .overlay(Circle().strokeBorder(Color.white.opacity(0.5), lineWidth: 1))
                        .position(x: x, y: y)
                }
            }
            .padding(.horizontal, 4)
        }
        .frame(height: 118)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.2), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func heroAxisReadout(_ item: ProofAxisItem) -> some View {
        let tint = STRQPalette.color(for: item.state)

        return HStack(spacing: 9) {
            Image(systemName: item.icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 24, height: 24)
                .background(tint.opacity(0.12), in: .rect(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 9, weight: .black))
                    .tracking(0.6)
                    .foregroundStyle(.white.opacity(0.45))
                    .textCase(.uppercase)
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(item.value)
                        .font(.system(size: 15, weight: .heavy, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.92))
                    Text(item.detail)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.46))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(Color.white.opacity(0.035), in: .rect(cornerRadius: 12))
    }

    private var proofHeadline: (String, String) {
        let progressing = vm.progressingExercises.count
        let prsThisMonth: Int = {
            let cal = Calendar.current
            return vm.personalRecords.filter { cal.isDate($0.date, equalTo: Date(), toGranularity: .month) }.count
        }()

        switch vm.dataMaturityTier {
        case .fresh:
            return ("0", L10n.tr("workouts logged"))
        case .firstSession:
            return ("1", L10n.tr("workout logged"))
        case .earlyWeek:
            return ("\(vm.totalCompletedWorkouts)", L10n.tr("workouts logged"))
        case .established:
            if progressing > 0 {
                return ("\(progressing)", L10n.tr("lifts progressing"))
            } else if prsThisMonth > 0 {
                return ("\(prsThisMonth)", L10n.tr("PRs this month"))
            } else {
                return ("\(vm.totalCompletedWorkouts)", L10n.tr("workouts logged"))
            }
        }
    }

    private var proofMaturityCopy: ProofMaturityCopy {
        switch vm.dataMaturityTier {
        case .fresh:
            return ProofMaturityCopy(
                eyebrow: L10n.tr("Baseline"),
                title: L10n.tr("Baseline forming"),
                detail: L10n.tr("progress.fresh.subtitle", fallback: "Log one workout, then Progress becomes useful."),
                meterLabel: L10n.tr("Start"),
                icon: "circle.dashed",
                progress: 0.08,
                state: .info
            )
        case .firstSession:
            return ProofMaturityCopy(
                eyebrow: L10n.tr("First signal"),
                title: L10n.tr("First training signal captured"),
                detail: L10n.tr("One finished workout is real evidence. A few more make strength, body, and volume trends trustworthy."),
                meterLabel: L10n.tr("Signal"),
                icon: "waveform.path.ecg",
                progress: 0.34,
                state: .info
            )
        case .earlyWeek:
            return ProofMaturityCopy(
                eyebrow: L10n.tr("Pattern"),
                title: L10n.tr("Early pattern building"),
                detail: L10n.tr("STRQ is reading consistency and load. Conclusions stay cautious until the baseline fills in."),
                meterLabel: L10n.tr("Forming"),
                icon: "chart.line.uptrend.xyaxis",
                progress: 0.64,
                state: .warning
            )
        case .established:
            return ProofMaturityCopy(
                eyebrow: L10n.tr("Proof"),
                title: L10n.tr("Proof is becoming meaningful"),
                detail: vm.streak > 0
                    ? L10n.format("%d-day streak with strength, recovery, and history now readable.", vm.streak)
                    : L10n.tr("Strength, recovery, and training history are now readable enough to trust."),
                meterLabel: L10n.tr("Proof"),
                icon: "checkmark.seal.fill",
                progress: 1.0,
                state: .success
            )
        }
    }

    private var proofTrustItems: [ProofTrustItem] {
        let target = max(1, min(3, vm.profile.daysPerWeek))
        let workoutsState: STRQPalette.State = vm.totalCompletedWorkouts >= 4 ? .success : (vm.totalCompletedWorkouts > 0 ? .info : .neutral)
        let consistencyState: STRQPalette.State = vm.weeklyStats.sessions >= target ? .success : (vm.weeklyStats.sessions > 0 ? .warning : .neutral)
        let recoveryState: STRQPalette.State = vm.totalCompletedWorkouts == 0 ? .neutral : (vm.effectiveRecoveryScore >= 70 ? .success : (vm.effectiveRecoveryScore >= 55 ? .warning : .danger))

        return [
            ProofTrustItem(
                title: L10n.tr("Training data"),
                value: "\(vm.totalCompletedWorkouts)",
                detail: vm.totalCompletedWorkouts >= 4 ? L10n.tr("Readable") : (vm.totalCompletedWorkouts == 0 ? L10n.tr("Awaiting first workout") : L10n.tr("Baseline forming")),
                icon: "figure.strengthtraining.traditional",
                state: workoutsState
            ),
            ProofTrustItem(
                title: L10n.tr("Consistency"),
                value: "\(vm.weeklyStats.sessions)/\(target)",
                detail: vm.weeklyStats.sessions >= target ? L10n.tr("Target met") : L10n.tr("Building pattern"),
                icon: "calendar.badge.clock",
                state: consistencyState
            ),
            ProofTrustItem(
                title: L10n.tr("Recovery"),
                value: "\(vm.effectiveRecoveryScore)%",
                detail: vm.totalCompletedWorkouts == 0 ? L10n.tr("Context only") : L10n.tr("Training context"),
                icon: "heart.fill",
                state: recoveryState
            )
        ]
    }

    private func proofMaturityRing(progress: Double, tint: Color, icon: String, label: String) -> some View {
        let clamped = max(0, min(progress, 1))
        return ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: 7)
            Circle()
                .trim(from: 0, to: appeared || reduceMotion ? clamped : 0)
                .stroke(tint.gradient, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.6), value: appeared)

            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(tint)
                Text(label)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(.white.opacity(0.74))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .frame(width: 76, height: 76)
        .padding(4)
        .background(Color.white.opacity(0.035), in: Circle())
    }

    private func proofTrustRow(_ item: ProofTrustItem) -> some View {
        let tint = STRQPalette.color(for: item.state)

        return HStack(spacing: 10) {
            Image(systemName: item.icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 26, height: 26)
                .background(tint.opacity(0.12), in: .rect(cornerRadius: 7))

            Text(item.title)
                .font(.system(size: 10, weight: .black))
                .tracking(0.5)
                .foregroundStyle(.white.opacity(0.5))
                .textCase(.uppercase)
                .frame(width: 104, alignment: .leading)

            Text(item.value)
                .font(.system(size: 15, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundStyle(.white.opacity(0.9))
                .frame(width: 48, alignment: .trailing)

            Text(item.detail)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.58))
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(Color.white.opacity(0.035), in: .rect(cornerRadius: 11))
    }

    private var achievementChips: some View {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        let prsThisMonth = vm.personalRecords.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }.count
        let thisWeek = vm.workoutHistory.filter { $0.startTime > weekAgo && $0.isCompleted }
        let lastWeek = vm.workoutHistory.filter { $0.startTime > twoWeeksAgo && $0.startTime <= weekAgo && $0.isCompleted }
        let volumeThis = thisWeek.reduce(0.0) { $0 + $1.totalVolume }
        let volumeLast = lastWeek.reduce(0.0) { $0 + $1.totalVolume }
        let consistencyTarget = max(1, min(vm.profile.daysPerWeek, 4))

        return LazyVGrid(columns: [GridItem(.adaptive(minimum: 108), spacing: 8)], alignment: .leading, spacing: 8) {
            if prsThisMonth > 0 {
                STRQCelebrationBadge(title: L10n.tr("PR"), subtitle: L10n.format("%d this month", prsThisMonth), icon: "trophy.fill", variant: .gold)
            }
            if vm.streak > 1 {
                STRQCelebrationBadge(title: L10n.tr("Streak"), subtitle: L10n.format("%d days", vm.streak), icon: "flame.fill", variant: .gold)
            }
            if volumeLast > 0 && volumeThis > volumeLast {
                STRQCelebrationBadge(title: L10n.tr("Volume up"), icon: "chart.line.uptrend.xyaxis", variant: .green)
            }
            if vm.weeklyStats.sessions >= consistencyTarget {
                STRQCelebrationBadge(title: L10n.tr("Consistency"), icon: "checkmark.seal.fill", variant: .green)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - What's Improving

    private struct ImprovementSignal {
        let title: String
        let detail: String
        let icon: String
        let state: STRQPalette.State
    }

    private var whatsImprovingCard: some View {
        let signal = strongestImprovementSignal
        let tint = STRQPalette.color(for: signal.state)

        return VStack(alignment: .leading, spacing: 13) {
            HStack(spacing: 8) {
                Text(L10n.tr("EVIDENCE SIGNAL"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.1)
                    .foregroundStyle(STRQBrand.steel)
                Spacer(minLength: 0)
                Text(proofMaturityCopy.eyebrow)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(tint)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(tint.opacity(0.12), in: Capsule())
            }

            HStack(alignment: .center, spacing: 12) {
                STRQPulseMark(size: 44, tint: tint) {
                    Image(systemName: signal.icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(tint)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(signal.title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(signal.detail)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }

            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)

            HStack(alignment: .top, spacing: 10) {
                evidenceMeta(
                    title: L10n.tr("Trust now"),
                    detail: evidenceTrustNow,
                    icon: "checkmark.seal"
                )
                evidenceMeta(
                    title: L10n.tr("Still forming"),
                    detail: evidenceStillForming,
                    icon: "circle.dashed"
                )
            }
        }
        .padding(14)
        .background(
            LinearGradient(
                colors: [Color(white: 0.13), Color(white: 0.065)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(tint.opacity(0.24), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 6)
    }

    private var evidenceTrustNow: String {
        if vm.totalCompletedWorkouts == 0 {
            return L10n.tr("Nothing yet")
        }
        if vm.hasEnoughDataForStrengthChart {
            return L10n.tr("Strength trend")
        }
        if vm.weeklyStats.sessions > 0 {
            return L10n.tr("Logged sessions")
        }
        return L10n.tr("First signal")
    }

    private var evidenceStillForming: String {
        if vm.totalCompletedWorkouts < 2 {
            return L10n.tr("Training baseline")
        }
        if !hasTrustworthyMuscleBalance {
            return L10n.tr("Muscle balance")
        }
        if vm.bodyWeightEntries.count < 2 && vm.nutritionLogs.isEmpty && vm.goalPace == nil {
            return L10n.tr("Body trend")
        }
        return L10n.tr("Longer pattern")
    }

    private func evidenceMeta(title: String, detail: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(STRQBrand.steel)
                .frame(width: 20, height: 20)
                .background(STRQBrand.steel.opacity(0.1), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 9, weight: .black))
                    .tracking(0.5)
                    .foregroundStyle(.white.opacity(0.44))
                    .textCase(.uppercase)
                Text(detail)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.72))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var strongestImprovementSignal: ImprovementSignal {
        if vm.totalCompletedWorkouts < 3 {
            let countLabel = vm.totalCompletedWorkouts == 1 ? L10n.tr("workout logged") : L10n.tr("workouts logged")
            return ImprovementSignal(
                title: vm.totalCompletedWorkouts == 0 ? L10n.tr("Baseline forming") : L10n.tr("First signal forming"),
                detail: "\(vm.totalCompletedWorkouts) \(countLabel)",
                icon: "waveform.path.ecg",
                state: .info
            )
        }

        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        let thisWeek = vm.workoutHistory.filter { $0.startTime > weekAgo && $0.isCompleted }
        let lastWeek = vm.workoutHistory.filter { $0.startTime > twoWeeksAgo && $0.startTime <= weekAgo && $0.isCompleted }
        let volumeThis = thisWeek.reduce(0.0) { $0 + $1.totalVolume }
        let volumeLast = lastWeek.reduce(0.0) { $0 + $1.totalVolume }
        let prsThisMonth = vm.personalRecords.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }.count
        let progressing = vm.progressingExercises.count
        let consistencyTarget = max(1, min(vm.profile.daysPerWeek, 4))

        if prsThisMonth > 0 {
            return ImprovementSignal(
                title: prsThisMonth == 1 ? L10n.tr("PR this month") : L10n.tr("PRs this month"),
                detail: L10n.format("%d this month", prsThisMonth),
                icon: "trophy.fill",
                state: .gold
            )
        }

        if progressing > 0 {
            return ImprovementSignal(
                title: L10n.format(progressing == 1 ? "%d lift progressing" : "%d lifts progressing", progressing),
                detail: L10n.tr("Strength signal is active"),
                icon: "arrow.up.right.circle.fill",
                state: .success
            )
        }

        if volumeLast > 0 && volumeThis > volumeLast {
            let pct = Int((volumeThis - volumeLast) / volumeLast * 100)
            return ImprovementSignal(
                title: L10n.format("Volume up %d%%", pct),
                detail: L10n.tr("More work than last week"),
                icon: "chart.line.uptrend.xyaxis",
                state: .success
            )
        }

        if vm.weeklyStats.sessions >= consistencyTarget {
            return ImprovementSignal(
                title: L10n.tr("Consistency is building"),
                detail: L10n.format("%d workouts", vm.weeklyStats.sessions),
                icon: "flame.fill",
                state: .success
            )
        }

        if let muscle = strongestMuscleThisWeek {
            return ImprovementSignal(
                title: L10n.format("%@ is your main focus", muscle.localizedDisplayName),
                detail: L10n.tr("Primary focus this week"),
                icon: muscle.symbolName,
                state: .neutral
            )
        }

        if vm.effectiveRecoveryScore >= 70 {
            return ImprovementSignal(
                title: L10n.tr("Recovery is supporting training"),
                detail: L10n.format("%d%% recovery score", vm.effectiveRecoveryScore),
                icon: "heart.fill",
                state: .success
            )
        }

        return ImprovementSignal(
            title: L10n.tr("You're building momentum"),
            detail: L10n.format("%d workouts", vm.totalCompletedWorkouts),
            icon: "checkmark.seal.fill",
            state: .neutral
        )
    }

    private var strongestMuscleThisWeek: MuscleGroup? {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        var counts: [MuscleGroup: Int] = [:]
        for session in vm.workoutHistory where session.startTime > weekAgo && session.isCompleted {
            for log in session.exerciseLogs {
                let completedSetCount = log.sets.filter(\.isCompleted).count
                guard completedSetCount > 0, let exercise = vm.library.exercise(byId: log.exerciseId) else { continue }
                counts[exercise.primaryMuscle, default: 0] += completedSetCount
            }
        }
        return counts.max { lhs, rhs in lhs.value < rhs.value }?.key
    }

    // MARK: - What Changed Strip

    private var whatChangedStrip: some View {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        let thisWeek = vm.workoutHistory.filter { $0.startTime > weekAgo && $0.isCompleted }
        let lastWeek = vm.workoutHistory.filter { $0.startTime > twoWeeksAgo && $0.startTime <= weekAgo && $0.isCompleted }
        let volumeThis = thisWeek.reduce(0.0) { $0 + $1.totalVolume }
        let volumeLast = lastWeek.reduce(0.0) { $0 + $1.totalVolume }
        let progressing = vm.progressingExercises.count
        let stalled = vm.stalledExercises.count
        let prsThisWeek = vm.personalRecords.filter { $0.date > weekAgo }.count

        let state: STRQPalette.State
        let headline: String
        let detail: String
        let icon: String

        if vm.isEarlyStage {
            state = .info
            icon = vm.totalCompletedWorkouts == 0 ? "arrow.forward.circle.fill" : "waveform.path.ecg"
            headline = vm.totalCompletedWorkouts == 0 ? L10n.tr("Your baseline starts with Today") : L10n.tr("Early signals are forming")
            detail = vm.totalCompletedWorkouts == 0
                ? L10n.tr("One workout gives Progress real training signal to read.")
                : L10n.tr("First trends form after a few more workouts.")
        } else if prsThisWeek > 0 {
            state = .success
            icon = "trophy.fill"
            headline = L10n.format(prsThisWeek == 1 ? "%d new PR this week" : "%d new PRs this week", prsThisWeek)
            detail = progressing > 0 ? L10n.format(progressing == 1 ? "%d lift still progressing" : "%d lifts still progressing", progressing) : L10n.tr("Strength is moving")
        } else if progressing > stalled && progressing > 0 {
            state = .success
            icon = "arrow.up.right"
            headline = L10n.format(progressing == 1 ? "%d lift progressing" : "%d lifts progressing", progressing)
            detail = stalled > 0 ? L10n.format("%d needs attention", stalled) : L10n.tr("Momentum on your side")
        } else if stalled > progressing && stalled > 0 {
            state = .warning
            icon = "arrow.right"
            headline = L10n.format(stalled == 1 ? "%d lift flat" : "%d lifts flat", stalled)
            detail = progressing > 0 ? L10n.format("%d still progressing", progressing) : L10n.tr("Consider a variation or reset")
        } else if volumeThis > volumeLast && volumeLast > 0 {
            let pct = Int((volumeThis - volumeLast) / volumeLast * 100)
            state = .success
            icon = "chart.line.uptrend.xyaxis"
            headline = L10n.format("Volume up %d%%", pct)
            detail = L10n.tr("More work than last week")
        } else if volumeLast > 0 && volumeThis < volumeLast * 0.85 {
            state = .warning
            icon = "chart.line.downtrend.xyaxis"
            headline = L10n.tr("Lighter week")
            detail = L10n.tr("Volume down vs last week")
        } else {
            state = .neutral
            icon = "equal.circle"
            headline = L10n.tr("Holding steady")
            detail = L10n.tr("Consistent output across the week")
        }

        return HStack(alignment: .center, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(STRQPalette.color(for: state))
                .frame(width: 36, height: 36)
                .background(STRQPalette.soft(for: state), in: .rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(L10n.tr("WHAT CHANGED"))
                        .font(.system(size: 9, weight: .black))
                        .tracking(1.1)
                        .foregroundStyle(.tertiary)
                    Text(L10n.tr("· 7 days"))
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.quaternary)
                }
                Text(headline)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(white: 0.095), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQPalette.color(for: state).opacity(0.18), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 6)
    }

    // MARK: - Momentum Breakdown

    @ViewBuilder
    private var momentumBreakdown: some View {
        let progressing = vm.progressingExercises
        let stalled = vm.stalledExercises
        let nutritionOn = vm.profile.nutritionTrackingEnabled
        let physique = vm.physiqueOutcome

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ForgeSectionHeader(title: L10n.tr("Proof Runway"))
                Spacer()
                Text(L10n.tr("strength · body · consistency"))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.tertiary)
            }

            VStack(spacing: 8) {
                momentumPill(
                    icon: "arrow.up.right",
                    title: L10n.tr("Strength"),
                    state: progressing.count > stalled.count ? .success : (stalled.count > 0 ? .warning : .neutral),
                    detail: {
                        if progressing.isEmpty && stalled.isEmpty { return L10n.tr("Calibrating") }
                        var parts: [String] = []
                        if !progressing.isEmpty { parts.append(L10n.format("%d progressing", progressing.count)) }
                        if !stalled.isEmpty { parts.append(L10n.format("%d flat", stalled.count)) }
                        return parts.joined(separator: " · ")
                    }()
                )

                if nutritionOn, let physique {
                    momentumPill(
                        icon: "figure.arms.open",
                        title: L10n.tr("Physique"),
                        state: mapVerdictState(physique.paceVerdict),
                        detail: physique.summary ?? L10n.tr("Calibrating")
                    )
                }

                momentumPill(
                    icon: "flame.fill",
                    title: L10n.tr("Consistency"),
                    state: vm.streak >= 7 ? .success : (vm.streak >= 3 ? .info : .neutral),
                    detail: vm.streak > 0 ? L10n.format("%d-day streak · %d workouts logged", vm.streak, vm.totalCompletedWorkouts) : L10n.tr("Start fresh today")
                )
            }
        }
        .padding(14)
        .background(Color(white: 0.105), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private func momentumPill(icon: String, title: String, state: STRQPalette.State, detail: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(STRQPalette.color(for: state))
                .frame(width: 26, height: 26)
                .background(STRQPalette.soft(for: state), in: .rect(cornerRadius: 7))
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 10, weight: .black))
                    .tracking(0.6)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Text(detail)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Circle()
                .fill(STRQPalette.color(for: state))
                .frame(width: 6, height: 6)
        }
    }

    private func mapVerdictState(_ v: PhysiquePaceVerdict) -> STRQPalette.State {
        switch v {
        case .onTrack, .aligned: return .success
        case .tooSlow, .tooFast: return .warning
        case .drifting: return .danger
        case .noSignal: return .neutral
        }
    }

    // MARK: - Signal Strip

    private var signalStrip: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(spacing: 8) {
                Text(L10n.tr("KEY PROOF POINTS"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.1)
                    .foregroundStyle(STRQBrand.steel)
                Spacer(minLength: 0)
                Text(vm.isEarlyStage ? L10n.tr("forming") : L10n.tr("active"))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.04), in: Capsule())
            }

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                metricProofPoint(icon: metricItems[0].icon, value: metricItems[0].value, label: metricItems[0].label, caption: metricItems[0].caption, color: metricItems[0].color)
                metricProofPoint(icon: metricItems[1].icon, value: metricItems[1].value, label: metricItems[1].label, caption: metricItems[1].caption, color: metricItems[1].color)
                metricProofPoint(icon: metricItems[2].icon, value: metricItems[2].value, label: metricItems[2].label, caption: metricItems[2].caption, color: metricItems[2].color)
                metricProofPoint(icon: metricItems[3].icon, value: metricItems[3].value, label: metricItems[3].label, caption: metricItems[3].caption, color: metricItems[3].color)
            }
        }
        .padding(14)
        .background(Color(white: 0.095), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
    }

    private var metricItems: [(icon: String, value: String, label: String, caption: String, color: Color)] {
        if vm.isEarlyStage {
            return [
                ("figure.strengthtraining.traditional", "\(vm.totalCompletedWorkouts)", L10n.tr("Logged"), vm.totalCompletedWorkouts == 0 ? L10n.tr("baseline forming") : L10n.tr("first signal"), STRQBrand.steel),
                ("calendar.badge.clock", "\(vm.weeklyStats.sessions)/\(max(1, min(3, vm.profile.daysPerWeek)))", L10n.tr("Target"), L10n.tr("building pattern"), STRQBrand.steel),
                ("flame.fill", "\(vm.streak)", L10n.tr("Streak"), vm.streak > 0 ? L10n.tr("active") : L10n.tr("not started"), STRQBrand.steel),
                ("heart.fill", "\(vm.effectiveRecoveryScore)%", L10n.tr("Recovery"), L10n.tr("context"), ForgeTheme.recoveryColor(for: vm.effectiveRecoveryScore))
            ]
        } else {
            return [
                ("arrow.up.right", "\(vm.progressingExercises.count)", L10n.tr("Progressing"), vm.progressingExercises.isEmpty ? L10n.tr("watching") : L10n.tr("moving"), STRQPalette.success),
                ("flame.fill", "\(vm.streak)", L10n.tr("Streak"), vm.streak > 0 ? L10n.tr("current run") : L10n.tr("ready"), STRQBrand.steel),
                ("figure.strengthtraining.traditional", "\(vm.totalCompletedWorkouts)", L10n.tr("Workouts"), L10n.tr("history"), STRQBrand.steel),
                ("heart.fill", "\(vm.effectiveRecoveryScore)%", L10n.tr("Recovery"), L10n.tr("context"), ForgeTheme.recoveryColor(for: vm.effectiveRecoveryScore))
            ]
        }
    }

    private func metricProofPoint(icon: String, value: String, label: String, caption: String, color: Color) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.1), in: .rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(.subheadline, design: .rounded, weight: .heavy).monospacedDigit())
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.72)
                        .lineLimit(1)
                    Text(label)
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.3)
                        .foregroundStyle(.white.opacity(0.48))
                        .textCase(.uppercase)
                        .lineLimit(1)
                }
                Text(caption)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.44))
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.035), in: .rect(cornerRadius: 12))
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 6) {
            ForEach(Array(progressTabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .snappy(duration: 0.25)) { selectedTab = index }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 11, weight: .bold))
                        Text(tab.title)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundStyle(selectedTab == index ? .white : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(
                        selectedTab == index
                            ? AnyShapeStyle(LinearGradient(colors: [STRQBrand.steel.opacity(0.28), STRQBrand.slate.opacity(0.12)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            : AnyShapeStyle(Color.white.opacity(0.02)),
                        in: .rect(cornerRadius: 10)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(selectedTab == index ? STRQBrand.steel.opacity(0.36) : Color.clear, lineWidth: 1)
                    )
                }
            }
        }
        .padding(4)
        .background(Color(white: 0.085), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
        .sensoryFeedback(.selection, trigger: selectedTab)
    }

    private var progressTabs: [(title: String, icon: String)] {
        [
            (L10n.tr("Strength"), "chart.line.uptrend.xyaxis"),
            (L10n.tr("Body"), "heart.text.square"),
            (L10n.tr("Volume"), "chart.bar.xaxis")
        ]
    }

    // MARK: - Strength Signals

    private struct StrengthTrendSnapshot {
        let stateLabel: String
        let state: STRQPalette.State
        let anchorWeeks: Int
        let caption: String
        let detail: String
    }

    private var strengthTrendSnapshot: StrengthTrendSnapshot {
        let anchorWeeks = vm.strengthProgress.count

        if vm.hasEnoughDataForStrengthChart {
            return StrengthTrendSnapshot(
                stateLabel: L10n.tr("Readable trend"),
                state: .info,
                anchorWeeks: anchorWeeks,
                caption: L10n.tr("Estimated 1RM movement anchors"),
                detail: L10n.tr("Repeated logged sets are enough to draw the existing 8-week estimate. Treat this as strength signal, not a PR claim.")
            )
        }

        if anchorWeeks > 0 || vm.totalCompletedWorkouts > 0 {
            return StrengthTrendSnapshot(
                stateLabel: L10n.tr("Early signal"),
                state: .warning,
                anchorWeeks: anchorWeeks,
                caption: L10n.tr("Anchor evidence is present"),
                detail: L10n.tr("Logged sets are real proof, but repeated anchor evidence is still thin. The chart stays quiet until the existing gate passes.")
            )
        }

        return StrengthTrendSnapshot(
            stateLabel: L10n.tr("Baseline forming"),
            state: .warning,
            anchorWeeks: anchorWeeks,
            caption: L10n.tr("Strength record is waiting"),
            detail: L10n.tr("Your first completed workout starts the strength record. STRQ waits for repeated lift evidence before drawing a trend.")
        )
    }

    @ViewBuilder
    private var strengthSignals: some View {
        VStack(spacing: 14) {
            if vm.hasEnoughDataForStrengthChart {
                strengthChart
            } else {
                strengthBaselineCard
            }
            if !vm.isEarlyStage || !vm.personalRecords.isEmpty {
                prHighlights
            }
            recentSessionsCard
            weeklyRhythmModule
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private var strengthBaselineCard: some View {
        let snapshot = strengthTrendSnapshot
        let tint = STRQPalette.color(for: snapshot.state)

        return evidenceModule(border: tint.opacity(0.2)) {
            VStack(alignment: .leading, spacing: 16) {
                evidenceHeader(
                    title: L10n.tr("Strength Trend"),
                    trailing: snapshot.stateLabel,
                    icon: "chart.line.uptrend.xyaxis",
                    state: snapshot.state,
                    subtitle: L10n.tr("Estimated 1RM from logged sets")
                )

                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text("\(snapshot.anchorWeeks)")
                        .font(.system(size: 34, weight: .heavy, design: .rounded).monospacedDigit())
                        .foregroundStyle(snapshot.anchorWeeks > 0 ? tint : .white.opacity(0.68))
                    Text(L10n.tr("anchor weeks"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.5))
                        .padding(.bottom, 6)
                    Spacer(minLength: 0)
                    evidenceChip(icon: "circle.dashed", text: L10n.tr("No PR claim"), state: .neutral)
                }

                plotShell(height: 118) {
                    strengthTrendSkeleton(anchorWeeks: snapshot.anchorWeeks, tint: tint)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(snapshot.caption)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                    Text(snapshot.detail)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.58))
                        .fixedSize(horizontal: false, vertical: true)
                }

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                    trendProofMetric(
                        title: L10n.tr("Signal"),
                        value: snapshot.stateLabel,
                        detail: L10n.tr("confidence"),
                        icon: "waveform.path.ecg",
                        state: snapshot.state
                    )
                    trendProofMetric(
                        title: L10n.tr("Window"),
                        value: L10n.tr("8 weeks"),
                        detail: L10n.tr("existing chart"),
                        icon: "calendar",
                        state: .neutral
                    )
                }
            }
        }
    }

    private func strengthTrendSkeleton(anchorWeeks: Int, tint: Color) -> some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)
            let markerInset: CGFloat = 8
            let markerWidth = max(width - markerInset * 2, 1)

            ZStack {
                VStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.white.opacity(0.05))
                            .frame(height: 1)
                        Spacer(minLength: 0)
                    }
                }

                Path { path in
                    path.move(to: CGPoint(x: 0, y: height * 0.62))
                    path.addLine(to: CGPoint(x: width, y: height * 0.62))
                }
                .stroke(tint.opacity(0.34), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [7, 8]))

                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .strokeBorder(tint.opacity(index < anchorWeeks ? 0.42 : 0.15), lineWidth: 2)
                        .background(
                            Circle()
                                .fill(index < anchorWeeks ? tint.opacity(0.16) : Color.white.opacity(0.025))
                        )
                        .frame(width: 12, height: 12)
                        .position(
                            x: markerInset + markerWidth * CGFloat(index) / 5,
                            y: height * (0.36 + CGFloat(index % 3) * 0.12)
                        )
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func trendProofMetric(title: String, value: String, detail: String, icon: String, state: STRQPalette.State) -> some View {
        let tint = STRQPalette.color(for: state)

        return HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 25, height: 25)
                .background(tint.opacity(0.1), in: .rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 9, weight: .black))
                    .tracking(0.5)
                    .foregroundStyle(.white.opacity(0.42))
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 14, weight: .heavy, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                        .minimumScaleFactor(0.62)
                    Text(detail)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.48))
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(Color.white.opacity(0.03), in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white.opacity(0.065), lineWidth: 1)
        )
    }

    private var strengthChart: some View {
        let entries = vm.strengthProgress
        let snapshot = strengthTrendSnapshot
        let tint = STRQPalette.color(for: snapshot.state)

        return evidenceModule(border: tint.opacity(0.2)) {
            VStack(alignment: .leading, spacing: 16) {
                evidenceHeader(
                    title: L10n.tr("Strength Trend"),
                    trailing: snapshot.stateLabel,
                    icon: "chart.line.uptrend.xyaxis",
                    state: snapshot.state,
                    subtitle: L10n.tr("Estimated 1RM movement anchors")
                )

                HStack(alignment: .top, spacing: 10) {
                    trendProofMetric(
                        title: L10n.tr("Evidence"),
                        value: "\(snapshot.anchorWeeks)",
                        detail: L10n.tr("anchor weeks"),
                        icon: "checkmark.seal",
                        state: snapshot.state
                    )
                    trendProofMetric(
                        title: L10n.tr("Claim"),
                        value: L10n.tr("Signal"),
                        detail: L10n.tr("not PRs"),
                        icon: "exclamationmark.shield",
                        state: .neutral
                    )
                }

                Text(snapshot.detail)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.58))
                    .fixedSize(horizontal: false, vertical: true)

                plotShell(height: 186) {
                    Chart {
                        ForEach(entries) { entry in
                            LineMark(x: .value("Week", entry.date), y: .value("Weight", entry.bench), series: .value("Anchor", "Push anchor"))
                                .foregroundStyle(Color.white).interpolationMethod(.catmullRom).symbol(.circle)
                            LineMark(x: .value("Week", entry.date), y: .value("Weight", entry.squat), series: .value("Anchor", "Squat pattern"))
                                .foregroundStyle(STRQBrand.steel).interpolationMethod(.catmullRom).symbol(.square)
                            LineMark(x: .value("Week", entry.date), y: .value("Weight", entry.deadlift), series: .value("Anchor", "Hinge pattern"))
                                .foregroundStyle(STRQBrand.slate).interpolationMethod(.catmullRom).symbol(.triangle)
                        }
                    }
                    .chartYScale(domain: .automatic(includesZero: false))
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3)).foregroundStyle(Color.white.opacity(0.12))
                            AxisValueLabel().foregroundStyle(Color.secondary)
                        }
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .weekOfYear, count: 2)) { _ in
                            AxisValueLabel(format: .dateTime.month(.abbreviated).day()).foregroundStyle(Color.secondary)
                        }
                    }
                    .chartForegroundStyleScale(["Push anchor": Color.white, "Squat pattern": STRQBrand.steel, "Hinge pattern": STRQBrand.slate])
                }

                HStack(spacing: 16) {
                    legendDot(color: .white, label: L10n.tr("Push anchor"))
                    legendDot(color: STRQBrand.steel, label: L10n.tr("Squat pattern"))
                    legendDot(color: STRQBrand.slate, label: L10n.tr("Hinge pattern"))
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label).font(.caption.weight(.medium)).foregroundStyle(.secondary)
        }
    }

    private func evidenceModule<Content: View>(
        cornerRadius: CGFloat = 18,
        border: Color = STRQBrand.cardBorder,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(16)
            .background(
                LinearGradient(
                    colors: [Color(white: 0.108), Color(white: 0.066)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: .rect(cornerRadius: cornerRadius)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(border, lineWidth: 1)
            )
            .overlay(alignment: .top) {
                border.opacity(0.62)
                    .frame(height: 1)
                    .clipShape(.rect(cornerRadii: .init(topLeading: cornerRadius, bottomLeading: 0, bottomTrailing: 0, topTrailing: cornerRadius)))
            }
            .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
    }

    private func evidenceHeader(
        title: String,
        trailing: String? = nil,
        icon: String,
        state: STRQPalette.State = .info,
        subtitle: String? = nil
    ) -> some View {
        let tint = STRQPalette.color(for: state)

        return HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.12), in: .rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 10, weight: .black))
                    .tracking(0.8)
                    .foregroundStyle(.white.opacity(0.52))
                    .textCase(.uppercase)
                if let subtitle {
                    Text(subtitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.78))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 0)

            if let trailing {
                evidenceBadge(trailing, state: state)
            }
        }
    }

    private func evidenceBadge(_ text: String, state: STRQPalette.State = .info) -> some View {
        let tint = STRQPalette.color(for: state)

        return Text(text)
            .font(.system(size: 10, weight: .bold, design: .rounded).monospacedDigit())
            .foregroundStyle(tint)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(tint.opacity(0.12), in: Capsule())
    }

    private func evidenceChip(icon: String, text: String, state: STRQPalette.State = .neutral) -> some View {
        let tint = STRQPalette.color(for: state)

        return HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 9, weight: .semibold))
            Text(text)
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(STRQPalette.soft(for: state), in: Capsule())
    }

    private func plotShell<Content: View>(
        height: CGFloat,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .frame(height: height)
            .padding(.horizontal, 4)
            .padding(.vertical, 10)
            .background(Color.white.opacity(0.025), in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
            )
    }

    private var prHighlights: some View {
        let sortedPRs = vm.personalRecords.sorted { $0.date > $1.date }
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                ForgeSectionHeader(title: L10n.tr("Personal Records"))
                Spacer()
                if !sortedPRs.isEmpty {
                    Text("\(sortedPRs.count)")
                        .font(.system(size: 11, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(STRQBrand.steel)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(STRQBrand.steel.opacity(0.12), in: Capsule())
                }
            }

            if sortedPRs.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "trophy")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(L10n.tr("Heavy sets and rep bests will start surfacing here as your log grows."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 4)
            } else if let top = sortedPRs.first {
                featuredPRRow(top)
                if sortedPRs.count > 1 {
                    Rectangle().fill(Color.white.opacity(0.05)).frame(height: 0.5)
                    VStack(spacing: 8) {
                        ForEach(Array(sortedPRs.dropFirst().prefix(3)), id: \.id) { pr in
                            compactPRRow(pr)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(white: 0.095), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private func featuredPRRow(_ pr: PersonalRecord) -> some View {
        HStack(alignment: .center, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(STRQPalette.goldSoft)
                    .frame(width: 44, height: 44)
                Image(systemName: "trophy.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(STRQPalette.goldGradient)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.tr("LATEST PR"))
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(STRQPalette.gold)
                Text(vm.library.exercise(byId: pr.exerciseId)?.name ?? pr.exerciseId)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(pr.date.formatted(.dateTime.month(.abbreviated).day().year()))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            Spacer(minLength: 0)
            VStack(alignment: .trailing, spacing: 2) {
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text("\(Int(pr.weight))")
                        .font(.system(size: 22, weight: .heavy, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white)
                    Text(L10n.tr("kg"))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Text(L10n.format("× %d · e1RM %d", pr.reps, Int(pr.estimatedOneRepMax)))
                    .font(.caption2.weight(.medium).monospacedDigit())
                    .foregroundStyle(.tertiary)
            }
        }
    }

    private func compactPRRow(_ pr: PersonalRecord) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 10))
                .foregroundStyle(STRQPalette.gold)
                .frame(width: 20)
            Text(vm.library.exercise(byId: pr.exerciseId)?.name ?? pr.exerciseId)
                .font(.caption.weight(.medium))
                .lineLimit(1)
            Spacer(minLength: 8)
            Text(L10n.format("%dkg × %d", Int(pr.weight), pr.reps))
                .font(.system(size: 11, weight: .semibold, design: .rounded).monospacedDigit())
                .foregroundStyle(.secondary)
            Text(pr.date.formatted(.dateTime.month(.abbreviated).day()))
                .font(.caption2.monospacedDigit())
                .foregroundStyle(.tertiary)
                .frame(width: 52, alignment: .trailing)
        }
    }

    // MARK: - Recent Improvement

    private var recentImprovementCard: some View {
        let calendar = Calendar.current
        let now = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: now) ?? now
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: now) ?? now
        let thisWeek = vm.workoutHistory.filter { $0.startTime > weekAgo && $0.isCompleted }
        let lastWeek = vm.workoutHistory.filter { $0.startTime > twoWeeksAgo && $0.startTime <= weekAgo && $0.isCompleted }
        let volumeThis = thisWeek.reduce(0.0) { $0 + $1.totalVolume }
        let volumeLast = lastWeek.reduce(0.0) { $0 + $1.totalVolume }
        let volumeDelta = volumeThis - volumeLast
        let sessionsDelta = thisWeek.count - lastWeek.count
        let prsThisWeek = vm.personalRecords.filter { $0.date > weekAgo }.count
        let progressing = vm.progressingExercises.count

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text(L10n.tr("RECENT PROOF"))
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(L10n.tr("vs last week"))
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.tertiary)
            }

            HStack(spacing: 8) {
                improvementCell(
                    label: L10n.tr("Volume"),
                    delta: volumeDelta == 0 ? "—" : String(format: "%@%@", volumeDelta > 0 ? "+" : "", ForgeTheme.formatVolume(volumeDelta)),
                    unit: volumeDelta == 0 ? nil : L10n.tr("kg"),
                    positive: volumeDelta > 0,
                    negative: volumeDelta < 0 && volumeLast > 0
                )
                improvementCell(
                    label: L10n.tr("Workouts"),
                    delta: sessionsDelta == 0 ? "\(thisWeek.count)" : String(format: "%@%d", sessionsDelta > 0 ? "+" : "", sessionsDelta),
                    unit: nil,
                    positive: sessionsDelta > 0,
                    negative: sessionsDelta < 0
                )
                improvementCell(
                    label: L10n.tr("New PRs"),
                    delta: "\(prsThisWeek)",
                    unit: nil,
                    positive: prsThisWeek > 0,
                    negative: false
                )
                improvementCell(
                    label: L10n.tr("Progressing"),
                    delta: "\(progressing)",
                    unit: nil,
                    positive: progressing > 0,
                    negative: false
                )
            }
        }
        .padding(14)
        .background(Color(white: 0.095), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private func improvementCell(label: String, delta: String, unit: String?, positive: Bool, negative: Bool) -> some View {
        let color: Color = positive ? STRQPalette.success : (negative ? STRQPalette.warning : .secondary)
        return VStack(alignment: .leading, spacing: 3) {
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text(delta)
                    .font(.system(size: 15, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(color)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if let unit {
                    Text(unit)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(color.opacity(0.6))
                }
            }
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.3)
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.03), in: .rect(cornerRadius: 10))
    }

    // MARK: - Recent Evidence

    private var recentSessionsCard: some View {
        let snapshot = recentEvidenceSnapshot
        let tint = STRQPalette.color(for: snapshot.state)

        return evidenceModule(border: tint.opacity(0.18)) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "list.bullet.rectangle.portrait.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(tint)
                        .frame(width: 30, height: 30)
                        .background(tint.opacity(0.12), in: .rect(cornerRadius: 8))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(L10n.tr("Recent Evidence"))
                            .font(.system(size: 10, weight: .black))
                            .tracking(0.8)
                            .foregroundStyle(.white.opacity(0.52))
                            .textCase(.uppercase)
                        Text(snapshot.subtitle)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.78))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    if snapshot.hasEvents {
                        NavigationLink(value: ProgressRoute.history) {
                            HStack(spacing: 4) {
                                Text(L10n.tr("History"))
                                    .font(.caption.weight(.semibold))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 9, weight: .bold))
                            }
                            .foregroundStyle(tint)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 5)
                            .background(tint.opacity(0.11), in: Capsule())
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 11) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(snapshot.countValue)
                            .font(.system(size: 28, weight: .heavy, design: .rounded).monospacedDigit())
                            .foregroundStyle(.white.opacity(0.94))
                            .lineLimit(1)
                        Text(snapshot.countDetail)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.56))
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                        Spacer(minLength: 0)
                        evidenceBadge(snapshot.stateLabel, state: snapshot.state)
                    }

                    Text(snapshot.detail)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.58))
                        .fixedSize(horizontal: false, vertical: true)

                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
                        ForEach(snapshot.metrics) { metric in
                            recentEvidenceMetric(metric)
                        }
                    }
                }
                .padding(12)
                .background(
                    LinearGradient(
                        colors: [tint.opacity(0.10), Color.white.opacity(0.022)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: .rect(cornerRadius: 14)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(tint.opacity(0.14), lineWidth: 1)
                )

                if snapshot.hasEvents {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 7) {
                            Circle()
                                .fill(tint)
                                .frame(width: 6, height: 6)
                            Text(L10n.tr("Latest sessions"))
                                .font(.system(size: 9, weight: .black))
                                .tracking(0.7)
                                .foregroundStyle(.white.opacity(0.46))
                                .textCase(.uppercase)
                            Spacer(minLength: 0)
                        }

                        VStack(spacing: 0) {
                            ForEach(Array(snapshot.events.enumerated()), id: \.element.id) { index, event in
                                recentEvidenceTimelineRow(
                                    event,
                                    isLast: index == snapshot.events.count - 1
                                )
                            }
                        }
                    }
                } else {
                    recentEvidenceEmptyState
                }
            }
        }
        .navigationDestination(for: ProgressRoute.self) { route in
            switch route {
            case .history: SessionHistoryView(vm: vm)
            }
        }
    }

    private var recentEvidenceSnapshot: RecentEvidenceSnapshot {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? Date()
        let windowStart = calendar.date(byAdding: .day, value: -27, to: today) ?? today
        let completedSessions = vm.workoutHistory
            .filter(\.isCompleted)
            .sorted { $0.startTime > $1.startTime }
        let sessionsInWindow = completedSessions.filter {
            $0.startTime >= windowStart && $0.startTime < tomorrow
        }
        let activeWeekStarts = Set(sessionsInWindow.map {
            calendar.dateInterval(of: .weekOfYear, for: $0.startTime)?.start ?? calendar.startOfDay(for: $0.startTime)
        })
        let activeWeeks = activeWeekStarts.count
        let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let currentWeekSessions = sessionsInWindow.filter { $0.startTime >= currentWeekStart }.count
        let target = max(1, min(vm.profile.daysPerWeek, 7))
        let recentRows = Array(completedSessions.prefix(5))
        let events = recentRows.enumerated().map { index, session in
            recentEvidenceEvent(
                session,
                previousSession: completedSessions.dropFirst(index + 1).first,
                isLatest: index == 0,
                calendar: calendar
            )
        }

        let state: STRQPalette.State
        let stateLabel: String
        let subtitle: String
        let detail: String
        switch sessionsInWindow.count {
        case 0:
            state = .neutral
            stateLabel = L10n.tr("Baseline forming")
            subtitle = L10n.tr("Training evidence starts with completed sessions")
            detail = L10n.tr("No completed workouts are shown here until real workout history exists.")
        case 1...2:
            state = .warning
            stateLabel = L10n.tr("Baseline forming")
            subtitle = L10n.tr("Real sessions logged, pattern still forming")
            detail = L10n.tr("STRQ has dated session evidence, but the recent baseline needs more completed workouts before it can explain a rhythm.")
        case 3...:
            if activeWeeks >= 2 {
                state = .info
                stateLabel = L10n.tr("Training evidence")
                subtitle = L10n.tr("Recent sessions shaping Progress")
                detail = L10n.tr("Completed workouts now span multiple weeks, enough to show which real sessions are shaping the current Progress picture.")
            } else {
                state = .warning
                stateLabel = L10n.tr("Building pattern")
                subtitle = L10n.tr("Recent sessions logged close together")
                detail = L10n.tr("STRQ has several completed workouts, but the weekly rhythm is still forming across the current evidence window.")
            }
        default:
            state = .neutral
            stateLabel = L10n.tr("Baseline forming")
            subtitle = L10n.tr("Training evidence starts with completed sessions")
            detail = L10n.tr("No completed workouts are shown here until real workout history exists.")
        }

        return RecentEvidenceSnapshot(
            state: state,
            stateLabel: stateLabel,
            subtitle: subtitle,
            detail: detail,
            countValue: "\(sessionsInWindow.count)",
            countDetail: L10n.tr("logged in 28d"),
            metrics: [
                RecentEvidenceMetric(
                    title: L10n.tr("Active weeks"),
                    value: "\(activeWeeks)",
                    detail: L10n.tr("of 4"),
                    icon: "calendar.badge.clock",
                    state: activeWeeks >= 2 ? .info : .neutral
                ),
                RecentEvidenceMetric(
                    title: L10n.tr("This week"),
                    value: "\(currentWeekSessions)",
                    detail: L10n.format("of %d", target),
                    icon: "checkmark.seal",
                    state: currentWeekSessions >= target ? .success : (currentWeekSessions > 0 ? .warning : .neutral)
                ),
                RecentEvidenceMetric(
                    title: L10n.tr("Source"),
                    value: "\(completedSessions.count)",
                    detail: L10n.tr("completed"),
                    icon: "list.bullet.rectangle.portrait",
                    state: completedSessions.isEmpty ? .neutral : .info
                ),
                RecentEvidenceMetric(
                    title: L10n.tr("Window"),
                    value: "28",
                    detail: L10n.tr("days"),
                    icon: "clock.arrow.circlepath",
                    state: .neutral
                )
            ],
            events: events
        )
    }

    private func recentEvidenceEvent(
        _ session: WorkoutSession,
        previousSession: WorkoutSession?,
        isLatest: Bool,
        calendar: Calendar
    ) -> RecentEvidenceEvent {
        let title = session.dayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? L10n.tr("Workout")
            : session.dayName
        let duration = session.endTime.map { max(0, Int($0.timeIntervalSince(session.startTime) / 60)) } ?? 0
        let sets = session.completedSetCount
        let reps = session.completedRepCount
        let exercises = session.distinctCompletedExerciseCount
        let volume = session.totalVolume
        let gapDays = previousSession.map {
            max(0, calendar.dateComponents([.day], from: calendar.startOfDay(for: $0.startTime), to: calendar.startOfDay(for: session.startTime)).day ?? 0)
        }

        let detail: String
        if sets > 0, duration > 0, volume > 0 {
            detail = L10n.format("Logged %d sets over %dmin with %@kg total volume.", sets, duration, ForgeTheme.formatVolume(volume))
        } else if sets > 0, volume > 0 {
            detail = L10n.format("Logged %d completed sets with %@kg total volume.", sets, ForgeTheme.formatVolume(volume))
        } else if sets > 0, exercises > 0 {
            detail = L10n.format("Logged %d completed sets across %d exercises.", sets, exercises)
        } else {
            detail = L10n.tr("Completed workout recorded from history.")
        }

        var chips: [RecentEvidenceChip] = [
            RecentEvidenceChip(icon: "checkmark.circle.fill", text: L10n.tr("Logged"), state: .success)
        ]
        if isLatest {
            chips.append(RecentEvidenceChip(icon: "clock", text: L10n.tr("Recent"), state: .info))
        }
        if let gapDays, gapDays <= 3 {
            chips.append(RecentEvidenceChip(icon: "calendar.badge.clock", text: L10n.tr("Building pattern"), state: .warning))
        } else if previousSession == nil, !isLatest {
            chips.append(RecentEvidenceChip(icon: "circle.dashed", text: L10n.tr("Baseline forming"), state: .neutral))
        }
        if duration > 0 {
            chips.append(RecentEvidenceChip(icon: "clock", text: L10n.format("%dmin", duration), state: .neutral))
        } else if sets > 0 {
            chips.append(RecentEvidenceChip(icon: "checkmark.seal", text: L10n.format("%d sets", sets), state: .neutral))
        }
        if volume > 0, chips.count < 4 {
            chips.append(RecentEvidenceChip(icon: "square.stack.3d.up.fill", text: L10n.format("%@kg", ForgeTheme.formatVolume(volume)), state: .neutral))
        } else if reps > 0, chips.count < 4 {
            chips.append(RecentEvidenceChip(icon: "number", text: L10n.format("%d reps", reps), state: .neutral))
        }

        return RecentEvidenceEvent(
            id: session.id,
            date: session.startTime,
            title: title,
            detail: detail,
            chips: Array(chips.prefix(4)),
            state: isLatest ? .info : .success
        )
    }

    private func recentEvidenceMetric(_ metric: RecentEvidenceMetric) -> some View {
        let tint = STRQPalette.color(for: metric.state)

        return HStack(spacing: 8) {
            Image(systemName: metric.icon)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 22, height: 22)
                .background(tint.opacity(0.10), in: .rect(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 1) {
                Text(metric.title)
                    .font(.system(size: 8, weight: .black))
                    .tracking(0.5)
                    .foregroundStyle(.white.opacity(0.42))
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(metric.value)
                        .font(.system(size: 13, weight: .heavy, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                    Text(metric.detail)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.48))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.03), in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
        )
    }

    private func recentEvidenceTimelineRow(_ event: RecentEvidenceEvent, isLast: Bool) -> some View {
        let tint = STRQPalette.color(for: event.state)

        return HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(tint.opacity(0.16))
                        .frame(width: 18, height: 18)
                    Circle()
                        .fill(tint)
                        .frame(width: 7, height: 7)
                }

                Rectangle()
                    .fill(isLast ? Color.clear : Color.white.opacity(0.10))
                    .frame(width: 1, height: isLast ? 0 : 58)
            }
            .frame(width: 20)

            VStack(alignment: .leading, spacing: 9) {
                HStack(alignment: .center, spacing: 8) {
                    VStack(spacing: 1) {
                        Text(event.date.formatted(.dateTime.month(.abbreviated)))
                            .font(.system(size: 8, weight: .black))
                            .tracking(0.6)
                            .foregroundStyle(.white.opacity(0.48))
                            .textCase(.uppercase)
                        Text(event.date.formatted(.dateTime.day()))
                            .font(.system(size: 17, weight: .heavy, design: .rounded).monospacedDigit())
                            .foregroundStyle(.white.opacity(0.92))
                    }
                    .frame(width: 40, height: 48)
                    .background(tint.opacity(0.10), in: .rect(cornerRadius: 11))
                    .overlay(
                        RoundedRectangle(cornerRadius: 11)
                            .strokeBorder(tint.opacity(0.16), lineWidth: 1)
                    )

                    VStack(alignment: .leading, spacing: 3) {
                        Text(event.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.92))
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                        Text(event.date.formatted(.dateTime.weekday(.abbreviated).hour().minute()))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.44))
                            .lineLimit(1)
                    }

                    Spacer(minLength: 0)
                }

                Text(event.detail)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.62))
                    .fixedSize(horizontal: false, vertical: true)

                FlowLayout(spacing: 6) {
                    ForEach(event.chips) { chip in
                        evidenceChip(icon: chip.icon, text: chip.text, state: chip.state)
                    }
                }
            }
            .padding(11)
            .background(Color.white.opacity(0.028), in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(0.065), lineWidth: 1)
            )
            .padding(.bottom, isLast ? 0 : 10)
        }
    }

    private var recentEvidenceEmptyState: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "circle.dashed")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(STRQBrand.steel)
                    .frame(width: 34, height: 34)
                    .background(STRQBrand.steel.opacity(0.10), in: Circle())

                VStack(alignment: .leading, spacing: 3) {
                    Text(L10n.tr("Baseline forming"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                    Text(L10n.tr("Complete workouts to create dated evidence with duration, sets, and volume when those fields exist in history."))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.58))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            FlowLayout(spacing: 6) {
                evidenceChip(icon: "checkmark.circle", text: L10n.tr("Logged"), state: .neutral)
                evidenceChip(icon: "calendar", text: L10n.tr("Workout date"), state: .neutral)
                evidenceChip(icon: "clock", text: L10n.tr("Duration"), state: .neutral)
                evidenceChip(icon: "square.stack.3d.up.fill", text: L10n.tr("Volume"), state: .neutral)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.025), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
        )
    }

    private struct RecentEvidenceSnapshot {
        let state: STRQPalette.State
        let stateLabel: String
        let subtitle: String
        let detail: String
        let countValue: String
        let countDetail: String
        let metrics: [RecentEvidenceMetric]
        let events: [RecentEvidenceEvent]

        var hasEvents: Bool { !events.isEmpty }
    }

    private struct RecentEvidenceMetric: Identifiable {
        let title: String
        let value: String
        let detail: String
        let icon: String
        let state: STRQPalette.State

        var id: String { "\(title)-\(value)-\(detail)" }
    }

    private struct RecentEvidenceEvent: Identifiable {
        let id: String
        let date: Date
        let title: String
        let detail: String
        let chips: [RecentEvidenceChip]
        let state: STRQPalette.State
    }

    private struct RecentEvidenceChip: Identifiable {
        let icon: String
        let text: String
        let state: STRQPalette.State

        var id: String { "\(icon)-\(text)" }
    }

    private struct WeeklyRhythmDay: Identifiable {
        let date: Date
        let sessionCount: Int
        let isToday: Bool

        var id: Date { date }
        var hasSession: Bool { sessionCount > 0 }
    }

    private struct WeeklyRhythmWeek: Identifiable {
        let startDate: Date
        let label: String
        let sessions: Int
        let target: Int
        let isCurrent: Bool

        var id: Date { startDate }
        var metTarget: Bool { sessions >= target }
        var ratio: Double { target > 0 ? min(Double(sessions) / Double(target), 1.0) : 0 }
    }

    private struct WeeklyRhythmSnapshot {
        let days: [WeeklyRhythmDay]
        let weeks: [WeeklyRhythmWeek]
        let daysWithSessions: Int
        let sessionsInWindow: Int
        let currentWeekSessions: Int
        let target: Int
        let activeWeeks: Int
        let targetWeeks: Int
        let stateLabel: String
        let detail: String
        let state: STRQPalette.State

        var currentWeekMetTarget: Bool { currentWeekSessions >= target }
    }

    private var weeklyRhythmModule: some View {
        let snapshot = weeklyRhythmSnapshot
        let stateTint = STRQPalette.color(for: snapshot.state)
        let completionTint = STRQPalette.success

        return evidenceModule(border: stateTint.opacity(snapshot.daysWithSessions > 0 ? 0.2 : 0.14)) {
            VStack(alignment: .leading, spacing: 14) {
                evidenceHeader(
                    title: L10n.tr("Weekly Rhythm"),
                    trailing: snapshot.stateLabel,
                    icon: "calendar.badge.clock",
                    state: snapshot.state,
                    subtitle: L10n.tr("Completed workout cadence")
                )

                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .lastTextBaseline, spacing: 5) {
                            Text("\(snapshot.daysWithSessions)")
                                .font(.system(size: 34, weight: .heavy, design: .rounded).monospacedDigit())
                                .foregroundStyle(snapshot.daysWithSessions > 0 ? completionTint : STRQBrand.steel)
                            Text(L10n.tr("/28 days"))
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.52))
                                .padding(.bottom, 4)
                        }

                        Text(snapshot.detail)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white.opacity(0.6))
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)

                    VStack(alignment: .trailing, spacing: 5) {
                        Text(L10n.tr("This week"))
                            .font(.system(size: 9, weight: .black))
                            .tracking(0.7)
                            .foregroundStyle(.white.opacity(0.42))
                            .textCase(.uppercase)
                        Text("\(snapshot.currentWeekSessions)/\(snapshot.target)")
                            .font(.system(size: 22, weight: .heavy, design: .rounded).monospacedDigit())
                            .foregroundStyle(snapshot.currentWeekMetTarget ? completionTint : stateTint)
                        Text(snapshot.currentWeekMetTarget ? L10n.tr("target reached") : L10n.tr("target forming"))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.5))
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.035), in: .rect(cornerRadius: 13))
                    .overlay(
                        RoundedRectangle(cornerRadius: 13)
                            .strokeBorder((snapshot.currentWeekMetTarget ? completionTint : stateTint).opacity(0.14), lineWidth: 1)
                    )
                }

                weeklyRhythmMetricGrid(snapshot)
                weeklyRhythmGrid(days: snapshot.days, completionTint: completionTint)
                weeklyRhythmWeekRows(snapshot.weeks, completionTint: completionTint, stateTint: stateTint)

                HStack(spacing: 10) {
                    evidenceChip(icon: "checkmark.circle", text: L10n.tr("Completed only"), state: .neutral)
                    Text(L10n.tr("Open days stay neutral; readiness check-ins do not count here."))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.tertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var weeklyRhythmSnapshot: WeeklyRhythmSnapshot {
        let calendar = Calendar.current
        let now = Date()
        let today = calendar.startOfDay(for: now)
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today) ?? now
        let windowStart = calendar.date(byAdding: .day, value: -27, to: today) ?? today
        let target = max(1, min(vm.profile.daysPerWeek, 7))
        let completedSessions = vm.workoutHistory.filter(\.isCompleted)
        let sessionsInWindow = completedSessions.filter { $0.startTime >= windowStart && $0.startTime < tomorrow }
        let sessionsByDay = Dictionary(grouping: sessionsInWindow) { session in
            calendar.startOfDay(for: session.startTime)
        }

        let days: [WeeklyRhythmDay] = (0..<28).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: windowStart) else { return nil }
            let day = calendar.startOfDay(for: date)
            return WeeklyRhythmDay(
                date: day,
                sessionCount: sessionsByDay[day]?.count ?? 0,
                isToday: calendar.isDateInToday(day)
            )
        }

        let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let weeks: [WeeklyRhythmWeek] = (0..<4).reversed().compactMap { weekOffset in
            guard
                let start = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: currentWeekStart),
                let end = calendar.date(byAdding: .day, value: 7, to: start)
            else { return nil }

            let count = completedSessions.filter { session in
                session.startTime >= start &&
                session.startTime < end &&
                session.startTime >= windowStart &&
                session.startTime < tomorrow
            }.count
            let label = weekOffset == 0 ? L10n.tr("Now") : L10n.format("%dw", weekOffset)
            return WeeklyRhythmWeek(
                startDate: start,
                label: label,
                sessions: count,
                target: target,
                isCurrent: weekOffset == 0
            )
        }

        let daysWithSessions = days.filter(\.hasSession).count
        let currentWeekSessions = weeks.first(where: \.isCurrent)?.sessions ?? 0
        let activeWeeks = weeks.filter { $0.sessions > 0 }.count
        let targetWeeks = weeks.filter(\.metTarget).count
        let currentWeekMetTarget = currentWeekSessions >= target
        let readable = daysWithSessions >= 4 && activeWeeks >= 2
        let consistentWeek = currentWeekMetTarget && daysWithSessions >= max(4, target)

        let stateLabel: String
        let detail: String
        let state: STRQPalette.State

        if daysWithSessions == 0 {
            stateLabel = L10n.tr("Baseline forming")
            detail = L10n.tr("Complete workouts to start the cadence map. The baseline stays quiet until real sessions land.")
            state = .neutral
        } else if consistentWeek {
            stateLabel = L10n.tr("Consistent week")
            detail = L10n.tr("This week has enough completed sessions for your target. Longer rhythm still comes from repeat weeks.")
            state = .success
        } else if readable {
            stateLabel = L10n.tr("Readable rhythm")
            detail = L10n.tr("Completed sessions now span multiple weeks, enough to read cadence without turning it into a streak game.")
            state = .info
        } else {
            stateLabel = L10n.tr("Early rhythm")
            detail = L10n.tr("A few training days are visible. Repeated weeks will make the rhythm more stable.")
            state = .warning
        }

        return WeeklyRhythmSnapshot(
            days: days,
            weeks: weeks,
            daysWithSessions: daysWithSessions,
            sessionsInWindow: sessionsInWindow.count,
            currentWeekSessions: currentWeekSessions,
            target: target,
            activeWeeks: activeWeeks,
            targetWeeks: targetWeeks,
            stateLabel: stateLabel,
            detail: detail,
            state: state
        )
    }

    private func weeklyRhythmMetricGrid(_ snapshot: WeeklyRhythmSnapshot) -> some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)], spacing: 8) {
            weeklyRhythmMetric(
                title: L10n.tr("This week"),
                value: "\(snapshot.currentWeekSessions)/\(snapshot.target)",
                detail: snapshot.currentWeekMetTarget ? L10n.tr("enough activity") : L10n.tr("still forming"),
                icon: "target",
                state: snapshot.currentWeekMetTarget ? .success : (snapshot.currentWeekSessions > 0 ? .warning : .neutral)
            )
            weeklyRhythmMetric(
                title: L10n.tr("Session days"),
                value: "\(snapshot.daysWithSessions)",
                detail: L10n.tr("last 28 days"),
                icon: "calendar",
                state: snapshot.daysWithSessions >= 4 ? .success : (snapshot.daysWithSessions > 0 ? .warning : .neutral)
            )
            weeklyRhythmMetric(
                title: L10n.tr("Active weeks"),
                value: "\(snapshot.activeWeeks)/4",
                detail: L10n.tr("recent weeks"),
                icon: "rectangle.stack",
                state: snapshot.activeWeeks >= 2 ? .info : (snapshot.activeWeeks > 0 ? .warning : .neutral)
            )
            weeklyRhythmMetric(
                title: L10n.tr("Target weeks"),
                value: "\(snapshot.targetWeeks)/4",
                detail: L10n.tr("met or above"),
                icon: "checkmark.seal",
                state: snapshot.targetWeeks > 0 ? .success : .neutral
            )
        }
    }

    private func weeklyRhythmMetric(title: String, value: String, detail: String, icon: String, state: STRQPalette.State) -> some View {
        let tint = STRQPalette.color(for: state)

        return HStack(spacing: 9) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 25, height: 25)
                .background(tint.opacity(0.1), in: .rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 9, weight: .black))
                    .tracking(0.5)
                    .foregroundStyle(.white.opacity(0.42))
                    .textCase(.uppercase)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 15, weight: .heavy, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.9))
                    Text(detail)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.48))
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 9)
        .background(Color.white.opacity(0.03), in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white.opacity(0.065), lineWidth: 1)
        )
    }

    private func weeklyRhythmGrid(days: [WeeklyRhythmDay], completionTint: Color) -> some View {
        VStack(spacing: 7) {
            HStack(spacing: 4) {
                ForEach(Array(days.prefix(7)), id: \.id) { day in
                    Text(day.date.formatted(.dateTime.weekday(.narrow)))
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(.white.opacity(0.42))
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(days) { day in
                    weeklyRhythmCell(day, completionTint: completionTint)
                }
            }
        }
        .padding(10)
        .background(Color.white.opacity(0.025), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
        )
    }

    private func weeklyRhythmCell(_ day: WeeklyRhythmDay, completionTint: Color) -> some View {
        let fill = day.hasSession ? completionTint : Color.white.opacity(day.isToday ? 0.085 : 0.045)
        let stroke = day.hasSession ? completionTint.opacity(0.42) : (day.isToday ? STRQBrand.steel.opacity(0.24) : Color.white.opacity(0.055))

        return RoundedRectangle(cornerRadius: 6)
            .fill(fill.gradient)
            .frame(height: 23)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .strokeBorder(stroke, lineWidth: 1)
            )
            .overlay(alignment: .bottom) {
                if day.hasSession {
                    Capsule()
                        .fill(Color.white.opacity(0.68))
                        .frame(width: day.sessionCount > 1 ? 18 : 12, height: 3)
                        .padding(.bottom, 4)
                }
            }
            .shadow(color: day.hasSession ? completionTint.opacity(0.1) : .clear, radius: 6, y: 2)
            .accessibilityLabel(Text(day.hasSession ? L10n.tr("Completed workout day") : L10n.tr("Open training day")))
    }

    private func weeklyRhythmWeekRows(_ weeks: [WeeklyRhythmWeek], completionTint: Color, stateTint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(L10n.tr("4-week cadence"))
                    .font(.system(size: 9, weight: .black))
                    .tracking(0.7)
                    .foregroundStyle(.white.opacity(0.42))
                    .textCase(.uppercase)
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)
                Text(L10n.format("target %d/wk", weeks.first?.target ?? 1))
                    .font(.caption2.weight(.semibold).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.48))
            }

            HStack(alignment: .bottom, spacing: 7) {
                ForEach(weeks) { week in
                    weeklyRhythmWeekColumn(week, completionTint: completionTint, stateTint: stateTint)
                }
            }
            .frame(height: 84)
        }
        .padding(12)
        .background(Color.white.opacity(0.025), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
        )
    }

    private func weeklyRhythmWeekColumn(_ week: WeeklyRhythmWeek, completionTint: Color, stateTint: Color) -> some View {
        let barTint = week.metTarget ? completionTint : (week.sessions > 0 ? stateTint : STRQBrand.slate.opacity(0.48))

        return VStack(spacing: 5) {
            GeometryReader { proxy in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 7)
                        .fill(Color.white.opacity(0.045))
                    RoundedRectangle(cornerRadius: 7)
                        .fill(barTint.opacity(week.sessions > 0 ? (week.isCurrent ? 0.88 : 0.56) : 0.18).gradient)
                        .frame(height: max(5, proxy.size.height * CGFloat(week.ratio)))
                }
            }
            .frame(height: 50)

            Text(week.label)
                .font(.system(size: 9, weight: .black))
                .foregroundStyle(week.isCurrent ? stateTint : .white.opacity(0.42))
                .lineLimit(1)
            Text("\(week.sessions)")
                .font(.system(size: 10, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundStyle(week.sessions > 0 ? .white.opacity(0.78) : .white.opacity(0.34))
        }
        .frame(maxWidth: .infinity)
        .accessibilityLabel(Text(L10n.format("%@, %d completed workouts", week.label, week.sessions)))
    }

    // MARK: - Body Signals

    @ViewBuilder
    private var bodySignals: some View {
        if vm.goalPace == nil && vm.bodyWeightEntries.count < 2 && vm.recoveryTrendData.count < 3 && vm.nutritionLogs.isEmpty {
            signalRunwayCard(
                title: L10n.tr("Body Signals"),
                trailing: L10n.tr("Baseline Forming"),
                icon: "heart.text.square.fill",
                headline: L10n.tr("Body baseline is forming"),
                detail: L10n.tr("progress.body.runway.detail", fallback: "Sleep, weight, and nutrition sharpen the read before STRQ turns it into a conclusion."),
                chips: [("moon.zzz.fill", L10n.tr("Recovery")), ("scalemass.fill", L10n.tr("Weight")), ("fork.knife", L10n.tr("Nutrition"))]
            )
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
        } else {
            VStack(spacing: 14) {
                if !hasRealBodyBaseline {
                    bodyBaselineNotice
                }
                if let pace = vm.goalPace {
                    goalPaceCard(pace)
                }
                bodyWeightChart
                recoveryTrend
                nutritionAdherence
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
        }
    }

    private var hasRealBodyBaseline: Bool {
        vm.goalPace != nil || vm.bodyWeightEntries.count >= 2 || !vm.nutritionLogs.isEmpty
    }

    private var bodyBaselineNotice: some View {
        signalRunwayCard(
            title: L10n.tr("Body Baseline"),
            trailing: L10n.tr("Forming"),
            icon: "heart.text.square.fill",
            headline: L10n.tr("Body trend is not ready yet"),
            detail: L10n.tr("Recovery can add context now, but weight, nutrition, or goal data make the body read trustworthy."),
            chips: [("moon.zzz.fill", L10n.tr("Context")), ("scalemass.fill", L10n.tr("Weight")), ("fork.knife", L10n.tr("Nutrition"))]
        )
    }

    private func signalRunwayCard(title: String, trailing: String, icon: String, headline: String, detail: String, chips: [(String, String)]) -> some View {
        evidenceModule(border: STRQPalette.warning.opacity(0.18)) {
            VStack(alignment: .leading, spacing: 14) {
                evidenceHeader(
                    title: title,
                    trailing: trailing,
                    icon: icon,
                    state: .warning,
                    subtitle: headline
                )

                Text(detail)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.58))
                    .fixedSize(horizontal: false, vertical: true)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Text(L10n.tr("EVIDENCE NEEDED"))
                            .font(.system(size: 9, weight: .black))
                            .tracking(0.7)
                            .foregroundStyle(.white.opacity(0.42))
                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 1)
                    }

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 6)], alignment: .leading, spacing: 6) {
                        ForEach(chips, id: \.1) { chip in
                            evidenceChip(icon: chip.0, text: chip.1, state: .neutral)
                        }
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.025), in: .rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
                )
            }
        }
    }

    private func goalPaceCard(_ pace: GoalPaceStatus) -> some View {
        let state: STRQPalette.State = pace.colorName == "green" ? .success : (pace.colorName == "red" ? .danger : .warning)
        let color = STRQPalette.color(for: state)

        return evidenceModule(border: color.opacity(0.18)) {
            HStack(spacing: 14) {
                Image(systemName: pace.icon)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(color)
                    .frame(width: 42, height: 42)
                    .background(color.opacity(0.12), in: .rect(cornerRadius: 11))
                    .overlay(
                        RoundedRectangle(cornerRadius: 11)
                            .strokeBorder(color.opacity(0.22), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 6) {
                        Text(L10n.tr("Goal Pace"))
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(color)
                            .textCase(.uppercase)
                            .tracking(0.6)
                        evidenceBadge(vm.nutritionTarget.nutritionGoal.displayName, state: state)
                    }
                    Text(pace.headline)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                    Text(pace.detail)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.58))
                        .lineLimit(2)
                }
                Spacer()
            }
        }
    }

    @ViewBuilder
    private var bodyWeightChart: some View {
        let entries = vm.bodyWeightEntries.sorted { $0.date < $1.date }

        if entries.count >= 2 {
            evidenceModule {
                VStack(alignment: .leading, spacing: 14) {
                    evidenceHeader(
                        title: L10n.tr("Body Weight"),
                        trailing: entries.last.map { L10n.format("%.1f kg", $0.weightKg) },
                        icon: "scalemass.fill",
                        state: .info,
                        subtitle: L10n.tr("Body baseline from logged weight")
                    )

                    plotShell(height: 146) {
                        Chart {
                            ForEach(entries) { entry in
                                AreaMark(x: .value("Date", entry.date), y: .value("Weight", entry.weightKg))
                                    .foregroundStyle(
                                        LinearGradient(colors: [STRQBrand.steel.opacity(0.2), STRQBrand.steel.opacity(0.02)], startPoint: .top, endPoint: .bottom)
                                    )
                                    .interpolationMethod(.catmullRom)
                                LineMark(x: .value("Date", entry.date), y: .value("Weight", entry.weightKg))
                                    .foregroundStyle(STRQBrand.steel).interpolationMethod(.catmullRom).lineStyle(StrokeStyle(lineWidth: 2))
                            }
                        }
                        .chartYScale(domain: .automatic(includesZero: false))
                        .chartYAxis {
                            AxisMarks(position: .leading) { _ in
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3)).foregroundStyle(Color.white.opacity(0.12))
                                AxisValueLabel().foregroundStyle(Color.secondary)
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                                AxisValueLabel(format: .dateTime.month(.abbreviated).day()).foregroundStyle(Color.secondary)
                            }
                        }
                    }

                    HStack(spacing: 10) {
                        let trendIcon = vm.weightTrendDescription == "Trending up" ? "arrow.up.right" : vm.weightTrendDescription == "Trending down" ? "arrow.down.right" : "equal"
                        evidenceChip(icon: trendIcon, text: vm.weightTrendDescription, state: .info)

                        Text(vm.nutritionTarget.weightGoalDirection.displayName)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var recoveryTrend: some View {
        let data = vm.recoveryTrendData
        if data.count >= 3 {
            let avgScore = data.map(\.score).reduce(0, +) / max(1, data.count)
            let scoreState: STRQPalette.State = avgScore >= 75 ? .success : avgScore >= 55 ? .warning : .danger
            let scoreColor = STRQPalette.color(for: scoreState)

            evidenceModule(border: scoreColor.opacity(0.18)) {
                VStack(alignment: .leading, spacing: 14) {
                    evidenceHeader(
                        title: L10n.tr("Recovery Trend"),
                        trailing: L10n.format("Avg %d", avgScore),
                        icon: "waveform.path.ecg",
                        state: scoreState,
                        subtitle: L10n.tr("Training context, not a medical read")
                    )

                    plotShell(height: 132) {
                        Chart {
                            ForEach(data, id: \.date) { item in
                                AreaMark(x: .value("Date", item.date), y: .value("Score", item.score))
                                    .foregroundStyle(
                                        LinearGradient(colors: [scoreColor.opacity(0.16), scoreColor.opacity(0.02)], startPoint: .top, endPoint: .bottom)
                                    )
                                    .interpolationMethod(.catmullRom)
                                LineMark(x: .value("Date", item.date), y: .value("Score", item.score))
                                    .foregroundStyle(scoreColor).interpolationMethod(.catmullRom).lineStyle(StrokeStyle(lineWidth: 2))
                            }
                            RuleMark(y: .value("Good", 70))
                                .foregroundStyle(STRQPalette.success.opacity(0.25))
                                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        }
                        .chartYScale(domain: 30...100)
                        .chartYAxis {
                            AxisMarks(position: .leading, values: [40, 60, 80, 100]) { _ in
                                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3)).foregroundStyle(Color.white.opacity(0.12))
                                AxisValueLabel().foregroundStyle(Color.secondary)
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: .stride(by: .day, count: 3)) { _ in
                                AxisValueLabel(format: .dateTime.weekday(.narrow)).foregroundStyle(Color.secondary)
                            }
                        }
                    }

                    HStack(spacing: 10) {
                        evidenceChip(icon: "line.3.horizontal.decrease", text: L10n.tr("70 reference"), state: .success)
                        Text(L10n.tr("Use this beside training load and sleep, not as a diagnosis."))
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.tertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var nutritionAdherence: some View {
        let logs = vm.nutritionLogs.prefix(7)
        if !logs.isEmpty {
            let avgProtein = logs.map(\.proteinGrams).reduce(0, +) / max(1, logs.count)

            evidenceModule {
                VStack(alignment: .leading, spacing: 14) {
                    evidenceHeader(
                        title: L10n.tr("Nutrition"),
                        trailing: L10n.format("Avg %dg", avgProtein),
                        icon: "fork.knife",
                        state: .info,
                        subtitle: L10n.tr("7-day adherence context")
                    )

                    HStack(spacing: 0) {
                        ForEach(Array(logs.reversed())) { log in
                            let proteinPct = vm.nutritionTarget.proteinGrams > 0 ? min(100, (log.proteinGrams * 100) / vm.nutritionTarget.proteinGrams) : 0
                            let calPct = vm.nutritionTarget.calories > 0 ? min(100, (log.calories * 100) / vm.nutritionTarget.calories) : 0
                            let avgPct = (proteinPct + calPct) / 2
                            let barColor: Color = avgPct >= 85 ? STRQPalette.success : avgPct >= 65 ? STRQPalette.warning : STRQPalette.danger

                            VStack(spacing: 4) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(barColor.gradient)
                                    .frame(width: 18, height: max(6, CGFloat(avgPct) / 100.0 * 42))
                                Text(log.date.formatted(.dateTime.weekday(.narrow)))
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundStyle(.tertiary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 58, alignment: .bottom)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.025), in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
                    )
                }
            }
        }
    }

    // MARK: - Volume Signals

    private struct WeeklyLoadWeek: Identifiable {
        let index: Int
        let label: String
        let count: Int

        var id: Int { index }
    }

    private struct VolumeTrendSnapshot {
        let stateLabel: String
        let state: STRQPalette.State
        let activeWeeks: Int
        let totalSessions: Int
        let currentWeekSessions: Int
        let peakWeekSessions: Int
        let detail: String
    }

    private func volumeTrendSnapshot(from weeks: [WeeklyLoadWeek]) -> VolumeTrendSnapshot {
        let activeWeeks = weeks.filter { $0.count > 0 }.count
        let totalSessions = weeks.reduce(0) { $0 + $1.count }
        let currentWeekSessions = weeks.last?.count ?? 0
        let peakWeekSessions = weeks.map(\.count).max() ?? 0

        if totalSessions <= 1 {
            return VolumeTrendSnapshot(
                stateLabel: L10n.tr("Baseline forming"),
                state: .warning,
                activeWeeks: activeWeeks,
                totalSessions: totalSessions,
                currentWeekSessions: currentWeekSessions,
                peakWeekSessions: peakWeekSessions,
                detail: L10n.tr("One or two sessions start the workload record. Weekly rhythm becomes useful after the same evidence repeats.")
            )
        }

        if activeWeeks >= 2 && totalSessions >= 4 {
            return VolumeTrendSnapshot(
                stateLabel: L10n.tr("Readable trend"),
                state: .info,
                activeWeeks: activeWeeks,
                totalSessions: totalSessions,
                currentWeekSessions: currentWeekSessions,
                peakWeekSessions: peakWeekSessions,
                detail: L10n.tr("Completed workouts now span multiple weeks, enough to read load rhythm without guessing at adaptation.")
            )
        }

        return VolumeTrendSnapshot(
            stateLabel: L10n.tr("Early signal"),
            state: .warning,
            activeWeeks: activeWeeks,
            totalSessions: totalSessions,
            currentWeekSessions: currentWeekSessions,
            peakWeekSessions: peakWeekSessions,
            detail: L10n.tr("The workload signal is present, but the weekly pattern is still thin. More completed sessions make the rhythm trustworthy.")
        )
    }

    @ViewBuilder
    private var volumeSignals: some View {
        if vm.totalCompletedWorkouts < 2 {
            signalRunwayCard(
                title: L10n.tr("Volume Signals"),
                trailing: L10n.tr("Baseline forming"),
                icon: "chart.bar.xaxis",
                headline: L10n.tr("Training load baseline is forming"),
                detail: L10n.tr("progress.volume.runway.detail", fallback: "A few completed workouts reveal weekly rhythm and workload before balance becomes trustworthy."),
                chips: [("figure.strengthtraining.traditional", L10n.tr("Workouts")), ("chart.bar.xaxis", L10n.tr("Weekly rhythm")), ("circle.dashed", L10n.tr("No conclusion"))]
            )
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
        } else {
            VStack(spacing: 14) {
                weeklySessionsChart
                if hasTrustworthyMuscleBalance {
                    muscleBalanceChart
                    movementBalanceCard
                } else {
                    muscleBalanceBaselineCard
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
        }
    }

    private var muscleBalanceBaselineCard: some View {
        let currentVolume = vm.muscleBalance.reduce(0.0) { $0 + $1.thisWeek }
        let averageVolume = vm.muscleBalance.reduce(0.0) { $0 + $1.average }
        let detail: String = {
            if vm.totalCompletedWorkouts < 4 {
                return L10n.tr("A few more completed workouts are needed before muscle balance can be trusted.")
            }
            if currentVolume <= 0 || averageVolume <= 0 {
                return L10n.tr("STRQ needs current and comparison volume before showing balance as evidence.")
            }
            return L10n.tr("Balance will appear once the comparison window is reliable.")
        }()

        return signalRunwayCard(
            title: L10n.tr("Muscle Balance"),
            trailing: L10n.tr("Baseline Forming"),
            icon: "arrow.left.arrow.right",
            headline: L10n.tr("Muscle balance is still forming"),
            detail: detail,
            chips: [("square.stack.3d.up.fill", L10n.tr("Current volume")), ("calendar", L10n.tr("4-week average")), ("checkmark.seal", L10n.tr("Trusted read"))]
        )
    }

    private var muscleBalanceChart: some View {
        evidenceModule {
            VStack(alignment: .leading, spacing: 14) {
                evidenceHeader(
                    title: L10n.tr("Muscle Balance"),
                    trailing: L10n.tr("vs 4-Week Avg"),
                    icon: "arrow.left.arrow.right",
                    state: .info,
                    subtitle: L10n.tr("Trusted read after baseline gate")
                )

                VStack(spacing: 10) {
                    ForEach(vm.muscleBalance.filter { $0.average > 0 }) { entry in
                        HStack(spacing: 9) {
                            Text(entry.muscle)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white.opacity(0.76))
                                .frame(width: 70, alignment: .leading)

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.white.opacity(0.055))
                                        .frame(height: 8)
                                    Rectangle()
                                        .fill(Color.white.opacity(0.18))
                                        .frame(width: 1, height: 14)
                                        .offset(x: geo.size.width * (1.0 / 1.3))
                                    Capsule()
                                        .fill(balanceColor(entry.percentOfAverage).gradient)
                                        .frame(
                                            width: max(0, geo.size.width * (appeared || reduceMotion ? min(CGFloat(entry.percentOfAverage), 1.3) / 1.3 : 0)),
                                            height: 8
                                        )
                                        .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.45), value: appeared)
                                }
                            }
                            .frame(height: 14)

                            Text(balanceLabel(entry.percentOfAverage))
                                .font(.system(size: 10, weight: .bold, design: .rounded).monospacedDigit())
                                .foregroundStyle(balanceColor(entry.percentOfAverage))
                                .frame(width: 42, alignment: .trailing)
                        }
                    }
                }

                HStack(spacing: 10) {
                    legendDot(color: Color.white.opacity(0.18), label: L10n.tr("100% baseline"))
                    legendDot(color: STRQBrand.steel, label: L10n.tr("Current week"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private var weeklySessionsChart: some View {
        let calendar = Calendar.current
        let last8Weeks: [WeeklyLoadWeek] = Array((0..<8).reversed().enumerated()).map { index, weekOffset in
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: Date())!
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            let count = vm.workoutHistory.filter { $0.startTime >= weekStart && $0.startTime < weekEnd && $0.isCompleted }.count
            let label = weekOffset == 0 ? L10n.tr("Now") : L10n.format("%dw", weekOffset)
            return WeeklyLoadWeek(index: index, label: label, count: count)
        }
        let snapshot = volumeTrendSnapshot(from: last8Weeks)
        let tint = STRQPalette.color(for: snapshot.state)

        evidenceModule(border: tint.opacity(0.2)) {
            VStack(alignment: .leading, spacing: 16) {
                evidenceHeader(
                    title: L10n.tr("Volume Trend"),
                    trailing: snapshot.stateLabel,
                    icon: "chart.bar.xaxis",
                    state: snapshot.state,
                    subtitle: L10n.tr("Weekly Workouts from completed sessions")
                )

                HStack(alignment: .top, spacing: 10) {
                    trendProofMetric(
                        title: L10n.tr("This week"),
                        value: "\(snapshot.currentWeekSessions)",
                        detail: L10n.tr("workouts"),
                        icon: "calendar.badge.clock",
                        state: snapshot.currentWeekSessions > 0 ? snapshot.state : .neutral
                    )
                    trendProofMetric(
                        title: L10n.tr("Active weeks"),
                        value: "\(snapshot.activeWeeks)/8",
                        detail: L10n.tr("with work"),
                        icon: "rectangle.stack",
                        state: snapshot.activeWeeks >= 2 ? .info : (snapshot.activeWeeks > 0 ? .warning : .neutral)
                    )
                }

                Text(snapshot.detail)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.58))
                    .fixedSize(horizontal: false, vertical: true)

                plotShell(height: 140) {
                    Chart {
                        ForEach(last8Weeks) { week in
                            BarMark(x: .value("Week", week.label), y: .value("Workouts", appeared || reduceMotion ? week.count : 0))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [tint, STRQBrand.slate.opacity(0.82)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .clipShape(.rect(cornerRadius: 3))
                        }
                    }
                    .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5), value: appeared)
                    .chartYAxis {
                        AxisMarks(position: .leading) { _ in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3)).foregroundStyle(Color.white.opacity(0.12))
                            AxisValueLabel().foregroundStyle(Color.secondary)
                        }
                    }
                    .chartXAxis {
                        AxisMarks { _ in AxisValueLabel().foregroundStyle(Color.secondary) }
                    }
                }

                weeklyWorkloadRail(weeks: last8Weeks, snapshot: snapshot, tint: tint)

                HStack(spacing: 10) {
                    evidenceChip(icon: "checkmark.circle", text: L10n.tr("Completed only"), state: .neutral)
                    Text(L10n.tr("Bars show finished workouts per week; this is rhythm evidence, not intensity scoring."))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.tertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private func weeklyWorkloadRail(weeks: [WeeklyLoadWeek], snapshot: VolumeTrendSnapshot, tint: Color) -> some View {
        let peak = max(snapshot.peakWeekSessions, 1)

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(L10n.tr("8-week load rhythm"))
                    .font(.system(size: 9, weight: .black))
                    .tracking(0.7)
                    .foregroundStyle(.white.opacity(0.42))
                    .textCase(.uppercase)
                Rectangle()
                    .fill(Color.white.opacity(0.06))
                    .frame(height: 1)
                Text(L10n.format("peak %d/wk", snapshot.peakWeekSessions))
                    .font(.caption2.weight(.semibold).monospacedDigit())
                    .foregroundStyle(.white.opacity(0.48))
            }

            HStack(alignment: .bottom, spacing: 6) {
                ForEach(weeks) { week in
                    VStack(spacing: 5) {
                        GeometryReader { proxy in
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(Color.white.opacity(0.045))
                                RoundedRectangle(cornerRadius: 7)
                                    .fill((week.count > 0 ? tint : STRQBrand.slate.opacity(0.44)).opacity(week.count > 0 ? 0.76 : 0.16).gradient)
                                    .frame(height: max(5, proxy.size.height * CGFloat(Double(week.count) / Double(peak))))
                            }
                        }
                        .frame(height: 46)

                        Text(week.label)
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(week.index == weeks.count - 1 ? tint : .white.opacity(0.42))
                            .lineLimit(1)
                        Text("\(week.count)")
                            .font(.system(size: 10, weight: .heavy, design: .rounded).monospacedDigit())
                            .foregroundStyle(week.count > 0 ? .white.opacity(0.72) : .white.opacity(0.3))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 80)
        }
        .padding(12)
        .background(Color.white.opacity(0.025), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
        )
    }

    private var movementBalanceCard: some View {
        evidenceModule {
            VStack(alignment: .leading, spacing: 14) {
                evidenceHeader(
                    title: L10n.tr("Movement Balance"),
                    icon: "figure.strengthtraining.traditional",
                    state: .info,
                    subtitle: L10n.tr("Movement mix from current volume")
                )

                let data = movementBalanceData
                HStack(spacing: 8) {
                    movementBar(label: "Push", value: data.push, total: data.total, color: Color.white)
                    movementBar(label: "Pull", value: data.pull, total: data.total, color: STRQBrand.steel)
                    movementBar(label: "Legs", value: data.legs, total: data.total, color: STRQBrand.slate)
                    movementBar(label: L10n.tr("Core"), value: data.core, total: data.total, color: STRQPalette.warning)
                }
                .padding(12)
                .background(Color.white.opacity(0.025), in: .rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
                )
            }
        }
    }

    private func movementBar(label: String, value: Double, total: Double, color: Color) -> some View {
        let ratio = total > 0 ? value / total : 0
        return VStack(spacing: 5) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.tertiarySystemGroupedBackground))
                    .frame(height: 44)
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.gradient)
                    .frame(height: max(4, 44 * CGFloat(ratio)))
            }
            .frame(maxWidth: .infinity)

            Text("\(Int(ratio * 100))%")
                .font(.system(size: 11, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Helpers

    private var hasTrustworthyMuscleBalance: Bool {
        let currentVolume = vm.muscleBalance.reduce(0.0) { $0 + $1.thisWeek }
        let averageVolume = vm.muscleBalance.reduce(0.0) { $0 + $1.average }
        return vm.totalCompletedWorkouts >= 4 && currentVolume > 0 && averageVolume > 0
    }

    private func balanceColor(_ ratio: Double) -> Color {
        if ratio >= 1.1 { return STRQPalette.success }
        if ratio >= 0.85 { return STRQBrand.steel }
        if ratio >= 0.65 { return STRQPalette.warning }
        return STRQPalette.danger
    }

    private func balanceLabel(_ ratio: Double) -> String {
        let pct = Int((ratio - 1.0) * 100)
        if pct >= 0 { return "+\(pct)%" }
        return "\(pct)%"
    }

    private var movementBalanceData: (push: Double, pull: Double, legs: Double, core: Double, total: Double) {
        let balance = vm.muscleBalance
        let push = (balance.first { $0.muscle == "Chest" }?.thisWeek ?? 0) +
                   (balance.first { $0.muscle == "Shoulders" }?.thisWeek ?? 0)
        let pull = (balance.first { $0.muscle == "Back" }?.thisWeek ?? 0)
        let legs = (balance.first { $0.muscle == "Quads" }?.thisWeek ?? 0) +
                   (balance.first { $0.muscle == "Hamstrings" }?.thisWeek ?? 0) +
                   (balance.first { $0.muscle == "Glutes" }?.thisWeek ?? 0)
        let core = (balance.first { $0.muscle == "Abs" }?.thisWeek ?? 0)
        let total = push + pull + legs + core
        return (push, pull, legs, core, total)
    }
}
