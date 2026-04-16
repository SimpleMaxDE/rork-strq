import SwiftUI

struct SwapExerciseSheet: View {
    let vm: AppViewModel
    let dayId: String
    let exerciseId: String
    let onSwap: (Exercise) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var options: [ExerciseSwapOption] = []
    @State private var selectedOption: ExerciseSwapOption?
    @State private var confirmed: Bool = false
    @State private var appeared: Bool = false

    private var currentExercise: Exercise? {
        vm.library.exercise(byId: exerciseId)
    }

    private var groupedOptions: [(String, [ExerciseSwapOption])] {
        var groups: [(String, [ExerciseSwapOption])] = []
        var samePattern: [ExerciseSwapOption] = []
        var sameTarget: [ExerciseSwapOption] = []
        var jointFriendly: [ExerciseSwapOption] = []
        var other: [ExerciseSwapOption] = []

        for opt in options {
            if opt.tags.contains("Same pattern") {
                samePattern.append(opt)
            } else if opt.tags.contains("Same target") {
                sameTarget.append(opt)
            } else if opt.tags.contains("Joint-friendly") {
                jointFriendly.append(opt)
            } else {
                other.append(opt)
            }
        }

        if !samePattern.isEmpty { groups.append(("Same Movement Pattern", samePattern)) }
        if !sameTarget.isEmpty { groups.append(("Same Target Muscle", sameTarget)) }
        if !jointFriendly.isEmpty { groups.append(("Joint-Friendly Options", jointFriendly)) }
        if !other.isEmpty { groups.append(("Other Alternatives", other)) }

        if groups.isEmpty && !options.isEmpty {
            groups.append(("Alternatives", options))
        }

        return groups
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            ScrollView {
                VStack(spacing: 20) {
                    currentExerciseCard
                    alternativesList
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            options = vm.swapExerciseOptions(for: exerciseId, dayId: dayId)
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    private var headerBar: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Swap Exercise")
                        .font(.headline)
                    Text("Choose a smart alternative")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    private var currentExerciseCard: some View {
        if let exercise = currentExercise {
            VStack(alignment: .leading, spacing: 10) {
                Text("CURRENT")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)

                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(STRQBrand.steel.opacity(0.12))
                            .frame(width: 48, height: 48)
                        Image(systemName: exercise.primaryMuscle.symbolName)
                            .font(.title3)
                            .foregroundStyle(STRQBrand.steel)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.subheadline.weight(.semibold))
                        HStack(spacing: 8) {
                            Text(exercise.primaryMuscle.displayName)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(STRQBrand.steel)
                            Text(exercise.movementPattern.displayName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            if exercise.category == .compound {
                                Text("Compound")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundStyle(.blue)
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 1)
                                    .background(Color.blue.opacity(0.1), in: Capsule())
                            }
                        }
                    }
                    Spacer()
                }
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.4), value: appeared)
        }
    }

    private var alternativesList: some View {
        VStack(alignment: .leading, spacing: 16) {
            if options.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("No alternatives found")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ForEach(Array(groupedOptions.enumerated()), id: \.offset) { _, group in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: groupIcon(group.0))
                                .font(.caption)
                                .foregroundStyle(groupColor(group.0))
                            Text(group.0.uppercased())
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.secondary)
                                .tracking(0.5)
                        }

                        ForEach(group.1) { option in
                            swapOptionCard(option)
                        }
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)
    }

    private func swapOptionCard(_ option: ExerciseSwapOption) -> some View {
        let isSelected = selectedOption?.id == option.id
        let accentColor: Color = isSelected ? .green : .blue
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(accentColor.opacity(0.1))
                        .frame(width: 48, height: 48)
                    Image(systemName: option.exercise.primaryMuscle.symbolName)
                        .font(.title3)
                        .foregroundStyle(accentColor)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(option.exercise.name)
                        .font(.subheadline.weight(.semibold))
                    Text(option.reason)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                if isSelected && confirmed {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.green)
                }
            }

            HStack(spacing: 6) {
                ForEach(option.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(tagColor(tag))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(tagColor(tag).opacity(0.1), in: Capsule())
                }

                Spacer()

                HStack(spacing: 3) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(i < diffLevel(option.exercise.difficulty) ? difficultyColor(option.exercise.difficulty) : Color(.separator))
                            .frame(width: 4, height: 4)
                    }
                }

                if let equip = option.exercise.equipment.first(where: { $0 != .none }) {
                    Text(equip.displayName)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }

            if isSelected && !confirmed {
                Button {
                    withAnimation(.snappy(duration: 0.3)) {
                        confirmed = true
                    }
                    onSwap(option.exercise)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        dismiss()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.caption2.weight(.semibold))
                        Text("Confirm Swap")
                            .font(.subheadline.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 42)
                    .foregroundStyle(.white)
                    .background(Color.green.gradient, in: .rect(cornerRadius: 12))
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(14)
        .background(isSelected ? Color.green.opacity(0.04) : Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.green.opacity(0.3), lineWidth: 1)
            }
        }
        .contentShape(.rect(cornerRadius: 14))
        .onTapGesture {
            guard !confirmed else { return }
            withAnimation(.snappy(duration: 0.25)) {
                selectedOption = option
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4), trigger: isSelected)
    }

    private func groupIcon(_ group: String) -> String {
        switch group {
        case "Same Movement Pattern": return "arrow.triangle.2.circlepath"
        case "Same Target Muscle": return "scope"
        case "Joint-Friendly Options": return "hand.thumbsup.fill"
        default: return "star.fill"
        }
    }

    private func groupColor(_ group: String) -> Color {
        switch group {
        case "Same Movement Pattern": return .purple
        case "Same Target Muscle": return .blue
        case "Joint-Friendly Options": return .green
        default: return STRQBrand.steel
        }
    }

    private func tagColor(_ tag: String) -> Color {
        switch tag {
        case "Same target": return .blue
        case "Same pattern": return .purple
        case "Joint-friendly": return .green
        case "Minimal equipment": return STRQBrand.steel
        case "Easier": return .teal
        default: return .secondary
        }
    }

    private func diffLevel(_ difficulty: ExerciseDifficulty) -> Int {
        switch difficulty {
        case .beginner: 1
        case .intermediate: 2
        case .advanced: 3
        }
    }

    private func difficultyColor(_ difficulty: ExerciseDifficulty) -> Color {
        switch difficulty {
        case .beginner: return .green
        case .intermediate: return STRQBrand.steel
        case .advanced: return .red
        }
    }
}
