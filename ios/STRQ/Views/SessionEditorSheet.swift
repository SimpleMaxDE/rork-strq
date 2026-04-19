import SwiftUI

struct SessionEditorSheet: View {
    let vm: AppViewModel
    let dayId: String

    @Environment(\.dismiss) private var dismiss
    @State private var editMode: EditMode = .active
    @State private var showAddExercise: Bool = false
    @State private var editingPlanned: PlannedExercise?
    @State private var swapTarget: PlannedExercise?

    private var day: WorkoutDay? {
        vm.currentPlan?.days.first { $0.id == dayId }
    }

    var body: some View {
        NavigationStack {
            if let day = day {
                content(for: day)
                    .navigationTitle("Edit Session")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Done") { dismiss() }
                                .fontWeight(.semibold)
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showAddExercise = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .environment(\.editMode, $editMode)
                    .sheet(isPresented: $showAddExercise) {
                        AddExerciseSheet(vm: vm) { exercise in
                            vm.addExercise(dayId: dayId, exercise: exercise)
                        }
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                    }
                    .sheet(item: $editingPlanned) { planned in
                        PrescriptionEditSheet(vm: vm, dayId: dayId, planned: planned)
                            .presentationDetents([.medium])
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
                ContentUnavailableView("Session not found", systemImage: "questionmark.folder")
            }
        }
    }

    @ViewBuilder
    private func content(for day: WorkoutDay) -> some View {
        List {
            Section {
                HStack(spacing: 10) {
                    Image(systemName: "square.and.pencil")
                        .font(.subheadline)
                        .foregroundStyle(STRQBrand.steel)
                        .frame(width: 30, height: 30)
                        .background(STRQBrand.steel.opacity(0.12), in: .rect(cornerRadius: 8))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(day.name)
                            .font(.subheadline.weight(.semibold))
                        Text("\(day.exercises.count) exercises · \(day.exercises.reduce(0) { $0 + $1.sets }) sets")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .listRowBackground(Color(.secondarySystemGroupedBackground))
            }

            Section {
                ForEach(Array(day.exercises.enumerated()), id: \.element.id) { index, planned in
                    exerciseRow(planned: planned, index: index)
                }
                .onMove { source, dest in
                    vm.reorderExercises(dayId: dayId, from: source, to: dest)
                }
                .onDelete { offsets in
                    for idx in offsets {
                        if idx < day.exercises.count {
                            vm.removePlannedExercise(dayId: dayId, plannedId: day.exercises[idx].id)
                        }
                    }
                }
            } header: {
                HStack {
                    Text("EXERCISES")
                    Spacer()
                    Text("Drag to reorder · swipe to remove")
                        .font(.system(size: 10))
                        .foregroundStyle(.tertiary)
                        .textCase(.none)
                }
            } footer: {
                Text("Key lifts appear first. Reordering changes session flow but keeps coach intelligence on weight, set, and rep prescription.")
                    .font(.caption)
            }

            Section {
                Button {
                    showAddExercise = true
                } label: {
                    Label("Add Exercise", systemImage: "plus.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(STRQBrand.steel)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    @ViewBuilder
    private func exerciseRow(planned: PlannedExercise, index: Int) -> some View {
        let exercise = vm.library.exercise(byId: planned.exerciseId)
        let isAnchor = exercise?.category == .compound && index < 2
        HStack(spacing: 12) {
            if let ex = exercise {
                ZStack {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(STRQBrand.steel.opacity(0.12))
                        .frame(width: 38, height: 38)
                    Image(systemName: ex.primaryMuscle.symbolName)
                        .font(.subheadline)
                        .foregroundStyle(STRQBrand.steel)
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 5) {
                    Text(exercise?.name ?? planned.exerciseId)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                    if isAnchor {
                        Text("ANCHOR")
                            .font(.system(size: 8, weight: .black))
                            .tracking(0.4)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1.5)
                            .background(STRQBrand.steelGradient, in: Capsule())
                    }
                }
                HStack(spacing: 6) {
                    Text("\(planned.sets) × \(planned.reps)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                    if let rpe = planned.rpe {
                        Text("· RPE \(Int(rpe))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("· \(planned.restSeconds)s")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Menu {
                Button {
                    editingPlanned = planned
                } label: {
                    Label("Edit Sets · Reps · Rest", systemImage: "slider.horizontal.3")
                }
                Button {
                    swapTarget = planned
                } label: {
                    Label("Swap Exercise", systemImage: "arrow.triangle.2.circlepath")
                }
                Divider()
                Button(role: .destructive) {
                    vm.removePlannedExercise(dayId: dayId, plannedId: planned.id)
                } label: {
                    Label("Remove", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            editingPlanned = planned
        }
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

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 12) {
                        if let ex = exercise {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(STRQBrand.steel.opacity(0.12))
                                    .frame(width: 44, height: 44)
                                Image(systemName: ex.primaryMuscle.symbolName)
                                    .font(.body)
                                    .foregroundStyle(STRQBrand.steel)
                            }
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(exercise?.name ?? planned.exerciseId)
                                .font(.subheadline.weight(.semibold))
                            Text(exercise?.primaryMuscle.displayName ?? "")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Sets") {
                    Stepper(value: $sets, in: 1...10) {
                        HStack {
                            Text("Sets")
                            Spacer()
                            Text("\(sets)")
                                .font(.body.monospacedDigit().weight(.semibold))
                                .foregroundStyle(STRQBrand.steel)
                        }
                    }
                }

                Section("Reps") {
                    HStack {
                        Text("Range")
                        Spacer()
                        TextField("8-10", text: $repsText)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.asciiCapable)
                            .foregroundStyle(STRQBrand.steel)
                            .frame(width: 100)
                    }
                    HStack(spacing: 8) {
                        ForEach(["3-5", "6-8", "8-10", "10-12", "12-15", "15-20"], id: \.self) { preset in
                            Button {
                                repsText = preset
                            } label: {
                                Text(preset)
                                    .font(.caption.monospacedDigit().weight(.semibold))
                                    .foregroundStyle(repsText == preset ? .white : .primary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(repsText == preset ? STRQBrand.steel : Color(.tertiarySystemGroupedBackground), in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section("Rest between sets") {
                    Stepper(value: $restSeconds, in: 15...600, step: 15) {
                        HStack {
                            Text("Rest")
                            Spacer()
                            Text(formatRest(restSeconds))
                                .font(.body.monospacedDigit().weight(.semibold))
                                .foregroundStyle(STRQBrand.steel)
                        }
                    }
                    HStack(spacing: 8) {
                        ForEach([60, 90, 120, 180], id: \.self) { preset in
                            Button {
                                restSeconds = preset
                            } label: {
                                Text(formatRest(preset))
                                    .font(.caption.monospacedDigit().weight(.semibold))
                                    .foregroundStyle(restSeconds == preset ? .white : .primary)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(restSeconds == preset ? STRQBrand.steel : Color(.tertiarySystemGroupedBackground), in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Section {
                    Toggle("Target RPE", isOn: $rpeEnabled)
                        .tint(STRQBrand.steel)
                    if rpeEnabled {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("RPE")
                                Spacer()
                                Text(String(format: "%.1f", rpeValue))
                                    .font(.body.monospacedDigit().weight(.semibold))
                                    .foregroundStyle(STRQBrand.steel)
                            }
                            Slider(value: $rpeValue, in: 5...10, step: 0.5)
                                .tint(STRQBrand.steel)
                        }
                    }
                } header: {
                    Text("Target Effort")
                } footer: {
                    Text("RPE 7 = 3 reps in reserve. RPE 9 = 1 rep in reserve. Leave off to let the coach choose.")
                        .font(.caption)
                }
            }
            .navigationTitle("Prescription")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
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

    private func formatRest(_ seconds: Int) -> String {
        if seconds >= 60 {
            let m = seconds / 60
            let s = seconds % 60
            return s == 0 ? "\(m) min" : "\(m):\(String(format: "%02d", s))"
        }
        return "\(seconds)s"
    }
}

// MARK: - Add Exercise Sheet

struct AddExerciseSheet: View {
    let vm: AppViewModel
    let onSelect: (Exercise) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var selectedMuscle: MuscleGroup?

    private let library = ExerciseLibrary.shared

    private var results: [Exercise] {
        var list: [Exercise]
        if !searchText.isEmpty {
            list = library.search(searchText)
        } else if let m = selectedMuscle {
            list = library.filtered(muscle: m, world: nil, difficulty: nil, bodyweightOnly: false, jointFriendly: false)
        } else {
            list = library.exercises
        }
        return list
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
                    HStack(spacing: 8) {
                        Button {
                            selectedMuscle = nil
                        } label: {
                            chipLabel("All", active: selectedMuscle == nil)
                        }
                        ForEach(MuscleGroup.allCases) { muscle in
                            Button {
                                selectedMuscle = selectedMuscle == muscle ? nil : muscle
                            } label: {
                                chipLabel(muscle.displayName, active: selectedMuscle == muscle)
                            }
                        }
                    }
                }
                .contentMargins(.horizontal, 16)
                .scrollIndicators(.hidden)
                .padding(.vertical, 10)

                List {
                    ForEach(grouped, id: \.0) { muscle, exercises in
                        Section(muscle.displayName) {
                            ForEach(exercises) { ex in
                                Button {
                                    onSelect(ex)
                                    dismiss()
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: ex.primaryMuscle.symbolName)
                                            .font(.subheadline)
                                            .foregroundStyle(STRQBrand.steel)
                                            .frame(width: 32, height: 32)
                                            .background(STRQBrand.steel.opacity(0.1), in: .rect(cornerRadius: 8))
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(ex.name)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(.primary)
                                                .lineLimit(1)
                                            HStack(spacing: 6) {
                                                Text(ex.category.displayName)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                if let eq = ex.equipment.first(where: { $0 != .none }) {
                                                    Text("·")
                                                        .font(.caption)
                                                        .foregroundStyle(.tertiary)
                                                    Text(eq.displayName)
                                                        .font(.caption)
                                                        .foregroundStyle(.secondary)
                                                }
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
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .searchable(text: $searchText, prompt: "Search exercises")
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func chipLabel(_ text: String, active: Bool) -> some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundStyle(active ? .white : .primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(active ? STRQBrand.steel : Color(.secondarySystemGroupedBackground), in: Capsule())
    }
}
