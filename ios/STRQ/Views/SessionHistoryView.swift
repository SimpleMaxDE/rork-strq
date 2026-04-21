import SwiftUI

struct SessionHistoryView: View {
    let vm: AppViewModel
    @State private var selectedSession: WorkoutSession?

    private var sessions: [WorkoutSession] {
        vm.workoutHistory.filter(\.isCompleted).sorted { $0.startTime > $1.startTime }
    }

    private var groupedSessions: [(String, [WorkoutSession])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: sessions) { session -> DateComponents in
            calendar.dateComponents([.year, .month], from: session.startTime)
        }
        return grouped
            .sorted {
                guard let lhs = calendar.date(from: $0.key), let rhs = calendar.date(from: $1.key) else { return false }
                return lhs > rhs
            }
            .map { key, value in
                let date = calendar.date(from: key) ?? Date()
                let title = date.formatted(.dateTime.month(.wide).year())
                return (title, value.sorted { $0.startTime > $1.startTime })
            }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                summaryBar
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                if sessions.isEmpty {
                    emptyState
                        .padding(.top, 60)
                } else {
                    LazyVStack(spacing: 14, pinnedViews: []) {
                        ForEach(groupedSessions, id: \.0) { month, monthSessions in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(month.uppercased())
                                        .font(.system(size: 10, weight: .black))
                                        .tracking(1.2)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("\(monthSessions.count) \(monthSessions.count == 1 ? "session" : "sessions")")
                                        .font(.system(size: 10, weight: .semibold).monospacedDigit())
                                        .foregroundStyle(.tertiary)
                                }
                                .padding(.horizontal, 4)

                                VStack(spacing: 0) {
                                    ForEach(Array(monthSessions.enumerated()), id: \.element.id) { index, session in
                                        Button { selectedSession = session } label: {
                                            sessionRow(session)
                                        }
                                        .buttonStyle(.strqRow)
                                        if index < monthSessions.count - 1 {
                                            Rectangle().fill(Color.white.opacity(0.04)).frame(height: 0.5)
                                                .padding(.leading, 54)
                                        }
                                    }
                                }
                                .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
                                )
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedSession) { session in
            NavigationStack {
                SessionDetailView(vm: vm, session: session)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private var summaryBar: some View {
        let totalSets = sessions.flatMap(\.exerciseLogs).flatMap(\.sets).filter(\.isCompleted).count
        let totalVolume = sessions.reduce(0.0) { $0 + $1.totalVolume }
        let totalMinutes = sessions.compactMap { s -> Int? in
            guard let end = s.endTime else { return nil }
            return Int(end.timeIntervalSince(s.startTime) / 60)
        }.reduce(0, +)

        return HStack(spacing: 10) {
            logbookStat(value: "\(sessions.count)", label: "Sessions")
            logbookStat(value: ForgeTheme.formatVolume(totalVolume), label: "Volume", unit: "kg")
            logbookStat(value: "\(totalSets)", label: "Sets")
            logbookStat(value: "\(totalMinutes / 60)", label: "Hours")
        }
    }

    private func logbookStat(value: String, label: String, unit: String? = nil) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(size: 17, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if let unit {
                    Text(unit)
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .tracking(0.4)
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "book.pages")
                .font(.system(size: 42))
                .foregroundStyle(STRQBrand.steel)
            Text("Your training log is starting")
                .font(.headline)
            Text("Finished sessions collect here as your week builds, so progress stays easy to review later.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
    }

    private func sessionRow(_ session: WorkoutSession) -> some View {
        let duration = session.endTime.map { Int($0.timeIntervalSince(session.startTime) / 60) } ?? 0
        let sets = session.exerciseLogs.flatMap(\.sets).filter(\.isCompleted).count
        let reps = session.exerciseLogs.flatMap(\.sets).filter(\.isCompleted).reduce(0) { $0 + $1.reps }
        let hasPR = session.exerciseLogs.flatMap(\.sets).contains(where: \.isPR)
        let volumeDelta = volumeDelta(for: session)
        let verdict = sessionVerdictTag(session: session, hasPR: hasPR, volumeDelta: volumeDelta)

        return HStack(spacing: 10) {
            VStack(spacing: 0) {
                Text(session.startTime.formatted(.dateTime.day()))
                    .font(.system(size: 16, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white)
                Text(session.startTime.formatted(.dateTime.weekday(.abbreviated)))
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.tertiary)
                    .textCase(.uppercase)
                    .tracking(0.3)
            }
            .frame(width: 32)

            Rectangle().fill(Color.white.opacity(0.06)).frame(width: 0.5, height: 30)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(session.dayName)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    if hasPR {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(STRQPalette.gold)
                    }
                    if let verdict {
                        Text(verdict.label.uppercased())
                            .font(.system(size: 8, weight: .black))
                            .tracking(0.6)
                            .foregroundStyle(STRQPalette.color(for: verdict.state))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(STRQPalette.soft(for: verdict.state), in: Capsule())
                    }
                }
                HStack(spacing: 6) {
                    logMetric("\(duration)", unit: "min")
                    dot
                    logMetric("\(session.exerciseLogs.filter(\.isCompleted).count)", unit: "ex")
                    dot
                    logMetric("\(sets)", unit: "sets")
                    dot
                    logMetric("\(reps)", unit: "reps")
                }
            }

            Spacer(minLength: 0)

            VStack(alignment: .trailing, spacing: 2) {
                Text(ForgeTheme.formatVolume(session.totalVolume))
                    .font(.system(size: 13, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white)
                if let volumeDelta, abs(volumeDelta) >= 0.03 {
                    Text(String(format: "%@%.0f%%", volumeDelta > 0 ? "+" : "", volumeDelta * 100))
                        .font(.system(size: 9, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(volumeDelta > 0 ? STRQPalette.success : STRQPalette.warning)
                } else {
                    Text("kg")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(.tertiary)
                        .textCase(.uppercase)
                        .tracking(0.3)
                }
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.quaternary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .contentShape(.rect)
    }

    private var dot: some View {
        Text("·")
            .font(.caption2)
            .foregroundStyle(.quaternary)
    }

    private func volumeDelta(for session: WorkoutSession) -> Double? {
        guard let prev = sessions.first(where: { $0.startTime < session.startTime && $0.dayName == session.dayName && $0.isCompleted }) else { return nil }
        guard prev.totalVolume > 0 else { return nil }
        return (session.totalVolume - prev.totalVolume) / prev.totalVolume
    }

    private func sessionVerdictTag(session: WorkoutSession, hasPR: Bool, volumeDelta: Double?) -> (label: String, state: STRQPalette.State)? {
        if hasPR { return ("PR", .gold) }
        if let d = volumeDelta {
            if d >= 0.05 { return ("Up", .success) }
            if d <= -0.08 { return ("Down", .warning) }
            return ("Held", .neutral)
        }
        return nil
    }

    private func logMetric(_ value: String, unit: String) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 2) {
            Text(value)
                .font(.system(size: 11, weight: .semibold, design: .rounded).monospacedDigit())
                .foregroundStyle(.secondary)
            Text(unit)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.tertiary)
        }
    }
}

struct SessionDetailView: View {
    let vm: AppViewModel
    let session: WorkoutSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                header
                verdictBanner
                statsRow
                if let note = sessionNote {
                    noteCard(note)
                }
                exercisesList
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle(session.dayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
                    .fontWeight(.semibold)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(session.startTime.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
                .font(.subheadline.weight(.semibold))
            Text(session.startTime.formatted(.dateTime.hour().minute()))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    private var highlightResult: WorkoutHighlightBuilder.Result {
        WorkoutHighlightBuilder.buildResult(
            session: session,
            history: vm.workoutHistory,
            streak: vm.streak,
            exerciseName: { id in vm.library.exercise(byId: id)?.name ?? id }
        )
    }

    private var sessionNote: String? {
        let note = session.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        return note.isEmpty ? nil : note
    }

    @ViewBuilder
    private var verdictBanner: some View {
        let result = highlightResult
        let verdict = result.verdict
        let state: STRQPalette.State = {
            switch verdict.kind {
            case .personalRecord: return .gold
            case .bestSet, .volumeUp: return .success
            case .volumeDown: return .warning
            case .firstSession: return .info
            case .consolidated: return .neutral
            }
        }()
        let icon: String = {
            switch verdict.kind {
            case .personalRecord: return "trophy.fill"
            case .bestSet: return "arrow.up.right"
            case .volumeUp: return "chart.line.uptrend.xyaxis"
            case .volumeDown: return "chart.line.downtrend.xyaxis"
            case .firstSession: return "sparkles"
            case .consolidated: return "checkmark.seal.fill"
            }
        }()

        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(STRQPalette.color(for: state))
                .frame(width: 36, height: 36)
                .background(STRQPalette.soft(for: state), in: .rect(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 3) {
                Text(verdict.eyebrow)
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.1)
                    .foregroundStyle(STRQPalette.color(for: state))
                Text(verdict.summary)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQPalette.color(for: state).opacity(0.2), lineWidth: 1)
        )
    }

    private var statsRow: some View {
        let duration = session.endTime.map { Int($0.timeIntervalSince(session.startTime) / 60) } ?? 0
        let sets = session.exerciseLogs.flatMap(\.sets).filter(\.isCompleted).count
        let reps = session.exerciseLogs.flatMap(\.sets).filter(\.isCompleted).reduce(0) { $0 + $1.reps }

        return HStack(spacing: 8) {
            detailStat(value: "\(duration)", unit: "min", label: "Time")
            detailStat(value: "\(session.exerciseLogs.filter(\.isCompleted).count)", unit: nil, label: "Exercises")
            detailStat(value: "\(sets)", unit: nil, label: "Sets")
            detailStat(value: "\(reps)", unit: nil, label: "Reps")
            detailStat(value: ForgeTheme.formatVolume(session.totalVolume), unit: "kg", label: "Volume")
        }
    }

    private func detailStat(value: String, unit: String?, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .lastTextBaseline, spacing: 1) {
                Text(value)
                    .font(.system(size: 14, weight: .heavy, design: .rounded).monospacedDigit())
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                if let unit {
                    Text(unit)
                        .font(.system(size: 8, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .tracking(0.3)
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private func noteCard(_ note: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "note.text")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(STRQBrand.steel)
                    .frame(width: 30, height: 30)
                    .background(STRQBrand.steel.opacity(0.12), in: .rect(cornerRadius: 9))
                Text("Session Note")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Spacer(minLength: 0)
            }

            Text(note)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private var exercisesList: some View {
        VStack(spacing: 12) {
            ForEach(session.exerciseLogs) { log in
                exerciseCard(log)
            }
        }
    }

    private func exerciseCard(_ log: ExerciseLog) -> some View {
        let exercise = vm.library.exercise(byId: log.exerciseId)
        let completed = log.sets.filter(\.isCompleted)
        let best = completed.max(by: { $0.weight < $1.weight })

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(exercise?.name ?? log.exerciseId)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    if let ex = exercise {
                        Text(ex.primaryMuscle.displayName)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                if let best {
                    Text("\(Int(best.weight))kg × \(best.reps)")
                        .font(.system(size: 11, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(STRQBrand.steel)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(STRQBrand.steel.opacity(0.12), in: Capsule())
                }
            }

            if !completed.isEmpty {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        setColHeader("#", width: 24, alignment: .leading)
                        setColHeader("KG")
                        setColHeader("REPS")
                        setColHeader("e1RM")
                    }
                    .padding(.bottom, 4)

                    ForEach(Array(completed.enumerated()), id: \.element.id) { _, set in
                        HStack(spacing: 0) {
                            Text("\(set.setNumber)")
                                .font(.system(size: 12, weight: .semibold, design: .rounded).monospacedDigit())
                                .foregroundStyle(.tertiary)
                                .frame(width: 24, alignment: .leading)
                            Text(String(format: "%g", set.weight))
                                .font(.system(size: 13, weight: .semibold, design: .rounded).monospacedDigit())
                                .frame(maxWidth: .infinity)
                            Text("\(set.reps)")
                                .font(.system(size: 13, weight: .semibold, design: .rounded).monospacedDigit())
                                .frame(maxWidth: .infinity)
                            HStack(spacing: 4) {
                                Text(String(format: "%.1f", set.weight * (1.0 + Double(set.reps) / 30.0)))
                                    .font(.system(size: 12, weight: .medium, design: .rounded).monospacedDigit())
                                    .foregroundStyle(.secondary)
                                if set.isPR {
                                    Image(systemName: "trophy.fill")
                                        .font(.system(size: 8))
                                        .foregroundStyle(STRQPalette.gold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, 5)
                    }
                }
                .padding(.top, 2)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private func setColHeader(_ text: String, width: CGFloat? = nil, alignment: Alignment = .center) -> some View {
        let label = Text(text)
            .font(.system(size: 9, weight: .black))
            .tracking(0.6)
            .foregroundStyle(.tertiary)
            .textCase(.uppercase)
        return Group {
            if let width {
                label.frame(width: width, alignment: alignment)
            } else {
                label.frame(maxWidth: .infinity, alignment: alignment)
            }
        }
    }
}
