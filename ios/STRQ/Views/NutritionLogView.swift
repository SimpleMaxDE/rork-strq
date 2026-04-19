import SwiftUI

struct NutritionLogView: View {
    @Bindable var vm: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""
    @State private var water: String = ""
    @State private var appeared: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                PhysiqueVerdictCard(vm: vm)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                targetOverview
                todayProgress
                quickLogSection
                recentLogsSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Nutrition")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            prefillToday()
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }

    private var targetOverview: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 4) {
                Image(systemName: vm.nutritionTarget.nutritionGoal.icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(colorFor(vm.nutritionTarget.nutritionGoal.colorName))
                Text(vm.nutritionTarget.nutritionGoal.displayName.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(colorFor(vm.nutritionTarget.nutritionGoal.colorName))
                    .tracking(0.5)
                Spacer()
                Text(vm.nutritionTarget.nutritionGoal.surplusRange)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                targetPill(value: "\(vm.nutritionTarget.calories)", unit: "kcal", label: "Calories", color: STRQBrand.steel)
                targetPill(value: "\(vm.nutritionTarget.proteinGrams)", unit: "g", label: "Protein", color: .blue)
                if let c = vm.nutritionTarget.carbsGrams {
                    targetPill(value: "\(c)", unit: "g", label: "Carbs", color: .green)
                }
                if let f = vm.nutritionTarget.fatGrams {
                    targetPill(value: "\(f)", unit: "g", label: "Fat", color: .purple)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private func targetPill(value: String, unit: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 2) {
                Text(value)
                    .font(.subheadline.bold().monospacedDigit())
                Text(unit)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.secondary)
            }
            Text(label)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var todayProgress: some View {
        let log = vm.todaysNutritionLog
        let target = vm.nutritionTarget

        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today")
                    .font(.headline)
                Spacer()
                if log != nil {
                    Text(vm.nutritionCoachSummary)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            macroRing(label: "Calories", current: log?.calories ?? 0, target: target.calories, unit: "kcal", color: STRQBrand.steel)
            macroRing(label: "Protein", current: log?.proteinGrams ?? 0, target: target.proteinGrams, unit: "g", color: .blue)
            if let carbTarget = target.carbsGrams {
                macroRing(label: "Carbs", current: log?.carbsGrams ?? 0, target: carbTarget, unit: "g", color: .green)
            }
            if let fatTarget = target.fatGrams {
                macroRing(label: "Fat", current: log?.fatGrams ?? 0, target: fatTarget, unit: "g", color: .purple)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.05), value: appeared)
    }

    private func macroRing(label: String, current: Int, target: Int, unit: String, color: Color) -> some View {
        let progress = target > 0 ? min(1.0, Double(current) / Double(target)) : 0
        let pct = Int(progress * 100)

        return HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color(.separator).opacity(0.3), lineWidth: 4)
                    .frame(width: 40, height: 40)
                Circle()
                    .trim(from: 0, to: appeared ? progress : 0)
                    .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 40, height: 40)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: appeared)
                Text("\(pct)%")
                    .font(.system(size: 9, weight: .bold, design: .rounded).monospacedDigit())
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline.weight(.medium))
                HStack(spacing: 4) {
                    Text("\(current)")
                        .font(.caption.weight(.bold).monospacedDigit())
                        .foregroundStyle(color)
                    Text("/ \(target) \(unit)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            let remaining = max(0, target - current)
            Text("\(remaining) left")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
        }
    }

    private var quickLogSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quick Log")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                logField("Calories", text: $calories, unit: "kcal", color: STRQBrand.steel)
                logField("Protein", text: $protein, unit: "g", color: .blue)
                logField("Carbs", text: $carbs, unit: "g", color: .green)
                logField("Fat", text: $fat, unit: "g", color: .purple)
            }

            Button {
                saveLog()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.subheadline)
                    Text("Log Nutrition")
                        .font(.body.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 14))
                    .foregroundStyle(.black)
            }
            .sensoryFeedback(.impact(flexibility: .soft), trigger: false)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    private func logField(_ label: String, text: Binding<String>, unit: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(color)
            HStack(spacing: 4) {
                TextField("0", text: text)
                    .keyboardType(.numberPad)
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                    .multilineTextAlignment(.leading)
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 10))
        }
    }

    @ViewBuilder
    private var recentLogsSection: some View {
        if !vm.nutritionLogs.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent")
                    .font(.headline)

                ForEach(vm.nutritionLogs.prefix(7)) { log in
                    let isToday = Calendar.current.isDateInToday(log.date)
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isToday ? "Today" : log.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
                                .font(.subheadline.weight(isToday ? .semibold : .medium))
                            HStack(spacing: 8) {
                                Text("\(log.calories) kcal")
                                    .font(.caption.weight(.semibold).monospacedDigit())
                                    .foregroundStyle(STRQBrand.steel)
                                Text("\(log.proteinGrams)g P")
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(.blue)
                                Text("\(log.carbsGrams)g C")
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(.green)
                                Text("\(log.fatGrams)g F")
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(.purple)
                            }
                        }
                        Spacer()

                        let proteinPct = vm.nutritionTarget.proteinGrams > 0 ? min(100, (log.proteinGrams * 100) / vm.nutritionTarget.proteinGrams) : 0
                        Circle()
                            .trim(from: 0, to: Double(proteinPct) / 100)
                            .stroke(proteinPct >= 80 ? Color.green : STRQBrand.steel, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 28, height: 28)
                            .rotationEffect(.degrees(-90))
                            .overlay {
                                Text("\(proteinPct)")
                                    .font(.system(size: 8, weight: .bold, design: .rounded).monospacedDigit())
                            }
                    }
                    .padding(12)
                    .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 12))
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)
        }
    }

    private func prefillToday() {
        if let log = vm.todaysNutritionLog {
            calories = "\(log.calories)"
            protein = "\(log.proteinGrams)"
            carbs = "\(log.carbsGrams)"
            fat = "\(log.fatGrams)"
        }
    }

    private func saveLog() {
        let cal = Int(calories) ?? 0
        let pro = Int(protein) ?? 0
        let car = Int(carbs) ?? 0
        let fa = Int(fat) ?? 0
        guard cal > 0 || pro > 0 else { return }

        let log = DailyNutritionLog(
            calories: cal,
            proteinGrams: pro,
            carbsGrams: car,
            fatGrams: fa,
            waterLiters: 0
        )
        vm.logNutrition(log)
    }

    private func colorFor(_ name: String) -> Color {
        switch name {
        case "orange": return STRQBrand.steel
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "red": return .red
        case "yellow": return .yellow
        case "mint": return .mint
        default: return STRQBrand.steel
        }
    }
}
