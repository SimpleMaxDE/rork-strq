import SwiftUI

struct WeightQuickLogSheet: View {
    @Bindable var vm: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var weightText: String = ""
    @State private var bodyFatText: String = ""
    @State private var saved: Bool = false

    private var currentWeight: Double? {
        vm.bodyWeightEntries.sorted { $0.date > $1.date }.first?.weightKg
    }

    private var startWeight: Double {
        vm.profile.startWeightKg ?? vm.profile.weightKg
    }

    private var weightChange: Double? {
        guard let current = currentWeight else { return nil }
        return current - startWeight
    }

    private var weeklyTrend: Double? {
        let sorted = vm.bodyWeightEntries.sorted { $0.date < $1.date }
        guard sorted.count >= 4 else { return nil }
        let recent3 = sorted.suffix(3).map(\.weightKg).reduce(0, +) / 3.0
        let earlier3 = sorted.prefix(3).map(\.weightKg).reduce(0, +) / 3.0
        let weeks = max(1.0, Double(Calendar.current.dateComponents([.day], from: sorted.first!.date, to: sorted.last!.date).day ?? 7) / 7.0)
        return (recent3 - earlier3) / weeks
    }

    var body: some View {
        VStack(spacing: 0) {
            handle
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    currentStatusSection
                    inputSection
                    trendSection
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            if let w = currentWeight {
                weightText = String(format: "%.1f", w)
            }
        }
    }

    private var handle: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(Color(.tertiaryLabel))
            .frame(width: 36, height: 5)
            .padding(.top, 10)
            .padding(.bottom, 16)
    }

    private var headerSection: some View {
        VStack(spacing: 6) {
            Image(systemName: "scalemass.fill")
                .font(.title2)
                .foregroundStyle(STRQBrand.steel)
            Text("Body Check-In")
                .font(.title3.bold())
            Text("Quick weigh-in to keep your progress on track")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var currentStatusSection: some View {
        HStack(spacing: 12) {
            statusTile(
                label: "Current",
                value: currentWeight.map { String(format: "%.1f", $0) } ?? "—",
                unit: "kg",
                color: .primary
            )
            statusTile(
                label: "Start",
                value: String(format: "%.1f", startWeight),
                unit: "kg",
                color: .secondary
            )
            if let change = weightChange {
                statusTile(
                    label: "Change",
                    value: String(format: "%+.1f", change),
                    unit: "kg",
                    color: changeColor(change)
                )
            }
        }
    }

    private func statusTile(label: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
                .tracking(0.3)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(.headline, design: .rounded, weight: .bold).monospacedDigit())
                    .foregroundStyle(color)
                Text(unit)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weight")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(STRQBrand.steel)
                    HStack(spacing: 4) {
                        TextField("0.0", text: $weightText)
                            .keyboardType(.decimalPad)
                            .font(.body.weight(.semibold).monospacedDigit())
                        Text("kg")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Body Fat (optional)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        TextField("—", text: $bodyFatText)
                            .keyboardType(.decimalPad)
                            .font(.body.weight(.semibold).monospacedDigit())
                        Text("%")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
                }
            }

            Button {
                saveWeight()
            } label: {
                HStack(spacing: 8) {
                    if saved {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline)
                        Text("Saved")
                            .font(.body.weight(.semibold))
                    } else {
                        Image(systemName: "scalemass.fill")
                            .font(.subheadline)
                        Text("Log Weight")
                            .font(.body.weight(.semibold))
                    }
                }
                .foregroundStyle(saved ? .white : .black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    saved
                        ? AnyShapeStyle(Color.green.gradient)
                        : AnyShapeStyle(STRQBrand.accentGradient),
                    in: .rect(cornerRadius: 14)
                )
            }
            .disabled(Double(weightText) == nil || Double(weightText)! <= 0)
            .sensoryFeedback(.success, trigger: saved)
        }
    }

    @ViewBuilder
    private var trendSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForgeSectionHeader(title: "Insights")

            if let trend = weeklyTrend {
                coachRow(
                    icon: trend > 0.05 ? "arrow.up.right" : trend < -0.05 ? "arrow.down.right" : "equal",
                    color: trendColor(trend),
                    text: trendMessage(trend)
                )
            }

            if let pace = vm.goalPace {
                coachRow(
                    icon: pace.icon,
                    color: ForgeTheme.color(for: pace.colorName),
                    text: pace.headline
                )
            }

            if let target = vm.profile.targetWeightKg, let current = currentWeight {
                let remaining = target - current
                coachRow(
                    icon: "target",
                    color: STRQBrand.steel,
                    text: remaining > 0
                        ? String(format: "%.1f kg to go until your target", remaining)
                        : remaining < 0
                            ? String(format: "%.1f kg below your target", abs(remaining))
                            : "You've reached your target weight"
                )
            }
        }
    }

    private func coachRow(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 24, height: 24)
                .background(color.opacity(0.1), in: .rect(cornerRadius: 7))
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
    }

    private func changeColor(_ change: Double) -> Color {
        switch vm.nutritionTarget.weightGoalDirection {
        case .gaining: return change > 0 ? .green : STRQBrand.steel
        case .losing: return change < 0 ? .green : STRQBrand.steel
        case .maintaining: return abs(change) < 1 ? .green : .yellow
        }
    }

    private func trendColor(_ trend: Double) -> Color {
        switch vm.nutritionTarget.weightGoalDirection {
        case .gaining: return trend > 0 ? .green : .yellow
        case .losing: return trend < 0 ? .green : .yellow
        case .maintaining: return abs(trend) < 0.1 ? .green : .yellow
        }
    }

    private func trendMessage(_ trend: Double) -> String {
        if abs(trend) < 0.05 {
            return "Weight is stable week over week"
        } else if trend > 0 {
            return String(format: "Gaining ~%.1f kg/week", trend)
        } else {
            return String(format: "Losing ~%.1f kg/week", abs(trend))
        }
    }

    private func saveWeight() {
        guard let w = Double(weightText), w > 0 else { return }
        let bf = Double(bodyFatText)
        vm.logBodyWeight(weight: w, bodyFat: bf)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            saved = true
        }
        Task {
            try? await Task.sleep(for: .seconds(1.2))
            dismiss()
        }
    }
}
