import SwiftUI

struct NutritionSettingsView: View {
    @Bindable var vm: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var appeared: Bool = false
    @State private var editingCalories: String = ""
    @State private var editingProtein: String = ""
    @State private var editingCarbs: String = ""
    @State private var editingFat: String = ""
    @State private var editingTargetWeight: String = ""
    @State private var selectedGoal: NutritionGoal = .leanBulk
    @State private var showRecompute: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                goalSelectionCard
                computedTargetsCard
                customTargetsCard
                bodyGoalCard
                trainingConnectionCard
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Nutrition Targets")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadCurrentValues()
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }

    private var goalSelectionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "target")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(STRQBrand.steel)
                Text("NUTRITION GOAL")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(STRQBrand.steel)
                    .tracking(0.5)
                Spacer()
                Text("Aligned with \(vm.profile.goal.displayName)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 6) {
                ForEach(NutritionGoal.allCases) { goal in
                    let isSelected = selectedGoal == goal
                    Button {
                        withAnimation(.snappy(duration: 0.2)) {
                            selectedGoal = goal
                            showRecompute = true
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: goal.icon)
                                .font(.subheadline)
                                .foregroundStyle(isSelected ? .white : colorFor(goal.colorName))
                                .frame(width: 32, height: 32)
                                .background(
                                    isSelected ?
                                    AnyShapeStyle(colorFor(goal.colorName).gradient) :
                                    AnyShapeStyle(colorFor(goal.colorName).opacity(0.12)),
                                    in: .rect(cornerRadius: 8)
                                )

                            VStack(alignment: .leading, spacing: 2) {
                                Text(goal.displayName)
                                    .font(.subheadline.weight(isSelected ? .semibold : .regular))
                                    .foregroundStyle(.primary)
                                Text(goal.surplusRange)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(colorFor(goal.colorName))
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            isSelected ?
                            Color(.tertiarySystemGroupedBackground) :
                            Color(.secondarySystemGroupedBackground),
                            in: .rect(cornerRadius: 12)
                        )
                    }
                }
            }

            if showRecompute {
                Button {
                    recomputeTargets()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.subheadline)
                        Text("Recompute Targets")
                            .font(.body.weight(.semibold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 12))
                    .foregroundStyle(.black)
                }
                .sensoryFeedback(.impact(flexibility: .soft), trigger: false)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private var computedTargetsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "cpu")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.blue)
                Text("COMPUTED TARGETS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.blue)
                    .tracking(0.5)
                Spacer()
                Text("Based on your profile")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            let computed = NutritionCoachEngine().computeTargets(profile: vm.profile)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                computedPill(label: "Calories", value: "\(computed.calories)", unit: "kcal", color: STRQBrand.steel)
                computedPill(label: "Protein", value: "\(computed.proteinGrams)", unit: "g", color: .blue)
                if let c = computed.carbsGrams {
                    computedPill(label: "Carbs", value: "\(c)", unit: "g", color: .green)
                }
                if let f = computed.fatGrams {
                    computedPill(label: "Fat", value: "\(f)", unit: "g", color: .purple)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                computedRow("BMR-based TDEE", detail: "Activity: \(vm.profile.activityLevel.displayName)")
                computedRow("Protein multiplier", detail: "\(vm.profile.trainingLevel.shortName) level + \(selectedGoal.displayName)")
                computedRow("Weekly pace", detail: String(format: "%+.2f kg/wk", computed.targetWeeklyChangeKg))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.05), value: appeared)
    }

    private func computedPill(label: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 2) {
                Text(value)
                    .font(.title3.bold().monospacedDigit())
                Text(unit)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.secondary)
            }
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 12))
    }

    private func computedRow(_ title: String, detail: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(detail)
                .font(.caption.weight(.medium))
        }
    }

    private var customTargetsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "slider.horizontal.3")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.green)
                Text("CUSTOM OVERRIDES")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.green)
                    .tracking(0.5)
                Spacer()
                Text("Optional fine-tuning")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                editField("Calories", text: $editingCalories, unit: "kcal", color: STRQBrand.steel)
                editField("Protein", text: $editingProtein, unit: "g", color: .blue)
                editField("Carbs", text: $editingCarbs, unit: "g", color: .green)
                editField("Fat", text: $editingFat, unit: "g", color: .purple)
            }

            Button {
                saveCustomTargets()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.subheadline)
                    Text("Save Custom Targets")
                        .font(.body.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(.green.gradient, in: .rect(cornerRadius: 12))
            }
            .sensoryFeedback(.impact(flexibility: .soft), trigger: false)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    private func editField(_ label: String, text: Binding<String>, unit: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(color)
            HStack(spacing: 4) {
                TextField("Auto", text: text)
                    .keyboardType(.numberPad)
                    .font(.subheadline.weight(.semibold).monospacedDigit())
                Text(unit)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 10))
        }
    }

    private var bodyGoalCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 6) {
                Image(systemName: "scalemass.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.purple)
                Text("BODY WEIGHT GOAL")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.purple)
                    .tracking(0.5)
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Weight")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f kg", vm.profile.weightKg))
                        .font(.title3.bold().monospacedDigit())
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Target Weight")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        TextField("—", text: $editingTargetWeight)
                            .keyboardType(.decimalPad)
                            .font(.title3.bold().monospacedDigit())
                            .frame(width: 60)
                        Text("kg")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Direction")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(vm.nutritionTarget.weightGoalDirection.displayName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(directionColor)
                }
            }

            if let target = Double(editingTargetWeight), target > 0 {
                let diff = target - vm.profile.weightKg
                let weeklyRate = vm.nutritionTarget.targetWeeklyChangeKg
                let weeks = weeklyRate != 0 ? abs(diff / weeklyRate) : 0

                HStack(spacing: 8) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.purple)
                    Text(String(format: "%.0f kg to go · ~%.0f weeks at current pace", abs(diff), weeks))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.purple.opacity(0.08), in: .rect(cornerRadius: 8))
            }

            Button {
                saveTargetWeight()
            } label: {
                Text("Save Target Weight")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.purple)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.purple.opacity(0.12), in: .rect(cornerRadius: 10))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)
    }

    private var trainingConnectionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "link")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.cyan)
                Text("TRAINING CONNECTION")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.cyan)
                    .tracking(0.5)
            }

            VStack(alignment: .leading, spacing: 8) {
                connectionRow(icon: "figure.strengthtraining.traditional", color: STRQBrand.steel, title: "Training Goal", detail: vm.profile.goal.displayName)
                connectionRow(icon: "dumbbell.fill", color: .blue, title: "Training Level", detail: vm.profile.trainingLevel.shortName)
                connectionRow(icon: "calendar", color: .green, title: "Sessions/Week", detail: "\(vm.profile.daysPerWeek)")
                connectionRow(icon: "moon.zzz.fill", color: .purple, title: "Avg Sleep", detail: String(format: "%.1fh", vm.averageSleepHours))
                connectionRow(icon: "heart.fill", color: .red, title: "Recovery Score", detail: "\(vm.effectiveRecoveryScore)%")
            }

            Text("Your nutrition targets are computed from these training parameters. Changes to your training profile will update nutrition recommendations.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
    }

    private func connectionRow(icon: String, color: Color, title: String, detail: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(color)
                .frame(width: 24, height: 24)
                .background(color.opacity(0.12), in: .rect(cornerRadius: 6))
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(detail)
                .font(.caption.weight(.semibold))
        }
    }

    private var directionColor: Color {
        switch vm.nutritionTarget.weightGoalDirection {
        case .gaining: return .green
        case .maintaining: return .blue
        case .losing: return STRQBrand.steel
        }
    }

    private func loadCurrentValues() {
        editingCalories = "\(vm.nutritionTarget.calories)"
        editingProtein = "\(vm.nutritionTarget.proteinGrams)"
        editingCarbs = vm.nutritionTarget.carbsGrams.map { "\($0)" } ?? ""
        editingFat = vm.nutritionTarget.fatGrams.map { "\($0)" } ?? ""
        editingTargetWeight = vm.profile.targetWeightKg.map { String(format: "%.1f", $0) } ?? ""
        selectedGoal = vm.nutritionTarget.nutritionGoal
    }

    private func recomputeTargets() {
        let engine = NutritionCoachEngine()
        vm.nutritionTarget = engine.computeTargets(profile: vm.profile)
        vm.nutritionTarget.nutritionGoal = selectedGoal
        loadCurrentValues()
        showRecompute = false
        vm.refreshNutritionInsights()
    }

    private func saveCustomTargets() {
        if let cal = Int(editingCalories), cal > 0 { vm.nutritionTarget.calories = cal }
        if let pro = Int(editingProtein), pro > 0 { vm.nutritionTarget.proteinGrams = pro }
        vm.nutritionTarget.carbsGrams = Int(editingCarbs)
        vm.nutritionTarget.fatGrams = Int(editingFat)
        vm.nutritionTarget.nutritionGoal = selectedGoal
        vm.refreshNutritionInsights()
    }

    private func saveTargetWeight() {
        if let w = Double(editingTargetWeight), w > 0 {
            vm.profile.targetWeightKg = w
        }
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
