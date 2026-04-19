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
                summaryStatsRow
                    .padding(.horizontal, 16)
                    .padding(.top, 18)
                quickInfoStrip
                    .padding(.top, 12)

                // SECTION 1 — TODAY
                sectionGroup("Today") {
                    if let ctx = planContext {
                        planContextCard(ctx)
                    }
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

                // SECTION 2 — EXECUTION
                if !exercise.instructions.isEmpty || !exercise.cues.isEmpty || !exercise.commonMistakes.isEmpty {
                    sectionGroup("Execution") {
                        if !exercise.instructions.isEmpty { instructionsSection }
                        if !exercise.cues.isEmpty { cuesSection }
                        if !exercise.commonMistakes.isEmpty { mistakesSection }
                    }
                }

                // SECTION 3 — TARGET
                sectionGroup("Target") {
                    muscleMapSection
                }

                // SECTION 4 — ALTERNATIVES & PROGRESSION
                sectionGroup("Variations") {
                    progressionChainSection
                    familySection
                    alternativesSection
                    homeAlternativesSection
                    jointFriendlySection
                }

                // SECTION 5 — EQUIPMENT
                equipmentSection
                    .padding(.top, 18)

                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle(exercise.name)
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
                Button("Done") { dismiss() }
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
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(title.uppercased())
                    .font(.system(size: 11, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(.secondary)
                Rectangle()
                    .fill(Color(.separator).opacity(0.5))
                    .frame(height: 0.5)
            }
            .padding(.horizontal, 16)

            VStack(spacing: 10) {
                content()
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 22)
    }

    private var summaryStatsRow: some View {
        HStack(spacing: 0) {
            summaryStatCell(
                value: exercise.difficulty.displayName,
                label: "Difficulty"
            )
            summaryDivider
            summaryStatCell(
                value: exercise.category.displayName,
                label: "Type"
            )
            summaryDivider
            if let last = vm.lastPerformance(for: exercise.id) {
                summaryStatCell(
                    value: "\(formatKg(last.topWeight))×\(last.topReps)",
                    label: "Last"
                )
            } else {
                summaryStatCell(value: "—", label: "Last")
            }
            summaryDivider
            if let prog = progression {
                summaryStatCell(
                    value: "\(prog.sessionCount)",
                    label: "Sessions"
                )
            } else {
                summaryStatCell(value: "0", label: "Sessions")
            }
        }
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
    }

    private func summaryStatCell(value: String, label: String) -> some View {
        VStack(spacing: 3) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label.uppercased())
                .font(.system(size: 9, weight: .bold))
                .tracking(0.6)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 6)
    }

    private var summaryDivider: some View {
        Rectangle()
            .fill(Color(.separator).opacity(0.6))
            .frame(width: 1, height: 24)
    }

    private var emptyTodayPlaceholder: some View {
        HStack(spacing: 10) {
            Image(systemName: "circle.dashed")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Text("Log a set to unlock today's guidance.")
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

    private var quickInfoStrip: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                infoChip(exercise.difficulty.displayName, icon: difficultyIcon, color: diffColor)
                infoChip(exercise.category.displayName, icon: categoryIcon, color: categoryColor)
                infoChip(exercise.movementPattern.displayName, icon: "arrow.triangle.2.circlepath", color: .purple)
                if exercise.isBodyweight {
                    infoChip("Bodyweight", icon: "figure.stand", color: .green)
                }
                if exercise.isJointFriendly {
                    infoChip("Joint-Friendly", icon: "hand.thumbsup.fill", color: .mint)
                }
                if exercise.isBeginnerFriendly {
                    infoChip("Beginner OK", icon: "star.fill", color: .yellow)
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
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
                    .foregroundStyle(.blue)
                Text("IN YOUR PLAN")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.blue)
                    .tracking(0.5)
                Spacer()
                Text(ctx.role.displayName)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.blue.opacity(0.1), in: Capsule())
            }

            Text(ctx.reason)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Label("\(ctx.sets) × \(ctx.reps)", systemImage: "rectangle.stack.fill")
                    .font(.caption.weight(.medium))
                if let rpe = ctx.rpe {
                    Label("RPE \(Int(rpe))", systemImage: "gauge.with.needle.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(STRQBrand.steel)
                }
            }
            .labelStyle(.titleAndIcon)
            .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color.blue.opacity(0.04), in: .rect(cornerRadius: 14))
    }

    private func loadSuggestionCard(_ suggestion: StartingLoadEngine.LoadSuggestion) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "scalemass.fill")
                    .font(.caption)
                    .foregroundStyle(.green)
                Text("SUGGESTED LOAD")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(0.5)
                Spacer()
                Text(suggestion.confidence.label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.green.opacity(0.1), in: Capsule())
            }

            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Weight")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.tertiary)
                    Text(suggestion.formattedWeight)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.green)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Reps")
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
        .background(Color.green.opacity(0.04), in: .rect(cornerRadius: 14))
    }

    private func nextSessionCard(_ g: NextSessionGuidance) -> some View {
        let color = guidanceColorValue(g.color)
        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: g.icon)
                    .font(.caption)
                    .foregroundStyle(color)
                Text("NEXT SESSION")
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
        case "green": return .green
        case "blue": return .blue
        case "orange": return STRQBrand.steel
        case "red": return .red
        case "purple": return .purple
        case "teal": return .teal
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
                Text("PROGRESSION STATUS")
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
                    Text("Last")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.tertiary)
                    Text("\(String(format: "%.1f", prog.lastWeight)) kg × \(prog.lastReps)")
                        .font(.caption.weight(.semibold))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sessions")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.tertiary)
                    Text("\(prog.sessionCount)")
                        .font(.caption.weight(.semibold))
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Strategy")
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
                        Text("PRIMARY")
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
                            Text("SECONDARY")
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
        VStack(alignment: .leading, spacing: 10) {
            subsectionHeader("How to Perform", icon: "list.number")

            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(exercise.instructions.enumerated()), id: \.offset) { index, instruction in
                    HStack(alignment: .top, spacing: 14) {
                        Text("\(index + 1)")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 24, height: 24)
                            .background(categoryColor, in: Circle())

                        Text(instruction)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 10)

                    if index < exercise.instructions.count - 1 {
                        Rectangle()
                            .fill(Color(.separator).opacity(0.3))
                            .frame(width: 1, height: 8)
                            .padding(.leading, 12)
                    }
                }
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)
    }

    private var cuesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            subsectionHeader("Coaching Cues", icon: "checkmark.seal.fill")

            VStack(alignment: .leading, spacing: 8) {
                ForEach(exercise.cues, id: \.self) { cue in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.green)
                        Text(cue)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
    }

    private var mistakesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            subsectionHeader("Common Mistakes", icon: "exclamationmark.triangle.fill")

            VStack(alignment: .leading, spacing: 8) {
                ForEach(exercise.commonMistakes, id: \.self) { mistake in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.subheadline)
                            .foregroundStyle(.red)
                        Text(mistake)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .padding(14)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        }
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
    private var alternativesSection: some View {
        let alts = library.alternatives(for: exercise)
        if !alts.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                subsectionHeader("Alternatives", icon: "arrow.triangle.2.circlepath")

                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(alts) { alt in
                            Button {
                                selectedAlternative = alt
                            } label: {
                                alternativeCard(alt)
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
        case "Same pattern": return .purple
        case "Same target": return .blue
        case "Joint-friendly": return .green
        case "No equipment": return STRQBrand.steel
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
                        progressionRow(reg, label: "Easier", color: .green, icon: "arrow.down.circle.fill")
                    }

                    HStack(spacing: 10) {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundStyle(STRQBrand.steel)
                        Text(exercise.name)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("Current")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(STRQBrand.steel, in: Capsule())
                    }
                    .padding(12)
                    .background(STRQBrand.steel.opacity(0.08), in: .rect(cornerRadius: 12))

                    ForEach(progressions) { prog in
                        progressionRow(prog, label: "Harder", color: .red, icon: "arrow.up.circle.fill")
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
                                Text("PROGRESSION PATH")
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
                                Text("FAMILY MEMBERS")
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

    @ViewBuilder
    private var homeAlternativesSection: some View {
        let homeAlts = library.homeAlternatives(for: exercise)
        if !homeAlts.isEmpty && exercise.locationType == .gym {
            VStack(alignment: .leading, spacing: 10) {
                subsectionHeader("Home Alternatives", icon: "house.fill")

                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(homeAlts) { alt in
                            Button {
                                selectedAlternative = alt
                            } label: {
                                alternativeCard(alt, reasonOverride: "Home option")
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.33), value: appeared)
        }
    }

    @ViewBuilder
    private var jointFriendlySection: some View {
        let jfOptions = library.jointFriendlyOptions(for: exercise)
        if !jfOptions.isEmpty && !exercise.isJointFriendly {
            VStack(alignment: .leading, spacing: 10) {
                subsectionHeader("Joint-Friendly Options", icon: "hand.thumbsup.fill")

                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(jfOptions) { alt in
                            Button {
                                selectedAlternative = alt
                            } label: {
                                alternativeCard(alt, reasonOverride: "Joint-friendly")
                            }
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.5).delay(0.36), value: appeared)
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
        case .isolation: return .blue
        case .bodyweight: return .green
        case .cardio: return .red
        case .mobility: return .teal
        case .warmup: return .yellow
        case .recovery: return .mint
        case .pilates: return .pink
        }
    }

    private var diffColor: Color {
        switch exercise.difficulty {
        case .beginner: .green
        case .intermediate: STRQBrand.steel
        case .advanced: .red
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
        case .progressing: .green
        case .stalling: .yellow
        case .plateaued: STRQBrand.steel
        case .regressing: .red
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
        case .beginner: .green
        case .intermediate: STRQBrand.steel
        case .advanced: .red
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
