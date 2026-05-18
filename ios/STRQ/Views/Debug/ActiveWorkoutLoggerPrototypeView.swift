import SwiftUI

#if DEBUG
struct ActiveWorkoutLoggerPrototypeView: View {
    let isFullscreen: Bool

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var density: ActiveWorkoutLoggerDensity = .beginner
    @State private var phase: ActiveWorkoutLoggerPhase = .beforeLogging
    @State private var motionStep: ActiveWorkoutLoggerMotionStep = .ready
    @State private var motionSequenceTask: Task<Void, Never>?
    @State private var isMotionSequenceRunning = false
    @State private var logSetFeedbackTrigger = false

    init(isFullscreen: Bool = false) {
        self.isFullscreen = isFullscreen
    }

    private var scenario: ActiveWorkoutLoggerScenario {
        ActiveWorkoutLoggerScenario.make(
            density: density,
            phase: phase,
            motionStep: phase == .beforeLogging ? motionStep : nil
        )
    }

    var body: some View {
        ZStack {
            ActiveWorkoutLoggerStyle.background.ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        debugControls
                            .id(ActiveWorkoutLoggerScrollTarget.top)
                        header
                        currentExercisePanel
                        stateLine
                        if scenario.showUndo && !scenario.restActive {
                            undoStrip
                                .transition(quietInsertionTransition)
                        }
                        setTable
                        if scenario.restActive {
                            restInlineControl
                                .transition(miniPlayerTransition)
                        }
                        secondaryActions
                        upNextPanel
                    }
                    .frame(maxWidth: 430)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 14)
                    .padding(.top, isFullscreen ? 18 : 14)
                    .padding(.bottom, isFullscreen ? 30 : 14)
                }
                .scrollContentBackground(.hidden)
                .onChange(of: phase) { _, _ in
                    scrollToScenarioFocus(using: proxy)
                }
                .onChange(of: density) { _, _ in
                    scrollToScenarioFocus(using: proxy)
                }
            }

            if isFullscreen {
                topSafeAreaShield
            }
        }
        .preferredColorScheme(.dark)
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.52), trigger: logSetFeedbackTrigger)
        .onDisappear {
            cancelMotionSequence()
        }
    }

    private func scrollToScenarioFocus(using proxy: ScrollViewProxy) {
        guard isFullscreen else { return }

        let target = scenario.scrollTarget
        let anchor = scenario.scrollAnchor

        DispatchQueue.main.async {
            if reduceMotion {
                proxy.scrollTo(target, anchor: anchor)
            } else {
                withAnimation(.easeInOut(duration: 0.24)) {
                    proxy.scrollTo(target, anchor: anchor)
                }
            }
        }
    }

    private var phaseSelection: Binding<ActiveWorkoutLoggerPhase> {
        Binding(
            get: { phase },
            set: { selectPhase($0) }
        )
    }

    private var rowSettleAnimation: Animation {
        reduceMotion ? .easeOut(duration: 0.08) : .easeOut(duration: 0.16)
    }

    private var rowSignatureAnimation: Animation {
        reduceMotion ? .easeOut(duration: 0.08) : .spring(response: 0.28, dampingFraction: 0.9, blendDuration: 0)
    }

    private var quietRevealAnimation: Animation {
        reduceMotion ? .easeOut(duration: 0.08) : .easeOut(duration: 0.26)
    }

    private var miniPlayerAnimation: Animation {
        reduceMotion ? .easeOut(duration: 0.08) : .easeInOut(duration: 0.28)
    }

    private var quietInsertionTransition: AnyTransition {
        let insertion: AnyTransition = reduceMotion ? .opacity : .opacity.combined(with: .offset(y: 10))
        return .asymmetric(
            insertion: insertion.animation(quietRevealAnimation),
            removal: AnyTransition.opacity.animation(.easeOut(duration: 0.08))
        )
    }

    private var miniPlayerTransition: AnyTransition {
        let insertion: AnyTransition = reduceMotion ? .opacity : .opacity.combined(with: .offset(y: 12))
        return .asymmetric(
            insertion: insertion.animation(miniPlayerAnimation),
            removal: AnyTransition.opacity.animation(.easeOut(duration: 0.08))
        )
    }

    private var isPrimaryActionDisabled: Bool {
        isMotionSequenceRunning
    }

    private func selectPhase(_ newPhase: ActiveWorkoutLoggerPhase) {
        cancelMotionSequence()
        motionStep = .ready
        phase = newPhase
    }

    private func handlePrimaryAction() {
        guard !isPrimaryActionDisabled else { return }

        if phase == .beforeLogging {
            startMotionSequence()
        } else {
            cancelMotionSequence()
            withAnimation(rowSettleAnimation) {
                phase = scenario.nextPhaseFromPrimary
            }
        }
    }

    private func startMotionSequence() {
        guard phase == .beforeLogging, motionStep == .ready, !isMotionSequenceRunning else { return }

        motionSequenceTask?.cancel()
        isMotionSequenceRunning = true
        logSetFeedbackTrigger.toggle()

        motionSequenceTask = Task { @MainActor in
            motionStep = .rowComplete
            guard await pauseMotion(milliseconds: reduceMotion ? 70 : 230) else { return }

            motionStep = .undoVisible
            guard await pauseMotion(milliseconds: reduceMotion ? 70 : 320) else { return }

            motionStep = .restVisible
            guard await pauseMotion(milliseconds: reduceMotion ? 70 : 320) else { return }

            motionStep = .nextActive
            isMotionSequenceRunning = false
            motionSequenceTask = nil
        }
    }

    private func resetMotionPrototype() {
        cancelMotionSequence()
        phase = .beforeLogging
        motionStep = .ready
    }

    private func startNextFromRest() {
        cancelMotionSequence()
        withAnimation(rowSettleAnimation) {
            if phase == .beforeLogging {
                motionStep = .nextActive
            } else {
                phase = .afterOne
            }
        }
    }

    private func cancelMotionSequence() {
        motionSequenceTask?.cancel()
        motionSequenceTask = nil
        isMotionSequenceRunning = false
    }

    private func pauseMotion(milliseconds: Int) async -> Bool {
        do {
            try await Task.sleep(nanoseconds: UInt64(milliseconds) * 1_000_000)
            return !Task.isCancelled
        } catch {
            return false
        }
    }

    private var topSafeAreaShield: some View {
        VStack(spacing: 0) {
            ActiveWorkoutLoggerStyle.background
                .frame(height: 58)
                .overlay(alignment: .bottom) {
                    LinearGradient(
                        colors: [
                            ActiveWorkoutLoggerStyle.background,
                            ActiveWorkoutLoggerStyle.background.opacity(0)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 18)
                    .offset(y: 18)
                }

            Spacer(minLength: 0)
        }
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
    }

    private var debugControls: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(verbatim: "Active Workout Logger")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)

                Spacer(minLength: 8)

                Text(verbatim: "DEBUG")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(ActiveWorkoutLoggerStyle.signal)
                    .padding(.horizontal, 8)
                    .frame(height: 24)
                    .background(ActiveWorkoutLoggerStyle.signal.opacity(0.12), in: .capsule)
                    .overlay(Capsule().strokeBorder(ActiveWorkoutLoggerStyle.signal.opacity(0.22), lineWidth: 1))

                if isFullscreen {
                    Button {
                        dismiss()
                    } label: {
                        STRQIconView(.close, size: 11, tint: STRQColors.iconSecondary)
                            .frame(width: 28, height: 28)
                            .background(ActiveWorkoutLoggerStyle.control, in: Circle())
                            .overlay(Circle().strokeBorder(ActiveWorkoutLoggerStyle.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close prototype")
                }
            }

            HStack(spacing: 6) {
                segmentedControl(
                    items: ActiveWorkoutLoggerDensity.allCases,
                    selection: $density,
                    label: \.title
                )

                segmentedControl(
                    items: ActiveWorkoutLoggerPhase.allCases,
                    selection: phaseSelection,
                    label: \.shortTitle
                )
            }
        }
    }

    private func segmentedControl<Item: Hashable>(
        items: [Item],
        selection: Binding<Item>,
        label: @escaping (Item) -> String
    ) -> some View {
        HStack(spacing: 3) {
            ForEach(items, id: \.self) { item in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selection.wrappedValue = item
                    }
                } label: {
                    Text(verbatim: label(item))
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(selection.wrappedValue == item ? STRQColors.primaryText : STRQColors.mutedText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .background(
                            selection.wrappedValue == item
                                ? ActiveWorkoutLoggerStyle.surfaceHot
                                : Color.clear,
                            in: .rect(cornerRadius: 9)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .frame(maxWidth: .infinity)
        .background(ActiveWorkoutLoggerStyle.control, in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(ActiveWorkoutLoggerStyle.border, lineWidth: 1)
        )
    }

    private var header: some View {
        VStack(spacing: 10) {
            HStack(alignment: .center, spacing: 10) {
                Button {} label: {
                    STRQIconView(.chevronLeft, size: 15, tint: STRQColors.iconSecondary)
                        .frame(width: 38, height: 38)
                        .background(ActiveWorkoutLoggerStyle.control, in: Circle())
                        .overlay(Circle().strokeBorder(ActiveWorkoutLoggerStyle.border, lineWidth: 1))
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: "Chest & Back")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(STRQColors.mutedText)
                        .textCase(.uppercase)
                    Text(verbatim: scenario.elapsed)
                        .font(.system(size: 27, weight: .black, design: .rounded).monospacedDigit())
                        .foregroundStyle(STRQColors.primaryText)
                }

                Spacer(minLength: 8)

                Button {} label: {
                    HStack(spacing: 7) {
                        Text(verbatim: scenario.exerciseProgress)
                            .font(.system(size: 12, weight: .black).monospacedDigit())
                        STRQIconView(.checklist, size: 14, tint: STRQColors.iconSecondary)
                    }
                    .foregroundStyle(STRQColors.secondaryText)
                    .padding(.horizontal, 11)
                    .frame(height: 36)
                    .background(ActiveWorkoutLoggerStyle.control, in: .capsule)
                    .overlay(Capsule().strokeBorder(ActiveWorkoutLoggerStyle.border, lineWidth: 1))
                }
                .buttonStyle(.plain)

                finishButton(isPromoted: scenario.isComplete)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(ActiveWorkoutLoggerStyle.track)
                    Capsule()
                        .fill(scenario.isComplete ? STRQColors.successGreen : ActiveWorkoutLoggerStyle.steel)
                        .frame(width: proxy.size.width * scenario.workoutProgress)
                }
            }
            .frame(height: 3)
        }
        .padding(12)
        .background(
            LinearGradient(
                colors: [
                    ActiveWorkoutLoggerStyle.surface,
                    ActiveWorkoutLoggerStyle.surfaceDeep
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 22, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(ActiveWorkoutLoggerStyle.borderStrong, lineWidth: 1)
        )
    }

    private func finishButton(isPromoted: Bool) -> some View {
        Button {} label: {
            HStack(spacing: 6) {
                STRQIconView(.checkCircle, size: isPromoted ? 14 : 12, tint: isPromoted ? STRQColors.actionText : STRQColors.iconSecondary.opacity(0.78))
                Text(verbatim: "Finish")
                    .font(.system(size: isPromoted ? 12 : 11, weight: .black))
                    .lineLimit(1)
            }
            .foregroundStyle(isPromoted ? STRQColors.actionText : STRQColors.mutedText)
            .padding(.horizontal, isPromoted ? 13 : 10)
            .frame(height: isPromoted ? 36 : 32)
            .background(
                isPromoted ? AnyShapeStyle(STRQColors.primaryAccent) : AnyShapeStyle(Color.white.opacity(0.025)),
                in: .capsule
            )
            .overlay(
                Capsule()
                    .strokeBorder(isPromoted ? Color.white.opacity(0.35) : Color.white.opacity(0.06), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var currentExercisePanel: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .top, spacing: 10) {
                exerciseTile

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(verbatim: "1 of 6")
                            .font(.system(size: 10, weight: .black).monospacedDigit())
                            .foregroundStyle(ActiveWorkoutLoggerStyle.signal)
                        Rectangle()
                            .fill(ActiveWorkoutLoggerStyle.borderStrong)
                            .frame(width: 1, height: 12)
                        Text(verbatim: "Barbell")
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(STRQColors.mutedText)
                    }
                    .textCase(.uppercase)

                    Text(verbatim: scenario.exerciseName)
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.72)

                    Text(verbatim: scenario.exerciseDetail)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 5) {
                    Text(verbatim: scenario.setProgress)
                        .font(.system(size: 12, weight: .black).monospacedDigit())
                        .foregroundStyle(STRQColors.primaryText)
                        .padding(.horizontal, 10)
                        .frame(height: 30)
                        .background(Color.white.opacity(0.06), in: .capsule)
                        .overlay(Capsule().strokeBorder(ActiveWorkoutLoggerStyle.borderStrong, lineWidth: 1))

                    Text(verbatim: scenario.targetLine)
                        .font(.system(size: 10, weight: .bold).monospacedDigit())
                        .foregroundStyle(STRQColors.mutedText)
                        .lineLimit(1)
                }
            }

            HStack(spacing: 7) {
                metricPill(icon: .target, title: "Target", value: scenario.target)
                metricPill(icon: .clock, title: "Rest", value: scenario.restTarget)
                if density == .athlete {
                    metricPill(icon: .trendUp, title: "e1RM", value: scenario.e1RMHint)
                }
            }
        }
        .padding(11)
        .background {
            ZStack(alignment: .topTrailing) {
                LinearGradient(
                    colors: [
                        ActiveWorkoutLoggerStyle.surfaceHot,
                        ActiveWorkoutLoggerStyle.surface,
                        ActiveWorkoutLoggerStyle.surfaceDeep
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                STRQIconView(.barbell, size: 96, tint: Color.white.opacity(0.04))
                    .offset(x: 14, y: -16)
            }
            .clipShape(.rect(cornerRadius: 22, style: .continuous))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(ActiveWorkoutLoggerStyle.borderStrong, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 18, y: 10)
    }

    private var exerciseTile: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            ActiveWorkoutLoggerStyle.signal.opacity(0.22),
                            Color.white.opacity(0.075),
                            ActiveWorkoutLoggerStyle.steel.opacity(0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            STRQIconView(.barbell, size: 30, tint: STRQColors.primaryText)
            VStack {
                Spacer()
                Rectangle()
                    .fill(ActiveWorkoutLoggerStyle.signal)
                    .frame(height: 3)
            }
        }
        .frame(width: 54, height: 54)
        .overlay(
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    private func metricPill(icon: STRQIcon, title: String, value: String) -> some View {
        HStack(spacing: 7) {
            STRQIconView(icon, size: 13, tint: ActiveWorkoutLoggerStyle.signal)
            VStack(alignment: .leading, spacing: 1) {
                Text(verbatim: title)
                    .font(.system(size: 8, weight: .black))
                    .foregroundStyle(STRQColors.mutedText)
                    .textCase(.uppercase)
                Text(verbatim: value)
                    .font(.system(size: 11, weight: .black).monospacedDigit())
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 9)
        .frame(height: 42)
        .background(ActiveWorkoutLoggerStyle.control, in: .rect(cornerRadius: 13))
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .strokeBorder(ActiveWorkoutLoggerStyle.border, lineWidth: 1)
        )
    }

    private var stateLine: some View {
        HStack(spacing: 10) {
            STRQIconView(scenario.stateIcon, size: 15, tint: scenario.stateTint)
                .frame(width: 30, height: 30)
                .background(scenario.stateTint.opacity(0.12), in: Circle())
                .overlay(Circle().strokeBorder(scenario.stateTint.opacity(0.25), lineWidth: 1))

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: scenario.stateTitle)
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Text(verbatim: scenario.stateSubtitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .layoutPriority(1)

            Spacer(minLength: 8)

            if scenario.restActive {
                Text(verbatim: scenario.restRemaining)
                    .font(.system(size: 18, weight: .black, design: .rounded).monospacedDigit())
                    .foregroundStyle(ActiveWorkoutLoggerStyle.signal)
            } else if phase == .beforeLogging && motionStep != .ready {
                stateSavedPill
            } else if !scenario.isComplete {
                statePrimaryActionButton
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(ActiveWorkoutLoggerStyle.control, in: .rect(cornerRadius: 17))
        .overlay(
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .strokeBorder(scenario.restActive ? ActiveWorkoutLoggerStyle.signal.opacity(0.2) : ActiveWorkoutLoggerStyle.border, lineWidth: 1)
        )
    }

    private var statePrimaryActionButton: some View {
        Button {
            handlePrimaryAction()
        } label: {
            HStack(spacing: 6) {
                STRQIconView(scenario.primaryActionIcon, size: 13, tint: STRQColors.actionText)
                Text(verbatim: scenario.primaryActionTitle)
                    .font(.system(size: 13, weight: .black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
            .foregroundStyle(STRQColors.actionText)
            .padding(.horizontal, 13)
            .frame(height: 38)
            .background(STRQColors.primaryAccent, in: .rect(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
            )
            .opacity(isPrimaryActionDisabled ? 0.58 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isPrimaryActionDisabled)
    }

    private var stateSavedPill: some View {
        HStack(spacing: 6) {
            STRQIconView(.check, size: 12, tint: STRQColors.successGreen)
            Text(verbatim: "Saved")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(STRQColors.secondaryText)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .frame(height: 34)
        .background(STRQColors.successGreen.opacity(0.11), in: .capsule)
        .overlay(Capsule().strokeBorder(STRQColors.successGreen.opacity(0.24), lineWidth: 1))
        .transition(quietInsertionTransition)
    }

    private var setTable: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: "Sets")
                        .font(.system(size: 19, weight: .black, design: .rounded))
                        .foregroundStyle(STRQColors.primaryText)
                    Text(verbatim: scenario.tableSubtitle)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(STRQColors.mutedText)
                }

                Spacer(minLength: 8)

                tableProgressDots
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            .padding(.bottom, 8)

            tableHeader

            VStack(spacing: 5) {
                ForEach(scenario.sets) { set in
                    setRow(set)
                        .id(ActiveWorkoutLoggerScrollTarget.set(set.number))
                }
            }
            .padding(.horizontal, 6)
            .padding(.bottom, 6)
        }
        .background(
            LinearGradient(
                colors: [
                    ActiveWorkoutLoggerStyle.surface,
                    ActiveWorkoutLoggerStyle.surfaceDeep
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 22, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(ActiveWorkoutLoggerStyle.borderStrong, lineWidth: 1)
        )
    }

    private var tableProgressDots: some View {
        HStack(spacing: 5) {
            ForEach(scenario.sets) { set in
                Capsule()
                    .fill(set.completed ? STRQColors.successGreen.opacity(0.62) : set.isActive ? STRQColors.primaryAccent : STRQColors.gray600)
                    .frame(width: set.isActive ? 22 : 8, height: 8)
                    .overlay(Capsule().strokeBorder(Color.white.opacity(set.isActive ? 0.22 : 0.08), lineWidth: 1))
            }
        }
        .padding(.horizontal, 9)
        .frame(height: 28)
        .background(ActiveWorkoutLoggerStyle.control, in: .capsule)
        .overlay(Capsule().strokeBorder(ActiveWorkoutLoggerStyle.border, lineWidth: 1))
    }

    private var tableHeader: some View {
        HStack(spacing: 7) {
            tableHeaderText("Set", width: 38, alignment: .leading)
            tableHeaderText("Previous", width: density.previousColumnWidth)
            tableHeaderText("kg")
            tableHeaderText("reps")
            tableHeaderText("", width: 34)
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 6)
    }

    private func tableHeaderText(_ text: String, width: CGFloat? = nil, alignment: Alignment = .center) -> some View {
        Text(verbatim: text)
            .font(.system(size: 9, weight: .black))
            .foregroundStyle(STRQColors.mutedText)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: alignment)
            .frame(width: width)
    }

    private func setRow(_ set: ActiveWorkoutLoggerSet) -> some View {
        HStack(spacing: 6) {
            setNumberCell(set)
                .frame(width: 38, alignment: .leading)

            VStack(spacing: 2) {
                Text(verbatim: set.previous)
                    .font(.system(size: 12, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(set.isActive ? STRQColors.secondaryText : STRQColors.mutedText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                if density == .athlete, let delta = set.delta {
                    Text(verbatim: delta)
                        .font(.system(size: 8, weight: .black).monospacedDigit())
                        .foregroundStyle(set.deltaTint)
                        .lineLimit(1)
                }
            }
            .frame(width: density.previousColumnWidth)

            inputCell(set.weight, active: set.isActive, completed: set.completed)
            inputCell(set.reps, active: set.isActive, completed: set.completed)

            doneCell(set)
                .frame(width: 34)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, density.rowVerticalPadding)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(rowBackground(set))
                .animation(rowSignatureAnimation, value: set.completed)
                .animation(rowSignatureAnimation, value: set.isActive)
        }
        .overlay(alignment: .leading) {
            Capsule()
                .fill(rowRail(set))
                .frame(width: rowRailWidth(set))
                .padding(.vertical, 8)
                .padding(.leading, 1)
                .animation(rowSignatureAnimation, value: motionStep)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(rowBorder(set), lineWidth: 1)
                .animation(rowSignatureAnimation, value: set.completed)
                .animation(rowSignatureAnimation, value: set.isActive)
        )
        .offset(y: rowMotionOffset(set))
        .animation(rowSignatureAnimation, value: motionStep)
    }

    private func setNumberCell(_ set: ActiveWorkoutLoggerSet) -> some View {
        Text(verbatim: set.kind)
            .font(.system(size: set.kind.count > 1 ? 10 : 14, weight: .black, design: .rounded).monospacedDigit())
            .foregroundStyle(set.isActive ? STRQColors.actionText : set.completed ? STRQColors.primaryText : STRQColors.mutedText)
            .frame(width: 30, height: 30)
            .background(
                set.isActive
                    ? AnyShapeStyle(STRQColors.primaryAccent)
                    : AnyShapeStyle(Color.white.opacity(set.completed ? 0.08 : 0.035)),
                in: Circle()
            )
            .overlay(Circle().strokeBorder(Color.white.opacity(set.isActive ? 0.32 : 0.08), lineWidth: 1))
    }

    private func inputCell(_ value: String, active: Bool, completed: Bool) -> some View {
        Text(verbatim: value)
            .font(.system(size: active ? 17 : 15, weight: .black, design: .rounded).monospacedDigit())
            .foregroundStyle(active || completed ? STRQColors.primaryText : STRQColors.mutedText)
            .lineLimit(1)
            .minimumScaleFactor(0.58)
            .frame(maxWidth: .infinity)
            .frame(height: density.inputHeight)
            .background(
                active
                    ? ActiveWorkoutLoggerStyle.inputActive
                    : ActiveWorkoutLoggerStyle.inputIdle,
                in: .rect(cornerRadius: 12, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(active ? ActiveWorkoutLoggerStyle.steel.opacity(0.42) : ActiveWorkoutLoggerStyle.border, lineWidth: 1)
            )
    }

    private func doneCell(_ set: ActiveWorkoutLoggerSet) -> some View {
        ZStack {
            Circle()
                .strokeBorder(STRQColors.successGreen.opacity(0.34), lineWidth: 2)
                .opacity(isSignatureCompletedSet(set) ? 1 : 0)
            Circle()
                .fill(STRQColors.successGreen.opacity(0.2))
                .opacity(set.completed ? 1 : 0)
            Circle()
                .strokeBorder(STRQColors.successGreen.opacity(0.52), lineWidth: 1)
                .opacity(set.completed ? 1 : 0)
            STRQIconView(.check, size: isSignatureCompletedSet(set) ? 14 : 12, tint: STRQColors.successGreen)
                .opacity(set.completed ? 1 : 0)

            Circle()
                .strokeBorder(STRQColors.primaryText.opacity(0.82), lineWidth: 1.4)
                .opacity(set.isActive ? 1 : 0)
            Circle()
                .fill(STRQColors.primaryText)
                .frame(width: 6, height: 6)
                .opacity(set.isActive ? 1 : 0)

            Circle()
                .strokeBorder(STRQColors.gray600, lineWidth: 1)
                .opacity(!set.completed && !set.isActive ? 1 : 0)
        }
        .frame(width: 26, height: 26)
        .animation(rowSignatureAnimation, value: set.completed)
        .animation(rowSignatureAnimation, value: set.isActive)
        .animation(rowSignatureAnimation, value: motionStep)
    }

    private func rowBackground(_ set: ActiveWorkoutLoggerSet) -> Color {
        if isSignatureCompletedSet(set) { return STRQColors.successDim.opacity(0.24) }
        if isSignatureNextSet(set) { return Color.white.opacity(0.1) }
        if set.isActive { return Color.white.opacity(0.07) }
        if set.completed { return STRQColors.successDim.opacity(0.14) }
        return Color.white.opacity(0.025)
    }

    private func rowBorder(_ set: ActiveWorkoutLoggerSet) -> Color {
        if isSignatureCompletedSet(set) { return STRQColors.successGreen.opacity(0.22) }
        if isSignatureNextSet(set) { return ActiveWorkoutLoggerStyle.steel.opacity(0.6) }
        if set.isActive { return ActiveWorkoutLoggerStyle.steel.opacity(0.42) }
        if set.completed { return STRQColors.successGreen.opacity(0.1) }
        return ActiveWorkoutLoggerStyle.border
    }

    private func rowRail(_ set: ActiveWorkoutLoggerSet) -> Color {
        if isSignatureCompletedSet(set) { return STRQColors.successGreen.opacity(0.82) }
        if isSignatureNextSet(set) { return STRQColors.primaryAccent }
        if set.completed { return STRQColors.successGreen.opacity(0.55) }
        if set.isActive { return STRQColors.primaryAccent.opacity(0.86) }
        return STRQColors.gray700
    }

    private func rowRailWidth(_ set: ActiveWorkoutLoggerSet) -> CGFloat {
        isSignatureCompletedSet(set) || isSignatureNextSet(set) ? 5 : 3
    }

    private func rowMotionOffset(_ set: ActiveWorkoutLoggerSet) -> CGFloat {
        guard !reduceMotion else { return 0 }
        if isSignatureCompletedSet(set) { return -2 }
        if isSignatureNextSet(set) { return -3 }
        return 0
    }

    private func isSignatureCompletedSet(_ set: ActiveWorkoutLoggerSet) -> Bool {
        guard phase == .beforeLogging, set.number == 1 else { return false }
        return motionStep == .rowComplete || motionStep == .undoVisible || motionStep == .restVisible
    }

    private func isSignatureNextSet(_ set: ActiveWorkoutLoggerSet) -> Bool {
        phase == .beforeLogging && set.number == 2 && motionStep == .nextActive
    }

    private var secondaryActions: some View {
        HStack(spacing: 8) {
            secondaryAction(icon: .info, title: "Guide")
            secondaryAction(icon: .swap, title: "Swap")
            secondaryAction(icon: .edit, title: "Notes")
        }
    }

    private func secondaryAction(icon: STRQIcon, title: String) -> some View {
        Button {} label: {
            HStack(spacing: 7) {
                STRQIconView(icon, size: 14, tint: STRQColors.iconSecondary)
                Text(verbatim: title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            .background(ActiveWorkoutLoggerStyle.control, in: .rect(cornerRadius: 13))
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(ActiveWorkoutLoggerStyle.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var upNextPanel: some View {
        HStack(spacing: 10) {
            STRQIconView(.arrowRight, size: 16, tint: ActiveWorkoutLoggerStyle.signal)
                .frame(width: 34, height: 34)
                .background(ActiveWorkoutLoggerStyle.signal.opacity(0.12), in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(verbatim: "Up next")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(STRQColors.mutedText)
                    .textCase(.uppercase)
                Text(verbatim: scenario.upNext)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 8)

            Text(verbatim: "2 of 6")
                .font(.system(size: 11, weight: .black).monospacedDigit())
                .foregroundStyle(STRQColors.secondaryText)
        }
        .padding(10)
        .background(ActiveWorkoutLoggerStyle.control, in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(ActiveWorkoutLoggerStyle.border, lineWidth: 1)
        )
    }

    private var restInlineControl: some View {
        controlShell {
            restMiniPlayer
        }
        .shadow(color: .black.opacity(0.16), radius: 16, y: 8)
    }

    private func controlShell<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 7) {
            content()
        }
        .padding(8)
        .background(
            ActiveWorkoutLoggerStyle.bottomGlass,
            in: .rect(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(ActiveWorkoutLoggerStyle.border, lineWidth: 1)
        )
    }

    private var undoStrip: some View {
        HStack(spacing: 8) {
            Text(verbatim: scenario.undoTitle)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(STRQColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 8)
            Button {
                resetMotionPrototype()
            } label: {
                Text(verbatim: "Undo")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(STRQColors.secondaryText)
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .background(Color.white.opacity(0.045), in: .capsule)
                    .overlay(Capsule().strokeBorder(ActiveWorkoutLoggerStyle.border, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .frame(height: 40)
        .background(ActiveWorkoutLoggerStyle.control.opacity(0.82), in: .rect(cornerRadius: 14))
    }

    private var restMiniPlayer: some View {
        VStack(spacing: 7) {
            HStack(spacing: 8) {
                Text(verbatim: scenario.undoTitle)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 8)

                Button {
                    resetMotionPrototype()
                } label: {
                    Text(verbatim: "Undo")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(STRQColors.secondaryText)
                        .padding(.horizontal, 12)
                        .frame(height: 30)
                        .background(Color.white.opacity(0.045), in: .capsule)
                        .overlay(Capsule().strokeBorder(ActiveWorkoutLoggerStyle.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)
            .frame(height: 34)
            .background(ActiveWorkoutLoggerStyle.control.opacity(0.64), in: .rect(cornerRadius: 14))

            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: "Rest")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(STRQColors.mutedText)
                        .textCase(.uppercase)
                    Text(verbatim: scenario.restRemaining)
                        .font(.system(size: 23, weight: .black, design: .rounded).monospacedDigit())
                        .foregroundStyle(ActiveWorkoutLoggerStyle.signal)
                }

                Spacer(minLength: 8)

                restButton("-15")
                restButton("+15")
                Button {
                    startNextFromRest()
                } label: {
                    Text(verbatim: "Start next")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(STRQColors.actionText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.74)
                        .padding(.horizontal, 13)
                        .frame(height: 38)
                        .background(STRQColors.primaryAccent, in: .capsule)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func restButton(_ title: String) -> some View {
        Button {} label: {
            Text(verbatim: title)
                .font(.system(size: 12, weight: .black).monospacedDigit())
                .foregroundStyle(STRQColors.primaryText)
                .frame(width: 38, height: 34)
                .background(Color.white.opacity(0.045), in: .capsule)
                .overlay(Capsule().strokeBorder(ActiveWorkoutLoggerStyle.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

private enum ActiveWorkoutLoggerDensity: String, CaseIterable, Hashable {
    case beginner
    case athlete

    var title: String {
        switch self {
        case .beginner: return "Beginner"
        case .athlete: return "Athlete"
        }
    }

    var previousColumnWidth: CGFloat {
        switch self {
        case .beginner: return 58
        case .athlete: return 68
        }
    }

    var rowVerticalPadding: CGFloat {
        switch self {
        case .beginner: return 7
        case .athlete: return 6
        }
    }

    var inputHeight: CGFloat {
        switch self {
        case .beginner: return 34
        case .athlete: return 32
        }
    }
}

private enum ActiveWorkoutLoggerPhase: String, CaseIterable, Hashable {
    case beforeLogging
    case afterOne
    case rest
    case complete

    var shortTitle: String {
        switch self {
        case .beforeLogging: return "Before"
        case .afterOne: return "Logged"
        case .rest: return "Rest"
        case .complete: return "Done"
        }
    }
}

private enum ActiveWorkoutLoggerMotionStep: Hashable {
    case ready
    case rowComplete
    case undoVisible
    case restVisible
    case nextActive
}

private enum ActiveWorkoutLoggerScrollTarget {
    static let top = "top"

    static func set(_ number: Int) -> String {
        "set-\(number)"
    }
}

private struct ActiveWorkoutLoggerScenario {
    let density: ActiveWorkoutLoggerDensity
    let phase: ActiveWorkoutLoggerPhase
    let motionStep: ActiveWorkoutLoggerMotionStep?
    let sets: [ActiveWorkoutLoggerSet]
    let elapsed: String
    let exerciseName: String
    let exerciseDetail: String
    let exerciseProgress: String
    let setProgress: String
    let targetLine: String
    let target: String
    let restTarget: String
    let e1RMHint: String
    let tableSubtitle: String
    let stateTitle: String
    let stateSubtitle: String
    let stateIcon: STRQIcon
    let stateTint: Color
    let restRemaining: String
    let restActive: Bool
    let showUndo: Bool
    let undoTitle: String
    let justLogged: String
    let nextSet: String
    let upNext: String
    let primaryActionTitle: String
    let primaryActionDetail: String
    let primaryActionEyebrow: String
    let primaryActionIcon: STRQIcon
    let nextPhaseFromPrimary: ActiveWorkoutLoggerPhase

    var workoutProgress: CGFloat {
        CGFloat(sets.filter(\.completed).count) / 24.0
    }

    var isComplete: Bool {
        phase == .complete
    }

    var scrollTarget: String {
        switch phase {
        case .beforeLogging:
            return ActiveWorkoutLoggerScrollTarget.top
        case .afterOne:
            return ActiveWorkoutLoggerScrollTarget.set(2)
        case .rest:
            return ActiveWorkoutLoggerScrollTarget.set(3)
        case .complete:
            return ActiveWorkoutLoggerScrollTarget.set(4)
        }
    }

    var scrollAnchor: UnitPoint {
        switch phase {
        case .beforeLogging:
            return .top
        case .afterOne, .rest:
            return .center
        case .complete:
            return UnitPoint(x: 0.5, y: 0.58)
        }
    }

    static func make(
        density: ActiveWorkoutLoggerDensity,
        phase: ActiveWorkoutLoggerPhase,
        motionStep: ActiveWorkoutLoggerMotionStep? = nil
    ) -> ActiveWorkoutLoggerScenario {
        let motionStep = phase == .beforeLogging ? motionStep : nil
        let sets = ActiveWorkoutLoggerSet.make(phase: phase, density: density, motionStep: motionStep)
        let completed = sets.filter(\.completed).count
        let active = sets.first(where: \.isActive)?.number ?? min(completed + 1, sets.count)
        let restActive = phase == .rest || motionStep == .restVisible || motionStep == .nextActive
        let complete = phase == .complete
        let loggedSetTitle = motionStep == nil && phase == .rest ? "Set 2 logged - 80 kg x 6" : "Set 1 logged - 80 kg x 8"

        return ActiveWorkoutLoggerScenario(
            density: density,
            phase: phase,
            motionStep: motionStep,
            sets: sets,
            elapsed: elapsed(phase: phase, motionStep: motionStep, restActive: restActive),
            exerciseName: "Barbell Bench Press",
            exerciseDetail: density == .beginner ? "Chest - anchor lift" : "Horizontal push - strength block",
            exerciseProgress: "1/6",
            setProgress: setProgress(phase: phase, motionStep: motionStep, active: active),
            targetLine: density == .beginner ? "Target 6-8" : "80 kg - RPE 8",
            target: density == .beginner ? "6-8 reps" : "80 kg x 6-8",
            restTarget: "120s",
            e1RMHint: complete ? "105" : "101",
            tableSubtitle: tableSubtitle(phase: phase, motionStep: motionStep, completed: completed, active: active),
            stateTitle: stateTitle(phase: phase, motionStep: motionStep),
            stateSubtitle: stateSubtitle(phase: phase, motionStep: motionStep, density: density),
            stateIcon: stateIcon(phase: phase, motionStep: motionStep),
            stateTint: stateTint(phase: phase, motionStep: motionStep),
            restRemaining: restRemaining(phase: phase, motionStep: motionStep),
            restActive: restActive,
            showUndo: phase == .afterOne || phase == .rest || motionStep == .undoVisible || motionStep == .restVisible || motionStep == .nextActive,
            undoTitle: loggedSetTitle,
            justLogged: "Just logged: \(loggedSetTitle)",
            nextSet: phase == .rest && motionStep == nil ? "Next: Set 3 - 80 kg x 6" : "Next: Set 2 - 80 kg x 6",
            upNext: "Incline Bench Press",
            primaryActionTitle: complete ? "Review" : "Log Set",
            primaryActionDetail: complete ? "All working sets are logged." : "Set \(active) selected.",
            primaryActionEyebrow: complete ? "Complete" : "Current set",
            primaryActionIcon: complete ? .checkCircle : .check,
            nextPhaseFromPrimary: complete ? .complete : phase == .beforeLogging ? .afterOne : .rest
        )
    }

    private static func elapsed(
        phase: ActiveWorkoutLoggerPhase,
        motionStep: ActiveWorkoutLoggerMotionStep?,
        restActive: Bool
    ) -> String {
        if phase == .complete { return "41:08" }
        if motionStep == .rowComplete { return "31:57" }
        if motionStep == .undoVisible { return "31:58" }
        if motionStep == .restVisible { return "32:00" }
        if motionStep == .nextActive { return "32:01" }
        if restActive { return "33:42" }
        if phase == .afterOne { return "32:19" }
        return "31:56"
    }

    private static func setProgress(
        phase: ActiveWorkoutLoggerPhase,
        motionStep: ActiveWorkoutLoggerMotionStep?,
        active: Int
    ) -> String {
        if phase == .complete { return "4/4 sets" }
        if motionStep == .rowComplete || motionStep == .undoVisible || motionStep == .restVisible {
            return "1/4 sets"
        }
        return "Set \(active)/4"
    }

    private static func tableSubtitle(
        phase: ActiveWorkoutLoggerPhase,
        motionStep: ActiveWorkoutLoggerMotionStep?,
        completed: Int,
        active: Int
    ) -> String {
        if phase == .complete { return "4/4 logged" }

        switch motionStep {
        case .rowComplete:
            return "1/4 logged - row settling"
        case .undoVisible:
            return "1/4 logged - undo available"
        case .restVisible:
            return "1/4 logged - rest started"
        case .nextActive:
            return "1/4 logged - Set 2 ready"
        case .ready, nil:
            return "\(completed)/4 logged - Set \(active) ready"
        }
    }

    private static func stateTitle(
        phase: ActiveWorkoutLoggerPhase,
        motionStep: ActiveWorkoutLoggerMotionStep?
    ) -> String {
        if let motionStep {
            switch motionStep {
            case .ready: return "Ready to log Set 1"
            case .rowComplete: return "Set 1 logged"
            case .undoVisible: return "Set logged"
            case .restVisible: return "Rest starting"
            case .nextActive: return "Set 2 ready"
            }
        }

        switch phase {
        case .beforeLogging: return "Ready to log Set 1"
        case .afterOne: return "Set logged"
        case .rest: return "Rest running"
        case .complete: return "Exercise complete"
        }
    }

    private static func stateSubtitle(
        phase: ActiveWorkoutLoggerPhase,
        motionStep: ActiveWorkoutLoggerMotionStep?,
        density: ActiveWorkoutLoggerDensity
    ) -> String {
        if let motionStep {
            switch motionStep {
            case .ready:
                return density == .beginner ? "Previous, kg, reps, check." : "Previous, delta, kg, reps."
            case .rowComplete:
                return "80 kg x 8 saved."
            case .undoVisible:
                return "Undo is quiet and non-blocking."
            case .restVisible:
                return "Rest is inline; the table stays usable."
            case .nextActive:
                return "Rest is running; Set 2 is active."
            }
        }

        switch phase {
        case .beforeLogging:
            return density == .beginner ? "Previous, kg, reps, check." : "Previous, delta, kg, reps."
        case .afterOne:
            return "Set 2 is ready."
        case .rest:
            return "Start next when rest is done."
        case .complete:
            return "All working sets are logged."
        }
    }

    private static func stateIcon(
        phase: ActiveWorkoutLoggerPhase,
        motionStep: ActiveWorkoutLoggerMotionStep?
    ) -> STRQIcon {
        if let motionStep {
            switch motionStep {
            case .ready: return .target
            case .rowComplete, .undoVisible: return .checkCircle
            case .restVisible, .nextActive: return .clock
            }
        }

        switch phase {
        case .beforeLogging: return .target
        case .afterOne: return .checkCircle
        case .rest: return .clock
        case .complete: return .trophy
        }
    }

    private static func stateTint(
        phase: ActiveWorkoutLoggerPhase,
        motionStep: ActiveWorkoutLoggerMotionStep?
    ) -> Color {
        if let motionStep {
            switch motionStep {
            case .ready: return ActiveWorkoutLoggerStyle.signal
            case .rowComplete, .undoVisible: return STRQColors.successGreen
            case .restVisible, .nextActive: return ActiveWorkoutLoggerStyle.steel
            }
        }

        switch phase {
        case .beforeLogging: return ActiveWorkoutLoggerStyle.signal
        case .afterOne: return STRQColors.successGreen
        case .rest: return ActiveWorkoutLoggerStyle.steel
        case .complete: return STRQColors.successGreen
        }
    }

    private static func restRemaining(
        phase: ActiveWorkoutLoggerPhase,
        motionStep: ActiveWorkoutLoggerMotionStep?
    ) -> String {
        switch motionStep {
        case .restVisible:
            return "02:00"
        case .nextActive:
            return "01:58"
        case .ready, .rowComplete, .undoVisible, nil:
            return phase == .rest ? "01:17" : "02:00"
        }
    }
}

private struct ActiveWorkoutLoggerSet: Identifiable {
    let id: Int
    let number: Int
    let kind: String
    let previous: String
    let weight: String
    let reps: String
    let completed: Bool
    let isActive: Bool
    let delta: String?
    let deltaTint: Color

    static func make(
        phase: ActiveWorkoutLoggerPhase,
        density: ActiveWorkoutLoggerDensity,
        motionStep: ActiveWorkoutLoggerMotionStep? = nil
    ) -> [ActiveWorkoutLoggerSet] {
        let completed: Set<Int>
        let active: Int?

        if let motionStep {
            switch motionStep {
            case .ready:
                completed = []
                active = 1
            case .rowComplete, .undoVisible, .restVisible:
                completed = [1]
                active = nil
            case .nextActive:
                completed = [1]
                active = 2
            }
        } else {
            switch phase {
            case .beforeLogging:
                completed = []
                active = 1
            case .afterOne:
                completed = [1]
                active = 2
            case .rest:
                completed = [1, 2]
                active = 3
            case .complete:
                completed = [1, 2, 3, 4]
                active = nil
            }
        }

        let firstSetReady = phase == .beforeLogging && (motionStep == nil || motionStep == .ready)
        let rows: [(Int, String, String, String, String, String?)] = density == .beginner
            ? [
                (1, "1", "77.5x8", "80", firstSetReady ? "6-8" : "8", nil),
                (2, "2", "80x6", "80", "6", nil),
                (3, "3", "80x6", "80", "6", nil),
                (4, "4", "77.5x8", "77.5", "8", nil)
            ]
            : [
                (1, "1", "77.5x8", "80", firstSetReady ? "6-8" : "8", "+2.5"),
                (2, "2", "80x6", "80", "6", "="),
                (3, "3", "80x6", "80", "6", "101 e1RM"),
                (4, "4", "77.5x8", "77.5", "8", "-2.5")
            ]

        return rows.map { row in
            ActiveWorkoutLoggerSet(
                id: row.0,
                number: row.0,
                kind: row.1,
                previous: row.2,
                weight: row.3,
                reps: row.4,
                completed: completed.contains(row.0),
                isActive: active == row.0,
                delta: row.5,
                deltaTint: row.5 == "-2.5" ? STRQColors.warning : STRQColors.successGreen
            )
        }
    }
}

private enum ActiveWorkoutLoggerStyle {
    static let background = hex(0x050607)
    static let surfaceDeep = hex(0x090B0F)
    static let surface = hex(0x11151B)
    static let surfaceHot = hex(0x1A2028)
    static let control = hex(0x0C1016)
    static let inputIdle = hex(0x10141A)
    static let inputActive = hex(0x171D25)
    static let bottomGlass = hex(0x0B0F14).opacity(0.9)
    static let track = hex(0x252B32)
    static let border = Color.white.opacity(0.08)
    static let borderStrong = Color.white.opacity(0.14)
    static let steel = hex(0xA9B7C6)
    static let signal = hex(0x7DE0D0)

    private static func hex(_ value: UInt, opacity: Double = 1) -> Color {
        Color(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: opacity
        )
    }
}

private struct ActiveWorkoutLoggerPrototypeView_Previews: PreviewProvider {
    static var previews: some View {
        ActiveWorkoutLoggerPrototypeView()
            .previewDisplayName("Active Workout Logger Prototype")
    }
}
#endif
