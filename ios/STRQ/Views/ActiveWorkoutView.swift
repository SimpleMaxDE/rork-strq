import SwiftUI

struct ActiveWorkoutView: View {
    @Bindable var vm: AppViewModel
    @State private var elapsedSeconds: Int = 0
    @State private var restTimerActive: Bool = false
    @State private var restTimeRemaining: Int = 0
    @State private var showCompletion: Bool = false
    @State private var showSwapSheet: Bool = false
    @State private var showExerciseInfo: Exercise?
    @State private var timerTask: Task<Void, Never>?
    @State private var appeared: Bool = false
    @State private var setCompletedTrigger: Bool = false
    @State private var showExerciseList: Bool = false
    @State private var exerciseTransition: Bool = false
    @State private var lastLoggedSet: (exerciseIndex: Int, setIndex: Int)?

    private var workout: ActiveWorkoutState? { vm.activeWorkout }

    var body: some View {
        if showCompletion {
            WorkoutCompletionView(vm: vm, session: vm.workoutHistory.first) {
                showCompletion = false
            }
        } else if let workout = workout {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    workoutHeader(workout)
                    progressStrip(workout)

                    ScrollView {
                        VStack(spacing: 10) {
                            exerciseFocusHero(workout)
                                .padding(.horizontal, 14)
                                .padding(.top, 4)

                            VStack(spacing: 6) {
                                activeSetCard(workout)
                                setLogTable(workout)
                                previousSessionTable(workout)
                            }
                            .padding(.horizontal, 14)

                            exerciseActions(workout)
                                .padding(.horizontal, 14)

                            upNextPreview(workout)
                                .padding(.horizontal, 14)
                        }
                        .padding(.bottom, 100)
                    }
                }

                if restTimerActive {
                    restTimerOverlay(workout)
                }

                VStack {
                    Spacer()
                    bottomAction(workout)
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                startTimer()
                withAnimation(.easeOut(duration: 0.4)) { appeared = true }
            }
            .onDisappear { timerTask?.cancel() }
            .sheet(item: $showExerciseInfo) { exercise in
                NavigationStack {
                    ExerciseDetailView(exercise: exercise, vm: vm)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $showExerciseList) {
                exerciseListSheet(workout)
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationContentInteraction(.scrolls)
            }
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.6), trigger: setCompletedTrigger)
        }
    }

    // MARK: - Header

    private func workoutHeader(_ workout: ActiveWorkoutState) -> some View {
        let total = workout.session.exerciseLogs.count
        let done = workout.session.exerciseLogs.filter(\.isCompleted).count
        return HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(workout.session.dayName.uppercased())
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.4)
                    .foregroundStyle(STRQBrand.steel)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Text(formatTime(elapsedSeconds))
                    .font(.system(size: 22, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
            }

            Spacer(minLength: 12)

            Button { showExerciseList = true } label: {
                HStack(spacing: 6) {
                    Text("\(done)/\(total)")
                        .font(.caption.weight(.bold).monospacedDigit())
                    Image(systemName: "list.bullet")
                        .font(.caption2)
                }
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal, 11)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.06), in: Capsule())
            }
            .buttonStyle(.strqPressable)
            .padding(.trailing, 10)

            Button {
                vm.completeWorkout()
                showCompletion = true
            } label: {
                Text("Finish")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(STRQBrand.accentGradient, in: Capsule())
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 30)
        .padding(.bottom, 8)
    }

    private func progressStrip(_ workout: ActiveWorkoutState) -> some View {
        let total = workout.session.exerciseLogs.count
        let completed = workout.session.exerciseLogs.filter(\.isCompleted).count
        let progress = total > 0 ? CGFloat(completed) / CGFloat(total) : 0

        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle().fill(Color.white.opacity(0.06))
                Rectangle().fill(STRQBrand.steelGradient)
                    .frame(width: geo.size.width * progress)
                    .animation(.spring(response: 0.4), value: progress)
            }
        }
        .frame(height: 3)
    }

    // MARK: - Exercise Focus Hero

    @ViewBuilder
    private func exerciseFocusHero(_ workout: ActiveWorkoutState) -> some View {
        let exerciseIndex = workout.currentExerciseIndex
        if exerciseIndex < workout.session.exerciseLogs.count {
            let log = workout.session.exerciseLogs[exerciseIndex]
            let exercise = vm.library.exercise(byId: log.exerciseId)
            let planned = exerciseIndex < workout.plannedExercises.count ? workout.plannedExercises[exerciseIndex] : nil
            let mediaProvider = ExerciseMediaProvider.shared

            VStack(spacing: 0) {
                if let ex = exercise {
                    let gradientColors = mediaProvider.heroGradient(for: ex)
                    let heroSymbol = mediaProvider.heroSymbol(for: ex)

                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [gradientColors[0], gradientColors[1]],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 66)

                        HStack(spacing: 11) {
                            Image(systemName: heroSymbol)
                                .font(.system(size: 20, weight: .thin))
                                .foregroundStyle(.white.opacity(0.9))
                                .frame(width: 38, height: 38)
                                .background(.white.opacity(0.1), in: .rect(cornerRadius: 9))

                            VStack(alignment: .leading, spacing: 3) {
                                HStack(spacing: 6) {
                                    Text("\(exerciseIndex + 1)/\(workout.session.exerciseLogs.count)")
                                        .font(.system(size: 9, weight: .black).monospacedDigit())
                                        .foregroundStyle(.white.opacity(0.55))
                                        .tracking(0.8)
                                    Text("·")
                                        .foregroundStyle(.white.opacity(0.3))
                                    Text(ex.primaryMuscle.displayName.uppercased())
                                        .font(.system(size: 9, weight: .black))
                                        .foregroundStyle(.white.opacity(0.55))
                                        .tracking(0.8)
                                }

                                Text(ex.name)
                                    .font(.system(size: 17, weight: .heavy))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)

                                HStack(spacing: 8) {
                                    if let p = planned {
                                        Text("\(p.sets) × \(p.reps)")
                                            .font(.system(size: 11, weight: .bold).monospacedDigit())
                                            .foregroundStyle(.white.opacity(0.75))
                                    }
                                    if let p = planned, let rpe = p.rpe {
                                        Text("RPE \(Int(rpe))")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(.white.opacity(0.55))
                                    }
                                }
                            }

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 12)
                    }
                    .clipShape(.rect(cornerRadius: 14))
                }

                if let guidance = vm.nextSessionGuidance(for: log.exerciseId) {
                    HStack(spacing: 6) {
                        Image(systemName: guidance.icon)
                            .font(.system(size: 9))
                            .foregroundStyle(guidanceColor(guidance.color))
                        Text(guidance.action)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.75))
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.035), in: .rect(cornerRadius: 9))
                    .padding(.top, 4)
                }
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.4), value: appeared)
        }
    }

    // MARK: - Active Set Card

    @ViewBuilder
    private func activeSetCard(_ workout: ActiveWorkoutState) -> some View {
        let exerciseIndex = workout.currentExerciseIndex
        if exerciseIndex < workout.session.exerciseLogs.count {
            let log = workout.session.exerciseLogs[exerciseIndex]
            let currentSetIdx = workout.currentSetIndex
            let currentSet: SetLog? = currentSetIdx < log.sets.count && !log.sets[currentSetIdx].isCompleted
                ? log.sets[currentSetIdx]
                : log.sets.first(where: { !$0.isCompleted })
            let activeSetIndex = currentSet.flatMap { s in log.sets.firstIndex(where: { $0.id == s.id }) } ?? currentSetIdx

            if let setLog = currentSet {
                VStack(spacing: 12) {
                    HStack(alignment: .firstTextBaseline) {
                        HStack(spacing: 6) {
                            Text("SET")
                                .font(.system(size: 10, weight: .black))
                                .tracking(1.2)
                                .foregroundStyle(STRQBrand.steel)
                            Text("\(setLog.setNumber)")
                                .font(.system(size: 20, weight: .heavy, design: .rounded).monospacedDigit())
                                .foregroundStyle(.white)
                            Text("of \(log.sets.count)")
                                .font(.system(size: 12, weight: .semibold).monospacedDigit())
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        Spacer()
                        let planned = exerciseIndex < workout.plannedExercises.count ? workout.plannedExercises[exerciseIndex] : nil
                        if let suggestion = vm.loadSuggestion(for: log.exerciseId, planned: planned),
                           suggestion.suggestedWeight > 0,
                           abs(suggestion.suggestedWeight - setLog.weight) > 0.01 {
                            Button {
                                updateSet(exerciseIndex: exerciseIndex, setIndex: activeSetIndex, weight: suggestion.suggestedWeight, reps: setLog.reps)
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "scope")
                                        .font(.system(size: 9, weight: .bold))
                                    Text("target \(suggestion.formattedWeight)")
                                        .font(.system(size: 10, weight: .bold).monospacedDigit())
                                }
                                .foregroundStyle(.white.opacity(0.5))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.05), in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    HStack(spacing: 14) {
                        let exerciseForIncrement = vm.library.exercise(byId: log.exerciseId)
                        let increment = weightIncrement(for: exerciseForIncrement)
                        let isBodyweight = exerciseForIncrement?.category == .bodyweight || (exerciseForIncrement?.isBodyweight ?? false)

                        VStack(spacing: 4) {
                            Text("WEIGHT")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.tertiary)
                                .tracking(0.5)

                            HStack(spacing: 0) {
                                Button {
                                    let step = isBodyweight ? 1.0 : increment
                                    guard step > 0 else { return }
                                    updateSet(exerciseIndex: exerciseIndex, setIndex: activeSetIndex, weight: max(0, setLog.weight - step), reps: setLog.reps)
                                } label: {
                                    Image(systemName: "minus")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.5))
                                        .frame(width: 44, height: 44)
                                        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 9))
                                        .contentShape(.rect)
                                }
                                .buttonStyle(.strqStepper)
                                .disabled(isBodyweight && setLog.weight <= 0)

                                Text(isBodyweight && setLog.weight <= 0 ? "BW" : formatWeight(setLog.weight, increment: increment))
                                    .font(.system(size: 30, weight: .heavy, design: .rounded).monospacedDigit())
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .frame(maxWidth: .infinity)
                                    .contentTransition(.numericText())

                                Button {
                                    let step = isBodyweight ? 1.0 : increment
                                    guard step > 0 else { return }
                                    updateSet(exerciseIndex: exerciseIndex, setIndex: activeSetIndex, weight: setLog.weight + step, reps: setLog.reps)
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.5))
                                        .frame(width: 44, height: 44)
                                        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 9))
                                        .contentShape(.rect)
                                }
                                .buttonStyle(.strqStepper)
                            }

                            Text(isBodyweight ? "added load" : "kg")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity)

                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 1, height: 56)

                        VStack(spacing: 4) {
                            Text("REPS")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.tertiary)
                                .tracking(0.5)

                            HStack(spacing: 0) {
                                Button { updateSet(exerciseIndex: exerciseIndex, setIndex: activeSetIndex, weight: setLog.weight, reps: max(0, setLog.reps - 1)) } label: {
                                    Image(systemName: "minus")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.5))
                                        .frame(width: 44, height: 44)
                                        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 9))
                                        .contentShape(.rect)
                                }
                                .buttonStyle(.strqStepper)

                                Text("\(setLog.reps)")
                                    .font(.system(size: 30, weight: .heavy, design: .rounded).monospacedDigit())
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity)
                                    .contentTransition(.numericText())

                                Button { updateSet(exerciseIndex: exerciseIndex, setIndex: activeSetIndex, weight: setLog.weight, reps: setLog.reps + 1) } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.5))
                                        .frame(width: 44, height: 44)
                                        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 9))
                                        .contentShape(.rect)
                                }
                                .buttonStyle(.strqStepper)
                            }

                            Text("reps")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    Button {
                        completeSet(exerciseIndex: exerciseIndex, setIndex: activeSetIndex)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark")
                                .font(.subheadline.weight(.bold))
                            Text("Log Set \(setLog.setNumber)")
                                .font(.body.weight(.heavy))
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 46)
                        .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 12))
                        .shadow(color: .white.opacity(0.12), radius: 10, y: 2)
                    }
                    .buttonStyle(.strqPressable)
                }
                .padding(.horizontal, 13)
                .padding(.vertical, 11)
                .background(
                    LinearGradient(
                        colors: [Color.white.opacity(0.07), Color.white.opacity(0.03)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    in: .rect(cornerRadius: 18)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                )
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(STRQPalette.success)
                    Text("All sets complete")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 22))
            }
        }
    }

    // MARK: - Set Log Table (Alpha-inspired precision table)

    @ViewBuilder
    private func setLogTable(_ workout: ActiveWorkoutState) -> some View {
        let exerciseIndex = workout.currentExerciseIndex
        if exerciseIndex < workout.session.exerciseLogs.count {
            let log = workout.session.exerciseLogs[exerciseIndex]
            let planned = exerciseIndex < workout.plannedExercises.count ? workout.plannedExercises[exerciseIndex] : nil
            let targetReps = planned?.reps ?? "—"

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    tableHeader("#", width: 28, alignment: .leading)
                    tableHeader("KG")
                    tableHeader("REPS")
                    tableHeader("e1RM")
                    Color.clear.frame(width: 32)
                }
                .padding(.horizontal, 14)
                .padding(.top, 10)
                .padding(.bottom, 6)

                Rectangle().fill(Color.white.opacity(0.05)).frame(height: 0.5)

                ForEach(Array(log.sets.enumerated()), id: \.element.id) { idx, setLog in
                    let isActive = idx == workout.currentSetIndex && !setLog.isCompleted && !log.sets.prefix(idx).contains(where: { !$0.isCompleted })
                    setLogRow(setLog: setLog, idx: idx, isActive: isActive, exerciseIndex: exerciseIndex, targetReps: targetReps)
                    if idx < log.sets.count - 1 {
                        Rectangle().fill(Color.white.opacity(0.04)).frame(height: 0.5).padding(.leading, 14)
                    }
                }
            }
            .background(Color.white.opacity(0.025), in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
    }

    private func tableHeader(_ text: String, width: CGFloat? = nil, alignment: Alignment = .center) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .black))
            .tracking(1.0)
            .foregroundStyle(.white.opacity(0.35))
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: alignment)
            .frame(width: width)
    }

    @ViewBuilder
    private func setLogRow(setLog: SetLog, idx: Int, isActive: Bool, exerciseIndex: Int, targetReps: String) -> some View {
        let completed = setLog.isCompleted
        let e1rm = estimatedOneRM(weight: setLog.weight, reps: setLog.reps)
        let rowOpacity: Double = completed ? 0.85 : (isActive ? 1.0 : 0.45)

        Button {
            if !completed && !isActive {
                jumpToSet(exerciseIndex: exerciseIndex, setIndex: idx)
            }
        } label: {
            HStack(spacing: 0) {
                Text("\(setLog.setNumber)")
                    .font(.system(size: 13, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(isActive ? STRQBrand.steel : .white.opacity(0.55))
                    .frame(width: 28, alignment: .leading)

                Text(completed || setLog.weight > 0 ? formatWeight(setLog.weight, increment: 0.5) : "—")
                    .font(.system(size: 14, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white.opacity(rowOpacity))
                    .frame(maxWidth: .infinity)

                Text(completed || setLog.reps > 0 ? "\(setLog.reps)" : targetReps)
                    .font(.system(size: 14, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white.opacity(rowOpacity))
                    .frame(maxWidth: .infinity)

                Text(e1rm > 0 ? String(format: "%.1f", e1rm) : "—")
                    .font(.system(size: 13, weight: .semibold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white.opacity(completed ? 0.55 : 0.3))
                    .frame(maxWidth: .infinity)

                ZStack {
                    if completed {
                        Circle().fill(STRQPalette.success).frame(width: 22, height: 22)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.black)
                    } else if isActive {
                        Circle().strokeBorder(Color.white.opacity(0.5), lineWidth: 1.2).frame(width: 22, height: 22)
                    } else {
                        Circle().fill(Color.white.opacity(0.06)).frame(width: 22, height: 22)
                    }
                }
                .frame(width: 32)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(isActive ? Color.white.opacity(0.04) : Color.clear)
        }
        .buttonStyle(.plain)
        .disabled(completed)
    }

    // MARK: - Previous Session Table

    @ViewBuilder
    private func previousSessionTable(_ workout: ActiveWorkoutState) -> some View {
        let exerciseIndex = workout.currentExerciseIndex
        if exerciseIndex < workout.session.exerciseLogs.count {
            let log = workout.session.exerciseLogs[exerciseIndex]
            if let prev = previousSessionLog(for: log.exerciseId) {
                let completedSets = prev.session.exerciseLogs.first(where: { $0.exerciseId == log.exerciseId })?.sets.filter(\.isCompleted) ?? []
                if !completedSets.isEmpty {
                    VStack(spacing: 0) {
                        HStack(spacing: 6) {
                            Text("LAST SESSION")
                                .font(.system(size: 9, weight: .black))
                                .tracking(1.2)
                                .foregroundStyle(.white.opacity(0.45))
                            Text("·")
                                .foregroundStyle(.white.opacity(0.25))
                            Text(formatRelativeDate(prev.session.startTime))
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.45))
                            Spacer()
                            Text(prev.session.dayName)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.white.opacity(0.35))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 10)
                        .padding(.bottom, 8)

                        Rectangle().fill(Color.white.opacity(0.04)).frame(height: 0.5)

                        HStack(spacing: 0) {
                            tableHeader("#", width: 28, alignment: .leading)
                            tableHeader("KG")
                            tableHeader("REPS")
                            tableHeader("e1RM")
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 8)
                        .padding(.bottom, 4)

                        ForEach(Array(completedSets.enumerated()), id: \.element.id) { _, s in
                            HStack(spacing: 0) {
                                Text("\(s.setNumber)")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded).monospacedDigit())
                                    .foregroundStyle(.white.opacity(0.35))
                                    .frame(width: 28, alignment: .leading)
                                Text(formatWeight(s.weight, increment: 0.5))
                                    .font(.system(size: 12, weight: .semibold, design: .rounded).monospacedDigit())
                                    .foregroundStyle(.white.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                Text("\(s.reps)")
                                    .font(.system(size: 12, weight: .semibold, design: .rounded).monospacedDigit())
                                    .foregroundStyle(.white.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                Text(String(format: "%.1f", estimatedOneRM(weight: s.weight, reps: s.reps)))
                                    .font(.system(size: 12, weight: .semibold, design: .rounded).monospacedDigit())
                                    .foregroundStyle(.white.opacity(0.4))
                                    .frame(maxWidth: .infinity)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 5)
                        }
                    }
                    .padding(.bottom, 10)
                    .background(Color.white.opacity(0.02), in: .rect(cornerRadius: 12))
                }
            }
        }
    }

    private struct PreviousSessionRef {
        let session: WorkoutSession
    }

    private func previousSessionLog(for exerciseId: String) -> PreviousSessionRef? {
        for session in vm.workoutHistory where session.isCompleted {
            if let log = session.exerciseLogs.first(where: { $0.exerciseId == exerciseId }), log.sets.contains(where: { $0.isCompleted }) {
                return PreviousSessionRef(session: session)
            }
        }
        return nil
    }

    private func estimatedOneRM(weight: Double, reps: Int) -> Double {
        guard weight > 0, reps > 0 else { return 0 }
        if reps == 1 { return weight }
        // Epley
        return weight * (1.0 + Double(reps) / 30.0)
    }

    private func formatRelativeDate(_ date: Date) -> String {
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        if days <= 0 { return "today" }
        if days == 1 { return "yesterday" }
        if days < 7 { return "\(days)d ago" }
        if days < 30 { return "\(days / 7)w ago" }
        let f = DateFormatter()
        f.dateFormat = "d MMM"
        return f.string(from: date)
    }

    // MARK: - Exercise Actions

    private func exerciseActions(_ workout: ActiveWorkoutState) -> some View {
        HStack(spacing: 0) {
            Button { moveToPreviousExercise() } label: {
                Image(systemName: "chevron.left")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(workout.currentExerciseIndex == 0 ? AnyShapeStyle(.quaternary) : AnyShapeStyle(Color.white.opacity(0.55)))
                    .frame(width: 44, height: 40)
            }
            .disabled(workout.currentExerciseIndex == 0)

            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 1, height: 20)

            if let exercise = vm.library.exercise(byId: workout.session.exerciseLogs[workout.currentExerciseIndex].exerciseId) {
                Button { showExerciseInfo = exercise } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.caption2.weight(.semibold))
                        Text("Exercise Guide")
                            .font(.footnote.weight(.medium))
                    }
                    .foregroundStyle(.white.opacity(0.55))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                }
            }

            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 1, height: 20)

            Button { moveToNextExercise() } label: {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(workout.currentExerciseIndex >= workout.session.exerciseLogs.count - 1 ? AnyShapeStyle(.quaternary) : AnyShapeStyle(Color.white.opacity(0.55)))
                    .frame(width: 44, height: 40)
            }
            .disabled(workout.currentExerciseIndex >= workout.session.exerciseLogs.count - 1)
        }
        .background(Color.white.opacity(0.025), in: Capsule())
    }

    // MARK: - Up Next Preview

    @ViewBuilder
    private func upNextPreview(_ workout: ActiveWorkoutState) -> some View {
        let nextIndex = workout.currentExerciseIndex + 1
        if nextIndex < workout.session.exerciseLogs.count {
            let remaining = Array(workout.session.exerciseLogs[nextIndex...].prefix(2))
            let total = workout.session.exerciseLogs.count - nextIndex

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    Text("UP NEXT")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.white.opacity(0.9))
                        .tracking(1.4)
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 0.5)
                    Text("\(total) left")
                        .font(.system(size: 10, weight: .bold).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.55))
                }

                VStack(spacing: 6) {
                    ForEach(Array(remaining.enumerated()), id: \.element.id) { offset, log in
                        upNextRow(log: log, isImmediate: offset == 0, positionLabel: offset == 0 ? "NEXT" : "THEN")
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func upNextRow(log: ExerciseLog, isImmediate: Bool, positionLabel: String) -> some View {
        let exercise = vm.library.exercise(byId: log.exerciseId)
        let mediaProvider = ExerciseMediaProvider.shared
        let tileSize: CGFloat = isImmediate ? 36 : 30

        HStack(spacing: 12) {
            if let ex = exercise {
                let colors = mediaProvider.heroGradient(for: ex)
                let symbol = mediaProvider.heroSymbol(for: ex)
                ZStack {
                    RoundedRectangle(cornerRadius: 9)
                        .fill(LinearGradient(colors: [colors[0], colors[1]], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: tileSize, height: tileSize)
                        .opacity(isImmediate ? 1 : 0.7)
                    Image(systemName: symbol)
                        .font(.system(size: isImmediate ? 16 : 13, weight: .thin))
                        .foregroundStyle(.white.opacity(isImmediate ? 0.9 : 0.75))
                }
                .frame(width: 36, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(positionLabel)
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.0)
                    .foregroundStyle(isImmediate ? STRQBrand.steel : .white.opacity(0.4))
                Text(exercise?.name ?? log.exerciseId)
                    .font(.subheadline.weight(isImmediate ? .semibold : .medium))
                    .foregroundStyle(isImmediate ? .white : .white.opacity(0.75))
                    .lineLimit(1)
                if let ex = exercise {
                    Text("\(ex.primaryMuscle.displayName) · \(log.sets.count) sets")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(isImmediate ? 0.55 : 0.42))
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(isImmediate ? 0.4 : 0.22))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, isImmediate ? 9 : 7)
        .background(Color.white.opacity(isImmediate ? 0.07 : 0.035), in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color.white.opacity(isImmediate ? 0.09 : 0.04), lineWidth: 1)
        )
    }

    // MARK: - Bottom CTA

    private func bottomAction(_ workout: ActiveWorkoutState) -> some View {
        let allCurrentSetsDone = {
            let idx = workout.currentExerciseIndex
            guard idx < workout.session.exerciseLogs.count else { return false }
            return workout.session.exerciseLogs[idx].sets.allSatisfy(\.isCompleted)
        }()
        let isLastExercise = workout.currentExerciseIndex >= workout.session.exerciseLogs.count - 1
        let allDone = workout.session.exerciseLogs.allSatisfy(\.isCompleted)

        return VStack(spacing: 0) {
            LinearGradient(colors: [Color.black.opacity(0), Color.black], startPoint: .top, endPoint: .bottom)
                .frame(height: 40)

            Group {
                if allDone {
                    Button {
                        vm.completeWorkout()
                        showCompletion = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
                                .font(.subheadline)
                            Text("Complete Workout")
                                .font(.body.weight(.bold))
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 16))
                    }
                } else if allCurrentSetsDone && !isLastExercise {
                    Button { moveToNextExercise() } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right")
                                .font(.subheadline)
                            Text("Next Exercise")
                                .font(.body.weight(.bold))
                        }
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 16))
                    }
                } else {
                    EmptyView()
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .background(Color.black)
        }
    }

    // MARK: - Rest Timer

    @ViewBuilder
    private func restTimerOverlay(_ workout: ActiveWorkoutState) -> some View {
        ZStack {
            Color.black.opacity(0.94).ignoresSafeArea()
                .onTapGesture { }

            let planned = workout.currentExerciseIndex < workout.plannedExercises.count ? workout.plannedExercises[workout.currentExerciseIndex] : nil
            let totalRest = planned?.restSeconds ?? 90
            let progress = totalRest > 0 ? CGFloat(restTimeRemaining) / CGFloat(totalRest) : 0

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                VStack(spacing: 14) {
                    Text("REST")
                        .font(.system(size: 11, weight: .black))
                        .foregroundStyle(STRQBrand.steel)
                        .tracking(2.5)

                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.06), lineWidth: 6)
                            .frame(width: 196, height: 196)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                restTimeRemaining <= 10 ? STRQPalette.warning : Color.white,
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 196, height: 196)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: restTimeRemaining)

                        VStack(spacing: 6) {
                            Text(formatTime(restTimeRemaining))
                                .font(.system(size: 52, weight: .bold, design: .monospaced))
                                .foregroundStyle(restTimeRemaining <= 10 ? STRQPalette.warning : .white)
                                .contentTransition(.numericText(countsDown: true))
                            Text("remaining")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white.opacity(0.35))
                                .tracking(0.5)
                        }
                    }
                }

                Spacer(minLength: 24)

                if let last = lastLoggedSet,
                   last.exerciseIndex < workout.session.exerciseLogs.count,
                   last.setIndex < workout.session.exerciseLogs[last.exerciseIndex].sets.count {
                    let currentQuality = workout.session.exerciseLogs[last.exerciseIndex].sets[last.setIndex].quality
                    VStack(spacing: 12) {
                        Text("SET FEEL")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.35))
                            .tracking(1.5)
                        HStack(spacing: 6) {
                            ForEach(SetQuality.allCases, id: \.self) { quality in
                                let isSelected = currentQuality == quality
                                Button {
                                    setQuality(exerciseIndex: last.exerciseIndex, setIndex: last.setIndex, quality: isSelected ? nil : quality)
                                } label: {
                                    VStack(spacing: 5) {
                                        Image(systemName: quality.icon)
                                            .font(.system(size: 14, weight: .semibold))
                                        Text(quality.shortLabel)
                                            .font(.system(size: 9, weight: .bold))
                                    }
                                    .foregroundStyle(isSelected ? .black : .white.opacity(0.65))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .background(
                                        isSelected
                                            ? AnyShapeStyle(qualityColor(quality.colorName))
                                            : AnyShapeStyle(Color.white.opacity(0.05)),
                                        in: .rect(cornerRadius: 12)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(Color.white.opacity(isSelected ? 0 : 0.06), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }

                Spacer(minLength: 28)

                HStack(spacing: 14) {
                    Button { restTimeRemaining = max(0, restTimeRemaining - 15) } label: {
                        Text("−15s")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.75))
                            .frame(width: 68, height: 44)
                            .background(Color.white.opacity(0.05), in: Capsule())
                            .overlay(Capsule().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
                    }
                    .buttonStyle(.strqPressable)

                    Button {
                        restTimeRemaining = 0
                        restTimerActive = false
                    } label: {
                        Text("Skip Rest")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(STRQBrand.accentGradient, in: Capsule())
                    }
                    .buttonStyle(.strqPressable)

                    Button { restTimeRemaining += 15 } label: {
                        Text("+15s")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.75))
                            .frame(width: 68, height: 44)
                            .background(Color.white.opacity(0.05), in: Capsule())
                            .overlay(Capsule().strokeBorder(Color.white.opacity(0.08), lineWidth: 1))
                    }
                    .buttonStyle(.strqPressable)
                }
                .padding(.horizontal, 20)

                if let nextUp = nextUpPreview(workout) {
                    VStack(spacing: 6) {
                        Text("UP NEXT")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.28))
                            .tracking(1.5)
                        Text(nextUp)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }

                Spacer(minLength: 24)
            }
            .padding(.top, 40)
            .padding(.bottom, 20)
        }
    }

    private func nextUpPreview(_ workout: ActiveWorkoutState) -> String? {
        let nextIdx = workout.currentExerciseIndex + 1
        guard nextIdx < workout.session.exerciseLogs.count else { return nil }
        let nextLog = workout.session.exerciseLogs[nextIdx]
        return vm.library.exercise(byId: nextLog.exerciseId)?.name ?? nextLog.exerciseId
    }

    // MARK: - Exercise List Sheet

    private func exerciseListSheet(_ workout: ActiveWorkoutState) -> some View {
        NavigationStack {
            List {
                ForEach(Array(workout.session.exerciseLogs.enumerated()), id: \.element.id) { index, log in
                    let exercise = vm.library.exercise(byId: log.exerciseId)
                    let isCurrent = index == workout.currentExerciseIndex
                    let completedSets = log.sets.filter(\.isCompleted).count
                    let totalSets = log.sets.count

                    Button {
                        jumpToExercise(index)
                        showExerciseList = false
                    } label: {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(log.isCompleted ? STRQPalette.success : isCurrent ? Color.white : Color.white.opacity(0.08))
                                    .frame(width: 30, height: 30)
                                if log.isCompleted {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.white)
                                } else {
                                    Text("\(index + 1)")
                                        .font(.caption.weight(.bold).monospacedDigit())
                                        .foregroundStyle(isCurrent ? .black : .secondary)
                                }
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise?.name ?? log.exerciseId)
                                    .font(.subheadline.weight(isCurrent ? .bold : .medium))
                                    .foregroundStyle(isCurrent ? .white : .primary)
                                Text("\(completedSets)/\(totalSets) sets")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if isCurrent {
                                Text("Active")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(STRQBrand.steel)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(STRQBrand.steel.opacity(0.12), in: Capsule())
                            }
                        }
                    }
                }
            }
            .navigationTitle("Exercises")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showExerciseList = false }
                }
            }
        }
    }

    // MARK: - Actions

    private func updateSet(exerciseIndex: Int, setIndex: Int, weight: Double, reps: Int) {
        withAnimation(.snappy(duration: 0.15)) {
            vm.updateSetLoad(exerciseIndex: exerciseIndex, setIndex: setIndex, weight: weight, reps: reps)
        }
    }

    private func completeSet(exerciseIndex: Int, setIndex: Int) {
        let rest = vm.completeCurrentSet(exerciseIndex: exerciseIndex, setIndex: setIndex)
        guard rest > 0 else { return }
        setCompletedTrigger.toggle()
        lastLoggedSet = (exerciseIndex, setIndex)
        restTimeRemaining = rest
        restTimerActive = true
    }

    private func setQuality(exerciseIndex: Int, setIndex: Int, quality: SetQuality?) {
        vm.setSetQuality(exerciseIndex: exerciseIndex, setIndex: setIndex, quality: quality)
        setCompletedTrigger.toggle()
    }

    private func qualityColor(_ name: String) -> Color {
        switch name {
        case "green": return STRQPalette.success
        case "blue": return STRQPalette.info
        case "orange": return STRQPalette.warning
        case "yellow": return STRQPalette.warning
        case "red": return STRQPalette.danger
        default: return .white
        }
    }

    private func jumpToSet(exerciseIndex: Int, setIndex: Int) {
        vm.jumpToSet(exerciseIndex: exerciseIndex, setIndex: setIndex)
    }

    private func moveToNextExercise() {
        vm.moveToNextExercise()
    }

    private func moveToPreviousExercise() {
        vm.moveToPreviousExercise()
    }

    private func jumpToExercise(_ index: Int) {
        vm.jumpToExercise(index)
    }

    private func liveRestEndsAt() -> Date? {
        guard restTimerActive, restTimeRemaining > 0 else { return nil }
        return Date().addingTimeInterval(TimeInterval(restTimeRemaining))
    }

    private func startTimer() {
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { break }
                elapsedSeconds += 1
                if restTimerActive && restTimeRemaining > 0 {
                    restTimeRemaining -= 1
                    if restTimeRemaining <= 0 {
                        restTimerActive = false
                    }
                }
            }
        }
    }

    private func formatTime(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }

    private func weightIncrement(for exercise: Exercise?) -> Double {
        guard let ex = exercise else { return 2.5 }
        if ex.category == .bodyweight { return ex.isBodyweight ? 1.0 : 0 }
        if ex.category == .isolation {
            if ex.equipment.contains(.dumbbell) { return 1.0 }
            return 1.25
        }
        if ex.equipment.contains(.kettlebell) { return 4.0 }
        if ex.equipment.contains(.barbell) { return 2.5 }
        if ex.equipment.contains(.dumbbell) { return 2.0 }
        if ex.equipment.contains(.machine) || ex.equipment.contains(.cable) { return 2.5 }
        return 2.5
    }

    private func formatWeight(_ weight: Double, increment: Double) -> String {
        if increment > 0 && increment.truncatingRemainder(dividingBy: 1) == 0 && weight.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", weight)
        }
        return String(format: "%.1f", weight)
    }

    private func guidanceColor(_ name: String) -> Color {
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
}

