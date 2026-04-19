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
                        VStack(spacing: 20) {
                            exerciseFocusHero(workout)
                                .padding(.horizontal, 16)
                                .padding(.top, 18)

                            VStack(spacing: 10) {
                                activeSetCard(workout)
                                remainingSetsStrip(workout)
                            }
                            .padding(.horizontal, 16)

                            exerciseActions(workout)
                                .padding(.horizontal, 16)

                            upNextPreview(workout)
                                .padding(.horizontal, 16)
                                .padding(.top, 4)
                        }
                        .padding(.bottom, 120)
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
        return HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 3) {
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

            Spacer(minLength: 8)

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
        .padding(.horizontal, 16)
        .padding(.top, 26)
        .padding(.bottom, 16)
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
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [gradientColors[0], gradientColors[1]],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 160)

                        Canvas { context, size in
                            for i in 0..<3 {
                                let xFraction: [CGFloat] = [0.2, 0.6, 0.85]
                                let yFraction: [CGFloat] = [0.3, 0.65, 0.25]
                                let radius = CGFloat(20 + i * 15)
                                let circle = Path(ellipseIn: CGRect(
                                    x: xFraction[i] * size.width - radius,
                                    y: yFraction[i] * size.height - radius,
                                    width: radius * 2, height: radius * 2
                                ))
                                context.fill(circle, with: .color(.white.opacity(0.03)))
                            }
                        }
                        .frame(height: 160)
                        .clipShape(.rect(cornerRadius: 20))
                        .allowsHitTesting(false)

                        HStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.08))
                                    .frame(width: 80, height: 80)
                                    .blur(radius: 10)

                                Image(systemName: heroSymbol)
                                    .font(.system(size: 40, weight: .thin))
                                    .foregroundStyle(.white.opacity(0.9))
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("EXERCISE \(exerciseIndex + 1) OF \(workout.session.exerciseLogs.count)")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white.opacity(0.5))
                                    .tracking(0.8)

                                Text(ex.name)
                                    .font(.title3.bold())
                                    .foregroundStyle(.white)
                                    .lineLimit(2)

                                HStack(spacing: 8) {
                                    Text(ex.primaryMuscle.displayName)
                                        .font(.caption2.weight(.semibold))
                                        .foregroundStyle(.white.opacity(0.8))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(.white.opacity(0.15), in: Capsule())

                                    if let p = planned {
                                        Text("\(p.sets) × \(p.reps)")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(.white.opacity(0.7))
                                    }

                                    if let p = planned, let rpe = p.rpe {
                                        Text("RPE \(Int(rpe))")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundStyle(.white.opacity(0.6))
                                    }
                                }
                            }

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 20)
                    }
                    .clipShape(.rect(cornerRadius: 20))
                }

                if let guidance = vm.nextSessionGuidance(for: log.exerciseId) {
                    HStack(spacing: 8) {
                        Image(systemName: guidance.icon)
                            .font(.system(size: 11))
                            .foregroundStyle(guidanceColor(guidance.color))
                        Text(guidance.action)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 14))
                    .padding(.top, 8)
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
                VStack(spacing: 18) {
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
                        if let suggestion = vm.loadSuggestion(for: log.exerciseId, planned: planned), suggestion.suggestedWeight > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "scope")
                                    .font(.system(size: 9, weight: .bold))
                                Text(suggestion.formattedWeight)
                                    .font(.system(size: 10, weight: .black).monospacedDigit())
                            }
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.white.opacity(0.08), in: Capsule())
                        }
                    }

                    HStack(spacing: 24) {
                        let exerciseForIncrement = vm.library.exercise(byId: log.exerciseId)
                        let increment = weightIncrement(for: exerciseForIncrement)
                        let isBodyweight = increment <= 0

                        VStack(spacing: 8) {
                            Text("WEIGHT")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.tertiary)
                                .tracking(0.5)

                            HStack(spacing: 0) {
                                Button {
                                    let step = isBodyweight ? 1.0 : increment
                                    updateSet(exerciseIndex: exerciseIndex, setIndex: activeSetIndex, weight: max(0, setLog.weight - step), reps: setLog.reps)
                                } label: {
                                    Image(systemName: "minus")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.5))
                                        .frame(width: 44, height: 56)
                                        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 10))
                                }
                                .disabled(isBodyweight && setLog.weight <= 0)

                                Text(isBodyweight && setLog.weight <= 0 ? "BW" : formatWeight(setLog.weight, increment: increment))
                                    .font(.system(size: 48, weight: .heavy, design: .rounded).monospacedDigit())
                                    .frame(minWidth: 96)
                                    .contentTransition(.numericText())

                                Button {
                                    let step = isBodyweight ? 1.0 : increment
                                    updateSet(exerciseIndex: exerciseIndex, setIndex: activeSetIndex, weight: setLog.weight + step, reps: setLog.reps)
                                } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.5))
                                        .frame(width: 44, height: 56)
                                        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 10))
                                }
                            }

                            Text(isBodyweight ? "added load" : "kg")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity)

                        Rectangle()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 1, height: 80)

                        VStack(spacing: 8) {
                            Text("REPS")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.tertiary)
                                .tracking(0.5)

                            HStack(spacing: 0) {
                                Button { updateSet(exerciseIndex: exerciseIndex, setIndex: activeSetIndex, weight: setLog.weight, reps: max(0, setLog.reps - 1)) } label: {
                                    Image(systemName: "minus")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.5))
                                        .frame(width: 44, height: 56)
                                        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 10))
                                }

                                Text("\(setLog.reps)")
                                    .font(.system(size: 48, weight: .heavy, design: .rounded).monospacedDigit())
                                    .frame(minWidth: 60)
                                    .contentTransition(.numericText())

                                Button { updateSet(exerciseIndex: exerciseIndex, setIndex: activeSetIndex, weight: setLog.weight, reps: setLog.reps + 1) } label: {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(.white.opacity(0.5))
                                        .frame(width: 44, height: 56)
                                        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 10))
                                }
                            }

                            Text("reps")
                                .font(.system(size: 10, weight: .medium))
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
                        .frame(height: 56)
                        .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 16))
                        .shadow(color: .white.opacity(0.15), radius: 14, y: 3)
                    }
                }
                .padding(22)
                .background(
                    LinearGradient(
                        colors: [Color.white.opacity(0.07), Color.white.opacity(0.03)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    in: .rect(cornerRadius: 24)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                )
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(.green)
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

    // MARK: - Remaining Sets Strip

    @ViewBuilder
    private func remainingSetsStrip(_ workout: ActiveWorkoutState) -> some View {
        let exerciseIndex = workout.currentExerciseIndex
        if exerciseIndex < workout.session.exerciseLogs.count {
            let log = workout.session.exerciseLogs[exerciseIndex]

            HStack(spacing: 6) {
                ForEach(Array(log.sets.enumerated()), id: \.element.id) { idx, setLog in
                    let isActive = idx == workout.currentSetIndex && !setLog.isCompleted
                    let isCompleted = setLog.isCompleted

                    Button {
                        if !isCompleted && !isActive {
                            jumpToSet(exerciseIndex: exerciseIndex, setIndex: idx)
                        }
                    } label: {
                        VStack(spacing: 3) {
                            ZStack {
                                Circle()
                                    .fill(isCompleted ? Color.green : isActive ? Color.white : Color.white.opacity(0.08))
                                    .frame(width: 32, height: 32)
                                if isCompleted {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.black)
                                } else {
                                    Text("\(setLog.setNumber)")
                                        .font(.caption2.weight(.bold).monospacedDigit())
                                        .foregroundStyle(isActive ? .black : .secondary)
                                }
                            }
                            if isCompleted && setLog.weight > 0 {
                                Text("\(String(format: "%.0f", setLog.weight))×\(setLog.reps)")
                                    .font(.system(size: 8, weight: .medium).monospacedDigit())
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .disabled(isCompleted)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color.white.opacity(0.03), in: .rect(cornerRadius: 14))
        }
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

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Text("UP NEXT")
                        .font(.system(size: 10, weight: .black))
                        .foregroundStyle(STRQBrand.steel)
                        .tracking(1.4)
                    Rectangle()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 1)
                    Text("\(total) left")
                        .font(.system(size: 10, weight: .bold).monospacedDigit())
                        .foregroundStyle(.white.opacity(0.35))
                }

                VStack(spacing: 8) {
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
        let tileSize: CGFloat = isImmediate ? 46 : 36

        HStack(spacing: 14) {
            if let ex = exercise {
                let colors = mediaProvider.heroGradient(for: ex)
                let symbol = mediaProvider.heroSymbol(for: ex)
                ZStack {
                    RoundedRectangle(cornerRadius: 11)
                        .fill(LinearGradient(colors: [colors[0], colors[1]], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: tileSize, height: tileSize)
                        .opacity(isImmediate ? 1 : 0.65)
                    Image(systemName: symbol)
                        .font(.system(size: isImmediate ? 20 : 16, weight: .thin))
                        .foregroundStyle(.white.opacity(isImmediate ? 0.9 : 0.75))
                }
                .frame(width: 46, alignment: .leading)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(positionLabel)
                    .font(.system(size: 9, weight: .black))
                    .tracking(1.2)
                    .foregroundStyle(isImmediate ? STRQBrand.steel : .white.opacity(0.3))
                Text(exercise?.name ?? log.exerciseId)
                    .font(isImmediate ? .subheadline.weight(.semibold) : .subheadline.weight(.medium))
                    .foregroundStyle(isImmediate ? .white.opacity(0.9) : .white.opacity(0.55))
                    .lineLimit(1)
                if let ex = exercise {
                    Text("\(ex.primaryMuscle.displayName) · \(log.sets.count) sets")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.35))
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white.opacity(isImmediate ? 0.3 : 0.18))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, isImmediate ? 12 : 10)
        .background(Color.white.opacity(isImmediate ? 0.045 : 0.02), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(isImmediate ? 0.06 : 0), lineWidth: 1)
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
                .frame(height: 50)

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
            Color.black.opacity(0.92).ignoresSafeArea()
                .onTapGesture { }

            VStack(spacing: 28) {
                Text("REST")
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(STRQBrand.steel)
                    .tracking(2)

                let planned = workout.currentExerciseIndex < workout.plannedExercises.count ? workout.plannedExercises[workout.currentExerciseIndex] : nil
                let totalRest = planned?.restSeconds ?? 90
                let progress = totalRest > 0 ? CGFloat(restTimeRemaining) / CGFloat(totalRest) : 0

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 6)
                        .frame(width: 180, height: 180)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            restTimeRemaining <= 10 ? Color.red : Color.white,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 180, height: 180)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: restTimeRemaining)

                    VStack(spacing: 4) {
                        Text(formatTime(restTimeRemaining))
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundStyle(restTimeRemaining <= 10 ? .red : .white)
                        Text("remaining")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }

                if let last = lastLoggedSet,
                   last.exerciseIndex < workout.session.exerciseLogs.count,
                   last.setIndex < workout.session.exerciseLogs[last.exerciseIndex].sets.count {
                    let currentQuality = workout.session.exerciseLogs[last.exerciseIndex].sets[last.setIndex].quality
                    VStack(spacing: 10) {
                        Text("HOW DID THAT SET FEEL?")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(.white.opacity(0.4))
                            .tracking(1.0)
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
                                    .frame(height: 52)
                                    .background(
                                        isSelected
                                            ? AnyShapeStyle(qualityColor(quality.colorName))
                                            : AnyShapeStyle(Color.white.opacity(0.06)),
                                        in: .rect(cornerRadius: 12)
                                    )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                }

                HStack(spacing: 16) {
                    Button { restTimeRemaining = max(0, restTimeRemaining - 15) } label: {
                        Text("-15s")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, height: 40)
                            .background(Color.white.opacity(0.06), in: .rect(cornerRadius: 12))
                    }

                    Button {
                        restTimeRemaining = 0
                        restTimerActive = false
                    } label: {
                        Text("Skip")
                            .font(.body.weight(.bold))
                            .foregroundStyle(.black)
                            .frame(width: 80, height: 44)
                            .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 14))
                    }

                    Button { restTimeRemaining += 15 } label: {
                        Text("+15s")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 60, height: 40)
                            .background(Color.white.opacity(0.06), in: .rect(cornerRadius: 12))
                    }
                }

                if let nextIdx = Optional(workout.currentExerciseIndex + 1), nextIdx < workout.session.exerciseLogs.count {
                    let nextLog = workout.session.exerciseLogs[nextIdx]
                    let nextEx = vm.library.exercise(byId: nextLog.exerciseId)
                    HStack(spacing: 8) {
                        Text("Next:")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.tertiary)
                        Text(nextEx?.name ?? nextLog.exerciseId)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 8)
                }
            }
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
                            ZStack {
                                Circle()
                                    .fill(log.isCompleted ? Color.green : isCurrent ? Color.white : Color.white.opacity(0.08))
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
        guard var workout = vm.activeWorkout,
              exerciseIndex < workout.session.exerciseLogs.count,
              setIndex < workout.session.exerciseLogs[exerciseIndex].sets.count else { return }
        withAnimation(.snappy(duration: 0.15)) {
            workout.session.exerciseLogs[exerciseIndex].sets[setIndex].weight = weight
            workout.session.exerciseLogs[exerciseIndex].sets[setIndex].reps = reps
            vm.activeWorkout = workout
        }
    }

    private func completeSet(exerciseIndex: Int, setIndex: Int) {
        guard var workout = vm.activeWorkout,
              exerciseIndex < workout.session.exerciseLogs.count,
              setIndex < workout.session.exerciseLogs[exerciseIndex].sets.count else { return }

        workout.session.exerciseLogs[exerciseIndex].sets[setIndex].isCompleted = true
        setCompletedTrigger.toggle()
        lastLoggedSet = (exerciseIndex, setIndex)

        let allDone = workout.session.exerciseLogs[exerciseIndex].sets.allSatisfy(\.isCompleted)
        if allDone {
            workout.session.exerciseLogs[exerciseIndex].isCompleted = true
            if exerciseIndex < workout.session.exerciseLogs.count - 1 {
                workout.currentExerciseIndex = exerciseIndex + 1
                workout.currentSetIndex = 0
            }
        } else {
            workout.currentSetIndex = setIndex + 1
        }

        vm.activeWorkout = workout

        let planned = exerciseIndex < workout.plannedExercises.count ? workout.plannedExercises[exerciseIndex] : nil
        let rest = planned?.restSeconds ?? 90
        restTimeRemaining = rest
        restTimerActive = true
        vm.updateLiveActivity(restEndsAt: Date().addingTimeInterval(TimeInterval(rest)))
    }

    private func setQuality(exerciseIndex: Int, setIndex: Int, quality: SetQuality?) {
        guard var workout = vm.activeWorkout,
              exerciseIndex < workout.session.exerciseLogs.count,
              setIndex < workout.session.exerciseLogs[exerciseIndex].sets.count else { return }
        workout.session.exerciseLogs[exerciseIndex].sets[setIndex].quality = quality
        vm.activeWorkout = workout
        setCompletedTrigger.toggle()
    }

    private func qualityColor(_ name: String) -> Color {
        switch name {
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        case "yellow": return .yellow
        case "red": return .red
        default: return .white
        }
    }

    private func jumpToSet(exerciseIndex: Int, setIndex: Int) {
        guard var workout = vm.activeWorkout else { return }
        workout.currentSetIndex = setIndex
        vm.activeWorkout = workout
        vm.updateLiveActivity(restEndsAt: liveRestEndsAt())
    }

    private func moveToNextExercise() {
        guard var workout = vm.activeWorkout else { return }
        if workout.currentExerciseIndex < workout.session.exerciseLogs.count - 1 {
            workout.currentExerciseIndex += 1
            workout.currentSetIndex = 0
            vm.activeWorkout = workout
            vm.updateLiveActivity(restEndsAt: liveRestEndsAt())
        }
    }

    private func moveToPreviousExercise() {
        guard var workout = vm.activeWorkout else { return }
        if workout.currentExerciseIndex > 0 {
            workout.currentExerciseIndex -= 1
            workout.currentSetIndex = 0
            vm.activeWorkout = workout
            vm.updateLiveActivity(restEndsAt: liveRestEndsAt())
        }
    }

    private func jumpToExercise(_ index: Int) {
        guard var workout = vm.activeWorkout else { return }
        workout.currentExerciseIndex = index
        workout.currentSetIndex = 0
        vm.activeWorkout = workout
        vm.updateLiveActivity(restEndsAt: liveRestEndsAt())
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
        if ex.category == .bodyweight { return 0 }
        if ex.equipment.contains(.kettlebell) { return 4.0 }
        if ex.equipment.contains(.barbell) { return 2.5 }
        if ex.equipment.contains(.dumbbell) { return 2.0 }
        if ex.equipment.contains(.machine) || ex.equipment.contains(.cable) {
            return ex.category == .isolation ? 2.5 : 2.5
        }
        if ex.category == .isolation { return 1.25 }
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
        case "green": return .green
        case "blue": return .blue
        case "orange": return STRQBrand.steel
        case "red": return .red
        case "purple": return .purple
        case "teal": return .teal
        default: return STRQBrand.steel
        }
    }
}

struct WorkoutCompletionView: View {
    let vm: AppViewModel
    let session: WorkoutSession?
    let onDismiss: () -> Void

    @State private var appeared: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 28) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.06))
                            .frame(width: 110, height: 110)
                            .scaleEffect(appeared ? 1 : 0.5)
                            .animation(.spring(response: 0.6, dampingFraction: 0.5), value: appeared)

                        Image(systemName: "trophy.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.yellow)
                            .scaleEffect(appeared ? 1 : 0.3)
                            .animation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.1), value: appeared)
                    }

                    VStack(spacing: 8) {
                        Text("Workout Complete")
                            .font(.title.bold())
                        Text(session?.dayName ?? "Great session!")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
                }

                if let session {
                    let duration = session.endTime.map { Int($0.timeIntervalSince(session.startTime) / 60) } ?? 0
                    let totalSets = session.exerciseLogs.flatMap(\.sets).filter(\.isCompleted).count
                    let totalReps = session.exerciseLogs.flatMap(\.sets).filter(\.isCompleted).reduce(0) { $0 + $1.reps }
                    let completedExercises = session.exerciseLogs.filter(\.isCompleted).count

                    VStack(spacing: 20) {
                        HStack(spacing: 0) {
                            completionStat("Duration", value: "\(duration)m", icon: "clock.fill", color: STRQBrand.steel)
                            completionStat("Exercises", value: "\(completedExercises)", icon: "figure.strengthtraining.traditional", color: STRQBrand.steel)
                            completionStat("Sets", value: "\(totalSets)", icon: "checkmark.circle.fill", color: .green)
                            completionStat("Reps", value: "\(totalReps)", icon: "repeat", color: STRQBrand.slate)
                        }

                        if session.totalVolume > 0 {
                            VStack(spacing: 4) {
                                Text("Total Volume")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(String(format: "%.0f kg", session.totalVolume))
                                    .font(.system(.title2, design: .rounded, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 36)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.5).delay(0.4), value: appeared)
                }

                Spacer()

                Button { onDismiss() } label: {
                    Text("Done")
                        .font(.body.weight(.bold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.5).delay(0.5), value: appeared)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { withAnimation { appeared = true } }
    }

    private func completionStat(_ title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
