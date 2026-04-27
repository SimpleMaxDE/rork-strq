import SwiftUI

struct SessionEditorSheet: View {
    let vm: AppViewModel
    let dayId: String

    @Environment(\.dismiss) private var dismiss
    @State private var showAddExercise: Bool = false
    @State private var editingPlanned: PlannedExercise?
    @State private var swapTarget: PlannedExercise?
    @State private var reorderMode: Bool = false

    private var day: WorkoutDay? {
        vm.currentPlan?.days.first { $0.id == dayId }
    }

    var body: some View {
        NavigationStack {
            if let day = day {
                content(for: day)
                    .navigationTitle(L10n.tr("Edit Workout"))
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button(L10n.tr("Done")) { dismiss() }
                                .fontWeight(.semibold)
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            HStack(spacing: 14) {
                                Button {
                                    withAnimation(.snappy) { reorderMode.toggle() }
                                } label: {
                                    Image(systemName: reorderMode ? "checkmark" : "arrow.up.arrow.down")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(reorderMode ? STRQPalette.success : STRQBrand.steel)
                                }
                                Button {
                                    showAddExercise = true
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.subheadline.weight(.bold))
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $showAddExercise) {
                        AddExerciseSheet(vm: vm, day: day) { exercise in
                            vm.addExercise(dayId: dayId, exercise: exercise)
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                    }
                    .sheet(item: $editingPlanned) { planned in
                        PrescriptionEditSheet(vm: vm, dayId: dayId, planned: planned)
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(.visible)
                    }
                    .sheet(item: $swapTarget) { planned in
                        SwapExerciseSheet(vm: vm, dayId: dayId, exerciseId: planned.exerciseId) { newExercise in
                            vm.applyExerciseSwap(dayId: dayId, oldExerciseId: planned.exerciseId, newExercise: newExercise)
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                    }
            } else {
                ContentUnavailableView(L10n.tr("Workout not found"), systemImage: "questionmark.folder")
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private func content(for day: WorkoutDay) -> some View {
        ScrollView {
            VStack(spacing: 14) {
                headerSummary(day: day)
                    .padding(.horizontal, 16)
                    .padding(.top, 6)

                groupedRows(day: day)
                    .padding(.horizontal, 16)

                Button {
                    showAddExercise = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.subheadline.weight(.semibold))
                        Text(L10n.tr("Add Exercise"))
                            .font(.subheadline.weight(.bold))
                    }
                    .foregroundStyle(STRQBrand.steel)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(STRQBrand.steel.opacity(0.08), in: .rect(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(STRQBrand.steel.opacity(0.2), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    )
                }
                .buttonStyle(.strqPressable)
                .padding(.horizontal, 16)
                .padding(.top, 4)
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Header Summary

    private func headerSummary(day: WorkoutDay) -> some View {
        let counts = roleCounts(day: day)
        let totalSets = day.exercises.reduce(0) { $0 + $1.sets }
        return VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(day.name)
                        .font(.headline)
                        .lineLimit(1)
                    Text(L10n.format("%d exercises · %d sets · ~%dm", day.exercises.count, totalSets, day.estimatedMinutes))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .monospacedDigit()
                }
                Spacer()
            }

            HStack(spacing: 6) {
                if counts.key > 0 { roleSummaryChip(label: L10n.format("%d key", counts.key), color: .primary, bg: STRQBrand.steel.opacity(0.18)) }
                if counts.support > 0 { roleSummaryChip(label: L10n.format("%d support", counts.support), color: STRQPalette.info, bg: STRQPalette.info.opacity(0.12)) }
                if counts.accessory > 0 { roleSummaryChip(label: L10n.format("%d accessory", counts.accessory), color: STRQBrand.steel, bg: STRQBrand.steel.opacity(0.12)) }
                if counts.warm > 0 { roleSummaryChip(label: L10n.format("%d warm-up", counts.warm), color: STRQPalette.warning, bg: STRQPalette.warning.opacity(0.12)) }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private func roleSummaryChip(label: String, color: Color, bg: Color) -> some View {
        Text(label)
            .font(.system(size: 10, weight: .bold))
            .tracking(0.3)
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(bg, in: Capsule())
    }

    // MARK: - Grouped Rows

    @ViewBuilder
    private func groupedRows(day: WorkoutDay) -> some View {
        let groups = roleGroups(day: day)
        VStack(spacing: 14) {
            ForEach(groups, id: \.title) { group in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 1.5)
                            .fill(group.color)
                            .frame(width: 3, height: 11)
                        Text(group.title.uppercased())
                            .font(.system(size: 10, weight: .black))
                            .tracking(0.8)
                            .foregroundStyle(group.color == .white ? Color.primary : group.color)
                        Spacer()
                        Text(L10n.format("%d · %d sets", group.items.count, group.totalSets))
                            .font(.system(size: 10, weight: .semibold).monospacedDigit())
                            .foregroundStyle(.tertiary)
                    }
                    .padding(.horizontal, 2)

                    VStack(spacing: 5) {
                        ForEach(group.items, id: \.planned.id) { item in
                            builderRow(planned: item.planned, index: item.index, role: item.role, day: day)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Builder Row

    @ViewBuilder
    private func builderRow(planned: PlannedExercise, index: Int, role: ExerciseRole, day: WorkoutDay) -> some View {
        let exercise = vm.library.exercise(byId: planned.exerciseId)
        let isCustom = planned.isCustomized
        let hasCoachNote = !planned.notes.isEmpty && planned.notes.hasPrefix("Coach:")

        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Rectangle()
                    .fill(roleAccent(role))
                    .frame(width: 2.5)
                    .frame(maxHeight: .infinity)

                Text("\(index + 1)")
                    .font(.system(size: 12, weight: .black, design: .rounded).monospacedDigit())
                    .foregroundStyle(role == .keyLift ? .primary : .secondary)
                    .frame(width: 18, alignment: .leading)
                    .padding(.leading, 6)

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 5) {
                        Text(exercise?.name ?? planned.exerciseId)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                        if hasCoachNote {
                            Image(systemName: "brain.head.profile.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(STRQBrand.steel)
                        }
                        if isCustom {
                            Text(L10n.tr("CUSTOM"))
                                .font(.system(size: 7, weight: .black))
                                .tracking(0.4)
                                .foregroundStyle(STRQPalette.warning)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1.5)
                                .background(STRQPalette.warning.opacity(0.14), in: Capsule())
                        }
                    }

                    HStack(spacing: 5) {
                        Text("\(planned.sets)×\(planned.reps)")
                            .font(.system(size: 11, weight: .bold).monospacedDigit())
                            .foregroundStyle(.primary)
                        Text("·")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Text(formatRestShort(planned.restSeconds))
                            .font(.system(size: 10, weight: .medium).monospacedDigit())
                            .foregroundStyle(.secondary)
                        if let rpe = planned.rpe {
                            Text("·")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                            Text("RPE\(Int(rpe))")
                                .font(.system(size: 10, weight: .bold).monospacedDigit())
                                .foregroundStyle(STRQBrand.steel)
                        }
                    }
                }

                Spacer(minLength: 4)

                if reorderMode {
                    VStack(spacing: 2) {
                        Button {
                            withAnimation(.snappy) {
                                vm.reorderExercises(dayId: dayId, from: IndexSet(integer: index), to: max(0, index - 1))
                            }
                        } label: {
                            Image(systemName: "chevron.up")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(index > 0 ? STRQBrand.steel : Color.gray.opacity(0.3))
                                .frame(width: 30, height: 18)
                                .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 5))
                        }
                        .disabled(index == 0)
                        Button {
                            withAnimation(.snappy) {
                                vm.reorderExercises(dayId: dayId, from: IndexSet(integer: index), to: index + 2)
                            }
                        } label: {
                            Image(systemName: "chevron.down")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(index < day.exercises.count - 1 ? STRQBrand.steel : Color.gray.opacity(0.3))
                                .frame(width: 30, height: 18)
                                .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 5))
                        }
                        .disabled(index >= day.exercises.count - 1)
                    }
                    .padding(.trailing, 8)
                } else {
                    HStack(spacing: 6) {
                        inlineActionButton(icon: "slider.horizontal.3", color: STRQBrand.steel) {
                            editingPlanned = planned
                        }
                        inlineActionButton(icon: "arrow.triangle.2.circlepath", color: STRQPalette.info) {
                            swapTarget = planned
                        }
                    }
                    .padding(.trailing, 8)
                }
            }
            .padding(.vertical, 8)
        }
        .frame(minHeight: 52)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(isCustom ? STRQPalette.warning.opacity(0.25) : STRQBrand.cardBorder, lineWidth: 1)
        )
        .contextMenu {
            Button { editingPlanned = planned } label: { Label(L10n.tr("Edit Prescription"), systemImage: "slider.horizontal.3") }
            Button { swapTarget = planned } label: { Label(L10n.tr("Swap Exercise"), systemImage: "arrow.triangle.2.circlepath") }
            if isCustom {
                Button {
                    vm.restoreCoachDefault(dayId: dayId, plannedId: planned.id)
                } label: { Label(L10n.tr("Restore Coach Default"), systemImage: "arrow.uturn.backward") }
            }
            Divider()
            Button(role: .destructive) {
                vm.removePlannedExercise(dayId: dayId, plannedId: planned.id)
            } label: { Label(L10n.tr("Remove"), systemImage: "trash") }
        }
    }

    private func inlineActionButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12), in: .rect(cornerRadius: 8))
        }
        .buttonStyle(.strqPressable)
    }

    // MARK: - Helpers

    private struct BuilderGroup {
        let title: String
        let color: Color
        let items: [(planned: PlannedExercise, index: Int, role: ExerciseRole)]
        var totalSets: Int { items.reduce(0) { $0 + $1.planned.sets } }
    }

    private func roleGroups(day: WorkoutDay) -> [BuilderGroup] {
        var key: [(planned: PlannedExercise, index: Int, role: ExerciseRole)] = []
        var support: [(planned: PlannedExercise, index: Int, role: ExerciseRole)] = []
        var accessory: [(planned: PlannedExercise, index: Int, role: ExerciseRole)] = []
        var warm: [(planned: PlannedExercise, index: Int, role: ExerciseRole)] = []
        for (idx, pe) in day.exercises.enumerated() {
            let role = classifyRole(pe, index: idx, day: day)
            let entry = (planned: pe, index: idx, role: role)
            switch role {
            case .keyLift: key.append(entry)
            case .supportLift: support.append(entry)
            case .accessory, .saferSubstitute: accessory.append(entry)
            case .warmup: warm.append(entry)
            }
        }
        var out: [BuilderGroup] = []
        if !warm.isEmpty { out.append(BuilderGroup(title: L10n.tr("Warm-Up"), color: STRQPalette.warning, items: warm)) }
        if !key.isEmpty { out.append(BuilderGroup(title: L10n.tr("Key Lifts"), color: .white, items: key)) }
        if !support.isEmpty { out.append(BuilderGroup(title: L10n.tr("Support"), color: STRQPalette.info, items: support)) }
        if !accessory.isEmpty { out.append(BuilderGroup(title: L10n.tr("Accessory"), color: STRQBrand.steel, items: accessory)) }
        return out
    }

    private func classifyRole(_ planned: PlannedExercise, index: Int, day: WorkoutDay) -> ExerciseRole {
        guard let exercise = vm.library.exercise(byId: planned.exerciseId) else { return .accessory }
        if exercise.category == .warmup || exercise.category == .mobility { return .warmup }
        if exercise.category == .compound && index < 2 { return .keyLift }
        if exercise.category == .compound { return .supportLift }
        return .accessory
    }

    private func roleAccent(_ role: ExerciseRole) -> Color {
        switch role {
        case .keyLift: .white
        case .supportLift: STRQPalette.info
        case .accessory: STRQBrand.steel
        case .warmup: STRQPalette.warning
        case .saferSubstitute: STRQPalette.success
        }
    }

    private func roleCounts(day: WorkoutDay) -> (key: Int, support: Int, accessory: Int, warm: Int) {
        var k = 0, s = 0, a = 0, w = 0
        for (idx, pe) in day.exercises.enumerated() {
            let r = classifyRole(pe, index: idx, day: day)
            switch r {
            case .keyLift: k += 1
            case .supportLift: s += 1
            case .accessory, .saferSubstitute: a += 1
            case .warmup: w += 1
            }
        }
        return (k, s, a, w)
    }

    private func formatRestShort(_ seconds: Int) -> String {
        if seconds >= 60 {
            let m = seconds / 60
            let s = seconds % 60
            return s == 0 ? "\(m)m" : "\(m):\(String(format: "%02d", s))"
        }
        return "\(seconds)s"
    }
}

// MARK: - Prescription Edit Sheet

struct PrescriptionEditSheet: View {
    let vm: AppViewModel
    let dayId: String
    let planned: PlannedExercise

    @Environment(\.dismiss) private var dismiss
    @State private var sets: Int = 3
    @State private var repsText: String = "8-10"
    @State private var restSeconds: Int = 90
    @State private var rpeValue: Double = 8.0
    @State private var rpeEnabled: Bool = true

    private var exercise: Exercise? {
        vm.library.exercise(byId: planned.exerciseId)
    }

    private var coachDefault: CoachDefault? { planned.coachDefault }

    private var isCustom: Bool {
        guard let cd = coachDefault else { return false }
        let currentRPE: Double? = rpeEnabled ? rpeValue : nil
        return cd.sets != sets || cd.reps != repsText || cd.restSeconds != restSeconds || cd.rpe != currentRPE
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    headerCard
                    if isCustom, coachDefault != nil {
                        restoreBanner
                    }
                    setsCard
                    repsCard
                    restCard
                    rpeCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(L10n.tr("Prescription"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(L10n.tr("Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.tr("Save")) {
                        vm.updatePrescription(
                            dayId: dayId,
                            plannedId: planned.id,
                            sets: sets,
                            reps: repsText,
                            restSeconds: restSeconds,
                            rpe: .some(rpeEnabled ? rpeValue : nil)
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                sets = planned.sets
                repsText = planned.reps
                restSeconds = planned.restSeconds
                if let r = planned.rpe {
                    rpeValue = r
                    rpeEnabled = true
                } else {
                    rpeEnabled = false
                }
            }
        }
    }

    private var headerCard: some View {
        HStack(spacing: 12) {
            if let ex = exercise {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(STRQBrand.steel.opacity(0.14))
                        .frame(width: 42, height: 42)
                    Image(systemName: ex.primaryMuscle.symbolName)
                        .font(.subheadline)
                        .foregroundStyle(STRQBrand.steel)
                }
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(exercise?.name ?? planned.exerciseId)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                HStack(spacing: 5) {
                    Text(exercise?.primaryMuscle.localizedDisplayName ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if isCustom {
                        Text(L10n.tr("CUSTOM"))
                            .font(.system(size: 8, weight: .black))
                            .tracking(0.4)
                            .foregroundStyle(STRQPalette.warning)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background(STRQPalette.warning.opacity(0.14), in: Capsule())
                    } else if coachDefault != nil {
                        Text(L10n.tr("COACH DEFAULT"))
                            .font(.system(size: 8, weight: .black))
                            .tracking(0.4)
                            .foregroundStyle(STRQBrand.steel)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background(STRQBrand.steel.opacity(0.12), in: Capsule())
                    }
                }
            }
            Spacer()
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
    }

    private var restoreBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "arrow.uturn.backward.circle.fill")
                .font(.subheadline)
                .foregroundStyle(STRQPalette.warning)
            VStack(alignment: .leading, spacing: 1) {
                Text(L10n.tr("Customized from coach default"))
                    .font(.caption.weight(.semibold))
                if let cd = coachDefault {
                    let previousPrescription = "\(cd.sets)×\(cd.reps) · \(formatRest(cd.restSeconds))\(cd.rpe.map { " · RPE\(Int($0))" } ?? "")"
                    Text(L10n.format("Was %@", previousPrescription))
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button {
                if let cd = coachDefault {
                    withAnimation(.snappy) {
                        sets = cd.sets
                        repsText = cd.reps
                        restSeconds = cd.restSeconds
                        if let r = cd.rpe {
                            rpeValue = r
                            rpeEnabled = true
                        } else {
                            rpeEnabled = false
                        }
                    }
                }
            } label: {
                Text(L10n.tr("Restore"))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(STRQPalette.warning, in: Capsule())
            }
            .buttonStyle(.strqPressable)
        }
        .padding(12)
        .background(STRQPalette.warning.opacity(0.08), in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(STRQPalette.warning.opacity(0.25), lineWidth: 1)
        )
    }

    private var setsCard: some View {
        builderCard(title: L10n.tr("SETS"), trailing: "\(sets)") {
            HStack(spacing: 6) {
                ForEach([1, 2, 3, 4, 5, 6], id: \.self) { n in
                    Button {
                        withAnimation(STRQMotion.tap) { sets = n }
                    } label: {
                        Text("\(n)")
                            .font(.system(size: 14, weight: .bold).monospacedDigit())
                            .foregroundStyle(sets == n ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 38)
                            .background(sets == n ? STRQBrand.steel : Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 9))
                    }
                    .buttonStyle(.strqPressable)
                    .sensoryFeedback(.selection, trigger: sets)
                }
            }
        }
    }

    private var repsCard: some View {
        builderCard(title: L10n.tr("REPS"), trailing: repsText) {
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    ForEach(["3-5", "6-8", "8-10", "10-12"], id: \.self) { preset in
                        repsPresetButton(preset)
                    }
                }
                HStack(spacing: 6) {
                    ForEach(["12-15", "15-20", "AMRAP"], id: \.self) { preset in
                        repsPresetButton(preset)
                    }
                    TextField(L10n.tr("Custom"), text: $repsText)
                        .multilineTextAlignment(.center)
                        .keyboardType(.asciiCapable)
                        .font(.system(size: 12, weight: .semibold).monospacedDigit())
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 9))
                }
            }
        }
    }

    private func repsPresetButton(_ preset: String) -> some View {
        Button {
            withAnimation(STRQMotion.tap) { repsText = preset }
        } label: {
            Text(preset)
                .font(.system(size: 12, weight: .bold).monospacedDigit())
                .foregroundStyle(repsText == preset ? .white : .primary)
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background(repsText == preset ? STRQBrand.steel : Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 9))
        }
        .buttonStyle(.strqPressable)
        .sensoryFeedback(.selection, trigger: repsText)
    }

    private var restCard: some View {
        builderCard(title: L10n.tr("REST"), trailing: formatRest(restSeconds)) {
            HStack(spacing: 6) {
                ForEach([45, 60, 90, 120, 180, 240], id: \.self) { preset in
                    Button {
                        withAnimation(STRQMotion.tap) { restSeconds = preset }
                    } label: {
                        Text(formatRestShort(preset))
                            .font(.system(size: 12, weight: .bold).monospacedDigit())
                            .foregroundStyle(restSeconds == preset ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 34)
                            .background(restSeconds == preset ? STRQBrand.steel : Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 9))
                    }
                    .buttonStyle(.strqPressable)
                    .sensoryFeedback(.selection, trigger: restSeconds)
                }
            }
        }
    }

    private var rpeCard: some View {
        builderCard(title: L10n.tr("EFFORT"), trailing: rpeEnabled ? "RPE \(String(format: "%.1f", rpeValue))" : "Coach") {
            VStack(spacing: 10) {
                Toggle(L10n.tr("Target RPE"), isOn: $rpeEnabled)
                    .tint(STRQBrand.steel)
                    .font(.caption.weight(.semibold))
                if rpeEnabled {
                    Slider(value: $rpeValue, in: 5...10, step: 0.5)
                        .tint(STRQBrand.steel)
                    Text(L10n.tr("RPE 7 = 3 in reserve · RPE 9 = 1 in reserve"))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }

    private func builderCard<Content: View>(title: String, trailing: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.system(size: 10, weight: .black))
                    .tracking(0.8)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(trailing)
                    .font(.system(size: 13, weight: .bold).monospacedDigit())
                    .foregroundStyle(STRQBrand.steel)
            }
            content()
        }
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
    }

    private func formatRest(_ seconds: Int) -> String {
        if seconds >= 60 {
            let m = seconds / 60
            let s = seconds % 60
            return s == 0 ? "\(m) min" : "\(m):\(String(format: "%02d", s))"
        }
        return "\(seconds)s"
    }

    private func formatRestShort(_ seconds: Int) -> String {
        if seconds >= 60 {
            let m = seconds / 60
            let s = seconds % 60
            return s == 0 ? "\(m)m" : "\(m):\(String(format: "%02d", s))"
        }
        return "\(seconds)s"
    }
}

// MARK: - Add Exercise Sheet

struct AddExerciseSheet: View {
    let vm: AppViewModel
    let day: WorkoutDay?
    let onSelect: (Exercise) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var selectedMuscle: MuscleGroup?

    private let library = ExerciseLibrary.shared
    private let catalog = ExerciseCatalog.shared

    init(vm: AppViewModel, day: WorkoutDay? = nil, onSelect: @escaping (Exercise) -> Void) {
        self.vm = vm
        self.day = day
        self.onSelect = onSelect
    }

    private var results: [Exercise] {
        var list: [Exercise]
        if !searchText.isEmpty {
            list = catalog.search(searchText)
        } else if let m = selectedMuscle {
            list = catalog.exercises(forMuscle: m)
        } else {
            list = catalog.all
        }
        return list
    }

    private var contextualPicks: [Exercise] {
        guard searchText.isEmpty, selectedMuscle == nil, let day = day else { return [] }
        let focusMuscles = Set(day.focusMuscles)
        let existingIds = Set(day.exercises.map(\.exerciseId))
        let existingMuscles = Set(day.exercises.compactMap { vm.library.exercise(byId: $0.exerciseId)?.primaryMuscle })
        let missingFocus = focusMuscles.subtracting(existingMuscles)

        let matches = library.exercises.filter { ex in
            guard !existingIds.contains(ex.id) else { return false }
            return focusMuscles.contains(ex.primaryMuscle) || !missingFocus.isDisjoint(with: Set([ex.primaryMuscle]))
        }

        func score(_ ex: Exercise) -> Double {
            var s: Double = 0
            if missingFocus.contains(ex.primaryMuscle) { s += 10 }
            if focusMuscles.contains(ex.primaryMuscle) { s += 5 }
            if ex.category == .compound { s += 2 }
            if day.exercises.count < 3 && ex.category == .compound { s += 3 }
            return s
        }

        return Array(matches.sorted { score($0) > score($1) }.prefix(6))
    }

    private var grouped: [(MuscleGroup, [Exercise])] {
        let d = Dictionary(grouping: results) { $0.primaryMuscle }
        return MuscleGroup.allCases.compactMap { m in
            guard let arr = d[m], !arr.isEmpty else { return nil }
            return (m, arr)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(.horizontal) {
                    HStack(spacing: 6) {
                        Button {
                            selectedMuscle = nil
                        } label: {
                            chipLabel(L10n.tr("All"), active: selectedMuscle == nil)
                        }
                        ForEach(MuscleGroup.allCases) { muscle in
                            Button {
                                selectedMuscle = selectedMuscle == muscle ? nil : muscle
                            } label: {
                            chipLabel(muscle.localizedDisplayName, active: selectedMuscle == muscle)
                            }
                        }
                    }
                }
                .contentMargins(.horizontal, 16)
                .scrollIndicators(.hidden)
                .padding(.vertical, 8)

                List {
                    if !contextualPicks.isEmpty {
                        Section {
                            ForEach(contextualPicks) { ex in
                                contextualRow(ex)
                            }
                        } header: {
                            HStack(spacing: 5) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 10))
                                    .foregroundStyle(STRQBrand.steel)
                                Text(L10n.tr("Fits this workout"))
                            }
                        } footer: {
                            Text(L10n.tr("Suggestions based on this workout's focus muscles and gaps."))
                                .font(.caption2)
                        }
                    }

                    ForEach(grouped, id: \.0) { muscle, exercises in
                        Section(muscle.localizedDisplayName) {
                            ForEach(exercises) { ex in
                                resultRow(ex)
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .searchable(text: $searchText, prompt: L10n.tr("Search exercises"))
            .navigationTitle(L10n.tr("Add Exercise"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.tr("Cancel")) { dismiss() }
                }
            }
        }
    }

    private func contextualRow(_ ex: Exercise) -> some View {
        let focus = Set(day?.focusMuscles ?? [])
        let existing = Set((day?.exercises ?? []).compactMap { vm.library.exercise(byId: $0.exerciseId)?.primaryMuscle })
        let isMissing = focus.contains(ex.primaryMuscle) && !existing.contains(ex.primaryMuscle)
        let hint: String = isMissing
            ? L10n.format("Fills %@ gap", ex.primaryMuscle.localizedDisplayName)
            : L10n.format("Matches %@ focus", ex.primaryMuscle.localizedDisplayName)
        let hintColor: Color = isMissing ? STRQPalette.warning : STRQPalette.success

        return Button {
            onSelect(ex)
            dismiss()
        } label: {
            HStack(spacing: 11) {
                ExerciseThumbnail(exercise: ex, size: .small, cornerRadius: 8)
                VStack(alignment: .leading, spacing: 2) {
                    Text(ex.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    HStack(spacing: 4) {
                        Text(hint)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(hintColor)
                        Text("·")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        Text(ex.category.displayName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.body)
                    .foregroundStyle(STRQBrand.steel)
            }
        }
        .buttonStyle(.plain)
    }

    private func resultRow(_ ex: Exercise) -> some View {
        Button {
            onSelect(ex)
            dismiss()
        } label: {
            HStack(spacing: 11) {
                ExerciseThumbnail(exercise: ex, size: .small, cornerRadius: 8)
                VStack(alignment: .leading, spacing: 2) {
                    Text(ex.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    HStack(spacing: 5) {
                        Text(ex.category.displayName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        if let eq = ex.equipment.first(where: { $0 != .none }) {
                            Text("·")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                            Text(eq.displayName)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.subheadline)
                    .foregroundStyle(STRQBrand.steel)
            }
        }
        .buttonStyle(.plain)
    }

    private func chipLabel(_ text: String, active: Bool) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(active ? .white : .primary)
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(active ? STRQBrand.steel : Color(.secondarySystemGroupedBackground), in: Capsule())
    }
}
