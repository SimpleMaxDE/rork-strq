import SwiftUI

struct PreWorkoutHandoffView: View {
    let vm: AppViewModel
    let day: WorkoutDay
    let onStart: () -> Void
    let onCancel: () -> Void

    @State private var appeared: Bool = false
    @State private var selectedExerciseIndex: Int?

    private var briefing: SessionBriefing {
        vm.sessionBriefing(for: day)
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    sessionHero
                    readinessRow
                    sessionStats
                    exercisePreviewList
                    whyThisSessionCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }

            VStack {
                Spacer()
                startButton
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) { appeared = true }
        }
        .sheet(item: $selectedExerciseIndex) { index in
            if index < day.exercises.count {
                let planned = day.exercises[index]
                let prescription = vm.exercisePrescription(for: planned, in: day, index: index)
                NavigationStack {
                    ExercisePrescriptionSheet(
                        exercise: vm.library.exercise(byId: planned.exerciseId),
                        planned: planned,
                        prescription: prescription,
                        vm: vm
                    )
                }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
            }
        }
    }

    // MARK: - Session Hero

    private var sessionHero: some View {
        VStack(spacing: 20) {
            HStack {
                Button { onCancel() } label: {
                    Image(systemName: "xmark")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.06), in: Circle())
                }
                Spacer()
                if briefing.hasCoachAdjustment {
                    HStack(spacing: 5) {
                        Image(systemName: "brain.head.profile.fill")
                            .font(.system(size: 10))
                        Text("Coach-Adjusted")
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(STRQBrand.steel)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(STRQBrand.steel.opacity(0.12), in: Capsule())
                }
            }

            VStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.04))
                        .frame(width: 90, height: 90)

                    HStack(spacing: 4) {
                        ForEach(briefing.focusMuscles.prefix(2)) { muscle in
                            Image(systemName: muscle.symbolName)
                                .font(.system(size: 28, weight: .thin))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }
                .scaleEffect(appeared ? 1 : 0.7)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: appeared)

                VStack(spacing: 6) {
                    Text("TODAY'S SESSION")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(STRQBrand.steel)
                        .tracking(1.5)

                    Text(briefing.dayName)
                        .font(.system(.title, design: .rounded, weight: .bold))

                    Text(briefing.dayExplanation)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)

                ScrollView(.horizontal) {
                    HStack(spacing: 6) {
                        ForEach(briefing.focusMuscles.prefix(5)) { muscle in
                            Text(muscle.displayName)
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(STRQBrand.steel)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(STRQBrand.steel.opacity(0.12), in: Capsule())
                        }
                    }
                }
                .contentMargins(.horizontal, 0)
                .scrollIndicators(.hidden)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Readiness

    private var readinessRow: some View {
        HStack(spacing: 8) {
            readinessItem(
                icon: recoveryIcon,
                color: recoveryColor,
                title: "Recovery",
                value: "\(briefing.recoveryScore)%"
            )
            readinessItem(
                icon: briefing.phase.icon,
                color: phaseColor,
                title: "Phase",
                value: briefing.phase.displayName.replacingOccurrences(of: " Phase", with: "")
            )
            readinessItem(
                icon: intensityIcon,
                color: intensityColor,
                title: "Intensity",
                value: briefing.intensityLabel
            )
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.25), value: appeared)
    }

    private func readinessItem(icon: String, color: Color, title: String, value: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.12), in: Circle())
            Text(value)
                .font(.caption.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 14))
    }

    // MARK: - Session Stats

    private var sessionStats: some View {
        HStack(spacing: 0) {
            statItem(value: "\(briefing.exerciseCount)", label: "Exercises")
            Rectangle().fill(Color.white.opacity(0.06)).frame(width: 1, height: 28)
            statItem(value: "\(briefing.totalSets)", label: "Sets")
            Rectangle().fill(Color.white.opacity(0.06)).frame(width: 1, height: 28)
            statItem(value: "~\(briefing.estimatedMinutes)m", label: "Duration")
            Rectangle().fill(Color.white.opacity(0.06)).frame(width: 1, height: 28)
            statItem(value: "RPE \(String(format: "%.0f", briefing.avgRPE))", label: "Effort")
        }
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.subheadline.bold().monospacedDigit())
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Exercise Preview

    private var exercisePreviewList: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("SESSION PLAN")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(STRQBrand.steel)
                    .tracking(0.5)
                Spacer()
                Text("Tap for prescription")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 4)

            ForEach(Array(day.exercises.enumerated()), id: \.element.id) { index, planned in
                let exercise = vm.library.exercise(byId: planned.exerciseId)
                let suggestion = vm.loadSuggestion(for: planned.exerciseId, planned: planned)
                let mediaProvider = ExerciseMediaProvider.shared

                Button {
                    selectedExerciseIndex = index
                } label: {
                    HStack(spacing: 12) {
                        if let ex = exercise {
                            let colors = mediaProvider.heroGradient(for: ex)
                            let symbol = mediaProvider.heroSymbol(for: ex)
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(LinearGradient(colors: [colors[0], colors[1]], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 40, height: 40)
                                Image(systemName: symbol)
                                    .font(.system(size: 18, weight: .thin))
                                    .foregroundStyle(.white.opacity(0.85))
                            }
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(exercise?.name ?? planned.exerciseId)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                if let ex = exercise, ex.category == .compound && index < 2 {
                                    Text("KEY")
                                        .font(.system(size: 8, weight: .black))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 2)
                                        .background(STRQBrand.steelGradient, in: Capsule())
                                }
                            }
                            HStack(spacing: 8) {
                                Text("\(planned.sets) × \(planned.reps)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                if let rpe = planned.rpe {
                                    Text("RPE \(Int(rpe))")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(STRQBrand.steel)
                                }
                                if let s = suggestion, s.suggestedWeight > 0 {
                                    Text(s.formattedWeight)
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(STRQPalette.success)
                                }
                            }
                        }
                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.quaternary)
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .background(Color.white.opacity(0.03), in: .rect(cornerRadius: 14))
                }
                .buttonStyle(.plain)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.35), value: appeared)
    }

    // MARK: - Why This Session

    @ViewBuilder
    private var whyThisSessionCard: some View {
        let phase = briefing.phase
        let recovery = briefing.recoveryScore

        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "brain.head.profile.fill")
                    .font(.caption)
                    .foregroundStyle(STRQBrand.steel)
                Text("WHY THIS SESSION")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(STRQBrand.steel)
                    .tracking(0.5)
            }

            VStack(alignment: .leading, spacing: 8) {
                reasonRow(icon: phase.icon, color: ForgeTheme.color(for: phase.colorName),
                         text: "\(phase.displayName): \(phase.description)")

                if recovery >= 80 {
                    reasonRow(icon: "heart.circle.fill", color: STRQPalette.success,
                             text: "Recovery is strong — good day to push intensity.")
                } else if recovery < 60 {
                    reasonRow(icon: "exclamationmark.heart", color: STRQPalette.danger,
                             text: "Recovery is low — session adjusted for safer training.")
                }

                if !vm.profile.focusMuscles.isEmpty {
                    let overlap = day.focusMuscles.filter { vm.profile.focusMuscles.contains($0) }
                    if !overlap.isEmpty {
                        reasonRow(icon: "scope", color: STRQBrand.steel,
                                 text: "\(overlap.map(\.displayName).joined(separator: ", ")) prioritized based on your focus areas.")
                    }
                }

                if briefing.hasCoachAdjustment, let note = briefing.coachNote {
                    reasonRow(icon: "brain.head.profile.fill", color: STRQBrand.steel, text: note)
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.03), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.4), value: appeared)
    }

    private func reasonRow(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(color)
                .frame(width: 18)
                .padding(.top, 1)
            Text(text)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Start Button

    private var startButton: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [Color.black.opacity(0), Color.black],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)

            Button { onStart() } label: {
                HStack(spacing: 10) {
                    Image(systemName: "bolt.fill")
                        .font(.subheadline)
                    Text("Begin Workout")
                        .font(.body.weight(.bold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 16))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .background(Color.black)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(.easeOut(duration: 0.5).delay(0.45), value: appeared)
    }

    // MARK: - Helpers

    private var recoveryIcon: String {
        switch briefing.recoveryScore {
        case 80...: return "heart.circle.fill"
        case 60..<80: return "heart.circle"
        default: return "exclamationmark.heart"
        }
    }

    private var recoveryColor: Color {
        switch briefing.recoveryScore {
        case 80...: return STRQPalette.success
        case 60..<80: return STRQPalette.warning
        default: return STRQPalette.danger
        }
    }

    private var phaseColor: Color {
        ForgeTheme.color(for: briefing.phase.colorName)
    }

    private var intensityIcon: String {
        switch briefing.intensityLabel {
        case "Light": return "gauge.with.dots.needle.0percent"
        case "Moderate": return "gauge.with.dots.needle.33percent"
        case "Hard": return "gauge.with.dots.needle.67percent"
        default: return "gauge.with.dots.needle.100percent"
        }
    }

    private var intensityColor: Color {
        switch briefing.intensityLabel {
        case "Light": return STRQPalette.success
        case "Moderate": return STRQPalette.info
        case "Hard": return STRQBrand.steel
        default: return STRQPalette.warning
        }
    }
}

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}
