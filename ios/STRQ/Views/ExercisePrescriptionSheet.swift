import SwiftUI

struct ExercisePrescriptionSheet: View {
    let exercise: Exercise?
    let planned: PlannedExercise
    let prescription: ExercisePrescription
    let vm: AppViewModel
    let todayOverride: TodayPrescription?

    @Environment(\.dismiss) private var dismiss
    @State private var appeared: Bool = false

    init(
        exercise: Exercise?,
        planned: PlannedExercise,
        prescription: ExercisePrescription,
        vm: AppViewModel,
        todayOverride: TodayPrescription? = nil
    ) {
        self.exercise = exercise
        self.planned = planned
        self.prescription = prescription
        self.vm = vm
        self.todayOverride = todayOverride
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                todayCard
                prescriptionCards
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle(L10n.tr("Exercise Details"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(L10n.tr("Done")) { dismiss() }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }

    private var today: TodayPrescription {
        todayOverride ?? vm.todayPrescription(for: planned)
    }

    private var planLoad: StartingLoadEngine.LoadSuggestion? {
        vm.loadSuggestion(for: planned.exerciseId, planned: planned)
    }

    private var todayCard: some View {
        let t = today
        let loadText = todayLoadDisplayText
        let color = decisionColor(t.decision.colorName)
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: t.decision.icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(L10n.tr("TODAY"))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color)
                    .tracking(0.6)
                Spacer()
                Text(t.setsReduced ? L10n.tr("Today reduced") : t.decision.label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(color.opacity(0.14), in: Capsule())
            }

            HStack(alignment: .firstTextBaseline, spacing: 14) {
                if let loadText {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(loadText)
                            .font(.system(.title, design: .rounded, weight: .bold).monospacedDigit())
                        if let delta = t.formattedDelta {
                            Text(delta)
                                .font(.caption.weight(.bold).monospacedDigit())
                                .foregroundStyle(color)
                        } else if let last = t.lastRepsSummary {
                            Text(last)
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.tertiary)
                        }
                    }
                    Spacer(minLength: 0)
                }
                VStack(alignment: loadText == nil ? .leading : .trailing, spacing: 2) {
                    Text("\(t.suggestedSets) \u{00D7} \(t.suggestedRepRange)")
                        .font(.system(.title3, design: .rounded, weight: .bold).monospacedDigit())
                    if t.setsReduced {
                        Text("\(L10n.tr("Plan")): \(t.plannedSets) \(L10n.tr("Sets"))")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(color)
                    } else if let rpe = t.targetRPE {
                        Text("RPE \(Int(rpe))")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Text(t.reasoning)
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)

            if let note = t.readinessNote {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(STRQPalette.warning)
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "scalemass")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                Text(t.rule)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.06), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(color.opacity(0.2), lineWidth: 1)
        )
    }

    private func decisionColor(_ name: String) -> Color {
        switch name {
        case "green": STRQPalette.success
        case "red": STRQPalette.danger
        case "yellow": STRQPalette.warning
        case "blue": STRQPalette.info
        default: STRQBrand.steel
        }
    }

    private var headerSection: some View {
        let t = today
        let loadText = todayLoadDisplayText
        return VStack(spacing: 14) {
            if let ex = exercise {
                let mediaProvider = ExerciseMediaProvider.shared
                let gradientColors = mediaProvider.heroGradient(for: ex)
                let heroSymbol = mediaProvider.heroSymbol(for: ex)

                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(LinearGradient(colors: [gradientColors[0], gradientColors[1]], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 64, height: 64)
                        Image(systemName: heroSymbol)
                            .font(.system(size: 28, weight: .thin))
                            .foregroundStyle(.white.opacity(0.9))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(ex.name)
                            .font(.title3.bold())
                        HStack(spacing: 8) {
                            roleBadge
                            Text(ex.primaryMuscle.displayName)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    Spacer()
                }
            }

            HStack(spacing: 0) {
                statItem(value: "\(t.suggestedSets)", label: L10n.tr("Sets"))
                Divider().frame(height: 28).opacity(0.3)
                statItem(value: t.suggestedRepRange, label: L10n.tr("Reps"))
                Divider().frame(height: 28).opacity(0.3)
                if let rpe = t.targetRPE ?? planned.rpe {
                    statItem(value: "RPE \(formatRPE(rpe))", label: L10n.tr("Effort"))
                    Divider().frame(height: 28).opacity(0.3)
                }
                statItem(value: "\(planned.restSeconds)s", label: L10n.tr("Set rest"))
                if let loadText {
                    Divider().frame(height: 28).opacity(0.3)
                    statItem(
                        value: loadText,
                        label: L10n.tr("Load"),
                        valueColor: t.suggestedWeight > 0 ? STRQPalette.success : .primary
                    )
                }
            }
            .padding(.vertical, 14)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))

            if let planReference = planReferenceText(for: planned, today: t, planLoad: planLoad) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 10, weight: .semibold))
                    Text(planReference)
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private func statItem(value: String, label: String, valueColor: Color = .primary) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .bold).monospacedDigit())
                .foregroundStyle(valueColor)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
    }

    private var roleBadge: some View {
        Text(prescription.role.displayName)
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(roleColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(roleColor.opacity(0.12), in: Capsule())
    }

    private var prescriptionCards: some View {
        VStack(spacing: 12) {
            prescriptionCard(
                icon: "questionmark.circle.fill",
                label: "WHY THIS EXERCISE",
                text: prescription.whyThisExercise,
                color: STRQPalette.info
            )

            prescriptionCard(
                icon: "rectangle.stack.fill",
                label: L10n.tr("TODAY'S SETS"),
                text: todaySetsText,
                color: STRQBrand.slate
            )

            if let todayLoadText {
                prescriptionCard(
                    icon: "scalemass.fill",
                    label: L10n.tr("TODAY'S LOAD"),
                    text: todayLoadText,
                    color: STRQPalette.success
                )
            }

            prescriptionCard(
                icon: "gauge.with.needle.fill",
                label: L10n.tr("TODAY'S EFFORT"),
                text: todayEffortText,
                color: STRQBrand.steel
            )

        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    private func prescriptionCard(icon: String, label: String, text: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(color)
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color)
                    .tracking(0.5)
            }
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.04), in: .rect(cornerRadius: 14))
    }

    private var roleColor: Color {
        switch prescription.role {
        case .keyLift: .white
        case .supportLift: STRQPalette.info
        case .accessory: STRQBrand.steel
        case .warmup: STRQPalette.warning
        case .saferSubstitute: STRQPalette.success
        }
    }

    private var guidanceColorValue: Color {
        switch prescription.guidanceColor {
        case "green": STRQPalette.success
        case "blue": STRQPalette.info
        case "red": STRQPalette.danger
        case "purple": STRQBrand.slate
        case "teal": STRQPalette.info
        default: STRQBrand.steel
        }
    }

    private var todaySetsText: String {
        let primary = "\(today.suggestedSets) × \(today.suggestedRepRange)"
        if let planReference = planReferenceText(for: planned, today: today, planLoad: planLoad) {
            return "\(L10n.format("From today's target: %@", primary)) \(planReference)."
        }
        return L10n.format("From today's target: %@", primary)
    }

    private var todayLoadText: String? {
        guard let primary = todayLoadDisplayText else { return nil }
        if let delta = today.formattedDelta {
            return "\(L10n.format("From today's target: %@", primary)) \(delta)."
        }
        return L10n.format("From today's target: %@", primary)
    }

    private var todayLoadDisplayText: String? {
        loadText(for: today, exercise: exercise)
    }

    private var todayEffortText: String {
        if let rpe = today.targetRPE ?? planned.rpe {
            return L10n.format("From today's target: %@", "RPE \(formatRPE(rpe))")
        }
        return L10n.tr("From today's target")
    }

    private func planReferenceText(
        for planned: PlannedExercise,
        today: TodayPrescription,
        planLoad: StartingLoadEngine.LoadSuggestion?
    ) -> String? {
        var parts: [String] = []
        let repsChanged = normalizedReps(today.suggestedRepRange) != normalizedReps(planned.reps)

        if today.suggestedSets != planned.sets || repsChanged {
            if today.suggestedSets != planned.sets, !repsChanged {
                parts.append("\(planned.sets) \(L10n.tr("Sets"))")
            } else {
                parts.append("\(planned.sets) × \(planned.reps)")
            }
        }

        if let planLoad,
           planLoad.suggestedWeight > 0,
           abs(planLoad.suggestedWeight - today.suggestedWeight) >= 0.05 {
            parts.append(planLoad.formattedWeight)
        }

        guard !parts.isEmpty else { return nil }
        return "\(L10n.tr("Plan")): \(parts.joined(separator: " · "))"
    }

    private func loadText(for today: TodayPrescription, exercise: Exercise?) -> String? {
        if today.suggestedWeight > 0 { return today.formattedWeight }
        guard isBodyweightLoad(exercise) else { return nil }
        return L10n.tr("BW")
    }

    private func isBodyweightLoad(_ exercise: Exercise?) -> Bool {
        guard let exercise else { return false }
        return exercise.isBodyweight || exercise.category == .bodyweight
    }

    private func normalizedReps(_ reps: String) -> String {
        reps
            .replacingOccurrences(of: "–", with: "-")
            .replacingOccurrences(of: " ", with: "")
            .lowercased()
    }

    private func formatRPE(_ rpe: Double) -> String {
        if rpe.truncatingRemainder(dividingBy: 1) == 0 { return "\(Int(rpe))" }
        return String(format: "%.1f", rpe)
    }
}
