import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    let vm: AppViewModel
    var planContext: ExercisePlanContext?

    @Environment(\.dismiss) private var dismiss
    @State private var selectedAlternative: Exercise?
    @State private var appeared: Bool = false

    private let library = ExerciseLibrary.shared

    private var progression: ExerciseProgressionState? {
        vm.progressionStates.first(where: { $0.exerciseId == exercise.id })
    }

    private var loadSuggestion: StartingLoadEngine.LoadSuggestion? {
        vm.loadSuggestion(for: exercise.id)
    }

    private var guidance: NextSessionGuidance? {
        vm.nextSessionGuidance(for: exercise.id)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                heroSection
                classificationRow
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                // Plan context leads — "why STRQ picked this"
                if let ctx = planContext {
                    planContextCard(ctx)
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                }

                // SECTION 1 — TODAY
                if loadSuggestion != nil || guidance != nil || progression != nil || (planContext == nil) {
                    sectionGroup("Today") {
                        if let suggestion = loadSuggestion {
                            loadSuggestionCard(suggestion)
                        }
                        if let g = guidance {
                            nextSessionCard(g)
                        }
                        if let prog = progression {
                            progressionStatusCard(prog)
                        }
                        if planContext == nil && loadSuggestion == nil && guidance == nil && progression == nil {
                            emptyTodayPlaceholder
                        }
                    }
                }

                // SECTION 2 — VARIATIONS (family-first)
                sectionGroup("Variations") {
                    progressionChainSection
                    unifiedAlternativesSection
                    familySection
                }

                // SECTION 3 — EXECUTION
                if !exercise.instructions.isEmpty || !exercise.cues.isEmpty || !exercise.commonMistakes.isEmpty {
                    sectionGroup("Execution") {
                        if !exercise.instructions.isEmpty { instructionsSection }
                        if !exercise.cues.isEmpty { cuesSection }
                        if !exercise.commonMistakes.isEmpty { mistakesSection }
                    }
                }

                // SECTION 4 — TARGET
                sectionGroup("Target") {
                    muscleMapSection
                }

                // SECTION 5 — EQUIPMENT
                equipmentSection
                    .padding(.top, 18)

                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle(exercise.name)
        .toolbarTitleDisplayMode(.inline)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        vm.toggleFavorite(exercise.id)
                    } label: {
                        Image(systemName: vm.favoriteExerciseIds.contains(exercise.id) ? "heart.fill" : "heart")
                            .foregroundStyle(vm.favoriteExerciseIds.contains(exercise.id) ? .red : .secondary)
                    }
                    .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4), trigger: vm.favoriteExerciseIds.contains(exercise.id))
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button(L10n.tr("Done")) { dismiss() }
            }
        }
        .sheet(item: $selectedAlternative) { alt in
            NavigationStack {
                ExerciseDetailView(exercise: alt, vm: vm)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }

    private var heroSection: some View {
        ExerciseHeroView(exercise: exercise, compact: false, showTitle: true)
    }

    @ViewBuilder
    private func sectionGroup<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 8) {
                Text(title.uppercased())
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(.secondary)
                Rectangle()
                    .fill(Color(.separator).opacity(0.5))
                    .frame(height: 0.5)
            }
            .padding(.horizontal, 16)

            VStack(spacing: 8) {
                content()
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 14)
    }

    private var classificationRow: some View {
        let family = library.family(for: exercise)?.name
        let role = planContext?.role.displayName ?? (exercise.category == .compound ? "Key Lift" : exercise.category == .isolation ? "Accessory" : exercise.category.displayName)
        return HStack(spacing: 0) {
            classificationCell(label: "Role", value: role, accent: .primary)
            classificationDivider
            classificationCell(label: "Family", value: family ?? exercise.movementPattern.displayName, accent: .primary)
            classificationDivider
            classificationCell(label: "Pattern", value: shortPatternName(exercise.movementPattern), accent: .secondary)
            classificationDivider
            classificationCell(label: "Level", value: exercise.difficulty.displayName, accent: diffColor)
        }
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
    }

    private func classificationCell(label: String, value: String, accent: Color) -> some View {
        VStack(spacing: 3) {
            Text(label.uppercased())
                .font(.system(size: 8.5, weight: .bold))
                .tracking(0.7)
                .foregroundStyle(.tertiary)
            Text(value)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(accent)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
    }

    private var classificationDivider: some View {
        Rectangle()
            .fill(Color(.separator).opacity(0.5))
            .frame(width: 1, height: 26)
    }

    private func shortPatternName(_ p: MovementPattern) -> String {
        switch p {
        case .horizontalPush: "H. Push"
        case .horizontalPull: "H. Pull"
        case .verticalPush: "V. Push"
        case .verticalPull: "V. Pull"
        case .hipHinge: "Hinge"
        case .squat: "Squat"
        case .lunge: "Lunge"
        case .carry: "Carry"
        case .rotation: "Rotation"
        case .antiRotation: "Anti-Rot"
        case .flexion: "Flexion"
        case .extension_: "Extension"
        case .abduction: "Abduction"
        case .adduction: "Adduction"
        case .isometric: "Isometric"
        case .plyometric: "Plyo"
        case .locomotion: "Locomotion"
        }
    }


    private var emptyTodayPlaceholder: some View {
        HStack(spacing: 10) {
            Image(systemName: "circle.dashed")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Text(L10n.tr("Log a set to unlock today's guidance."))
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .padding(12)
        .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 12))
    }

    private func formatKg(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", v) : String(format: "%.1f", v)
    }


    private func infoChip(_ text: String, icon: String, color: Color) -> some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundStyle(color)
            Text(text)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(color.opacity(0.08), in: Capsule())
    }

    private func planContextCard(_ ctx: ExercisePlanContext) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "calendar.badge.clock")
                    .font(.caption)
                    .foregroundStyle(STRQPalette.info)
                Text(L10n.tr("WHY STRQ PICKED THIS"))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(STRQPalette.info)
                    .tracking(0.5)
                Spacer()
                Text(ctx.role.displayName)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(STRQPalette.info)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(STRQPalette.infoSoft, in: Capsule())
            }

            Text(ctx.reason)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(roleRationale(ctx.role))
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)

            HStack(spacing: 12) {
                Label("\(ctx.sets) × \(ctx.reps)", systemImage: "rectangle.stack.fill")
                    .font(.caption.weight(.medium))
                if let rpe = ctx.rpe {
                    Label("RPE \(Int(rpe))", systemImage: "gauge.with.needle.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(STRQBrand.steel)
                }
                Spacer()
                Text(ctx.dayName)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .labelStyle(.titleAndIcon)
            .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(STRQPalette.info.opacity(0.05), in: .rect(cornerRadius: 14))
    }

    private func roleRationale(_ role: ExerciseRole) -> String {
        switch role {
        case .keyLift: return "Anchor lift — strongest stimulus, highest priority. STRQ will only swap this if load is too heavy or a joint signal appears."
        case .supportLift: return "Supports the anchor with a complementary angle. Swappable for similar pattern variations."
        case .accessory: return "Targeted volume for lagging or focus muscles. Swap freely within the same muscle group."
        case .warmup: return "Primes the movement. Swap for any pattern-matched mobility or activation drill."
        case .saferSubstitute: return "Selected because of a joint or recovery signal. STRQ will restore the standard lift when signals clear."
        }
    }

    private func loadSuggestionCard(_ suggestion: StartingLoadEngine.LoadSuggestion) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "scalemass.fill")
                    .font(.caption)
                    .foregroundStyle(STRQPalette.success)
                Text(L10n.tr("SUGGESTED LOAD"))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
                Spacer()
                Text(suggestion.confidence.label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(STRQPalette.success)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(STRQPalette.successSoft, in: Capsule())
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.tr("Weight"))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.tertiary)
                    Text(suggestion.formattedWeight)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(STRQPalette.success)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.tr("Reps"))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.tertiary)
                    Text(suggestion.repTarget)
                        .font(.subheadline.weight(.bold))
                }
                Spacer()
            }

            Text(suggestion.basis)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(STRQPalette.successSoft.opacity(0.4), in: .rect(cornerRadius: 14))
    }

    private func nextSessionCard(_ g: NextSessionGuidance) -> some View {
        let color = guidanceColorValue(g.color)
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: g.icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text(L10n.tr("NEXT SESSION"))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
            }

            Text(g.action)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)

            Text(g.detail)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.04), in: .rect(cornerRadius: 14))
    }

    private func guidanceColorValue(_ name: String) -> Color {
        switch name {
        case "green": return STRQPalette.success
        case "blue": return STRQPalette.info
        case "orange": return STRQPalette.warning
        case "red": return STRQPalette.danger
        case "purple": return STRQBrand.slate
        case "teal": return STRQPalette.info
        default: return STRQBrand.steel
        }
    }

    private func progressionStatusCard(_ prog: ExerciseProgressionState) -> some View {
        let statusColor = plateauColor(prog.plateauStatus)

        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: prog.plateauStatus.icon)
                    .font(.caption)
                    .foregroundStyle(statusColor)
                Text(L10n.tr("PROGRESSION STATUS"))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
                Spacer()
                Text(prog.plateauStatus.displayName)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(statusColor.opacity(0.12), in: Capsule())
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.tr("Last"))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.tertiary)
                    Text("\(String(format: "%.1f", prog.lastWeight)) kg × \(prog.lastReps)")
                        .font(.caption.weight(.semibold))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.tr("Sessions"))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.tertiary)
                    Text("\(prog.sessionCount)")
                        .font(.caption.weight(.semibold))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.tr("Strategy"))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.tertiary)
                    Text(prog.recommendedStrategy.displayName)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(statusColor)
                }
            }

            if !prog.coachNote.isEmpty {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "brain.head.profile.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.purple)
                    Text(prog.coachNote)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .background(statusColor.opacity(0.04), in: .rect(cornerRadius: 14))
    }

    private var muscleMapSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 16) {
                BodyMapView(
                    primaryMuscles: [exercise.primaryMuscle],
                    secondaryMuscles: exercise.secondaryMuscles,
                    compact: true
                )

                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.tr("PRIMARY"))
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(STRQBrand.steel)
                            .tracking(0.5)
                        HStack(spacing: 6) {
                            Image(systemName: exercise.primaryMuscle.symbolName)
                                .font(.caption)
                                .foregroundStyle(STRQBrand.steel)
                            Text(exercise.primaryMuscle.displayName)
                                .font(.subheadline.weight(.semibold))
                        }
                    }

                    if !exercise.secondaryMuscles.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(L10n.tr("SECONDARY"))
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.secondary)
                                .tracking(0.5)
                            ForEach(exercise.secondaryMuscles) { muscle in
                                HStack(spacing: 6) {
                                    Image(systemName: muscle.symbolName)
                                        .font(.system(size: 10))
                                        .foregroundStyle(.secondary)
                                    Text(muscle.displayName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
                Spacer()
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    private var instructionsSection: some View {
        let splitIndex = min(2, exercise.instructions.count)
        let setup = Array(exercise.instructions.prefix(splitIndex))
        let execute = Array(exercise.instructions.dropFirst(splitIndex))

        return VStack(alignment: .leading, spacing: 10) {
            subsectionHeader("How to Perform", icon: "list.number")

            VStack(alignment: .leading, spacing: 12) {
                if !setup.isEmpty {
                    instructionPhase(label: "SETUP", color: STRQPalette.info, steps: setup, startIndex: 0)
                }
                if !execute.isEmpty {
                    instructionPhase(label: "EXECUTE", color: categoryColor, steps: execute, startIndex: splitIndex)
                }
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)
    }

    private func instructionPhase(label: String, color: Color, steps: [String], startIndex: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Rectangle()
                    .fill(color)
                    .frame(width: 3, height: 10)
                    .clipShape(.capsule)
                Text(label)
                    .font(.system(size: 9, weight: .black))
                    .tracking(0.8)
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 7) {
                ForEach(Array(steps.enumerated()), id: \.offset) { idx, step in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(startIndex + idx + 1)")
                            .font(.system(size: 11, weight: .bold, design: .rounded))
                            .foregroundStyle(color)
                            .frame(width: 18, height: 18)
                            .background(color.opacity(0.12), in: Circle())
                        Text(step)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
    }

    private var cuesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(STRQPalette.success)
                Text(L10n.tr("DO THIS"))
                    .font(.system(size: 9, weight: .black))
                    .tracking(0.8)
                    .foregroundStyle(STRQPalette.success)
            }
            VStack(alignment: .leading, spacing: 6) {
                ForEach(exercise.cues, id: \.self) { cue in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(STRQPalette.success)
                            .frame(width: 14, alignment: .center)
                            .padding(.top, 3)
                        Text(cue)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
    }

    private var mistakesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(STRQPalette.danger)
                Text(L10n.tr("AVOID THIS"))
                    .font(.system(size: 9, weight: .black))
                    .tracking(0.8)
                    .foregroundStyle(STRQPalette.danger)
            }
            VStack(alignment: .leading, spacing: 6) {
                ForEach(exercise.commonMistakes, id: \.self) { mistake in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "xmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(STRQPalette.danger)
                            .frame(width: 14, alignment: .center)
                            .padding(.top, 3)
                        Text(mistake)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.25), value: appeared)
    }

    private func subsectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
        }
    }

    @ViewBuilder
    private var unifiedAlternativesSection: some View {
        let items = unifiedAlternativeItems()
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                subsectionHeader("Alternatives", icon: "arrow.triangle.2.circlepath")

                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(items, id: \.exercise.id) { item in
                            Button {
                                selectedAlternative = item.exercise
                            } label: {
                                alternativeCard(item.exercise, reasonOverride: item.reason)
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.3), value: appeared)
        }
    }

    private struct UnifiedAltItem {
        let exercise: Exercise
        let reason: String
        let priority: Int
    }

    private func unifiedAlternativeItems() -> [UnifiedAltItem] {
        // Use the intent-ranked engine so the detail rail shows the same
        // role-preserving, coach-grade alternatives as the swap sheet —
        // curated first, followed by joint-friendly and home contexts.
        var seen: Set<String> = [exercise.id]
        var items: [UnifiedAltItem] = []

        let selection = ExerciseSelectionEngine()
        let context = ExerciseSelectionContext(
            profile: vm.profile,
            progressionStates: vm.progressionStates,
            workoutHistory: vm.workoutHistory,
            recoveryScore: vm.effectiveRecoveryScore,
            phase: vm.trainingPhaseState.currentPhase
        )

        func add(intent: SwapIntent, limit: Int, priority: Int) {
            let ranked = selection.rankedSubstitutes(
                for: exercise.id,
                intent: intent,
                context: context,
                limit: limit
            )
            for scored in ranked {
                if seen.contains(scored.exercise.id) { continue }
                seen.insert(scored.exercise.id)
                let reason = scored.reasons.first ?? intent.shortLabel
                items.append(UnifiedAltItem(exercise: scored.exercise, reason: reason, priority: priority))
            }
        }

        add(intent: .closest, limit: 4, priority: 0)
        add(intent: .variation, limit: 3, priority: 1)
        if !exercise.isJointFriendly {
            add(intent: .jointFriendly, limit: 2, priority: 2)
        }
        if exercise.locationType == .gym {
            add(intent: .home, limit: 2, priority: 3)
        }

        if items.isEmpty {
            for alt in library.alternatives(for: exercise) {
                if seen.contains(alt.id) { continue }
                seen.insert(alt.id)
                items.append(UnifiedAltItem(exercise: alt, reason: alternativeReason(alt), priority: 0))
            }
        }

        return items.sorted { $0.priority < $1.priority }
    }



    @ViewBuilder
    private func alternativeReasonTag(_ alt: Exercise) -> some View {
        let reason = alternativeReason(alt)
        Text(reason)
            .font(.system(size: 9, weight: .semibold))
            .foregroundStyle(alternativeReasonColor(reason))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(alternativeReasonColor(reason).opacity(0.1), in: Capsule())
    }

    private func alternativeReason(_ alt: Exercise) -> String {
        if alt.primaryMuscle == exercise.primaryMuscle && alt.movementPattern == exercise.movementPattern {
            return "Same pattern"
        }
        if alt.primaryMuscle == exercise.primaryMuscle {
            return "Same target"
        }
        if alt.isJointFriendly && !exercise.isJointFriendly {
            return "Joint-friendly"
        }
        if alt.isBodyweight && !exercise.isBodyweight {
            return "No equipment"
        }
        return "Alternative"
    }

    private func alternativeReasonColor(_ reason: String) -> Color {
        switch reason {
        case "Same pattern": return STRQBrand.slate
        case "Same target": return STRQPalette.info
        case "Joint-friendly": return STRQPalette.success
        case "No equipment": return STRQBrand.steel
        case "Home option": return STRQPalette.info
        default: return .secondary
        }
    }

    @ViewBuilder
    private var progressionChainSection: some View {
        let progressions = library.progressions(for: exercise)
        let regressions = library.regressions(for: exercise)

        if !progressions.isEmpty || !regressions.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                subsectionHeader("Progression Chain", icon: "arrow.up.arrow.down")

                VStack(spacing: 4) {
                    ForEach(regressions) { reg in
                        progressionRow(reg, label: "Easier", color: STRQPalette.success, icon: "arrow.down.circle.fill")
                    }

                    HStack(spacing: 10) {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundStyle(STRQBrand.steel)
                        Text(exercise.name)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text(L10n.tr("Current"))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(STRQBrand.steel, in: Capsule())
                    }
                    .padding(12)
                    .background(STRQBrand.steel.opacity(0.08), in: .rect(cornerRadius: 12))

                    ForEach(progressions) { prog in
                        progressionRow(prog, label: "Harder", color: STRQPalette.warning, icon: "arrow.up.circle.fill")
                    }
                }
            }
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.35), value: appeared)
        }
    }

    private func progressionRow(_ exercise: Exercise, label: String, color: Color, icon: String) -> some View {
        Button {
            selectedAlternative = exercise
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                VStack(alignment: .leading, spacing: 1) {
                    Text(exercise.name)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Text(exercise.difficulty.displayName)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
                Spacer()
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(color)
                Image(systemName: "chevron.right")
                    .font(.system(size: 10))
                    .foregroundStyle(.quaternary)
            }
            .padding(12)
            .background(color.opacity(0.04), in: .rect(cornerRadius: 12))
        }
    }

    @ViewBuilder
    private var familySection: some View {
        if let family = library.family(for: exercise) {
            let chain = library.progressionChain(for: exercise)
            VStack(alignment: .leading, spacing: 10) {
                subsectionHeader("\(family.name) Family", icon: family.icon)

                VStack(alignment: .leading, spacing: 10) {
                    Text(family.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if chain.count > 1 {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.purple)
                                Text(L10n.tr("PROGRESSION PATH"))
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.purple)
                                    .tracking(0.5)
                            }

                            ScrollView(.horizontal) {
                                HStack(spacing: 4) {
                                    ForEach(Array(chain.enumerated()), id: \.element.id) { index, ex in
                                        let isCurrent = ex.id == exercise.id
                                        Button {
                                            if !isCurrent { selectedAlternative = ex }
                                        } label: {
                                            HStack(spacing: 4) {
                                                Text(ex.name)
                                                    .font(.system(size: 10, weight: isCurrent ? .bold : .medium))
                                                    .foregroundStyle(isCurrent ? .white : .primary)
                                                    .lineLimit(1)
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(isCurrent ? Color.purple : Color(.tertiarySystemGroupedBackground), in: Capsule())
                                        }
                                        .buttonStyle(.plain)

                                        if index < chain.count - 1 {
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 8))
                                                .foregroundStyle(.quaternary)
                                        }
                                    }
                                }
                            }
                            .scrollIndicators(.hidden)
                        }
                    }

                    let members = library.familyMembers(for: exercise).prefix(6)
                    if !members.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 6) {
                                Image(systemName: "rectangle.stack.fill")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.secondary)
                                Text(L10n.tr("FAMILY MEMBERS"))
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.secondary)
                                    .tracking(0.5)
                                Text("\(members.count)")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundStyle(.tertiary)
                            }

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 6)], spacing: 6) {
                                ForEach(Array(members)) { member in
                                    Button {
                                        selectedAlternative = member
                                    } label: {
                                        HStack(spacing: 8) {
                                            Image(systemName: member.primaryMuscle.symbolName)
                                                .font(.caption2)
                                                .foregroundStyle(.purple)
                                                .frame(width: 24, height: 24)
                                                .background(Color.purple.opacity(0.1), in: .rect(cornerRadius: 6))
                                            VStack(alignment: .leading, spacing: 1) {
                                                Text(member.name)
                                                    .font(.system(size: 11, weight: .medium))
                                                    .foregroundStyle(.primary)
                                                    .lineLimit(1)
                                                Text(member.difficulty.displayName)
                                                    .font(.system(size: 9))
                                                    .foregroundStyle(.tertiary)
                                            }
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 9))
                                                .foregroundStyle(.quaternary)
                                        }
                                        .padding(8)
                                        .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 10))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
            }
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.28), value: appeared)
        }
    }


    private func alternativeCard(_ alt: Exercise, reasonOverride: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: alt.primaryMuscle.symbolName)
                    .font(.title3)
                    .foregroundStyle(.blue)
                    .frame(width: 36, height: 36)
                    .background(Color.blue.opacity(0.1), in: .rect(cornerRadius: 10))
                Spacer()
                HStack(spacing: 2) {
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(i < altDiffLevel(alt) ? altDiffColor(alt) : Color(.separator))
                            .frame(width: 4, height: 4)
                    }
                }
            }

            Text(alt.name)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            HStack(spacing: 4) {
                Text(alt.primaryMuscle.displayName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                if let equip = alt.equipment.first(where: { $0 != .none }) {
                    Circle().fill(Color(.separator)).frame(width: 3, height: 3)
                    Text(equip.displayName)
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                }
            }

            if let reason = reasonOverride {
                Text(reason)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(alternativeReasonColor(reason))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(alternativeReasonColor(reason).opacity(0.1), in: Capsule())
            } else {
                alternativeReasonTag(alt)
            }
        }
        .frame(width: 150)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
    }

    @ViewBuilder
    private var equipmentSection: some View {
        let equips = exercise.equipment.filter { $0 != .none }
        if !equips.isEmpty {
            sectionGroup("Equipment") {
                HStack(spacing: 8) {
                    ForEach(equips) { equip in
                        HStack(spacing: 6) {
                            Image(systemName: "wrench.fill")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                            Text(equip.displayName)
                                .font(.caption.weight(.medium))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.tertiarySystemGroupedBackground), in: Capsule())
                    }
                    Spacer()
                }
            }
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.4), value: appeared)
        }
    }

    private func sectionHeader(_ title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(title)
                .font(.headline)
        }
        .padding(.horizontal, 16)
    }

    private var categoryColor: Color {
        switch exercise.category {
        case .compound: return STRQBrand.steel
        case .isolation: return STRQPalette.info
        case .bodyweight: return STRQPalette.success
        case .cardio: return STRQPalette.danger
        case .mobility: return STRQPalette.info
        case .warmup: return STRQPalette.warning
        case .recovery: return STRQPalette.success
        case .pilates: return STRQBrand.slate
        }
    }

    private var diffColor: Color {
        switch exercise.difficulty {
        case .beginner: STRQPalette.success
        case .intermediate: STRQBrand.steel
        case .advanced: STRQPalette.warning
        }
    }

    private var difficultyIcon: String {
        switch exercise.difficulty {
        case .beginner: "1.circle.fill"
        case .intermediate: "2.circle.fill"
        case .advanced: "3.circle.fill"
        }
    }

    private var categoryIcon: String {
        switch exercise.category {
        case .compound: "circle.grid.cross.fill"
        case .isolation: "scope"
        case .bodyweight: "figure.stand"
        case .cardio: "heart.fill"
        case .mobility: "figure.flexibility"
        case .warmup: "flame.fill"
        case .recovery: "cross.circle.fill"
        case .pilates: "figure.pilates"
        }
    }

    private func plateauColor(_ status: PlateauStatus) -> Color {
        switch status {
        case .progressing: STRQPalette.success
        case .stalling: STRQPalette.warning
        case .plateaued: STRQBrand.steel
        case .regressing: STRQPalette.danger
        }
    }

    private func altDiffLevel(_ ex: Exercise) -> Int {
        switch ex.difficulty {
        case .beginner: 1
        case .intermediate: 2
        case .advanced: 3
        }
    }

    private func altDiffColor(_ ex: Exercise) -> Color {
        switch ex.difficulty {
        case .beginner: STRQPalette.success
        case .intermediate: STRQBrand.steel
        case .advanced: STRQPalette.warning
        }
    }
}

struct ExercisePlanContext {
    let role: ExerciseRole
    let reason: String
    let sets: Int
    let reps: String
    let rpe: Double?
    let dayName: String
}

enum ExerciseRole {
    case keyLift
    case supportLift
    case accessory
    case warmup
    case saferSubstitute

    var displayName: String {
        switch self {
        case .keyLift: "Key Lift"
        case .supportLift: "Support"
        case .accessory: "Accessory"
        case .warmup: "Warm-Up"
        case .saferSubstitute: "Safer Sub"
        }
    }
}
