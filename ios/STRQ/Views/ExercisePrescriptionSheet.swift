import SwiftUI

struct ExercisePrescriptionSheet: View {
    let exercise: Exercise?
    let planned: PlannedExercise
    let prescription: ExercisePrescription
    let vm: AppViewModel

    @Environment(\.dismiss) private var dismiss
    @State private var appeared: Bool = false

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
        .navigationTitle("Exercise Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }

    private var today: TodayPrescription {
        vm.todayPrescription(for: planned)
    }

    private var todayCard: some View {
        let t = today
        let color = decisionColor(t.decision.colorName)
        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: t.decision.icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text("TODAY")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color)
                    .tracking(0.6)
                Spacer()
                Text(t.decision.label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(color.opacity(0.14), in: Capsule())
            }

            HStack(alignment: .firstTextBaseline, spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(t.formattedWeight)
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
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(t.suggestedSets) \u{00D7} \(t.suggestedRepRange)")
                        .font(.system(.title3, design: .rounded, weight: .bold).monospacedDigit())
                    if t.setsReduced {
                        Text("Reduced from \(t.plannedSets) sets")
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
                        .foregroundStyle(.yellow)
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
        case "green": .green
        case "red": .red
        case "yellow": .yellow
        case "blue": .blue
        default: STRQBrand.steel
        }
    }

    private var headerSection: some View {
        VStack(spacing: 14) {
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
                statItem(value: "\(planned.sets)", label: "Sets")
                Divider().frame(height: 28).opacity(0.3)
                statItem(value: planned.reps, label: "Reps")
                Divider().frame(height: 28).opacity(0.3)
                if let rpe = planned.rpe {
                    statItem(value: "RPE \(Int(rpe))", label: "Effort")
                    Divider().frame(height: 28).opacity(0.3)
                }
                statItem(value: "\(planned.restSeconds)s", label: "Rest")
                if let weight = prescription.suggestedWeight {
                    Divider().frame(height: 28).opacity(0.3)
                    statItem(value: weight, label: "Load", valueColor: .green)
                }
            }
            .padding(.vertical, 14)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
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
                color: .blue
            )

            prescriptionCard(
                icon: "rectangle.stack.fill",
                label: "SETS & REPS",
                text: prescription.whySetsReps,
                color: .purple
            )

            prescriptionCard(
                icon: "scalemass.fill",
                label: "SUGGESTED WEIGHT",
                text: prescription.whyWeight,
                color: .green
            )

            prescriptionCard(
                icon: "gauge.with.needle.fill",
                label: "TARGET EFFORT",
                text: prescription.whyEffort,
                color: STRQBrand.steel
            )

            if let progression = prescription.progressionNote {
                prescriptionCard(
                    icon: "arrow.up.right.circle.fill",
                    label: "PROGRESSION",
                    text: progression,
                    color: guidanceColorValue
                )
            }
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
        case .supportLift: .blue
        case .accessory: STRQBrand.steel
        case .warmup: .yellow
        case .saferSubstitute: .green
        }
    }

    private var guidanceColorValue: Color {
        switch prescription.guidanceColor {
        case "green": .green
        case "blue": .blue
        case "red": .red
        case "purple": .purple
        case "teal": .teal
        default: STRQBrand.steel
        }
    }
}
