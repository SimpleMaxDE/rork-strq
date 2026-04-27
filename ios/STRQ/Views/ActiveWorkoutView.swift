import SwiftUI

struct ActiveWorkoutView: View {
    @Bindable var vm: AppViewModel
    let onCompletionDismiss: () -> Void
    @State private var elapsedSeconds: Int = 0
    @State private var restTimerActive: Bool = false
    @State private var restTimeRemaining: Int = 0
    @State private var showExerciseInfo: Exercise?
    @State private var timerTask: Task<Void, Never>?
    @State private var appeared: Bool = false
    @State private var setCompletedTrigger: Bool = false
    @State private var showExerciseList: Bool = false
    @State private var lastLoggedSet: (exerciseIndex: Int, setIndex: Int)?
    @State private var numericEdit: NumericEditContext?
    @State private var showExitDialog: Bool = false
    @State private var confirmDiscard: Bool = false
    @State private var showSessionNoteEditor: Bool = false
    @State private var swapContextIndex: Int?
    @State private var swapConfirmationText: String?
    @State private var swapFeedbackTrigger: Bool = false
    @State private var swapFeedbackTask: Task<Void, Never>?
    @State private var undoPrompt: LoggedSetUndoPrompt?
    @State private var undoDismissTask: Task<Void, Never>?
    @State private var showWorkoutDetails: Bool = false

    private var workout: ActiveWorkoutState? { vm.activeWorkout }
    private var completedSession: WorkoutSession? { vm.completedWorkoutHandoff }

    var body: some View {
        if let completedSession {
            WorkoutCompletionView(vm: vm, session: completedSession, onDismiss: onCompletionDismiss)
        } else if let workout = workout {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 0) {
                    workoutHeader(workout)
                    progressStrip(workout)

                    GeometryReader { proxy in
                        ScrollView(.vertical) {
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

                                sessionNoteCard(workout)
                                    .padding(.horizontal, 14)

                                exerciseActions(workout)
                                    .padding(.horizontal, 14)

                                if shouldShowUpNext(workout) {
                                    upNextPreview(workout)
                                        .padding(.horizontal, 14)
                                }
                            }
                            .frame(width: proxy.size.width, alignment: .top)
                            .padding(.bottom, 100)
                        }
                    }
                }

                if restTimerActive {
                    restTimerOverlay(workout)
                }

                if let swapConfirmationText {
                    VStack {
                        swapConfirmationBanner(text: swapConfirmationText)
                            .padding(.top, 76)
                            .padding(.horizontal, 16)
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                if let undoPrompt, vm.canUndoLastCompletedSet {
                    VStack {
                        Spacer()
                        undoBanner(prompt: undoPrompt)
                            .padding(.horizontal, 16)
                            .padding(.bottom, restTimerActive ? 28 : 92)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                VStack {
                    Spacer()
                    bottomAction(workout)
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                startTimer(startTime: workout.session.startTime)
                withAnimation(.easeOut(duration: 0.4)) { appeared = true }
            }
            .onDisappear {
                timerTask?.cancel()
                swapFeedbackTask?.cancel()
                undoDismissTask?.cancel()
            }
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
            .sheet(isPresented: $showSessionNoteEditor) {
                WorkoutNoteSheet(note: workout.session.notes) { note in
                    vm.workoutController.updateWorkoutNote(note)
                }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            .sheet(item: $numericEdit) { ctx in
                NumericInputSheet(context: ctx) { newValue in
                    applyNumericEdit(ctx: ctx, newValue: newValue)
                }
                .presentationDetents([.height(280)])
                .presentationDragIndicator(.visible)
            }
            .sheet(item: Binding(
                get: { swapContextIndex.map { SwapIdx(index: $0) } },
                set: { swapContextIndex = $0?.index }
            )) { ctx in
                if ctx.index < workout.session.exerciseLogs.count {
                    let exId = workout.session.exerciseLogs[ctx.index].exerciseId
                    SwapExerciseSheet(vm: vm, dayId: workout.session.dayId, exerciseId: exId) { newExercise in
                        let previousName = vm.library.exercise(byId: exId)?.name ?? "Exercise"
                        vm.workoutController.replaceExerciseInActiveWorkout(exerciseIndex: ctx.index, with: newExercise)
                        presentSwapConfirmation(
                            oldExerciseName: previousName,
                            newExerciseName: newExercise.name,
                            isCurrentExercise: ctx.index == workout.currentExerciseIndex
                        )
                    }
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                }
            }
            .confirmationDialog(L10n.tr("Workout options"), isPresented: $showExitDialog, titleVisibility: .visible) {
                Button(L10n.tr("Save & Leave")) {
                    saveAndLeave()
                }
                Button(L10n.tr("Discard Workout"), role: .destructive) {
                    confirmDiscard = true
                }
                Button(L10n.tr("Continue Workout"), role: .cancel) { }
            } message: {
                Text(L10n.tr("Save & Leave preserves everything you've logged and keeps this workout ready to resume from Today."))
            }
            .confirmationDialog(L10n.tr("Discard Workout?"), isPresented: $confirmDiscard, titleVisibility: .visible) {
                Button(L10n.tr("Discard Workout"), role: .destructive) {
                    vm.workoutController.discardWorkout()
                }
                Button(L10n.tr("Keep Workout"), role: .cancel) { }
            } message: {
                Text(L10n.tr("All logged sets for this session will be lost. This can't be undone."))
            }
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.6), trigger: setCompletedTrigger)
            .sensoryFeedback(.success, trigger: swapFeedbackTrigger)
        }
    }

    private struct LoggedSetUndoPrompt {
        let title: String
        let subtitle: String
    }

    // MARK: - Header

    private func workoutHeader(_ workout: ActiveWorkoutState) -> some View {
        let total = workout.session.exerciseLogs.count
        let done = workout.session.exerciseLogs.filter(\.isCompleted).count
        return HStack(alignment: .center, spacing: 10) {
            Button { showExitDialog = true } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white.opacity(0.75))
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.06), in: Circle())
            }
            .buttonStyle(.strqPressable)
            .accessibilityLabel(L10n.tr("Workout options"))

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
                finishWorkout()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 11, weight: .bold))
                    Text(L10n.tr("Finish Workout"))
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundStyle(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(STRQBrand.accentGradient, in: Capsule())
            }
            .accessibilityLabel(L10n.tr("Finish workout"))
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
                                Text(L10n.format("EX %d/%d", exerciseIndex + 1, workout.session.exerciseLogs.count))
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
                                Text(L10n.format("SET %d/%d", activeSetNumber, log.sets.count))
                                    .font(.system(size: 10, weight: .heavy).monospacedDigit())
                                    .tracking(0.8)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(Color.white.opacity(0.15), in: Capsule())
                            }

                            HStack(spacing: 10) {
                                ExerciseThumbnail(exercise: ex, size: .small, cornerRadius: 8)
                                    .frame(width: 44, height: 44)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(ex.name)
                                        .font(.system(size: 17, weight: .heavy))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)

                                    HStack(spacing: 6) {
                                        if let p = planned {
                                            Text(L10n.format("Target %@", p.reps))
                                                .font(.system(size: 10, weight: .bold).monospacedDigit())
                                                .foregroundStyle(.white.opacity(0.78))
                                            if let rpe = p.rpe {
                                                Text("·").foregroundStyle(.white.opacity(0.3))
                                                Text(L10n.format("RPE %@", formatRPE(rpe)))
                                                    .font(.system(size: 10, weight: .bold).monospacedDigit())
                                                    .foregroundStyle(.white.opacity(0.6))
                                            }
                                            Text("·").foregroundStyle(.white.opacity(0.3))
                                            Text(L10n.format("%ds rest", p.restSeconds))
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
                    workoutDetailsDisclosure(log: log, planned: planned, guidance: guidance)
                        .padding(.top, 6)

                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(.easeOut(duration: 0.4), value: appeared)
            }
        }
    }

    private func workoutDetailsDisclosure(
        log: ExerciseLog,
        planned: PlannedExercise?,
        guidance: NextSessionGuidance?
    ) -> some View {
        VStack(spacing: 6) {
            Button {
                withAnimation(.snappy(duration: 0.2)) {
                    showWorkoutDetails.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 10, weight: .semibold))
                    Text(L10n.tr("common.details", fallback: "Details"))
                        .font(.system(size: 11, weight: .semibold))
                    Spacer(minLength: 0)
                    Image(systemName: showWorkoutDetails ? "chevron.up" : "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundStyle(.white.opacity(0.56))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.white.opacity(0.035), in: .rect(cornerRadius: 9))
            }
            .buttonStyle(.plain)

            if showWorkoutDetails {
                contextStrip(log: log, planned: planned)

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
                }
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
                label: L10n.tr("PREV"),
                primary: last.map { "\(formatWeight($0.topWeight, increment: 0.5))×\($0.topReps)" } ?? "—",
                secondary: last.map { formatRelativeDate($0.date) } ?? L10n.tr("no data")
            )
            contextDivider()
            contextCell(
                label: L10n.tr("BEST"),
                primary: best.map { "\(formatWeight($0.weight, increment: 0.5))×\($0.reps)" } ?? "—",
                secondary: best.map { L10n.format("e1RM %.0f", $0.e1rm) } ?? "—"
            )
            contextDivider()
            contextCell(
                label: L10n.tr("TARGET"),
                primary: suggestion.map { $0.suggestedWeight > 0 ? formatWeight($0.suggestedWeight, increment: 0.5) : L10n.tr("BW") } ?? "—",
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
                    activeTaskHeader(
                        exercise: exerciseForIncrement,
                        currentSet: setLog,
                        totalSets: log.sets.count
                    )

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
                            label: isBodyweight ? L10n.tr("ADDED LOAD") : L10n.tr("WEIGHT"),
                            value: isBodyweight && setLog.weight <= 0 ? L10n.tr("BW") : formatWeight(setLog.weight, increment: increment),
                            unit: isBodyweight ? L10n.tr("kg added") : "kg",
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
                                    title: L10n.tr("Edit Weight"),
                                    unit: isBodyweight ? L10n.tr("kg added") : "kg"
                                )
                            },
                            plateMath: plateMathLabel(weight: setLog.weight, exercise: exerciseForIncrement)
                        )
                        .frame(maxWidth: .infinity)

                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 1, height: 64)

                        inputColumn(
                            label: L10n.tr("REPS"),
                            value: "\(setLog.reps)",
                            unit: L10n.tr("reps"),
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
                                    title: L10n.tr("Edit Reps"),
                                    unit: L10n.tr("reps")
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
                            Text(L10n.format("Log Set %d", setLog.setNumber))
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
                let isLastExercise = exerciseIndex >= workout.session.exerciseLogs.count - 1
                VStack(spacing: 10) {
                    Image(systemName: isLastExercise ? "flag.checkered" : "checkmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(isLastExercise ? STRQBrand.steel : STRQPalette.success)
                    Text(isLastExercise ? L10n.tr("Last exercise complete") : L10n.tr("Exercise complete"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(isLastExercise ? L10n.tr("Finish Workout when you're ready to save this session.") : L10n.tr("Move to the next exercise when you're ready."))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 22)
                .padding(.horizontal, 16)
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
                        label: L10n.tr("Match last"),
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
                        label: L10n.tr("Target"),
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
                        Text(L10n.tr("LAST"))
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

    private func sessionNoteCard(_ workout: ActiveWorkoutState) -> some View {
        let note = workout.session.notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasNote = !note.isEmpty

        return Button {
            showSessionNoteEditor = true
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: hasNote ? "note.text" : "square.and.pencil")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(hasNote ? .white : STRQBrand.steel)
                    .frame(width: 36, height: 36)
                    .background(hasNote ? Color.white.opacity(0.06) : STRQBrand.steel.opacity(0.14), in: .rect(cornerRadius: 11))

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.tr("Session Note"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(hasNote ? note : L10n.tr("Add one quick thought to remember how this session felt."))
                        .font(.footnote)
                        .foregroundStyle(hasNote ? .white.opacity(0.72) : .white.opacity(0.48))
                        .multilineTextAlignment(.leading)
                        .lineLimit(hasNote ? 3 : 2)
                    Text(hasNote ? L10n.tr("Saved with this workout") : L10n.tr("Optional"))
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.7)
                        .foregroundStyle(.white.opacity(0.34))
                        .textCase(.uppercase)
                }

                Spacer(minLength: 12)

                Text(hasNote ? L10n.tr("Edit") : L10n.tr("Add"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.82))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.06), in: Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.025), in: .rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.strqPressable)
        .accessibilityLabel(hasNote ? L10n.tr("Edit session note") : L10n.tr("Add session note"))
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
        if days <= 0 { return L10n.tr("today") }
        if days == 1 { return L10n.tr("yesterday") }
        if days < 7 { return L10n.format("%dd ago", days) }
        if days < 30 { return L10n.format("%dw ago", days / 7) }
        let f = DateFormatter()
        f.locale = Locale.current
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
                    .frame(width: 40, height: 38)
            }
            .disabled(workout.currentExerciseIndex == 0)

            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 1, height: 18)

            if let exercise = vm.library.exercise(byId: workout.session.exerciseLogs[workout.currentExerciseIndex].exerciseId) {
                Button { showExerciseInfo = exercise } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "info.circle")
                            .font(.caption2.weight(.semibold))
                        Text(L10n.tr("Exercise Guide"))
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

            Button { swapContextIndex = workout.currentExerciseIndex } label: {
                HStack(spacing: 5) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.caption2.weight(.semibold))
                    Text(L10n.tr("Swap Exercise"))
                        .font(.footnote.weight(.semibold))
                }
                .foregroundStyle(.white.opacity(0.75))
                .frame(maxWidth: .infinity)
                .frame(height: 38)
            }
            .accessibilityLabel(L10n.tr("Swap exercise"))

            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 1, height: 18)

            Button { moveToNextExercise() } label: {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(workout.currentExerciseIndex >= workout.session.exerciseLogs.count - 1 ? AnyShapeStyle(.quaternary) : AnyShapeStyle(Color.white.opacity(0.55)))
                    .frame(width: 40, height: 38)
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
                    Text(L10n.tr("UP NEXT"))
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(.white.opacity(0.9))
                        .tracking(1.4)
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 0.5)
                    Text(L10n.format("%d left", total))
                        .font(.system(size: 10, weight: .bold).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.55))
                }

                VStack(spacing: 6) {
                    ForEach(Array(remaining.enumerated()), id: \.element.id) { offset, log in
                        upNextRow(log: log, isImmediate: offset == 0, positionLabel: offset == 0 ? L10n.tr("NEXT") : L10n.tr("THEN"))
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func upNextRow(log: ExerciseLog, isImmediate: Bool, positionLabel: String) -> some View {
        let exercise = vm.library.exercise(byId: log.exerciseId)
        let tileSize: CGFloat = isImmediate ? 36 : 30

        HStack(spacing: 12) {
            if let ex = exercise {
                ExerciseThumbnail(exercise: ex, size: isImmediate ? .small : .mini, cornerRadius: 9)
                    .frame(width: tileSize, height: tileSize)
                    .opacity(isImmediate ? 1 : 0.78)
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
                    Text(L10n.format("%@ · %d sets", ex.primaryMuscle.localizedDisplayName, log.sets.count))
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

    private func undoBanner(prompt: LoggedSetUndoPrompt) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(prompt.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(prompt.subtitle)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(1)
            }

            Spacer(minLength: 12)

            Button {
                undoLastCompletedSet()
            } label: {
                Text(L10n.tr("Undo"))
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(STRQBrand.accentGradient, in: Capsule())
            }
            .buttonStyle(.strqPressable)
            .accessibilityLabel(L10n.tr("Undo last logged set"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.08), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 16, y: 8)
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
                    VStack(spacing: 10) {
                        Text(L10n.tr("All sets are logged. Finish Workout to hand this session back to Today."))
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                        Button {
                            finishWorkout()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "flag.checkered")
                                    .font(.subheadline)
                                Text(L10n.tr("Finish Workout"))
                                    .font(.body.weight(.bold))
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 16))
                        }
                    }
                } else if allCurrentSetsDone && !isLastExercise {
                    VStack(spacing: 10) {
                        Text(L10n.tr("Current exercise is complete. Move on when you're ready."))
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                        Button { moveToNextExercise() } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.right")
                                    .font(.subheadline)
                                Text(L10n.tr("Next Exercise"))
                                    .font(.body.weight(.bold))
                            }
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 16))
                        }
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
        let planned = workout.currentExerciseIndex < workout.plannedExercises.count ? workout.plannedExercises[workout.currentExerciseIndex] : nil
        let totalRest = planned?.restSeconds ?? 90
        let progress = totalRest > 0 ? CGFloat(restTimeRemaining) / CGFloat(totalRest) : 0

        ZStack {
            Color.black.opacity(0.84).ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 0) {
                Spacer(minLength: 20)

                VStack(spacing: 18) {
                    if let last = lastLoggedSet,
                       last.exerciseIndex < workout.session.exerciseLogs.count,
                       last.setIndex < workout.session.exerciseLogs[last.exerciseIndex].sets.count {
                        let log = workout.session.exerciseLogs[last.exerciseIndex]
                        let loggedSet = log.sets[last.setIndex]
                        let exerciseName = vm.library.exercise(byId: log.exerciseId)?.name ?? "Exercise"
                        let e1rm = estimatedOneRM(weight: loggedSet.weight, reps: loggedSet.reps)
                        let currentQuality = loggedSet.quality

                        VStack(alignment: .leading, spacing: 14) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(L10n.tr("JUST LOGGED"))
                                    .font(.system(size: 9, weight: .black))
                                    .tracking(1.5)
                                    .foregroundStyle(STRQBrand.steel)
                                Text(exerciseName)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.85)
                                Text(L10n.format("Set %d · %@ × %d", loggedSet.setNumber, formatWeight(loggedSet.weight, increment: 0.5), loggedSet.reps))
                                    .font(.system(size: 24, weight: .heavy, design: .rounded).monospacedDigit())
                                    .foregroundStyle(.white)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                if e1rm > 0 {
                                    Text(L10n.format("Estimated 1RM %.0f", e1rm))
                                        .font(.caption.weight(.semibold).monospacedDigit())
                                        .foregroundStyle(.white.opacity(0.52))
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text(L10n.tr("How did that feel?"))
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white.opacity(0.48))
                                HStack(spacing: 8) {
                                    ForEach(SetQuality.allCases, id: \.self) { quality in
                                        let isSelected = currentQuality == quality
                                        Button {
                                            setQuality(exerciseIndex: last.exerciseIndex, setIndex: last.setIndex, quality: isSelected ? nil : quality)
                                        } label: {
                                            VStack(spacing: 4) {
                                                Image(systemName: quality.icon)
                                                    .font(.system(size: 13, weight: .semibold))
                                                Text(quality.shortLabel)
                                                    .font(.caption2.weight(.bold))
                                                    .lineLimit(1)
                                            }
                                            .foregroundStyle(isSelected ? .black : .white.opacity(0.74))
                                            .frame(maxWidth: .infinity)
                                            .frame(minHeight: 50)
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
                                        .buttonStyle(.strqPressable)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05), in: .rect(cornerRadius: 20))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                        )
                    }

                    VStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.06), lineWidth: 6)
                                .frame(width: 176, height: 176)
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(
                                    restTimeRemaining <= 10 ? STRQPalette.warning : Color.white,
                                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                                )
                                .frame(width: 176, height: 176)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 1), value: restTimeRemaining)

                            VStack(spacing: 6) {
                                Text(L10n.tr("REST"))
                                    .font(.system(size: 10, weight: .black))
                                    .tracking(2.0)
                                    .foregroundStyle(.white.opacity(0.46))
                                Text(formatTime(restTimeRemaining))
                                    .font(.system(size: 42, weight: .bold, design: .monospaced))
                                    .foregroundStyle(restTimeRemaining <= 10 ? STRQPalette.warning : .white)
                                    .contentTransition(.numericText(countsDown: true))
                            }
                        }

                        Text(restCountdownHint())
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.58))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)

                    if let nextRec = nextSetRecommendation(workout) {
                        restNextActionCard(nextRec)
                    }

                    HStack(spacing: 12) {
                        restTimerAdjustmentButton(title: "−15s") {
                            let updatedTime = max(0, restTimeRemaining - 15)
                            restTimeRemaining = updatedTime
                            if updatedTime == 0 {
                                restTimerActive = false
                            }
                        }

                        Button {
                            restTimeRemaining = 0
                            restTimerActive = false
                        } label: {
                            Text(L10n.tr("Continue Now"))
                                .font(.body.weight(.bold))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(STRQBrand.accentGradient, in: Capsule())
                        }
                        .buttonStyle(.strqPressable)
                        .accessibilityLabel(L10n.tr("Continue workout now"))

                        restTimerAdjustmentButton(title: "+15s") {
                            restTimeRemaining += 15
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: 380)
                .background(
                    LinearGradient(
                        colors: [Color.white.opacity(0.08), Color.white.opacity(0.04)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: .rect(cornerRadius: 28)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 22, y: 12)
                .padding(.horizontal, 20)

                Spacer(minLength: 92)
            }
        }
    }

    private func restTimerAdjustmentButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white.opacity(0.78))
                .frame(width: 72, height: 46)
                .background(Color.white.opacity(0.05), in: Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        }
        .buttonStyle(.strqPressable)
    }

    private func restCountdownHint() -> String {
        if restTimeRemaining <= 10 {
            return L10n.tr("Get set for the next effort.")
        }
        if restTimeRemaining <= 30 {
            return L10n.tr("Reset, then go again.")
        }
        return L10n.tr("activeWorkout.rest.nextQueued", fallback: "Next set is ready.")
    }

    private func restNextActionCard(_ nextRec: NextSetRec) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Image(systemName: nextRec.icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(nextRec.tint)
                .frame(width: 40, height: 40)
                .background(nextRec.tint.opacity(0.16), in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 5) {
                Text(nextRec.eyebrow)
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.4)
                    .foregroundStyle(nextRec.tint)
                Text(nextRec.primary)
                    .font(nextRec.usesMonospacedPrimary ? .system(size: 20, weight: .heavy, design: .rounded).monospacedDigit() : .title3.weight(.heavy))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                Text(nextRec.detail)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(.white.opacity(0.58))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.05), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(nextRec.tint.opacity(0.22), lineWidth: 1)
        )
    }

    private struct NextSetRec {
        let eyebrow: String
        let primary: String
        let detail: String
        let icon: String
        let tint: Color
        let usesMonospacedPrimary: Bool
    }

    private func nextSetRecommendation(_ workout: ActiveWorkoutState) -> NextSetRec? {
        guard let last = lastLoggedSet,
              last.exerciseIndex < workout.session.exerciseLogs.count else { return nil }
        let log = workout.session.exerciseLogs[last.exerciseIndex]
        guard last.setIndex < log.sets.count else { return nil }
        let justLogged = log.sets[last.setIndex]
        let nextPending = log.sets.dropFirst(last.setIndex + 1).first(where: { !$0.isCompleted })

        guard let next = nextPending else {
            let nextIdx = last.exerciseIndex + 1
            if nextIdx < workout.session.exerciseLogs.count {
                let nextEx = vm.library.exercise(byId: workout.session.exerciseLogs[nextIdx].exerciseId)
                return NextSetRec(
                    eyebrow: L10n.tr("NEXT EXERCISE"),
                    primary: nextEx?.name ?? L10n.tr("Next exercise"),
                    detail: L10n.tr("This lift is done. Move on when the rest feels right."),
                    icon: "arrow.right.circle.fill",
                    tint: STRQBrand.steel,
                    usesMonospacedPrimary: false
                )
            }
            return NextSetRec(
                eyebrow: L10n.tr("WORKOUT READY"),
                primary: L10n.tr("Finish Workout"),
                detail: L10n.tr("All working sets are logged. Finish when you're ready."),
                icon: "flag.checkered",
                tint: STRQPalette.success,
                usesMonospacedPrimary: false
            )
        }

        let planned = last.exerciseIndex < workout.plannedExercises.count ? workout.plannedExercises[last.exerciseIndex] : nil
        let quality = justLogged.quality
        var targetWeight = next.weight > 0 ? next.weight : justLogged.weight
        var targetReps = next.reps > 0 ? next.reps : justLogged.reps
        var guidance = "Repeat the last set cleanly."
        var icon = "figure.strengthtraining.traditional"
        var tint: Color = STRQBrand.steel

        let exercise = vm.library.exercise(byId: log.exerciseId)
        let increment = weightIncrement(for: exercise)

        if let q = quality {
            switch q {
            case .tooEasy:
                targetWeight = roundTo(targetWeight + max(increment, 2.5), step: increment)
                guidance = "Felt easy. Add a small bump and keep the reps clean."
                icon = "arrow.up.right.circle.fill"
                tint = STRQPalette.success
            case .onTarget:
                guidance = "Stay here. Same load, same standard."
                icon = "checkmark.circle.fill"
                tint = STRQBrand.steel
            case .grinder:
                guidance = "Hold the load. Match the reps if they're still clean."
                icon = "minus.circle.fill"
                tint = STRQPalette.warning
            case .formBreakdown:
                targetWeight = roundTo(max(0, targetWeight - max(increment, 2.5)), step: increment)
                guidance = "Drop the load slightly and keep the pattern smooth."
                icon = "arrow.down.right.circle.fill"
                tint = STRQPalette.warning
            case .pain:
                guidance = "Pain noted. Swap or stop this movement if it doesn't settle."
                icon = "exclamationmark.triangle.fill"
                tint = STRQPalette.danger
            }
        } else if let p = planned, let plannedTopReps = parsePlannedReps(p.reps), justLogged.reps >= plannedTopReps {
            targetWeight = roundTo(targetWeight + increment, step: increment)
            guidance = "Top of the range hit. Nudge the load up."
            icon = "arrow.up.right.circle.fill"
            tint = STRQPalette.success
        }

        let primary: String
        if targetWeight <= 0 && (exercise?.isBodyweight ?? false) {
            primary = "Set \(next.setNumber) · BW × \(targetReps)"
        } else {
            primary = "Set \(next.setNumber) · \(formatWeight(targetWeight, increment: increment)) × \(targetReps)"
        }

        if next.weight != targetWeight || next.reps != targetReps {
            let setIndex = last.setIndex + 1 + (log.sets.dropFirst(last.setIndex + 1).firstIndex(where: { !$0.isCompleted }) ?? 0)
            if setIndex < log.sets.count {
                vm.updateSetLoad(exerciseIndex: last.exerciseIndex, setIndex: setIndex, weight: targetWeight, reps: targetReps)
            }
            _ = targetReps
        }

        return NextSetRec(
            eyebrow: L10n.tr("NEXT SET"),
            primary: primary,
            detail: guidance,
            icon: icon,
            tint: tint,
            usesMonospacedPrimary: true
        )
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
                            ZStack(alignment: .topTrailing) {
                                if let ex = exercise {
                                    ExerciseThumbnail(exercise: ex, size: .small, cornerRadius: 9)
                                        .opacity(log.isCompleted ? 0.55 : 1)
                                } else {
                                    RoundedRectangle(cornerRadius: 9)
                                        .fill(Color.white.opacity(0.08))
                                        .frame(width: 44, height: 44)
                                }
                                ZStack {
                                    Circle()
                                        .fill(log.isCompleted ? STRQPalette.success : isCurrent ? Color.white : Color.black.opacity(0.7))
                                        .frame(width: 18, height: 18)
                                    if log.isCompleted {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundStyle(.white)
                                    } else {
                                        Text("\(index + 1)")
                                            .font(.system(size: 9, weight: .bold).monospacedDigit())
                                            .foregroundStyle(isCurrent ? .black : .white.opacity(0.7))
                                    }
                                }
                                .offset(x: 5, y: -5)
                            }
                            .frame(width: 44, height: 44)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(exercise?.name ?? log.exerciseId)
                                    .font(.subheadline.weight(isCurrent ? .bold : .medium))
                                    .foregroundStyle(isCurrent ? .white : .primary)
                                Text(L10n.format("%d/%d sets", completedSets, totalSets))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            if isCurrent {
                                Text(L10n.tr("Active"))
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(STRQBrand.steel)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(STRQBrand.steel.opacity(0.12), in: Capsule())
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            showExerciseList = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                swapContextIndex = index
                            }
                        } label: {
                            Label(L10n.tr("Swap Exercise"), systemImage: "arrow.triangle.2.circlepath")
                        }
                        .tint(STRQBrand.steel)
                    }
                }
            }
            .navigationTitle(L10n.tr("Exercises"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.tr("Done")) { showExerciseList = false }
                }
            }
        }
    }

    // MARK: - Actions & helpers

    private func swapConfirmationBanner(text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(STRQPalette.success)
            Text(text)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.08), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    private func presentSwapConfirmation(oldExerciseName: String, newExerciseName: String, isCurrentExercise: Bool) {
        let message = isCurrentExercise
            ? L10n.format("Current exercise updated to %@", newExerciseName)
            : L10n.format("Swapped %@ for %@", oldExerciseName, newExerciseName)
        swapFeedbackTask?.cancel()
        withAnimation(.easeOut(duration: 0.2)) {
            swapConfirmationText = message
        }
        swapFeedbackTrigger.toggle()
        swapFeedbackTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation(.easeOut(duration: 0.2)) {
                    swapConfirmationText = nil
                }
            }
        }
    }

    private func saveAndLeave() {
        dismissUndoPrompt()
        restTimerActive = false
        showExitDialog = false
        vm.workoutController.pauseWorkout()
    }

    private func finishWorkout() {
        dismissUndoPrompt()
        restTimerActive = false
        showExitDialog = false
        confirmDiscard = false
        vm.completeWorkout()
    }

    private func activeTaskHeader(exercise: Exercise?, currentSet: SetLog?, totalSets: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(currentSet == nil ? L10n.tr("NEXT ACTION") : L10n.tr("CURRENT TASK"))
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.0)
                    .foregroundStyle(.white.opacity(0.45))
                Text(taskHeaderTitle(exercise: exercise, currentSet: currentSet, totalSets: totalSets))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                Text(taskHeaderDetail(currentSet: currentSet, totalSets: totalSets))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            if let exercise {
                Button {
                    showExerciseInfo = exercise
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "info.circle")
                            .font(.caption.weight(.semibold))
                        Text(L10n.tr("Exercise Guide"))
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(.white.opacity(0.82))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.06), in: Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
                }
                .buttonStyle(.strqPressable)
            }
        }
    }

    private func taskHeaderTitle(exercise: Exercise?, currentSet: SetLog?, totalSets: Int) -> String {
        let exerciseName = exercise?.name ?? L10n.tr("Exercise")
        if let currentSet {
            return L10n.format("Log set %d of %d for %@", currentSet.setNumber, totalSets, exerciseName)
        }
        return L10n.format("All sets logged for %@", exerciseName)
    }

    private func taskHeaderDetail(currentSet: SetLog?, totalSets: Int) -> String {
        if let currentSet {
            return L10n.tr("Rest as needed. Adjust load or reps by feel.")
        }
        return totalSets == 0 ? L10n.tr("This exercise is ready.") : L10n.tr("Use the bottom action to move forward when you're ready.")
    }

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
        let prompt = undoPromptDetails(exerciseIndex: exerciseIndex, setIndex: setIndex)
        let rest = vm.completeCurrentSet(exerciseIndex: exerciseIndex, setIndex: setIndex)
        setCompletedTrigger.toggle()
        lastLoggedSet = (exerciseIndex, setIndex)
        if let prompt {
            presentUndoPrompt(prompt)
        }
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

    private func undoPromptDetails(exerciseIndex: Int, setIndex: Int) -> LoggedSetUndoPrompt? {
        guard let workout,
              exerciseIndex < workout.session.exerciseLogs.count,
              setIndex < workout.session.exerciseLogs[exerciseIndex].sets.count else { return nil }
        let set = workout.session.exerciseLogs[exerciseIndex].sets[setIndex]
        let exerciseId = workout.session.exerciseLogs[exerciseIndex].exerciseId
        let exerciseName = vm.library.exercise(byId: exerciseId)?.name ?? L10n.tr("Exercise")
        return LoggedSetUndoPrompt(
            title: L10n.format("Set %d logged", set.setNumber),
            subtitle: L10n.format("%@ · %@ × %d", exerciseName, formatWeight(set.weight, increment: 0.5), set.reps)
        )
    }

    private func presentUndoPrompt(_ prompt: LoggedSetUndoPrompt) {
        undoDismissTask?.cancel()
        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
            undoPrompt = prompt
        }
        undoDismissTask = Task {
            try? await Task.sleep(for: .seconds(4))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                dismissUndoPrompt()
            }
        }
    }

    private func dismissUndoPrompt() {
        undoDismissTask?.cancel()
        undoDismissTask = nil
        vm.clearLastCompletedSetUndo()
        withAnimation(.easeOut(duration: 0.2)) {
            undoPrompt = nil
        }
    }

    private func undoLastCompletedSet() {
        let restored = vm.undoLastCompletedSet()
        undoDismissTask?.cancel()
        undoDismissTask = nil
        withAnimation(.easeOut(duration: 0.2)) {
            undoPrompt = nil
        }
        guard restored else { return }
        restTimerActive = false
        restTimeRemaining = 0
        lastLoggedSet = nil
    }

    private func startTimer(startTime: Date) {
        timerTask?.cancel()
        elapsedSeconds = max(0, Int(Date().timeIntervalSince(startTime)))
        timerTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { break }
                elapsedSeconds = max(0, Int(Date().timeIntervalSince(startTime)))
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

private struct WorkoutNoteSheet: View {
    let note: String
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var draftNote: String = ""
    @FocusState private var focused: Bool

    private var trimmedNote: String {
        draftNote.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text(L10n.tr("Keep one quick note for this workout."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TextField(L10n.tr("How did this session feel?"), text: $draftNote, axis: .vertical)
                    .lineLimit(4...8)
                    .padding(14)
                    .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color(.separator).opacity(0.35), lineWidth: 1)
                    )
                    .focused($focused)

                Text(trimmedNote.isEmpty ? L10n.tr("Optional. Save a cue, win, or anything you want to remember next time.") : L10n.tr("This note stays attached to the saved session."))
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }
            .padding(20)
            .navigationTitle(L10n.tr("Session Note"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(L10n.tr("Cancel")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(trimmedNote.isEmpty ? L10n.tr("Done") : L10n.tr("Save")) {
                        onSave(trimmedNote)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button(L10n.tr("Done")) {
                        focused = false
                    }
                }
            }
            .onAppear {
                draftNote = note
                focused = note.isEmpty
            }
        }
    }
}

private struct SwapIdx: Identifiable {
    let index: Int
    var id: Int { index }
}

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
                    Button(L10n.tr("Cancel")) { dismiss() }
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(.tertiarySystemFill), in: .rect(cornerRadius: 14))

                    Button(L10n.tr("Save")) {
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
