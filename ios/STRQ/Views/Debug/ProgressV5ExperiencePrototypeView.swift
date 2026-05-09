import SwiftUI

struct ProgressV5ExperiencePrototypeView: View {
    @State private var selectedState: ProgressV5ExperienceState = .beginner

    private var scenario: ProgressV5Scenario {
        selectedState.scenario
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: STRQSpacing.md) {
                ProgressV5Header()
                ProgressV5StateControl(selection: $selectedState)
                ProgressV5Hero(scenario: scenario)
                ProgressV5RhythmStory(scenario: scenario)
                ProgressV5NextUnlock(scenario: scenario)
                ProgressV5EvidenceTimeline(scenario: scenario)
                ProgressV5ConfidencePanel(scenario: scenario)
                ProgressV5AnalyticsDoorway(scenario: scenario)
            }
            .frame(maxWidth: 430)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, STRQSpacing.md)
            .padding(.vertical, STRQSpacing.lg)
        }
        .background(ProgressV5Style.background.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
}

private struct ProgressV5Header: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Progress V5")
                .font(STRQTypography.headingSmall)
                .foregroundStyle(STRQColors.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text("A training story surface built around map, rhythm, unlocks, evidence, and confidence.")
                .font(STRQTypography.caption)
                .foregroundStyle(STRQColors.secondaryText)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct ProgressV5StateControl: View {
    @Binding var selection: ProgressV5ExperienceState

    var body: some View {
        HStack(spacing: 4) {
            ForEach(ProgressV5ExperienceState.allCases) { state in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selection = state
                    }
                } label: {
                    VStack(spacing: 2) {
                        Text(state.title)
                            .font(STRQTypography.labelSmall)
                            .foregroundStyle(selection == state ? STRQColors.primaryText : STRQColors.secondaryText)
                            .lineLimit(1)

                        Text(state.caption)
                            .font(STRQTypography.micro)
                            .foregroundStyle(selection == state ? state.tint : STRQColors.mutedText)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, minHeight: 48)
                    .background(selection == state ? state.tint.opacity(0.1) : Color.clear, in: .rect(cornerRadius: STRQRadii.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                            .strokeBorder(selection == state ? state.tint.opacity(0.34) : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(ProgressV5Style.control, in: .rect(cornerRadius: STRQRadii.lg))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.lg, style: .continuous)
                .strokeBorder(ProgressV5Style.border, lineWidth: 1)
        )
    }
}

private struct ProgressV5Hero: View {
    let scenario: ProgressV5Scenario

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.md) {
            HStack(alignment: .top, spacing: STRQSpacing.sm) {
                VStack(alignment: .leading, spacing: 7) {
                    ProgressV5Capsule(text: scenario.heroStatus, tint: scenario.tint)

                    Text(scenario.heroTitle)
                        .font(STRQTypography.headingXS)
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.76)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(scenario.heroMessage)
                        .font(STRQTypography.caption)
                        .foregroundStyle(STRQColors.secondaryText)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: STRQSpacing.xs)

                ProgressV5ConfidenceRing(
                    value: scenario.heroConfidenceValue,
                    label: scenario.confidenceLabel,
                    tint: scenario.tint,
                    icon: scenario.confidenceIcon
                )
            }

            ProgressV5TrainingMap(scenario: scenario)
                .frame(height: scenario.state == .beginner ? 286 : 326)

            HStack(spacing: 0) {
                ProgressV5HeroStat(title: "Workouts", value: scenario.workoutCount, tint: scenario.tint)
                ProgressV5Divider()
                ProgressV5HeroStat(title: "Window", value: scenario.windowLabel, tint: scenario.tint)
                ProgressV5Divider()
                ProgressV5HeroStat(title: "Confidence", value: scenario.confidenceLabel, tint: scenario.tint)
            }
            .padding(.vertical, STRQSpacing.sm)
            .background(ProgressV5Style.glass, in: .rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(ProgressV5Style.borderStrong, lineWidth: 1)
            )
        }
        .padding(STRQSpacing.md)
        .background {
            ZStack {
                LinearGradient(
                    colors: [
                        scenario.tint.opacity(scenario.state == .beginner ? 0.18 : 0.28),
                        ProgressV5Style.stage,
                        ProgressV5Style.surfaceDeep
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                ProgressV5FineGrid()
                    .opacity(0.24)
            }
            .clipShape(.rect(cornerRadius: 30))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .strokeBorder(scenario.tint.opacity(0.3), lineWidth: 1)
        )
        .overlay(alignment: .topLeading) {
            Rectangle()
                .fill(scenario.tint.opacity(0.88))
                .frame(width: scenario.state == .beginner ? 88 : 136, height: 3)
                .padding(.leading, STRQSpacing.lg)
        }
    }
}

private struct ProgressV5TrainingMap: View {
    let scenario: ProgressV5Scenario

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)

            ZStack {
                ProgressV5MapBackdrop(tint: scenario.tint)

                ForEach(scenario.routes) { route in
                    ProgressV5RouteLine(
                        start: scenario.area(for: route.start),
                        end: scenario.area(for: route.end),
                        width: width,
                        height: height,
                        tint: route.tint(scenario: scenario),
                        isLocked: route.isLocked(in: scenario)
                    )
                }

                ForEach(scenario.areas) { area in
                    ProgressV5MapNode(area: area, tint: scenario.tint)
                        .frame(width: area.nodeSize, height: area.nodeSize)
                        .position(x: width * area.x, y: height * area.y)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Training Map")
                        .font(STRQTypography.labelSmall)
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(1)
                    Text(scenario.mapCaption)
                        .font(STRQTypography.micro)
                        .foregroundStyle(STRQColors.mutedText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: min(172, width * 0.46), alignment: .leading)
                .padding(STRQSpacing.sm)
                .background(ProgressV5Style.plot.opacity(0.78), in: .rect(cornerRadius: STRQRadii.md))
                .overlay(
                    RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                        .strokeBorder(ProgressV5Style.border, lineWidth: 1)
                )
                .position(x: width * 0.26, y: height * 0.16)
            }
        }
        .padding(STRQSpacing.xs)
        .background(ProgressV5Style.plot, in: .rect(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(ProgressV5Style.border, lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Training Map showing \(scenario.accessibilityMapSummary)"))
    }
}

private struct ProgressV5MapBackdrop: View {
    let tint: Color

    var body: some View {
        GeometryReader { proxy in
            let width = max(proxy.size.width, 1)
            let height = max(proxy.size.height, 1)

            ZStack {
                Path { path in
                    path.addEllipse(in: CGRect(x: width * 0.12, y: height * 0.1, width: width * 0.76, height: height * 0.72))
                    path.addEllipse(in: CGRect(x: width * 0.28, y: height * 0.23, width: width * 0.44, height: height * 0.42))
                }
                .stroke(tint.opacity(0.12), style: StrokeStyle(lineWidth: 1, dash: [6, 9]))

                Path { path in
                    path.move(to: CGPoint(x: width * 0.5, y: height * 0.08))
                    path.addLine(to: CGPoint(x: width * 0.5, y: height * 0.88))
                    path.move(to: CGPoint(x: width * 0.12, y: height * 0.5))
                    path.addLine(to: CGPoint(x: width * 0.88, y: height * 0.5))
                }
                .stroke(ProgressV5Style.grid, style: StrokeStyle(lineWidth: 1, dash: [3, 8]))
            }
        }
    }
}

private struct ProgressV5RouteLine: View {
    let start: ProgressV5TrainingArea
    let end: ProgressV5TrainingArea
    let width: CGFloat
    let height: CGFloat
    let tint: Color
    let isLocked: Bool

    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: width * start.x, y: height * start.y))
            path.addLine(to: CGPoint(x: width * end.x, y: height * end.y))
        }
        .stroke(
            tint.opacity(isLocked ? 0.22 : 0.52),
            style: StrokeStyle(lineWidth: isLocked ? 1 : 2, lineCap: .round, dash: isLocked ? [5, 7] : [])
        )
    }
}

private struct ProgressV5MapNode: View {
    let area: ProgressV5TrainingArea
    let tint: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(area.state.fill(tint: tint))
                .overlay(
                    Circle()
                        .strokeBorder(area.state.stroke(tint: tint), style: StrokeStyle(lineWidth: 1, dash: area.state == .locked ? [4, 5] : []))
                )
                .shadow(color: area.state.shadow(tint: tint), radius: area.state == .locked ? 0 : 10, y: 4)

            Circle()
                .trim(from: 0, to: area.value)
                .stroke(area.state.accent(tint: tint), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .opacity(area.state == .locked ? 0.2 : 0.95)
                .padding(3)

            VStack(spacing: 4) {
                STRQIconView(area.icon, size: area.isPrimary ? 18 : 15, tint: area.state.iconTint(tint: tint))
                Text(area.title)
                    .font(STRQTypography.micro)
                    .foregroundStyle(area.state.textColor(tint: tint))
                    .lineLimit(1)
                    .minimumScaleFactor(0.64)
            }
            .padding(.horizontal, 5)
        }
        .accessibilityLabel(Text("\(area.title), \(area.state.label)"))
    }
}

private struct ProgressV5RhythmStory: View {
    let scenario: ProgressV5Scenario

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)

    var body: some View {
        ProgressV5AngledPanel(tint: scenario.tint) {
            VStack(alignment: .leading, spacing: STRQSpacing.sm) {
                HStack(alignment: .top, spacing: STRQSpacing.sm) {
                    ProgressV5SectionTitle(icon: .calendar, title: "Rhythm Story", subtitle: scenario.rhythmCaption, tint: scenario.tint)
                    Spacer(minLength: STRQSpacing.xs)
                    Text(scenario.rhythmValue)
                        .font(STRQTypography.labelSmall)
                        .foregroundStyle(scenario.tint)
                        .lineLimit(1)
                        .monospacedDigit()
                }

                LazyVGrid(columns: columns, spacing: 5) {
                    ForEach(scenario.rhythmDays) { day in
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(day.fill(tint: scenario.tint))
                            .frame(height: 24)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .strokeBorder(day.stroke(tint: scenario.tint), lineWidth: 1)
                            )
                            .overlay(alignment: .bottom) {
                                if day.status == .trained {
                                    Capsule()
                                        .fill(scenario.tint)
                                        .frame(width: 13, height: 3)
                                        .padding(.bottom, 4)
                                }
                            }
                            .accessibilityLabel(Text("Rhythm day \(day.index), \(day.status.label)"))
                    }
                }
                .padding(STRQSpacing.sm)
                .background(ProgressV5Style.plot, in: .rect(cornerRadius: 18))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(ProgressV5Style.border, lineWidth: 1)
                )

                HStack(alignment: .bottom, spacing: 7) {
                    ForEach(scenario.weeks) { week in
                        ProgressV5WeekColumn(week: week, tint: scenario.tint)
                    }
                }
                .frame(height: 76)
            }
        }
    }
}

private struct ProgressV5WeekColumn: View {
    let week: ProgressV5Week
    let tint: Color

    var body: some View {
        VStack(spacing: 5) {
            GeometryReader { proxy in
                ZStack(alignment: .bottom) {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(ProgressV5Style.track)
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(week.sessions > 0 ? tint.opacity(week.isCurrent ? 0.92 : 0.54) : ProgressV5Style.steel.opacity(0.14))
                        .frame(height: max(5, proxy.size.height * CGFloat(week.ratio)))
                }
            }
            .frame(height: 42)

            Text(week.label)
                .font(STRQTypography.micro)
                .foregroundStyle(week.isCurrent ? tint : STRQColors.mutedText)
                .lineLimit(1)
            Text("\(week.sessions)")
                .font(STRQTypography.micro)
                .foregroundStyle(STRQColors.secondaryText)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ProgressV5NextUnlock: View {
    let scenario: ProgressV5Scenario

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            ProgressV5SectionTitle(icon: .bolt, title: "Next Unlock", subtitle: scenario.unlockCaption, tint: scenario.tint)

            VStack(spacing: STRQSpacing.xs) {
                ForEach(scenario.unlocks) { unlock in
                    ProgressV5UnlockRow(unlock: unlock, tint: scenario.tint)
                }
            }
        }
        .padding(STRQSpacing.md)
        .background {
            ZStack(alignment: .topTrailing) {
                ProgressV5Style.surface
                Circle()
                    .fill(scenario.tint.opacity(0.12))
                    .frame(width: 126, height: 126)
                    .offset(x: 46, y: -58)
            }
            .clipShape(.rect(cornerRadius: 24))
        }
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(scenario.tint.opacity(0.22), lineWidth: 1)
        )
    }
}

private struct ProgressV5UnlockRow: View {
    let unlock: ProgressV5Unlock
    let tint: Color

    var body: some View {
        HStack(spacing: STRQSpacing.sm) {
            ZStack {
                Circle()
                    .stroke(ProgressV5Style.track, lineWidth: 5)
                Circle()
                    .trim(from: 0, to: unlock.progress)
                    .stroke(unlock.tone.tint(defaultTint: tint), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                STRQIconView(unlock.icon, size: 15, tint: unlock.tone.tint(defaultTint: tint))
            }
            .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(unlock.label)
                        .font(STRQTypography.micro)
                        .foregroundStyle(unlock.tone.tint(defaultTint: tint))
                        .lineLimit(1)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(unlock.tone.tint(defaultTint: tint).opacity(0.1), in: Capsule())

                    Text(unlock.title)
                        .font(STRQTypography.bodySmallMedium)
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }

                Text(unlock.detail)
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(STRQSpacing.sm)
        .background(ProgressV5Style.surfaceSecondary.opacity(0.72), in: .rect(cornerRadius: STRQRadii.md))
        .overlay(
            RoundedRectangle(cornerRadius: STRQRadii.md, style: .continuous)
                .strokeBorder(ProgressV5Style.border, lineWidth: 1)
        )
    }
}

private struct ProgressV5EvidenceTimeline: View {
    let scenario: ProgressV5Scenario

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            ProgressV5SectionTitle(icon: .checklist, title: "Evidence Timeline", subtitle: scenario.evidenceCaption, tint: scenario.tint)

            VStack(spacing: 0) {
                ForEach(scenario.evidence.indices, id: \.self) { index in
                    let item = scenario.evidence[index]
                    ProgressV5EvidenceRow(item: item, tint: scenario.tint, isLast: index == scenario.evidence.count - 1)
                }
            }
        }
        .padding(STRQSpacing.md)
        .background(ProgressV5Style.surfaceDeep, in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(ProgressV5Style.border, lineWidth: 1)
        )
    }
}

private struct ProgressV5EvidenceRow: View {
    let item: ProgressV5EvidenceItem
    let tint: Color
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: STRQSpacing.sm) {
            VStack(spacing: 6) {
                Circle()
                    .fill(item.tone.tint(defaultTint: tint))
                    .frame(width: 8, height: 8)
                    .overlay(Circle().strokeBorder(Color.white.opacity(0.42), lineWidth: 1))
                Rectangle()
                    .fill(isLast ? Color.clear : ProgressV5Style.borderStrong)
                    .frame(width: 1)
            }
            .frame(width: 14)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(item.date)
                        .font(STRQTypography.micro)
                        .foregroundStyle(item.tone.tint(defaultTint: tint))
                        .lineLimit(1)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(item.tone.tint(defaultTint: tint).opacity(0.1), in: Capsule())

                    Text(item.title)
                        .font(STRQTypography.bodySmallMedium)
                        .foregroundStyle(STRQColors.primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }

                Text(item.detail)
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, isLast ? 0 : STRQSpacing.sm)
        }
    }
}

private struct ProgressV5ConfidencePanel: View {
    let scenario: ProgressV5Scenario

    var body: some View {
        VStack(alignment: .leading, spacing: STRQSpacing.sm) {
            ProgressV5SectionTitle(icon: .checkCircle, title: "Confidence State", subtitle: scenario.confidenceCaption, tint: scenario.tint)

            VStack(spacing: STRQSpacing.xs) {
                ForEach(scenario.confidenceItems) { item in
                    HStack(spacing: STRQSpacing.sm) {
                        STRQIconView(item.icon, size: 16, tint: item.tone.tint(defaultTint: scenario.tint))
                            .frame(width: 30, height: 30)
                            .background(item.tone.tint(defaultTint: scenario.tint).opacity(0.1), in: .rect(cornerRadius: 9))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(STRQTypography.bodySmallMedium)
                                .foregroundStyle(STRQColors.primaryText)
                                .lineLimit(1)
                            Text(item.detail)
                                .font(STRQTypography.micro)
                                .foregroundStyle(STRQColors.mutedText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }

                        Spacer(minLength: 0)

                        Text(item.state)
                            .font(STRQTypography.micro)
                            .foregroundStyle(item.tone.tint(defaultTint: scenario.tint))
                            .lineLimit(1)
                            .minimumScaleFactor(0.68)
                    }
                    .padding(STRQSpacing.xs)
                    .background(ProgressV5Style.surfaceSecondary.opacity(0.55), in: .rect(cornerRadius: STRQRadii.md))
                }
            }
        }
        .padding(STRQSpacing.md)
        .background(ProgressV5Style.surface, in: .rect(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(ProgressV5Style.border, lineWidth: 1)
        )
    }
}

private struct ProgressV5AnalyticsDoorway: View {
    let scenario: ProgressV5Scenario

    var body: some View {
        HStack(alignment: .center, spacing: STRQSpacing.sm) {
            STRQIconView(scenario.doorwayIcon, size: 22, tint: scenario.tint)
                .frame(width: 46, height: 46)
                .background(scenario.tint.opacity(0.1), in: .rect(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(scenario.tint.opacity(0.24), lineWidth: 1)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Deeper Analytics")
                    .font(STRQTypography.cardTitle)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                Text(scenario.doorwayCopy)
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Text(scenario.doorwayState)
                .font(STRQTypography.micro)
                .foregroundStyle(scenario.tint)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(scenario.tint.opacity(0.1), in: Capsule())
        }
        .padding(STRQSpacing.md)
        .background(ProgressV5Style.surfaceSecondary, in: .rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(ProgressV5Style.border, lineWidth: 1)
        )
    }
}

private struct ProgressV5AngledPanel<Content: View>: View {
    let tint: Color
    let content: Content

    init(tint: Color, @ViewBuilder content: () -> Content) {
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        content
            .padding(STRQSpacing.md)
            .background {
                UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 28, bottomTrailingRadius: 10, topTrailingRadius: 28, style: .continuous)
                    .fill(ProgressV5Style.surface)
            }
            .overlay(
                UnevenRoundedRectangle(topLeadingRadius: 10, bottomLeadingRadius: 28, bottomTrailingRadius: 10, topTrailingRadius: 28, style: .continuous)
                    .strokeBorder(tint.opacity(0.18), lineWidth: 1)
            )
    }
}

private struct ProgressV5SectionTitle: View {
    let icon: STRQIcon
    let title: String
    let subtitle: String
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: STRQSpacing.sm) {
            STRQIconView(icon, size: 15, tint: tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.1), in: .rect(cornerRadius: 9))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(STRQTypography.cardTitle)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                Text(subtitle)
                    .font(STRQTypography.caption)
                    .foregroundStyle(STRQColors.secondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct ProgressV5ConfidenceRing: View {
    let value: Double
    let label: String
    let tint: Color
    let icon: STRQIcon

    var body: some View {
        ZStack {
            Circle()
                .stroke(ProgressV5Style.track, lineWidth: 7)
            Circle()
                .trim(from: 0, to: max(0, min(value, 1)))
                .stroke(tint, style: StrokeStyle(lineWidth: 7, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 4) {
                STRQIconView(icon, size: 16, tint: tint)
                Text(label)
                    .font(STRQTypography.micro)
                    .foregroundStyle(STRQColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.62)
            }
        }
        .frame(width: 80, height: 80)
        .padding(4)
        .background(ProgressV5Style.glass, in: Circle())
    }
}

private struct ProgressV5HeroStat: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value)
                .font(STRQTypography.labelLarge)
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
                .monospacedDigit()

            Text(title)
                .font(STRQTypography.micro)
                .foregroundStyle(STRQColors.mutedText)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, STRQSpacing.sm)
    }
}

private struct ProgressV5Capsule: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(STRQTypography.micro)
            .foregroundStyle(tint)
            .lineLimit(1)
            .minimumScaleFactor(0.68)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(tint.opacity(0.12), in: Capsule())
            .overlay(Capsule().strokeBorder(tint.opacity(0.32), lineWidth: 1))
    }
}

private struct ProgressV5Divider: View {
    var body: some View {
        Rectangle()
            .fill(ProgressV5Style.border)
            .frame(width: 1, height: 36)
    }
}

private struct ProgressV5FineGrid: View {
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
            .stroke(ProgressV5Style.grid, lineWidth: 1)
        }
    }
}

private enum ProgressV5ExperienceState: CaseIterable, Identifiable {
    case beginner
    case athlete

    var id: Self { self }

    var title: String {
        switch self {
        case .beginner:
            return "Beginner"
        case .athlete:
            return "Athlete"
        }
    }

    var caption: String {
        switch self {
        case .beginner:
            return "1 workout"
        case .athlete:
            return "32 workouts"
        }
    }

    var tint: Color {
        switch self {
        case .beginner:
            return ProgressV5Style.amber
        case .athlete:
            return ProgressV5Style.signal
        }
    }

    var scenario: ProgressV5Scenario {
        switch self {
        case .beginner:
            return .beginner
        case .athlete:
            return .athlete
        }
    }
}

private struct ProgressV5Scenario {
    let state: ProgressV5ExperienceState
    let heroStatus: String
    let heroTitle: String
    let heroMessage: String
    let workoutCount: String
    let windowLabel: String
    let confidenceLabel: String
    let heroConfidenceValue: Double
    let confidenceIcon: STRQIcon
    let mapCaption: String
    let rhythmCaption: String
    let rhythmValue: String
    let unlockCaption: String
    let evidenceCaption: String
    let confidenceCaption: String
    let doorwayCopy: String
    let doorwayState: String
    let doorwayIcon: STRQIcon
    let areas: [ProgressV5TrainingArea]
    let routes: [ProgressV5MapRoute]
    let rhythmDays: [ProgressV5RhythmDay]
    let weeks: [ProgressV5Week]
    let unlocks: [ProgressV5Unlock]
    let evidence: [ProgressV5EvidenceItem]
    let confidenceItems: [ProgressV5ConfidenceItem]

    var tint: Color { state.tint }

    var accessibilityMapSummary: String {
        areas.map { "\($0.title) \($0.state.label)" }.joined(separator: ", ")
    }

    func area(for id: String) -> ProgressV5TrainingArea {
        areas.first { $0.id == id } ?? areas[0]
    }

    static let beginner = ProgressV5Scenario(
        state: .beginner,
        heroStatus: "Calibrating",
        heroTitle: "One workout has started the record.",
        heroMessage: "Repeat one lift to make the map readable. Until then, STRQ keeps the story simple and honest.",
        workoutCount: "1",
        windowLabel: "7 day",
        confidenceLabel: "Calibrating",
        heroConfidenceValue: 0.24,
        confidenceIcon: .clock,
        mapCaption: "The first anchors are visible; locked areas stay quiet until training repeats.",
        rhythmCaption: "One completed session is evidence, not a streak.",
        rhythmValue: "1/3 this week",
        unlockCaption: "The next workout should make one comparison possible.",
        evidenceCaption: "Only the facts that exist are shown.",
        confidenceCaption: "Claims stay narrow while the baseline forms.",
        doorwayCopy: "Strength, volume, and coverage detail open once the map has repeat evidence.",
        doorwayState: "Locked",
        doorwayIcon: .lock,
        areas: [
            .init(title: "Push", detail: "first anchor", state: .forming, value: 0.22, x: 0.29, y: 0.42, icon: .barbell, isPrimary: true),
            .init(title: "Legs", detail: "first anchor", state: .forming, value: 0.18, x: 0.55, y: 0.72, icon: .train, isPrimary: false),
            .init(title: "Pull", detail: "waiting", state: .locked, value: 0.06, x: 0.7, y: 0.38, icon: .muscle, isPrimary: false),
            .init(title: "Posterior", detail: "locked", state: .locked, value: 0, x: 0.42, y: 0.58, icon: .activityRing, isPrimary: false),
            .init(title: "Core", detail: "locked", state: .locked, value: 0, x: 0.58, y: 0.22, icon: .target, isPrimary: false)
        ],
        routes: ProgressV5MapRoute.standard,
        rhythmDays: ProgressV5Factory.days(trained: [5], forming: [12, 19, 26], count: 28),
        weeks: ProgressV5Factory.weeks([0, 0, 0, 1], target: 3),
        unlocks: [
            .init(label: "Next", title: "Repeat one lift", detail: "A second exposure turns one entry into the first comparison.", progress: 0.34, icon: .repeatAction, tone: .primary)
        ],
        evidence: [
            .init(date: "Today", title: "First workout logged", detail: "Push and leg work created the first visible anchors.", tone: .primary),
            .init(date: "Next", title: "Map readability pending", detail: "Repeat one lift before STRQ compares direction.", tone: .neutral)
        ],
        confidenceItems: [
            .init(title: "Training Map", detail: "first anchors only", state: "Calibrating", icon: .progress, tone: .primary),
            .init(title: "Rhythm Story", detail: "one completed day", state: "Forming", icon: .calendar, tone: .neutral),
            .init(title: "Deep Trends", detail: "needs repeats", state: "Locked", icon: .lock, tone: .neutral)
        ]
    )

    static let athlete = ProgressV5Scenario(
        state: .athlete,
        heroStatus: "Confident",
        heroTitle: "Your four-week map is readable enough to guide the next block.",
        heroMessage: "Coverage, rhythm, and recent evidence point to a stable pattern with one area still light.",
        workoutCount: "32",
        windowLabel: "4 week",
        confidenceLabel: "Confident",
        heroConfidenceValue: 0.92,
        confidenceIcon: .checkCircle,
        mapCaption: "Covered areas, improving work, and one light pattern stay visible in one read.",
        rhythmCaption: "Cadence is repeatable without turning open days into failure.",
        rhythmValue: "14/16 target",
        unlockCaption: "The next sessions can close a gap without flooding the view with raw tables.",
        evidenceCaption: "Recent sessions explain why the map is saying this.",
        confidenceCaption: "Signals are readable, but plan impact remains a future layer.",
        doorwayCopy: "Detailed anchors, load rhythm, and movement breakdown can live behind this doorway.",
        doorwayState: "Ready",
        doorwayIcon: .chartLine,
        areas: [
            .init(title: "Push", detail: "improving", state: .improving, value: 0.86, x: 0.27, y: 0.38, icon: .barbell, isPrimary: true),
            .init(title: "Legs", detail: "covered", state: .covered, value: 0.81, x: 0.53, y: 0.72, icon: .train, isPrimary: true),
            .init(title: "Pull", detail: "covered", state: .covered, value: 0.74, x: 0.72, y: 0.38, icon: .muscle, isPrimary: false),
            .init(title: "Posterior", detail: "light", state: .light, value: 0.58, x: 0.42, y: 0.58, icon: .activityRing, isPrimary: false),
            .init(title: "Core", detail: "forming", state: .forming, value: 0.46, x: 0.58, y: 0.2, icon: .target, isPrimary: false)
        ],
        routes: ProgressV5MapRoute.standard,
        rhythmDays: ProgressV5Factory.days(trained: [1, 3, 5, 8, 10, 12, 15, 17, 19, 22, 24, 26, 27, 28], forming: [], count: 28),
        weeks: ProgressV5Factory.weeks([3, 4, 3, 4], target: 4),
        unlocks: [
            .init(label: "Gap", title: "Posterior chain", detail: "One hinge-focused session can move the light area toward covered.", progress: 0.58, icon: .target, tone: .warning),
            .init(label: "Repeat", title: "Heavy pull", detail: "Repeat the main pull anchor to confirm the trend line.", progress: 0.74, icon: .repeatAction, tone: .primary),
            .init(label: "Rhythm", title: "Close the week", detail: "Two planned sessions keep cadence readable for the block.", progress: 0.88, icon: .calendar, tone: .positive)
        ],
        evidence: [
            .init(date: "Apr 29", title: "Upper strength held", detail: "Push and pull work moved together without crowding the week.", tone: .positive),
            .init(date: "May 02", title: "Lower work repeated", detail: "Legs stayed covered across the four-week window.", tone: .positive),
            .init(date: "May 05", title: "Posterior still light", detail: "Hinge exposure is present, but not as stable as the main map.", tone: .warning),
            .init(date: "May 08", title: "Rhythm stayed readable", detail: "The week closed on target while open days stayed neutral.", tone: .primary)
        ],
        confidenceItems: [
            .init(title: "Training Map", detail: "four-week coverage", state: "Confident", icon: .progress, tone: .positive),
            .init(title: "Rhythm Story", detail: "repeatable weeks", state: "Readable", icon: .calendar, tone: .primary),
            .init(title: "Plan Impact", detail: "future provenance", state: "Locked", icon: .lock, tone: .neutral)
        ]
    )
}

private struct ProgressV5TrainingArea: Identifiable {
    let title: String
    let detail: String
    let state: ProgressV5MapState
    let value: Double
    let x: CGFloat
    let y: CGFloat
    let icon: STRQIcon
    let isPrimary: Bool

    var id: String { title }
    var nodeSize: CGFloat { isPrimary ? 74 : 62 }
}

private struct ProgressV5MapRoute: Identifiable {
    let start: String
    let end: String

    var id: String { "\(start)-\(end)" }

    static let standard = [
        ProgressV5MapRoute(start: "Push", end: "Core"),
        ProgressV5MapRoute(start: "Core", end: "Pull"),
        ProgressV5MapRoute(start: "Push", end: "Posterior"),
        ProgressV5MapRoute(start: "Posterior", end: "Legs"),
        ProgressV5MapRoute(start: "Pull", end: "Posterior"),
        ProgressV5MapRoute(start: "Pull", end: "Legs")
    ]

    func isLocked(in scenario: ProgressV5Scenario) -> Bool {
        scenario.area(for: start).state == .locked || scenario.area(for: end).state == .locked
    }

    func tint(scenario: ProgressV5Scenario) -> Color {
        isLocked(in: scenario) ? ProgressV5Style.steel : scenario.tint
    }
}

private enum ProgressV5MapState {
    case locked
    case forming
    case covered
    case improving
    case light

    var label: String {
        switch self {
        case .locked:
            return "locked"
        case .forming:
            return "forming"
        case .covered:
            return "covered"
        case .improving:
            return "improving"
        case .light:
            return "light"
        }
    }

    func fill(tint: Color) -> Color {
        switch self {
        case .locked:
            return ProgressV5Style.surfaceSecondary.opacity(0.7)
        case .forming:
            return ProgressV5Style.amber.opacity(0.16)
        case .covered:
            return ProgressV5Style.success.opacity(0.18)
        case .improving:
            return tint.opacity(0.22)
        case .light:
            return ProgressV5Style.steel.opacity(0.13)
        }
    }

    func stroke(tint: Color) -> Color {
        switch self {
        case .locked:
            return ProgressV5Style.steel.opacity(0.22)
        case .forming:
            return ProgressV5Style.amber.opacity(0.52)
        case .covered:
            return ProgressV5Style.success.opacity(0.5)
        case .improving:
            return tint.opacity(0.62)
        case .light:
            return ProgressV5Style.steel.opacity(0.42)
        }
    }

    func accent(tint: Color) -> Color {
        switch self {
        case .locked:
            return ProgressV5Style.steel
        case .forming:
            return ProgressV5Style.amber
        case .covered:
            return ProgressV5Style.success
        case .improving:
            return tint
        case .light:
            return ProgressV5Style.steel
        }
    }

    func iconTint(tint: Color) -> Color {
        switch self {
        case .locked:
            return ProgressV5Style.steel.opacity(0.7)
        default:
            return accent(tint: tint)
        }
    }

    func textColor(tint: Color) -> Color {
        switch self {
        case .locked:
            return STRQColors.mutedText
        default:
            return STRQColors.primaryText
        }
    }

    func shadow(tint: Color) -> Color {
        switch self {
        case .locked:
            return .clear
        default:
            return accent(tint: tint).opacity(0.24)
        }
    }
}

private struct ProgressV5RhythmDay: Identifiable {
    let index: Int
    let status: ProgressV5RhythmStatus
    let intensity: Double

    var id: Int { index }

    func fill(tint: Color) -> Color {
        switch status {
        case .open:
            return ProgressV5Style.surfaceSecondary
        case .forming:
            return tint.opacity(0.12)
        case .trained:
            return tint.opacity(0.2 + intensity * 0.24)
        }
    }

    func stroke(tint: Color) -> Color {
        switch status {
        case .open:
            return ProgressV5Style.border
        case .forming:
            return tint.opacity(0.24)
        case .trained:
            return tint.opacity(0.48)
        }
    }
}

private enum ProgressV5RhythmStatus {
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

private struct ProgressV5Week: Identifiable {
    let label: String
    let sessions: Int
    let target: Int
    let isCurrent: Bool

    var id: String { label }
    var ratio: Double { target > 0 ? min(Double(sessions) / Double(target), 1) : 0 }
}

private struct ProgressV5Unlock: Identifiable {
    let label: String
    let title: String
    let detail: String
    let progress: Double
    let icon: STRQIcon
    let tone: ProgressV5Tone

    var id: String { "\(label)-\(title)" }
}

private struct ProgressV5EvidenceItem: Identifiable {
    let date: String
    let title: String
    let detail: String
    let tone: ProgressV5Tone

    var id: String { "\(date)-\(title)" }
}

private struct ProgressV5ConfidenceItem: Identifiable {
    let title: String
    let detail: String
    let state: String
    let icon: STRQIcon
    let tone: ProgressV5Tone

    var id: String { title }
}

private enum ProgressV5Tone {
    case neutral
    case primary
    case positive
    case warning

    func tint(defaultTint: Color) -> Color {
        switch self {
        case .neutral:
            return ProgressV5Style.steel
        case .primary:
            return defaultTint
        case .positive:
            return ProgressV5Style.success
        case .warning:
            return ProgressV5Style.amber
        }
    }
}

private enum ProgressV5Factory {
    static func days(trained: [Int], forming: [Int], count: Int) -> [ProgressV5RhythmDay] {
        (1...count).map { index in
            let status: ProgressV5RhythmStatus
            if trained.contains(index) {
                status = .trained
            } else if forming.contains(index) {
                status = .forming
            } else {
                status = .open
            }

            let intensity = 0.36 + Double((index * 19) % 48) / 100.0
            return ProgressV5RhythmDay(index: index, status: status, intensity: intensity)
        }
    }

    static func weeks(_ sessionCounts: [Int], target: Int) -> [ProgressV5Week] {
        sessionCounts.enumerated().map { index, sessionCount in
            ProgressV5Week(
                label: index == sessionCounts.count - 1 ? "Now" : "\(sessionCounts.count - index - 1)w",
                sessions: sessionCount,
                target: target,
                isCurrent: index == sessionCounts.count - 1
            )
        }
    }
}

private enum ProgressV5Style {
    static let background = hex(0x05070A)
    static let stage = hex(0x091116)
    static let surfaceDeep = hex(0x080B10)
    static let surface = hex(0x10151C)
    static let surfaceSecondary = hex(0x151B23)
    static let control = hex(0x0B1016)
    static let glass = hex(0x111A22).opacity(0.82)
    static let plot = hex(0x070A0F)
    static let track = hex(0x27313B)
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

#if DEBUG
private struct ProgressV5ExperiencePrototypeView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressV5ExperiencePrototypeView()
            .previewDisplayName("Progress V5 Experience")
    }
}
#endif
