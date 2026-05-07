import SwiftUI

#if DEBUG
struct ProgressV4HybridCandidateView: View {
    @State private var state: ProgressV4DemoState = .baseline

    private var data: ProgressV4DemoData {
        state.demoData
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                ProgressV4Header()
                ProgressV4StateControl(selection: $state)
                ProgressV4MuscleProofHero(data: data)
                ProgressV4RhythmLayer(data: data)
                ProgressV4TrendDetailLayer(data: data)
                ProgressV4TrainingMix(data: data)
                ProgressV4RecentEvidence(data: data)
            }
            .frame(maxWidth: 430)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, STRQSpacing.md)
            .padding(.vertical, STRQSpacing.lg)
        }
        .background(ProgressV4Style.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

private struct ProgressV4Header: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Training Progress")
                .font(STRQTypography.headingSmall)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.68)

            Text("Distribution, rhythm, strength trend, and recent proof in one progress surface.")
                .font(STRQTypography.caption)
                .foregroundStyle(STRQColors.secondaryText)
                .lineLimit(2)
        }
    }
}

private struct ProgressV4StateControl: View {
    @Binding var selection: ProgressV4DemoState

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ProgressV4DemoState.allCases) { item in
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
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(selection == item ? item.tint.opacity(0.1) : Color.clear, in: .rect(cornerRadius: STRQRadii.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                            .strokeBorder(selection == item ? item.tint.opacity(0.32) : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(ProgressV4Style.controlDeep, in: .rect(cornerRadius: STRQRadii.lg))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.lg, style: .continuous)
                .strokeBorder(ProgressV4Style.border, lineWidth: 1)
        )
    }
}

// MARK: - Hero

private struct ProgressV4MuscleProofHero: View {
    let data: ProgressV4DemoData

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.md) {
            VStack(alignment: .leading, spacing: 7) {
                Text("Training Distribution")
                    .font(STRQTypography.headingXS)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(alignment: .top, spacing: STRQSpacing.sm) {
                    Text(data.heroCaption)
                        .font(STRQTypography.caption)
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(2)

                    Spacer(minLength: STRQSpacing.xs)
                    ProgressV4StatusChip(text: data.maturityLabel, tint: data.tint)
                        .padding(.top, 1)
                }
            }

            HStack(alignment: .center, spacing: STRQSpacing.sm) {
                ProgressV4BodyFigure(
                    title: "Front",
                    base: "STRQHumanBodyMaleFrontBase",
                    layers: data.frontLayers,
                    tint: data.tint,
                    isBaseline: data.state == .baseline
                )

                VStack(alignment: .leading, spacing: STRQSpacing.xs) {
                    Text("Muscle Coverage")
                        .font(STRQTypography.micro)
                        .foregroundStyle(STRQColors.mutedText)
                        .lineLimit(1)

                    ForEach(data.coverageBars) { bar in
                        ProgressV4CoverageBar(item: bar, tint: data.tint)
                    }
                }
                .frame(width: 128)

                ProgressV4BodyFigure(
                    title: "Back",
                    base: "STRQHumanBodyMaleBackBase",
                    layers: data.backLayers,
                    tint: data.tint,
                    isBaseline: data.state == .baseline
                )
            }
            .padding(.vertical, STRQSpacing.xs)

            HStack(spacing: 0) {
                ProgressV4HeroStat(title: "Workouts", value: data.workoutValue, tint: data.tint)
                ProgressV4Divider()
                ProgressV4HeroStat(title: "Window", value: data.windowValue, tint: data.tint)
                ProgressV4Divider()
                ProgressV4HeroStat(title: "Signal", value: data.readabilityValue, tint: data.tint)
            }
            .padding(.vertical, STRQSpacing.sm)
            .background(ProgressV4Style.glassSurface, in: .rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(ProgressV4Style.border, lineWidth: 1)
            )
        }
        .padding(STRQSpacing.md)
        .background {
            ZStack {
                LinearGradient(
                    colors: [
                        data.tint.opacity(data.state == .baseline ? 0.16 : 0.23),
                        ProgressV4Style.heroBottom,
                        ProgressV4Style.surfaceDeep
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                ProgressV4FineGrid().opacity(0.22)
            }
            .clipShape(.rect(cornerRadius: 30))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(data.tint.opacity(data.state == .baseline ? 0.18 : 0.32), lineWidth: 1)
        )
        .overlay(alignment: .topLeading) {
            Rectangle()
                .fill(data.tint.opacity(data.state == .baseline ? 0.52 : 0.88))
                .frame(width: data.state == .baseline ? 74 : 118, height: 3)
                .padding(.leading, STRQSpacing.lg)
        }
    }
}

private struct ProgressV4BodyFigure: View {
    let title: String
    let base: String
    let layers: [ProgressV4BodyLayer]
    let tint: Color
    let isBaseline: Bool

    var body: some View {
        VStack(spacing: STRQSpacing.xs) {
            ZStack {
                Image(base)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .opacity(isBaseline ? 0.3 : 0.52)

                ForEach(layers) { layer in
                    Image(layer.asset)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(layer.color.opacity(layer.opacity))
                }

                if layers.isEmpty {
                    ProgressV4BodyScanLines(tint: tint)
                        .opacity(0.28)
                } else {
                    Image(base)
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .blendMode(.darken)
                        .opacity(0.32)
                }
            }
            .frame(height: 226)
            .frame(maxWidth: .infinity)
            .padding(6)

            Text(title.uppercased())
                .font(STRQTypography.micro)
                .foregroundStyle(STRQColors.mutedText)
                .lineLimit(1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(title) muscle coverage"))
    }
}

private struct ProgressV4BodyScanLines: View {
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)
            let xPositions: [CGFloat] = [0.38, 0.62, 0.5, 0.43, 0.57]
            let yPositions: [CGFloat] = [0.25, 0.25, 0.46, 0.7, 0.7]

            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .strokeBorder(tint.opacity(0.13), style: StrokeStyle(lineWidth: 1, dash: [6, 8]))
                    .padding(.horizontal, width * 0.18)
                    .padding(.vertical, height * 0.08)

                Path { path in
                    for index in 0..<7 {
                        let y = height * CGFloat(index + 1) / 8
                        path.move(to: CGPoint(x: width * 0.16, y: y))
                        path.addLine(to: CGPoint(x: width * 0.84, y: y))
                    }
                }
                .stroke(tint.opacity(0.34), style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [5, 7]))

                Path { path in
                    path.move(to: CGPoint(x: width * 0.5, y: height * 0.12))
                    path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.88))
                    path.move(to: CGPoint(x: width * 0.32, y: height * 0.34))
                    path.addLine(to: CGPoint(x: width * 0.68, y: height * 0.34))
                    path.move(to: CGPoint(x: width * 0.36, y: height * 0.66))
                    path.addLine(to: CGPoint(x: width * 0.64, y: height * 0.66))
                }
                .stroke(tint.opacity(0.18), style: StrokeStyle(lineWidth: 1, lineCap: .round))

                ForEach(0..<5, id: \.self) { index in
                    Circle()
                        .strokeBorder(tint.opacity(index == 2 ? 0.32 : 0.18), lineWidth: 1)
                        .background(Circle().fill(ProgressV4Style.plot.opacity(0.42)))
                        .frame(width: 7, height: 7)
                        .position(
                            x: width * xPositions[index],
                            y: height * yPositions[index]
                        )
                }
            }
        }
    }
}

private struct ProgressV4CoverageBar: View {
    let item: ProgressV4CoverageItem
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.title)
                    .font(STRQTypography.micro)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Spacer()
                Text(item.label)
                    .font(STRQTypography.micro)
                    .foregroundStyle(item.value > 0 ? tint : STRQColors.mutedText)
                    .monospacedDigit()
                    .lineLimit(1)
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(ProgressV4Style.track)
                    if item.value > 0 {
                        Capsule()
                            .fill(tint.opacity(item.isPrimary ? 0.94 : 0.6))
                            .frame(width: max(4, proxy.size.width * CGFloat(item.clampedValue)))
                    } else {
                        Capsule()
                            .fill(ProgressV4Style.steel.opacity(0.08))
                            .frame(width: proxy.size.width * 0.34)
                        Capsule()
                            .fill(ProgressV4Style.steel.opacity(0.2))
                            .frame(width: 12)
                    }
                }
            }
            .frame(height: 7)
        }
        .padding(STRQSpacing.xs)
        .background(ProgressV4Style.surface.opacity(0.58), in: .rect(cornerRadius: STRQRadii.md))
    }
}

private struct ProgressV4HeroStat: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(STRQTypography.labelLarge)
                .foregroundStyle(value == "--" ? STRQColors.mutedText : tint)
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(title)
                .font(STRQTypography.micro)
                .foregroundStyle(STRQColors.mutedText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, STRQSpacing.sm)
    }
}

// MARK: - Rhythm

private struct ProgressV4RhythmLayer: View {
    let data: ProgressV4DemoData

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Rhythm")
                        .font(STRQTypography.cardTitle)
                        .foregroundStyle(STRQColors.primaryText)
                    Text(data.rhythmCaption)
                        .font(STRQTypography.caption)
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(2)
                }
                Spacer()
                Text(data.rhythmValue)
                    .font(STRQTypography.labelSmall)
                    .foregroundStyle(data.tint)
                    .lineLimit(1)
                    .monospacedDigit()
            }

            ProgressV4RhythmGrid(days: data.rhythmDays, tint: data.tint)

            HStack(alignment: .bottom, spacing: 7) {
                ForEach(data.weekSummaries) { week in
                    ProgressV4WeekColumn(week: week, tint: data.tint)
                }
            }
            .frame(height: 86)
        }
        .padding(STRQSpacing.md)
        .background {
            UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 28, bottomTrailingRadius: 10, topTrailingRadius: 28, style: .continuous)
                .fill(ProgressV4Style.surface)
        }
        .overlay(
            UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 28, bottomTrailingRadius: 10, topTrailingRadius: 28, style: .continuous)
                .strokeBorder(ProgressV4Style.border, lineWidth: 1)
        )
    }
}

private struct ProgressV4RhythmGrid: View {
    let days: [ProgressV4RhythmDay]
    let tint: Color

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)
    private let labels = ["M", "T", "W", "T", "F", "S", "S"]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 5) {
            ForEach(Array(labels.enumerated()), id: \.offset) { _, label in
                Text(label)
                    .font(STRQTypography.micro)
                    .foregroundStyle(STRQColors.mutedText)
                    .frame(height: 14)
            }

            ForEach(days) { day in
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(day.fill(tint: tint))
                    .frame(height: 24)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(day.stroke(tint: tint), lineWidth: 1)
                    )
                    .overlay(alignment: .bottom) {
                        if day.status == .trained {
                            Capsule()
                                .fill(tint)
                                .frame(width: 14, height: 3)
                                .padding(.bottom, 4)
                        }
                    }
                    .accessibilityLabel(Text("Training rhythm day \(day.index) \(day.status.label)"))
            }
        }
        .padding(STRQSpacing.sm)
        .background(ProgressV4Style.plot, in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(ProgressV4Style.border, lineWidth: 1)
        )
    }
}

private struct ProgressV4WeekColumn: View {
    let week: ProgressV4WeekSummary
    let tint: Color

    var body: some View {
        VStack(spacing: 5) {
            GeometryReader { proxy in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(ProgressV4Style.track)
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(week.sessions > 0 ? tint.opacity(week.current ? 0.92 : 0.5) : ProgressV4Style.steel.opacity(0.14))
                        .frame(height: max(5, proxy.size.height * CGFloat(week.ratio)))
                }
            }
            .frame(height: 52)

            Text(week.label)
                .font(STRQTypography.micro)
                .foregroundStyle(week.current ? tint : STRQColors.mutedText)
                .lineLimit(1)
            Text("\(week.sessions)")
                .font(STRQTypography.micro)
                .foregroundStyle(STRQColors.secondaryText)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Trend

private struct ProgressV4TrendDetailLayer: View {
    let data: ProgressV4DemoData

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Strength Trend")
                        .font(STRQTypography.cardTitle)
                        .foregroundStyle(STRQColors.primaryText)
                    Text(data.trendCaption)
                        .font(STRQTypography.caption)
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(2)
                }
                Spacer()
                ProgressV4StatusChip(text: data.trendStatus, tint: data.tint)
            }

            HStack(alignment: .lastTextBaseline, spacing: 5) {
                Text(data.trendValue)
                    .font(STRQTypography.metricMedium)
                    .foregroundStyle(data.trendValues.isEmpty ? STRQColors.mutedText : STRQColors.primaryText)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
                if !data.trendUnit.isEmpty {
                    Text(data.trendUnit)
                        .font(STRQTypography.caption)
                        .foregroundStyle(STRQColors.secondaryText)
                        .padding(.bottom, 5)
                }
                Spacer()
                Text(data.trendWindow)
                    .font(STRQTypography.micro)
                    .foregroundStyle(STRQColors.mutedText)
                    .lineLimit(1)
            }

            ProgressV4LineChart(values: data.trendValues, tint: data.tint)
                .frame(height: 146)
                .padding(STRQSpacing.sm)
                .background(ProgressV4Style.plot, in: .rect(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(ProgressV4Style.border, lineWidth: 1)
                )
        }
        .padding(STRQSpacing.md)
        .background {
            ZStack(alignment: .topTrailing) {
                ProgressV4Style.surfaceSecondary
                Rectangle()
                    .fill(data.tint.opacity(0.14))
                    .frame(width: 104)
                    .rotationEffect(.degrees(13))
                    .offset(x: 40, y: -28)
            }
            .clipShape(.rect(cornerRadius: 22))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(data.tint.opacity(data.state == .baseline ? 0.12 : 0.22), lineWidth: 1)
        )
    }
}

private struct ProgressV4LineChart: View {
    let values: [Double]
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            let points = normalizedPoints(size: proxy.size)

            ZStack {
                ProgressV4Grid(rows: 4, columns: 6)

                if points.count < 2 {
                    ProgressV4TrendSkeleton(tint: tint)
                } else {
                    area(points: points, height: proxy.size.height)
                        .fill(LinearGradient(colors: [tint.opacity(0.2), tint.opacity(0.02)], startPoint: .top, endPoint: .bottom))

                    line(points: points)
                        .stroke(tint, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                    ForEach(Array(points.enumerated()), id: \.offset) { index, point in
                        Circle()
                            .fill(index == points.count - 1 ? tint : ProgressV4Style.plot)
                            .frame(width: index == points.count - 1 ? 11 : 8, height: index == points.count - 1 ? 11 : 8)
                            .overlay(Circle().strokeBorder(tint.opacity(0.85), lineWidth: 2))
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
                y: (1 - CGFloat((value - minValue) / span)) * (max(size.height, 1) - 26) + 13
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

private struct ProgressV4TrendSkeleton: View {
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)

            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height * 0.62))
                    path.addLine(to: CGPoint(x: width, y: height * 0.62))
                }
                .stroke(tint.opacity(0.32), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [7, 8]))

                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .strokeBorder(tint.opacity(index < 2 ? 0.38 : 0.14), lineWidth: 2)
                        .frame(width: 13, height: 13)
                        .position(
                            x: width * CGFloat(index) / 5,
                            y: height * (0.36 + CGFloat(index % 3) * 0.12)
                        )
                }
            }
        }
    }
}

// MARK: - Mix

private struct ProgressV4TrainingMix: View {
    let data: ProgressV4DemoData

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.md) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Training Mix")
                        .font(STRQTypography.cardTitle)
                        .foregroundStyle(STRQColors.primaryText)
                    Text(data.mixCaption)
                        .font(STRQTypography.caption)
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(2)
                }
                Spacer()
                Text(data.mixStatus)
                    .font(STRQTypography.micro)
                    .foregroundStyle(data.tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
            }

            ProgressV4MixRail(segments: data.mixSegments, tint: data.tint, state: data.state)
                .frame(height: 36)

            VStack(spacing: STRQSpacing.xs) {
                ForEach(data.mixSegments) { segment in
                    ProgressV4MixRow(segment: segment, tint: data.tint, state: data.state)
                }
            }
        }
        .padding(.horizontal, STRQSpacing.md)
        .padding(.vertical, STRQSpacing.md)
        .background(ProgressV4Style.surfaceDeep)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(data.tint.opacity(data.state == .baseline ? 0.18 : 0.46))
                .frame(height: 1)
        }
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(ProgressV4Style.border)
                .frame(height: 1)
        }
    }
}

private struct ProgressV4MixRail: View {
    let segments: [ProgressV4MixSegment]
    let tint: Color
    let state: ProgressV4DemoState

    var body: some View {
        GeometryReader { proxy in
            let availableWidth = max(proxy.size.width - CGFloat(max(segments.count - 1, 0) * 4), 1)

            HStack(spacing: 4) {
                ForEach(segments) { segment in
                    let segmentWidth = max(state == .baseline ? 14 : 28, availableWidth * CGFloat(segment.clampedValue))

                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(segment.color(tint: tint, state: state).opacity(segment.value > 0 ? 0.9 : 0.16))
                        .frame(width: segmentWidth)
                        .overlay {
                            if segment.value > 0, segmentWidth > 34 {
                                Text(segment.short)
                                    .font(STRQTypography.micro)
                                    .foregroundStyle(segment.value > 0.13 ? ProgressV4Style.background : STRQColors.mutedText)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.48)
                            }
                        }
                }
            }
        }
        .padding(4)
        .background(ProgressV4Style.plot, in: .rect(cornerRadius: STRQRadii.md))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                .strokeBorder(ProgressV4Style.border, lineWidth: 1)
        )
    }
}

private struct ProgressV4MixRow: View {
    let segment: ProgressV4MixSegment
    let tint: Color
    let state: ProgressV4DemoState

    var body: some View {
        HStack(spacing: STRQSpacing.sm) {
            Text(segment.name)
                .font(STRQTypography.caption)
                .foregroundStyle(STRQColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .frame(width: 70, alignment: .leading)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(ProgressV4Style.track)
                    Capsule()
                        .fill(segment.color(tint: tint, state: state).opacity(segment.value > 0 ? 0.82 : 0.14))
                        .frame(width: max(5, proxy.size.width * CGFloat(segment.clampedValue)))
                }
            }
            .frame(height: 8)

            Text(segment.label)
                .font(STRQTypography.micro)
                .foregroundStyle(segment.value > 0 ? segment.color(tint: tint, state: state) : STRQColors.mutedText)
                .monospacedDigit()
                .lineLimit(1)
                .frame(width: 42, alignment: .trailing)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Evidence

private struct ProgressV4RecentEvidence: View {
    let data: ProgressV4DemoData

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text("Recent Evidence")
                    .font(STRQTypography.cardTitle)
                    .foregroundStyle(STRQColors.primaryText)
                Spacer()
                Text(data.evidenceWindow)
                    .font(STRQTypography.micro)
                    .foregroundStyle(data.tint)
                    .lineLimit(1)
            }

            VStack(spacing: 0) {
                ForEach(Array(data.evidence.enumerated()), id: \.element.id) { index, item in
                    ProgressV4EvidenceRow(
                        item: item,
                        tint: data.tint,
                        isLast: index == data.evidence.count - 1
                    )
                }
            }
        }
        .padding(STRQSpacing.md)
        .background(ProgressV4Style.surface, in: .rect(cornerRadius: 12))
        .overlay(alignment: .leading) {
            Rectangle()
                .fill(data.tint.opacity(data.state == .baseline ? 0.24 : 0.62))
                .frame(width: 2)
                .padding(.vertical, STRQSpacing.md)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(ProgressV4Style.border, lineWidth: 1)
        )
    }
}

private struct ProgressV4EvidenceRow: View {
    let item: ProgressV4EvidenceItem
    let tint: Color
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: STRQSpacing.sm) {
            VStack(spacing: 0) {
                Circle()
                    .fill(item.tone.markerColor(tint: tint))
                    .frame(width: 12, height: 12)
                    .overlay(Circle().strokeBorder(STRQColors.white.opacity(0.22), lineWidth: 1))
                Rectangle()
                    .fill(isLast ? Color.clear : ProgressV4Style.borderStrong)
                    .frame(width: 1)
            }
            .frame(width: 16)

            VStack(alignment: .leading, spacing: 5) {
                HStack(alignment: .firstTextBaseline, spacing: STRQSpacing.xs) {
                    Text(item.date)
                        .font(STRQTypography.micro)
                        .foregroundStyle(item.tone.tagColor(tint: tint))
                        .lineLimit(1)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(item.tone.tagColor(tint: tint).opacity(0.1), in: Capsule())

                    Text(item.title)
                        .font(STRQTypography.bodySmallMedium)
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Text(item.detail)
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(2)

                if !item.tags.isEmpty {
                    HStack(spacing: 5) {
                        ForEach(item.tags, id: \.self) { tag in
                            Text(tag)
                                .font(STRQTypography.micro)
                                .foregroundStyle(item.tone.tagColor(tint: tint))
                                .lineLimit(1)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 4)
                                .background(item.tone.tagColor(tint: tint).opacity(0.1), in: Capsule())
                        }
                    }
                }
            }
            .padding(STRQSpacing.sm)
            .background(ProgressV4Style.surfaceSecondary.opacity(0.58), in: .rect(cornerRadius: STRQRadii.md))
            .overlay(
                RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                    .strokeBorder(item.tone.markerColor(tint: tint).opacity(0.16), lineWidth: 1)
            )
            .padding(.bottom, isLast ? 0 : STRQSpacing.xs)
        }
    }
}

// MARK: - Shared

private struct ProgressV4StatusChip: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(STRQTypography.micro)
            .foregroundStyle(tint)
            .lineLimit(1)
            .minimumScaleFactor(0.66)
            .padding(.horizontal, STRQSpacing.xs)
            .padding(.vertical, 5)
            .background(tint.opacity(0.12), in: Capsule())
            .overlay(Capsule().strokeBorder(tint.opacity(0.32), lineWidth: 1))
    }
}

private struct ProgressV4Divider: View {
    var body: some View {
        Rectangle()
            .fill(ProgressV4Style.border)
            .frame(width: 1, height: 36)
    }
}

private struct ProgressV4FineGrid: View {
    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)

            Path { path in
                for index in 0...8 {
                    let x = width * CGFloat(index) / 8
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }
                for index in 0...7 {
                    let y = height * CGFloat(index) / 7
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
            }
            .stroke(ProgressV4Style.grid, lineWidth: 1)
        }
    }
}

private struct ProgressV4Grid: View {
    let rows: Int
    let columns: Int

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)

            Path { path in
                for index in 0...rows {
                    let y = height * CGFloat(index) / CGFloat(max(rows, 1))
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
                for index in 0...columns {
                    let x = width * CGFloat(index) / CGFloat(max(columns, 1))
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }
            }
            .stroke(ProgressV4Style.grid, lineWidth: 1)
        }
    }
}

// MARK: - Local Data

private enum ProgressV4DemoState: CaseIterable, Identifiable {
    case baseline
    case forming
    case established

    var id: Self { self }

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
            return ProgressV4Style.steel
        case .forming:
            return ProgressV4Style.amber
        case .established:
            return ProgressV4Style.signal
        }
    }

    var demoData: ProgressV4DemoData {
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

private struct ProgressV4DemoData {
    let state: ProgressV4DemoState
    let heroCaption: String
    let maturityLabel: String
    let workoutValue: String
    let windowValue: String
    let readabilityValue: String
    let frontLayers: [ProgressV4BodyLayer]
    let backLayers: [ProgressV4BodyLayer]
    let coverageBars: [ProgressV4CoverageItem]
    let rhythmCaption: String
    let rhythmValue: String
    let rhythmDays: [ProgressV4RhythmDay]
    let weekSummaries: [ProgressV4WeekSummary]
    let trendCaption: String
    let trendStatus: String
    let trendValue: String
    let trendUnit: String
    let trendWindow: String
    let trendValues: [Double]
    let mixCaption: String
    let mixStatus: String
    let mixSegments: [ProgressV4MixSegment]
    let evidenceWindow: String
    let evidence: [ProgressV4EvidenceItem]

    var tint: Color { state.tint }

    // Prototype-only demo data. It stays local to this DEBUG candidate and does not touch app models.
    static let baseline = ProgressV4DemoData(
        state: .baseline,
        heroCaption: "Complete sessions to build the first coverage map. Until then, this stays structured and quiet.",
        maturityLabel: "Baseline forming",
        workoutValue: "0",
        windowValue: "--",
        readabilityValue: "Locked",
        frontLayers: [],
        backLayers: [],
        coverageBars: ProgressV4Factory.coverage(push: 0, pull: 0, legs: 0, posterior: 0),
        rhythmCaption: "Cadence is open until training starts.",
        rhythmValue: "0 sessions",
        rhythmDays: ProgressV4Factory.days(trained: [], forming: [8, 15, 22, 29]),
        weekSummaries: ProgressV4Factory.weeks([0, 0, 0, 0, 0, 0], current: 5),
        trendCaption: "Strength stays blank until the first repeatable anchor exists.",
        trendStatus: "Locked",
        trendValue: "--",
        trendUnit: "",
        trendWindow: "baseline",
        trendValues: [],
        mixCaption: "Push, pull, legs, core, and posterior work start empty.",
        mixStatus: "Baseline forming",
        mixSegments: ProgressV4Factory.mix(push: 0, pull: 0, legs: 0, core: 0, posterior: 0),
        evidenceWindow: "now",
        evidence: [
            .init(date: "Now", title: "No completed sessions", detail: "Complete workouts to start the training record.", tags: ["0 workouts"], tone: .neutral),
            .init(date: "0/3", title: "First anchors pending", detail: "Coverage, rhythm, and trend stay quiet until the first sessions land.", tags: ["Baseline"], tone: .neutral)
        ]
    )

    static let forming = ProgressV4DemoData(
        state: .forming,
        heroCaption: "Three workouts show early push, legs, and pull signals without claiming balance.",
        maturityLabel: "Early signal",
        workoutValue: "3",
        windowValue: "1 wk",
        readabilityValue: "Early",
        frontLayers: [
            .init(asset: "STRQHumanBodyMaleFrontChestOverlay", color: ProgressV4Style.amber, opacity: 0.54),
            .init(asset: "STRQHumanBodyMaleFrontUpperLegOverlay", color: ProgressV4Style.amber, opacity: 0.34)
        ],
        backLayers: [
            .init(asset: "STRQHumanBodyMaleBackBackOverlay", color: ProgressV4Style.amber, opacity: 0.42),
            .init(asset: "STRQHumanBodyMaleBackHamstringOverlay", color: ProgressV4Style.steel, opacity: 0.24)
        ],
        coverageBars: ProgressV4Factory.coverage(push: 0.42, pull: 0.28, legs: 0.34, posterior: 0.18),
        rhythmCaption: "A week is visible, but the cadence still needs repeats.",
        rhythmValue: "3 sessions",
        rhythmDays: ProgressV4Factory.days(trained: [3, 7, 12], forming: [18, 23, 28]),
        weekSummaries: ProgressV4Factory.weeks([0, 1, 0, 2, 0, 3], current: 5),
        trendCaption: "Volume is moving; repeats will turn it into a reliable trend.",
        trendStatus: "Early signal",
        trendValue: "+4",
        trendUnit: "% volume",
        trendWindow: "3 sessions",
        trendValues: [42, 48, 46, 53, 57],
        mixCaption: "The first week leans push and legs, with pull still light.",
        mixStatus: "Early signal",
        mixSegments: ProgressV4Factory.mix(push: 0.32, pull: 0.22, legs: 0.28, core: 0.1, posterior: 0.08),
        evidenceWindow: "this week",
        evidence: [
            .init(date: "Mon", title: "Upper Strength", detail: "Pressing and rows created the first upper-body anchors.", tags: ["Push", "Pull"], tone: .forming),
            .init(date: "Thu", title: "Lower Strength", detail: "Squat work added a clear leg signal.", tags: ["Legs"], tone: .forming),
            .init(date: "Sat", title: "Full Body", detail: "Third workout made weekly rhythm visible; repeats will confirm it.", tags: ["Rhythm"], tone: .forming)
        ]
    )

    static let established = ProgressV4DemoData(
        state: .established,
        heroCaption: "A four-week window shows readable coverage across push, pull, legs, and posterior chain.",
        maturityLabel: "High confidence",
        workoutValue: "27",
        windowValue: "4 wk",
        readabilityValue: "Readable",
        frontLayers: [
            .init(asset: "STRQHumanBodyMaleFrontChestOverlay", color: ProgressV4Style.signal, opacity: 0.64),
            .init(asset: "STRQHumanBodyMaleFrontShoulderOverlay", color: ProgressV4Style.signal, opacity: 0.5),
            .init(asset: "STRQHumanBodyMaleFrontUpperLegOverlay", color: ProgressV4Style.success, opacity: 0.56),
            .init(asset: "STRQHumanBodyMaleFrontAbsOverlay", color: ProgressV4Style.steel, opacity: 0.34)
        ],
        backLayers: [
            .init(asset: "STRQHumanBodyMaleBackBackOverlay", color: ProgressV4Style.signal, opacity: 0.68),
            .init(asset: "STRQHumanBodyMaleBackHamstringOverlay", color: ProgressV4Style.success, opacity: 0.48),
            .init(asset: "STRQHumanBodyMaleBackGluteOverlay", color: ProgressV4Style.success, opacity: 0.42),
            .init(asset: "STRQHumanBodyMaleBackTrapOverlay", color: ProgressV4Style.steel, opacity: 0.4)
        ],
        coverageBars: ProgressV4Factory.coverage(push: 0.82, pull: 0.78, legs: 0.74, posterior: 0.66),
        rhythmCaption: "Sessions are spaced well enough to read weekly cadence.",
        rhythmValue: "6 sessions",
        rhythmDays: ProgressV4Factory.days(trained: [1, 3, 5, 8, 10, 12, 15, 17, 19, 22, 24, 26, 29, 31, 33], forming: [35]),
        weekSummaries: ProgressV4Factory.weeks([3, 4, 3, 5, 4, 6], current: 5),
        trendCaption: "Strength volume is up while coverage stays balanced.",
        trendStatus: "High confidence",
        trendValue: "+11",
        trendUnit: "% volume",
        trendWindow: "4 weeks",
        trendValues: [52, 56, 58, 62, 61, 68, 73, 72, 79, 84],
        mixCaption: "Distribution is broad without letting one pattern dominate the week.",
        mixStatus: "Balanced",
        mixSegments: ProgressV4Factory.mix(push: 0.25, pull: 0.28, legs: 0.24, core: 0.09, posterior: 0.14),
        evidenceWindow: "latest",
        evidence: [
            .init(date: "Apr 29", title: "Upper Strength", detail: "Press and row moved together without crowding lower work.", tags: ["Push", "Pull"], tone: .positive),
            .init(date: "May 01", title: "Lower Power", detail: "Leg work returned near the four-week average.", tags: ["Legs"], tone: .positive),
            .init(date: "May 04", title: "Pull Focus", detail: "Back volume filled the main coverage gap.", tags: ["Pull"], tone: .positive),
            .init(date: "May 05", title: "Recovery Slot", detail: "Low-load work preserved cadence without changing the trend.", tags: ["Rhythm"], tone: .neutral)
        ]
    )
}

private enum ProgressV4Factory {
    static func coverage(push: Double, pull: Double, legs: Double, posterior: Double) -> [ProgressV4CoverageItem] {
        let values = [
            ("Push", push),
            ("Pull", pull),
            ("Legs", legs),
            ("Posterior", posterior)
        ]
        let maxValue = values.map { $0.1 }.max() ?? 0

        return values.map { name, value in
            ProgressV4CoverageItem(title: name, value: min(max(value, 0), 1), isPrimary: value > 0 && value == maxValue)
        }
    }

    static func days(trained: [Int], forming: [Int]) -> [ProgressV4RhythmDay] {
        (1...35).map { index in
            let status: ProgressV4RhythmDayStatus
            let intensity: Double

            if trained.contains(index) {
                status = .trained
                intensity = 0.4 + Double((index * 17) % 44) / 100.0
            } else if forming.contains(index) {
                status = .forming
                intensity = 0.22
            } else {
                status = .open
                intensity = 0
            }

            return ProgressV4RhythmDay(index: index, intensity: intensity, status: status)
        }
    }

    static func weeks(_ sessions: [Int], current: Int) -> [ProgressV4WeekSummary] {
        sessions.enumerated().map { index, count in
            ProgressV4WeekSummary(label: index == current ? "Now" : "\(sessions.count - index)w", sessions: count, target: 6, current: index == current)
        }
    }

    static func mix(push: Double, pull: Double, legs: Double, core: Double, posterior: Double) -> [ProgressV4MixSegment] {
        [
            .init(name: "Push", short: "Push", value: push, role: .primary),
            .init(name: "Pull", short: "Pull", value: pull, role: .secondary),
            .init(name: "Legs", short: "Legs", value: legs, role: .success),
            .init(name: "Core", short: "Core", value: core, role: .neutral),
            .init(name: "Posterior", short: "Posterior", value: posterior, role: .successSoft)
        ]
    }
}

private struct ProgressV4BodyLayer: Identifiable {
    let asset: String
    let color: Color
    let opacity: Double
    var id: String { asset }
}

private struct ProgressV4CoverageItem: Identifiable {
    let title: String
    let value: Double
    let isPrimary: Bool
    var id: String { title }
    var clampedValue: Double { min(max(value, 0), 1) }
    var label: String { value > 0 ? "\(Int((clampedValue * 100).rounded()))%" : "--" }
}

private struct ProgressV4RhythmDay: Identifiable {
    let index: Int
    let intensity: Double
    let status: ProgressV4RhythmDayStatus
    var id: Int { index }

    func fill(tint: Color) -> Color {
        switch status {
        case .open:
            return ProgressV4Style.surfaceSecondary
        case .forming:
            return tint.opacity(0.12 + intensity * 0.14)
        case .trained:
            return tint.opacity(0.22 + intensity * 0.28)
        }
    }

    func stroke(tint: Color) -> Color {
        switch status {
        case .open:
            return ProgressV4Style.border
        case .forming:
            return tint.opacity(0.24)
        case .trained:
            return tint.opacity(0.45)
        }
    }
}

private enum ProgressV4RhythmDayStatus {
    case open
    case forming
    case trained

    var label: String {
        switch self {
        case .open:
            return "open"
        case .forming:
            return "forming"
        case .trained:
            return "trained"
        }
    }
}

private struct ProgressV4WeekSummary: Identifiable {
    let label: String
    let sessions: Int
    let target: Int
    let current: Bool
    var id: String { label }
    var ratio: Double { target > 0 ? min(Double(sessions) / Double(target), 1) : 0 }
}

private struct ProgressV4MixSegment: Identifiable {
    let name: String
    let short: String
    let value: Double
    let role: ProgressV4MixRole
    var id: String { name }
    var clampedValue: Double { min(max(value, 0), 1) }
    var label: String { value > 0 ? "\(Int((clampedValue * 100).rounded()))%" : "--" }

    func color(tint: Color, state: ProgressV4DemoState) -> Color {
        guard state != .baseline else {
            return ProgressV4Style.steel
        }

        switch role {
        case .primary:
            return tint
        case .secondary:
            return state == .forming ? ProgressV4Style.amber.opacity(0.74) : ProgressV4Style.steel
        case .success:
            return state == .forming ? ProgressV4Style.amber.opacity(0.62) : ProgressV4Style.success
        case .successSoft:
            return state == .forming ? ProgressV4Style.steel.opacity(0.76) : ProgressV4Style.success.opacity(0.78)
        case .neutral:
            return ProgressV4Style.steel.opacity(0.68)
        }
    }
}

private enum ProgressV4MixRole {
    case primary
    case secondary
    case success
    case successSoft
    case neutral
}

private struct ProgressV4EvidenceItem: Identifiable {
    let date: String
    let title: String
    let detail: String
    let tags: [String]
    let tone: ProgressV4EvidenceTone
    var id: String { "\(date)-\(title)" }
}

private enum ProgressV4EvidenceTone {
    case neutral
    case forming
    case positive

    func markerColor(tint: Color) -> Color {
        switch self {
        case .neutral:
            return ProgressV4Style.steel.opacity(0.62)
        case .forming, .positive:
            return tint
        }
    }

    func tagColor(tint: Color) -> Color {
        switch self {
        case .neutral:
            return ProgressV4Style.steel
        case .forming, .positive:
            return tint
        }
    }
}

private enum ProgressV4Style {
    static let background = hex(0x05070A)
    static let surfaceDeep = hex(0x080B10)
    static let surface = hex(0x10141A)
    static let surfaceSecondary = hex(0x151A21)
    static let controlDeep = hex(0x0C1016)
    static let glassSurface = hex(0x111821).opacity(0.82)
    static let plot = hex(0x070A0F)
    static let heroBottom = hex(0x0A1015)
    static let track = hex(0x2A323B)
    static let border = Color.white.opacity(0.08)
    static let borderStrong = Color.white.opacity(0.14)
    static let grid = Color.white.opacity(0.06)
    static let steel = hex(0xAAB7C7)
    static let signal = hex(0x69D7CE)
    static let success = STRQColors.successGreen
    static let amber = hex(0xD4B86A)

    private static func hex(_ value: UInt, opacity: Double = 1) -> Color {
        Color(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: opacity
        )
    }
}

private struct ProgressV4HybridCandidateView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProgressV4HybridCandidateView()
                .previewDisplayName("Progress V4 Hybrid Candidate")
        }
    }
}
#endif
