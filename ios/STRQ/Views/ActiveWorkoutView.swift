import SwiftUI

struct ActiveWorkoutView: View {
    @Bindable var vm: AppViewModel
    @State private var elapsedSeconds: Int = 0
    @State private var restTimerActive: Bool = false
    @State private var restTimeRemaining: Int = 0
    @State private var showCompletion: Bool = false
    @State private var showExerciseInfo: Exercise?
    @State private var timerTask: Task<Void, Never>?
    @State private var appeared: Bool = false
    @State private var setCompletedTrigger: Bool = false
    @State private var showExerciseList: Bool = false
    @State private var lastLoggedSet: (exerciseIndex: Int, setIndex: Int)?
    @State private var numericEdit: NumericEditContext?

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
                            currentTaskBlock(workout)
                                .padding(.horizontal, 14)
                                .padding(.top, 6)

                            activeSetCard(workout)
                                .padding(.horizontal, 14)

                            setLogTable(workout)
                                .padding(.horizontal, 14)

                            previousSessionStrip(workout)
                                .padding(.horizontal, 14)

                            exerciseActions(workout)
                                .padding(.horizontal, 14)

                            if shouldShowUpNext(workout) {
                                upNextPreview(workout)
                                    .padding(.horizontal, 14)
                            }
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
            .sheet(item: $numericEdit) { ctx in
                NumericInputSheet(context: ctx) { newValue in
                    applyNumericEdit(ctx: ctx, newValue: newValue)
                }
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
            }
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.6), trigger: setCompletedTrigger)
        }
    }

    // MARK: - Header

    private func workoutHeader(_ workout: ActiveWorkoutState) -> some View {
        let total = workout.session.exerciseLogs.count
        let done = workout.session.exerciseLogs.filter(\.isCompleted).count
        return HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(workout.session.dayName.uppercased())
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.4)
                    .foregroundStyle(STRQBrand.steel)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Text(formatTime(elapsedSeconds))
                    .font(.system(size: 20, weight: .bold, design: .rounded).monospacedDigit())
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
                .foregroundStyle(.white.opacity(0.75))
                .padding(.horizontal, 11)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.06), in: Capsule())
            }
            .buttonStyle(.strqPressable)

            Button {
                vm.completeWorkout()
                showCompletion = true
            } label: {
                Text("Finish")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(STRQBrand.accentGradient, in: Capsule())
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 28)
        .padding(.bottom, 6)
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
        .frame(height: 2)
    }

    // MARK: - Current Task Block (fused hero + meta + context)

    @ViewBuilder
    private func currentTaskBlock(_ workout: ActiveWorkoutState) -> some View {
        let exerciseIndex = workout.currentExerciseIndex
        if exerciseIndex < workout.session.exerciseLogs.count {
            let log = workout.session.exerciseLogs[exerciseIndex]
            let exercise = vm.library.exercise(byId: log.exerciseId)
            let planned = exerciseIndex < workout.plannedExercises.count ? workout.plannedExercises[exerciseIndex] : nil
            let mediaProvider = ExerciseMediaProvider.shared
            let currentSet = activeSetFor(log: log, workout: workout)
            let activeSetNumber = currentSet?.setNumber ?? (log.sets.filter(\.isCompleted).count + 1)
            let guidance = vm.nextSessionGuidance(for: log.exerciseId)

            if let ex = exercise {
                let gradientColors = mediaProvider.heroGradient(for: ex)
                let heroSymbol = mediaProvider.heroSymbol(for: ex)

                VStack(spacing: 0) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [gradientColors[0], gradientColors[1]],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        VStack(alignment: .leading, spacing: 6) {
                            HStack(spacing: 8) {
                                Text("EX \(exerciseIndex + 1)/\(workout.session.exerciseLogs.count)")
                                    .font(.system(size: 9, weight: .black).monospacedDigit())
                                    .foregroundStyle(.white.opacity(0.6))
                                    .tracking(0.8)
                                Text("·")
                                    .foregroundStyle(.white.opacity(0.3))
                                Text(ex.primaryMuscle.displayName.uppercased())
                                    .font(.system(size: 9, weight: .black))
                                    .foregroundStyle(.white.opacity(0.6))
                                    .tracking(0.8)
                                Spacer()
                                Text("SET \(activeSetNumber)/\(log.sets.count)")
                                    .font(.system(size: 10, weight: .heavy).monospacedDigit())
                                    .tracking(0.8)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(Color.white.opacity(0.15), in: Capsule())
                            }

                            HStack(spacing: 10) {
                                Image(systemName: heroSymbol)
                                    .font(.system(size: 18, weight: .thin))
                                    .foregroundStyle(.white.opacity(0.92))
                                    .frame(width: 34, height: 34)
                                    .background(.white.opacity(0.12), in: .rect(cornerRadius: 8))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ex.name)
                                        .font(.system(size: 17, weight: .heavy))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)

                                    HStack(spacing: 6) {
                                        if let p = planned {
                                            Text("Target \(p.reps)")
                                                .font(.system(size: 10, weight: .bold).monospacedDigit())
                                                .foregroundStyle(.white.opacity(0.78))
                                            if let rpe = p.rpe {
                                                Text("·").foregroundStyle(.white.opacity(0.3))
                                                Text("RPE \(formatRPE(rpe))")
                                                    .font(.system(size: 10, weight: .bold).monospacedDigit())
                                                    .foregroundStyle(.white.opacity(0.6))
                                            }
                                            Text("·").foregroundStyle(.white.opacity(0.3))
                                            Text("\(p.restSeconds)s rest")
                                                .font(.system(size: 10, weight: .semibold).monospacedDigit())
                                                .foregroundStyle(.white.opacity(0.55))
                                        }
                                    }
                                }
                                Spacer(minLength: 0)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                    }
                    .clipShape(.rect(cornerRadius: 14))

                    // Context strip: PREV · BEST · TARGET
                    contextStrip(log: log, planned: planned)
                        .padding(.top, 6)

                    if let g = guidance {
                        HStack(spacing: 6) {
                            Image(systemName: g.icon)
                                .font(.system(size: 10))
                                .foregroundStyle(guidanceColor(g.color))
                            Text(g.action)
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.82))
                                .lineLimit(1)
                                .minimumScaleFactor(0.85)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(guidanceColor(g.color).opacity(0.10), in: .rect(cornerRadius: 9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 9)
                                .strokeBorder(guidanceColor(g.color).opacity(0.22), lineWidth: 1)
                        )
                        .padding(.top, 6)
                    }
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.easeOut(duration: 0.4), value: appeared)
            }
        }
    }

    @ViewBuilder
    private func contextStrip(log: ExerciseLog, planned: PlannedExercise?) -> some View {
        let last = vm.lastPerformance(for: log.exerciseId)
        let best = personalBest(for: log.exerciseId)
        let suggestion = vm.loadSuggestion(for: log.exerciseId, planned: planned)

        HStack(spacing: 0) {
            contextCell(
                label: "PREV",
                primary: last.map { "\(formatWeight($0.topWeight, increment: 0.5))×\($0.topReps)" } ?? "—",
                secondary: last.map { formatRelativeDate($0.date) } ?? "no data"
            )
            contextDivider()
            contextCell(
                label: "BEST",
                primary: best.map { "\(formatWeight($0.weight, increment: 0.5))×\($0.reps)" } ?? "—",
                secondary: best.map { String(format: "e1RM %.0f", $0.e1rm) } ?? "—"
            )
            contextDivider()
            contextCell(
                label: "TARGET",
                primary: suggestion.map { $0.suggestedWeight > 0 ? formatWeight($0.suggestedWeight, increment: 0.5) : "BW" } ?? "—",
                secondary: planned.map { "× \($0.reps)" } ?? "—"
            )
        }
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.03), in: .rect(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.white.opacity(0.05), lineWidth: 1)
        )
    }

    private func contextCell(label: String, primary: String, secondary: String) -> some View {
        VStack(alignment: .center, spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .black))
                .tracking(1.2)
                .foregroundStyle(.white.opacity(0.4))
            Text(primary)
                .font(.system(size: 13, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundStyle(.white.opacity(0.92))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(secondary)
                .font(.system(size: 9, weight: .semibold).monospacedDigit())
                .foregroundStyle(.white.opacity(0.42))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
    }

    private func contextDivider() -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.06))
            .frame(width: 1, height: 30)
    }

    // MARK: - Active Set Card

    @ViewBuilder
    private func activeSetCard(_ workout: ActiveWorkoutState) -> some View {
        let exerciseIndex = workout.currentExerciseIndex
        if exerciseIndex < workout.session.exerciseLogs.count {
            let log = workout.session.exerciseLogs[exerciseIndex]
            let currentSet = activeSetFor(log: log, workout: workout)
            let activeSetIndex = currentSet.flatMap { s in log.sets.firstIndex(where: { $0.id == s.id }) } ?? workout.currentSetIndex
            let planned = exerciseIndex < workout.plannedExercises.count ? workout.plannedExercises[exerciseIndex] : nil
            let lastPerf = vm.lastPerformance(for: log.exerciseId)
            let suggestion = vm.loadSuggestion(for: log.exerciseId, planned: planned)

            if let setLog = currentSet {
                let exerciseForIncrement = vm.library.exercise(byId: log.exerciseId)
                let increment = weightIncrement(for: exerciseForIncrement)
                let isBodyweight = exerciseForIncrement?.category == .bodyweight || (exerciseForIncrement?.isBodyweight ?? false)

                VStack(spacing: 10) {
                    // Match chips
                    matchChipsRow(
                        setLog: setLog,
                        exerciseIndex: exerciseIndex,
                        setIndex: activeSetIndex,
                        lastWeight: lastPerf?.topWeight,
                        lastReps: lastPerf?.topReps,
                        targetWeight: suggestion?.suggestedWeight,
                        targetReps: parsePlannedReps(planned?.reps)
                    )

                    HStack(spacing: 14) {
                        inputColumn(
                            label: isBodyweight ? "ADDED LOAD" : "WEIGHT",
                            value: isBodyweight && setLog.weight <= 0 ? "BW" : formatWeight(setLog.weight, increment: increment),
                            unit: isBodyweight ? "kg added" : "kg",
                            disableMinus: isBodyweight && setLog.weight <= 0,
                            onMinus: { step in
                                let s = isBodyweight ? 1.0 : (step ?? increment)
                                guard s > 0 else { return }
                                updateSet(exerciseIndex: exerciseIndex, setIndex: activeSetIndex, weight: max(0, setLog.weight - s), reps: setLog.reps)
                            },
                            onPlus: { step in
                                let s = isBodyweight ? 1.0 : (step ?? increment)
                                guard s > 0 else { return }
                                updateSet(exerciseIndex: exerciseIndex, setIndex: activeSetIndex, weight: setLog.weight + s, reps: setLog.reps)
                            },
                            onTapValue: {
                                numericEdit = NumericEditContext(
                                    field: .weight,
                                    exerciseIndex: exerciseIndex,
                                    setIndex: activeSetIndex,
                                    currentWeight: setLog.weight,
                                    currentReps: setLog.reps,
                                    title: "Edit Weight",
                                    unit: isBodyweight ? "kg added" : "kg"
                                )
                            },
                            plateMath: plateMathLabel(weight: setLog.weight, exercise: exerciseForIncrement)
                        )
                        .frame(maxWidth: .infinity)

                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 1, height: 64)

                        inputColumn(
                            label: "REPS",
                            value: "\(setLog.reps)",
                            unit: "reps",
                            disableMinus: setLog.reps <= 0,
                            onMinus: { step in
                                let s = Int(step ?? 1)
                                updateSet(exerciseIndex: exerciseIndex, setIndex: activeSetIndex, weight: setLog.weight, reps: max(0, setLog.reps - s))
                            },
                            onPlus: { step in
                                let s = Int(step ?? 1)
                                updateSet(exerciseIndex: exerciseIndex, setIndex: activeSetIndex, weight: setLog.weight, reps: setLog.reps + s)
                            },
                            onTapValue: {
                                numericEdit = NumericEditContext(
                                    field: .reps,
                                    exerciseIndex: exerciseIndex,
                                    setIndex: activeSetIndex,
                                    currentWeight: setLog.weight,
                                    currentReps: setLog.reps,
                                    title: "Edit Reps",
                                    unit: "reps"
                                )
                            },
                            plateMath: nil
                        )
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
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    in: .rect(cornerRadius: 16)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(STRQPalette.success)
                    Text("All sets complete")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 16))
            }
        }
    }

    // MARK: - Match chips

    @ViewBuilder
    private func matchChipsRow(
        setLog: SetLog,
        exerciseIndex: Int,
        setIndex: Int,
        lastWeight: Double?,
        lastReps: Int?,
        targetWeight: Double?,
        targetReps: Int?
    ) -> some View {
        let showLast = lastWeight.map { abs($0 - setLog.weight) > 0.01 } ?? false
        let showTarget: Bool = {
            guard let tw = targetWeight, tw > 0 else { return false }
            return abs(tw - setLog.weight) > 0.01
        }()

        if showLast || showTarget {
            HStack(spacing: 6) {
                if showLast, let lw = lastWeight {
                    matchChip(
                        icon: "arrow.uturn.backward",
                        label: "Match last",
                        value: "\(formatWeight(lw, increment: 0.5))\(lastReps.map { "×\($0)" } ?? "")"
                    ) {
                        updateSet(
                            exerciseIndex: exerciseIndex,
                            setIndex: setIndex,
                            weight: lw,
                            reps: lastReps ?? setLog.reps
                        )
                    }
                }
                if showTarget, let tw = targetWeight {
                    matchChip(
                        icon: "scope",
                        label: "Target",
                        value: "\(formatWeight(tw, increment: 0.5))\(targetReps.map { "×\($0)" } ?? "")"
                    ) {
                        updateSet(
                            exerciseIndex: exerciseIndex,
                            setIndex: setIndex,
                            weight: tw,
                            reps: targetReps ?? setLog.reps
                        )
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }

    private func matchChip(icon: String, label: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white.opacity(0.55))
                Text(value)
                    .font(.system(size: 10, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white)
            }
            .foregroundStyle(.white.opacity(0.75))
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(Color.white.opacity(0.06), in: Capsule())
            .overlay(Capsule().strokeBorder(Color.white.opacity(0.09), lineWidth: 1))
        }
        .buttonStyle(.strqPressable)
    }

    // MARK: - Input column

    @ViewBuilder
    private func inputColumn(
        label: String,
        value: String,
        unit: String,
        disableMinus: Bool,
        onMinus: @escaping (Double?) -> Void,
        onPlus: @escaping (Double?) -> Void,
        onTapValue: @escaping () -> Void,
        plateMath: String?
    ) -> some View {
        VStack(spacing: 3) {
            Text(label)
                .font(.system(size: 9, weight: .black))
                .tracking(1.0)
                .foregroundStyle(.white.opacity(0.45))

            HStack(spacing: 0) {
                stepperButton(icon: "minus", disabled: disableMinus, onTap: { onMinus(nil) }, onLongStep: { onMinus(5) })
                Button(action: onTapValue) {
                    Text(value)
                        .font(.system(size: 30, weight: .heavy, design: .rounded).monospacedDigit())
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .contentTransition(.numericText())
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                stepperButton(icon: "plus", disabled: false, onTap: { onPlus(nil) }, onLongStep: { onPlus(5) })
            }

            Text(plateMath ?? unit)
                .font(.system(size: 9, weight: plateMath != nil ? .semibold : .medium, design: plateMath != nil ? .monospaced : .default))
                .foregroundStyle(.white.opacity(plateMath != nil ? 0.55 : 0.4))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private func stepperButton(icon: String, disabled: Bool, onTap: @escaping () -> Void, onLongStep: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.white.opacity(disabled ? 0.25 : 0.55))
                .frame(width: 44, height: 44)
                .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 9))
                .contentShape(.rect)
        }
        .buttonStyle(.strqStepper)
        .disabled(disabled)
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.4)
                .onEnded { _ in
                    guard !disabled else { return }
                    onLongStep()
                }
        )
    }

    // MARK: - Set Log Table

    @ViewBuilder
    private func setLogTable(_ workout: ActiveWorkoutState) -> some View {
        let exerciseIndex = workout.currentExerciseIndex
        if exerciseIndex < workout.session.exerciseLogs.count {
            let log = workout.session.exerciseLogs[exerciseIndex]
            let planned = exerciseIndex < workout.plannedExercises.count ? workout.plannedExercises[exerciseIndex] : nil
            let targetReps = planned?.reps ?? "—"
            let suggestion = vm.loadSuggestion(for: log.exerciseId, planned: planned)
            let targetWeight: String = {
                guard let s = suggestion, s.suggestedWeight > 0 else { return "—" }
                return formatWeight(s.suggestedWeight, increment: 0.5)
            }()
            let lastSessionSets = previousSetsMap(for: log.exerciseId)
            let firstActiveIdx = log.sets.firstIndex(where: { !$0.isCompleted })

            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    tableHeader("#", width: 22, alignment: .leading)
                    tableHeader("KG")
                    tableHeader("REPS")
                    tableHeader("TGT")
                    tableHeader("e1RM")
                    Color.clear.frame(width: 28)
                }
                .padding(.horizontal, 12)
                .padding(.top, 9)
                .padding(.bottom, 5)

                Rectangle().fill(Color.white.opacity(0.05)).frame(height: 0.5)

                ForEach(Array(log.sets.enumerated()), id: \.element.id) { idx, setLog in
                    let isActive = idx == firstActiveIdx
                    setLogRow(
                        setLog: setLog,
                        idx: idx,
                        isActive: isActive,
                        exerciseIndex: exerciseIndex,
                        targetReps: targetReps,
                        targetWeight: targetWeight,
                        previousSet: lastSessionSets[setLog.setNumber]
                    )
                    if idx < log.sets.count - 1 {
                        Rectangle().fill(Color.white.opacity(0.04)).frame(height: 0.5).padding(.leading, 12)
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
    private func setLogRow(
        setLog: SetLog,
        idx: Int,
        isActive: Bool,
        exerciseIndex: Int,
        targetReps: String,
        targetWeight: String,
        previousSet: SetLog?
    ) -> some View {
        let completed = setLog.isCompleted
        let e1rm = estimatedOneRM(weight: setLog.weight, reps: setLog.reps)
        let rowOpacity: Double = completed ? 0.9 : (isActive ? 1.0 : 0.38)
        let delta = completed ? deltaChip(current: setLog, previous: previousSet) : nil

        Button {
            if !completed && !isActive {
                jumpToSet(exerciseIndex: exerciseIndex, setIndex: idx)
            }
        } label: {
            HStack(spacing: 0) {
                Text("\(setLog.setNumber)")
                    .font(.system(size: 13, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(isActive ? .white : .white.opacity(0.5))
                    .frame(width: 22, alignment: .leading)

                HStack(spacing: 3) {
                    Text(completed || setLog.weight > 0 ? formatWeight(setLog.weight, increment: 0.5) : "—")
                        .font(.system(size: 14, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white.opacity(rowOpacity))
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: 3) {
                    if completed || setLog.reps > 0 {
                        Text("\(setLog.reps)")
                            .font(.system(size: 14, weight: .bold, design: .rounded).monospacedDigit())
                            .foregroundStyle(.white.opacity(rowOpacity))
                    } else {
                        Text(targetReps)
                            .font(.system(size: 12, weight: .semibold, design: .rounded).monospacedDigit())
                            .foregroundStyle(.white.opacity(0.25))
                    }
                }
                .frame(maxWidth: .infinity)

                Text(targetWeight)
                    .font(.system(size: 11, weight: .semibold, design: .rounded).monospacedDigit())
                    .foregroundStyle(.white.opacity(isActive ? 0.55 : 0.3))
                    .frame(maxWidth: .infinity)

                HStack(spacing: 4) {
                    Text(e1rm > 0 ? String(format: "%.0f", e1rm) : "—")
                        .font(.system(size: 12, weight: .semibold, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white.opacity(completed ? 0.55 : 0.25))
                    if let d = delta {
                        Text(d.text)
                            .font(.system(size: 9, weight: .heavy).monospacedDigit())
                            .foregroundStyle(d.color)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1.5)
                            .background(d.color.opacity(0.14), in: Capsule())
                    }
                }
                .frame(maxWidth: .infinity)

                ZStack {
                    if completed {
                        Circle().fill(STRQPalette.success).frame(width: 20, height: 20)
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.black)
                    } else if isActive {
                        Circle().strokeBorder(Color.white, lineWidth: 1.4).frame(width: 20, height: 20)
                        Circle().fill(Color.white).frame(width: 6, height: 6)
                    } else {
                        Circle()
                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [2, 2]))
                            .foregroundStyle(Color.white.opacity(0.2))
                            .frame(width: 20, height: 20)
                    }
                }
                .frame(width: 28)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                ZStack {
                    if isActive {
                        RoundedRectangle(cornerRadius: 0)
                            .fill(Color.white.opacity(0.05))
                        RoundedRectangle(cornerRadius: 0)
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    }
                }
            )
        }
        .buttonStyle(.plain)
        .disabled(completed)
    }

    private struct DeltaChip {
        let text: String
        let color: Color
    }

    private func deltaChip(current: SetLog, previous: SetLog?) -> DeltaChip? {
        guard let prev = previous, prev.weight > 0 || prev.reps > 0 else { return nil }
        let dw = current.weight - prev.weight
        let dr = current.reps - prev.reps
        if abs(dw) < 0.01 && dr == 0 {
            return DeltaChip(text: "=", color: .white.opacity(0.4))
        }
        if abs(dw) >= 0.01 {
            let sign = dw > 0 ? "+" : "−"
            let val = formatWeight(abs(dw), increment: 0.5)
            return DeltaChip(text: "\(sign)\(val)", color: dw > 0 ? STRQPalette.success : STRQPalette.warning)
        }
        let sign = dr > 0 ? "+" : "−"
        return DeltaChip(text: "\(sign)\(abs(dr))r", color: dr > 0 ? STRQPalette.success : STRQPalette.warning)
    }

    // MARK: - Previous Session Strip (compact)

    @ViewBuilder
    private func previousSessionStrip(_ workout: ActiveWorkoutState) -> some View {
        let exerciseIndex = workout.currentExerciseIndex
        if exerciseIndex < workout.session.exerciseLogs.count {
            let log = workout.session.exerciseLogs[exerciseIndex]
            if let prev = previousSessionLog(for: log.exerciseId) {
                let completedSets = prev.session.exerciseLogs.first(where: { $0.exerciseId == log.exerciseId })?.sets.filter(\.isCompleted) ?? []
                if !completedSets.isEmpty {
                    let summary = completedSets
                        .map { "\(formatWeight($0.weight, increment: 0.5))×\($0.reps)" }
                        .joined(separator: "  ")
                    HStack(spacing: 8) {
                        Text("LAST")
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.2)
                            .foregroundStyle(.white.opacity(0.45))
                        Text(formatRelativeDate(prev.session.startTime))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.45))
                        Rectangle().fill(Color.white.opacity(0.08)).frame(width: 1, height: 12)
                        Text(summary)
                            .font(.system(size: 11, weight: .semibold, design: .rounded).monospacedDigit())
                            .foregroundStyle(.white.opacity(0.7))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.02), in: .rect(cornerRadius: 9))
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

    private func previousSetsMap(for exerciseId: String) -> [Int: SetLog] {
        guard let prev = previousSessionLog(for: exerciseId) else { return [:] }
        let sets = prev.session.exerciseLogs.first(where: { $0.exerciseId == exerciseId })?.sets.filter(\.isCompleted) ?? []
        var map: [Int: SetLog] = [:]
        for s in sets { map[s.setNumber] = s }
        return map
    }

    private struct PersonalBest {
        let weight: Double
        let reps: Int
        let e1rm: Double
    }

    private func personalBest(for exerciseId: String) -> PersonalBest? {
        var best: PersonalBest?
        for session in vm.workoutHistory where session.isCompleted {
            guard let log = session.exerciseLogs.first(where: { $0.exerciseId == exerciseId }) else { continue }
            for s in log.sets where s.isCompleted && s.weight > 0 && s.reps > 0 {
                let e = estimatedOneRM(weight: s.weight, reps: s.reps)
                if best == nil || e > best!.e1rm {
                    best = PersonalBest(weight: s.weight, reps: s.reps, e1rm: e)
                }
            }
        }
        return best
    }

    private func estimatedOneRM(weight: Double, reps: Int) -> Double {
        guard weight > 0, reps > 0 else { return 0 }
        if reps == 1 { return weight }
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
                    .frame(width: 44, height: 38)
            }
            .disabled(workout.currentExerciseIndex == 0)

            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 1, height: 18)

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
                    .frame(height: 38)
                }
            }

            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 1, height: 18)

            Button { moveToNextExercise() } label: {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(workout.currentExerciseIndex >= workout.session.exerciseLogs.count - 1 ? AnyShapeStyle(.quaternary) : AnyShapeStyle(Color.white.opacity(0.55)))
                    .frame(width: 44, height: 38)
            }
            .disabled(workout.currentExerciseIndex >= workout.session.exerciseLogs.count - 1)
        }
        .background(Color.white.opacity(0.025), in: Capsule())
    }

    // MARK: - Up Next Preview

    private func shouldShowUpNext(_ workout: ActiveWorkoutState) -> Bool {
        let idx = workout.currentExerciseIndex
        guard idx < workout.session.exerciseLogs.count else { return false }
        // Only show when all sets of current exercise are done (i.e. between exercises)
        return workout.session.exerciseLogs[idx].sets.allSatisfy(\.isCompleted)
    }

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

    // MARK: - Rest Timer Overlay

    @ViewBuilder
    private func restTimerOverlay(_ workout: ActiveWorkoutState) -> some View {
        ZStack {
            Color.black.opacity(0.95).ignoresSafeArea()
                .onTapGesture { }

            let planned = workout.currentExerciseIndex < workout.plannedExercises.count ? workout.plannedExercises[workout.currentExerciseIndex] : nil
            let totalRest = planned?.restSeconds ?? 90
            let progress = totalRest > 0 ? CGFloat(restTimeRemaining) / CGFloat(totalRest) : 0

            VStack(spacing: 0) {
                Spacer(minLength: 0)

                // Just logged summary
                if let last = lastLoggedSet,
                   last.exerciseIndex < workout.session.exerciseLogs.count,
                   last.setIndex < workout.session.exerciseLogs[last.exerciseIndex].sets.count {
                    let loggedSet = workout.session.exerciseLogs[last.exerciseIndex].sets[last.setIndex]
                    let e1rm = estimatedOneRM(weight: loggedSet.weight, reps: loggedSet.reps)
                    VStack(spacing: 4) {
                        Text("JUST LOGGED")
                            .font(.system(size: 9, weight: .black))
                            .tracking(1.5)
                            .foregroundStyle(STRQBrand.steel)
                        HStack(spacing: 10) {
                            Text("Set \(loggedSet.setNumber)")
                                .font(.system(size: 11, weight: .heavy).monospacedDigit())
                                .foregroundStyle(.white.opacity(0.55))
                            Text("\(formatWeight(loggedSet.weight, increment: 0.5)) × \(loggedSet.reps)")
                                .font(.system(size: 20, weight: .heavy, design: .rounded).monospacedDigit())
                                .foregroundStyle(.white)
                            if e1rm > 0 {
                                Rectangle().fill(Color.white.opacity(0.15)).frame(width: 1, height: 14)
                                Text(String(format: "e1RM %.0f", e1rm))
                                    .font(.system(size: 11, weight: .bold).monospacedDigit())
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                    }
                    .padding(.bottom, 14)
                }

                // SET FEEL (moved above timer)
                if let last = lastLoggedSet,
                   last.exerciseIndex < workout.session.exerciseLogs.count,
                   last.setIndex < workout.session.exerciseLogs[last.exerciseIndex].sets.count {
                    let currentQuality = workout.session.exerciseLogs[last.exerciseIndex].sets[last.setIndex].quality
                    VStack(spacing: 8) {
                        Text("HOW DID THAT FEEL?")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(.white.opacity(0.4))
                            .tracking(1.5)
                        HStack(spacing: 6) {
                            ForEach(SetQuality.allCases, id: \.self) { quality in
                                let isSelected = currentQuality == quality
                                Button {
                                    setQuality(exerciseIndex: last.exerciseIndex, setIndex: last.setIndex, quality: isSelected ? nil : quality)
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: quality.icon)
                                            .font(.system(size: 13, weight: .semibold))
                                        Text(quality.shortLabel)
                                            .font(.system(size: 9, weight: .bold))
                                    }
                                    .foregroundStyle(isSelected ? .black : .white.opacity(0.7))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(
                                        isSelected
                                            ? AnyShapeStyle(qualityColor(quality.colorName))
                                            : AnyShapeStyle(Color.white.opacity(0.05)),
                                        in: .rect(cornerRadius: 11)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 11)
                                            .strokeBorder(Color.white.opacity(isSelected ? 0 : 0.06), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.strqPressable)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 18)
                }

                // Timer ring (smaller, more utility-focused)
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 5)
                        .frame(width: 168, height: 168)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            restTimeRemaining <= 10 ? STRQPalette.warning : Color.white,
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 168, height: 168)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: restTimeRemaining)

                    VStack(spacing: 4) {
                        Text("REST")
                            .font(.system(size: 10, weight: .black))
                            .tracking(2.0)
                            .foregroundStyle(.white.opacity(0.5))
                        Text(formatTime(restTimeRemaining))
                            .font(.system(size: 42, weight: .bold, design: .monospaced))
                            .foregroundStyle(restTimeRemaining <= 10 ? STRQPalette.warning : .white)
                            .contentTransition(.numericText(countsDown: true))
                    }
                }

                Spacer(minLength: 20)

                // Next set recommendation
                if let nextRec = nextSetRecommendation(workout) {
                    VStack(spacing: 5) {
                        Text("NEXT SET")
                            .font(.system(size: 9, weight: .black))
                            .foregroundStyle(.white.opacity(0.4))
                            .tracking(1.5)
                        Text(nextRec.primary)
                            .font(.system(size: 18, weight: .heavy, design: .rounded).monospacedDigit())
                            .foregroundStyle(.white)
                        Text(nextRec.detail)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white.opacity(0.55))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 18)
                    .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 14)
                }

                // Timer controls
                HStack(spacing: 12) {
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

                Spacer(minLength: 20)
            }
            .padding(.top, 36)
            .padding(.bottom, 20)
        }
    }

    private struct NextSetRec {
        let primary: String
        let detail: String
    }

    private func nextSetRecommendation(_ workout: ActiveWorkoutState) -> NextSetRec? {
        guard let last = lastLoggedSet,
              last.exerciseIndex < workout.session.exerciseLogs.count else { return nil }
        let log = workout.session.exerciseLogs[last.exerciseIndex]
        guard last.setIndex < log.sets.count else { return nil }
        let justLogged = log.sets[last.setIndex]
        // find next pending set
        let nextPending = log.sets.dropFirst(last.setIndex + 1).first(where: { !$0.isCompleted })
        guard let next = nextPending else {
            // Last set — recommend moving on
            let nextIdx = last.exerciseIndex + 1
            if nextIdx < workout.session.exerciseLogs.count {
                let nextEx = vm.library.exercise(byId: workout.session.exerciseLogs[nextIdx].exerciseId)
                return NextSetRec(
                    primary: nextEx?.name ?? "Next exercise",
                    detail: "All sets done — move on when ready"
                )
            }
            return nil
        }

        let planned = last.exerciseIndex < workout.plannedExercises.count ? workout.plannedExercises[last.exerciseIndex] : nil
        let quality = justLogged.quality
        var targetWeight = next.weight > 0 ? next.weight : justLogged.weight
        var targetReps = next.reps > 0 ? next.reps : justLogged.reps
        var guidance = "Match the last set"

        let exercise = vm.library.exercise(byId: log.exerciseId)
        let increment = weightIncrement(for: exercise)

        if let q = quality {
            switch q {
            case .tooEasy:
                targetWeight = roundTo(targetWeight + max(increment, 2.5), step: increment)
                guidance = "Last set felt easy — add load"
            case .onTarget:
                guidance = "Hold steady — same load & reps"
            case .grinder:
                guidance = "Tough finish — hold load, aim for same reps"
            case .formBreakdown:
                targetWeight = roundTo(max(0, targetWeight - max(increment, 2.5)), step: increment)
                guidance = "Form broke — drop load to clean it up"
            case .pain:
                guidance = "Pain signal — swap or skip the next set"
            }
        } else if let p = planned, let plannedTopReps = parsePlannedReps(p.reps), justLogged.reps >= plannedTopReps {
            targetWeight = roundTo(targetWeight + increment, step: increment)
            guidance = "Hit target reps — nudge weight up"
        }

        let primary: String
        if targetWeight <= 0 && (exercise?.isBodyweight ?? false) {
            primary = "Set \(next.setNumber) · BW × \(targetReps)"
        } else {
            primary = "Set \(next.setNumber) · \(formatWeight(targetWeight, increment: increment)) × \(targetReps)"
        }
        // Apply suggestion to the set so inputs pre-fill
        if next.weight != targetWeight || next.reps != targetReps {
            let setIndex = last.setIndex + 1 + (log.sets.dropFirst(last.setIndex + 1).firstIndex(where: { !$0.isCompleted }) ?? 0)
            if setIndex < log.sets.count {
                vm.updateSetLoad(exerciseIndex: last.exerciseIndex, setIndex: setIndex, weight: targetWeight, reps: targetReps)
            }
            _ = targetReps
        }

        return NextSetRec(primary: primary, detail: guidance)
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

    // MARK: - Actions & helpers

    private func activeSetFor(log: ExerciseLog, workout: ActiveWorkoutState) -> SetLog? {
        let currentSetIdx = workout.currentSetIndex
        if currentSetIdx < log.sets.count && !log.sets[currentSetIdx].isCompleted {
            return log.sets[currentSetIdx]
        }
        return log.sets.first(where: { !$0.isCompleted })
    }

    private func updateSet(exerciseIndex: Int, setIndex: Int, weight: Double, reps: Int) {
        withAnimation(.snappy(duration: 0.15)) {
            vm.updateSetLoad(exerciseIndex: exerciseIndex, setIndex: setIndex, weight: weight, reps: reps)
        }
    }

    private func completeSet(exerciseIndex: Int, setIndex: Int) {
        let rest = vm.completeCurrentSet(exerciseIndex: exerciseIndex, setIndex: setIndex)
        setCompletedTrigger.toggle()
        lastLoggedSet = (exerciseIndex, setIndex)
        guard rest > 0 else { return }
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

    private func applyNumericEdit(ctx: NumericEditContext, newValue: Double) {
        switch ctx.field {
        case .weight:
            updateSet(exerciseIndex: ctx.exerciseIndex, setIndex: ctx.setIndex, weight: max(0, newValue), reps: ctx.currentReps)
        case .reps:
            updateSet(exerciseIndex: ctx.exerciseIndex, setIndex: ctx.setIndex, weight: ctx.currentWeight, reps: max(0, Int(newValue.rounded())))
        }
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

    private func formatRPE(_ rpe: Double) -> String {
        if rpe.truncatingRemainder(dividingBy: 1) == 0 { return "\(Int(rpe))" }
        return String(format: "%.1f", rpe)
    }

    private func roundTo(_ value: Double, step: Double) -> Double {
        guard step > 0 else { return value }
        return (value / step).rounded() * step
    }

    private func parsePlannedReps(_ reps: String?) -> Int? {
        guard let r = reps else { return nil }
        let parts = r.split(whereSeparator: { !$0.isNumber })
        // Use the top of the rep range (e.g. "8-10" → 10) for "target" comparison
        if parts.count >= 2, let top = Int(parts[1]) { return top }
        if let only = parts.first.flatMap({ Int($0) }) { return only }
        return nil
    }

    private func plateMathLabel(weight: Double, exercise: Exercise?) -> String? {
        guard let ex = exercise, ex.equipment.contains(.barbell) else { return nil }
        let barWeight: Double = 20
        guard weight >= barWeight + 2.5 else { return nil }
        let perSide = (weight - barWeight) / 2.0
        let plates: [Double] = [25, 20, 15, 10, 5, 2.5, 1.25]
        var remaining = perSide
        var counts: [(Double, Int)] = []
        for p in plates {
            let c = Int(remaining / p)
            if c > 0 {
                counts.append((p, c))
                remaining -= Double(c) * p
            }
            if remaining < 0.01 { break }
        }
        guard !counts.isEmpty, remaining < 0.1 else { return nil }
        let parts = counts.map { plate, count -> String in
            let pStr = plate.truncatingRemainder(dividingBy: 1) == 0 ? "\(Int(plate))" : String(format: "%.2g", plate)
            return count > 1 ? "\(count)×\(pStr)" : pStr
        }
        return parts.joined(separator: "+") + " /side"
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

// MARK: - Numeric Input Sheet

struct NumericEditContext: Identifiable {
    enum Field { case weight, reps }
    let id = UUID()
    let field: Field
    let exerciseIndex: Int
    let setIndex: Int
    let currentWeight: Double
    let currentReps: Int
    let title: String
    let unit: String
}

private struct NumericInputSheet: View {
    let context: NumericEditContext
    let onSave: (Double) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var text: String = ""
    @FocusState private var focused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(context.unit.uppercased())
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.5)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                TextField("", text: $text)
                    .keyboardType(context.field == .weight ? .decimalPad : .numberPad)
                    .font(.system(size: 56, weight: .heavy, design: .rounded).monospacedDigit())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .focused($focused)

                HStack(spacing: 12) {
                    Button("Cancel") { dismiss() }
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(.tertiarySystemFill), in: .rect(cornerRadius: 14))

                    Button("Save") {
                        let normalized = text.replacingOccurrences(of: ",", with: ".")
                        if let value = Double(normalized) {
                            onSave(value)
                        }
                        dismiss()
                    }
                    .font(.body.weight(.heavy))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 14))
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle(context.title)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                text = context.field == .weight
                    ? (context.currentWeight.truncatingRemainder(dividingBy: 1) == 0
                        ? "\(Int(context.currentWeight))"
                        : String(format: "%.1f", context.currentWeight))
                    : "\(context.currentReps)"
                focused = true
            }
        }
    }
}
