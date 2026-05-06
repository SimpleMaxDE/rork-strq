import SwiftUI

#if DEBUG
struct ProgressV3ConceptLabView: View {
    @State private var concept: ProgressV3Concept = .metricInsight
    @State private var state: ProgressV3DemoState = .baseline

    private var data: ProgressV3DemoData {
        state.data
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                ProgressV3Header()
                ProgressV3ConceptSwitch(selection: $concept)
                ProgressV3StateSwitch(selection: $state)

                switch concept {
                case .metricInsight:
                    ProgressV3MetricInsight(data: data)
                case .rhythm:
                    ProgressV3RhythmSystem(data: data)
                case .distribution:
                    ProgressV3DistributionProof(data: data)
                }
            }
            .frame(maxWidth: 430)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, STRQSpacing.md)
            .padding(.vertical, STRQSpacing.lg)
        }
        .background(ProgressV3Style.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

private struct ProgressV3Header: View {
    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.xs) {
            HStack(alignment: .firstTextBaseline) {
                Text("Progress V3 Concept Lab")
                    .font(STRQTypography.headingSmall)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)

                Spacer()

                Text("DEBUG")
                    .font(STRQTypography.micro)
                    .foregroundStyle(ProgressV3Style.signal)
                    .padding(.horizontal, STRQSpacing.xs)
                    .padding(.vertical, 5)
                    .background(ProgressV3Style.signal.opacity(0.12), in: Capsule())
                    .overlay(Capsule().strokeBorder(ProgressV3Style.signal.opacity(0.35), lineWidth: 1))
            }

            Text("Prototype only. Local demo data, no production Progress wiring.")
                .font(STRQTypography.caption)
                .foregroundStyle(STRQColors.mutedText)
                .lineLimit(2)
        }
    }
}

private struct ProgressV3ConceptSwitch: View {
    @Binding var selection: ProgressV3Concept

    var body: some View {
        HStack(spacing: 5) {
            ForEach(ProgressV3Concept.allCases) { item in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selection = item
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(item.shortTitle)
                            .font(STRQTypography.labelSmall)
                            .foregroundStyle(selection == item ? STRQColors.primaryText : STRQColors.secondaryText)
                            .lineLimit(1)
                        Text(item.sourceLabel)
                            .font(STRQTypography.micro)
                            .foregroundStyle(selection == item ? ProgressV3Style.signal : STRQColors.mutedText)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                    .padding(.horizontal, STRQSpacing.xs)
                    .background(selection == item ? ProgressV3Style.selected : Color.clear, in: .rect(cornerRadius: STRQRadii.md))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text(item.title))
            }
        }
        .padding(5)
        .background(ProgressV3Style.control, in: .rect(cornerRadius: STRQRadii.lg))
        .overlay(RoundedRectangle(cornerRadius: STRQRadii.lg).strokeBorder(ProgressV3Style.border, lineWidth: 1))
    }
}

private struct ProgressV3StateSwitch: View {
    @Binding var selection: ProgressV3DemoState

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ProgressV3DemoState.allCases) { item in
                Button {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selection = item
                    }
                } label: {
                    VStack(spacing: 2) {
                        Text(item.title)
                            .font(STRQTypography.labelSmall)
                            .foregroundStyle(selection == item ? STRQColors.primaryText : STRQColors.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)

                        Text(item.workoutLabel)
                            .font(STRQTypography.micro)
                            .foregroundStyle(selection == item ? item.tint : STRQColors.mutedText)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, minHeight: 46)
                    .background(selection == item ? item.tint.opacity(0.1) : Color.clear, in: .rect(cornerRadius: STRQRadii.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: STRQRadii.md)
                            .strokeBorder(selection == item ? item.tint.opacity(0.32) : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(ProgressV3Style.controlDeep, in: .rect(cornerRadius: STRQRadii.lg))
        .overlay(RoundedRectangle(cornerRadius: STRQRadii.lg).strokeBorder(ProgressV3Style.border, lineWidth: 1))
    }
}

// MARK: - Concept A

private struct ProgressV3MetricInsight: View {
    let data: ProgressV3DemoData

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            ProgressV3ConceptTitle(
                eyebrow: "Concept A",
                title: "Metric Insight Report",
                detail: "Chart-first proof surface using prototype training signals.",
                tint: data.tint
            )

            ProgressV3ChartHero(data: data)
            ProgressV3Rail(metrics: data.rail, tint: data.tint)

            HStack(alignment: .top, spacing: STRQSpacing.sm) {
                ProgressV3TrendPanel(data: data)
                VStack(spacing: STRQSpacing.xs) {
                    ForEach(data.metrics.prefix(3)) { metric in
                        ProgressV3MiniMetric(metric: metric)
                    }
                }
                .frame(width: 126)
            }

            ProgressV3EvidenceList(title: "Recent Proof", items: data.proof, tint: data.tint)
        }
    }
}

private struct ProgressV3ChartHero: View {
    let data: ProgressV3DemoData

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            ProgressV3LineChart(values: data.trend, tint: data.tint, isEmpty: data.state == .baseline)
                .padding(.horizontal, STRQSpacing.sm)
                .padding(.top, 62)
                .padding(.bottom, STRQSpacing.sm)

            VStack(alignment: .leading, spacing: STRQSpacing.xs) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(data.metricLabel.uppercased())
                            .font(STRQTypography.micro)
                            .foregroundStyle(ProgressV3Style.steel)
                            .lineLimit(1)

                        HStack(alignment: .lastTextBaseline, spacing: 5) {
                            Text(data.metricValue)
                                .font(.system(size: 54, weight: .heavy, design: .rounded).monospacedDigit())
                                .foregroundStyle(STRQColors.primaryText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.55)

                            Text(data.metricUnit)
                                .font(STRQTypography.textLarge)
                                .foregroundStyle(STRQColors.secondaryText)
                                .padding(.bottom, 9)
                                .lineLimit(1)
                        }
                    }

                    Spacer()
                    ProgressV3Status(text: data.status, tint: data.tint)
                }

                Text(data.metricCaption)
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(2)
                    .frame(maxWidth: 270, alignment: .leading)
            }
            .padding(STRQSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [ProgressV3Style.heroBottom.opacity(0.98), ProgressV3Style.heroBottom.opacity(0.25)],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
        .frame(height: 332)
        .background {
            ZStack {
                LinearGradient(colors: [ProgressV3Style.heroTop, ProgressV3Style.heroBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
                ProgressV3FineGrid().opacity(0.48)
            }
        }
        .clipShape(.rect(cornerRadius: 34))
        .overlay(RoundedRectangle(cornerRadius: 34).strokeBorder(ProgressV3Style.borderStrong, lineWidth: 1))
        .overlay(alignment: .topLeading) {
            Rectangle()
                .fill(data.tint)
                .frame(width: 112, height: 3)
                .padding(.leading, STRQSpacing.lg)
        }
    }
}

private struct ProgressV3TrendPanel: View {
    let data: ProgressV3DemoData

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            HStack(spacing: STRQSpacing.xs) {
                ProgressV3Dot(color: data.tint)
                Text("Trend Detail")
                    .font(STRQTypography.labelSmall)
                    .foregroundStyle(STRQColors.secondaryText)
            }

            Spacer(minLength: 0)

            HStack(alignment: .lastTextBaseline, spacing: 5) {
                Text(data.trendValue)
                    .font(STRQTypography.metricMedium)
                    .foregroundStyle(STRQColors.primaryText)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(data.trendUnit)
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQColors.secondaryText)
                    .padding(.bottom, 5)
            }

            ProgressV3Bars(values: data.bars, tint: data.tint)
                .frame(height: 48)

            Text(data.trendCaption)
                .font(STRQTypography.caption)
                .foregroundStyle(STRQColors.mutedText)
                .lineLimit(3)
        }
        .frame(maxWidth: .infinity, minHeight: 214, alignment: .leading)
        .padding(STRQSpacing.md)
        .background {
            ZStack(alignment: .topTrailing) {
                ProgressV3Style.surfaceSecondary
                Rectangle()
                    .fill(data.tint.opacity(0.18))
                    .frame(width: 82)
                    .rotationEffect(.degrees(18))
                    .offset(x: 28, y: -26)
            }
            .clipShape(.rect(cornerRadius: 24))
        }
        .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(data.tint.opacity(0.18), lineWidth: 1))
    }
}

// MARK: - Concept B

private struct ProgressV3RhythmSystem: View {
    let data: ProgressV3DemoData

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            ProgressV3ConceptTitle(
                eyebrow: "Concept B",
                title: "Progress Goal / Rhythm System",
                detail: "Goal progress, weekly cadence, and session proof as one system.",
                tint: data.tint
            )

            ProgressV3GoalRhythmHero(data: data)
            ProgressV3WeeklyProof(weeks: data.weeks, tint: data.tint)
            ProgressV3SessionList(items: data.sessions, tint: data.tint)
        }
    }
}

private struct ProgressV3GoalRhythmHero: View {
    let data: ProgressV3DemoData

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.md) {
            HStack(alignment: .top, spacing: STRQSpacing.md) {
                ProgressV3GoalRing(goal: data.goal, tint: data.tint)

                VStack(alignment: .leading, spacing: STRQSpacing.sm) {
                    Text(data.goal.title)
                        .font(STRQTypography.cardTitle)
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(2)

                    Text(data.goal.detail)
                        .font(STRQTypography.caption)
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(3)

                    ProgressV3GoalScale(goal: data.goal, tint: data.tint)
                        .frame(height: 46)
                }
            }

            ProgressV3Calendar(days: data.days, tint: data.tint)
        }
        .padding(STRQSpacing.md)
        .background {
            ZStack {
                LinearGradient(colors: [ProgressV3Style.goalTop, ProgressV3Style.surfaceDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
                ProgressV3FineGrid().opacity(0.28)
            }
            .clipShape(.rect(cornerRadius: 32))
        }
        .overlay(RoundedRectangle(cornerRadius: 32).strokeBorder(ProgressV3Style.borderStrong, lineWidth: 1))
    }
}

private struct ProgressV3GoalRing: View {
    let goal: ProgressV3Goal
    let tint: Color

    var body: some View {
        ZStack {
            Circle().stroke(ProgressV3Style.track, lineWidth: 11)
            Circle()
                .trim(from: 0, to: goal.clampedProgress)
                .stroke(tint, style: StrokeStyle(lineWidth: 11, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 3) {
                Text(goal.value)
                    .font(STRQTypography.metricSmall)
                    .foregroundStyle(STRQColors.primaryText)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.68)
                Text(goal.unit)
                    .font(STRQTypography.micro)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(1)
            }
        }
        .frame(width: 118, height: 118)
        .padding(STRQSpacing.xs)
        .background(ProgressV3Style.surface.opacity(0.65), in: Circle())
    }
}

private struct ProgressV3GoalScale: View {
    let goal: ProgressV3Goal
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let marker = width * CGFloat(goal.clampedProgress)

            ZStack(alignment: .leading) {
                Capsule().fill(ProgressV3Style.track).frame(height: 8)
                Capsule()
                    .fill(tint.opacity(goal.progress > 0 ? 0.85 : 0.16))
                    .frame(width: max(8, marker), height: 8)
                Rectangle()
                    .fill(STRQColors.white.opacity(0.28))
                    .frame(width: 1, height: 26)
                    .offset(x: width * 0.74)
                VStack(spacing: 2) {
                    Circle().fill(goal.progress > 0 ? tint : ProgressV3Style.steel).frame(width: 12, height: 12)
                    Text(goal.markerLabel)
                        .font(STRQTypography.micro)
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(1)
                }
                .offset(x: min(max(marker - 24, 0), width - 48), y: 14)
            }
        }
    }
}

private struct ProgressV3Calendar: View {
    let days: [ProgressV3Day]
    let tint: Color

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)
    private let labels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.xs) {
            HStack {
                Text("Weekly Rhythm")
                    .font(STRQTypography.labelSmall)
                    .foregroundStyle(STRQColors.secondaryText)
                Spacer()
                Text("prototype calendar")
                    .font(STRQTypography.micro)
                    .foregroundStyle(STRQColors.mutedText)
            }

            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(Array(labels.enumerated()), id: \.offset) { _, label in
                    Text(label)
                        .font(STRQTypography.micro)
                        .foregroundStyle(STRQColors.mutedText)
                        .frame(height: 16)
                }

                ForEach(days) { day in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(day.fill(tint: tint))
                        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(day.stroke(tint: tint), lineWidth: 1))
                        .frame(height: 30)
                        .overlay {
                            if day.status == .done {
                                Circle().fill(tint).frame(width: 5, height: 5)
                            }
                        }
                        .accessibilityLabel(Text("Prototype day \(day.index) \(day.status.label)"))
                }
            }
        }
        .padding(STRQSpacing.sm)
        .background(ProgressV3Style.plot, in: .rect(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(ProgressV3Style.border, lineWidth: 1))
    }
}

private struct ProgressV3WeeklyProof: View {
    let weeks: [ProgressV3Week]
    let tint: Color

    var body: some View {
        ProgressV3Module(title: "Weekly Proof", trailing: "sessions", tint: tint) {
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(weeks) { week in
                    VStack(spacing: 5) {
                        GeometryReader { proxy in
                            ZStack(alignment: .bottom) {
                                RoundedRectangle(cornerRadius: 7).fill(ProgressV3Style.track)
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(week.sessions > 0 ? tint.opacity(week.current ? 0.95 : 0.48) : ProgressV3Style.steel.opacity(0.12))
                                    .frame(height: max(6, proxy.size.height * CGFloat(week.ratio)))
                            }
                        }
                        .frame(height: 92)
                        Text(week.label)
                            .font(STRQTypography.micro)
                            .foregroundStyle(week.current ? tint : STRQColors.mutedText)
                        Text("\(week.sessions)")
                            .font(STRQTypography.micro)
                            .foregroundStyle(STRQColors.secondaryText)
                            .monospacedDigit()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

private struct ProgressV3SessionList: View {
    let items: [ProgressV3Session]
    let tint: Color

    var body: some View {
        ProgressV3Module(title: "Recent Sessions", trailing: "demo", tint: tint) {
            VStack(spacing: STRQSpacing.xs) {
                ForEach(items) { item in
                    HStack(spacing: STRQSpacing.sm) {
                        Text(item.day)
                            .font(STRQTypography.labelSmall)
                            .foregroundStyle(item.done ? tint : STRQColors.mutedText)
                            .frame(width: 42, height: 42)
                            .background(item.done ? tint.opacity(0.12) : ProgressV3Style.control, in: .rect(cornerRadius: STRQRadii.md))
                            .overlay(RoundedRectangle(cornerRadius: STRQRadii.md).strokeBorder(item.done ? tint.opacity(0.28) : ProgressV3Style.border, lineWidth: 1))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(STRQTypography.bodySmallMedium)
                                .foregroundStyle(STRQColors.primaryText)
                                .lineLimit(1)
                            Text(item.detail)
                                .font(STRQTypography.caption)
                                .foregroundStyle(STRQColors.secondaryText)
                                .lineLimit(2)
                        }

                        Spacer()

                        Text(item.badge)
                            .font(STRQTypography.micro)
                            .foregroundStyle(item.done ? tint : STRQColors.mutedText)
                    }
                    .padding(STRQSpacing.xs)
                    .background(ProgressV3Style.surfaceSecondary, in: .rect(cornerRadius: STRQRadii.lg))
                }
            }
        }
    }
}

// MARK: - Concept C

private struct ProgressV3DistributionProof: View {
    let data: ProgressV3DemoData

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            ProgressV3ConceptTitle(
                eyebrow: "Concept C",
                title: "Training Distribution / Muscle Proof",
                detail: "Coverage, training mix, and muscle focus as progress evidence.",
                tint: data.tint
            )

            ProgressV3CoverageHero(data: data)
            ProgressV3TrainingMix(data: data)
            ProgressV3MuscleEvidence(items: data.muscleEvidence, tint: data.tint)
        }
    }
}

private struct ProgressV3CoverageHero: View {
    let data: ProgressV3DemoData

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.md) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Coverage Map")
                        .font(STRQTypography.cardTitle)
                        .foregroundStyle(STRQColors.primaryText)
                    Text(data.coverageCaption)
                        .font(STRQTypography.caption)
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(2)
                }
                Spacer()
                ProgressV3Status(text: data.coverageStatus, tint: data.tint)
            }

            HStack(alignment: .center, spacing: STRQSpacing.sm) {
                ProgressV3BodyFigure(title: "front", base: "STRQHumanBodyMaleFrontBase", layers: data.frontLayers, tint: data.tint)
                VStack(spacing: STRQSpacing.xs) {
                    ForEach(data.muscles.prefix(4)) { muscle in
                        ProgressV3MuscleScore(muscle: muscle, tint: data.tint)
                    }
                }
                .frame(width: 122)
                ProgressV3BodyFigure(title: "back", base: "STRQHumanBodyMaleBackBase", layers: data.backLayers, tint: data.tint)
            }
        }
        .padding(STRQSpacing.md)
        .background {
            ZStack {
                LinearGradient(colors: [ProgressV3Style.bodyTop, ProgressV3Style.surfaceDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
                ProgressV3FineGrid().opacity(0.3)
            }
            .clipShape(.rect(cornerRadius: 32))
        }
        .overlay(RoundedRectangle(cornerRadius: 32).strokeBorder(ProgressV3Style.borderStrong, lineWidth: 1))
    }
}

private struct ProgressV3BodyFigure: View {
    let title: String
    let base: String
    let layers: [ProgressV3BodyLayer]
    let tint: Color

    var body: some View {
        VStack(spacing: STRQSpacing.xs) {
            ZStack {
                Image(base)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .opacity(layers.isEmpty ? 0.44 : 0.54)

                ForEach(layers) { layer in
                    Image(layer.asset)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(layer.color.opacity(layer.opacity))
                }

                if !layers.isEmpty {
                    Image(base)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .blendMode(.darken)
                        .opacity(0.36)
                }
            }
            .frame(height: 230)
            .frame(maxWidth: .infinity)
            .padding(STRQSpacing.xs)
            .background(ProgressV3Style.plot.opacity(0.76), in: .rect(cornerRadius: 22))
            .overlay(RoundedRectangle(cornerRadius: 22).strokeBorder(layers.isEmpty ? ProgressV3Style.border : tint.opacity(0.24), lineWidth: 1))

            Text(title.uppercased())
                .font(STRQTypography.micro)
                .foregroundStyle(STRQColors.mutedText)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(title) prototype muscle coverage"))
    }
}

private struct ProgressV3MuscleScore: View {
    let muscle: ProgressV3Muscle
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(muscle.name)
                    .font(STRQTypography.micro)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(1)
                Spacer()
                Text(muscle.label)
                    .font(STRQTypography.micro)
                    .foregroundStyle(muscle.value > 0 ? tint : STRQColors.mutedText)
                    .monospacedDigit()
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(ProgressV3Style.track)
                    Capsule()
                        .fill(muscle.value > 0 ? tint.opacity(0.82) : ProgressV3Style.steel.opacity(0.12))
                        .frame(width: max(4, proxy.size.width * CGFloat(muscle.value)))
                }
            }
            .frame(height: 7)
        }
        .padding(STRQSpacing.xs)
        .background(ProgressV3Style.surface.opacity(0.7), in: .rect(cornerRadius: STRQRadii.md))
    }
}

private struct ProgressV3TrainingMix: View {
    let data: ProgressV3DemoData

    var body: some View {
        ProgressV3Module(title: "Training Mix", trailing: data.mixStatus, tint: data.tint) {
            VStack(spacing: STRQSpacing.sm) {
                ProgressV3MixBar(segments: data.mix, tint: data.tint)
                    .frame(height: 34)
                ProgressV3MuscleBars(muscles: data.muscles, tint: data.tint)
                    .frame(height: 126)
            }
        }
    }
}

private struct ProgressV3MixBar: View {
    let segments: [ProgressV3MixSegment]
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width - CGFloat(max(segments.count - 1, 0) * 4), 1)

            HStack(spacing: 4) {
                ForEach(segments) { segment in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(segment.color(tint: tint).opacity(segment.value > 0 ? 0.9 : 0.18))
                        .frame(width: max(12, width * CGFloat(segment.value)))
                        .overlay {
                            Text(segment.label)
                                .font(STRQTypography.micro)
                                .foregroundStyle(segment.value > 0.16 ? ProgressV3Style.background : STRQColors.mutedText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.62)
                        }
                }
            }
        }
        .padding(4)
        .background(ProgressV3Style.plot, in: .rect(cornerRadius: STRQRadii.md))
        .overlay(RoundedRectangle(cornerRadius: STRQRadii.md).strokeBorder(ProgressV3Style.border, lineWidth: 1))
    }
}

private struct ProgressV3MuscleBars: View {
    let muscles: [ProgressV3Muscle]
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            let height = max(proxy.size.height - 30, 1)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(muscles) { muscle in
                    VStack(spacing: 5) {
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 8).fill(ProgressV3Style.track).frame(height: height)
                            RoundedRectangle(cornerRadius: 8)
                                .fill(muscle.value > 0 ? tint.opacity(muscle.primary ? 0.96 : 0.56) : ProgressV3Style.steel.opacity(0.14))
                                .frame(height: max(5, height * CGFloat(muscle.value)))
                        }
                        Text(muscle.short)
                            .font(STRQTypography.micro)
                            .foregroundStyle(muscle.primary ? tint : STRQColors.mutedText)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

private struct ProgressV3MuscleEvidence: View {
    let items: [ProgressV3MuscleEvidenceItem]
    let tint: Color

    var body: some View {
        ProgressV3Module(title: "Recent Muscle Focus", trailing: "prototype", tint: tint) {
            VStack(spacing: STRQSpacing.xs) {
                ForEach(items) { item in
                    HStack(spacing: STRQSpacing.sm) {
                        ZStack {
                            Circle().stroke(ProgressV3Style.track, lineWidth: 5)
                            Circle()
                                .trim(from: 0, to: item.clamped)
                                .stroke(item.coverage > 0 ? tint : ProgressV3Style.steel.opacity(0.2), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                            Text(item.short)
                                .font(STRQTypography.micro)
                                .foregroundStyle(item.coverage > 0 ? tint : STRQColors.mutedText)
                        }
                        .frame(width: 44, height: 44)

                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.title)
                                .font(STRQTypography.bodySmallMedium)
                                .foregroundStyle(STRQColors.primaryText)
                                .lineLimit(1)
                            Text(item.detail)
                                .font(STRQTypography.caption)
                                .foregroundStyle(STRQColors.secondaryText)
                                .lineLimit(2)
                        }

                        Spacer()

                        Text(item.value)
                            .font(STRQTypography.micro)
                            .foregroundStyle(item.coverage > 0 ? tint : STRQColors.mutedText)
                            .monospacedDigit()
                    }
                    .padding(STRQSpacing.xs)
                    .background(ProgressV3Style.surfaceSecondary, in: .rect(cornerRadius: STRQRadii.lg))
                }
            }
        }
    }
}

// MARK: - Shared Views

private struct ProgressV3ConceptTitle: View {
    let eyebrow: String
    let title: String
    let detail: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: STRQSpacing.xs) {
                Text(eyebrow.uppercased())
                    .font(STRQTypography.micro)
                    .foregroundStyle(tint)
                Rectangle()
                    .fill(ProgressV3Style.borderStrong)
                    .frame(width: 28, height: 1)
            }

            Text(title)
                .font(STRQTypography.headingXS)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(2)
                .minimumScaleFactor(0.72)

            Text(detail)
                .font(STRQTypography.caption)
                .foregroundStyle(STRQColors.secondaryText)
                .lineLimit(2)
        }
    }
}

private struct ProgressV3Module<Content: View>: View {
    let title: String
    let trailing: String
    let tint: Color
    let content: Content

    init(title: String, trailing: String, tint: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.trailing = trailing
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(STRQTypography.cardTitle)
                    .foregroundStyle(STRQColors.primaryText)
                Spacer()
                Text(trailing)
                    .font(STRQTypography.micro)
                    .foregroundStyle(tint)
                    .lineLimit(1)
            }
            content
        }
        .padding(STRQSpacing.md)
        .background(ProgressV3Style.surface, in: .rect(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).strokeBorder(ProgressV3Style.border, lineWidth: 1))
    }
}

private struct ProgressV3Status: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text.uppercased())
            .font(STRQTypography.micro)
            .foregroundStyle(tint)
            .lineLimit(1)
            .minimumScaleFactor(0.68)
            .padding(.horizontal, STRQSpacing.xs)
            .padding(.vertical, 5)
            .background(tint.opacity(0.12), in: Capsule())
            .overlay(Capsule().strokeBorder(tint.opacity(0.32), lineWidth: 1))
    }
}

private struct ProgressV3Rail: View {
    let metrics: [ProgressV3Metric]
    let tint: Color

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(metrics.enumerated()), id: \.element.id) { index, metric in
                VStack(alignment: .leading, spacing: 3) {
                    Text(metric.value)
                        .font(STRQTypography.labelLarge)
                        .foregroundStyle(metric.tone.color)
                        .monospacedDigit()
                        .lineLimit(1)
                    Text(metric.title)
                        .font(STRQTypography.micro)
                        .foregroundStyle(STRQColors.mutedText)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, STRQSpacing.sm)
                .padding(.vertical, STRQSpacing.sm)

                if index < metrics.count - 1 {
                    Rectangle().fill(ProgressV3Style.border).frame(width: 1, height: 36)
                }
            }
        }
        .background(ProgressV3Style.surface, in: .rect(cornerRadius: 18))
        .overlay(RoundedRectangle(cornerRadius: 18).strokeBorder(ProgressV3Style.border, lineWidth: 1))
    }
}

private struct ProgressV3MiniMetric: View {
    let metric: ProgressV3Metric

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: STRQSpacing.xs) {
                ProgressV3Dot(color: metric.tone.color)
                Text(metric.title)
                    .font(STRQTypography.micro)
                    .foregroundStyle(STRQColors.mutedText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.66)
            }

            Text(metric.value)
                .font(STRQTypography.labelLarge)
                .foregroundStyle(STRQColors.primaryText)
                .monospacedDigit()
                .lineLimit(1)

            Text(metric.detail)
                .font(STRQTypography.micro)
                .foregroundStyle(STRQColors.secondaryText)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, minHeight: 66, alignment: .topLeading)
        .padding(STRQSpacing.xs)
        .background(ProgressV3Style.surface, in: .rect(cornerRadius: STRQRadii.md))
        .overlay(RoundedRectangle(cornerRadius: STRQRadii.md).strokeBorder(ProgressV3Style.border, lineWidth: 1))
    }
}

private struct ProgressV3EvidenceList: View {
    let title: String
    let items: [ProgressV3Proof]
    let tint: Color

    var body: some View {
        ProgressV3Module(title: title, trailing: "demo", tint: tint) {
            VStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    HStack(alignment: .top, spacing: STRQSpacing.sm) {
                        VStack(spacing: 0) {
                            Circle()
                                .fill(item.tone.markerColor(tint: tint))
                                .frame(width: 10, height: 10)
                                .overlay(Circle().strokeBorder(STRQColors.white.opacity(0.24), lineWidth: 1))
                            Rectangle()
                                .fill(index == items.count - 1 ? Color.clear : ProgressV3Style.border)
                                .frame(width: 1)
                        }
                        .frame(width: 14)

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(item.title)
                                    .font(STRQTypography.bodySmallMedium)
                                    .foregroundStyle(STRQColors.primaryText)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                                Spacer()
                                Text(item.date)
                                    .font(STRQTypography.micro)
                                    .foregroundStyle(STRQColors.mutedText)
                            }
                            Text(item.detail)
                                .font(STRQTypography.caption)
                                .foregroundStyle(STRQColors.secondaryText)
                                .lineLimit(2)
                        }
                        .padding(.bottom, index == items.count - 1 ? 0 : STRQSpacing.sm)
                    }
                }
            }
        }
    }
}

private struct ProgressV3LineChart: View {
    let values: [Double]
    let tint: Color
    let isEmpty: Bool

    var body: some View {
        GeometryReader { proxy in
            let points = normalizedPoints(size: proxy.size)

            ZStack {
                ProgressV3Grid(rows: 5)

                if isEmpty || points.count < 2 {
                    ProgressV3ChartSkeleton(tint: tint)
                } else {
                    area(points: points, height: proxy.size.height)
                        .fill(LinearGradient(colors: [tint.opacity(0.24), tint.opacity(0.02)], startPoint: .top, endPoint: .bottom))

                    line(points: points)
                        .stroke(tint, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                    ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                        Circle()
                            .fill(index == points.count - 1 ? tint : ProgressV3Style.heroBottom)
                            .frame(width: index == points.count - 1 ? 11 : 8, height: index == points.count - 1 ? 11 : 8)
                            .overlay(Circle().strokeBorder(tint.opacity(0.8), lineWidth: 2))
                            .position(point)
                    }
                }
            }
        }
    }

    private func normalizedPoints(size: CGSize) -> [CGPoint] {
        guard values.count > 1 else { return [] }
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 1
        let span = max(maxValue - minValue, 0.01)
        let step = max(size.width, 1) / CGFloat(values.count - 1)

        return values.enumerated().map { index, value in
            CGPoint(
                x: CGFloat(index) * step,
                y: (1 - CGFloat((value - minValue) / span)) * (max(size.height, 1) - 28) + 14
            )
        }
    }

    private func line(points: [CGPoint]) -> Path {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: first)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
        }
    }

    private func area(points: [CGPoint], height: CGFloat) -> Path {
        Path { path in
            guard let first = points.first, let last = points.last else { return }
            path.move(to: CGPoint(x: first.x, y: height))
            path.addLine(to: first)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            path.addLine(to: CGPoint(x: last.x, y: height))
            path.closeSubpath()
        }
    }
}

private struct ProgressV3ChartSkeleton: View {
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)

            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height * 0.64))
                    path.addLine(to: CGPoint(x: width, y: height * 0.64))
                }
                .stroke(tint.opacity(0.34), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [7, 8]))

                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .strokeBorder(tint.opacity(index < 3 ? 0.42 : 0.16), lineWidth: 2)
                        .frame(width: 15, height: 15)
                        .position(
                            x: width * CGFloat(index) / 7,
                            y: height * (0.35 + CGFloat(index % 3) * 0.11)
                        )
                }
            }
        }
    }
}

private struct ProgressV3Bars: View {
    let values: [Double]
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            HStack(alignment: .bottom, spacing: 5) {
                ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(value > 0 ? tint.opacity(index == values.count - 1 ? 0.95 : 0.36 + Double(index % 3) * 0.1) : ProgressV3Style.steel.opacity(0.14))
                        .frame(height: max(5, proxy.size.height * CGFloat(min(max(value, 0), 1))))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}

private struct ProgressV3Grid: View {
    let rows: Int

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0...rows, id: \.self) { _ in
                Rectangle().fill(ProgressV3Style.grid).frame(height: 1)
                Spacer(minLength: 0)
            }
        }
    }
}

private struct ProgressV3FineGrid: View {
    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)

            Path { path in
                for index in 0...6 {
                    let y = height * CGFloat(index) / 6
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
                for index in 0...4 {
                    let x = width * CGFloat(index) / 4
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }
            }
            .stroke(ProgressV3Style.grid, lineWidth: 1)
        }
    }
}

private struct ProgressV3Dot: View {
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 7, height: 7)
            .overlay(Circle().strokeBorder(STRQColors.white.opacity(0.24), lineWidth: 1))
    }
}

// MARK: - Data

private enum ProgressV3Concept: String, CaseIterable, Identifiable {
    case metricInsight
    case rhythm
    case distribution

    var id: String { rawValue }

    var title: String {
        switch self {
        case .metricInsight:
            return "Metric Insight Report"
        case .rhythm:
            return "Progress Goal / Rhythm System"
        case .distribution:
            return "Training Distribution / Muscle Proof"
        }
    }

    var shortTitle: String {
        switch self {
        case .metricInsight:
            return "Insight"
        case .rhythm:
            return "Rhythm"
        case .distribution:
            return "Coverage"
        }
    }

    var sourceLabel: String {
        switch self {
        case .metricInsight:
            return "chart report"
        case .rhythm:
            return "goal grid"
        case .distribution:
            return "muscle proof"
        }
    }
}

private enum ProgressV3DemoState: String, CaseIterable, Identifiable {
    case baseline
    case forming
    case established

    var id: String { rawValue }

    var title: String {
        switch self {
        case .baseline:
            return "Baseline"
        case .forming:
            return "Forming"
        case .established:
            return "Established"
        }
    }

    var workoutLabel: String {
        switch self {
        case .baseline:
            return "0 workouts"
        case .forming:
            return "3 workouts"
        case .established:
            return "27 workouts"
        }
    }

    var tint: Color {
        switch self {
        case .baseline:
            return ProgressV3Style.steel
        case .forming:
            return ProgressV3Style.amber
        case .established:
            return ProgressV3Style.signal
        }
    }

    var data: ProgressV3DemoData {
        switch self {
        case .baseline:
            return .baseline
        case .forming:
            return .forming
        case .established:
            return .established
        }
    }
}

private struct ProgressV3DemoData {
    let state: ProgressV3DemoState
    let metricLabel: String
    let metricValue: String
    let metricUnit: String
    let metricCaption: String
    let trend: [Double]
    let status: String
    let trendValue: String
    let trendUnit: String
    let trendCaption: String
    let bars: [Double]
    let rail: [ProgressV3Metric]
    let metrics: [ProgressV3Metric]
    let proof: [ProgressV3Proof]
    let goal: ProgressV3Goal
    let days: [ProgressV3Day]
    let weeks: [ProgressV3Week]
    let sessions: [ProgressV3Session]
    let coverageStatus: String
    let coverageCaption: String
    let frontLayers: [ProgressV3BodyLayer]
    let backLayers: [ProgressV3BodyLayer]
    let muscles: [ProgressV3Muscle]
    let mix: [ProgressV3MixSegment]
    let mixStatus: String
    let muscleEvidence: [ProgressV3MuscleEvidenceItem]

    var tint: Color { state.tint }

    // Prototype-only demo data. It intentionally stays local to this DEBUG file.
    static let baseline = ProgressV3DemoData(
        state: .baseline,
        metricLabel: "Strength proof",
        metricValue: "--",
        metricUnit: "trend",
        metricCaption: "No conclusion is shown until workouts create a real baseline.",
        trend: [],
        status: "Baseline forming",
        trendValue: "0/3",
        trendUnit: "anchors",
        trendCaption: "The chart shell is visible, but the report does not invent progress.",
        bars: [0.08, 0.06, 0.1, 0.05, 0.09],
        rail: [
            .init(title: "sessions", value: "0", detail: "no workouts", tone: .neutral),
            .init(title: "trend", value: "--", detail: "locked", tone: .neutral),
            .init(title: "proof", value: "open", detail: "forming", tone: .neutral)
        ],
        metrics: [
            .init(title: "Workouts", value: "0", detail: "none yet", tone: .neutral),
            .init(title: "Anchors", value: "0/3", detail: "needed", tone: .neutral),
            .init(title: "Rhythm", value: "open", detail: "no pattern", tone: .neutral)
        ],
        proof: [
            .init(title: "No completed sessions", date: "Now", detail: "Baseline state stays empty instead of pretending to know a trend.", tone: .neutral),
            .init(title: "Report locked", date: "0/3", detail: "Recommendations wait for training evidence.", tone: .neutral)
        ],
        goal: .init(title: "Build the first training baseline", detail: "The goal is not progress yet. It is enough completed sessions to make Progress useful.", value: "0/4", unit: "sessions", progress: 0, markerLabel: "start"),
        days: ProgressV3Factory.days(completed: [], forming: [6, 13, 20]),
        weeks: ProgressV3Factory.weeks([0, 0, 0, 0, 0, 0], current: 5),
        sessions: [
            .init(day: "--", title: "No session evidence", detail: "Complete a workout to start the proof trail.", badge: "open", done: false),
            .init(day: "01", title: "First anchor pending", detail: "Strength, rhythm, and coverage stay inactive.", badge: "locked", done: false)
        ],
        coverageStatus: "forming",
        coverageCaption: "No muscle coverage is claimed before workouts exist.",
        frontLayers: [],
        backLayers: [],
        muscles: ProgressV3Factory.muscles([0, 0, 0, 0, 0, 0]),
        mix: ProgressV3Factory.mix(push: 0, pull: 0, legs: 0, core: 0),
        mixStatus: "not enough data",
        muscleEvidence: [
            .init(short: "--", title: "Coverage unavailable", detail: "Training distribution starts empty.", value: "--", coverage: 0),
            .init(short: "0", title: "No muscle focus yet", detail: "No focus evidence is displayed.", value: "0 sets", coverage: 0)
        ]
    )

    static let forming = ProgressV3DemoData(
        state: .forming,
        metricLabel: "Early strength signal",
        metricValue: "+2",
        metricUnit: "anchors",
        metricCaption: "Three workouts show early movement, but the report stays cautious.",
        trend: [42, 48, 46, 53, 57],
        status: "Early signal",
        trendValue: "+4",
        trendUnit: "% volume",
        trendCaption: "A small signal is visible. The status remains forming until the window fills.",
        bars: [0.12, 0.24, 0.18, 0.38, 0.44],
        rail: [
            .init(title: "sessions", value: "3", detail: "logged", tone: .forming),
            .init(title: "trend", value: "+2", detail: "anchors", tone: .forming),
            .init(title: "proof", value: "42%", detail: "forming", tone: .forming)
        ],
        metrics: [
            .init(title: "Workouts", value: "3", detail: "first week", tone: .forming),
            .init(title: "Anchors", value: "2/3", detail: "partial", tone: .forming),
            .init(title: "Coverage", value: "4", detail: "zones", tone: .forming)
        ],
        proof: [
            .init(title: "Upper Strength", date: "Mon", detail: "Bench and row created the first upper-body anchor.", tone: .forming),
            .init(title: "Lower Strength", date: "Thu", detail: "Squat work added a lower-body signal.", tone: .forming),
            .init(title: "Full Body", date: "Sat", detail: "Third session made weekly rhythm visible.", tone: .forming)
        ],
        goal: .init(title: "Reach a readable four-session baseline", detail: "The pattern has started. STRQ would still label conclusions as early.", value: "3/4", unit: "sessions", progress: 0.38, markerLabel: "early"),
        days: ProgressV3Factory.days(completed: [3, 7, 12], forming: [18, 23, 28]),
        weeks: ProgressV3Factory.weeks([0, 1, 0, 2, 0, 3], current: 5),
        sessions: [
            .init(day: "M", title: "Upper Strength", detail: "Push and pull anchors logged.", badge: "done", done: true),
            .init(day: "T", title: "Lower Strength", detail: "Leg volume entered the baseline.", badge: "done", done: true),
            .init(day: "S", title: "Full Body", detail: "Third workout revealed cadence.", badge: "signal", done: true)
        ],
        coverageStatus: "early map",
        coverageCaption: "Coverage starts to show push, legs, and back without claiming balance.",
        frontLayers: [
            .init(asset: "STRQHumanBodyMaleFrontChestOverlay", color: ProgressV3Style.amber, opacity: 0.62),
            .init(asset: "STRQHumanBodyMaleFrontUpperLegOverlay", color: ProgressV3Style.signal, opacity: 0.42)
        ],
        backLayers: [
            .init(asset: "STRQHumanBodyMaleBackBackOverlay", color: ProgressV3Style.amber, opacity: 0.48)
        ],
        muscles: ProgressV3Factory.muscles([0.42, 0.34, 0.28, 0.2, 0.18, 0.12]),
        mix: ProgressV3Factory.mix(push: 0.34, pull: 0.24, legs: 0.3, core: 0.12),
        mixStatus: "sample forming",
        muscleEvidence: [
            .init(short: "P", title: "Push anchor", detail: "Chest and shoulders appeared first.", value: "7 sets", coverage: 0.42),
            .init(short: "L", title: "Lower anchor", detail: "Quads entered the first baseline.", value: "5 sets", coverage: 0.3),
            .init(short: "B", title: "Pull is light", detail: "Back signal exists but needs repetition.", value: "4 sets", coverage: 0.24)
        ]
    )

    static let established = ProgressV3DemoData(
        state: .established,
        metricLabel: "Training proof trend",
        metricValue: "+11",
        metricUnit: "% volume",
        metricCaption: "A stable demo window now supports trend, rhythm, and coverage review.",
        trend: [52, 56, 58, 62, 61, 68, 73, 72, 79, 84],
        status: "Proof window",
        trendValue: "+11",
        trendUnit: "% volume",
        trendCaption: "Twenty-seven demo workouts create a readable trend and recent proof trail.",
        bars: [0.38, 0.44, 0.52, 0.58, 0.64, 0.73, 0.82],
        rail: [
            .init(title: "sessions", value: "27", detail: "logged", tone: .positive),
            .init(title: "trend", value: "+11%", detail: "volume", tone: .positive),
            .init(title: "proof", value: "86%", detail: "ready", tone: .positive)
        ],
        metrics: [
            .init(title: "Workouts", value: "27", detail: "demo set", tone: .positive),
            .init(title: "Anchors", value: "9", detail: "trusted", tone: .positive),
            .init(title: "Coverage", value: "82%", detail: "mapped", tone: .positive)
        ],
        proof: [
            .init(title: "Upper Strength", date: "Apr 29", detail: "Top set moved while weekly volume stayed controlled.", tone: .positive),
            .init(title: "Lower Power", date: "May 01", detail: "Leg work returned near the four-week average.", tone: .positive),
            .init(title: "Pull Focus", date: "May 04", detail: "Back volume filled the distribution gap.", tone: .positive),
            .init(title: "Recovery Slot", date: "May 05", detail: "Lower load preserved cadence.", tone: .neutral)
        ],
        goal: .init(title: "Hold a four-week strength rhythm", detail: "Goal progress is shown as training consistency, not a game score.", value: "86%", unit: "rhythm", progress: 0.86, markerLabel: "stable"),
        days: ProgressV3Factory.days(completed: [1, 3, 5, 8, 10, 12, 15, 17, 19, 22, 24, 26, 29, 31, 33], forming: [35]),
        weeks: ProgressV3Factory.weeks([3, 4, 3, 5, 4, 6], current: 5),
        sessions: [
            .init(day: "M", title: "Upper Strength", detail: "Press and row improved together.", badge: "+4%", done: true),
            .init(day: "W", title: "Lower Power", detail: "Hinge volume returned to target.", badge: "balanced", done: true),
            .init(day: "F", title: "Pull Focus", detail: "Back work completed weekly coverage.", badge: "filled", done: true),
            .init(day: "S", title: "Recovery Slot", detail: "Low-load session kept rhythm intact.", badge: "easy", done: true)
        ],
        coverageStatus: "readable",
        coverageCaption: "Muscle coverage is now visible as distribution proof, not just workout count.",
        frontLayers: [
            .init(asset: "STRQHumanBodyMaleFrontChestOverlay", color: ProgressV3Style.signal, opacity: 0.64),
            .init(asset: "STRQHumanBodyMaleFrontShoulderOverlay", color: ProgressV3Style.signal, opacity: 0.5),
            .init(asset: "STRQHumanBodyMaleFrontUpperLegOverlay", color: ProgressV3Style.success, opacity: 0.54),
            .init(asset: "STRQHumanBodyMaleFrontAbsOverlay", color: ProgressV3Style.steel, opacity: 0.34)
        ],
        backLayers: [
            .init(asset: "STRQHumanBodyMaleBackBackOverlay", color: ProgressV3Style.signal, opacity: 0.68),
            .init(asset: "STRQHumanBodyMaleBackHamstringOverlay", color: ProgressV3Style.success, opacity: 0.46),
            .init(asset: "STRQHumanBodyMaleBackGluteOverlay", color: ProgressV3Style.success, opacity: 0.4),
            .init(asset: "STRQHumanBodyMaleBackTrapOverlay", color: ProgressV3Style.steel, opacity: 0.42)
        ],
        muscles: ProgressV3Factory.muscles([0.82, 0.78, 0.72, 0.64, 0.58, 0.46]),
        mix: ProgressV3Factory.mix(push: 0.28, pull: 0.31, legs: 0.29, core: 0.12),
        mixStatus: "balanced demo",
        muscleEvidence: [
            .init(short: "P", title: "Push volume steady", detail: "Chest and shoulder work stayed within target.", value: "24 sets", coverage: 0.82),
            .init(short: "B", title: "Pull gap closed", detail: "Back work filled the week.", value: "22 sets", coverage: 0.78),
            .init(short: "L", title: "Legs on pace", detail: "Quads and posterior chain remain readable.", value: "21 sets", coverage: 0.72)
        ]
    )
}

private enum ProgressV3Factory {
    static func days(completed: [Int], forming: [Int]) -> [ProgressV3Day] {
        (1...35).map { index in
            let status: ProgressV3DayStatus
            let intensity: Double
            if completed.contains(index) {
                status = .done
                intensity = 0.42 + Double((index * 19) % 48) / 100.0
            } else if forming.contains(index) {
                status = .forming
                intensity = 0.2
            } else {
                status = .open
                intensity = 0
            }
            return ProgressV3Day(index: index, intensity: intensity, status: status)
        }
    }

    static func weeks(_ sessions: [Int], current: Int) -> [ProgressV3Week] {
        sessions.enumerated().map { index, count in
            ProgressV3Week(label: index == current ? "Now" : "\(sessions.count - index)w", sessions: count, target: 6, current: index == current)
        }
    }

    static func muscles(_ values: [Double]) -> [ProgressV3Muscle] {
        let names = ["Push", "Pull", "Legs", "Posterior", "Core", "Carry"]
        let shorts = ["P", "B", "L", "H", "C", "Y"]
        let maxValue = values.max() ?? 0
        return zip(names.indices, values).map { index, value in
            ProgressV3Muscle(name: names[index], short: shorts[index], value: min(max(value, 0), 1), primary: value > 0 && value == maxValue)
        }
    }

    static func mix(push: Double, pull: Double, legs: Double, core: Double) -> [ProgressV3MixSegment] {
        [
            .init(name: "Push", label: "push", value: push, role: .primary),
            .init(name: "Pull", label: "pull", value: pull, role: .secondary),
            .init(name: "Legs", label: "legs", value: legs, role: .success),
            .init(name: "Core", label: "core", value: core, role: .neutral)
        ]
    }
}

private struct ProgressV3Metric: Identifiable {
    let title: String
    let value: String
    let detail: String
    let tone: ProgressV3Tone
    var id: String { "\(title)-\(value)" }
}

private struct ProgressV3Proof: Identifiable {
    let title: String
    let date: String
    let detail: String
    let tone: ProgressV3Tone
    var id: String { "\(date)-\(title)" }
}

private struct ProgressV3Goal {
    let title: String
    let detail: String
    let value: String
    let unit: String
    let progress: Double
    let markerLabel: String
    var clampedProgress: Double { min(max(progress, 0), 1) }
}

private struct ProgressV3Day: Identifiable {
    let index: Int
    let intensity: Double
    let status: ProgressV3DayStatus
    var id: Int { index }

    func fill(tint: Color) -> Color {
        switch status {
        case .open:
            return ProgressV3Style.surfaceSecondary
        case .forming:
            return tint.opacity(0.12 + intensity * 0.18)
        case .done:
            return tint.opacity(0.24 + intensity * 0.28)
        }
    }

    func stroke(tint: Color) -> Color {
        switch status {
        case .open:
            return ProgressV3Style.border
        case .forming:
            return tint.opacity(0.26)
        case .done:
            return tint.opacity(0.46)
        }
    }
}

private enum ProgressV3DayStatus {
    case open
    case forming
    case done

    var label: String {
        switch self {
        case .open:
            return "open"
        case .forming:
            return "forming"
        case .done:
            return "completed"
        }
    }
}

private struct ProgressV3Week: Identifiable {
    let label: String
    let sessions: Int
    let target: Int
    let current: Bool
    var id: String { label }
    var ratio: Double { target > 0 ? min(Double(sessions) / Double(target), 1) : 0 }
}

private struct ProgressV3Session: Identifiable {
    let day: String
    let title: String
    let detail: String
    let badge: String
    let done: Bool
    var id: String { "\(day)-\(title)" }
}

private struct ProgressV3BodyLayer: Identifiable {
    let asset: String
    let color: Color
    let opacity: Double
    var id: String { asset }
}

private struct ProgressV3Muscle: Identifiable {
    let name: String
    let short: String
    let value: Double
    let primary: Bool
    var id: String { name }
    var label: String { value > 0 ? "\(Int(value * 100))%" : "--" }
}

private struct ProgressV3MixSegment: Identifiable {
    let name: String
    let label: String
    let value: Double
    let role: ProgressV3MixRole
    var id: String { name }

    func color(tint: Color) -> Color {
        switch role {
        case .primary:
            return tint
        case .secondary:
            return ProgressV3Style.steel
        case .success:
            return ProgressV3Style.success
        case .neutral:
            return STRQColors.gray500
        }
    }
}

private enum ProgressV3MixRole {
    case primary
    case secondary
    case success
    case neutral
}

private struct ProgressV3MuscleEvidenceItem: Identifiable {
    let short: String
    let title: String
    let detail: String
    let value: String
    let coverage: Double
    var id: String { "\(short)-\(title)" }
    var clamped: Double { min(max(coverage, 0), 1) }
}

private enum ProgressV3Tone {
    case neutral
    case forming
    case positive

    var color: Color {
        switch self {
        case .neutral:
            return ProgressV3Style.steel
        case .forming:
            return ProgressV3Style.amber
        case .positive:
            return ProgressV3Style.signal
        }
    }

    func markerColor(tint: Color) -> Color {
        switch self {
        case .neutral:
            return tint.opacity(0.4)
        case .forming, .positive:
            return color
        }
    }
}

private enum ProgressV3Style {
    static let background = hex(0x050608)
    static let surfaceDeep = hex(0x090B0F)
    static let surface = hex(0x101318)
    static let surfaceSecondary = hex(0x171B22)
    static let control = hex(0x151922)
    static let controlDeep = hex(0x0D1016)
    static let selected = hex(0x242B34)
    static let plot = hex(0x070A0F)
    static let heroTop = hex(0x18202A)
    static let heroBottom = hex(0x07090D)
    static let goalTop = hex(0x111A18)
    static let bodyTop = hex(0x151A20)
    static let track = hex(0x2C333D)
    static let grid = Color.white.opacity(0.065)
    static let border = Color.white.opacity(0.08)
    static let borderStrong = Color.white.opacity(0.14)
    static let steel = hex(0xAAB7C7)
    static let signal = hex(0x69D7CE)
    static let success = STRQColors.successGreen
    static let amber = STRQColors.warningAmber

    private static func hex(_ value: UInt, opacity: Double = 1) -> Color {
        Color(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: opacity
        )
    }
}

private struct ProgressV3ConceptLabView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressV3ConceptLabView()
            .previewDisplayName("Progress V3 Concept Lab")
    }
}
#endif
