import SwiftUI

#if DEBUG
struct ActiveWorkoutLoggerPrototypeView: View {
    let isFullscreen: Bool

    @Environment(\.dismiss) private var dismiss
    @State private var density: ActiveWorkoutLoggerDensity = .beginner
    @State private var phase: ActiveWorkoutLoggerPhase = .beforeLogging

    init(isFullscreen: Bool = false) {
        self.isFullscreen = isFullscreen
    }

    private var scenario: ActiveWorkoutLoggerScenario {
        ActiveWorkoutLoggerScenario.make(density: density, phase: phase)
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
                        setTable
                        if scenario.restActive {
                            restStickyControl
                        }
                        secondaryActions
                        upNextPanel
                        if !scenario.restActive {
                            inlineActionPanel
                        }
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
    }

    private func scrollToScenarioFocus(using proxy: ScrollViewProxy) {
        guard isFullscreen else { return }

        let target = scenario.scrollTarget
        let anchor = scenario.scrollAnchor

        DispatchQueue.main.async {
            withAnimation(.easeInOut(duration: 0.24)) {
                proxy.scrollTo(target, anchor: anchor)
            }
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
                Text("Active Workout Logger")
                    .font(.system(size: 17, weight: .black, design: .rounded))
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.74)

                Spacer(minLength: 8)

                Text("DEBUG")
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
                    selection: $phase,
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
                    Text(label(item))
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
                    Text("Chest & Back")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(STRQColors.mutedText)
                        .textCase(.uppercase)
                    Text(scenario.elapsed)
                        .font(.system(size: 27, weight: .black, design: .rounded).monospacedDigit())
                        .foregroundStyle(STRQColors.primaryText)
                        .contentTransition(.numericText())
                }

                Spacer(minLength: 8)

                Button {} label: {
                    HStack(spacing: 7) {
                        Text(scenario.exerciseProgress)
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
                STRQIconView(.checkCircle, size: 14, tint: isPromoted ? STRQColors.actionText : STRQColors.iconSecondary)
                Text("Finish")
                    .font(.system(size: 12, weight: .black))
                    .lineLimit(1)
            }
            .foregroundStyle(isPromoted ? STRQColors.actionText : STRQColors.secondaryText)
            .padding(.horizontal, isPromoted ? 13 : 10)
            .frame(height: 36)
            .background(
                isPromoted ? AnyShapeStyle(STRQColors.primaryAccent) : AnyShapeStyle(ActiveWorkoutLoggerStyle.control),
                in: .capsule
            )
            .overlay(
                Capsule()
                    .strokeBorder(isPromoted ? Color.white.opacity(0.35) : ActiveWorkoutLoggerStyle.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var currentExercisePanel: some View {
        VStack(alignment: .leading, spacing: 13) {
            HStack(alignment: .top, spacing: 12) {
                exerciseTile

                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Text("1 of 6")
                            .font(.system(size: 10, weight: .black).monospacedDigit())
                            .foregroundStyle(ActiveWorkoutLoggerStyle.signal)
                        Rectangle()
                            .fill(ActiveWorkoutLoggerStyle.borderStrong)
                            .frame(width: 1, height: 12)
                        Text("Barbell")
                            .font(.system(size: 10, weight: .black))
                            .foregroundStyle(STRQColors.mutedText)
                    }
                    .textCase(.uppercase)

                    Text(scenario.exerciseName)
                        .font(.system(size: 25, weight: .black, design: .rounded))
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.74)

                    Text(scenario.exerciseDetail)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: 5) {
                    Text(scenario.setProgress)
                        .font(.system(size: 12, weight: .black).monospacedDigit())
                        .foregroundStyle(STRQColors.primaryText)
                        .padding(.horizontal, 10)
                        .frame(height: 30)
                        .background(Color.white.opacity(0.06), in: .capsule)
                        .overlay(Capsule().strokeBorder(ActiveWorkoutLoggerStyle.borderStrong, lineWidth: 1))

                    Text(scenario.targetLine)
                        .font(.system(size: 10, weight: .bold).monospacedDigit())
                        .foregroundStyle(STRQColors.mutedText)
                        .lineLimit(1)
                }
            }

            HStack(spacing: 8) {
                metricPill(icon: .target, title: "Target", value: scenario.target)
                metricPill(icon: .clock, title: "Rest", value: scenario.restTarget)
                if density == .athlete {
                    metricPill(icon: .trendUp, title: "e1RM", value: scenario.e1RMHint)
                }
            }
        }
        .padding(14)
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

                STRQIconView(.barbell, size: 112, tint: Color.white.opacity(0.045))
                    .offset(x: 14, y: -16)
            }
            .clipShape(.rect(cornerRadius: 24, style: .continuous))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(ActiveWorkoutLoggerStyle.borderStrong, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.24), radius: 24, y: 14)
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
        .frame(width: 62, height: 62)
        .overlay(
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    private func metricPill(icon: STRQIcon, title: String, value: String) -> some View {
        HStack(spacing: 7) {
            STRQIconView(icon, size: 13, tint: ActiveWorkoutLoggerStyle.signal)
            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.system(size: 8, weight: .black))
                    .foregroundStyle(STRQColors.mutedText)
                    .textCase(.uppercase)
                Text(value)
                    .font(.system(size: 12, weight: .black).monospacedDigit())
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .frame(height: 48)
        .background(ActiveWorkoutLoggerStyle.control, in: .rect(cornerRadius: 13))
        .overlay(
            RoundedRectangle(cornerRadius: 13, style: .continuous)
                .strokeBorder(ActiveWorkoutLoggerStyle.border, lineWidth: 1)
        )
    }

    private var stateLine: some View {
        HStack(spacing: 10) {
            STRQIconView(scenario.stateIcon, size: 15, tint: scenario.stateTint)
                .frame(width: 32, height: 32)
                .background(scenario.stateTint.opacity(0.12), in: Circle())
                .overlay(Circle().strokeBorder(scenario.stateTint.opacity(0.25), lineWidth: 1))

            VStack(alignment: .leading, spacing: 2) {
                Text(scenario.stateTitle)
                    .font(.system(size: 13, weight: .black))
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
                Text(scenario.stateSubtitle)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 8)

            if scenario.restActive {
                Text(scenario.restRemaining)
                    .font(.system(size: 18, weight: .black, design: .rounded).monospacedDigit())
                    .foregroundStyle(ActiveWorkoutLoggerStyle.signal)
                    .contentTransition(.numericText())
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(ActiveWorkoutLoggerStyle.control, in: .rect(cornerRadius: 17))
        .overlay(
            RoundedRectangle(cornerRadius: 17, style: .continuous)
                .strokeBorder(scenario.restActive ? ActiveWorkoutLoggerStyle.signal.opacity(0.2) : ActiveWorkoutLoggerStyle.border, lineWidth: 1)
        )
    }

    private var setTable: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Sets")
                        .font(.system(size: 19, weight: .black, design: .rounded))
                        .foregroundStyle(STRQColors.primaryText)
                    Text(scenario.tableSubtitle)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(STRQColors.mutedText)
                }

                Spacer(minLength: 8)

                tableProgressDots
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 10)

            tableHeader

            VStack(spacing: 7) {
                ForEach(scenario.sets) { set in
                    setRow(set)
                        .id(ActiveWorkoutLoggerScrollTarget.set(set.number))
                }
            }
            .padding(.horizontal, 7)
            .padding(.bottom, 7)
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
            in: .rect(cornerRadius: 24, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(ActiveWorkoutLoggerStyle.borderStrong, lineWidth: 1)
        )
    }

    private var tableProgressDots: some View {
        HStack(spacing: 5) {
            ForEach(scenario.sets) { set in
                Capsule()
                    .fill(set.completed ? STRQColors.successGreen : set.isActive ? STRQColors.primaryAccent : STRQColors.gray600)
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
            tableHeaderText("Reps")
            tableHeaderText("", width: 34)
        }
        .padding(.horizontal, 14)
        .padding(.bottom, 7)
    }

    private func tableHeaderText(_ text: String, width: CGFloat? = nil, alignment: Alignment = .center) -> some View {
        Text(text)
            .font(.system(size: 9, weight: .black))
            .foregroundStyle(STRQColors.mutedText)
            .textCase(.uppercase)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: width == nil ? .infinity : nil, alignment: alignment)
            .frame(width: width)
    }

    private func setRow(_ set: ActiveWorkoutLoggerSet) -> some View {
        HStack(spacing: 7) {
            setNumberCell(set)
                .frame(width: 38, alignment: .leading)

            VStack(spacing: 2) {
                Text(set.previous)
                    .font(.system(size: 12, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(set.isActive ? STRQColors.secondaryText : STRQColors.mutedText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                if density == .athlete, let delta = set.delta {
                    Text(delta)
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
        .padding(.horizontal, 9)
        .padding(.vertical, density.rowVerticalPadding)
        .background(rowBackground(set), in: .rect(cornerRadius: 16, style: .continuous))
        .overlay(alignment: .leading) {
            Capsule()
                .fill(rowRail(set))
                .frame(width: 3)
                .padding(.vertical, 10)
                .padding(.leading, 1)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(rowBorder(set), lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.18), value: phase)
    }

    private func setNumberCell(_ set: ActiveWorkoutLoggerSet) -> some View {
        Text(set.kind)
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
        Text(value)
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
            if set.completed {
                Circle().fill(STRQColors.successGreen)
                STRQIconView(.check, size: 12, tint: STRQColors.actionText)
            } else if set.isActive {
                Circle().strokeBorder(STRQColors.primaryText.opacity(0.82), lineWidth: 1.4)
                Circle().fill(STRQColors.primaryText).frame(width: 6, height: 6)
            } else {
                Circle().strokeBorder(STRQColors.gray600, lineWidth: 1)
            }
        }
        .frame(width: 26, height: 26)
    }

    private func rowBackground(_ set: ActiveWorkoutLoggerSet) -> Color {
        if set.isActive { return Color.white.opacity(0.07) }
        if set.completed { return STRQColors.successDim.opacity(0.32) }
        return Color.white.opacity(0.025)
    }

    private func rowBorder(_ set: ActiveWorkoutLoggerSet) -> Color {
        if set.isActive { return ActiveWorkoutLoggerStyle.steel.opacity(0.42) }
        if set.completed { return STRQColors.successGreen.opacity(0.16) }
        return ActiveWorkoutLoggerStyle.border
    }

    private func rowRail(_ set: ActiveWorkoutLoggerSet) -> Color {
        if set.completed { return STRQColors.successGreen.opacity(0.9) }
        if set.isActive { return STRQColors.primaryAccent.opacity(0.86) }
        return STRQColors.gray700
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
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 42)
            .background(ActiveWorkoutLoggerStyle.control, in: .rect(cornerRadius: 13))
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .strokeBorder(ActiveWorkoutLoggerStyle.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var upNextPanel: some View {
        HStack(spacing: 11) {
            STRQIconView(.arrowRight, size: 16, tint: ActiveWorkoutLoggerStyle.signal)
                .frame(width: 38, height: 38)
                .background(ActiveWorkoutLoggerStyle.signal.opacity(0.12), in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text("Up next")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(STRQColors.mutedText)
                    .textCase(.uppercase)
                Text(scenario.upNext)
                    .font(.system(size: 14, weight: .black, design: .rounded))
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            Spacer(minLength: 8)

            Text("2 of 6")
                .font(.system(size: 11, weight: .black).monospacedDigit())
                .foregroundStyle(STRQColors.secondaryText)
        }
        .padding(12)
        .background(ActiveWorkoutLoggerStyle.control, in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(ActiveWorkoutLoggerStyle.border, lineWidth: 1)
        )
    }

    private var inlineActionPanel: some View {
        controlShell {
            if scenario.showUndo {
                undoStrip
            }

            logControl
        }
    }

    private var restStickyControl: some View {
        controlShell {
            restMiniPlayer
        }
        .shadow(color: .black.opacity(0.36), radius: 28, y: 14)
    }

    private func controlShell<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 8) {
            content()
        }
        .padding(10)
        .background(
            ActiveWorkoutLoggerStyle.bottomGlass,
            in: .rect(cornerRadius: 24, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(ActiveWorkoutLoggerStyle.borderStrong, lineWidth: 1)
        )
    }

    private var undoStrip: some View {
        HStack(spacing: 8) {
            Text(scenario.undoTitle)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(STRQColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Spacer(minLength: 8)
            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    phase = .beforeLogging
                }
            } label: {
                Text("Undo")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(STRQColors.primaryText)
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .background(Color.white.opacity(0.07), in: .capsule)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .frame(height: 40)
        .background(ActiveWorkoutLoggerStyle.control.opacity(0.82), in: .rect(cornerRadius: 14))
    }

    private var restMiniPlayer: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(scenario.undoTitle)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: 8)

                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        phase = .beforeLogging
                    }
                } label: {
                    Text("Undo")
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(STRQColors.primaryText)
                        .padding(.horizontal, 12)
                        .frame(height: 30)
                        .background(Color.white.opacity(0.07), in: .capsule)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)
            .frame(height: 36)
            .background(ActiveWorkoutLoggerStyle.control.opacity(0.74), in: .rect(cornerRadius: 14))

            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Rest")
                        .font(.system(size: 9, weight: .black))
                        .foregroundStyle(STRQColors.mutedText)
                        .textCase(.uppercase)
                    Text(scenario.restRemaining)
                        .font(.system(size: 25, weight: .black, design: .rounded).monospacedDigit())
                        .foregroundStyle(ActiveWorkoutLoggerStyle.signal)
                }

                Spacer(minLength: 8)

                restButton("-15")
                restButton("+15")
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        phase = .afterOne
                    }
                } label: {
                    STRQIconView(.skip, size: 14, tint: STRQColors.actionText)
                        .frame(width: 38, height: 36)
                        .background(STRQColors.primaryAccent, in: .capsule)
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        phase = .afterOne
                    }
                } label: {
                    Text("Start next")
                        .font(.system(size: 13, weight: .black))
                        .foregroundStyle(STRQColors.actionText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.74)
                        .padding(.horizontal, 12)
                        .frame(height: 36)
                        .background(ActiveWorkoutLoggerStyle.signal, in: .capsule)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func restButton(_ title: String) -> some View {
        Button {} label: {
            Text(title)
                .font(.system(size: 12, weight: .black).monospacedDigit())
                .foregroundStyle(STRQColors.primaryText)
                .frame(width: 38, height: 36)
                .background(Color.white.opacity(0.07), in: .capsule)
                .overlay(Capsule().strokeBorder(ActiveWorkoutLoggerStyle.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private var logControl: some View {
        HStack(spacing: 9) {
            VStack(alignment: .leading, spacing: 2) {
                Text(scenario.primaryActionEyebrow)
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(STRQColors.mutedText)
                    .textCase(.uppercase)
                Text(scenario.primaryActionDetail)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
            }

            Spacer(minLength: 8)

            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    phase = scenario.nextPhaseFromPrimary
                }
            } label: {
                HStack(spacing: 7) {
                    STRQIconView(scenario.primaryActionIcon, size: 15, tint: STRQColors.actionText)
                    Text(scenario.primaryActionTitle)
                        .font(.system(size: 14, weight: .black))
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                .foregroundStyle(STRQColors.actionText)
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(scenario.isComplete ? STRQColors.successGreen : STRQColors.primaryAccent, in: .rect(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
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
        case .beginner: return 62
        case .athlete: return 70
        }
    }

    var rowVerticalPadding: CGFloat {
        switch self {
        case .beginner: return 12
        case .athlete: return 8
        }
    }

    var inputHeight: CGFloat {
        switch self {
        case .beginner: return 42
        case .athlete: return 36
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

private enum ActiveWorkoutLoggerScrollTarget {
    static let top = "top"

    static func set(_ number: Int) -> String {
        "set-\(number)"
    }
}

private struct ActiveWorkoutLoggerScenario {
    let density: ActiveWorkoutLoggerDensity
    let phase: ActiveWorkoutLoggerPhase
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

    static func make(density: ActiveWorkoutLoggerDensity, phase: ActiveWorkoutLoggerPhase) -> ActiveWorkoutLoggerScenario {
        let sets = ActiveWorkoutLoggerSet.make(phase: phase, density: density)
        let completed = sets.filter(\.completed).count
        let active = sets.first(where: \.isActive)?.number ?? min(completed + 1, sets.count)
        let restActive = phase == .rest
        let complete = phase == .complete

        return ActiveWorkoutLoggerScenario(
            density: density,
            phase: phase,
            sets: sets,
            elapsed: complete ? "41:08" : restActive ? "33:42" : phase == .afterOne ? "32:19" : "31:56",
            exerciseName: "Barbell Bench Press",
            exerciseDetail: density == .beginner ? "Chest - anchor lift" : "Horizontal push - strength block",
            exerciseProgress: "1/6",
            setProgress: complete ? "4/4 sets" : "Set \(active)/4",
            targetLine: density == .beginner ? "Target 6-8" : "80 kg - RPE 8",
            target: density == .beginner ? "6-8 reps" : "80 kg x 6-8",
            restTarget: "120s",
            e1RMHint: complete ? "105" : "101",
            tableSubtitle: "\(completed)/4 logged - active row stays clear",
            stateTitle: stateTitle(phase: phase),
            stateSubtitle: stateSubtitle(phase: phase, density: density),
            stateIcon: stateIcon(phase: phase),
            stateTint: stateTint(phase: phase),
            restRemaining: restActive ? "01:17" : "02:00",
            restActive: restActive,
            showUndo: phase == .afterOne || phase == .rest,
            undoTitle: phase == .rest ? "Set 2 logged - 80 kg x 6" : "Set 1 logged - 80 kg x 8",
            justLogged: phase == .rest ? "Just logged: Set 2 - 80 kg x 6" : "Just logged: Set 1 - 80 kg x 8",
            nextSet: phase == .rest ? "Next: Set 3 - 80 kg x 6" : "Next: Set 2 - 80 kg x 6",
            upNext: complete ? "Incline Bench Press" : "Incline Bench Press waits below",
            primaryActionTitle: complete ? "Finish workout" : phase == .afterOne ? "Log Set 2" : "Log Set \(active)",
            primaryActionDetail: complete ? "All working sets are logged." : density == .beginner ? "Tap the row values to edit before logging." : "Inline kg and reps stay ready for fast edits.",
            primaryActionEyebrow: complete ? "Complete" : "Current set",
            primaryActionIcon: complete ? .checkCircle : .check,
            nextPhaseFromPrimary: complete ? .complete : phase == .beforeLogging ? .afterOne : .rest
        )
    }

    private static func stateTitle(phase: ActiveWorkoutLoggerPhase) -> String {
        switch phase {
        case .beforeLogging: return "Ready to log Set 1"
        case .afterOne: return "Set logged. Next row is active."
        case .rest: return "Rest running. Table stays usable."
        case .complete: return "Exercise complete"
        }
    }

    private static func stateSubtitle(phase: ActiveWorkoutLoggerPhase, density: ActiveWorkoutLoggerDensity) -> String {
        switch phase {
        case .beforeLogging:
            return density == .beginner ? "Previous, kg, reps, done - no hidden cockpit." : "Previous, target delta, kg, reps, check."
        case .afterOne:
            return "Undo is quiet, not a blocking banner."
        case .rest:
            return "Mini-player floats below without covering the active row."
        case .complete:
            return "Finish is promoted only after the work is done."
        }
    }

    private static func stateIcon(phase: ActiveWorkoutLoggerPhase) -> STRQIcon {
        switch phase {
        case .beforeLogging: return .target
        case .afterOne: return .checkCircle
        case .rest: return .clock
        case .complete: return .trophy
        }
    }

    private static func stateTint(phase: ActiveWorkoutLoggerPhase) -> Color {
        switch phase {
        case .beforeLogging: return ActiveWorkoutLoggerStyle.signal
        case .afterOne: return STRQColors.successGreen
        case .rest: return ActiveWorkoutLoggerStyle.steel
        case .complete: return STRQColors.successGreen
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

    static func make(phase: ActiveWorkoutLoggerPhase, density: ActiveWorkoutLoggerDensity) -> [ActiveWorkoutLoggerSet] {
        let completed: Set<Int>
        let active: Int?

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

        let rows: [(Int, String, String, String, String, String?)] = density == .beginner
            ? [
                (1, "1", "77.5x8", "80", phase == .beforeLogging ? "6-8" : "8", nil),
                (2, "2", "80x6", "80", "6", nil),
                (3, "3", "80x6", "80", "6", nil),
                (4, "4", "77.5x8", "77.5", "8", nil)
            ]
            : [
                (1, "1", "77.5x8", "80", phase == .beforeLogging ? "6-8" : "8", "+2.5"),
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
    static let bottomGlass = hex(0x0B0F14).opacity(0.95)
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
