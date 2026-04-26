import SwiftUI

struct WorkoutCompletionView: View {
    let vm: AppViewModel
    let session: WorkoutSession?
    let onDismiss: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var appeared: Bool = false
    @State private var trophyPulse: Bool = false
    @State private var highlightsAppeared: Bool = false
    @State private var sparkTrigger: Int = 0
    @State private var hapticTick: Int = 0
    @State private var celebrationTrigger: Bool = false

    private var result: WorkoutHighlightBuilder.Result {
        guard let session else {
            return WorkoutHighlightBuilder.Result(
                highlights: [],
                verdict: SessionVerdict(kind: .consolidated, eyebrow: L10n.tr("SESSION LOGGED"), summary: L10n.tr("Work put in"))
            )
        }
        return WorkoutHighlightBuilder.buildResult(
            session: session,
            history: vm.workoutHistory,
            streak: vm.streak,
            exerciseName: { id in vm.library.exercise(byId: id)?.name ?? L10n.tr("Exercise") }
        )
    }

    private var highlights: [WorkoutHighlight] { result.highlights }
    private var verdict: SessionVerdict { result.verdict }
    private var hasPR: Bool { verdict.kind == .personalRecord }

    private var primaryAccent: Color {
        switch verdict.kind {
        case .personalRecord: return STRQPalette.gold
        case .bestSet, .volumeUp: return STRQPalette.success
        case .firstSession: return STRQPalette.info
        case .consolidated: return STRQBrand.steel
        case .volumeDown: return STRQPalette.warning
        }
    }

    private var verdictIcon: String {
        switch verdict.kind {
        case .personalRecord: return "trophy.fill"
        case .bestSet: return "bolt.fill"
        case .volumeUp: return "arrow.up.right.circle.fill"
        case .volumeDown: return "equal.circle.fill"
        case .firstSession: return "sparkles"
        case .consolidated: return "checkmark.seal.fill"
        }
    }

    var body: some View {
        ZStack {
            backgroundLayer

            if !reduceMotion {
                SparkField(trigger: sparkTrigger, intensity: hasPR ? 1.0 : 0.55, accent: primaryAccent)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 28)
                    heroSection
                    statsSection
                    activationRibbon
                    highlightsSection
                    nextSessionBridge
                    Color.clear.frame(height: 110)
                }
            }
            .scrollIndicators(.hidden)

            VStack {
                Spacer()
                bottomActions
            }
        }
        .preferredColorScheme(.dark)
        .sensoryFeedback(.success, trigger: celebrationTrigger)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.6), trigger: hapticTick)
        .onAppear(perform: onFirstAppear)
    }

    // MARK: - Layers

    private var backgroundLayer: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            RadialGradient(
                colors: [primaryAccent.opacity(hasPR ? 0.20 : 0.12), Color.clear],
                center: .top,
                startRadius: 10,
                endRadius: 520
            )
            .ignoresSafeArea()
            RadialGradient(
                colors: [Color.white.opacity(0.04), Color.clear],
                center: .bottom,
                startRadius: 10,
                endRadius: 360
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 132, height: 132)
                Circle()
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    .frame(width: 132, height: 132)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [primaryAccent.opacity(hasPR ? 0.32 : 0.22), Color.clear],
                            center: .center,
                            startRadius: 4,
                            endRadius: 72
                        )
                    )
                    .frame(width: 132, height: 132)

                Image(systemName: verdictIcon)
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundStyle(hasPR ? AnyShapeStyle(STRQPalette.goldGradient) : AnyShapeStyle(primaryAccent.gradient))
                    .scaleEffect(trophyPulse ? 1.04 : 1.0)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: trophyPulse)
            }
            .scaleEffect(appeared ? 1 : 0.7)
            .opacity(appeared ? 1 : 0)
            .animation(reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.55, dampingFraction: 0.7), value: appeared)

            VStack(spacing: 6) {
                Text(verdict.eyebrow)
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(primaryAccent)
                    .tracking(3)
                Text(verdict.summary)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 28)
                if let day = session?.dayName, !day.isEmpty {
                    Text(day)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)
        }
    }

    // MARK: - Stats

    @ViewBuilder
    private var statsSection: some View {
        if let session {
            let duration = session.endTime.map { Int($0.timeIntervalSince(session.startTime) / 60) } ?? 0
            let totalSets = session.exerciseLogs.flatMap(\.sets).filter(\.isCompleted).count
            let totalReps = session.exerciseLogs.flatMap(\.sets).filter(\.isCompleted).reduce(0) { $0 + $1.reps }
            let completedExercises = session.exerciseLogs.filter(\.isCompleted).count

            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    completionStat(L10n.tr("Time"), value: "\(duration)", unit: "min")
                    completionStat(L10n.tr("Exercises"), value: "\(completedExercises)", unit: nil)
                    completionStat(L10n.tr("Sets"), value: "\(totalSets)", unit: nil)
                    completionStat(L10n.tr("Reps"), value: "\(totalReps)", unit: nil)
                }

                if session.totalVolume > 0 {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(L10n.tr("TOTAL VOLUME"))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white.opacity(0.42))
                                .tracking(1.2)
                            Text(String(format: "%.0f kg", session.totalVolume))
                                .font(.system(size: 26, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        Spacer()
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(STRQBrand.steel.opacity(0.6))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 20)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)
        }
    }

    // MARK: - Highlights

    // MARK: - Activation Ribbon (first-week framing)

    private struct ActivationRibbonCopy {
        let headline: String
        let detail: String
        let icon: String
    }

    private func activationRibbonCopy(for roadmap: ActivationRoadmap) -> ActivationRibbonCopy {
        switch vm.totalCompletedWorkouts {
        case 1:
            return .init(
                headline: L10n.tr("Baseline locked in"),
                detail: L10n.tr("STRQ now knows your starting loads. Session 2 switches on real progression calls."),
                icon: "scalemass.fill"
            )
        case 2:
            return .init(
                headline: L10n.tr("Progression is live"),
                detail: L10n.tr("Coach can now adjust load and volume. One more session sharpens pattern reads."),
                icon: "chart.line.uptrend.xyaxis"
            )
        case 3:
            return .init(
                headline: L10n.tr("Pattern reads unlocked"),
                detail: L10n.tr("STRQ is reading balance, fatigue, and load pacing. Finish the week to unlock your first review."),
                icon: "waveform.path.ecg"
            )
        default:
            return .init(
                headline: L10n.format("Step %d of %d", roadmap.completedCount, roadmap.steps.count),
                detail: roadmap.subhead,
                icon: "sparkles"
            )
        }
    }

    @ViewBuilder
    private var activationRibbon: some View {
        if let roadmap = vm.activationRoadmap {
            let copy = activationRibbonCopy(for: roadmap)
            let headline = copy.headline
            let detail = copy.detail
            let icon = copy.icon

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(STRQBrand.steelGradient, in: .rect(cornerRadius: 9))

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(L10n.tr("COACH CALIBRATION"))
                                .font(.system(size: 9, weight: .black))
                                .tracking(1.2)
                                .foregroundStyle(STRQBrand.steel)
                            Text("\(roadmap.completedCount)/\(roadmap.steps.count)")
                                .font(.system(size: 9, weight: .black).monospacedDigit())
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        Text(headline)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    Spacer(minLength: 0)
                }

                Text(detail)
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundStyle(.white.opacity(0.65))
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 4) {
                    ForEach(0..<roadmap.steps.count, id: \.self) { i in
                        Capsule()
                            .fill(i < roadmap.completedCount
                                  ? AnyShapeStyle(STRQBrand.accentGradient)
                                  : AnyShapeStyle(Color.white.opacity(0.08)))
                            .frame(height: 3)
                    }
                }
            }
            .padding(14)
            .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.35), value: appeared)
        }
    }

    @ViewBuilder
    private var highlightsSection: some View {
        if !highlights.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader(title: L10n.tr("WHAT IMPROVED"), count: highlights.count)

                VStack(spacing: 8) {
                    ForEach(Array(highlights.enumerated()), id: \.element.id) { idx, h in
                        HighlightRow(highlight: h)
                            .opacity(highlightsAppeared ? 1 : 0)
                            .offset(y: highlightsAppeared ? 0 : 14)
                            .animation(
                                reduceMotion
                                    ? .easeOut(duration: 0.2)
                                    : .spring(response: 0.5, dampingFraction: 0.82).delay(0.45 + Double(idx) * 0.07),
                                value: highlightsAppeared
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Next session bridge

    @ViewBuilder
    private var nextSessionBridge: some View {
        let items = nextSessionItems()
        if !items.isEmpty || nextDayName != nil {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader(title: L10n.tr("NEXT SESSION"), count: nil)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: "calendar")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white.opacity(0.75))
                            .frame(width: 28, height: 28)
                            .background(Color.white.opacity(0.06), in: .rect(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(nextDayName ?? L10n.tr("Upcoming session"))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                            Text(nextDaySubtitle)
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white.opacity(0.5))
                                .lineLimit(1)
                        }
                        Spacer()
                    }

                    if !items.isEmpty {
                        Divider()
                            .overlay(Color.white.opacity(0.06))

                        VStack(spacing: 6) {
                            ForEach(items) { item in
                                HStack(spacing: 10) {
                                    Image(systemName: item.icon)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(item.color)
                                        .frame(width: 16)
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(item.exerciseName)
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundStyle(.white.opacity(0.9))
                                            .lineLimit(1)
                                        Text(item.detail)
                                            .font(.system(size: 10.5, weight: .medium))
                                            .foregroundStyle(.white.opacity(0.55))
                                            .lineLimit(1)
                                    }
                                    Spacer(minLength: 4)
                                    Text(item.tag)
                                        .font(.system(size: 9, weight: .black))
                                        .tracking(0.8)
                                        .foregroundStyle(item.color)
                                        .padding(.horizontal, 7)
                                        .padding(.vertical, 3)
                                        .background(item.color.opacity(0.12), in: Capsule())
                                        .overlay(Capsule().strokeBorder(item.color.opacity(0.22), lineWidth: 0.5))
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .background(Color.white.opacity(0.035), in: .rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
            .opacity(highlightsAppeared ? 1 : 0)
            .offset(y: highlightsAppeared ? 0 : 14)
            .animation(
                reduceMotion ? .easeOut(duration: 0.2) : .spring(response: 0.5, dampingFraction: 0.82).delay(0.7),
                value: highlightsAppeared
            )
        }
    }

    private var nextDayName: String? {
        guard let plan = vm.currentPlan else { return nil }
        guard let id = vm.nextSessionDayId, let day = plan.days.first(where: { $0.id == id }) else { return nil }
        // Avoid trivially naming the same session they just finished if another day exists.
        if day.id == session?.dayId, let other = plan.days.first(where: { $0.id != day.id && !$0.isSkipped }) {
            return other.name
        }
        return day.name
    }

    private var nextDaySubtitle: String {
        if let date = vm.nextScheduledWorkoutDate {
            let cal = Calendar.current
            if cal.isDateInToday(date) { return L10n.tr("scheduled today") }
            if cal.isDateInTomorrow(date) { return L10n.tr("scheduled tomorrow") }
            let days = cal.dateComponents([.day], from: cal.startOfDay(for: Date()), to: cal.startOfDay(for: date)).day ?? 0
            if days > 0 && days < 7 {
                let f = DateFormatter()
                f.locale = Locale.current
                f.dateFormat = "EEEE"
                return L10n.format("scheduled %@", f.string(from: date).localizedLowercase)
            }
        }
        return L10n.tr("STRQ will adapt from today's data")
    }

    private struct BridgeItem: Identifiable {
        let id = UUID()
        let exerciseName: String
        let detail: String
        let tag: String
        let icon: String
        let color: Color
    }

    private func nextSessionItems() -> [BridgeItem] {
        guard let session else { return [] }
        var items: [BridgeItem] = []

        // Priority 1: PR or best-set exercises from this session → PUSH next time
        var pushed: Set<String> = []
        for h in highlights.prefix(3) where h.kind == .personalRecord || h.kind == .bestSet {
            guard let name = h.subtitle else { continue }
            if pushed.contains(name) { continue }
            pushed.insert(name)
            let detail: String
            if h.kind == .personalRecord {
                detail = L10n.tr("Confirmed progression — load up next time")
            } else {
                detail = L10n.tr("Beat last session — push next time")
            }
            items.append(BridgeItem(
                exerciseName: name,
                detail: detail,
                tag: L10n.tr("PUSH"),
                icon: "arrow.up.right.circle.fill",
                color: STRQPalette.success
            ))
            if items.count >= 2 { return items }
        }

        // Priority 2: exercises in this session with hold/deload guidance
        for log in session.exerciseLogs.prefix(6) {
            guard let state = vm.progressionStates.first(where: { $0.exerciseId == log.exerciseId }) else { continue }
            guard let ex = vm.library.exercise(byId: log.exerciseId) else { continue }
            if pushed.contains(ex.name) { continue }

            switch state.recommendedStrategy {
            case .loadFirst where state.plateauStatus == .progressing:
                items.append(BridgeItem(
                    exerciseName: ex.name,
                    detail: L10n.format("Next: %.1f kg × %d", state.lastWeight + 2.5, state.lastReps),
                    tag: L10n.tr("PUSH"),
                    icon: "arrow.up.right.circle.fill",
                    color: STRQPalette.success
                ))
            case .holdAndConsolidate:
                items.append(BridgeItem(
                    exerciseName: ex.name,
                    detail: L10n.tr("Hold load — consolidate technique"),
                    tag: L10n.tr("HOLD"),
                    icon: "pause.circle.fill",
                    color: STRQPalette.warning
                ))
            case .deloadAndRebuild:
                items.append(BridgeItem(
                    exerciseName: ex.name,
                    detail: L10n.format("Deload to %.1f kg — rebuild clean", state.lastWeight * 0.85),
                    tag: L10n.tr("DROP"),
                    icon: "arrow.down.circle.fill",
                    color: STRQPalette.danger
                ))
            default:
                continue
            }
            pushed.insert(ex.name)
            if items.count >= 2 { return items }
        }

        return items
    }

    // MARK: - Bottom actions

    private var bottomActions: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [Color.black.opacity(0), Color.black], startPoint: .top, endPoint: .bottom)
                .frame(height: 40)
            VStack(spacing: 10) {
                Button { onDismiss() } label: {
                    Text(L10n.tr("Back to Today"))
                        .font(.body.weight(.bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 18))
                }
                .buttonStyle(.strqPressable)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
            .background(Color.black)
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.5), value: appeared)
    }

    // MARK: - Helpers

    private func sectionHeader(title: String, count: Int?) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .black))
                .tracking(1.4)
                .foregroundStyle(.white.opacity(0.55))
            Spacer()
            if let count {
                Text("\(count)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.35))
            }
        }
        .padding(.horizontal, 4)
    }

    private func completionStat(_ title: String, value: String, unit: String?) -> some View {
        VStack(spacing: 5) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                if let unit {
                    Text(unit)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
            Text(title.uppercased())
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(1.0)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    private func onFirstAppear() {
        withAnimation { appeared = true }
        trophyPulse = true
        celebrationTrigger.toggle()

        guard !reduceMotion else {
            highlightsAppeared = true
            return
        }

        Task { @MainActor in
            try? await Task.sleep(for: .milliseconds(120))
            sparkTrigger &+= 1
            try? await Task.sleep(for: .milliseconds(180))
            hapticTick &+= 1
            try? await Task.sleep(for: .milliseconds(200))
            highlightsAppeared = true
            if hasPR {
                try? await Task.sleep(for: .milliseconds(260))
                sparkTrigger &+= 1
                hapticTick &+= 1
            }
        }
    }
}

// MARK: - Highlight Row

private struct HighlightRow: View {
    let highlight: WorkoutHighlight

    private var palette: (color: Color, soft: Color, icon: String) {
        switch highlight.kind {
        case .personalRecord:
            return (STRQPalette.gold, STRQPalette.goldSoft, "trophy.fill")
        case .bestSet:
            return (STRQPalette.success, STRQPalette.successSoft, "bolt.fill")
        case .volumeUp:
            return (STRQPalette.success, STRQPalette.successSoft, "arrow.up.right.circle.fill")
        case .volumeDown:
            return (STRQPalette.warning, STRQPalette.warningSoft, "arrow.down.right.circle.fill")
        case .firstTime:
            return (STRQPalette.info, STRQPalette.infoSoft, "sparkles")
        case .consolidation:
            return (STRQBrand.steel, STRQBrand.steel.opacity(0.18), "checkmark.seal.fill")
        case .longestSession:
            return (STRQPalette.gold, STRQPalette.goldSoft, "timer")
        case .streakMilestone:
            return (STRQPalette.gold, STRQPalette.goldSoft, "flame.fill")
        case .setsMilestone:
            return (STRQPalette.gold, STRQPalette.goldSoft, "checkmark.seal.fill")
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(palette.soft)
                    .frame(width: highlight.isPrimary ? 44 : 38, height: highlight.isPrimary ? 44 : 38)
                Image(systemName: palette.icon)
                    .font(.system(size: highlight.isPrimary ? 18 : 15, weight: .bold))
                    .foregroundStyle(palette.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(highlight.title)
                        .font(.system(size: highlight.isPrimary ? 14 : 13, weight: highlight.isPrimary ? .heavy : .bold))
                        .foregroundStyle(.white)
                    if highlight.isPrimary {
                        Text(L10n.tr("TOP"))
                            .font(.system(size: 8, weight: .black))
                            .tracking(0.8)
                            .foregroundStyle(palette.color)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(palette.color.opacity(0.14), in: Capsule())
                    }
                }
                if let subtitle = highlight.subtitle {
                    Text(subtitle)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 2) {
                Text(highlight.valuePrimary)
                    .font(.system(size: highlight.isPrimary ? 15 : 14, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(palette.color)
                if let secondary = highlight.valueSecondary {
                    Text(secondary)
                        .font(.system(size: 10, weight: .semibold).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.42))
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, highlight.isPrimary ? 14 : 11)
        .background(
            Color.white.opacity(highlight.isPrimary ? 0.055 : 0.03),
            in: .rect(cornerRadius: 14)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(
                    palette.color.opacity(highlight.isPrimary ? 0.32 : 0.16),
                    lineWidth: highlight.isPrimary ? 1.0 : 0.7
                )
        )
    }
}

// MARK: - Particle Field

private struct SparkField: View {
    let trigger: Int
    let intensity: Double
    let accent: Color

    @State private var particles: [Particle] = []

    private struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var vx: CGFloat
        var vy: CGFloat
        var size: CGFloat
        var life: Double
        var maxLife: Double
        var hue: Double
        var isAccent: Bool
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { context in
            Canvas { ctx, _ in
                let now = context.date.timeIntervalSinceReferenceDate
                for p in particles {
                    let alpha = max(0, 1.0 - (now - p.life) / p.maxLife)
                    guard alpha > 0 else { continue }
                    let color: Color = p.isAccent
                        ? accent.opacity(alpha)
                        : Color.white.opacity(alpha * 0.85)
                    let rect = CGRect(x: p.x - p.size / 2, y: p.y - p.size / 2, width: p.size, height: p.size)
                    ctx.fill(Path(ellipseIn: rect), with: .color(color))
                    if p.isAccent {
                        let glow = CGRect(x: p.x - p.size, y: p.y - p.size, width: p.size * 2, height: p.size * 2)
                        ctx.fill(Path(ellipseIn: glow), with: .color(accent.opacity(alpha * 0.18)))
                    }
                }
            }
            .onChange(of: context.date) { _, date in
                step(at: date.timeIntervalSinceReferenceDate, size: UIScreen.main.bounds.size)
            }
        }
        .onChange(of: trigger) { _, _ in
            burst(at: UIScreen.main.bounds.size)
        }
    }

    private func burst(at size: CGSize) {
        let count = Int(Double(70) * intensity)
        let now = Date().timeIntervalSinceReferenceDate
        let originX = size.width / 2
        let originY = size.height * 0.28
        var new: [Particle] = []
        for _ in 0..<count {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 90...260)
            let isAccent = Double.random(in: 0...1) < 0.55
            new.append(Particle(
                x: originX,
                y: originY,
                vx: CGFloat(cos(angle)) * speed,
                vy: CGFloat(sin(angle)) * speed - CGFloat.random(in: 20...80),
                size: CGFloat.random(in: 2.0...4.5),
                life: now,
                maxLife: Double.random(in: 0.8...1.6),
                hue: 0,
                isAccent: isAccent
            ))
        }
        particles.append(contentsOf: new)
    }

    private func step(at now: TimeInterval, size: CGSize) {
        guard !particles.isEmpty else { return }
        let dt: CGFloat = 1.0 / 60.0
        var next: [Particle] = []
        next.reserveCapacity(particles.count)
        for var p in particles {
            let age = now - p.life
            if age > p.maxLife { continue }
            p.vy += 260 * dt
            p.vx *= 0.985
            p.x += p.vx * dt
            p.y += p.vy * dt
            next.append(p)
        }
        particles = next
    }
}
