import SwiftUI

struct SwapExerciseSheet: View {
    let vm: AppViewModel
    let dayId: String
    let exerciseId: String
    let onSwap: (Exercise) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var results: ExerciseSwapResults = ExerciseSwapResults(currentRole: .accessory, sections: [])
    @State private var selectedIntent: SwapIntent?
    @State private var selectedOption: ExerciseSwapOption?
    @State private var confirmed: Bool = false
    @State private var appeared: Bool = false

    private var currentExercise: Exercise? {
        vm.library.exercise(byId: exerciseId)
    }

    private var availableIntents: [SwapIntent] {
        results.sections.map(\.intent)
    }

    private var visibleSections: [ExerciseSwapSection] {
        if let intent = selectedIntent {
            return results.sections.filter { $0.intent == intent }
        }
        return results.sections
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar
            ScrollView {
                VStack(spacing: 18) {
                    currentExerciseCard
                    if !availableIntents.isEmpty { intentFilterStrip }
                    alternativesList
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            results = vm.swapExerciseResults(for: exerciseId, dayId: dayId)
            withAnimation(.easeOut(duration: 0.4)) { appeared = true }
        }
    }

    private var headerBar: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.tr("Swap Exercise"))
                    .font(.headline)
                Text(L10n.tr("Pick a role-preserving alternative"))
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
            .accessibilityLabel(L10n.tr("Cancel swap"))
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private var currentExerciseCard: some View {
        if let exercise = currentExercise {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(STRQBrand.steel)
                    Text(L10n.tr("REPLACING"))
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(STRQBrand.steel)
                        .tracking(0.8)
                    Spacer()
                    roleBadge(results.currentRole)
                }

                HStack(spacing: 12) {
                    ExerciseThumbnail(exercise: exercise, size: .medium, cornerRadius: 12)

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
                        }
                    }
                    Spacer()
                }
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(STRQBrand.steel.opacity(0.22), lineWidth: 1)
            )
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.4), value: appeared)
        }
    }

    private var intentFilterStrip: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                intentChip(nil, label: "All", systemImage: "square.grid.2x2.fill")
                ForEach(availableIntents) { intent in
                    intentChip(intent, label: intent.label, systemImage: intent.symbolName)
                }
            }
            .padding(.vertical, 2)
        }
        .scrollIndicators(.hidden)
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.05), value: appeared)
    }

    private func intentChip(_ intent: SwapIntent?, label: String, systemImage: String) -> some View {
        let isSelected = selectedIntent == intent
        let accent = intent.map(intentColor) ?? STRQBrand.steel
        return Button {
            withAnimation(STRQMotion.tap) {
                selectedIntent = intent
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 11, weight: .semibold))
                Text(label)
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(isSelected ? .white : accent)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(isSelected ? accent : accent.opacity(0.12))
            )
        }
        .buttonStyle(.strqPressable)
    }

    private var alternativesList: some View {
        VStack(alignment: .leading, spacing: 18) {
            if results.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text(L10n.tr("No alternatives found"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                ForEach(visibleSections) { section in
                    intentSection(section)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.4).delay(0.1), value: appeared)
    }

    private func intentSection(_ section: ExerciseSwapSection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: section.intent.symbolName)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(intentColor(section.intent))
                    .frame(width: 22, height: 22)
                    .background(intentColor(section.intent).opacity(0.14), in: .rect(cornerRadius: 6))
                VStack(alignment: .leading, spacing: 1) {
                    Text(section.intent.label.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.primary)
                        .tracking(0.6)
                    Text(section.intent.shortLabel)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            VStack(spacing: 8) {
                ForEach(section.options) { option in
                    swapOptionCard(option)
                }
            }
        }
    }

    private func swapOptionCard(_ option: ExerciseSwapOption) -> some View {
        let isSelected = selectedOption?.id == option.id
        let accent = intentColor(option.intent)
        let showConfirm = isSelected && !confirmed
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ExerciseThumbnail(exercise: option.exercise, size: .small, cornerRadius: 12)

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
                        .foregroundStyle(STRQPalette.success)
                }
            }

            HStack(spacing: 6) {
                roleChip(option.role, preserved: option.role == results.currentRole)

                ForEach(option.tags.prefix(2), id: \.self) { tag in
                    Text(tag)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(tagColor(tag))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(tagColor(tag).opacity(0.12), in: Capsule())
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

            if showConfirm {
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
                        Text(L10n.tr("Confirm Swap"))
                            .font(.subheadline.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .foregroundStyle(.white)
                    .background(STRQPalette.success.gradient, in: .rect(cornerRadius: 12))
                }
                .buttonStyle(.strqPressable)
                .sensoryFeedback(.success, trigger: confirmed)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding(14)
        .background(isSelected ? STRQPalette.success.opacity(0.05) : Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(STRQPalette.success.opacity(0.35), lineWidth: 1)
            }
        }
        .contentShape(.rect(cornerRadius: 14))
        .onTapGesture {
            guard !confirmed else { return }
            withAnimation(STRQMotion.tap) {
                selectedOption = option
            }
        }
        .sensoryFeedback(.selection, trigger: isSelected)
    }

    private func roleBadge(_ role: ReplacementRole) -> some View {
        HStack(spacing: 4) {
            Image(systemName: roleIcon(role))
                .font(.system(size: 9, weight: .bold))
            Text(role.displayName.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(0.5)
        }
        .foregroundStyle(roleColor(role))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(roleColor(role).opacity(0.14), in: Capsule())
    }

    private func roleChip(_ role: ReplacementRole, preserved: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: preserved ? "checkmark.shield.fill" : roleIcon(role))
                .font(.system(size: 9, weight: .bold))
            Text(preserved ? L10n.tr("Same role") : role.displayName)
                .font(.system(size: 10, weight: .semibold))
        }
        .foregroundStyle(preserved ? STRQPalette.success : roleColor(role))
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background((preserved ? STRQPalette.success : roleColor(role)).opacity(0.12), in: Capsule())
    }

    private func roleIcon(_ role: ReplacementRole) -> String {
        switch role {
        case .anchor: "bolt.fill"
        case .secondary: "circle.grid.cross.fill"
        case .accessory: "scope"
        case .isolation: "target"
        case .warmup: "flame.fill"
        case .mobility: "figure.flexibility"
        }
    }

    private func roleColor(_ role: ReplacementRole) -> Color {
        switch role {
        case .anchor: .primary
        case .secondary: STRQPalette.info
        case .accessory, .isolation: STRQBrand.steel
        case .warmup: STRQPalette.warning
        case .mobility: STRQPalette.success
        }
    }

    private func intentColor(_ intent: SwapIntent) -> Color {
        switch intent {
        case .closest: STRQPalette.info
        case .variation: .purple
        case .easier: STRQPalette.success
        case .harder: STRQPalette.warning
        case .jointFriendly: STRQPalette.success
        case .home: STRQBrand.steel
        }
    }

    private func tagColor(_ tag: String) -> Color {
        switch tag {
        case "Same target": return STRQPalette.info
        case "Same pattern": return .purple
        case "Joint-friendly": return STRQPalette.success
        case "Minimal equipment": return STRQBrand.steel
        case "Easier": return .teal
        case "Harder": return STRQPalette.warning
        case "Same family": return .purple
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
        case .beginner: return STRQPalette.success
        case .intermediate: return STRQBrand.steel
        case .advanced: return STRQPalette.warning
        }
    }
}
