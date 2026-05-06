import SwiftUI

#if DEBUG
struct ProgressV2PrototypeView: View {
    @State private var selectedState: ProgressV2PrototypeState = .baseline

    var body: some View {
        ScrollView {
            ProgressV2PrototypeContent(selectedState: $selectedState)
                .padding(.horizontal, STRQSpacing.md)
                .padding(.top, STRQSpacing.lg)
                .padding(.bottom, STRQSpacing.xxl)
        }
        .background(ProgressV2Palette.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

private struct ProgressV2PrototypeContent: View {
    @Binding var selectedState: ProgressV2PrototypeState

    private var data: ProgressV2PrototypeDemoData {
        selectedState.demoData
    }

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.md) {
            ProgressV2Header()
            ProgressV2StateSelector(selectedState: $selectedState)
            ProgressV2Hero(data: data)
            ProgressV2ProofArea(data: data)
            ProgressV2RhythmModule(data: data)
            ProgressV2TrendModule(data: data)
            ProgressV2DistributionModule(data: data)
            ProgressV2EvidenceModule(data: data)
        }
        .frame(maxWidth: 430)
        .frame(maxWidth: .infinity)
    }
}

private struct ProgressV2Header: View {
    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.xs) {
            HStack(spacing: STRQSpacing.xs) {
                Text("Progress V2 Prototype")
                    .font(STRQTypography.headingSmall)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: STRQSpacing.xs)

                Text("DEBUG")
                    .font(STRQTypography.micro)
                    .foregroundStyle(ProgressV2Palette.accent)
                    .padding(.horizontal, STRQSpacing.xs)
                    .padding(.vertical, 5)
                    .background(ProgressV2Palette.accent.opacity(0.12), in: Capsule())
                    .overlay(Capsule().strokeBorder(ProgressV2Palette.accent.opacity(0.32), lineWidth: 1))
            }

            Text("Prototype data, not connected to workout history.")
                .font(STRQTypography.caption)
                .foregroundStyle(STRQColors.mutedText)
                .lineLimit(2)
                .minimumScaleFactor(0.78)
        }
    }
}

private struct ProgressV2StateSelector: View {
    @Binding var selectedState: ProgressV2PrototypeState

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ProgressV2PrototypeState.allCases) { state in
                Button {
                    withAnimation(.easeInOut(duration: 0.22)) {
                        selectedState = state
                    }
                } label: {
                    VStack(spacing: 2) {
                        Text(state.title)
                            .font(STRQTypography.labelSmall)
                            .foregroundStyle(selectedState == state ? STRQColors.primaryText : STRQColors.secondaryText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)

                        Text(state.workoutLabel)
                            .font(STRQTypography.micro)
                            .foregroundStyle(selectedState == state ? ProgressV2Palette.accent : STRQColors.mutedText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 48)
                    .background(
                        selectedState == state ? ProgressV2Palette.controlSelected : Color.clear,
                        in: .rect(cornerRadius: STRQRadii.md)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(ProgressV2Palette.control, in: .rect(cornerRadius: STRQRadii.lg))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.lg, style: .continuous)
                .strokeBorder(ProgressV2Palette.border, lineWidth: 1)
        )
    }
}

private struct ProgressV2Hero: View {
    let data: ProgressV2PrototypeDemoData

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.md) {
            HStack(alignment: .top, spacing: STRQSpacing.md) {
                VStack(alignment: .leading, spacing: STRQSpacing.xs) {
                    Text(data.maturityLabel.uppercased())
                        .font(STRQTypography.micro)
                        .foregroundStyle(data.state.tint)
                        .padding(.horizontal, STRQSpacing.xs)
                        .padding(.vertical, 5)
                        .background(data.state.tint.opacity(0.12), in: Capsule())
                        .overlay(Capsule().strokeBorder(data.state.tint.opacity(0.32), lineWidth: 1))

                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text("\(data.workouts)")
                            .font(STRQTypography.metricLarge)
                            .foregroundStyle(STRQColors.primaryText)
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.62)

                        Text(data.workoutUnit)
                            .font(STRQTypography.bodySmallMedium)
                            .foregroundStyle(STRQColors.secondaryText)
                            .padding(.bottom, 7)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }

                    Text(data.heroTitle)
                        .font(STRQTypography.cardTitle)
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)
                }

                Spacer(minLength: STRQSpacing.xs)

                ProgressV2MaturityRing(
                    value: data.maturityProgress,
                    label: data.state.shortTitle,
                    tint: data.state.tint
                )
            }

            ProgressV2HeroChart(
                values: data.heroTrend,
                tint: data.state.tint,
                isBaseline: data.state == .baseline
            )
            .frame(height: 154)

            HStack(spacing: STRQSpacing.xs) {
                ForEach(data.heroSignals) { signal in
                    ProgressV2SignalPill(signal: signal, tint: data.state.tint)
                }
            }
        }
        .padding(STRQSpacing.lg)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [ProgressV2Palette.heroTop, ProgressV2Palette.heroBottom],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                ProgressV2HeroGrid()
                    .opacity(0.34)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(ProgressV2Palette.borderStrong, lineWidth: 1)
        )
        .overlay(alignment: .top) {
            Capsule()
                .fill(data.state.tint.opacity(0.7))
                .frame(height: 2)
                .padding(.horizontal, STRQSpacing.xl)
        }
    }
}

private struct ProgressV2MaturityRing: View {
    let value: Double
    let label: String
    let tint: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(ProgressV2Palette.track, lineWidth: 9)

            Circle()
                .trim(from: 0, to: clampedValue)
                .stroke(tint, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .shadow(color: tint.opacity(0.26), radius: 10, y: 3)

            VStack(spacing: 2) {
                Text("\(Int(clampedValue * 100))")
                    .font(STRQTypography.metricSmall)
                    .foregroundStyle(STRQColors.primaryText)
                    .monospacedDigit()
                    .lineLimit(1)

                Text(label)
                    .font(STRQTypography.micro)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(STRQSpacing.xs)
        }
        .frame(width: 96, height: 96)
        .accessibilityLabel(Text("\(label) maturity \(Int(clampedValue * 100)) percent"))
    }

    private var clampedValue: Double {
        min(max(value, 0), 1)
    }
}

private struct ProgressV2HeroChart: View {
    let values: [Double]
    let tint: Color
    let isBaseline: Bool

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)
            let points = normalizedPoints(in: CGSize(width: width, height: height))

            ZStack {
                ProgressV2PlotGrid(rows: 4)

                if isBaseline {
                    ProgressV2BaselineSkeleton(tint: tint)
                } else {
                    areaPath(points: points, height: height)
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.22), tint.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    linePath(points: points)
                        .stroke(tint, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                    ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                        Circle()
                            .fill(ProgressV2Palette.heroBottom)
                            .frame(width: 10, height: 10)
                            .overlay(Circle().strokeBorder(tint, lineWidth: 2))
                            .position(point)
                    }
                }
            }
        }
        .padding(STRQSpacing.sm)
        .background(ProgressV2Palette.plot, in: .rect(cornerRadius: STRQRadii.lg))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.lg, style: .continuous)
                .strokeBorder(ProgressV2Palette.border, lineWidth: 1)
        )
    }

    private func normalizedPoints(in size: CGSize) -> [CGPoint] {
        guard values.count > 1 else { return [] }
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 1
        let span = max(maxValue - minValue, 0.01)
        let step = size.width / CGFloat(values.count - 1)
        return values.enumerated().map { index, value in
            let x = CGFloat(index) * step
            let ratio = (value - minValue) / span
            let y = (1 - CGFloat(ratio)) * (size.height - 18) + 9
            return CGPoint(x: x, y: y)
        }
    }

    private func linePath(points: [CGPoint]) -> Path {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: first)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
        }
    }

    private func areaPath(points: [CGPoint], height: CGFloat) -> Path {
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

private struct ProgressV2HeroGrid: View {
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
            .stroke(STRQColors.white.opacity(0.08), lineWidth: 1)
        }
        .clipShape(.rect(cornerRadius: 30))
    }
}

private struct ProgressV2BaselineSkeleton: View {
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)
            let count = 9
            let step = width / CGFloat(count - 1)

            ZStack {
                ForEach(0..<count, id: \.self) { index in
                    let x = CGFloat(index) * step
                    let y = height * (0.34 + CGFloat((index % 3)) * 0.12)
                    Circle()
                        .strokeBorder(tint.opacity(index < 3 ? 0.5 : 0.18), lineWidth: 2)
                        .frame(width: 16, height: 16)
                        .position(x: x, y: y)
                }

                Path { path in
                    path.move(to: CGPoint(x: 0, y: height * 0.72))
                    path.addLine(to: CGPoint(x: width, y: height * 0.72))
                }
                .stroke(tint.opacity(0.26), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [6, 7]))
            }
        }
    }
}

private struct ProgressV2SignalPill: View {
    let signal: ProgressV2Signal
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(signal.value)
                .font(STRQTypography.labelMedium)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(signal.label)
                .font(STRQTypography.micro)
                .foregroundStyle(STRQColors.mutedText)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, STRQSpacing.sm)
        .padding(.vertical, STRQSpacing.xs)
        .background(tint.opacity(0.08), in: .rect(cornerRadius: STRQRadii.md))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                .strokeBorder(tint.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct ProgressV2ProofArea: View {
    let data: ProgressV2PrototypeDemoData

    var body: some View {
        HStack(alignment: .top, spacing: STRQSpacing.sm) {
            ProgressV2ConfidencePanel(data: data)

            VStack(spacing: STRQSpacing.sm) {
                ForEach(data.proofMetrics) { metric in
                    ProgressV2ProofMetricTile(metric: metric, tint: data.state.tint)
                }
            }
        }
    }
}

private struct ProgressV2ConfidencePanel: View {
    let data: ProgressV2PrototypeDemoData

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            Text("Proof Confidence")
                .font(STRQTypography.labelSmall)
                .foregroundStyle(STRQColors.secondaryText)

            Spacer(minLength: 0)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(data.confidenceValue)
                    .font(STRQTypography.metricMedium)
                    .foregroundStyle(STRQColors.primaryText)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)

                Text(data.confidenceUnit)
                    .font(STRQTypography.bodySmallMedium)
                    .foregroundStyle(STRQColors.secondaryText)
                    .padding(.bottom, 4)
            }

            ProgressV2MiniBars(values: data.confidenceBars, tint: data.state.tint)
                .frame(height: 54)

            Text(data.confidenceCaption)
                .font(STRQTypography.caption)
                .foregroundStyle(STRQColors.mutedText)
                .lineLimit(2)
                .minimumScaleFactor(0.74)
        }
        .frame(maxWidth: .infinity, minHeight: 184, alignment: .leading)
        .padding(STRQSpacing.md)
        .background(ProgressV2Palette.surface, in: .rect(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(ProgressV2Palette.border, lineWidth: 1)
        )
    }
}

private struct ProgressV2ProofMetricTile: View {
    let metric: ProgressV2ProofMetric
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.xs) {
            HStack(spacing: STRQSpacing.xs) {
                Circle()
                    .fill(metric.tone.color.opacity(0.18))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Circle()
                            .strokeBorder(metric.tone.color.opacity(0.42), lineWidth: 1)
                    )
                    .overlay {
                        Circle()
                            .fill(metric.tone.color)
                            .frame(width: 7, height: 7)
                    }

                Spacer(minLength: STRQSpacing.xs)

                Text(metric.value)
                    .font(STRQTypography.labelMedium)
                    .foregroundStyle(STRQColors.primaryText)
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Text(metric.title)
                .font(STRQTypography.caption)
                .foregroundStyle(STRQColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text(metric.detail)
                .font(STRQTypography.micro)
                .foregroundStyle(STRQColors.mutedText)
                .lineLimit(2)
                .minimumScaleFactor(0.68)
        }
        .frame(maxWidth: .infinity, minHeight: 88, alignment: .topLeading)
        .padding(STRQSpacing.sm)
        .background(ProgressV2Palette.surfaceSecondary, in: .rect(cornerRadius: STRQRadii.lg))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.lg, style: .continuous)
                .strokeBorder(tint.opacity(0.16), lineWidth: 1)
        )
    }
}

private struct ProgressV2MiniBars: View {
    let values: [Double]
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            let height = max(proxy.size.height, 1)

            HStack(alignment: .bottom, spacing: 5) {
                ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(index == values.count - 1 ? tint : tint.opacity(0.28 + Double(index % 3) * 0.12))
                        .frame(height: max(5, height * CGFloat(min(max(value, 0), 1))))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
    }
}

private struct ProgressV2RhythmModule: View {
    let data: ProgressV2PrototypeDemoData

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)

    var body: some View {
        ProgressV2ModuleShell(title: "Training Rhythm", eyebrow: data.rhythmEyebrow, tint: data.state.tint) {
            VStack(spacing: STRQSpacing.sm) {
                HStack {
                    ForEach(Array(["M", "T", "W", "T", "F", "S", "S"].enumerated()), id: \.offset) { _, label in
                        Text(label)
                            .font(STRQTypography.micro)
                            .foregroundStyle(STRQColors.mutedText)
                            .frame(maxWidth: .infinity)
                    }
                }

                LazyVGrid(columns: columns, spacing: 6) {
                    ForEach(data.rhythmDays) { day in
                        ProgressV2RhythmCell(day: day, tint: data.state.tint)
                    }
                }

                HStack(spacing: STRQSpacing.sm) {
                    ProgressV2LegendDot(color: data.state.tint, label: "Completed")
                    ProgressV2LegendDot(color: ProgressV2Palette.track, label: "Open")
                    Spacer(minLength: 0)
                    Text(data.rhythmSummary)
                        .font(STRQTypography.micro)
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.68)
                }
            }
        }
    }
}

private struct ProgressV2RhythmCell: View {
    let day: ProgressV2RhythmDay
    let tint: Color

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(day.status.background(tint: tint))

            if day.status == .completed {
                Circle()
                    .trim(from: 0, to: max(0.08, day.intensity))
                    .stroke(tint, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .padding(7)
            } else if day.status == .forming {
                Circle()
                    .stroke(tint.opacity(0.28), style: StrokeStyle(lineWidth: 2, dash: [4, 4]))
                    .padding(8)
            } else {
                Circle()
                    .stroke(STRQColors.gray600.opacity(0.45), lineWidth: 2)
                    .padding(9)
            }

            Text(day.label)
                .font(STRQTypography.micro)
                .foregroundStyle(day.status == .open ? STRQColors.mutedText : STRQColors.primaryText)
                .monospacedDigit()
        }
        .frame(height: 38)
        .accessibilityLabel(Text("Prototype rhythm day \(day.label) \(day.status.accessibilityLabel)"))
    }
}

private struct ProgressV2TrendModule: View {
    let data: ProgressV2PrototypeDemoData

    var body: some View {
        ProgressV2ModuleShell(title: "Strength Signal", eyebrow: data.trendEyebrow, tint: data.state.tint) {
            VStack(alignment: .leading, spacing: STRQSpacing.sm) {
                HStack(alignment: .firstTextBaseline, spacing: STRQSpacing.xs) {
                    Text(data.trendValue)
                        .font(STRQTypography.metricSmall)
                        .foregroundStyle(STRQColors.primaryText)
                        .monospacedDigit()
                        .lineLimit(1)

                    Text(data.trendUnit)
                        .font(STRQTypography.caption)
                        .foregroundStyle(STRQColors.secondaryText)

                    Spacer(minLength: STRQSpacing.xs)

                    Text(data.trendTag)
                        .font(STRQTypography.micro)
                        .foregroundStyle(data.state.tint)
                        .padding(.horizontal, STRQSpacing.xs)
                        .padding(.vertical, 5)
                        .background(data.state.tint.opacity(0.1), in: Capsule())
                }

                ProgressV2LineAreaChart(
                    values: data.strengthTrend,
                    tint: data.state.tint,
                    isSkeleton: data.state == .baseline
                )
                .frame(height: 152)

                ProgressV2VolumeBars(values: data.volumeBars, tint: data.state.tint)
                    .frame(height: 42)
            }
        }
    }
}

private struct ProgressV2LineAreaChart: View {
    let values: [Double]
    let tint: Color
    let isSkeleton: Bool

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let points = normalizedPoints(in: size)

            ZStack {
                ProgressV2PlotGrid(rows: 3)

                if isSkeleton || points.count < 2 {
                    ProgressV2BaselineSkeleton(tint: tint)
                        .padding(.horizontal, STRQSpacing.md)
                } else {
                    areaPath(points: points, height: size.height)
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.2), tint.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    linePath(points: points)
                        .stroke(tint, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                    if let last = points.last {
                        Circle()
                            .fill(tint)
                            .frame(width: 11, height: 11)
                            .overlay(Circle().strokeBorder(ProgressV2Palette.plot, lineWidth: 3))
                            .position(last)
                    }
                }
            }
        }
        .padding(STRQSpacing.sm)
        .background(ProgressV2Palette.plot, in: .rect(cornerRadius: STRQRadii.lg))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.lg, style: .continuous)
                .strokeBorder(ProgressV2Palette.border, lineWidth: 1)
        )
    }

    private func normalizedPoints(in size: CGSize) -> [CGPoint] {
        guard values.count > 1 else { return [] }
        let minValue = values.min() ?? 0
        let maxValue = values.max() ?? 1
        let span = max(maxValue - minValue, 0.01)
        let step = size.width / CGFloat(values.count - 1)
        return values.enumerated().map { index, value in
            let x = CGFloat(index) * step
            let ratio = (value - minValue) / span
            let y = (1 - CGFloat(ratio)) * (size.height - 20) + 10
            return CGPoint(x: x, y: y)
        }
    }

    private func linePath(points: [CGPoint]) -> Path {
        Path { path in
            guard let first = points.first else { return }
            path.move(to: first)
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
        }
    }

    private func areaPath(points: [CGPoint], height: CGFloat) -> Path {
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

private struct ProgressV2VolumeBars: View {
    let values: [Double]
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            let height = max(proxy.size.height, 1)

            HStack(alignment: .bottom, spacing: 7) {
                ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(value > 0 ? tint.opacity(0.24 + min(value, 1) * 0.56) : ProgressV2Palette.track)
                            .frame(height: max(4, height * CGFloat(min(max(value, 0), 1))))

                        if index % 2 == 0 {
                            Circle()
                                .fill(value > 0 ? tint.opacity(0.78) : STRQColors.gray700)
                                .frame(width: 4, height: 4)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                }
            }
        }
    }
}

private struct ProgressV2DistributionModule: View {
    let data: ProgressV2PrototypeDemoData

    var body: some View {
        ProgressV2ModuleShell(title: "Muscle Balance", eyebrow: data.distributionEyebrow, tint: data.state.tint) {
            VStack(spacing: STRQSpacing.sm) {
                ProgressV2DistributionBody(groups: data.muscleDistribution, tint: data.state.tint)
                    .frame(height: 188)

                VStack(spacing: STRQSpacing.xs) {
                    ForEach(data.muscleDistribution) { group in
                        ProgressV2DistributionRow(group: group, tint: data.state.tint)
                    }
                }
            }
        }
    }
}

private struct ProgressV2DistributionBody: View {
    let groups: [ProgressV2MuscleGroup]
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)
            let center = width / 2

            ZStack {
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .fill(ProgressV2Palette.plot)

                Path { path in
                    path.move(to: CGPoint(x: center, y: 18))
                    path.addCurve(
                        to: CGPoint(x: center, y: height - 18),
                        control1: CGPoint(x: center - 28, y: height * 0.34),
                        control2: CGPoint(x: center + 28, y: height * 0.64)
                    )
                }
                .stroke(STRQColors.white.opacity(0.12), style: StrokeStyle(lineWidth: 3, lineCap: .round))

                ForEach(Array(groups.enumerated()), id: \.element.id) { index, group in
                    let y = CGFloat(index + 1) / CGFloat(groups.count + 1) * height
                    let laneWidth = min(width * 0.36, 128)
                    let leftValue = laneWidth * CGFloat(group.left)
                    let rightValue = laneWidth * CGFloat(group.right)

                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(tint.opacity(0.18 + group.left * 0.52))
                        .frame(width: max(12, leftValue), height: 14)
                        .position(x: center - 18 - max(6, leftValue / 2), y: y)

                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(tint.opacity(0.18 + group.right * 0.52))
                        .frame(width: max(12, rightValue), height: 14)
                        .position(x: center + 18 + max(6, rightValue / 2), y: y)

                    Text(group.shortLabel)
                        .font(STRQTypography.micro)
                        .foregroundStyle(STRQColors.secondaryText)
                        .position(x: center, y: y)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 36, style: .continuous)
                    .strokeBorder(ProgressV2Palette.border, lineWidth: 1)
            )
        }
    }
}

private struct ProgressV2DistributionRow: View {
    let group: ProgressV2MuscleGroup
    let tint: Color

    var body: some View {
        HStack(spacing: STRQSpacing.sm) {
            Text(group.title)
                .font(STRQTypography.caption)
                .foregroundStyle(STRQColors.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
                .frame(width: 72, alignment: .leading)

            GeometryReader { proxy in
                let width = proxy.size.width

                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(ProgressV2Palette.track)
                        .frame(height: 8)

                    Capsule()
                        .fill(tint.opacity(group.value > 0 ? 0.8 : 0.18))
                        .frame(width: max(5, width * CGFloat(min(max(group.value, 0), 1))), height: 8)
                }
            }
            .frame(height: 10)

            Text(group.valueLabel)
                .font(STRQTypography.micro)
                .foregroundStyle(group.value > 0 ? tint : STRQColors.mutedText)
                .monospacedDigit()
                .frame(width: 38, alignment: .trailing)
        }
    }
}

private struct ProgressV2EvidenceModule: View {
    let data: ProgressV2PrototypeDemoData

    var body: some View {
        ProgressV2ModuleShell(title: "Recent Evidence", eyebrow: data.evidenceEyebrow, tint: data.state.tint) {
            VStack(spacing: 0) {
                ForEach(Array(data.evidence.enumerated()), id: \.element.id) { index, item in
                    ProgressV2EvidenceRow(
                        item: item,
                        tint: data.state.tint,
                        isFirst: index == 0,
                        isLast: index == data.evidence.count - 1
                    )
                }
            }
        }
    }
}

private struct ProgressV2EvidenceRow: View {
    let item: ProgressV2EvidenceItem
    let tint: Color
    let isFirst: Bool
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: STRQSpacing.sm) {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(isFirst ? Color.clear : ProgressV2Palette.border)
                    .frame(width: 2, height: 10)

                Circle()
                    .fill(item.kind.color(tint: tint))
                    .frame(width: 11, height: 11)
                    .overlay(Circle().strokeBorder(STRQColors.white.opacity(0.28), lineWidth: 1))

                Rectangle()
                    .fill(isLast ? Color.clear : ProgressV2Palette.border)
                    .frame(width: 2)
            }
            .frame(width: 18)

            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .firstTextBaseline, spacing: STRQSpacing.xs) {
                    Text(item.title)
                        .font(STRQTypography.bodySmallMedium)
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Spacer(minLength: STRQSpacing.xs)

                    Text(item.date)
                        .font(STRQTypography.micro)
                        .foregroundStyle(STRQColors.mutedText)
                        .lineLimit(1)
                }

                Text(item.detail)
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.74)

                if let tag = item.tag {
                    Text(tag)
                        .font(STRQTypography.micro)
                        .foregroundStyle(item.kind.color(tint: tint))
                        .padding(.horizontal, STRQSpacing.xs)
                        .padding(.vertical, 4)
                        .background(item.kind.color(tint: tint).opacity(0.1), in: Capsule())
                }
            }
            .padding(.bottom, isLast ? 0 : STRQSpacing.sm)
        }
    }
}

private struct ProgressV2ModuleShell<Content: View>: View {
    let title: String
    let eyebrow: String
    let tint: Color
    let content: Content

    init(title: String, eyebrow: String, tint: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.eyebrow = eyebrow
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.md) {
            HStack(alignment: .firstTextBaseline, spacing: STRQSpacing.sm) {
                Text(title)
                    .font(STRQTypography.cardTitle)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Spacer(minLength: STRQSpacing.xs)

                Text(eyebrow)
                    .font(STRQTypography.micro)
                    .foregroundStyle(tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.66)
            }

            content
        }
        .padding(STRQSpacing.md)
        .background(ProgressV2Palette.surface, in: .rect(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(ProgressV2Palette.border, lineWidth: 1)
        )
    }
}

private struct ProgressV2PlotGrid: View {
    let rows: Int

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0...rows, id: \.self) { _ in
                Rectangle()
                    .fill(STRQColors.white.opacity(0.07))
                    .frame(height: 1)
                if rows > 0 {
                    Spacer(minLength: 0)
                }
            }
        }
    }
}

private struct ProgressV2LegendDot: View {
    let color: Color
    let label: String

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(STRQTypography.micro)
                .foregroundStyle(STRQColors.mutedText)
                .lineLimit(1)
        }
    }
}

private enum ProgressV2PrototypeState: String, CaseIterable, Identifiable {
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

    var shortTitle: String {
        switch self {
        case .baseline:
            return "Base"
        case .forming:
            return "Form"
        case .established:
            return "Proof"
        }
    }

    var workoutLabel: String {
        switch self {
        case .baseline:
            return "0 workouts"
        case .forming:
            return "3 workouts"
        case .established:
            return "24 workouts"
        }
    }

    var tint: Color {
        switch self {
        case .baseline:
            return ProgressV2Palette.steel
        case .forming:
            return ProgressV2Palette.amber
        case .established:
            return ProgressV2Palette.accent
        }
    }

    var demoData: ProgressV2PrototypeDemoData {
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

private struct ProgressV2PrototypeDemoData {
    let state: ProgressV2PrototypeState
    let workouts: Int
    let maturityProgress: Double
    let maturityLabel: String
    let heroTitle: String
    let heroTrend: [Double]
    let heroSignals: [ProgressV2Signal]
    let confidenceValue: String
    let confidenceUnit: String
    let confidenceCaption: String
    let confidenceBars: [Double]
    let proofMetrics: [ProgressV2ProofMetric]
    let rhythmDays: [ProgressV2RhythmDay]
    let rhythmEyebrow: String
    let rhythmSummary: String
    let trendEyebrow: String
    let trendValue: String
    let trendUnit: String
    let trendTag: String
    let strengthTrend: [Double]
    let volumeBars: [Double]
    let distributionEyebrow: String
    let muscleDistribution: [ProgressV2MuscleGroup]
    let evidenceEyebrow: String
    let evidence: [ProgressV2EvidenceItem]

    var workoutUnit: String {
        workouts == 1 ? "workout" : "workouts"
    }

    // Prototype-only demo data. This intentionally stays local and is not wired to app state.
    static let baseline = ProgressV2PrototypeDemoData(
        state: .baseline,
        workouts: 0,
        maturityProgress: 0.08,
        maturityLabel: "Baseline forming",
        heroTitle: "STRQ is waiting for the first training evidence.",
        heroTrend: [],
        heroSignals: [
            .init(value: "0", label: "sessions"),
            .init(value: "0/3", label: "anchors"),
            .init(value: "open", label: "rhythm")
        ],
        confidenceValue: "8",
        confidenceUnit: "%",
        confidenceCaption: "Only the proof scaffold is visible until workouts exist.",
        confidenceBars: [0.08, 0.1, 0.06, 0.12, 0.09],
        proofMetrics: [
            .init(title: "Sessions", value: "0", detail: "No completed workouts", tone: .neutral),
            .init(title: "Consistency", value: "--", detail: "No rhythm yet", tone: .neutral)
        ],
        rhythmDays: ProgressV2DemoFactory.rhythm(completed: [], forming: [8, 15, 22]),
        rhythmEyebrow: "no pattern yet",
        rhythmSummary: "baseline open",
        trendEyebrow: "no conclusion",
        trendValue: "--",
        trendUnit: "signal",
        trendTag: "needs workouts",
        strengthTrend: [],
        volumeBars: Array(repeating: 0.0, count: 12),
        distributionEyebrow: "not enough data",
        muscleDistribution: ProgressV2DemoFactory.muscles(values: [0, 0, 0, 0, 0]),
        evidenceEyebrow: "empty",
        evidence: [
            .init(title: "No completed sessions", date: "Now", detail: "This prototype keeps the baseline honest.", tag: "awaiting evidence", kind: .neutral),
            .init(title: "Trend locked", date: "0/3", detail: "Strength and distribution stay visual but inactive.", tag: nil, kind: .neutral)
        ]
    )

    static let forming = ProgressV2PrototypeDemoData(
        state: .forming,
        workouts: 3,
        maturityProgress: 0.42,
        maturityLabel: "Pattern forming",
        heroTitle: "Early training evidence is visible, but conclusions stay cautious.",
        heroTrend: [0.22, 0.38, 0.33, 0.47, 0.44],
        heroSignals: [
            .init(value: "3", label: "sessions"),
            .init(value: "2", label: "anchors"),
            .init(value: "2w", label: "rhythm")
        ],
        confidenceValue: "42",
        confidenceUnit: "%",
        confidenceCaption: "Enough to show early signal, not enough to certify trend.",
        confidenceBars: [0.24, 0.38, 0.32, 0.44, 0.42],
        proofMetrics: [
            .init(title: "Sessions", value: "3", detail: "First week captured", tone: .forming),
            .init(title: "Streak", value: "2", detail: "Training days close", tone: .forming)
        ],
        rhythmDays: ProgressV2DemoFactory.rhythm(completed: [3, 6, 12], forming: [17, 20, 25]),
        rhythmEyebrow: "early rhythm",
        rhythmSummary: "3 completed",
        trendEyebrow: "early range",
        trendValue: "+2",
        trendUnit: "anchors",
        trendTag: "forming",
        strengthTrend: [84, 87, 86, 90],
        volumeBars: [0, 0.22, 0.0, 0.36, 0.0, 0.48, 0, 0.16, 0, 0.32, 0, 0.0],
        distributionEyebrow: "sample only",
        muscleDistribution: ProgressV2DemoFactory.muscles(values: [0.32, 0.2, 0.16, 0.28, 0.12]),
        evidenceEyebrow: "3 items",
        evidence: [
            .init(title: "Upper Strength", date: "Mon", detail: "Bench and row anchors logged.", tag: "signal started", kind: .forming),
            .init(title: "Lower Strength", date: "Thu", detail: "Squat pattern entered the baseline.", tag: nil, kind: .forming),
            .init(title: "Full Body", date: "Sat", detail: "Third session gives rhythm a first shape.", tag: "consistency forming", kind: .forming)
        ]
    )

    static let established = ProgressV2PrototypeDemoData(
        state: .established,
        workouts: 24,
        maturityProgress: 0.88,
        maturityLabel: "Proof established",
        heroTitle: "Training evidence now shows progress, rhythm, and balance.",
        heroTrend: [0.32, 0.39, 0.43, 0.51, 0.49, 0.61, 0.68, 0.76, 0.73, 0.84],
        heroSignals: [
            .init(value: "24", label: "sessions"),
            .init(value: "+11%", label: "volume"),
            .init(value: "86%", label: "rhythm")
        ],
        confidenceValue: "88",
        confidenceUnit: "%",
        confidenceCaption: "A stable window exists for trend and distribution review.",
        confidenceBars: [0.52, 0.62, 0.68, 0.74, 0.82, 0.88],
        proofMetrics: [
            .init(title: "Consistency", value: "6/7", detail: "Weekly rhythm held", tone: .established),
            .init(title: "Recovery", value: "72", detail: "Training context ok", tone: .established)
        ],
        rhythmDays: ProgressV2DemoFactory.rhythm(completed: [1, 3, 5, 8, 10, 12, 15, 17, 19, 22, 24, 26, 29, 31, 33], forming: [35]),
        rhythmEyebrow: "stable rhythm",
        rhythmSummary: "15 active days",
        trendEyebrow: "visible trend",
        trendValue: "+11",
        trendUnit: "% volume",
        trendTag: "uptrend",
        strengthTrend: [92, 94, 96, 95, 99, 102, 105, 107, 110, 113],
        volumeBars: [0.42, 0.58, 0.45, 0.68, 0.52, 0.76, 0.64, 0.8, 0.7, 0.86, 0.74, 0.92],
        distributionEyebrow: "demo balance",
        muscleDistribution: ProgressV2DemoFactory.muscles(values: [0.82, 0.74, 0.68, 0.78, 0.58]),
        evidenceEyebrow: "recent proof",
        evidence: [
            .init(title: "Upper Strength", date: "Apr 29", detail: "Top set improved while volume stayed controlled.", tag: "+4% estimated strength", kind: .established),
            .init(title: "Lower Power", date: "May 01", detail: "Leg volume returned near the four-week average.", tag: "balance recovered", kind: .established),
            .init(title: "Pull Focus", date: "May 04", detail: "Back work completed the weekly distribution.", tag: "coverage filled", kind: .established),
            .init(title: "Recovery Slot", date: "May 05", detail: "Low-load work preserved the consistency rhythm.", tag: nil, kind: .neutral)
        ]
    )
}

private enum ProgressV2DemoFactory {
    static func rhythm(completed: [Int], forming: [Int]) -> [ProgressV2RhythmDay] {
        (1...35).map { index in
            let status: ProgressV2RhythmStatus
            let intensity: Double
            if completed.contains(index) {
                status = .completed
                intensity = 0.38 + Double((index * 17) % 52) / 100.0
            } else if forming.contains(index) {
                status = .forming
                intensity = 0.18
            } else {
                status = .open
                intensity = 0
            }
            return ProgressV2RhythmDay(index: index, label: "\(index)", intensity: intensity, status: status)
        }
    }

    static func muscles(values: [Double]) -> [ProgressV2MuscleGroup] {
        let titles = ["Push", "Pull", "Core", "Legs", "Posterior"]
        let shorts = ["P", "B", "C", "L", "H"]
        return zip(titles.indices, values).map { index, value in
            ProgressV2MuscleGroup(
                title: titles[index],
                shortLabel: shorts[index],
                value: value,
                left: max(0.05, value * (index.isMultiple(of: 2) ? 0.86 : 0.72)),
                right: max(0.05, value * (index.isMultiple(of: 2) ? 0.74 : 0.9))
            )
        }
    }
}

private struct ProgressV2Signal: Identifiable {
    let value: String
    let label: String

    var id: String { "\(value)-\(label)" }
}

private struct ProgressV2ProofMetric: Identifiable {
    let title: String
    let value: String
    let detail: String
    let tone: ProgressV2MetricTone

    var id: String { title }
}

private enum ProgressV2MetricTone {
    case neutral
    case forming
    case established

    var color: Color {
        switch self {
        case .neutral:
            return ProgressV2Palette.steel
        case .forming:
            return ProgressV2Palette.amber
        case .established:
            return ProgressV2Palette.accent
        }
    }
}

private struct ProgressV2RhythmDay: Identifiable {
    let index: Int
    let label: String
    let intensity: Double
    let status: ProgressV2RhythmStatus

    var id: Int { index }
}

private enum ProgressV2RhythmStatus: Equatable {
    case open
    case forming
    case completed

    func background(tint: Color) -> Color {
        switch self {
        case .open:
            return ProgressV2Palette.plot
        case .forming:
            return tint.opacity(0.08)
        case .completed:
            return tint.opacity(0.14)
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .open:
            return "open"
        case .forming:
            return "forming"
        case .completed:
            return "completed"
        }
    }
}

private struct ProgressV2MuscleGroup: Identifiable {
    let title: String
    let shortLabel: String
    let value: Double
    let left: Double
    let right: Double

    var id: String { title }

    var valueLabel: String {
        value > 0 ? "\(Int(value * 100))%" : "--"
    }
}

private struct ProgressV2EvidenceItem: Identifiable {
    let title: String
    let date: String
    let detail: String
    let tag: String?
    let kind: ProgressV2EvidenceKind

    var id: String { "\(date)-\(title)" }
}

private enum ProgressV2EvidenceKind {
    case neutral
    case forming
    case established

    func color(tint: Color) -> Color {
        switch self {
        case .neutral:
            return ProgressV2Palette.steel
        case .forming:
            return ProgressV2Palette.amber
        case .established:
            return tint
        }
    }
}

private enum ProgressV2Palette {
    static let background = hex(0x050608)
    static let surface = hex(0x111317)
    static let surfaceSecondary = hex(0x171A20)
    static let control = hex(0x181B21)
    static let controlSelected = hex(0x252A32)
    static let heroTop = hex(0x171B21)
    static let heroBottom = hex(0x080A0E)
    static let plot = hex(0x0B0E13)
    static let track = hex(0x313742)
    static let border = Color.white.opacity(0.08)
    static let borderStrong = Color.white.opacity(0.14)
    static let steel = hex(0xAAB7C7)
    static let accent = hex(0x21D4C8)
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

private struct ProgressV2PrototypeView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressV2PrototypeView()
            .previewDisplayName("Progress V2 Prototype")
    }
}
#endif
