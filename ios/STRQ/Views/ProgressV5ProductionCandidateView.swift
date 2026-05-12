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
            .padding(.bottom, STRQSpacing.tabBarHeight + STRQSpacing.xxxl)
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

            Text("A clear read from your completed workouts.")
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
                        stateCapsule(snapshot.mapStateLabel, state: snapshot.overallState)
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
                    .fill(TrainingProgressStyle.stageGradient)

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
                .stroke(TrainingProgressStyle.grid, style: StrokeStyle(lineWidth: 1, dash: [3, 8]))

                ForEach(snapshot.mapLinks) { link in
                    let start = snapshot.node(named: link.start)
                    let end = snapshot.node(named: link.end)
                    let isQuiet = start.state == .locked || end.state == .locked

                    Path { path in
                        path.move(to: CGPoint(x: width * start.x, y: height * start.y))
                        path.addLine(to: CGPoint(x: width * end.x, y: height * end.y))
                    }
                    .stroke(
                        (isQuiet ? TrainingProgressStyle.steel : end.state.tint).opacity(isQuiet ? 0.24 : 0.56),
                        style: StrokeStyle(lineWidth: isQuiet ? 1.25 : 2.25, lineCap: .round, dash: isQuiet ? [5, 7] : [])
                    )
                }

                ForEach(snapshot.mapNodes) { node in
                    mapNode(node)
                        .frame(width: node.size, height: node.size)
                        .position(x: width * node.x, y: height * node.y)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Training Map")
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
        .padding(STRQSpacing.xs)
        .background(TrainingProgressStyle.plot, in: .rect(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(TrainingProgressStyle.border, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Training Map, \(snapshot.accessibilityMapSummary)"))
    }

    private func mapNode(_ node: TrainingMapNode) -> some View {
        ZStack {
            Circle()
                .fill(node.state.background)
                .overlay(
                    Circle()
                        .strokeBorder(node.state.border, style: StrokeStyle(lineWidth: 1, dash: node.state == .locked ? [4, 5] : []))
                )
                .shadow(color: node.state.shadow, radius: node.state == .locked ? 0 : 11, y: 4)

            Circle()
                .trim(from: 0, to: node.state.ringProgress)
                .stroke(node.state.tint.opacity(node.state == .locked ? 0.24 : 0.92), style: StrokeStyle(lineWidth: node.isPrimary ? 3 : 2.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(4)

            VStack(spacing: 4) {
                Image(systemName: node.icon)
                    .font(.system(size: node.isPrimary ? 16 : 14, weight: .bold))
                    .foregroundStyle(node.state.iconTint)

                Text(node.title)
                    .font(STRQTypography.micro)
                    .foregroundStyle(node.state == .locked ? STRQPalette.textSecondary : STRQPalette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(node.statusLabel)
                    .font(.system(size: 8, weight: .black))
                    .foregroundStyle(node.state.tint.opacity(node.state == .locked ? 0.70 : 0.94))
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
            }
            .padding(6)
        }
        .accessibilityLabel(Text("\(node.title), \(node.statusLabel)"))
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
                    stateCapsule(snapshot.rhythmStateLabel, state: snapshot.rhythmState)
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
                sectionTitle("bolt.fill", "Next Unlock", "The next completed workout that makes the map easier to trust.", state: snapshot.nextUnlock.state)

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
                Text("Complete your first workout to start the timeline.")
                    .font(STRQTypography.labelMedium)
                    .foregroundStyle(STRQPalette.textPrimary)
                Text("Only completed workouts appear here. No claims yet.")
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
                sectionTitle("checkmark.seal.fill", "Signal Readiness", "What completed workouts can safely support.", state: snapshot.overallState)

                VStack(spacing: 8) {
                    ForEach(snapshot.readinessItems) { item in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: STRQSpacing.sm) {
                                Image(systemName: item.icon)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundStyle(item.state.iconTint)
                                    .frame(width: 30, height: 30)
                                    .background(item.state.tint.opacity(0.11), in: .rect(cornerRadius: 10))

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(item.title)
                                        .font(STRQTypography.labelMedium)
                                        .foregroundStyle(STRQPalette.textPrimary)
                                    Text(item.label)
                                        .font(.system(size: 9, weight: .black))
                                        .foregroundStyle(item.state.tint)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.72)
                                }

                                Spacer(minLength: 0)
                            }

                            Text(item.detail)
                                .font(STRQTypography.caption)
                                .foregroundStyle(STRQPalette.textMuted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(STRQSpacing.sm)
                        .background(
                            LinearGradient(
                                colors: [item.state.tint.opacity(0.10), TrainingProgressStyle.panel],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            in: .rect(cornerRadius: STRQRadii.md)
                        )
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .fill(item.state.tint.opacity(item.state == .locked ? 0.32 : 0.72))
                                .frame(width: 3)
                                .padding(.vertical, 12)
                        }
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

                stateCapsule(snapshot.analyticsStateLabel, state: snapshot.analyticsState)
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

@MainActor
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
    let mapStateLabel: String
    let rhythmStateLabel: String
    let evidenceStateLabel: String
    let analyticsStateLabel: String
    let strengthStateLabel: String
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
        mapNodes.map { "\($0.title) \($0.statusLabel)" }.joined(separator: ", ")
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
        let mapStateLabel = Self.mapStateLabel(state: overallState, completedWorkouts: completedWorkouts)
        let rhythmStateLabel = Self.rhythmStateLabel(state: rhythmState)
        let evidenceStateLabel = Self.evidenceStateLabel(state: evidenceState)
        let analyticsStateLabel = Self.deepTrendLabel(state: analyticsState)
        let strengthStateLabel = Self.deepTrendLabel(state: strengthState)

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
        self.mapStateLabel = mapStateLabel
        self.rhythmStateLabel = rhythmStateLabel
        self.evidenceStateLabel = evidenceStateLabel
        self.analyticsStateLabel = analyticsStateLabel
        self.strengthStateLabel = strengthStateLabel
        self.headline = Self.headline(for: completedWorkouts, state: overallState)
        self.subhead = Self.subhead(for: completedWorkouts, activeWeeks: activeWeeks)
        self.mapCaption = Self.mapCaption(for: overallState)
        self.rhythmDetail = Self.rhythmDetail(state: rhythmState, activeWeeks: activeWeeks)
        self.evidenceDetail = Self.evidenceDetail(state: evidenceState)
        self.analyticsDetail = completedWorkouts >= 4
            ? "Detailed strength, body, and volume views are available without changing this map."
            : "More completed workouts open deeper strength, body, and volume reads."
        self.mapNodes = Self.mapNodes(
            overall: overallState,
            rhythm: rhythmState,
            evidence: evidenceState,
            strength: strengthState,
            analytics: analyticsState
        )
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
            ReadinessItem(title: "Training Map", label: mapStateLabel, detail: Self.mapReadinessDetail(for: overallState), icon: "map.fill", state: overallState),
            ReadinessItem(title: "Rhythm Story", label: rhythmStateLabel, detail: Self.rhythmReadinessDetail(daysWithSessions: daysWithSessions, activeWeeks: activeWeeks, state: rhythmState), icon: "calendar.badge.clock", state: rhythmState),
            ReadinessItem(title: "Evidence Timeline", label: evidenceStateLabel, detail: sessionsInWindow.isEmpty ? "Waiting for completed sessions." : "\(sessionsInWindow.count) completed sessions in the current window.", icon: "checklist", state: evidenceState),
            ReadinessItem(title: "Deep Trends", label: strengthStateLabel, detail: strengthState == .readable ? "Repeated anchors are available." : "Repeated anchors need more history.", icon: "chart.line.uptrend.xyaxis", state: strengthState)
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
            return "Complete your first workout to start the map."
        case .forming:
            return completedWorkouts == 1 ? "One workout has started the record." : "The map is taking shape."
        case .readable:
            return "Your recent training has a readable structure."
        }
    }

    private static func subhead(for completedWorkouts: Int, activeWeeks: Int) -> String {
        if completedWorkouts == 0 {
            return "The map fills from completed workouts. No claims yet."
        }
        if completedWorkouts < 4 {
            return "STRQ is using completed sessions only, keeping deeper reads quiet until repeats exist."
        }
        return "\(completedWorkouts) completed workouts across \(activeWeeks) recent active weeks power this view."
    }

    private static func mapCaption(for state: TrainingReadinessState) -> String {
        switch state {
        case .locked:
            return "Complete your first workout to start the map. No claims yet."
        case .forming:
            return "Early signals are visible. Detailed area reads stay quiet."
        case .readable:
            return "The structure is readable; detailed area claims stay conservative."
        }
    }

    private static func rhythmDetail(state: TrainingReadinessState, activeWeeks: Int) -> String {
        switch state {
        case .locked:
            return "Completed workouts start the rhythm."
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
            return "Complete your first workout. No claims yet."
        case .forming:
            return "Using high-level signals only."
        case .readable:
            return "Structure is readable without exact area claims."
        }
    }

    private static func rhythmReadinessDetail(daysWithSessions: Int, activeWeeks: Int, state: TrainingReadinessState) -> String {
        switch state {
        case .locked:
            return "The first completed workout starts the rhythm."
        case .forming:
            return "\(daysWithSessions) session days are starting to show a cadence."
        case .readable:
            return "Cadence spans \(activeWeeks) recent active weeks."
        }
    }

    private static func mapStateLabel(state: TrainingReadinessState, completedWorkouts: Int) -> String {
        switch state {
        case .locked:
            return completedWorkouts == 0 ? "No claims yet" : "Waiting"
        case .forming:
            return "Starting"
        case .readable:
            return "Readable"
        }
    }

    private static func rhythmStateLabel(state: TrainingReadinessState) -> String {
        switch state {
        case .locked:
            return "Waiting"
        case .forming:
            return "Rhythm forming"
        case .readable:
            return "Rhythm stable"
        }
    }

    private static func evidenceStateLabel(state: TrainingReadinessState) -> String {
        switch state {
        case .locked:
            return "No sessions yet"
        case .forming:
            return "Sessions starting"
        case .readable:
            return "Enough sessions"
        }
    }

    private static func deepTrendLabel(state: TrainingReadinessState) -> String {
        switch state {
        case .locked:
            return "Locked"
        case .forming:
            return "Opening"
        case .readable:
            return "Available"
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
            TrainingMapNode(title: "Sessions", statusLabel: nodeLabel(for: overall, locked: "Start here", forming: "Started", readable: "Readable"), icon: "figure.strengthtraining.traditional", state: overall, x: 0.28, y: 0.44, size: 86, isPrimary: true),
            TrainingMapNode(title: "Rhythm", statusLabel: nodeLabel(for: rhythm, locked: "Waiting", forming: "Forming", readable: "Stable"), icon: "calendar.badge.clock", state: rhythm, x: 0.58, y: 0.24, size: 76, isPrimary: false),
            TrainingMapNode(title: "Evidence", statusLabel: nodeLabel(for: evidence, locked: "Quiet", forming: "Starting", readable: "Enough"), icon: "checklist", state: evidence, x: 0.74, y: 0.52, size: 78, isPrimary: false),
            TrainingMapNode(title: "Strength", statusLabel: nodeLabel(for: strength, locked: "Needs reps", forming: "Opening", readable: "Available"), icon: "chart.line.uptrend.xyaxis", state: strength, x: 0.42, y: 0.72, size: 78, isPrimary: false),
            TrainingMapNode(title: "Detail", statusLabel: nodeLabel(for: analytics, locked: "Later", forming: "Opening", readable: "Available"), icon: "lock.fill", state: analytics, x: 0.22, y: 0.72, size: 70, isPrimary: false)
        ]
    }

    private static func nodeLabel(for state: TrainingReadinessState, locked: String, forming: String, readable: String) -> String {
        switch state {
        case .locked:
            return locked
        case .forming:
            return forming
        case .readable:
            return readable
        }
    }

    private static func nextUnlock(
        completedWorkouts: Int,
        currentWeekSessions: Int,
        target: Int,
        hasStrengthRead: Bool
    ) -> NextUnlock {
        if completedWorkouts == 0 {
            return NextUnlock(title: "One more completed workout starts the map.", detail: "Complete your first workout so the map can begin filling from real training history.", icon: "play.fill", state: .locked)
        }
        if completedWorkouts == 1 {
            return NextUnlock(title: "One more session gives the map a repeat.", detail: "Complete workout 2 to give STRQ the first real pattern to compare.", icon: "repeat", state: .forming)
        }
        if completedWorkouts == 2 {
            return NextUnlock(title: "One more session steadies the rhythm.", detail: "Complete workout 3 to make the weekly story easier to read.", icon: "calendar.badge.plus", state: .forming)
        }
        if currentWeekSessions < target {
            let remaining = max(1, target - currentWeekSessions)
            return NextUnlock(
                title: remaining == 1 ? "1 session left to stabilize the week." : "\(remaining) sessions left to stabilize the week.",
                detail: remaining == 1 ? "Complete one more session to make this week stable." : "Complete \(remaining) more sessions to make this week stable.",
                icon: "target",
                state: .forming
            )
        }
        if !hasStrengthRead {
            return NextUnlock(title: "Repeat one anchor to open deep trends.", detail: "Repeated logged sets help the deeper trend view become available.", icon: "chart.line.uptrend.xyaxis", state: .forming)
        }
        return NextUnlock(title: "Keep the week easy to trust.", detail: "Repeat the cadence next week so the structure stays readable.", icon: "checkmark.seal.fill", state: .readable)
    }

    private static func event(from session: WorkoutSession) -> EvidenceEvent {
        let title = session.dayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Workout" : session.dayName
        let sets = session.completedSetCount
        let reps = session.completedRepCount
        let minutes = session.endTime.map { max(0, Int($0.timeIntervalSince(session.startTime) / 60)) } ?? 0
        let volume = session.totalVolume
        let state: TrainingReadinessState

        let detail: String
        if sets > 0 && minutes > 0 && volume > 0 {
            detail = "\(sets) sets over \(minutes)min with \(Self.formattedVolumeText(volume))."
            state = .readable
        } else if sets > 0 && volume > 0 {
            detail = "\(sets) completed sets with \(Self.formattedVolumeText(volume))."
            state = .readable
        } else if sets > 0 {
            detail = "\(sets) completed sets and \(reps) reps logged."
            state = .forming
        } else {
            detail = "Completed workout recorded from history."
            state = .forming
        }

        return EvidenceEvent(id: session.id, date: session.startTime, title: title, detail: detail, state: state)
    }

    private static func formattedVolumeText(_ volume: Double) -> String {
        if volume >= 1000 {
            let thousands = volume / 1000
            let value = thousands >= 10
                ? String(format: "%.0f", thousands)
                : String(format: "%.1f", thousands).replacingOccurrences(of: ".0", with: "")
            return "\(value)k kg total volume"
        }

        return "\(String(format: "%.0f", volume)) kg total volume"
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
            return TrainingProgressStyle.steel
        case .forming:
            return TrainingProgressStyle.amber
        case .readable:
            return TrainingProgressStyle.signal
        }
    }

    var background: Color {
        switch self {
        case .locked:
            return TrainingProgressStyle.surfaceSecondary.opacity(0.72)
        case .forming:
            return TrainingProgressStyle.amber.opacity(0.16)
        case .readable:
            return TrainingProgressStyle.signal.opacity(0.16)
        }
    }

    var border: Color {
        switch self {
        case .locked:
            return TrainingProgressStyle.steel.opacity(0.22)
        case .forming:
            return TrainingProgressStyle.amber.opacity(0.50)
        case .readable:
            return TrainingProgressStyle.signal.opacity(0.54)
        }
    }

    var iconTint: Color {
        switch self {
        case .locked:
            return TrainingProgressStyle.steel.opacity(0.70)
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

private struct TrainingMapNode: Identifiable {
    let title: String
    let statusLabel: String
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
    let label: String
    let detail: String
    let icon: String
    let state: TrainingReadinessState

    var id: String { title }
}

private enum TrainingProgressStyle {
    static let background = Color(red: 0.020, green: 0.022, blue: 0.026)
    static let stage = Color(red: 0.035, green: 0.067, blue: 0.086)
    static let surfaceDeep = Color(red: 0.031, green: 0.039, blue: 0.055)
    static let surface = Color(red: 0.055, green: 0.066, blue: 0.082)
    static let surfaceSecondary = Color(red: 0.082, green: 0.106, blue: 0.133)
    static let panel = Color.white.opacity(0.045)
    static let plot = Color(red: 0.027, green: 0.039, blue: 0.059)
    static let callout = Color(red: 0.067, green: 0.086, blue: 0.106).opacity(0.90)
    static let track = Color(red: 0.153, green: 0.192, blue: 0.231)
    static let border = Color.white.opacity(0.08)
    static let borderStrong = Color.white.opacity(0.14)
    static let grid = Color.white.opacity(0.06)
    static let steel = Color(red: 0.667, green: 0.718, blue: 0.780)
    static let signal = Color(red: 0.412, green: 0.843, blue: 0.808)
    static let amber = Color(red: 0.831, green: 0.722, blue: 0.416)
    static let stageGradient = LinearGradient(
        colors: [stage, surfaceDeep, plot],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
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
