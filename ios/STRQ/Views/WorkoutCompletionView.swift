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
                verdict: SessionVerdict(kind: .consolidated, eyebrow: L10n.tr("WORKOUT LOGGED"), summary: L10n.tr("Work put in"))
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
    private var primaryHighlight: WorkoutHighlight? { highlights.first }
    private var isPeakCompletion: Bool {
        verdict.kind == .personalRecord || verdict.kind == .bestSet || isPeakHighlight(primaryHighlight)
    }
    private var hasPR: Bool {
        isPeakCompletion
    }
    private var isLighterDay: Bool {
        verdict.kind == .volumeDown || primaryHighlight?.kind == .volumeDown
    }

    private var primaryAccent: Color {
        if isPeakCompletion { return STRQPalette.gold }

        switch verdict.kind {
        case .personalRecord: return STRQPalette.gold
        case .bestSet: return STRQPalette.gold
        case .volumeUp: return STRQPalette.success
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

            if hasPR && !reduceMotion {
                SparkField(trigger: sparkTrigger, intensity: 0.48, accent: STRQPalette.gold)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            ScrollView {
                VStack(spacing: 18) {
                    Spacer(minLength: 18)
                    heroSection
                    primaryAchievementBadge
                    statsSection
                    whatChangedSection
                    highlightsSection
                    nextSessionBridge
                    Color.clear.frame(height: 24)
                }
            }
            .scrollIndicators(.hidden)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            bottomActions
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
                colors: [primaryAccent.opacity(hasPR ? 0.20 : 0.075), Color.clear],
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
        VStack(spacing: 14) {
            STRQPulseMark(size: hasPR ? 102 : 88, tint: primaryAccent, trigger: sparkTrigger) {
                Image(systemName: verdictIcon)
                    .font(.system(size: hasPR ? 38 : 32, weight: .semibold))
                    .foregroundStyle(hasPR ? AnyShapeStyle(STRQPalette.goldGradient) : AnyShapeStyle(primaryAccent.gradient))
                    .scaleEffect(hasPR && trophyPulse ? 1.045 : 1.0)
                    .animation(hasPR && !reduceMotion ? .easeInOut(duration: 1.6).repeatForever(autoreverses: true) : nil, value: trophyPulse)
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
                    .font(.system(size: 24, weight: .bold))
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
    private var primaryAchievementBadge: some View {
        if let highlight = primaryHighlight {
            let tint = proofAccent(for: highlight.kind)
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: badgeIcon(for: highlight.kind))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(tint)
                    .frame(width: 42, height: 42)
                    .background(tint.opacity(hasPR ? 0.20 : 0.13), in: .rect(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(tint.opacity(hasPR ? 0.34 : 0.18), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(highlight.title.uppercased())
                        .font(.system(size: 10, weight: .black))
                        .tracking(1.0)
                        .foregroundStyle(tint)
                        .lineLimit(1)
                    if let subtitle = highlight.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.62))
                            .lineLimit(1)
                    }
                }

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(highlight.valuePrimary)
                        .font(.system(size: hasPR ? 22 : 20, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(hasPR ? AnyShapeStyle(STRQPalette.goldGradient) : AnyShapeStyle(tint))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    if let secondary = softenedCompletionSecondary(highlight.valueSecondary) {
                        Text(secondary)
                            .font(.system(size: 10, weight: .semibold).monospacedDigit())
                            .foregroundStyle(.white.opacity(0.46))
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 13)
            .background(Color.white.opacity(hasPR ? 0.065 : 0.045), in: .rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(tint.opacity(hasPR ? 0.36 : 0.18), lineWidth: 1)
            )
            .shadow(color: hasPR ? STRQPalette.gold.opacity(0.16) : Color.clear, radius: 18, x: 0, y: 8)
            .padding(.horizontal, 20)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.45).delay(0.22), value: appeared)
        }
    }

    @ViewBuilder
    private var statsSection: some View {
        if let session {
            let duration = completionDurationDisplay(for: session)
            let totalSets = session.completedSetCount
            let totalReps = session.completedRepCount
            let completedExercises = session.distinctCompletedExerciseCount

            VStack(spacing: 10) {
                HStack(spacing: 8) {
                    completionStat(L10n.tr("Time"), value: duration, unit: "min")
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
                            STRQCountUpText(value: session.totalVolume) { value in
                                String(format: "%.0f kg", value)
                            }
                            .font(.system(size: 21, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        }
                        Spacer()
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(STRQBrand.steel.opacity(0.6))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.white.opacity(0.075), lineWidth: 1)
                    )
                }
            }
            .padding(.horizontal, 20)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 12)
            .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5).delay(0.3), value: appeared)
        }
    }

    private struct ChangedInsight: Identifiable {
        let id = UUID()
        let title: String
        let detail: String?
        let icon: String
        let color: Color
    }

    @ViewBuilder
    private var whatChangedSection: some View {
        let insights = whatChangedInsights
        if !insights.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    STRQPulseMark(size: 34, tint: primaryAccent) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(primaryAccent)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text(L10n.tr("STRQ learned"))
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.1)
                            .foregroundStyle(primaryAccent)
                        Text(L10n.tr("What changed"))
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                    }

                    Spacer(minLength: 0)
                }

                VStack(spacing: 8) {
                    ForEach(insights) { insight in
                        whatChangedRow(insight)
                    }
                }
            }
            .padding(14)
            .background(Color(white: 0.085), in: .rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(primaryAccent.opacity(0.22), lineWidth: 1)
            )
            .padding(.horizontal, 20)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.45).delay(0.36), value: appeared)
        }
    }

    private var whatChangedInsights: [ChangedInsight] {
        guard let session else { return [] }
        var insights: [ChangedInsight] = []

        if let top = highlights.first {
            insights.append(ChangedInsight(
                title: top.improvedLine ?? top.title,
                detail: top.valuePrimary,
                icon: badgeIcon(for: top.kind),
                color: primaryAccent
            ))
        }

        if let focus = dominantFocus(for: session) {
            let title = hasPreviousSignal(for: focus, before: session)
                ? L10n.format("%@ volume updated", focus.localizedDisplayName)
                : L10n.format("First %@ signal collected", focus.localizedDisplayName)
            insights.append(ChangedInsight(
                title: title,
                detail: L10n.tr("Next targets will use this"),
                icon: completionMuscleIcon(for: focus),
                color: STRQBrand.steel
            ))
        }

        if let next = nextSessionItems().first {
            insights.append(ChangedInsight(
                title: next.usesFallbackTarget
                    ? L10n.tr("Next targets need one more clean set.")
                    : L10n.tr("Next targets will adapt"),
                detail: next.exerciseName,
                icon: next.icon,
                color: next.color
            ))
        }

        let completedSets = session.completedSetCount
        if insights.count < 2 && completedSets > 0 {
            let setLabel = L10n.countLabel(
                completedSets,
                singularKey: "count.set.one",
                pluralKey: "count.set.other",
                singularFallback: "set",
                pluralFallback: "sets"
            )
            insights.append(ChangedInsight(
                title: L10n.format("%@ completed", setLabel),
                detail: session.dayName,
                icon: "checkmark.circle.fill",
                color: STRQPalette.success
            ))
        }

        if insights.count < 3 && session.totalVolume > 0 {
            insights.append(ChangedInsight(
                title: L10n.tr("Workout volume updated"),
                detail: String(format: "%.0f kg", session.totalVolume),
                icon: "chart.bar.fill",
                color: STRQBrand.steel
            ))
        }

        if insights.isEmpty {
            insights.append(ChangedInsight(
                title: L10n.tr("First signal collected"),
                detail: L10n.tr("Next targets will use this"),
                icon: "waveform.path.ecg",
                color: STRQBrand.steel
            ))
        }

        return Array(insights.prefix(3))
    }

    private func completionMuscleIcon(for muscle: MuscleGroup) -> String {
        switch muscle {
        case .back, .lats, .lowerBack:
            return "figure.strengthtraining.traditional"
        default:
            return muscle.symbolName
        }
    }

    private func whatChangedRow(_ insight: ChangedInsight) -> some View {
        HStack(spacing: 10) {
            Image(systemName: insight.icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(insight.color)
                .frame(width: 26, height: 26)
                .background(insight.color.opacity(0.14), in: .rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 1) {
                Text(insight.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                if let detail = insight.detail, !detail.isEmpty {
                    Text(detail)
                        .font(.system(size: 10.5, weight: .medium))
                        .foregroundStyle(.white.opacity(0.54))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 1)
    }

    private func dominantFocus(for session: WorkoutSession) -> MuscleGroup? {
        var counts: [MuscleGroup: Int] = [:]
        for log in session.exerciseLogs {
            let completedSetCount = log.sets.filter(\.isCompleted).count
            guard completedSetCount > 0, let exercise = vm.library.exercise(byId: log.exerciseId) else { continue }
            counts[exercise.primaryMuscle, default: 0] += completedSetCount
        }
        return counts.max { lhs, rhs in lhs.value < rhs.value }?.key
    }

    private func hasPreviousSignal(for muscle: MuscleGroup, before session: WorkoutSession) -> Bool {
        vm.workoutHistory.contains { historySession in
            historySession.id != session.id &&
            historySession.isCompleted &&
            historySession.startTime < session.startTime &&
            sessionFocusMuscles(historySession).contains(muscle)
        }
    }

    private func sessionFocusMuscles(_ session: WorkoutSession) -> Set<MuscleGroup> {
        var muscles: Set<MuscleGroup> = []
        for log in session.exerciseLogs where log.sets.contains(where: \.isCompleted) {
            if let exercise = vm.library.exercise(byId: log.exerciseId) {
                muscles.insert(exercise.primaryMuscle)
            }
        }
        return muscles
    }

    // MARK: - Highlights

    @ViewBuilder
    private var highlightsSection: some View {
        if !highlights.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                sectionHeader(
                    title: isLighterDay ? L10n.tr("What changed").uppercased() : L10n.tr("WHAT IMPROVED"),
                    count: highlights.count
                )

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
                sectionHeader(title: L10n.tr("NEXT WORKOUT"), count: nil)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: "calendar")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white.opacity(0.75))
                            .frame(width: 28, height: 28)
                            .background(Color.white.opacity(0.06), in: .rect(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 1) {
                            Text(nextDayName ?? L10n.tr("Upcoming workout"))
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
                                    if !item.tag.isEmpty {
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
        let usesFallbackTarget: Bool
    }

    private struct NextTargetDisplay {
        let detail: String
        let usesFallbackTarget: Bool
    }

    private func nextTargetDetail(weight: Double?, reps: Int?) -> NextTargetDisplay {
        guard
            let weight,
            let reps,
            weight.isFinite,
            weight > 0,
            reps > 0
        else {
            return NextTargetDisplay(
                detail: L10n.tr("Next target will update after another clean set."),
                usesFallbackTarget: true
            )
        }

        return NextTargetDisplay(
            detail: L10n.format("Next: %.1f kg × %d", weight, reps),
            usesFallbackTarget: false
        )
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
                detail = L10n.tr("Beat last workout — push next time")
            }
            items.append(BridgeItem(
                exerciseName: name,
                detail: detail,
                tag: L10n.tr("PUSH"),
                icon: "arrow.up.right.circle.fill",
                color: STRQPalette.success,
                usesFallbackTarget: false
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
                let target = nextTargetDetail(weight: state.lastWeight + 2.5, reps: state.lastReps)
                items.append(BridgeItem(
                    exerciseName: ex.name,
                    detail: target.detail,
                    tag: L10n.tr("PUSH"),
                    icon: "arrow.up.right.circle.fill",
                    color: STRQPalette.success,
                    usesFallbackTarget: target.usesFallbackTarget
                ))
            case .holdAndConsolidate:
                items.append(BridgeItem(
                    exerciseName: ex.name,
                    detail: L10n.tr("Hold load — consolidate technique"),
                    tag: L10n.tr("HOLD"),
                    icon: "pause.circle.fill",
                    color: STRQPalette.warning,
                    usesFallbackTarget: false
                ))
            case .deloadAndRebuild:
                items.append(BridgeItem(
                    exerciseName: ex.name,
                    detail: L10n.format("Deload to %.1f kg — rebuild clean", state.lastWeight * 0.85),
                    tag: "",
                    icon: "arrow.down.circle.fill",
                    color: STRQPalette.warning,
                    usesFallbackTarget: false
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
                        .foregroundStyle(Color.black.opacity(0.92))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.white.opacity(0.94), in: .rect(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(Color.white.opacity(0.22), lineWidth: 0.8)
                        )
                        .shadow(color: Color.white.opacity(0.10), radius: 12, x: 0, y: -2)
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

    private func completionDurationDisplay(for session: WorkoutSession) -> String {
        guard let endTime = session.endTime else { return "<1" }
        let elapsedSeconds = endTime.timeIntervalSince(session.startTime)
        let elapsedMinutes = Int(elapsedSeconds / 60)
        return elapsedMinutes > 0 ? "\(elapsedMinutes)" : "<1"
    }

    private func completionStat(_ title: String, value: String, unit: String?) -> some View {
        VStack(spacing: 5) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                if let numeric = Double(value) {
                    STRQCountUpText(value: numeric)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                } else {
                    Text(value)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
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
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.035), in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
        )
    }

    private func proofAccent(for kind: WorkoutHighlight.Kind) -> Color {
        switch kind {
        case .personalRecord, .bestSet:
            return STRQPalette.gold
        case .volumeUp:
            return STRQPalette.success
        case .volumeDown:
            return STRQPalette.warning
        case .firstTime:
            return STRQPalette.info
        case .consolidation, .longestSession, .streakMilestone, .setsMilestone:
            return STRQBrand.steel
        }
    }

    private func badgeIcon(for kind: WorkoutHighlight.Kind) -> String {
        switch kind {
        case .personalRecord:
            return "trophy.fill"
        case .bestSet:
            return "bolt.fill"
        case .volumeUp:
            return "arrow.up.right.circle.fill"
        case .volumeDown:
            return "equal.circle.fill"
        case .firstTime:
            return "sparkles"
        case .consolidation:
            return "checkmark.seal.fill"
        case .longestSession:
            return "timer"
        case .streakMilestone:
            return "flame.fill"
        case .setsMilestone:
            return "checkmark.seal.fill"
        }
    }

    private func onFirstAppear() {
        withAnimation { appeared = true }
        trophyPulse = hasPR
        celebrationTrigger.toggle()

        guard !reduceMotion else {
            highlightsAppeared = true
            return
        }

        Task { @MainActor in
            if hasPR {
                try? await Task.sleep(for: .milliseconds(160))
                sparkTrigger &+= 1
            }
            try? await Task.sleep(for: .milliseconds(180))
            hapticTick &+= 1
            try? await Task.sleep(for: .milliseconds(200))
            highlightsAppeared = true
            if hasPR {
                try? await Task.sleep(for: .milliseconds(260))
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
            return (STRQPalette.gold, STRQPalette.goldSoft, "bolt.fill")
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

    private var showsPeakBadge: Bool {
        guard highlight.isPrimary else { return false }
        switch highlight.kind {
        case .personalRecord, .bestSet, .longestSession, .streakMilestone, .setsMilestone:
            return true
        case .volumeUp, .volumeDown, .firstTime, .consolidation:
            return false
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
                    if showsPeakBadge {
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
                if let secondary = softenedCompletionSecondary(highlight.valueSecondary) {
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

private func isPeakHighlight(_ highlight: WorkoutHighlight?) -> Bool {
    guard let highlight else { return false }
    switch highlight.kind {
    case .personalRecord, .bestSet:
        return true
    case .volumeUp, .volumeDown, .firstTime, .consolidation, .longestSession, .streakMilestone, .setsMilestone:
        return false
    }
}

private func softenedCompletionSecondary(_ value: String?) -> String? {
    guard let value, !value.isEmpty else { return nil }
    guard value.contains("%") else { return value }
    guard let magnitude = completionPercentMagnitude(from: value) else { return value }
    return magnitude >= 300 ? nil : value
}

private func completionPercentMagnitude(from value: String) -> Double? {
    var number = value
        .replacingOccurrences(of: "%", with: "")
        .replacingOccurrences(of: "+", with: "")
        .trimmingCharacters(in: .whitespacesAndNewlines)

    if let separator = number.first(where: { $0 == "." || $0 == "," }),
       let suffix = number.split(separator: separator).last,
       suffix.count == 3 {
        number.removeAll { $0 == "." || $0 == "," }
    } else {
        number = number.replacingOccurrences(of: ",", with: ".")
    }

    return Double(number).map(abs)
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
        ZStack {
            if !particles.isEmpty {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
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
            }
        }
        .onChange(of: trigger) { _, _ in
            burst(at: UIScreen.main.bounds.size)
        }
    }

    private func burst(at size: CGSize) {
        let count = Int(Double(44) * intensity)
        let now = Date().timeIntervalSinceReferenceDate
        let originX = size.width / 2
        let originY = size.height * 0.28
        var new: [Particle] = []
        for _ in 0..<count {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 70...190)
            let isAccent = Double.random(in: 0...1) < 0.55
            new.append(Particle(
                x: originX,
                y: originY,
                vx: CGFloat(cos(angle)) * speed,
                vy: CGFloat(sin(angle)) * speed - CGFloat.random(in: 18...66),
                size: CGFloat.random(in: 1.6...3.6),
                life: now,
                maxLife: Double.random(in: 0.65...1.15),
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
