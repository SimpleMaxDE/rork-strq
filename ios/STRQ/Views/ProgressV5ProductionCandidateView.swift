import SwiftUI

struct ProgressV5ProductionCandidateView: View {
    let vm: AppViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    private var snapshot: TrainingProgressSnapshot {
        TrainingProgressSnapshot(vm: vm)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                header
                trainingMap(snapshot)
                rhythmStory(snapshot)
                nextUnlock(snapshot)
                evidenceTimeline(snapshot)
                signalReadiness(snapshot)
                analyticsDoorway(snapshot)
            }
            .frame(maxWidth: 430)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, STRQSpacing.md)
            .padding(.top, STRQSpacing.lg)
            .padding(.bottom, STRQSpacing.tabBarHeight + STRQSpacing.xl)
        }
        .background(TrainingProgressStyle.background.ignoresSafeArea())
        .navigationTitle("Training Map")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.42)) {
                appeared = true
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Training Map")
                .font(STRQTypography.headingSmall)
                .foregroundStyle(STRQPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.74)

            Text("A real-data read on what STRQ can safely show right now.")
                .font(STRQTypography.paragraphSmall)
                .foregroundStyle(STRQPalette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
    }

    private func trainingMap(_ snapshot: TrainingProgressSnapshot) -> some View {
        moduleShell(border: snapshot.overallState.tint.opacity(0.24)) {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                HStack(alignment: .top, spacing: STRQSpacing.sm) {
                    VStack(alignment: .leading, spacing: 8) {
                        stateCapsule(snapshot.overallState.label, state: snapshot.overallState)
                        Text(snapshot.headline)
                            .font(STRQTypography.headingXS)
                            .foregroundStyle(STRQPalette.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.78)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(snapshot.subhead)
                            .font(STRQTypography.caption)
                            .foregroundStyle(STRQPalette.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: STRQSpacing.xs)

                    VStack(spacing: 4) {
                        Text("\(snapshot.completedWorkouts)")
                            .font(.system(size: 30, weight: .heavy, design: .rounded).monospacedDigit())
                            .foregroundStyle(STRQPalette.textPrimary)
                        Text(snapshot.completedWorkouts == 1 ? "workout" : "workouts")
                            .font(STRQTypography.micro)
                            .foregroundStyle(STRQPalette.textMuted)
                            .lineLimit(1)
                    }
                    .frame(width: 76, height: 76)
                    .background(TrainingProgressStyle.panel, in: Circle())
                    .overlay(Circle().strokeBorder(snapshot.overallState.tint.opacity(0.20), lineWidth: 1))
                }

                mapCanvas(snapshot)
                    .frame(height: 292)

                HStack(spacing: 0) {
                    mapStat("Window", "\(snapshot.sessionsInWindow)", "in 28d")
                    divider
                    mapStat("Weeks", "\(snapshot.activeWeeks)/4", "active")
                    divider
                    mapStat("Target", "\(snapshot.currentWeekSessions)/\(snapshot.weeklyTarget)", "this week")
                }
                .padding(.vertical, STRQSpacing.sm)
                .background(TrainingProgressStyle.panel, in: .rect(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(TrainingProgressStyle.border, lineWidth: 1)
                )
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
    }

    private func mapCanvas(_ snapshot: TrainingProgressSnapshot) -> some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)

            ZStack {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(TrainingProgressStyle.plot)

                ForEach(snapshot.mapLinks) { link in
                    Path { path in
                        let start = snapshot.node(named: link.start)
                        let end = snapshot.node(named: link.end)
                        path.move(to: CGPoint(x: width * start.x, y: height * start.y))
                        path.addLine(to: CGPoint(x: width * end.x, y: height * end.y))
                    }
                    .stroke(TrainingProgressStyle.borderStrong, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 8]))
                }

                ForEach(snapshot.mapNodes) { node in
                    mapNode(node)
                        .frame(width: node.size, height: node.size)
                        .position(x: width * node.x, y: height * node.y)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Map structure")
                        .font(STRQTypography.labelSmall)
                        .foregroundStyle(STRQPalette.textPrimary)
                    Text(snapshot.mapCaption)
                        .font(STRQTypography.micro)
                        .foregroundStyle(STRQPalette.textMuted)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: min(190, width * 0.58), alignment: .leading)
                .padding(STRQSpacing.sm)
                .background(TrainingProgressStyle.callout, in: .rect(cornerRadius: STRQRadii.md))
                .overlay(
                    RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                        .strokeBorder(TrainingProgressStyle.border, lineWidth: 1)
                )
                .position(x: width * 0.31, y: height * 0.17)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Training Map, \(snapshot.accessibilityMapSummary)"))
    }

    private func mapNode(_ node: TrainingMapNode) -> some View {
        VStack(spacing: 5) {
            Image(systemName: node.icon)
                .font(.system(size: node.isPrimary ? 16 : 14, weight: .bold))
                .foregroundStyle(node.state.tint)

            Text(node.title)
                .font(STRQTypography.micro)
                .foregroundStyle(STRQPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(node.state.label)
                .font(.system(size: 8, weight: .black))
                .foregroundStyle(node.state.tint.opacity(0.86))
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
        .padding(6)
        .background(node.state.background, in: Circle())
        .overlay(
            Circle()
                .strokeBorder(node.state.border, style: StrokeStyle(lineWidth: 1, dash: node.state == .locked ? [4, 5] : []))
        )
    }

    private func rhythmStory(_ snapshot: TrainingProgressSnapshot) -> some View {
        moduleShell {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                sectionTitle("calendar.badge.clock", "Rhythm Story", snapshot.rhythmDetail, state: snapshot.rhythmState)

                HStack(alignment: .lastTextBaseline, spacing: 5) {
                    Text("\(snapshot.daysWithSessions)")
                        .font(.system(size: 36, weight: .heavy, design: .rounded).monospacedDigit())
                        .foregroundStyle(snapshot.rhythmState.tint)
                    Text("/28 days")
                        .font(STRQTypography.caption)
                        .foregroundStyle(STRQPalette.textSecondary)
                        .padding(.bottom, 6)
                    Spacer(minLength: 0)
                    stateCapsule(snapshot.rhythmState.label, state: snapshot.rhythmState)
                }

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7), spacing: 5) {
                    ForEach(snapshot.rhythmDays) { day in
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(day.hasSession ? snapshot.rhythmState.tint.opacity(0.72) : TrainingProgressStyle.track)
                            .frame(height: 14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .strokeBorder(day.isToday ? snapshot.rhythmState.tint.opacity(0.7) : Color.clear, lineWidth: 1)
                            )
                            .accessibilityLabel(Text(day.accessibilityLabel))
                    }
                }

                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(snapshot.weekRows) { week in
                        VStack(spacing: 6) {
                            GeometryReader { proxy in
                                VStack {
                                    Spacer(minLength: 0)
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .fill(week.sessions > 0 ? snapshot.rhythmState.tint.opacity(week.isCurrent ? 0.86 : 0.48) : TrainingProgressStyle.track)
                                        .frame(height: max(6, proxy.size.height * CGFloat(week.ratio)))
                                }
                            }
                            .frame(height: 50)

                            Text(week.label)
                                .font(STRQTypography.micro)
                                .foregroundStyle(week.isCurrent ? snapshot.rhythmState.tint : STRQPalette.textMuted)
                            Text("\(week.sessions)/\(week.target)")
                                .font(.system(size: 10, weight: .heavy, design: .rounded).monospacedDigit())
                                .foregroundStyle(STRQPalette.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(STRQSpacing.sm)
                .background(TrainingProgressStyle.panel, in: .rect(cornerRadius: STRQRadii.md))
            }
        }
    }

    private func nextUnlock(_ snapshot: TrainingProgressSnapshot) -> some View {
        moduleShell(border: snapshot.nextUnlock.state.tint.opacity(0.20)) {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                sectionTitle("bolt.fill", "Next Unlock", "One next step, based on real training history.", state: snapshot.nextUnlock.state)

                HStack(alignment: .top, spacing: STRQSpacing.sm) {
                    Image(systemName: snapshot.nextUnlock.icon)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(snapshot.nextUnlock.state.tint)
                        .frame(width: 38, height: 38)
                        .background(snapshot.nextUnlock.state.tint.opacity(0.12), in: .rect(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 5) {
                        Text(snapshot.nextUnlock.title)
                            .font(STRQTypography.cardTitle)
                            .foregroundStyle(STRQPalette.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                        Text(snapshot.nextUnlock.detail)
                            .font(STRQTypography.caption)
                            .foregroundStyle(STRQPalette.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func evidenceTimeline(_ snapshot: TrainingProgressSnapshot) -> some View {
        moduleShell {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                sectionTitle("checklist", "Evidence Timeline", snapshot.evidenceDetail, state: snapshot.evidenceState)

                if snapshot.evidenceEvents.isEmpty {
                    emptyEvidence
                } else {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array(snapshot.evidenceEvents.enumerated()), id: \.element.id) { index, event in
                            evidenceRow(event, isLast: index == snapshot.evidenceEvents.count - 1)
                        }
                    }
                }
            }
        }
    }

    private var emptyEvidence: some View {
        HStack(alignment: .top, spacing: STRQSpacing.sm) {
            Image(systemName: "circle.dashed")
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(STRQPalette.steel)
                .frame(width: 34, height: 34)
                .background(STRQPalette.steel.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("No completed workouts yet")
                    .font(STRQTypography.labelMedium)
                    .foregroundStyle(STRQPalette.textPrimary)
                Text("The timeline stays quiet until real completed sessions exist.")
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(STRQSpacing.sm)
        .background(TrainingProgressStyle.panel, in: .rect(cornerRadius: STRQRadii.md))
    }

    private func evidenceRow(_ event: EvidenceEvent, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: STRQSpacing.sm) {
            VStack(spacing: 5) {
                Circle()
                    .fill(event.state.tint)
                    .frame(width: 9, height: 9)
                    .padding(.top, 8)
                Rectangle()
                    .fill(isLast ? Color.clear : TrainingProgressStyle.borderStrong)
                    .frame(width: 1, height: isLast ? 0 : 58)
            }
            .frame(width: 18)

            VStack(alignment: .leading, spacing: 7) {
                HStack(spacing: 8) {
                    Text(event.date.formatted(.dateTime.month(.abbreviated).day()))
                        .font(STRQTypography.micro)
                        .foregroundStyle(event.state.tint)
                        .lineLimit(1)
                    Text(event.title)
                        .font(STRQTypography.labelMedium)
                        .foregroundStyle(STRQPalette.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                    Spacer(minLength: 0)
                }

                Text(event.detail)
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(STRQSpacing.sm)
            .background(TrainingProgressStyle.panel, in: .rect(cornerRadius: STRQRadii.md))
            .padding(.bottom, isLast ? 0 : STRQSpacing.xs)
        }
    }

    private func signalReadiness(_ snapshot: TrainingProgressSnapshot) -> some View {
        moduleShell {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                sectionTitle("checkmark.seal.fill", "Signal Readiness", "Each signal earns its state separately.", state: snapshot.overallState)

                VStack(spacing: 8) {
                    ForEach(snapshot.readinessItems) { item in
                        HStack(spacing: STRQSpacing.sm) {
                            Image(systemName: item.icon)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(item.state.tint)
                                .frame(width: 30, height: 30)
                                .background(item.state.tint.opacity(0.11), in: .rect(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(STRQTypography.labelMedium)
                                    .foregroundStyle(STRQPalette.textPrimary)
                                Text(item.detail)
                                    .font(STRQTypography.caption)
                                    .foregroundStyle(STRQPalette.textMuted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Spacer(minLength: STRQSpacing.xs)

                            Text(item.state.label)
                                .font(STRQTypography.micro)
                                .foregroundStyle(item.state.tint)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(item.state.tint.opacity(0.10), in: Capsule())
                        }
                        .padding(STRQSpacing.sm)
                        .background(TrainingProgressStyle.panel, in: .rect(cornerRadius: STRQRadii.md))
                    }
                }
            }
        }
    }

    private func analyticsDoorway(_ snapshot: TrainingProgressSnapshot) -> some View {
        moduleShell(border: STRQPalette.steel.opacity(0.18)) {
            HStack(alignment: .top, spacing: STRQSpacing.sm) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(STRQPalette.steel)
                    .frame(width: 42, height: 42)
                    .background(STRQPalette.steel.opacity(0.11), in: .rect(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 5) {
                    Text("Deeper Analytics")
                        .font(STRQTypography.cardTitle)
                        .foregroundStyle(STRQPalette.textPrimary)
                    Text(snapshot.analyticsDetail)
                        .font(STRQTypography.caption)
                        .foregroundStyle(STRQPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                stateCapsule(snapshot.analyticsState.label, state: snapshot.analyticsState)
            }
        }
    }

    private func sectionTitle(_ icon: String, _ title: String, _ subtitle: String, state: TrainingReadinessState) -> some View {
        HStack(alignment: .top, spacing: STRQSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(state.tint)
                .frame(width: 30, height: 30)
                .background(state.tint.opacity(0.11), in: .rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(STRQTypography.cardTitle)
                    .foregroundStyle(STRQPalette.textPrimary)
                Text(subtitle)
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
    }

    private func mapStat(_ title: String, _ value: String, _ detail: String) -> some View {
        VStack(spacing: 4) {
            Text(title.uppercased())
                .font(.system(size: 8, weight: .black))
                .foregroundStyle(STRQPalette.textMuted)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(value)
                .font(.system(size: 18, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundStyle(STRQPalette.textPrimary)
                .lineLimit(1)
            Text(detail)
                .font(STRQTypography.micro)
                .foregroundStyle(STRQPalette.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(TrainingProgressStyle.border)
            .frame(width: 1, height: 38)
    }

    private func stateCapsule(_ text: String, state: TrainingReadinessState) -> some View {
        Text(text.uppercased())
            .font(.system(size: 9, weight: .black))
            .foregroundStyle(state.tint)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(state.tint.opacity(0.10), in: Capsule())
            .overlay(Capsule().strokeBorder(state.tint.opacity(0.18), lineWidth: 1))
    }

    private func moduleShell<Content: View>(
        border: Color = TrainingProgressStyle.border,
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(STRQSpacing.md)
            .background(TrainingProgressStyle.surface, in: .rect(cornerRadius: 24))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(border, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.18), radius: 18, y: 7)
    }
}

private struct TrainingProgressSnapshot {
    let completedWorkouts: Int
    let sessionsInWindow: Int
    let daysWithSessions: Int
    let activeWeeks: Int
    let currentWeekSessions: Int
    let weeklyTarget: Int
    let overallState: TrainingReadinessState
    let rhythmState: TrainingReadinessState
    let evidenceState: TrainingReadinessState
    let analyticsState: TrainingReadinessState
    let headline: String
    let subhead: String
    let mapCaption: String
    let rhythmDetail: String
    let evidenceDetail: String
    let analyticsDetail: String
    let mapNodes: [TrainingMapNode]
    let mapLinks: [TrainingMapLink]
    let rhythmDays: [RhythmDay]
    let weekRows: [RhythmWeek]
    let nextUnlock: NextUnlock
    let evidenceEvents: [EvidenceEvent]
    let readinessItems: [ReadinessItem]

    var accessibilityMapSummary: String {
        mapNodes.map { "\($0.title) \($0.state.label)" }.joined(separator: ", ")
    }

    init(vm: AppViewModel) {
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
        let sessionsByDay = Dictionary(grouping: sessionsInWindow) { session in
            calendar.startOfDay(for: session.startTime)
        }
        let currentWeekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        let weeklyTarget = max(1, min(vm.profile.daysPerWeek, 7))

        let rhythmDays = (0..<28).compactMap { offset -> RhythmDay? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: windowStart) else { return nil }
            let day = calendar.startOfDay(for: date)
            return RhythmDay(date: day, sessionCount: sessionsByDay[day]?.count ?? 0, isToday: calendar.isDateInToday(day))
        }

        let weekRows = (0..<4).reversed().compactMap { offset -> RhythmWeek? in
            guard
                let start = calendar.date(byAdding: .weekOfYear, value: -offset, to: currentWeekStart),
                let end = calendar.date(byAdding: .day, value: 7, to: start)
            else { return nil }
            let count = completedSessions.filter { session in
                session.startTime >= start && session.startTime < end && session.startTime >= windowStart && session.startTime < tomorrow
            }.count
            return RhythmWeek(
                label: offset == 0 ? "Now" : "\(offset)w",
                sessions: count,
                target: weeklyTarget,
                isCurrent: offset == 0
            )
        }

        let daysWithSessions = rhythmDays.filter(\.hasSession).count
        let activeWeeks = weekRows.filter { $0.sessions > 0 }.count
        let currentWeekSessions = weekRows.first(where: \.isCurrent)?.sessions ?? 0
        let completedWorkouts = vm.totalCompletedWorkouts
        let overallState = Self.overallState(completedWorkouts: completedWorkouts, activeWeeks: activeWeeks)
        let rhythmState = Self.rhythmState(daysWithSessions: daysWithSessions, activeWeeks: activeWeeks, currentWeekSessions: currentWeekSessions, target: weeklyTarget)
        let evidenceState = Self.evidenceState(count: sessionsInWindow.count, activeWeeks: activeWeeks)
        let analyticsState: TrainingReadinessState = completedWorkouts >= 4 ? .readable : (completedWorkouts > 0 ? .forming : .locked)
        let strengthState: TrainingReadinessState = vm.hasEnoughDataForStrengthChart ? .readable : (vm.strengthProgress.isEmpty ? .locked : .forming)

        self.completedWorkouts = completedWorkouts
        self.sessionsInWindow = sessionsInWindow.count
        self.daysWithSessions = daysWithSessions
        self.activeWeeks = activeWeeks
        self.currentWeekSessions = currentWeekSessions
        self.weeklyTarget = weeklyTarget
        self.overallState = overallState
        self.rhythmState = rhythmState
        self.evidenceState = evidenceState
        self.analyticsState = analyticsState
        self.headline = Self.headline(for: completedWorkouts, state: overallState)
        self.subhead = Self.subhead(for: completedWorkouts, activeWeeks: activeWeeks)
        self.mapCaption = Self.mapCaption(for: overallState)
        self.rhythmDetail = Self.rhythmDetail(state: rhythmState, activeWeeks: activeWeeks)
        self.evidenceDetail = Self.evidenceDetail(state: evidenceState)
        self.analyticsDetail = completedWorkouts >= 4
            ? "Detailed strength, body, and volume views remain separate for now."
            : "More training history opens deeper strength, body, and volume reads."
        self.mapNodes = Self.mapNodes(overall: overallState, rhythm: rhythmState, evidence: evidenceState, strength: strengthState, analytics: analyticsState)
        self.mapLinks = TrainingMapLink.standard
        self.rhythmDays = rhythmDays
        self.weekRows = weekRows
        self.nextUnlock = Self.nextUnlock(
            completedWorkouts: completedWorkouts,
            currentWeekSessions: currentWeekSessions,
            target: weeklyTarget,
            hasStrengthRead: vm.hasEnoughDataForStrengthChart
        )
        self.evidenceEvents = Array(completedSessions.prefix(5)).map { Self.event(from: $0) }
        self.readinessItems = [
            ReadinessItem(title: "Training Map", detail: Self.mapReadinessDetail(for: overallState), icon: "map.fill", state: overallState),
            ReadinessItem(title: "Rhythm Story", detail: "\(daysWithSessions) session days in the last 28 days.", icon: "calendar.badge.clock", state: rhythmState),
            ReadinessItem(title: "Evidence Timeline", detail: sessionsInWindow.isEmpty ? "Waiting for completed sessions." : "\(sessionsInWindow.count) sessions in the current window.", icon: "checklist", state: evidenceState),
            ReadinessItem(title: "Deep Trends", detail: strengthState == .readable ? "Repeated anchors are readable." : "Repeated anchors are still forming.", icon: "chart.line.uptrend.xyaxis", state: strengthState)
        ]
    }

    func node(named name: String) -> TrainingMapNode {
        mapNodes.first { $0.title == name } ?? mapNodes[0]
    }

    private static func overallState(completedWorkouts: Int, activeWeeks: Int) -> TrainingReadinessState {
        if completedWorkouts == 0 { return .locked }
        if completedWorkouts >= 4 && activeWeeks >= 2 { return .readable }
        return .forming
    }

    private static func rhythmState(daysWithSessions: Int, activeWeeks: Int, currentWeekSessions: Int, target: Int) -> TrainingReadinessState {
        if daysWithSessions == 0 { return .locked }
        if daysWithSessions >= 4 && activeWeeks >= 2 { return .readable }
        if currentWeekSessions >= target && daysWithSessions >= target { return .readable }
        return .forming
    }

    private static func evidenceState(count: Int, activeWeeks: Int) -> TrainingReadinessState {
        if count == 0 { return .locked }
        if count >= 3 && activeWeeks >= 2 { return .readable }
        return .forming
    }

    private static func headline(for completedWorkouts: Int, state: TrainingReadinessState) -> String {
        switch state {
        case .locked:
            return "Your first workout starts the map."
        case .forming:
            return completedWorkouts == 1 ? "One workout has started the record." : "The map is taking shape."
        case .readable:
            return "Your recent training has a readable structure."
        }
    }

    private static func subhead(for completedWorkouts: Int, activeWeeks: Int) -> String {
        if completedWorkouts == 0 {
            return "No training claim appears until completed workout history exists."
        }
        if completedWorkouts < 4 {
            return "STRQ is using completed sessions only, keeping deeper reads quiet until repeats exist."
        }
        return "\(completedWorkouts) completed workouts across \(activeWeeks) recent active weeks power this view."
    }

    private static func mapCaption(for state: TrainingReadinessState) -> String {
        switch state {
        case .locked:
            return "The structure is locked until your first completed session."
        case .forming:
            return "Early signals are visible, but detailed area reads stay quiet."
        case .readable:
            return "The structure is readable; detailed area claims stay conservative."
        }
    }

    private static func rhythmDetail(state: TrainingReadinessState, activeWeeks: Int) -> String {
        switch state {
        case .locked:
            return "Completed workouts create the rhythm."
        case .forming:
            return "A few session days are visible."
        case .readable:
            return "Cadence spans \(activeWeeks) recent weeks."
        }
    }

    private static func evidenceDetail(state: TrainingReadinessState) -> String {
        switch state {
        case .locked:
            return "Only completed sessions appear here."
        case .forming:
            return "Recent sessions are real, but the pattern is still forming."
        case .readable:
            return "Recent sessions explain the current read."
        }
    }

    private static func mapReadinessDetail(for state: TrainingReadinessState) -> String {
        switch state {
        case .locked:
            return "Waiting for completed workout history."
        case .forming:
            return "Using high-level signals only."
        case .readable:
            return "Structure is readable without exact area claims."
        }
    }

    private static func mapNodes(
        overall: TrainingReadinessState,
        rhythm: TrainingReadinessState,
        evidence: TrainingReadinessState,
        strength: TrainingReadinessState,
        analytics: TrainingReadinessState
    ) -> [TrainingMapNode] {
        [
            TrainingMapNode(title: "Sessions", icon: "figure.strengthtraining.traditional", state: overall, x: 0.28, y: 0.44, size: 86, isPrimary: true),
            TrainingMapNode(title: "Rhythm", icon: "calendar.badge.clock", state: rhythm, x: 0.58, y: 0.24, size: 76, isPrimary: false),
            TrainingMapNode(title: "Evidence", icon: "checklist", state: evidence, x: 0.74, y: 0.52, size: 78, isPrimary: false),
            TrainingMapNode(title: "Strength", icon: "chart.line.uptrend.xyaxis", state: strength, x: 0.42, y: 0.72, size: 78, isPrimary: false),
            TrainingMapNode(title: "Detail", icon: "lock.fill", state: analytics, x: 0.22, y: 0.72, size: 70, isPrimary: false)
        ]
    }

    private static func nextUnlock(
        completedWorkouts: Int,
        currentWeekSessions: Int,
        target: Int,
        hasStrengthRead: Bool
    ) -> NextUnlock {
        if completedWorkouts == 0 {
            return NextUnlock(title: "Complete your first workout", detail: "That starts the record and opens the first real map signals.", icon: "play.fill", state: .locked)
        }
        if completedWorkouts == 1 {
            return NextUnlock(title: "Log workout 2", detail: "A second completed session gives STRQ the first repeat to compare.", icon: "repeat", state: .forming)
        }
        if completedWorkouts == 2 {
            return NextUnlock(title: "Log workout 3", detail: "A third completed session makes weekly rhythm easier to read.", icon: "calendar.badge.plus", state: .forming)
        }
        if currentWeekSessions < target {
            let remaining = max(1, target - currentWeekSessions)
            return NextUnlock(
                title: remaining == 1 ? "Close one more session" : "Close \(remaining) more sessions",
                detail: "That keeps the weekly rhythm on track without turning open days into failure.",
                icon: "target",
                state: .forming
            )
        }
        if !hasStrengthRead {
            return NextUnlock(title: "Repeat a strength anchor", detail: "Repeated logged sets help the deep trend view become readable.", icon: "chart.line.uptrend.xyaxis", state: .forming)
        }
        return NextUnlock(title: "Keep the week readable", detail: "Repeat the cadence next week so the structure stays easy to trust.", icon: "checkmark.seal.fill", state: .readable)
    }

    private static func event(from session: WorkoutSession) -> EvidenceEvent {
        let title = session.dayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Workout" : session.dayName
        let sets = session.completedSetCount
        let reps = session.completedRepCount
        let minutes = session.endTime.map { max(0, Int($0.timeIntervalSince(session.startTime) / 60)) } ?? 0
        let volume = session.totalVolume

        let detail: String
        if sets > 0 && minutes > 0 && volume > 0 {
            detail = "\(sets) sets over \(minutes)min with \(ForgeTheme.formatVolume(volume))kg total volume."
        } else if sets > 0 && volume > 0 {
            detail = "\(sets) completed sets with \(ForgeTheme.formatVolume(volume))kg total volume."
        } else if sets > 0 {
            detail = "\(sets) completed sets and \(reps) reps logged."
        } else {
            detail = "Completed workout recorded from history."
        }

        return EvidenceEvent(id: session.id, date: session.startTime, title: title, detail: detail, state: .readable)
    }
}

private enum TrainingReadinessState: Equatable {
    case locked
    case forming
    case readable

    var label: String {
        switch self {
        case .locked:
            return "Locked"
        case .forming:
            return "Forming"
        case .readable:
            return "Readable"
        }
    }

    var tint: Color {
        switch self {
        case .locked:
            return STRQPalette.textMuted
        case .forming:
            return STRQPalette.warning
        case .readable:
            return STRQPalette.steel
        }
    }

    var background: Color {
        switch self {
        case .locked:
            return STRQPalette.surfaceStrong.opacity(0.58)
        case .forming:
            return STRQPalette.warning.opacity(0.12)
        case .readable:
            return STRQPalette.steel.opacity(0.13)
        }
    }

    var border: Color {
        switch self {
        case .locked:
            return STRQPalette.borderSubtle
        case .forming:
            return STRQPalette.warning.opacity(0.28)
        case .readable:
            return STRQPalette.steel.opacity(0.28)
        }
    }
}

private struct TrainingMapNode: Identifiable {
    let title: String
    let icon: String
    let state: TrainingReadinessState
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let isPrimary: Bool

    var id: String { title }
}

private struct TrainingMapLink: Identifiable {
    let start: String
    let end: String

    var id: String { "\(start)-\(end)" }

    static let standard = [
        TrainingMapLink(start: "Sessions", end: "Rhythm"),
        TrainingMapLink(start: "Rhythm", end: "Evidence"),
        TrainingMapLink(start: "Evidence", end: "Strength"),
        TrainingMapLink(start: "Strength", end: "Detail"),
        TrainingMapLink(start: "Detail", end: "Sessions")
    ]
}

private struct RhythmDay: Identifiable {
    let date: Date
    let sessionCount: Int
    let isToday: Bool

    var id: Date { date }
    var hasSession: Bool { sessionCount > 0 }
    var accessibilityLabel: String {
        if hasSession {
            return "\(date.formatted(.dateTime.month().day())), \(sessionCount) completed sessions"
        }
        return "\(date.formatted(.dateTime.month().day())), no completed session"
    }
}

private struct RhythmWeek: Identifiable {
    let label: String
    let sessions: Int
    let target: Int
    let isCurrent: Bool

    var id: String { label }
    var ratio: Double {
        min(1.0, Double(sessions) / Double(max(target, 1)))
    }
}

private struct NextUnlock {
    let title: String
    let detail: String
    let icon: String
    let state: TrainingReadinessState
}

private struct EvidenceEvent: Identifiable {
    let id: String
    let date: Date
    let title: String
    let detail: String
    let state: TrainingReadinessState
}

private struct ReadinessItem: Identifiable {
    let title: String
    let detail: String
    let icon: String
    let state: TrainingReadinessState

    var id: String { title }
}

private enum TrainingProgressStyle {
    static let background = STRQPalette.backgroundPrimary
    static let surface = STRQPalette.surfaceBase
    static let panel = Color.white.opacity(0.035)
    static let plot = Color.white.opacity(0.028)
    static let callout = STRQPalette.surfaceRaised.opacity(0.82)
    static let track = Color.white.opacity(0.06)
    static let border = Color.white.opacity(0.08)
    static let borderStrong = Color.white.opacity(0.14)
}

#if DEBUG
private struct ProgressV5ProductionCandidateView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProgressV5ProductionCandidateView(vm: AppViewModel())
        }
    }
}
#endif
