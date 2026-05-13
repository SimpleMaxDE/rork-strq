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

    private var backgroundSurface: some View {
        LinearGradient(
            colors: [
                STRQPalette.backgroundPrimary,
                STRQPalette.backgroundCarbon,
                STRQPalette.backgroundPrimary
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    var body: some View {
        ZStack {
            backgroundSurface

            ScrollView {
                VStack(spacing: 16) {
                    sessionHero
                    readinessRow
                    prepCueCard
                    exercisePreviewList
                    whyThisSessionCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
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
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Button { onCancel() } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(STRQPalette.textSecondary)
                        .frame(width: 38, height: 38)
                        .background(Color.white.opacity(0.065), in: Circle())
                        .overlay(Circle().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
                }
                .accessibilityIdentifier("strq.handoff.cancel")
                Spacer()
                if briefing.hasCoachAdjustment {
                    HStack(spacing: 5) {
                        Image(systemName: "brain.head.profile.fill")
                            .font(.system(size: 10))
                        Text(L10n.tr("Coach-Adjusted"))
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(STRQBrand.steel)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(STRQBrand.steel.opacity(0.12), in: Capsule())
                    .overlay(Capsule().strokeBorder(STRQBrand.steel.opacity(0.18), lineWidth: 1))
                }
            }

            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(L10n.tr("TODAY'S WORKOUT"))
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(STRQBrand.steel)
                        .tracking(1.4)

                    Text(briefing.dayName)
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundStyle(STRQPalette.textPrimary)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)

                    Text(briefing.dayExplanation)
                        .font(.subheadline)
                        .foregroundStyle(STRQPalette.textSecondary)
                        .lineSpacing(2)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)

                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.11), STRQBrand.steel.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 74, height: 74)
                        .overlay(Circle().strokeBorder(Color.white.opacity(0.11), lineWidth: 1))

                    VStack(spacing: -2) {
                        ForEach(briefing.focusMuscles.prefix(2)) { muscle in
                            Image(systemName: muscle.symbolName)
                                .font(.system(size: 23, weight: .thin))
                                .foregroundStyle(STRQPalette.textPrimary.opacity(0.86))
                        }
                    }
                }
                .scaleEffect(appeared ? 1 : 0.82)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.55, dampingFraction: 0.76).delay(0.1), value: appeared)
            }

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(briefing.focusMuscles.prefix(5)) { muscle in
                        focusMuscleChip(muscle)
                    }
                }
            }
            .contentMargins(.horizontal, 0)
            .scrollIndicators(.hidden)

            sessionStats
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [STRQPalette.surfaceRaised.opacity(0.96), STRQPalette.backgroundCarbon.opacity(0.96)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(STRQBrand.steel.opacity(0.12))
                .frame(width: 190, height: 190)
                .blur(radius: 52)
                .offset(x: 72, y: -90)
                .allowsHitTesting(false)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color.white.opacity(0.09), lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.easeOut(duration: 0.5).delay(0.12), value: appeared)
    }

    private func focusMuscleChip(_ muscle: MuscleGroup) -> some View {
        HStack(spacing: 6) {
            Image(systemName: muscle.symbolName)
                .font(.system(size: 11, weight: .medium))
            Text(muscle.displayName)
                .font(.caption2.weight(.semibold))
                .lineLimit(1)
        }
        .foregroundStyle(STRQPalette.textPrimary.opacity(0.88))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.065), in: Capsule())
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
    }

    // MARK: - Readiness

    private var readinessRow: some View {
        HStack(spacing: 6) {
            readinessPill(
                icon: recoveryIcon,
                color: recoveryColor,
                value: "\(briefing.recoveryScore)%",
                label: "Recovery"
            )
            readinessPill(
                icon: briefing.phase.icon,
                color: phaseColor,
                value: briefing.phase.displayName.replacingOccurrences(of: " Phase", with: ""),
                label: "Phase"
            )
            readinessPill(
                icon: intensityIcon,
                color: intensityColor,
                value: briefing.intensityLabel,
                label: "Intensity"
            )
        }
        .padding(4)
        .background(STRQPalette.surfaceBase.opacity(0.84), in: .rect(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(Color.white.opacity(0.07), lineWidth: 1))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.25), value: appeared)
    }

    private func readinessPill(icon: String, color: Color, value: String, label: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.13), in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(STRQPalette.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
                Text(label)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(STRQPalette.textMuted)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .padding(.horizontal, 7)
    }

    // MARK: - Session Stats

    private var sessionStats: some View {
        HStack(spacing: 0) {
            statItem(icon: "list.bullet.rectangle.portrait", value: "\(briefing.exerciseCount)", label: "Exercises")
            statDivider
            statItem(icon: "square.stack.3d.up", value: "\(briefing.totalSets)", label: "Sets")
            statDivider
            statItem(icon: "clock", value: "~\(briefing.estimatedMinutes)m", label: "Time")
            statDivider
            statItem(icon: intensityIcon, value: "RPE \(String(format: "%.0f", briefing.avgRPE))", label: "Effort")
        }
        .padding(.top, 14)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.white.opacity(0.07))
                .frame(height: 1)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.07))
            .frame(width: 1, height: 34)
            .padding(.horizontal, 7)
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(STRQBrand.steel)
            Text(value)
                .font(.subheadline.bold().monospacedDigit())
                .foregroundStyle(STRQPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(STRQPalette.textMuted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Prep

    @ViewBuilder
    private var prepCueCard: some View {
        let hint = briefing.warmupHint.trimmingCharacters(in: .whitespacesAndNewlines)

        if !hint.isEmpty {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(STRQBrand.steel)
                    .frame(width: 34, height: 34)
                    .background(STRQBrand.steel.opacity(0.12), in: .rect(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(STRQBrand.steel.opacity(0.18), lineWidth: 1))

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.tr("PREP"))
                        .font(.system(size: 10, weight: .black))
                        .tracking(1.0)
                        .foregroundStyle(STRQBrand.steel)
                    Text(hint)
                        .font(.footnote)
                        .foregroundStyle(STRQPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(14)
            .background(STRQPalette.surfaceBase.opacity(0.78), in: .rect(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(Color.white.opacity(0.07), lineWidth: 1))
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.32), value: appeared)
        }
    }

    // MARK: - Exercise Preview

    private var exercisePreviewList: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(L10n.tr("WORKOUT PLAN"))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(STRQBrand.steel)
                    .tracking(0.5)
                Spacer()
                Text(L10n.tr("Tap for prescription"))
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 4)

            ForEach(Array(day.exercises.enumerated()), id: \.element.id) { index, planned in
                let exercise = vm.library.exercise(byId: planned.exerciseId)
                let suggestion = vm.loadSuggestion(for: planned.exerciseId, planned: planned)

                Button {
                    selectedExerciseIndex = index
                } label: {
                    HStack(spacing: 12) {
                        if let ex = exercise {
                            ExerciseThumbnail(exercise: ex, size: .small, cornerRadius: 10)
                                .frame(width: 40, height: 40)
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(exercise?.name ?? planned.exerciseId)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                                    .lineLimit(1)
                                if let ex = exercise, ex.category == .compound && index < 2 {
                                    Text(L10n.tr("KEY"))
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
                    .background(STRQPalette.surfaceBase.opacity(0.72), in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.white.opacity(0.055), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("strq.handoff.exercise.\(index)")
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
                Text(L10n.tr("WHY THIS WORKOUT"))
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
        .background(STRQPalette.surfaceBase.opacity(0.68), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.055), lineWidth: 1)
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
                colors: [STRQPalette.backgroundPrimary.opacity(0), STRQPalette.backgroundPrimary],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 40)

            Button { onStart() } label: {
                HStack(spacing: 10) {
                    Image(systemName: "bolt.fill")
                        .font(.subheadline)
                    Text(L10n.tr("Begin Workout"))
                        .font(.body.weight(.bold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [STRQPalette.textPrimary, STRQBrand.steel.opacity(0.86)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: .rect(cornerRadius: 16)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                )
                .shadow(color: Color.white.opacity(0.10), radius: 16, y: 5)
            }
            .accessibilityIdentifier("strq.handoff.start")
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .background(STRQPalette.backgroundPrimary)
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
