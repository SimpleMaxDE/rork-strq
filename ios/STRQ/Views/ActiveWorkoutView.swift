import SwiftUI

struct ActiveWorkoutView: View {
    @Bindable var vm: AppViewModel
    let onCompletionDismiss: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
    @State private var workoutCompletedTrigger: Bool = false

    private var workout: ActiveWorkoutState? { vm.activeWorkout }
    private var completedSession: WorkoutSession? { vm.completedWorkoutHandoff }

    private var activeWorkoutPanelFill: LinearGradient {
        LinearGradient(
            colors: [
                activeWorkoutSignal.opacity(0.07),
                STRQPalette.surfaceStrong.opacity(0.92),
                STRQPalette.surfaceRaised.opacity(0.88),
                STRQPalette.backgroundCarbon.opacity(0.96)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var activeWorkoutSignal: Color {
        Color(red: 0.48, green: 0.74, blue: 0.68)
    }

    private var activeWorkoutControlFill: Color {
        Color.white.opacity(0.055)
    }

    private var activeWorkoutControlStroke: Color {
        Color.white.opacity(0.105)
    }

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

                                if restTimerActive {
                                    afterLogStateLine(workout)
                                        .padding(.horizontal, 14)
                                } else if let undoPrompt, vm.canUndoLastCompletedSet {
                                    undoBanner(prompt: undoPrompt)
                                        .padding(.horizontal, 14)
                                }

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
                            .padding(.bottom, 140)
                        }
                    }
                }
                .blur(radius: restTimerActive ? 0.2 : 0)
                .saturation(restTimerActive ? 0.82 : 1)
                .opacity(restTimerActive ? 0.58 : 1)
                .allowsHitTesting(!restTimerActive)

                if let swapConfirmationText {
                    VStack {
                        swapConfirmationBanner(text: swapConfirmationText)
                            .padding(.top, 76)
                            .padding(.horizontal, 16)
                        Spacer()
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                VStack {
                    Spacer()
                    bottomAction(workout)
                }
                .blur(radius: restTimerActive ? 0.2 : 0)
                .opacity(restTimerActive ? 0.48 : 1)
                .allowsHitTesting(!restTimerActive)

                if restTimerActive {
                    restTimerOverlay(workout)
                        .zIndex(3)
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                startTimer(startTime: workout.session.startTime)
                withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.4)) { appeared = true }
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
                Text(L10n.tr("All logged sets for this workout will be lost. This can't be undone."))
            }
            .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.6), trigger: setCompletedTrigger)
            .sensoryFeedback(.success, trigger: swapFeedbackTrigger)
            .sensoryFeedback(.success, trigger: workoutCompletedTrigger)
            .accessibilityIdentifier("strq.active-workout.root")
        }
    }

    private struct LoggedSetUndoPrompt {
        let title: String
        let subtitle: String
    }

    // MARK: - Header

    private func workoutHeader(_ workout: ActiveWorkoutState) -> some View {
        let total = workout.session.exerciseLogs.count
        let currentExercise = total > 0 ? min(max(workout.currentExerciseIndex + 1, 1), total) : 0
        return HStack(alignment: .center, spacing: 10) {
            Button { showExitDialog = true } label: {
                Image(systemName: "chevron.down")
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(STRQPalette.textSecondary)
                    .frame(width: 38, height: 38)
                    .background(activeWorkoutControlFill, in: Circle())
                    .overlay(Circle().strokeBorder(activeWorkoutControlStroke, lineWidth: 1))
            }
            .buttonStyle(.strqPressable)
            .accessibilityLabel(L10n.tr("Workout options"))

            VStack(alignment: .leading, spacing: 2) {
                Text(workout.session.dayName.uppercased())
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.25)
                    .foregroundStyle(STRQPalette.textMuted.opacity(0.95))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Text(formatTime(elapsedSeconds))
                    .font(.system(size: 24, weight: .black, design: .rounded).monospacedDigit())
                    .foregroundStyle(STRQPalette.textPrimary)
                    .contentTransition(.numericText())
            }
            .layoutPriority(1)

            Spacer(minLength: 8)

            Button { showExerciseList = true } label: {
                HStack(spacing: 6) {
                    Text(L10n.format("EX %d/%d", currentExercise, total))
                        .font(.system(size: 12, weight: .black, design: .rounded).monospacedDigit())
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                    Image(systemName: "list.bullet")
                        .font(.system(size: 10, weight: .heavy))
                }
                .foregroundStyle(activeWorkoutSignal.opacity(0.82))
                .padding(.horizontal, 10)
                .frame(height: 36)
                .background(Color.white.opacity(0.055), in: Capsule())
                .overlay(Capsule().strokeBorder(activeWorkoutSignal.opacity(0.12), lineWidth: 1))
            }
            .buttonStyle(.strqPressable)
            .accessibilityLabel(L10n.format("%@ %d/%d", L10n.tr("Exercise"), currentExercise, total))
            .accessibilityHint(L10n.tr("Opens exercise list"))
            .layoutPriority(1)

            Button {
                finishWorkout()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 10, weight: .bold))
                    Text(L10n.tr("Finish Workout"))
                        .font(.system(size: 11, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
                .foregroundStyle(STRQPalette.textMuted)
                .padding(.horizontal, 9)
                .frame(height: 32)
                .background(Color.white.opacity(0.028), in: Capsule())
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.065), lineWidth: 1))
            }
            .buttonStyle(.strqPressable)
            .accessibilityLabel(L10n.tr("Finish workout"))
            .layoutPriority(1)
        }
        .padding(.horizontal, 14)
        .padding(.top, 28)
        .padding(.bottom, 9)
        .background {
            LinearGradient(
                colors: [STRQPalette.surfaceBase.opacity(0.96), activeWorkoutSignal.opacity(0.025), STRQPalette.backgroundCarbon.opacity(0.93)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.white.opacity(0.055))
                .frame(height: 0.5)
        }
    }

    private func progressStrip(_ workout: ActiveWorkoutState) -> some View {
        let total = workout.session.exerciseLogs.count
        let completed = workout.session.exerciseLogs.filter(\.isCompleted).count
        let progress = total > 0 ? CGFloat(completed) / CGFloat(total) : 0

        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.white.opacity(0.06))
                Capsule().fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.72), STRQBrand.steel.opacity(0.58)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                    .frame(width: geo.size.width * progress)
                    .animation(reduceMotion ? .easeOut(duration: 0.12) : .spring(response: 0.4), value: progress)
            }
        }
        .frame(height: 4)
        .padding(.horizontal, 14)
        .padding(.top, 0)
        .padding(.bottom, 9)
        .background(STRQPalette.backgroundCarbon.opacity(0.92))
    }

    // MARK: - Current Task Block (fused hero + meta + context)

    @ViewBuilder
    private func currentTaskBlock(_ workout: ActiveWorkoutState) -> some View {
        let exerciseIndex = workout.currentExerciseIndex
        if exerciseIndex < workout.session.exerciseLogs.count {
            let log = workout.session.exerciseLogs[exerciseIndex]
            let exercise = vm.library.exercise(byId: log.exerciseId)
            let planned = exerciseIndex < workout.plannedExercises.count ? workout.plannedExercises[exerciseIndex] : nil
            let today = planned.map { vm.todayPrescription(for: $0) }
            let mediaProvider = ExerciseMediaProvider.shared
            let currentSet = activeSetFor(log: log, workout: workout)
            let activeSetNumber = currentSet?.setNumber ?? (log.sets.filter(\.isCompleted).count + 1)
            let guidance = vm.nextSessionGuidance(for: log.exerciseId)

            if let ex = exercise {
                let gradientColors = mediaProvider.heroGradient(for: ex)

                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 11) {
                        HStack(spacing: 8) {
                            Text(L10n.format("EX %d/%d", exerciseIndex + 1, workout.session.exerciseLogs.count))
                                .font(.system(size: 9, weight: .black).monospacedDigit())
                                .foregroundStyle(activeWorkoutSignal.opacity(0.68))
                                .tracking(0.8)
                            Text("·")
                                .foregroundStyle(.white.opacity(0.18))
                            Text(ex.primaryMuscle.displayName.uppercased())
                                .font(.system(size: 9, weight: .black))
                                .foregroundStyle(STRQPalette.textMuted)
                                .tracking(0.8)
                                .lineLimit(1)
                                .minimumScaleFactor(0.82)
                            Spacer(minLength: 8)
                            Text(L10n.format("SET %d/%d", activeSetNumber, log.sets.count))
                                .font(.system(size: 10, weight: .heavy).monospacedDigit())
                                .tracking(0.7)
                                .foregroundStyle(STRQPalette.textPrimary.opacity(0.92))
                                .padding(.horizontal, 9)
                                .frame(height: 27)
                                .background(Color.white.opacity(0.055), in: Capsule())
                                .overlay(Capsule().strokeBorder(Color.white.opacity(0.105), lineWidth: 1))
                        }

                        HStack(spacing: 12) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 13, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [gradientColors[0].opacity(0.72), gradientColors[1].opacity(0.55)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                ExerciseThumbnail(exercise: ex, size: .small, cornerRadius: 10)
                                    .frame(width: 48, height: 48)
                            }
                            .frame(width: 56, height: 56)
                            .overlay(
                                RoundedRectangle(cornerRadius: 13, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                            )
                            .overlay(alignment: .bottom) {
                                Capsule()
                                    .fill(activeWorkoutSignal.opacity(0.52))
                                    .frame(width: 28, height: 3)
                                    .padding(.bottom, 5)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text(ex.name)
                                    .font(.system(size: 21, weight: .black, design: .rounded))
                                    .foregroundStyle(STRQPalette.textPrimary)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.68)

                                HStack(spacing: 6) {
                                    if let p = planned {
                                        let targetReps = today?.suggestedRepRange ?? p.reps
                                        exerciseMetricPill(L10n.format("Target %@", targetReps))
                                        if let rpe = today?.targetRPE ?? p.rpe {
                                            exerciseMetricPill(L10n.format("RPE %@", formatRPE(rpe)))
                                        }
                                        exerciseMetricPill(L10n.format("%ds rest", p.restSeconds))
                                    }
                                }
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                            }
                            .layoutPriority(1)

                            Spacer(minLength: 0)
                        }
                    }
                    .padding(.horizontal, 13)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(activeWorkoutPanelFill)
                            .overlay(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.075), Color.white.opacity(0.012)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            )
                    )
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(activeWorkoutSignal.opacity(0.34))
                            .frame(width: 2)
                            .padding(.vertical, 18)
                            .padding(.leading, 1)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.13), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.18), radius: 12, y: 8)

                    workoutDetailsDisclosure(log: log, planned: planned, currentSet: currentSet, guidance: guidance)
                        .padding(.top, 7)

                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 10)
                .animation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.4), value: appeared)
                .id("\(exerciseIndex)-\(activeSetNumber)")
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func exerciseMetricPill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold).monospacedDigit())
            .foregroundStyle(STRQPalette.textPrimary.opacity(0.76))
            .lineLimit(1)
            .minimumScaleFactor(0.72)
            .padding(.horizontal, 8)
            .frame(height: 24)
            .background(Color.white.opacity(0.045), in: Capsule())
            .overlay(Capsule().strokeBorder(Color.white.opacity(0.075), lineWidth: 1))
    }

    private func workoutDetailsDisclosure(
        log: ExerciseLog,
        planned: PlannedExercise?,
        currentSet: SetLog?,
        guidance: NextSessionGuidance?
    ) -> some View {
        VStack(spacing: 6) {
            Button {
                withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .snappy(duration: 0.2)) {
                    showWorkoutDetails.toggle()
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 10, weight: .bold))
                    Text(L10n.tr("common.details", fallback: "Details"))
                        .font(.system(size: 11, weight: .bold))
                    Spacer(minLength: 0)
                    Image(systemName: showWorkoutDetails ? "chevron.up" : "chevron.down")
                        .font(.system(size: 9, weight: .bold))
                }
                .foregroundStyle(STRQPalette.textMuted)
                .padding(.horizontal, 12)
                .frame(minHeight: 34)
                .background(Color.white.opacity(0.025), in: .rect(cornerRadius: 11))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.055), lineWidth: 1)
                )
            }
            .buttonStyle(.strqPressable)

            if showWorkoutDetails {
                contextStrip(log: log, planned: planned, currentSet: currentSet)

                if let g = visibleNextSessionGuidance(guidance, planned: planned, currentSet: currentSet) {
                    HStack(spacing: 6) {
                        Image(systemName: g.icon)
                            .font(.system(size: 10))
                            .foregroundStyle(guidanceColor(g.color))
                        Text(g.action)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(STRQPalette.textPrimary.opacity(0.84))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(guidanceColor(g.color).opacity(0.085), in: .rect(cornerRadius: 9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 9)
                            .strokeBorder(guidanceColor(g.color).opacity(0.18), lineWidth: 1)
                    )
                }
            }
        }
    }

    private func visibleNextSessionGuidance(
        _ guidance: NextSessionGuidance?,
        planned: PlannedExercise?,
        currentSet: SetLog?
    ) -> NextSessionGuidance? {
        guard let guidance else { return nil }
        guard let planned else { return guidance }

        let today = vm.todayPrescription(for: planned)
        if today.suggestedSets != planned.sets ||
            today.suggestedRepRange != planned.reps ||
            today.weightChanged {
            return nil
        }

        if let currentSet, today.suggestedWeight > 0, abs(today.suggestedWeight - currentSet.weight) >= 0.05 {
            return nil
        }

        return guidance
    }

    @ViewBuilder
    private func contextStrip(log: ExerciseLog, planned: PlannedExercise?, currentSet: SetLog?) -> some View {
        let last = vm.lastPerformance(for: log.exerciseId)
        let best = personalBest(for: log.exerciseId)
        let today = planned.map { vm.todayPrescription(for: $0) }
        let exercise = vm.library.exercise(byId: log.exerciseId)
        let targetPrimary = currentSet.flatMap { activeTargetWeightText(for: $0, exercise: exercise) }
        let targetReps = currentSet.map { "\($0.reps)" } ?? today?.suggestedRepRange
        let todayIsAdjusted = today.map { todayPrescriptionDiffersFromPlan($0, planned: planned, currentSet: currentSet) } ?? false
        let targetValue = todayIsAdjusted ? compactTargetText(primary: targetPrimary, reps: targetReps) : (targetPrimary ?? "—")
        let targetSecondary = todayIsAdjusted
            ? (today?.setsReduced == true ? L10n.tr("Today calmer") : L10n.tr("From today's target"))
            : (targetReps.map { "× \($0)" } ?? "—")

        HStack(spacing: 0) {
            contextCell(
                label: L10n.tr("PREV"),
                primary: last.map { "\(formatWeight($0.topWeight, increment: 0.5))×\($0.topReps)" } ?? "—",
                secondary: last.map { formatRelativeDate($0.date) } ?? L10n.tr("no data")
            )
            contextDivider()
            contextCell(
                label: L10n.tr("PR"),
                primary: best.map { "\(formatWeight($0.weight, increment: 0.5))×\($0.reps)" } ?? "—",
                secondary: best.map { _ in L10n.tr("Best mark") } ?? "—",
                symbolName: "trophy.fill",
                accent: STRQPalette.gold,
                primaryTint: STRQPalette.gold.opacity(0.98),
                lineOpacity: 0.78,
                sparkle: best != nil
            )
            contextDivider()
            contextCell(
                label: L10n.tr("TARGET"),
                primary: targetValue,
                secondary: targetSecondary,
                accent: todayIsAdjusted ? activeWorkoutSignal : nil,
                lineOpacity: 0.62
            )
        }
        .padding(.vertical, 7)
    }

    private func compactTargetText(primary: String?, reps: String?) -> String {
        guard let primary, primary != "—" else { return "—" }
        guard let reps, !reps.isEmpty else { return primary }
        return "\(primary)×\(reps)"
    }

    private func todayPrescriptionDiffersFromPlan(
        _ today: TodayPrescription,
        planned: PlannedExercise?,
        currentSet: SetLog?
    ) -> Bool {
        guard let planned else { return false }
        if today.suggestedSets != planned.sets { return true }
        if normalizedRepRange(today.suggestedRepRange) != normalizedRepRange(planned.reps) { return true }
        if today.weightChanged { return true }
        if let currentSet, today.suggestedWeight > 0, abs(today.suggestedWeight - currentSet.weight) >= 0.05 {
            return true
        }
        return false
    }

    private func normalizedRepRange(_ reps: String) -> String {
        reps
            .replacingOccurrences(of: "–", with: "-")
            .replacingOccurrences(of: " ", with: "")
            .lowercased()
    }

    private func contextCell(
        label: String,
        primary: String,
        secondary: String,
        symbolName: String? = nil,
        accent: Color? = nil,
        primaryTint: Color? = nil,
        lineOpacity: Double = 0.62,
        sparkle: Bool = false
    ) -> some View {
        VStack(alignment: .center, spacing: 2) {
            HStack(spacing: 3) {
                if let symbolName {
                    Image(systemName: symbolName)
                        .font(.system(size: 7.5, weight: .black))
                        .accessibilityHidden(true)
                }
                Text(label)
                    .font(.system(size: 8, weight: .black))
                    .tracking(1.2)
            }
            .foregroundStyle(accent ?? STRQPalette.textMuted.opacity(0.86))
            contextPrimaryText(
                primary,
                primaryTint: primaryTint,
                accent: accent,
                sparkle: sparkle
            )
            Text(secondary)
                .font(.system(size: 9, weight: .semibold).monospacedDigit())
                .foregroundStyle(accent.map { AnyShapeStyle($0.opacity(0.78)) } ?? AnyShapeStyle(STRQPalette.textMuted.opacity(0.82)))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .overlay {
            if sparkle, let accent, !reduceMotion {
                goldSparkleOverlay(accent: accent)
            }
        }
        .overlay(alignment: .bottom) {
            if let accent {
                Capsule()
                    .fill(accent.opacity(lineOpacity))
                    .frame(width: 24, height: 2)
                    .padding(.bottom, 2)
            }
        }
    }

    @ViewBuilder
    private func contextPrimaryText(
        _ primary: String,
        primaryTint: Color?,
        accent: Color?,
        sparkle: Bool
    ) -> some View {
        let tint = primaryTint ?? STRQPalette.textPrimary.opacity(0.92)

        if sparkle, let accent, !reduceMotion {
            TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let glow = max(
                    randomSparkleIntensity(time: time, lane: 5, cycle: 5.9),
                    randomSparkleIntensity(time: time, lane: 6, cycle: 8.8)
                )

                Text(primary)
                    .font(.system(size: 13, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(tint.opacity(0.94 + glow * 0.06))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .background {
                        Text(primary)
                            .font(.system(size: 13, weight: .heavy, design: .rounded).monospacedDigit())
                            .foregroundStyle(accent.opacity(glow * 0.42))
                            .blur(radius: 2 + CGFloat(glow) * 6)
                            .scaleEffect(1.02 + CGFloat(glow) * 0.05)
                    }
                    .shadow(color: accent.opacity(glow * 0.66), radius: 2 + CGFloat(glow) * 8)
                    .shadow(color: accent.opacity(glow * 0.34), radius: CGFloat(glow) * 18)
            }
        } else {
            Text(primary)
                .font(.system(size: 13, weight: .heavy, design: .rounded).monospacedDigit())
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    private func goldSparkleOverlay(accent: Color) -> some View {
        GeometryReader { proxy in
            TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate

                ZStack {
                    randomSparkleStar(
                        accent: accent,
                        time: time,
                        lane: 0,
                        cycle: 5.6,
                        size: 7,
                        bounds: proxy.size
                    )
                    randomSparkleStar(
                        accent: accent,
                        time: time,
                        lane: 1,
                        cycle: 7.1,
                        size: 5.4,
                        bounds: proxy.size
                    )
                    randomSparkleStar(
                        accent: accent,
                        time: time,
                        lane: 2,
                        cycle: 8.4,
                        size: 4.1,
                        bounds: proxy.size
                    )
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func randomSparkleStar(
        accent: Color,
        time: TimeInterval,
        lane: Int,
        cycle: Double,
        size: CGFloat,
        bounds: CGSize
    ) -> some View {
        let tick = floor(time / cycle)
        let intensity = randomSparkleIntensity(time: time, lane: lane, cycle: cycle)
        let xSeed = sparkleNoise(tick * 11.3 + Double(lane) * 23.7)
        let ySeed = sparkleNoise(tick * 7.9 + Double(lane) * 31.1)
        let sizeSeed = sparkleNoise(tick * 5.1 + Double(lane) * 17.4)
        let laneAnchor = sparkleLaneAnchor(lane)
        let x = bounds.width * (laneAnchor.x + (xSeed - 0.5) * 0.11)
        let y = bounds.height * (laneAnchor.y + (ySeed - 0.5) * 0.10)
        let adjustedSize = size * CGFloat(0.90 + sizeSeed * 0.14)

        return sparkleStarCore(accent: accent, intensity: intensity, size: adjustedSize)
            .position(x: x, y: y)
    }

    private func sparkleStarCore(accent: Color, intensity: Double, size: CGFloat) -> some View {
        let pulse = min(1, intensity * intensity)
        let visibleOpacity = pulse * 0.94
        let scale = 0.62 + CGFloat(pulse) * 0.54

        return Image(systemName: "star.fill")
            .font(.system(size: size, weight: .black))
            .foregroundStyle(accent.opacity(0.62 + pulse * 0.34))
            .shadow(color: accent.opacity(0.20 + pulse * 0.58), radius: 2 + CGFloat(pulse) * 8)
            .shadow(color: Color.white.opacity(pulse * 0.07), radius: 1 + CGFloat(pulse) * 2)
            .scaleEffect(scale)
            .opacity(visibleOpacity)
            .blur(radius: 0.18 - CGFloat(pulse) * 0.08)
    }

    private func randomSparkleIntensity(time: TimeInterval, lane: Int, cycle: Double) -> Double {
        let phase = time.truncatingRemainder(dividingBy: cycle)
        let tick = floor(time / cycle)
        let laneOffset = Double(lane) * 19.37
        let duration = 0.62 + sparkleNoise(tick * 3.41 + laneOffset) * 0.42
        let start = 0.10 + sparkleNoise(tick * 8.73 + laneOffset) * max(0.1, cycle - duration - 0.16)
        let brightness = 0.74 + sparkleNoise(tick * 5.29 + laneOffset) * 0.24

        return min(1, sparkleIntensity(phase: phase, start: start, duration: duration) * brightness)
    }

    private func sparkleLaneAnchor(_ lane: Int) -> (x: Double, y: Double) {
        switch lane % 3 {
        case 0:
            return (0.39, 0.34)
        case 1:
            return (0.58, 0.51)
        default:
            return (0.74, 0.36)
        }
    }

    private func sparkleIntensity(phase: Double, start: Double, duration: Double) -> Double {
        let elapsed = phase - start
        guard elapsed >= 0, elapsed <= duration else { return 0 }
        return sin((elapsed / duration) * .pi)
    }

    private func sparkleNoise(_ value: Double) -> Double {
        let raw = sin(value * 12.9898 + 78.233) * 43758.5453
        return raw - floor(raw)
    }

    private func contextDivider() -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.052))
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
            let lastPerf = vm.lastPerformance(for: log.exerciseId)

            if let setLog = currentSet {
                let exerciseForIncrement = vm.library.exercise(byId: log.exerciseId)
                let increment = weightIncrement(for: exerciseForIncrement)
                let isBodyweight = exerciseForIncrement?.category == .bodyweight || (exerciseForIncrement?.isBodyweight ?? false)
                let canLogSet = setLog.reps > 0

                VStack(spacing: 10) {
                    activeTaskHeader(
                        exercise: exerciseForIncrement,
                        currentSet: setLog,
                        totalSets: log.sets.count
                    )

                    currentSetProgressBar(setNumber: setLog.setNumber, totalSets: log.sets.count)

                    matchChipsRow(
                        setLog: setLog,
                        exerciseIndex: exerciseIndex,
                        setIndex: activeSetIndex,
                        lastWeight: lastPerf?.topWeight,
                        lastReps: lastPerf?.topReps,
                        targetWeight: setLog.weight,
                        targetReps: setLog.reps
                    )

                    HStack(spacing: 9) {
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
                            plateMath: plateMathLabel(weight: setLog.weight, exercise: exerciseForIncrement),
                            valueAccessibilityIdentifier: "strq.active-workout.weight-value"
                        )
                        .frame(maxWidth: .infinity)

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
                            plateMath: nil,
                            valueAccessibilityIdentifier: "strq.active-workout.reps-value"
                        )
                        .frame(maxWidth: .infinity)
                    }

                    Button {
                        guard canLogSet else { return }
                        completeSet(exerciseIndex: exerciseIndex, setIndex: activeSetIndex)
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: canLogSet ? "checkmark.circle.fill" : "checkmark.circle")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(canLogSet ? activeWorkoutSignal.opacity(0.68) : Color.white.opacity(0.28))
                            Text(L10n.format("Log Set %d", setLog.setNumber))
                                .font(.system(size: 16, weight: .heavy, design: .rounded))
                                .foregroundStyle(canLogSet ? STRQPalette.backgroundDeep.opacity(0.94) : Color.white.opacity(0.38))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(
                            canLogSet
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        colors: [Color.white, Color(red: 0.88, green: 0.89, blue: 0.91)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                : AnyShapeStyle(Color.white.opacity(0.045)),
                            in: .rect(cornerRadius: 15)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .strokeBorder(Color.white.opacity(canLogSet ? 0.34 : 0.07), lineWidth: 1)
                        )
                        .shadow(color: .white.opacity(canLogSet ? 0.07 : 0), radius: 10, y: 3)
                        .shadow(color: .black.opacity(canLogSet ? 0.20 : 0), radius: 12, y: 7)
                    }
                    .buttonStyle(.strqPressable)
                    .disabled(!canLogSet)
                    .accessibilityIdentifier("strq.active-workout.log-set")
                    .accessibilityHint(canLogSet ? "" : L10n.tr("Add reps to log this set."))

                    if !canLogSet {
                        Text(L10n.tr("Add reps to log this set."))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.48))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    activeWorkoutSignal.opacity(0.055),
                                    STRQPalette.surfaceRaised.opacity(0.90),
                                    STRQPalette.surfaceBase.opacity(0.96),
                                    STRQPalette.backgroundCarbon.opacity(0.96)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            LinearGradient(
                                colors: [Color.white.opacity(0.060), Color.white.opacity(0.010)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        )
                )
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(activeWorkoutSignal.opacity(0.36))
                        .frame(width: 2)
                        .padding(.vertical, 18)
                        .padding(.leading, 1)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.105), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.18), radius: 12, y: 8)
                .id(setLog.id)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.98)))
                .animation(reduceMotion ? .easeOut(duration: 0.12) : .spring(response: 0.32, dampingFraction: 0.84), value: setLog.id)
            } else {
                let isLastExercise = exerciseIndex >= workout.session.exerciseLogs.count - 1
                VStack(spacing: 10) {
                    Image(systemName: isLastExercise ? "flag.checkered" : "checkmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(isLastExercise ? STRQBrand.steel : STRQPalette.success)
                    Text(isLastExercise ? L10n.tr("Last exercise complete") : L10n.tr("Exercise complete"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(isLastExercise ? L10n.tr("Finish Workout when you're ready to save this workout.") : L10n.tr("Move to the next exercise when you're ready."))
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
            HStack(spacing: 7) {
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
                    .foregroundStyle(activeWorkoutSignal.opacity(0.68))
                Text(label)
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(STRQPalette.textMuted)
                Text(value)
                    .font(.system(size: 10, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(STRQPalette.textPrimary)
            }
            .foregroundStyle(STRQPalette.textSecondary)
            .padding(.horizontal, 10)
            .frame(height: 30)
            .background(Color.white.opacity(0.050), in: Capsule())
            .overlay(Capsule().strokeBorder(Color.white.opacity(0.085), lineWidth: 1))
        }
        .buttonStyle(.strqPressable)
    }

    // MARK: - Input column

    @ViewBuilder
    private func currentSetProgressBar(setNumber: Int, totalSets: Int) -> some View {
        let total = max(totalSets, 1)
        let clampedSet = min(max(setNumber, 1), total)
        let progress = CGFloat(clampedSet) / CGFloat(total)

        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.055))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.84), activeWorkoutSignal.opacity(0.44)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(8, proxy.size.width * progress))
            }
        }
        .frame(height: 4)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func inputColumn(
        label: String,
        value: String,
        unit: String,
        disableMinus: Bool,
        onMinus: @escaping (Double?) -> Void,
        onPlus: @escaping (Double?) -> Void,
        onTapValue: @escaping () -> Void,
        plateMath: String?,
        valueAccessibilityIdentifier: String? = nil
    ) -> some View {
        VStack(spacing: 7) {
            Text(label)
                .font(.system(size: 9, weight: .black))
                .tracking(1.0)
                .foregroundStyle(STRQPalette.textMuted)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                stepperButton(icon: "minus", disabled: disableMinus, onTap: { onMinus(nil) }, onLongStep: { onMinus(5) })
                Button(action: onTapValue) {
                    Text(value)
                        .font(.system(size: 30, weight: .heavy, design: .rounded).monospacedDigit())
                        .foregroundStyle(STRQPalette.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.white.opacity(0.038), in: .rect(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.070), lineWidth: 1)
                        )
                        .contentTransition(.numericText())
                        .contentShape(.rect)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(valueAccessibilityIdentifier ?? "")
                stepperButton(icon: "plus", disabled: false, onTap: { onPlus(nil) }, onLongStep: { onPlus(5) })
            }

            Text(plateMath ?? unit)
                .font(.system(size: 9, weight: plateMath != nil ? .semibold : .medium, design: plateMath != nil ? .monospaced : .default))
                .foregroundStyle(STRQPalette.textMuted.opacity(plateMath != nil ? 0.95 : 0.78))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(9)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(STRQPalette.backgroundCarbon.opacity(0.62))
                .overlay(
                    LinearGradient(
                        colors: [Color.white.opacity(0.052), Color.white.opacity(0.012)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.085), lineWidth: 1)
        )
    }

    private func stepperButton(icon: String, disabled: Bool, onTap: @escaping () -> Void, onLongStep: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white.opacity(disabled ? 0.22 : 0.78))
                .frame(width: 46, height: 48)
                .background(
                    Color.white.opacity(disabled ? 0.022 : 0.070),
                    in: .rect(cornerRadius: 12, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(disabled ? 0.035 : 0.105), lineWidth: 1)
                )
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
            let targetReps = planned.map { vm.todayPrescription(for: $0).suggestedRepRange } ?? "—"
            let lastSessionSets = previousSetsMap(for: log.exerciseId)
            let firstActiveIdx = log.sets.firstIndex(where: { !$0.isCompleted })
            let completedCount = log.sets.filter(\.isCompleted).count

            VStack(spacing: 8) {
                HStack(alignment: .center, spacing: 10) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(L10n.tr("Sets"))
                            .font(.system(size: 17, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white.opacity(0.94))
                        Text("\(completedCount)/\(log.sets.count)")
                            .font(.system(size: 10, weight: .bold).monospacedDigit())
                            .foregroundStyle(.white.opacity(0.46))
                    }

                    Spacer(minLength: 8)

                    setHistoryStatusRail(
                        totalSets: log.sets.count,
                        completedCount: completedCount,
                        activeIndex: firstActiveIdx
                    )
                }
                .padding(.horizontal, 14)
                .padding(.top, 13)

                setHistoryProgressBar(completedCount: completedCount, totalSets: log.sets.count)
                    .padding(.horizontal, 14)

                HStack(spacing: 7) {
                    tableHeader("#", width: 38, alignment: .leading)
                    tableHeader(L10n.tr("PREV"), width: 64)
                    tableHeader(L10n.tr("kg"))
                    tableHeader(L10n.tr("reps"))
                    tableHeader(L10n.tr("Done"), width: 36)
                }
                .padding(.horizontal, 14)
                .padding(.top, 2)

                VStack(spacing: 5) {
                    ForEach(Array(log.sets.enumerated()), id: \.element.id) { idx, setLog in
                        let isActive = idx == firstActiveIdx
                        setLogRow(
                            setLog: setLog,
                            idx: idx,
                            isActive: isActive,
                            exerciseIndex: exerciseIndex,
                            targetReps: targetReps,
                            previousSet: lastSessionSets[setLog.setNumber]
                        )
                    }
                }
                .padding(.horizontal, 6)
                .padding(.bottom, 6)
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                STRQPalette.surfaceRaised,
                                STRQPalette.backgroundCarbon.opacity(0.92)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        LinearGradient(
                            colors: [Color.white.opacity(0.075), Color.white.opacity(0.014)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.105), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.20), radius: 14, y: 8)
        }
    }

    private func tableHeader(_ text: String, width: CGFloat? = nil, alignment: Alignment = .center) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .black))
            .tracking(1.0)
            .foregroundStyle(.white.opacity(0.38))
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: alignment)
            .frame(width: width)
    }

    private func setHistoryProgressBar(completedCount: Int, totalSets: Int) -> some View {
        let progress = totalSets > 0 ? CGFloat(completedCount) / CGFloat(totalSets) : 0
        return GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.065))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [STRQPalette.success.opacity(0.95), STRQBrand.steel.opacity(0.78)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(completedCount > 0 ? 8 : 0, proxy.size.width * progress))
            }
        }
        .frame(height: 4)
        .accessibilityHidden(true)
    }

    private func setHistoryStatusRail(totalSets: Int, completedCount: Int, activeIndex: Int?) -> some View {
        HStack(spacing: 4) {
            ForEach(0..<totalSets, id: \.self) { index in
                let isCompleted = index < completedCount
                let isActive = activeIndex == index
                Capsule()
                    .fill(setHistoryRailColor(completed: isCompleted, active: isActive))
                    .frame(width: isActive ? 18 : 7, height: 7)
                    .overlay(
                        Capsule()
                            .strokeBorder(Color.white.opacity(isActive ? 0.22 : 0.06), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 7)
        .background(Color.black.opacity(0.16), in: Capsule())
        .overlay(Capsule().strokeBorder(Color.white.opacity(0.07), lineWidth: 1))
        .accessibilityHidden(true)
    }

    private func setHistoryRailColor(completed: Bool, active: Bool) -> Color {
        if completed { return STRQPalette.success.opacity(0.72) }
        if active { return Color.white.opacity(0.90) }
        return Color.white.opacity(0.20)
    }

    @ViewBuilder
    private func setLogRow(
        setLog: SetLog,
        idx: Int,
        isActive: Bool,
        exerciseIndex: Int,
        targetReps: String,
        previousSet: SetLog?
    ) -> some View {
        let completed = setLog.isCompleted
        let valueOpacity: Double = completed ? 0.78 : (isActive ? 1.0 : 0.34)
        let weightText = completed || setLog.weight > 0 ? formatWeight(setLog.weight, increment: 0.5) : "—"
        let repsIsPlaceholder = !(completed || setLog.reps > 0)
        let repsText = repsIsPlaceholder ? targetReps : "\(setLog.reps)"
        let previousText = previousSetText(previousSet)
        let hasPrevious = previousSet != nil

        Button {
            if !completed && !isActive {
                jumpToSet(exerciseIndex: exerciseIndex, setIndex: idx)
            }
        } label: {
            HStack(spacing: 7) {
                setNumberBadge(setNumber: setLog.setNumber, completed: completed, isActive: isActive)
                    .frame(width: 38, alignment: .leading)

                previousSetCell(
                    value: previousText,
                    completed: completed,
                    isActive: isActive,
                    hasPrevious: hasPrevious
                )
                .frame(width: 64)

                setPrimaryMetricCell(value: weightText, opacity: valueOpacity, active: isActive, completed: completed, isPlaceholder: weightText == "—")
                setPrimaryMetricCell(value: repsText, opacity: repsIsPlaceholder ? 0.42 : valueOpacity, active: isActive, completed: completed, isPlaceholder: repsIsPlaceholder)

                setRowStatusIndicator(completed: completed, isActive: isActive)
                    .frame(width: 36)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .fill(setRowBaseColor(completed: completed, isActive: isActive))
                    if isActive {
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.115), STRQBrand.steel.opacity(0.095)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    if completed {
                        RoundedRectangle(cornerRadius: 13, style: .continuous)
                            .fill(STRQPalette.success.opacity(0.040))
                    }
                }
            )
            .overlay(alignment: .leading) {
                Capsule()
                    .fill(setRowRailColor(completed: completed, isActive: isActive))
                    .frame(width: setRowRailWidth(completed: completed, isActive: isActive))
                    .padding(.vertical, 8)
                    .padding(.leading, 1)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(setRowBorderColor(completed: completed, isActive: isActive), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(completed)
    }

    private func previousSetText(_ previousSet: SetLog?) -> String {
        guard let previousSet else { return "—" }
        guard previousSet.weight > 0 || previousSet.reps > 0 else { return "—" }
        return "\(formatWeight(previousSet.weight, increment: 0.5))×\(previousSet.reps)"
    }

    private func setNumberBadge(setNumber: Int, completed: Bool, isActive: Bool) -> some View {
        Text("\(setNumber)")
            .font(.system(size: 14, weight: .heavy, design: .rounded).monospacedDigit())
            .foregroundStyle(isActive ? .black.opacity(0.92) : .white.opacity(completed ? 0.82 : 0.48))
            .frame(width: 30, height: 30)
            .background(
                isActive
                    ? Color.white.opacity(0.92)
                    : Color.white.opacity(completed ? 0.075 : 0.035),
                in: Circle()
            )
            .overlay(
                Circle()
                    .strokeBorder(Color.white.opacity(completed || isActive ? 0.16 : 0.06), lineWidth: 1)
            )
    }

    private func previousSetCell(value: String, completed: Bool, isActive: Bool, hasPrevious: Bool) -> some View {
        Text(value)
            .font(.system(size: isActive ? 12 : 11, weight: isActive ? .heavy : .semibold, design: .rounded).monospacedDigit())
            .foregroundStyle(.white.opacity(hasPrevious ? (isActive ? 0.78 : completed ? 0.58 : 0.38) : 0.26))
            .lineLimit(1)
            .minimumScaleFactor(0.58)
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .background(Color.black.opacity(isActive ? 0.14 : 0.06), in: .rect(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(Color.white.opacity(isActive ? 0.075 : 0.035), lineWidth: 1)
            )
    }

    private func setPrimaryMetricCell(value: String, opacity: Double, active: Bool, completed: Bool, isPlaceholder: Bool) -> some View {
        Text(value)
            .font(.system(size: active ? 17 : isPlaceholder ? 12 : 15, weight: isPlaceholder ? .semibold : .black, design: .rounded).monospacedDigit())
            .foregroundStyle(.white.opacity(opacity))
            .lineLimit(1)
            .minimumScaleFactor(0.58)
            .frame(maxWidth: .infinity)
            .frame(height: 32)
            .background(
                active
                    ? Color.white.opacity(0.075)
                    : Color.black.opacity(completed ? 0.10 : 0.055),
                in: .rect(cornerRadius: 11, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 11, style: .continuous)
                    .strokeBorder(active ? STRQBrand.steel.opacity(0.42) : Color.white.opacity(completed ? 0.055 : 0.035), lineWidth: 1)
            )
            .contentTransition(.numericText())
    }

    private func setRowStatusIndicator(completed: Bool, isActive: Bool) -> some View {
        ZStack {
            if completed {
                Circle().fill(STRQPalette.success.opacity(0.18)).frame(width: 24, height: 24)
                Circle().strokeBorder(STRQPalette.success.opacity(0.42), lineWidth: 1).frame(width: 24, height: 24)
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(STRQPalette.success)
            } else if isActive {
                Circle().strokeBorder(Color.white.opacity(0.88), lineWidth: 1.4).frame(width: 24, height: 24)
                Circle().fill(Color.white).frame(width: 6, height: 6)
            } else {
                Circle()
                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [2.2, 2.2]))
                    .foregroundStyle(Color.white.opacity(0.22))
                    .frame(width: 24, height: 24)
            }
        }
    }

    private func setRowBaseColor(completed: Bool, isActive: Bool) -> Color {
        if isActive { return Color.white.opacity(0.088) }
        if completed { return Color.white.opacity(0.032) }
        return Color.white.opacity(0.016)
    }

    private func setRowBorderColor(completed: Bool, isActive: Bool) -> Color {
        if isActive { return STRQBrand.steel.opacity(0.46) }
        if completed { return STRQPalette.success.opacity(0.115) }
        return Color.white.opacity(0.045)
    }

    private func setRowRailColor(completed: Bool, isActive: Bool) -> Color {
        if completed { return STRQPalette.success.opacity(0.56) }
        if isActive { return Color.white.opacity(0.90) }
        return Color.white.opacity(0.16)
    }

    private func setRowRailWidth(completed: Bool, isActive: Bool) -> CGFloat {
        if isActive { return 5 }
        if completed { return 4 }
        return 3
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
                    Text(L10n.tr("Workout Note"))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(hasNote ? note : L10n.tr("Add one quick thought to remember how this workout felt."))
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
        .accessibilityLabel(hasNote ? L10n.tr("Edit workout note") : L10n.tr("Add workout note"))
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

    private func afterLogStateLine(_ workout: ActiveWorkoutState) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "clock")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(STRQBrand.steel)
                .frame(width: 30, height: 30)
                .background(STRQBrand.steel.opacity(0.12), in: Circle())
                .overlay(Circle().strokeBorder(STRQBrand.steel.opacity(0.22), lineWidth: 1))

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.tr("Rest"))
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.92))
                    .lineLimit(1)
                Text(afterLogStateLineDetail(workout))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            .layoutPriority(1)

            Spacer(minLength: 8)

            Text(formatTime(restTimeRemaining))
                .font(.system(size: 18, weight: .black, design: .rounded).monospacedDigit())
                .foregroundStyle(STRQBrand.steel)
                .contentTransition(.numericText(countsDown: true))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.045), in: .rect(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(STRQBrand.steel.opacity(0.16), lineWidth: 1)
        )
    }

    private func afterLogStateLineDetail(_ workout: ActiveWorkoutState) -> String {
        let exerciseIndex = workout.currentExerciseIndex
        guard exerciseIndex < workout.session.exerciseLogs.count else {
            return L10n.tr("Use the bottom action to move forward when you're ready.")
        }
        let log = workout.session.exerciseLogs[exerciseIndex]
        let exerciseName = vm.library.exercise(byId: log.exerciseId)?.name ?? L10n.tr("Exercise")
        if let currentSet = activeSetFor(log: log, workout: workout) {
            return L10n.format("%@ · Set %d ready", exerciseName, currentSet.setNumber)
        }
        return L10n.tr("Use the bottom action to move forward when you're ready.")
    }

    private func undoBanner(prompt: LoggedSetUndoPrompt) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(STRQPalette.success.opacity(0.86))
                .frame(width: 28, height: 28)
                .background(STRQPalette.success.opacity(0.10), in: Circle())
                .overlay(Circle().strokeBorder(STRQPalette.success.opacity(0.18), lineWidth: 1))

            VStack(alignment: .leading, spacing: 2) {
                Text(prompt.title)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.88))
                    .lineLimit(1)
                Text(prompt.subtitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.50))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .layoutPriority(1)

            Spacer(minLength: 8)

            Button {
                undoLastCompletedSet()
            } label: {
                Text(L10n.tr("Undo"))
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(.white.opacity(0.74))
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .background(Color.white.opacity(0.045), in: Capsule())
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.09), lineWidth: 1))
            }
            .buttonStyle(.strqPressable)
            .accessibilityLabel(L10n.tr("Undo last logged set"))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 15, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .strokeBorder(Color.white.opacity(0.075), lineWidth: 1)
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
                    VStack(spacing: 10) {
                        Text(L10n.tr("All sets are logged. Finish Workout to hand this workout back to Today."))
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
            .padding(.bottom, 28)
            .background(Color.black)
        }
    }

    // MARK: - Rest Timer Overlay

    @ViewBuilder
    private func restTimerOverlay(_ workout: ActiveWorkoutState) -> some View {
        let planned = workout.currentExerciseIndex < workout.plannedExercises.count ? workout.plannedExercises[workout.currentExerciseIndex] : nil
        let totalRest = planned?.restSeconds ?? 90
        let progress = totalRest > 0 ? CGFloat(restTimeRemaining) / CGFloat(totalRest) : 0
        let nextRec = nextSetRecommendation(workout)
        let rationale = nextRec?.detail ?? restCountdownHint()
        let overlayTint = STRQBrand.steel

        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()
                .onTapGesture { }
            LinearGradient(
                colors: [
                    Color.black.opacity(0.34),
                    Color.black.opacity(0.08),
                    Color.black.opacity(0.48)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                Spacer(minLength: 58)

                VStack(spacing: 12) {
                    restFocusTimer(progress: progress, rationale: rationale, advisory: nextRec)

                    if let nextRec {
                        restNextActionCard(nextRec)
                    }

                    if let last = lastLoggedSet,
                       last.exerciseIndex < workout.session.exerciseLogs.count,
                       last.setIndex < workout.session.exerciseLogs[last.exerciseIndex].sets.count {
                        restLoggedSetSummary(
                            workout: workout,
                            exerciseIndex: last.exerciseIndex,
                            setIndex: last.setIndex
                        )
                    }

                    restControls()

                    if let undoPrompt, vm.canUndoLastCompletedSet {
                        restUndoStrip(prompt: undoPrompt)
                    }
                }
                .padding(14)
                .frame(maxWidth: 372)
                .background(
                    LinearGradient(
                        colors: [
                            overlayTint.opacity(0.070),
                            Color(white: 0.040).opacity(0.98),
                            Color(white: 0.028).opacity(0.98)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: .rect(cornerRadius: 24, style: .continuous)
                )
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.080),
                            Color.white.opacity(0.018),
                            Color.black.opacity(0.10)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(.rect(cornerRadius: 24, style: .continuous))
                    .allowsHitTesting(false)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(overlayTint.opacity(0.16), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.46), radius: 30, y: 18)
                .padding(.horizontal, 18)

                Color.clear
                    .frame(height: 72)
            }
        }
    }

    private func restUndoStrip(prompt: LoggedSetUndoPrompt) -> some View {
        HStack(spacing: 8) {
            Text(prompt.title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white.opacity(0.52))
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Spacer(minLength: 8)

            Button {
                undoLastCompletedSet()
            } label: {
                Text(L10n.tr("Undo"))
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(.white.opacity(0.66))
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .background(Color.white.opacity(0.032), in: Capsule())
                    .overlay(Capsule().strokeBorder(Color.white.opacity(0.06), lineWidth: 1))
            }
            .buttonStyle(.strqPressable)
            .accessibilityLabel(L10n.tr("Undo last logged set"))
        }
        .padding(.horizontal, 10)
        .frame(height: 34)
        .background(Color.white.opacity(0.024), in: .rect(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.045), lineWidth: 1)
        )
    }

    private func restLoggedSetSummary(
        workout: ActiveWorkoutState,
        exerciseIndex: Int,
        setIndex: Int
    ) -> some View {
        let log = workout.session.exerciseLogs[exerciseIndex]
        let loggedSet = log.sets[setIndex]
        let exerciseName = vm.library.exercise(byId: log.exerciseId)?.name ?? "Exercise"
        let e1rm = estimatedOneRM(weight: loggedSet.weight, reps: loggedSet.reps)
        let currentQuality = loggedSet.quality
        let summaryTint = currentQuality.map { qualityColor($0.colorName) } ?? STRQPalette.success
        let summaryIcon = currentQuality?.icon ?? "checkmark.circle.fill"

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: summaryIcon)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(summaryTint.opacity(0.82))
                    .frame(width: 26, height: 26)
                    .background(summaryTint.opacity(0.11), in: Circle())
                    .overlay(Circle().strokeBorder(summaryTint.opacity(0.24), lineWidth: 1))

                VStack(alignment: .leading, spacing: 2) {
                    Text(L10n.tr("Set logged"))
                        .font(.system(size: 9, weight: .black))
                        .tracking(0.8)
                        .foregroundStyle(.white.opacity(0.42))
                        .textCase(.uppercase)
                    Text(exerciseName)
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white.opacity(0.78))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)
                }
                .layoutPriority(1)

                VStack(alignment: .trailing, spacing: 2) {
                    Text(L10n.format("Set %d · %@ × %d", loggedSet.setNumber, formatWeight(loggedSet.weight, increment: 0.5), loggedSet.reps))
                        .font(.system(size: 13, weight: .black, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.70))
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                    if e1rm > 0 {
                        Text(L10n.format("e1RM %.0f", e1rm))
                            .font(.system(size: 10, weight: .bold).monospacedDigit())
                            .foregroundStyle(.white.opacity(0.34))
                    }
                }
            }

            restQualityPicker(
                currentQuality: currentQuality,
                exerciseIndex: exerciseIndex,
                setIndex: setIndex
            )
        }
        .padding(10)
        .background(
            LinearGradient(
                colors: [
                    summaryTint.opacity(currentQuality == nil ? 0.034 : 0.070),
                    Color.white.opacity(0.026)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 16, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(summaryTint.opacity(currentQuality == nil ? 0.10 : 0.20), lineWidth: 1)
        )
    }

    private func restQualityPicker(
        currentQuality: SetQuality?,
        exerciseIndex: Int,
        setIndex: Int
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L10n.tr("How did that feel?"))
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.46))

            HStack(spacing: 8) {
                ForEach(SetQuality.allCases, id: \.self) { quality in
                    restQualityButton(
                        quality: quality,
                        isSelected: currentQuality == quality,
                        exerciseIndex: exerciseIndex,
                        setIndex: setIndex
                    )
                }
            }
        }
    }

    private func restQualityButton(
        quality: SetQuality,
        isSelected: Bool,
        exerciseIndex: Int,
        setIndex: Int
    ) -> some View {
        let tint = qualityColor(quality.colorName)
        let foreground = isSelected ? STRQPalette.backgroundDeep : Color.white.opacity(0.74)
        let fillColors: [Color] = isSelected ? [tint.opacity(0.96), tint.opacity(0.72)] : [Color.white.opacity(0.065), Color.white.opacity(0.040)]
        let borderColor = isSelected ? Color.white.opacity(0.22) : Color.white.opacity(0.08)

        return Button {
            let newQuality: SetQuality? = isSelected ? nil : quality
            setQuality(exerciseIndex: exerciseIndex, setIndex: setIndex, quality: newQuality)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: quality.icon)
                    .font(.system(size: 11, weight: .semibold))
                Text(quality.shortLabel)
                    .font(.system(size: 10, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.76)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 36)
            .background(
                LinearGradient(
                    colors: fillColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: .rect(cornerRadius: 11)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 11)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
            .shadow(color: isSelected ? tint.opacity(0.18) : Color.clear, radius: 9, y: 4)
        }
        .buttonStyle(.strqPressable)
    }

    private func restFocusTimer(progress: CGFloat, rationale: String, advisory: NextSetRec?) -> some View {
        let isAlmostDone = restTimeRemaining <= 10
        let restTint = isAlmostDone ? STRQPalette.warning : STRQBrand.steel
        let timerTextColor = isAlmostDone ? STRQPalette.warning.opacity(0.88) : Color.white.opacity(0.88)
        let timerGlowColor = isAlmostDone ? STRQPalette.warning.opacity(0.14) : Color.white.opacity(0.10)
        let advisoryTint = advisory?.tint ?? STRQBrand.steel
        let advisoryIcon = advisory?.icon ?? "figure.strengthtraining.traditional"
        let timerAnimation: Animation = reduceMotion ? .easeOut(duration: 0.12) : .linear(duration: 1)
        let clampedProgress = min(max(progress, 0), 1)

        return VStack(spacing: 13) {
            VStack(spacing: 5) {
                Text(L10n.tr("REST"))
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.6)
                    .foregroundStyle(.white.opacity(0.46))
                Text(formatTime(restTimeRemaining))
                    .font(.system(size: 64, weight: .black, design: .rounded).monospacedDigit())
                    .foregroundStyle(timerTextColor)
                    .contentTransition(.numericText(countsDown: true))
                    .lineLimit(1)
                    .minimumScaleFactor(0.58)
                    .shadow(color: timerGlowColor, radius: 16, y: 6)
                HStack(alignment: .center, spacing: 7) {
                    Image(systemName: advisoryIcon)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(advisoryTint.opacity(0.94))
                        .frame(width: 18, height: 18)
                        .background(advisoryTint.opacity(0.12), in: Circle())
                    Text(rationale)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.72))
                        .lineLimit(2)
                        .minimumScaleFactor(0.82)
                        .multilineTextAlignment(.leading)
                        .layoutPriority(1)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .frame(maxWidth: .infinity, alignment: .center)
                .background(advisoryTint.opacity(0.070), in: .rect(cornerRadius: 13, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 13, style: .continuous)
                        .strokeBorder(advisoryTint.opacity(0.16), lineWidth: 1)
                )
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.080))
                    Capsule()
                        .fill(restTint.opacity(0.82))
                        .frame(width: proxy.size.width * clampedProgress)
                        .animation(timerAnimation, value: restTimeRemaining)
                }
            }
            .frame(height: 5)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.top, 8)
        .padding(.bottom, 2)
    }

    private func restControls() -> some View {
        HStack(spacing: 8) {
            restTimerAdjustmentButton(title: L10n.tr("-15s")) {
                let updatedTime = max(0, restTimeRemaining - 15)
                restTimeRemaining = updatedTime
                if updatedTime == 0 {
                    restTimerActive = false
                }
            }

            restContinueButton()

            restTimerAdjustmentButton(title: L10n.tr("+15s")) {
                restTimeRemaining += 15
            }
        }
    }

    private func restContinueButton() -> some View {
        Button {
            restTimeRemaining = 0
            restTimerActive = false
        } label: {
            Text(L10n.tr("Continue Now"))
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(STRQPalette.backgroundDeep)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    LinearGradient(
                        colors: [Color.white, Color(red: 0.92, green: 0.93, blue: 0.94)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: Capsule()
                )
                .overlay(Capsule().strokeBorder(Color.white.opacity(0.24), lineWidth: 1))
        }
        .buttonStyle(.strqPressable)
        .accessibilityLabel(L10n.tr("Continue workout now"))
        .accessibilityIdentifier("strq.active-workout.rest-continue")
    }

    private func restTimerAdjustmentButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .black, design: .rounded).monospacedDigit())
                .foregroundStyle(.white.opacity(0.76))
                .frame(width: 54, height: 40)
                .background(Color.white.opacity(0.060), in: Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.11), lineWidth: 1)
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
        HStack(alignment: .center, spacing: 10) {
            Capsule()
                .fill(nextRec.tint.opacity(0.58))
                .frame(width: 3, height: 34)

            Image(systemName: nextRec.icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(nextRec.tint.opacity(0.92))
                .frame(width: 28, height: 28)
                .background(nextRec.tint.opacity(0.13), in: .rect(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(nextRec.tint.opacity(0.18), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 3) {
                Text(nextRec.eyebrow)
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.0)
                    .foregroundStyle(nextRec.tint.opacity(0.88))
                Text(nextRec.primary)
                    .font(nextRec.usesMonospacedPrimary ? .system(size: 15, weight: .black, design: .rounded).monospacedDigit() : .system(size: 14, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.82))
                    .lineLimit(2)
                    .minimumScaleFactor(0.78)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(
            LinearGradient(
                colors: [
                    nextRec.tint.opacity(0.110),
                    Color.white.opacity(0.036)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 15, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .strokeBorder(nextRec.tint.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: nextRec.tint.opacity(0.10), radius: 12, y: 6)
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
        let sourceWorkout = vm.activeWorkout ?? workout
        guard let last = lastLoggedSet,
              last.exerciseIndex < sourceWorkout.session.exerciseLogs.count else { return nil }
        let loggedLog = sourceWorkout.session.exerciseLogs[last.exerciseIndex]
        guard last.setIndex < loggedLog.sets.count else { return nil }
        let justLogged = loggedLog.sets[last.setIndex]

        let activeExerciseIndex = sourceWorkout.currentExerciseIndex
        guard activeExerciseIndex < sourceWorkout.session.exerciseLogs.count else { return nil }
        let activeLog = sourceWorkout.session.exerciseLogs[activeExerciseIndex]

        guard let next = activeSetFor(log: activeLog, workout: sourceWorkout) else {
            return NextSetRec(
                eyebrow: L10n.tr("WORKOUT READY"),
                primary: L10n.tr("Finish Workout"),
                detail: L10n.tr("All working sets are logged. Finish when you're ready."),
                icon: "flag.checkered",
                tint: STRQPalette.success,
                usesMonospacedPrimary: false
            )
        }

        let planned = last.exerciseIndex < sourceWorkout.plannedExercises.count ? sourceWorkout.plannedExercises[last.exerciseIndex] : nil
        let today = planned.map { vm.todayPrescription(for: $0) }
        let quality = justLogged.quality
        var guidance = "Queued next set is ready. Adjust only if it feels right."
        var icon = "figure.strengthtraining.traditional"
        var tint: Color = STRQBrand.steel

        let exercise = vm.library.exercise(byId: activeLog.exerciseId)
        let increment = weightIncrement(for: exercise)
        let isSameExercise = activeExerciseIndex == last.exerciseIndex
        let todayIsAdjusted = today.map { todayPrescriptionDiffersFromPlan($0, planned: planned, currentSet: next) } ?? false
        let reducedSetGuidance = L10n.tr("Keep today's calmer target for the next set.")

        if !isSameExercise {
            guidance = "Next exercise is queued. Start when the rest feels right."
            icon = "arrow.right.circle.fill"
            tint = STRQBrand.steel
        } else if let q = quality {
            if todayIsAdjusted && q == .tooEasy {
                guidance = reducedSetGuidance
                icon = "heart.circle.fill"
                tint = activeWorkoutSignal
            } else {
                let advisory = restAdvisory(for: q)
                guidance = advisory.guidance
                icon = advisory.icon
                tint = advisory.tint
            }
        } else if todayIsAdjusted {
            guidance = reducedSetGuidance
            icon = "heart.circle.fill"
            tint = activeWorkoutSignal
        } else if let today, let targetTopReps = parsePlannedReps(today.suggestedRepRange), justLogged.reps >= targetTopReps {
            guidance = "Top of the range hit. Consider a small bump if it still feels clean."
            icon = "arrow.up.right.circle.fill"
            tint = STRQPalette.success
        }

        let queuedPrimary: String
        if next.weight <= 0 && (exercise?.isBodyweight ?? false) {
            queuedPrimary = "Set \(next.setNumber) · BW × \(next.reps)"
        } else {
            queuedPrimary = "Set \(next.setNumber) · \(formatWeight(next.weight, increment: increment)) × \(next.reps)"
        }

        return NextSetRec(
            eyebrow: L10n.tr("NEXT SET"),
            primary: queuedPrimary,
            detail: guidance,
            icon: icon,
            tint: tint,
            usesMonospacedPrimary: true
        )
    }

    private func restAdvisory(for quality: SetQuality) -> (guidance: String, icon: String, tint: Color) {
        switch quality {
        case .tooEasy:
            return (
                "Felt easy. Consider a small bump if the next set still feels clean.",
                "arrow.up.right.circle.fill",
                STRQPalette.info
            )
        case .onTarget:
            return (
                "Keep the next set controlled with the same standard.",
                "checkmark.circle.fill",
                STRQPalette.success
            )
        case .grinder:
            return (
                "Hold the load. Match clean reps before pushing.",
                "flame.fill",
                STRQPalette.warning
            )
        case .formBreakdown:
            return (
                "Technique flagged. Keep the next set cleaner before adding load.",
                "exclamationmark.triangle.fill",
                STRQPalette.warning
            )
        case .pain:
            return (
                "Pain noted. Swap or stop this movement if it does not settle.",
                "cross.case.fill",
                STRQPalette.danger
            )
        }
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
        withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.2)) {
            swapConfirmationText = message
        }
        swapFeedbackTrigger.toggle()
        swapFeedbackTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.2)) {
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
        workoutCompletedTrigger.toggle()
        vm.completeWorkout()
    }

    private func activeTaskHeader(exercise: Exercise?, currentSet: SetLog?, totalSets: Int) -> some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(currentSet == nil ? L10n.tr("NEXT ACTION") : L10n.tr("CURRENT TASK"))
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.0)
                    .foregroundStyle(activeWorkoutSignal.opacity(0.58))
                Text(taskHeaderTitle(exercise: exercise, currentSet: currentSet, totalSets: totalSets))
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(STRQPalette.textPrimary)
                    .lineLimit(2)
                Text(taskHeaderDetail(currentSet: currentSet, totalSets: totalSets))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(STRQPalette.textSecondary)
                    .lineLimit(2)
            }
            .layoutPriority(1)

            Spacer(minLength: 0)

            if let exercise {
                Button {
                    showExerciseInfo = exercise
                } label: {
                    Image(systemName: "info.circle")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(STRQPalette.textSecondary)
                        .frame(width: 38, height: 38)
                        .background(activeWorkoutControlFill, in: Circle())
                        .overlay(
                            Circle()
                                .strokeBorder(activeWorkoutControlStroke, lineWidth: 1)
                        )
                }
                .buttonStyle(.strqPressable)
                .accessibilityLabel(L10n.tr("Exercise Guide"))
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
        if currentSet != nil {
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
        withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .snappy(duration: 0.15)) {
            vm.updateSetLoad(exerciseIndex: exerciseIndex, setIndex: setIndex, weight: weight, reps: reps)
        }
    }

    private func completeSet(exerciseIndex: Int, setIndex: Int) {
        guard let workout,
              exerciseIndex < workout.session.exerciseLogs.count,
              setIndex < workout.session.exerciseLogs[exerciseIndex].sets.count,
              workout.session.exerciseLogs[exerciseIndex].sets[setIndex].reps > 0 else { return }
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
        withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .spring(response: 0.28, dampingFraction: 0.9)) {
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
        withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.2)) {
            undoPrompt = nil
        }
    }

    private func undoLastCompletedSet() {
        let restored = vm.undoLastCompletedSet()
        undoDismissTask?.cancel()
        undoDismissTask = nil
        withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.2)) {
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

    private func activeTargetWeightText(for setLog: SetLog, exercise: Exercise?) -> String? {
        if setLog.weight > 0 {
            return formatWeight(setLog.weight, increment: weightIncrement(for: exercise))
        }
        guard isBodyweightLoad(exercise) else { return nil }
        return L10n.tr("BW")
    }

    private func isBodyweightLoad(_ exercise: Exercise?) -> Bool {
        guard let exercise else { return false }
        return exercise.isBodyweight || exercise.category == .bodyweight
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

                TextField(L10n.tr("How did this workout feel?"), text: $draftNote, axis: .vertical)
                    .lineLimit(4...8)
                    .padding(14)
                    .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color(.separator).opacity(0.35), lineWidth: 1)
                    )
                    .focused($focused)

                Text(trimmedNote.isEmpty ? L10n.tr("Optional. Save a cue, win, or anything you want to remember next time.") : L10n.tr("This note stays attached to the saved workout."))
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)
            }
            .padding(20)
            .navigationTitle(L10n.tr("Workout Note"))
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
                    .accessibilityIdentifier("strq.active-workout.numeric-input")

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
