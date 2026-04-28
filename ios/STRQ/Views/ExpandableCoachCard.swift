import SwiftUI

struct ExpandableInsightCard: View {
    let insight: SmartInsight
    let actions: [CoachAction]
    let vm: AppViewModel
    @Binding var isExpanded: Bool
    var onAction: (CoachAction) -> Void

    @State private var actionApplied: CoachAction?
    @State private var showVolumePreview: Bool = false
    @State private var showLighterPreview: Bool = false
    @State private var showSwapSheet: Bool = false
    @State private var showRegenerateSheet: Bool = false
    @State private var showDeloadSheet: Bool = false
    @State private var volumePreview: VolumeReductionPreview?
    @State private var lighterPreview: LighterSessionPreview?
    @State private var regenPreview: WeekRegenerationPreview?
    @State private var deloadPreview: DeloadWeekPreview?

    private var accentColor: Color {
        switch insight.color {
        case "orange": return STRQPalette.warning
        case "yellow": return STRQPalette.warning
        case "green": return STRQPalette.success
        case "red": return STRQPalette.danger
        case "blue": return STRQPalette.info
        case "purple": return STRQBrand.slate
        default: return STRQBrand.steel
        }
    }

    private var severityColor: Color {
        switch insight.severity {
        case .high: return STRQPalette.danger
        case .medium: return STRQPalette.warning
        case .low: return STRQBrand.steel
        case .positive: return STRQPalette.success
        }
    }

    private var targetDayId: String? {
        vm.nextSessionDayId
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
            if isExpanded {
                expandedContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .background(
            accentColor.opacity(isExpanded ? 0.08 : 0.04),
            in: .rect(cornerRadius: 14)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(accentColor.opacity(isExpanded ? 0.2 : 0.08), lineWidth: 1)
        }
        .contentShape(.rect(cornerRadius: 14))
        .onTapGesture {
            withAnimation(.snappy(duration: 0.3)) {
                isExpanded.toggle()
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4), trigger: isExpanded)
        .sheet(isPresented: $showSwapSheet) {
            if let dayId = targetDayId,
               let day = vm.currentPlan?.days.first(where: { $0.id == dayId }),
               let firstExercise = day.exercises.first {
                SwapExerciseSheet(vm: vm, dayId: dayId, exerciseId: firstExercise.exerciseId) { newExercise in
                    vm.applyExerciseSwap(dayId: dayId, oldExerciseId: firstExercise.exerciseId, newExercise: newExercise)
                    withAnimation(.snappy(duration: 0.25)) {
                        actionApplied = actions.first { $0.type == .swapExercise }
                    }
                    vm.appliedActionIds.insert(insight.id)
                }
            }
        }
        .sheet(isPresented: $showRegenerateSheet) {
            if let preview = regenPreview {
                WeekRegenerationSheet(vm: vm, preview: preview) {
                    withAnimation(.snappy(duration: 0.3)) {
                        vm.applyWeekRegeneration()
                        actionApplied = actions.first { $0.type == .regenerateWeek }
                        vm.appliedActionIds.insert(insight.id)
                    }
                }
            }
        }
        .sheet(isPresented: $showDeloadSheet) {
            if let preview = deloadPreview {
                DeloadWeekSheet(vm: vm, preview: preview) {
                    withAnimation(.snappy(duration: 0.3)) {
                        vm.applyDeloadWeek()
                        actionApplied = actions.first { $0.type == .deload }
                        vm.appliedActionIds.insert(insight.id)
                    }
                }
            }
        }
    }

    private var headerRow: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(accentColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: insight.icon)
                    .font(.caption)
                    .foregroundStyle(accentColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(insight.title)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    if vm.appliedActionIds.contains(insight.id) {
                        appliedBadge
                    } else {
                        Circle()
                            .fill(severityColor)
                            .frame(width: 8, height: 8)
                    }
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Text(insight.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(isExpanded ? nil : 2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var appliedBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 9))
            Text(L10n.tr("Applied"))
                .font(.system(size: 9, weight: .semibold))
        }
        .foregroundStyle(STRQPalette.success)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(STRQPalette.successSoft, in: Capsule())
    }

    @ViewBuilder
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Divider()
                .background(accentColor.opacity(0.2))
                .padding(.top, 12)

            if let firstAction = actions.first {
                VStack(alignment: .leading, spacing: 6) {
                    Label(L10n.tr("Why This Matters"), systemImage: "info.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(accentColor)
                    Text(firstAction.whyItMatters)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            ForEach(actions) { action in
                actionCard(action)
            }
        }
    }

    private func actionCard(_ action: CoachAction) -> some View {
        let isApplied = actionApplied?.id == action.id || vm.appliedActionIds.contains(insight.id)
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: action.icon)
                    .font(.caption)
                    .foregroundStyle(accentColor)
                Text(action.explanation)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }

            if action.type == .reduceVolume, let preview = volumePreview, showVolumePreview {
                volumePreviewCard(preview)
            } else if action.type == .lighterSession, let preview = lighterPreview, showLighterPreview {
                lighterPreviewCard(preview)
            } else if action.type == .regenerateWeek || action.type == .deload {
                weekActionPreviewHint(action)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.4))
                    Text(action.previewText)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.06), in: .rect(cornerRadius: 8))
            }

            if isApplied {
                appliedRow(action)
            } else {
                actionButtons(action)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 12))
        .onAppear {
            loadPreviews(for: action)
        }
    }

    private func weekActionPreviewHint(_ action: CoachAction) -> some View {
        let isRegen = action.type == .regenerateWeek
        let color: Color = isRegen ? STRQBrand.steel : STRQBrand.slate
        let icon = isRegen ? "calendar.badge.clock" : "arrow.down.to.line"
        let label = isRegen ? "Full week adjustment" : "Deload all workouts"

        return HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(color.opacity(0.8))
            Spacer()
            Text(L10n.tr("Week-level"))
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(color.opacity(0.12), in: Capsule())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(color.opacity(0.06), in: .rect(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.12), lineWidth: 1)
        }
    }

    private func volumePreviewCard(_ preview: VolumeReductionPreview) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(STRQBrand.steel)
                Text("Preview: \(preview.dayName)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(STRQBrand.steel)
            }

            ForEach(preview.reductions) { reduction in
                HStack(spacing: 8) {
                    Circle()
                        .fill(STRQBrand.steel.opacity(0.3))
                        .frame(width: 5, height: 5)
                    Text(reduction.exerciseName)
                        .font(.caption2.weight(.medium))
                    Spacer()
                    Text("\(reduction.originalSets) → \(reduction.newSets) sets")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(STRQBrand.steel)
                }
            }

            HStack {
                Text("Total: \(preview.originalTotalSets) → \(preview.newTotalSets) sets")
                    .font(.caption2.weight(.semibold))
                Spacer()
                Text("~\(preview.estimatedTimeSaved) min saved")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 2)
        }
        .padding(10)
        .background(STRQBrand.steel.opacity(0.06), in: .rect(cornerRadius: 10))
    }

    private func lighterPreviewCard(_ preview: LighterSessionPreview) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(STRQBrand.steel)
                Text("Preview: \(preview.dayName)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(STRQBrand.steel)
            }

            ForEach(preview.changes) { change in
                HStack(spacing: 8) {
                    Circle()
                        .fill(STRQBrand.steel.opacity(0.3))
                        .frame(width: 5, height: 5)
                    Text(change.exerciseName)
                        .font(.caption2.weight(.medium))
                    Spacer()
                    Text(change.change)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(STRQBrand.steel)
                }
            }

            if preview.estimatedTimeSaved > 0 {
                HStack {
                    Text(L10n.tr("Effort: reduced"))
                        .font(.caption2.weight(.semibold))
                    Spacer()
                    Text("~\(preview.estimatedTimeSaved) min shorter")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 2)
            }
        }
        .padding(10)
        .background(STRQBrand.steel.opacity(0.06), in: .rect(cornerRadius: 10))
    }

    private func appliedRow(_ action: CoachAction) -> some View {
        let isWeekAction = action.type == .regenerateWeek || action.type == .deload
        return HStack(spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
                Text(L10n.tr("Applied"))
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(STRQPalette.success)

            Spacer()

            if isWeekAction, let adj = vm.weekAdjustment {
                Button {
                    withAnimation(.snappy(duration: 0.3)) {
                        vm.undoAdjustment(adj)
                        actionApplied = nil
                        vm.appliedActionIds.remove(insight.id)
                    }
                } label: {
                    undoLabel
                }
            } else if let dayId = targetDayId, let adj = vm.adjustment(for: dayId) {
                Button {
                    withAnimation(.snappy(duration: 0.3)) {
                        vm.undoAdjustment(adj)
                        actionApplied = nil
                        vm.appliedActionIds.remove(insight.id)
                    }
                } label: {
                    undoLabel
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var undoLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.uturn.backward")
                .font(.system(size: 10, weight: .semibold))
            Text(L10n.tr("Undo"))
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(.white.opacity(0.6))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.08), in: Capsule())
    }

    @ViewBuilder
    private func actionButtons(_ action: CoachAction) -> some View {
        switch action.type {
        case .reduceVolume:
            Button {
                guard let dayId = targetDayId, let preview = volumePreview else { return }
                withAnimation(.snappy(duration: 0.25)) {
                    vm.applyVolumeReduction(dayId: dayId, preview: preview)
                    actionApplied = action
                    vm.appliedActionIds.insert(insight.id)
                }
            } label: {
                actionButtonLabel(action)
            }
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.6), trigger: actionApplied != nil)
            .disabled(volumePreview == nil)

        case .swapExercise:
            Button {
                showSwapSheet = true
            } label: {
                actionButtonLabel(action)
            }

        case .lighterSession:
            Button {
                guard let dayId = targetDayId else { return }
                withAnimation(.snappy(duration: 0.25)) {
                    vm.applyLighterSession(dayId: dayId)
                    actionApplied = action
                    vm.appliedActionIds.insert(insight.id)
                }
            } label: {
                actionButtonLabel(action)
            }
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.6), trigger: actionApplied != nil)

        case .regenerateWeek:
            Button {
                regenPreview = vm.previewWeekRegeneration()
                if regenPreview != nil {
                    showRegenerateSheet = true
                }
            } label: {
                weekActionButtonLabel(action, color: STRQBrand.steel)
            }
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.6), trigger: showRegenerateSheet)

        case .deload:
            Button {
                deloadPreview = vm.previewDeloadWeek()
                if deloadPreview != nil {
                    showDeloadSheet = true
                }
            } label: {
                weekActionButtonLabel(action, color: STRQBrand.slate)
            }
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.6), trigger: showDeloadSheet)

        default:
            Button {
                withAnimation(.snappy(duration: 0.25)) {
                    actionApplied = action
                    vm.appliedActionIds.insert(insight.id)
                }
                onAction(action)
            } label: {
                actionButtonLabel(action)
            }
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.6), trigger: actionApplied != nil)
        }
    }

    private func actionButtonLabel(_ action: CoachAction) -> some View {
        HStack(spacing: 6) {
            Image(systemName: action.icon)
                .font(.caption2.weight(.semibold))
            Text(action.label)
                .font(.caption.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 36)
        .foregroundStyle(.black)
        .background(accentColor, in: .rect(cornerRadius: 10))
    }

    private func weekActionButtonLabel(_ action: CoachAction, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: action.icon)
                .font(.caption2.weight(.semibold))
            Text(action.label)
                .font(.caption.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 36)
        .foregroundStyle(.white)
        .background(
            LinearGradient(
                colors: [color, color.opacity(0.7)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: .rect(cornerRadius: 10)
        )
    }

    private func loadPreviews(for action: CoachAction) {
        guard let dayId = targetDayId else { return }
        switch action.type {
        case .reduceVolume:
            volumePreview = vm.previewVolumeReduction(for: dayId)
            showVolumePreview = volumePreview != nil
        case .lighterSession:
            lighterPreview = vm.previewLighterSession(for: dayId)
            showLighterPreview = lighterPreview != nil
        default:
            break
        }
    }
}

struct ExpandableRecommendationCard: View {
    let recommendation: Recommendation
    let actions: [CoachAction]
    let vm: AppViewModel
    @Binding var isExpanded: Bool
    var onAction: (CoachAction) -> Void

    @State private var actionApplied: CoachAction?
    @State private var showVolumePreview: Bool = false
    @State private var showLighterPreview: Bool = false
    @State private var showSwapSheet: Bool = false
    @State private var showRegenerateSheet: Bool = false
    @State private var showDeloadSheet: Bool = false
    @State private var volumePreview: VolumeReductionPreview?
    @State private var lighterPreview: LighterSessionPreview?
    @State private var regenPreview: WeekRegenerationPreview?
    @State private var deloadPreview: DeloadWeekPreview?

    private var accentColor: Color {
        switch recommendation.type {
        case .volumeImbalance: return STRQBrand.steel
        case .progressionSuggestion: return STRQPalette.success
        case .recoveryConcern: return STRQPalette.danger
        case .exerciseSwap: return STRQBrand.steel
        case .splitSuggestion: return STRQBrand.slate
        case .prCongrats: return STRQPalette.gold
        case .general: return .white.opacity(0.6)
        }
    }

    private var typeIcon: String {
        switch recommendation.type {
        case .volumeImbalance: return "chart.bar.fill"
        case .progressionSuggestion: return "arrow.up.right"
        case .recoveryConcern: return "heart.fill"
        case .exerciseSwap: return "arrow.triangle.2.circlepath"
        case .splitSuggestion: return "rectangle.split.3x1.fill"
        case .prCongrats: return "trophy.fill"
        case .general: return "lightbulb.fill"
        }
    }

    private var targetDayId: String? {
        vm.nextSessionDayId
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow
            if isExpanded {
                expandedContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .background(Color.white.opacity(isExpanded ? 0.07 : 0.04), in: .rect(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(accentColor.opacity(isExpanded ? 0.2 : 0), lineWidth: 1)
        }
        .contentShape(.rect(cornerRadius: 14))
        .onTapGesture {
            withAnimation(.snappy(duration: 0.3)) {
                isExpanded.toggle()
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4), trigger: isExpanded)
        .sheet(isPresented: $showSwapSheet) {
            if let dayId = targetDayId,
               let day = vm.currentPlan?.days.first(where: { $0.id == dayId }),
               let firstExercise = day.exercises.first {
                SwapExerciseSheet(vm: vm, dayId: dayId, exerciseId: firstExercise.exerciseId) { newExercise in
                    vm.applyExerciseSwap(dayId: dayId, oldExerciseId: firstExercise.exerciseId, newExercise: newExercise)
                    withAnimation(.snappy(duration: 0.25)) {
                        actionApplied = actions.first { $0.type == .swapExercise }
                        vm.appliedActionIds.insert(recommendation.id)
                    }
                }
            }
        }
        .sheet(isPresented: $showRegenerateSheet) {
            if let preview = regenPreview {
                WeekRegenerationSheet(vm: vm, preview: preview) {
                    withAnimation(.snappy(duration: 0.3)) {
                        vm.applyWeekRegeneration()
                        actionApplied = actions.first { $0.type == .regenerateWeek }
                        vm.appliedActionIds.insert(recommendation.id)
                    }
                }
            }
        }
        .sheet(isPresented: $showDeloadSheet) {
            if let preview = deloadPreview {
                DeloadWeekSheet(vm: vm, preview: preview) {
                    withAnimation(.snappy(duration: 0.3)) {
                        vm.applyDeloadWeek()
                        actionApplied = actions.first { $0.type == .deload }
                        vm.appliedActionIds.insert(recommendation.id)
                    }
                }
            }
        }
    }

    private var headerRow: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: typeIcon)
                .font(.caption)
                .foregroundStyle(accentColor)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(recommendation.title)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    if vm.appliedActionIds.contains(recommendation.id) {
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 9))
                            Text(L10n.tr("Applied"))
                                .font(.system(size: 9, weight: .semibold))
                        }
                        .foregroundStyle(STRQPalette.success)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(STRQPalette.successSoft, in: Capsule())
                    }
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                Text(recommendation.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(isExpanded ? nil : 2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    @ViewBuilder
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Divider()
                .background(accentColor.opacity(0.2))
                .padding(.top, 12)

            if let firstAction = actions.first {
                VStack(alignment: .leading, spacing: 6) {
                    Label(L10n.tr("Why This Matters"), systemImage: "info.circle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(accentColor)
                    Text(firstAction.whyItMatters)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            ForEach(actions) { action in
                actionCard(action)
            }
        }
    }

    private func actionCard(_ action: CoachAction) -> some View {
        let isApplied = actionApplied?.id == action.id || vm.appliedActionIds.contains(recommendation.id)
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: action.icon)
                    .font(.caption)
                    .foregroundStyle(accentColor)
                Text(action.explanation)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .fixedSize(horizontal: false, vertical: true)
            }

            if action.type == .reduceVolume, let preview = volumePreview, showVolumePreview {
                volumePreviewContent(preview)
            } else if action.type == .lighterSession, let preview = lighterPreview, showLighterPreview {
                lighterPreviewContent(preview)
            } else if action.type == .regenerateWeek || action.type == .deload {
                weekActionPreviewHint(action)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "eye.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(.white.opacity(0.4))
                    Text(action.previewText)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.06), in: .rect(cornerRadius: 8))
            }

            if isApplied {
                appliedRow(action)
            } else {
                actionButton(action)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 12))
        .onAppear {
            loadPreviews(for: action)
        }
    }

    private func weekActionPreviewHint(_ action: CoachAction) -> some View {
        let isRegen = action.type == .regenerateWeek
        let color: Color = isRegen ? STRQBrand.steel : STRQBrand.slate
        let icon = isRegen ? "calendar.badge.clock" : "arrow.down.to.line"
        let label = isRegen ? "Full week adjustment" : "Deload all workouts"

        return HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(color.opacity(0.8))
            Spacer()
            Text(L10n.tr("Week-level"))
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(color.opacity(0.12), in: Capsule())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(color.opacity(0.06), in: .rect(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.12), lineWidth: 1)
        }
    }

    private func appliedRow(_ action: CoachAction) -> some View {
        let isWeekAction = action.type == .regenerateWeek || action.type == .deload
        return HStack(spacing: 8) {
            HStack(spacing: 5) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption2)
                Text(L10n.tr("Applied"))
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(STRQPalette.success)

            Spacer()

            if isWeekAction, let adj = vm.weekAdjustment {
                Button {
                    withAnimation(.snappy(duration: 0.3)) {
                        vm.undoAdjustment(adj)
                        actionApplied = nil
                        vm.appliedActionIds.remove(recommendation.id)
                    }
                } label: {
                    undoLabel
                }
            } else if let dayId = targetDayId, let adj = vm.adjustment(for: dayId) {
                Button {
                    withAnimation(.snappy(duration: 0.3)) {
                        vm.undoAdjustment(adj)
                        actionApplied = nil
                        vm.appliedActionIds.remove(recommendation.id)
                    }
                } label: {
                    undoLabel
                }
            }
        }
        .padding(.vertical, 4)
    }

    private var undoLabel: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.uturn.backward")
                .font(.system(size: 10, weight: .semibold))
            Text(L10n.tr("Undo"))
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(.white.opacity(0.6))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.08), in: Capsule())
    }

    @ViewBuilder
    private func actionButton(_ action: CoachAction) -> some View {
        switch action.type {
        case .reduceVolume:
            Button {
                guard let dayId = targetDayId, let preview = volumePreview else { return }
                withAnimation(.snappy(duration: 0.25)) {
                    vm.applyVolumeReduction(dayId: dayId, preview: preview)
                    actionApplied = action
                    vm.appliedActionIds.insert(recommendation.id)
                }
            } label: {
                buttonLabel(action)
            }
            .disabled(volumePreview == nil)

        case .swapExercise:
            Button {
                showSwapSheet = true
            } label: {
                buttonLabel(action)
            }

        case .lighterSession:
            Button {
                guard let dayId = targetDayId else { return }
                withAnimation(.snappy(duration: 0.25)) {
                    vm.applyLighterSession(dayId: dayId)
                    actionApplied = action
                    vm.appliedActionIds.insert(recommendation.id)
                }
            } label: {
                buttonLabel(action)
            }

        case .regenerateWeek:
            Button {
                regenPreview = vm.previewWeekRegeneration()
                if regenPreview != nil {
                    showRegenerateSheet = true
                }
            } label: {
                weekButtonLabel(action, color: STRQBrand.steel)
            }
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.6), trigger: showRegenerateSheet)

        case .deload:
            Button {
                deloadPreview = vm.previewDeloadWeek()
                if deloadPreview != nil {
                    showDeloadSheet = true
                }
            } label: {
                weekButtonLabel(action, color: STRQBrand.slate)
            }
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.6), trigger: showDeloadSheet)

        default:
            Button {
                withAnimation(.snappy(duration: 0.25)) {
                    actionApplied = action
                    vm.appliedActionIds.insert(recommendation.id)
                }
                onAction(action)
            } label: {
                buttonLabel(action)
            }
        }
    }

    private func buttonLabel(_ action: CoachAction) -> some View {
        HStack(spacing: 6) {
            Image(systemName: action.icon)
                .font(.caption2.weight(.semibold))
            Text(action.label)
                .font(.caption.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 36)
        .foregroundStyle(.black)
        .background(accentColor, in: .rect(cornerRadius: 10))
    }

    private func weekButtonLabel(_ action: CoachAction, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: action.icon)
                .font(.caption2.weight(.semibold))
            Text(action.label)
                .font(.caption.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 36)
        .foregroundStyle(.white)
        .background(
            LinearGradient(
                colors: [color, color.opacity(0.7)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: .rect(cornerRadius: 10)
        )
    }

    private func volumePreviewContent(_ preview: VolumeReductionPreview) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(STRQBrand.steel)
                Text("Preview: \(preview.dayName)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(STRQBrand.steel)
            }
            ForEach(preview.reductions) { reduction in
                HStack(spacing: 8) {
                    Circle().fill(STRQBrand.steel.opacity(0.3)).frame(width: 5, height: 5)
                    Text(reduction.exerciseName).font(.caption2.weight(.medium))
                    Spacer()
                    Text("\(reduction.originalSets) → \(reduction.newSets) sets")
                        .font(.caption2.weight(.semibold)).foregroundStyle(STRQBrand.steel)
                }
            }
            HStack {
                Text("Total: \(preview.originalTotalSets) → \(preview.newTotalSets) sets")
                    .font(.caption2.weight(.semibold))
                Spacer()
                Text("~\(preview.estimatedTimeSaved) min saved")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(STRQBrand.steel.opacity(0.06), in: .rect(cornerRadius: 10))
    }

    private func lighterPreviewContent(_ preview: LighterSessionPreview) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(STRQBrand.steel)
                Text("Preview: \(preview.dayName)")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(STRQBrand.steel)
            }
            ForEach(preview.changes) { change in
                HStack(spacing: 8) {
                    Circle().fill(STRQBrand.steel.opacity(0.3)).frame(width: 5, height: 5)
                    Text(change.exerciseName).font(.caption2.weight(.medium))
                    Spacer()
                    Text(change.change)
                        .font(.caption2.weight(.semibold)).foregroundStyle(STRQBrand.steel)
                }
            }
            if preview.estimatedTimeSaved > 0 {
                HStack {
                    Text(L10n.tr("Effort: reduced")).font(.caption2.weight(.semibold))
                    Spacer()
                    Text("~\(preview.estimatedTimeSaved) min shorter")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(STRQBrand.steel.opacity(0.06), in: .rect(cornerRadius: 10))
    }

    private func loadPreviews(for action: CoachAction) {
        guard let dayId = targetDayId else { return }
        switch action.type {
        case .reduceVolume:
            volumePreview = vm.previewVolumeReduction(for: dayId)
            showVolumePreview = volumePreview != nil
        case .lighterSession:
            lighterPreview = vm.previewLighterSession(for: dayId)
            showLighterPreview = lighterPreview != nil
        default:
            break
        }
    }
}
