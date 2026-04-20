import SwiftUI

struct TrainingPlanView: View {
    let vm: AppViewModel
    @State private var selectedDayIndex: Int = 0
    @State private var showExerciseDetail: Exercise?
    @State private var exerciseDetailContext: ExercisePlanContext?
    @State private var showLibrary: Bool = false
    @State private var appeared: Bool = false
    @State private var showScheduleEditor: Bool = false
    @State private var selectedPrescriptionIndex: Int?
    @State private var showSessionEditor: Bool = false
    @State private var swapTargetPlanned: PlannedExercise?

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if let plan = vm.currentPlan {
                    weekCalendarHeader(plan)
                        .padding(.top, 4)
                    daySelector(plan)
                    dayContent(plan)
                } else {
                    emptyPlanState
                }
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Train")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    if let plan = vm.currentPlan, selectedDayIndex < plan.days.count {
                        Button {
                            showSessionEditor = true
                        } label: {
                            Label("Edit Session", systemImage: "slider.horizontal.3")
                        }
                    }
                    Button {
                        showScheduleEditor = true
                    } label: {
                        Label("Schedule", systemImage: "calendar.badge.clock")
                    }
                    Button {
                        showLibrary = true
                    } label: {
                        Label("Exercise Library", systemImage: "books.vertical.fill")
                    }
                    Divider()
                    Button {
                        vm.generatePlan()
                    } label: {
                        Label("Regenerate Plan", systemImage: "arrow.triangle.2.circlepath")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle").font(.body)
                }
            }
        }
        .sheet(item: $showExerciseDetail) { exercise in
            NavigationStack {
                ExerciseDetailView(exercise: exercise, vm: vm, planContext: exerciseDetailContext)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showLibrary) {
            NavigationStack {
                ExerciseLibraryView(vm: vm)
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showSessionEditor) {
            if let plan = vm.currentPlan, selectedDayIndex < plan.days.count {
                SessionEditorSheet(vm: vm, dayId: plan.days[selectedDayIndex].id)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
        }
        .sheet(isPresented: $showScheduleEditor) {
            ScheduleEditorSheet(vm: vm)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
        }
        .sheet(item: $swapTargetPlanned) { planned in
            if let plan = vm.currentPlan, selectedDayIndex < plan.days.count {
                let dayId = plan.days[selectedDayIndex].id
                SwapExerciseSheet(vm: vm, dayId: dayId, exerciseId: planned.exerciseId) { newExercise in
                    vm.applyExerciseSwap(dayId: dayId, oldExerciseId: planned.exerciseId, newExercise: newExercise)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
        .sheet(item: $selectedPrescriptionIndex) { index in
            if let plan = vm.currentPlan, selectedDayIndex < plan.days.count {
                let day = plan.days[selectedDayIndex]
                if index < day.exercises.count {
                    let planned = day.exercises[index]
                    let prescription = vm.exercisePrescription(for: planned, in: day, index: index)
                    NavigationStack {
                        ExercisePrescriptionSheet(
                            exercise: vm.library.exercise(byId: planned.exerciseId),
                            planned: planned,
                            prescription: prescription,
                            vm: vm
                        )
                    }
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationContentInteraction(.scrolls)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            if let plan = vm.currentPlan {
                autoSelectToday(plan)
            }
            Analytics.shared.track(.train_viewed)
        }
    }

    // MARK: - Week Calendar Header

    @ViewBuilder
    private func weekCalendarHeader(_ plan: WorkoutPlan) -> some View {
        if plan.days.contains(where: { $0.scheduledWeekday != nil }) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    ForEach(1...7, id: \.self) { weekday in
                        let matchingDay = plan.days.first { $0.scheduledWeekday == weekday && !$0.isSkipped }
                        let isToday = Calendar.current.component(.weekday, from: Date()) == weekday
                        let matchingIndex = matchingDay.flatMap { d in plan.days.firstIndex(where: { $0.id == d.id }) }

                        Button {
                            if let idx = matchingIndex {
                                withAnimation(.snappy(duration: 0.3)) { selectedDayIndex = idx }
                            }
                        } label: {
                            VStack(spacing: 5) {
                                Text(vm.weekdayName(weekday))
                                    .font(.system(size: 10, weight: isToday ? .bold : .medium))
                                    .foregroundStyle(isToday ? Color.white : Color.secondary)

                                ZStack {
                                    if isToday {
                                        Circle()
                                            .fill(matchingDay != nil ? Color.white : Color.white.opacity(0.15))
                                            .frame(width: 32, height: 32)
                                    } else if matchingDay != nil {
                                        Circle()
                                            .fill(matchingIndex == selectedDayIndex ? STRQBrand.steel : STRQBrand.steel.opacity(0.3))
                                            .frame(width: 32, height: 32)
                                    } else {
                                        Circle()
                                            .fill(Color.white.opacity(0.04))
                                            .frame(width: 32, height: 32)
                                    }

                                    if matchingDay != nil {
                                        Image(systemName: "figure.strengthtraining.traditional")
                                            .font(.system(size: 11, weight: .medium))
                                            .foregroundStyle(isToday ? .black : .white)
                                    }
                                }

                                if let day = matchingDay {
                                    Text(shortDayName(day.name))
                                        .font(.system(size: 8, weight: .medium))
                                        .foregroundStyle(matchingIndex == selectedDayIndex ? STRQBrand.steel : Color.gray)
                                        .lineLimit(1)
                                } else {
                                    Color.clear.frame(height: 10)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .disabled(matchingDay == nil)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
            }
            .padding(.horizontal, 16)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
            .padding(.horizontal, 16)
            .opacity(appeared ? 1 : 0)
            .animation(.easeOut(duration: 0.4), value: appeared)
        }
    }

    // MARK: - Day Selector

    @ViewBuilder
    private func daySelector(_ plan: WorkoutPlan) -> some View {
        ScrollView(.horizontal) {
            HStack(spacing: 6) {
                ForEach(Array(plan.days.enumerated()), id: \.element.id) { index, day in
                    daySelectorPill(index: index, day: day)
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .scrollIndicators(.hidden)
        .padding(.top, 12)
    }

    private func daySelectorPill(index: Int, day: WorkoutDay) -> some View {
        let isSelected = selectedDayIndex == index
        let hasAdj = vm.hasAdjustment(for: day.id)
        let isSkipped = day.isSkipped
        return Button {
            withAnimation(.snappy(duration: 0.3)) { selectedDayIndex = index }
        } label: {
            VStack(spacing: 3) {
                if let wd = day.scheduledWeekday {
                    Text(vm.weekdayName(wd).uppercased())
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(isSelected ? Color.white.opacity(0.6) : STRQBrand.steel)
                        .tracking(0.3)
                } else {
                    Text("DAY \(index + 1)")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(isSelected ? Color.white.opacity(0.6) : Color.secondary)
                        .tracking(0.3)
                }
                Text(shortDayName(day.name))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.white : isSkipped ? Color.secondary : Color.primary)
                    .lineLimit(1)
                if isSkipped {
                    Text("Skipped")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundStyle(STRQPalette.danger.opacity(0.8))
                } else if hasAdj {
                    Image(systemName: "brain.head.profile.fill")
                        .font(.system(size: 8))
                        .foregroundStyle(isSelected ? Color.white.opacity(0.7) : STRQBrand.steel)
                } else {
                    Text("~\(day.estimatedMinutes)m")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(isSelected ? Color.white.opacity(0.6) : Color.secondary)
                }
            }
            .frame(width: 74, height: 66)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(STRQBrand.steelGradient)
                        .shadow(color: STRQBrand.steel.opacity(0.2), radius: 8, y: 2)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemGroupedBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
                        )
                }
            }
            .opacity(isSkipped ? 0.6 : 1)
        }
        .sensoryFeedback(.selection, trigger: selectedDayIndex)
    }

    // MARK: - Day Content

    @ViewBuilder
    private func dayContent(_ plan: WorkoutPlan) -> some View {
        if selectedDayIndex < plan.days.count {
            let day = plan.days[selectedDayIndex]
            let briefing = vm.sessionBriefing(for: day)

            VStack(spacing: 14) {
                missionCard(day: day, briefing: briefing)
                    .padding(.horizontal, 16)

                scheduleControlRow(day: day)
                    .padding(.horizontal, 16)

                if let weekAdj = vm.weekAdjustment {
                    weekAdjBanner(weekAdj)
                        .padding(.horizontal, 16)
                } else if let adj = vm.adjustment(for: day.id) {
                    coachBanner(adj)
                        .padding(.horizontal, 16)
                }

                exerciseStack(day: day)
                    .padding(.horizontal, 16)

                if let outlook = vm.phaseOutlook {
                    PhaseOutlookCard(outlook: outlook, style: .compact)
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                }

                if !day.isSkipped {
                    ForgePrimaryButton(icon: "bolt.fill", title: "Review & Start") {
                        vm.prepareWorkoutHandoff(day: day)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 6)
                }
            }
            .padding(.top, 20)
        }
    }

    // MARK: - Mission Card

    private func missionCard(day: WorkoutDay, briefing: SessionBriefing) -> some View {
        ZStack(alignment: .topLeading) {
            Canvas { context, size in
                for i in 0..<3 {
                    let xF: [CGFloat] = [0.15, 0.7, 0.9]
                    let yF: [CGFloat] = [0.3, 0.7, 0.2]
                    let radius = CGFloat(70 + i * 25)
                    let circle = Path(ellipseIn: CGRect(
                        x: xF[i] * size.width - radius,
                        y: yF[i] * size.height - radius,
                        width: radius * 2, height: radius * 2
                    ))
                    context.fill(circle, with: .color(.white.opacity(0.025)))
                }
            }
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Text(vm.currentPhase.displayName.uppercased())
                        .font(.system(size: 9, weight: .black))
                        .tracking(1.2)
                        .foregroundStyle(STRQBrand.steel)
                    Spacer()
                    if let wd = day.scheduledWeekday {
                        Text(vm.fullWeekdayName(wd).uppercased())
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.2)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }

                Text(day.name)
                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if !vm.isEarlyStage {
                    Text(briefing.dayExplanation)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(2)
                }

                HStack(spacing: 0) {
                    ForgeStatCell(value: "\(briefing.exerciseCount)", label: "Exercises")
                    ForgeStatCell(value: "\(briefing.totalSets)", label: "Sets")
                    ForgeStatCell(value: "~\(briefing.estimatedMinutes)m", label: "Time")
                    ForgeStatCell(value: briefing.intensityLabel, label: "Effort", valueColor: STRQBrand.steel)
                }
                .padding(.top, 2)
            }
            .padding(14)
        }
        .background(
            LinearGradient(
                colors: [Color(white: 0.17), Color(white: 0.09)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 22)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
        .overlay(alignment: .top) {
            STRQBrand.accentGradient
                .frame(height: 3)
                .clipShape(.rect(cornerRadii: .init(topLeading: 22, bottomLeading: 0, bottomTrailing: 0, topTrailing: 22)))
        }
        .shadow(color: .black.opacity(0.25), radius: 18, y: 6)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.05), value: appeared)
    }

    // MARK: - Exercise Stack

    private func exerciseStack(day: WorkoutDay) -> some View {
        let groups = groupedByRole(day: day)
        return VStack(alignment: .leading, spacing: 14) {
            ForEach(groups, id: \.title) { group in
                VStack(alignment: .leading, spacing: 4) {
                    roleSectionHeader(title: group.title, count: group.items.count, sets: group.totalSets, color: group.color)
                    VStack(spacing: 4) {
                        ForEach(group.items, id: \.planned.id) { item in
                            exerciseRow(item.planned, index: item.index, day: day, role: item.role)
                        }
                    }
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    private struct RoleGroup {
        let title: String
        let color: Color
        let items: [(planned: PlannedExercise, index: Int, role: ExerciseRole)]
        var totalSets: Int { items.reduce(0) { $0 + $1.planned.sets } }
    }

    private func groupedByRole(day: WorkoutDay) -> [RoleGroup] {
        var key: [(planned: PlannedExercise, index: Int, role: ExerciseRole)] = []
        var support: [(planned: PlannedExercise, index: Int, role: ExerciseRole)] = []
        var accessory: [(planned: PlannedExercise, index: Int, role: ExerciseRole)] = []
        var warm: [(planned: PlannedExercise, index: Int, role: ExerciseRole)] = []
        for (idx, pe) in day.exercises.enumerated() {
            let role = exerciseRole(pe, index: idx, day: day)
            let entry = (planned: pe, index: idx, role: role)
            switch role {
            case .keyLift: key.append(entry)
            case .supportLift: support.append(entry)
            case .accessory, .saferSubstitute: accessory.append(entry)
            case .warmup: warm.append(entry)
            }
        }
        var out: [RoleGroup] = []
        if !warm.isEmpty { out.append(RoleGroup(title: "Warm-Up", color: STRQPalette.warning, items: warm)) }
        if !key.isEmpty { out.append(RoleGroup(title: "Key Lifts", color: .white, items: key)) }
        if !support.isEmpty { out.append(RoleGroup(title: "Support", color: STRQPalette.info, items: support)) }
        if !accessory.isEmpty { out.append(RoleGroup(title: "Accessory", color: STRQBrand.steel, items: accessory)) }
        return out
    }

    private func roleSectionHeader(title: String, count: Int, sets: Int, color: Color) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(color)
                .frame(width: 3, height: 10)
            Text(title.uppercased())
                .font(.system(size: 10, weight: .black))
                .tracking(0.8)
                .foregroundStyle(color == .white ? Color.primary : color)
            Spacer()
            Text("\(count) · \(sets) sets")
                .font(.system(size: 10, weight: .semibold).monospacedDigit())
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 2)
    }

    @ViewBuilder
    private func exerciseRow(_ planned: PlannedExercise, index: Int, day: WorkoutDay, role: ExerciseRole) -> some View {
        let exercise = vm.library.exercise(byId: planned.exerciseId)
        let progression = vm.progressionStates.first(where: { $0.exerciseId == planned.exerciseId })
        let hasCoachNote = !planned.notes.isEmpty && planned.notes.hasPrefix("Coach:")
        let isCustom = planned.isCustomized

        Button {
            selectedPrescriptionIndex = index
        } label: {
            HStack(spacing: 10) {
                // Ordinal + role accent bar
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(roleColor(role))
                        .frame(width: 2.5)
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .black, design: .rounded).monospacedDigit())
                        .foregroundStyle(role == .keyLift ? .primary : .secondary)
                        .frame(width: 16, alignment: .leading)
                }
                .frame(height: 38)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 5) {
                        Text(exercise?.name ?? planned.exerciseId)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        if hasCoachNote {
                            Image(systemName: "brain.head.profile.fill")
                                .font(.system(size: 8))
                                .foregroundStyle(STRQBrand.steel)
                        }
                        if isCustom {
                            Text("CUSTOM")
                                .font(.system(size: 7, weight: .black))
                                .tracking(0.4)
                                .foregroundStyle(STRQPalette.warning)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1.5)
                                .background(STRQPalette.warning.opacity(0.14), in: Capsule())
                        }
                        if let p = progression, p.plateauStatus != .progressing {
                            Image(systemName: p.plateauStatus.icon)
                                .font(.system(size: 8))
                                .foregroundStyle(ForgeTheme.color(for: p.plateauStatus.colorName))
                        }
                    }

                    HStack(spacing: 6) {
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
                        if let suggestion = vm.loadSuggestion(for: planned.exerciseId, planned: planned), suggestion.suggestedWeight > 0 {
                            Text("·")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                            Text(suggestion.formattedWeight)
                                .font(.system(size: 10, weight: .bold).monospacedDigit())
                                .foregroundStyle(STRQPalette.success)
                        }
                    }
                }

                Spacer(minLength: 4)

                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.quaternary)
            }
            .padding(.leading, 0)
            .padding(.trailing, 12)
            .padding(.vertical, 7)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button {
                selectedPrescriptionIndex = index
            } label: { Label("Edit Prescription", systemImage: "slider.horizontal.3") }
            Button {
                swapTargetPlanned = planned
            } label: { Label("Swap Exercise", systemImage: "arrow.triangle.2.circlepath") }
            if planned.isCustomized {
                Button {
                    vm.restoreCoachDefault(dayId: day.id, plannedId: planned.id)
                } label: { Label("Restore Coach Default", systemImage: "arrow.uturn.backward") }
            }
            Divider()
            Button(role: .destructive) {
                vm.removePlannedExercise(dayId: day.id, plannedId: planned.id)
            } label: { Label("Remove", systemImage: "trash") }
        }
    }

    private func formatRestShort(_ seconds: Int) -> String {
        if seconds >= 60 {
            let m = seconds / 60
            let s = seconds % 60
            return s == 0 ? "\(m)m" : "\(m):\(String(format: "%02d", s))"
        }
        return "\(seconds)s"
    }

    // MARK: - Coach Banners

    private func coachBanner(_ adj: CoachAdjustment) -> some View {
        let color = adjustmentColor(adj.type)
        return HStack(spacing: 10) {
            Image(systemName: adjustmentIcon(adj.type))
                .font(.caption)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 2) {
                Text(adjustmentLabel(adj.type))
                    .font(.caption.weight(.bold))
                    .foregroundStyle(color)
                if !adj.details.isEmpty {
                    Text(adj.details.map(\.change).joined(separator: " · "))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer()
            Button {
                withAnimation(.snappy(duration: 0.3)) { vm.undoAdjustment(adj) }
            } label: {
                Text("Undo")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(.tertiarySystemGroupedBackground), in: Capsule())
            }
        }
        .padding(12)
        .background(color.opacity(0.05), in: .rect(cornerRadius: 12))
    }

    private func weekAdjBanner(_ adj: CoachAdjustment) -> some View {
        let isDeload = adj.type == .deloadWeek
        let color: Color = isDeload ? STRQBrand.slate : STRQBrand.steel

        return HStack(spacing: 10) {
            Image(systemName: isDeload ? "arrow.down.to.line" : "arrow.triangle.2.circlepath.circle.fill")
                .font(.caption)
                .foregroundStyle(color)
            Text(isDeload ? "Deload Week" : "Coach-Adjusted Week")
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
            Spacer()
            Button {
                withAnimation(.snappy(duration: 0.3)) { vm.undoAdjustment(adj) }
            } label: {
                Text("Revert")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(color.opacity(0.1), in: Capsule())
            }
        }
        .padding(12)
        .background(color.opacity(0.05), in: .rect(cornerRadius: 12))
    }

    // MARK: - Schedule Control

    private func scheduleControlRow(day: WorkoutDay) -> some View {
        HStack(spacing: 8) {
            if let wd = day.scheduledWeekday {
                HStack(spacing: 5) {
                    Image(systemName: "calendar")
                        .font(.system(size: 10))
                        .foregroundStyle(STRQBrand.steel)
                    Text(vm.fullWeekdayName(wd))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(STRQBrand.steel.opacity(0.08), in: Capsule())
            }

            Spacer()

            Button {
                withAnimation(.snappy(duration: 0.3)) { vm.skipDay(dayId: day.id) }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: day.isSkipped ? "arrow.uturn.backward" : "forward.fill")
                        .font(.system(size: 9))
                    Text(day.isSkipped ? "Unskip" : "Skip")
                        .font(.caption2.weight(.semibold))
                }
                .foregroundStyle(day.isSkipped ? STRQPalette.success : .secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.tertiarySystemGroupedBackground), in: Capsule())
            }

            if day.scheduledWeekday != nil {
                Button {
                    withAnimation(.snappy(duration: 0.3)) { vm.moveDayToNext(dayId: day.id) }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 9))
                        Text("Move")
                            .font(.caption2.weight(.semibold))
                    }
                    .foregroundStyle(STRQBrand.steel)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(.tertiarySystemGroupedBackground), in: Capsule())
                }
            }
        }
    }

    // MARK: - Helpers

    private func autoSelectToday(_ plan: WorkoutPlan) {
        let todayWeekday = Calendar.current.component(.weekday, from: Date())
        if let idx = plan.days.firstIndex(where: { $0.scheduledWeekday == todayWeekday && !$0.isSkipped }) {
            selectedDayIndex = idx
        }
    }

    private func exerciseRole(_ planned: PlannedExercise, index: Int, day: WorkoutDay) -> ExerciseRole {
        guard let exercise = vm.library.exercise(byId: planned.exerciseId) else { return .accessory }
        if exercise.category == .compound && index < 2 { return .keyLift }
        if exercise.category == .compound { return .supportLift }
        if exercise.category == .warmup || exercise.category == .mobility { return .warmup }
        return .accessory
    }

    private func roleColor(_ role: ExerciseRole) -> Color {
        switch role {
        case .keyLift: .white
        case .supportLift: STRQBrand.steel
        case .accessory: .secondary
        case .warmup: STRQPalette.warning
        case .saferSubstitute: STRQPalette.success
        }
    }

    private func shortDayName(_ name: String) -> String {
        let words = name.split(separator: " ")
        if words.count > 1 { return String(words[0]) }
        return String(name.prefix(8))
    }

    private func adjustmentIcon(_ type: CoachAdjustmentType) -> String {
        switch type {
        case .volumeReduced: return "minus.circle.fill"
        case .exerciseSwapped: return "arrow.triangle.2.circlepath"
        case .lighterSession: return "arrow.down.circle.fill"
        case .weekRegenerated: return "arrow.triangle.2.circlepath.circle.fill"
        case .deloadWeek: return "arrow.down.to.line"
        }
    }

    private func adjustmentLabel(_ type: CoachAdjustmentType) -> String {
        switch type {
        case .volumeReduced: return "Volume Reduced"
        case .exerciseSwapped: return "Exercise Swapped"
        case .lighterSession: return "Lighter Session"
        case .weekRegenerated: return "Week Regenerated"
        case .deloadWeek: return "Deload Week"
        }
    }

    private func adjustmentColor(_ type: CoachAdjustmentType) -> Color {
        switch type {
        case .volumeReduced: return STRQBrand.steel
        case .exerciseSwapped: return STRQBrand.steel
        case .lighterSession: return STRQBrand.steel
        case .weekRegenerated: return STRQBrand.steel
        case .deloadWeek: return STRQBrand.slate
        }
    }

    private var emptyPlanState: some View {
        ForgeEmptyState(
            icon: "doc.text.magnifyingglass",
            title: "No Plan Yet",
            message: "Complete onboarding to generate\nyour personalized training plan."
        )
        .padding(.top, 40)
    }
}
