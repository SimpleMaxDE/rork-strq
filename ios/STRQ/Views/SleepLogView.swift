import SwiftUI
import Charts

struct SleepLogView: View {
    @Bindable var vm: AppViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var hoursInput: Double = 7.0
    @State private var qualitySelection: ReadinessLevel = .good
    @State private var appeared: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                recoveryContextCard
                sleepTrendChart
                quickLogCard
                trainingImpactCard
                recentSleepList
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .navigationTitle(L10n.tr("Sleep & Recovery"))
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }

    private var recoveryContextCard: some View {
        let avgSleep = vm.averageSleepHours
        let recoveryScore = vm.effectiveRecoveryScore
        let sleepColor: Color = avgSleep >= 7.5 ? .green : avgSleep >= 6.5 ? .yellow : .red
        let recoveryColor: Color = recoveryScore >= 80 ? .green : recoveryScore >= 60 ? .yellow : .red

        return VStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "moon.stars.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(STRQBrand.steel)
                Text(L10n.tr("RECOVERY STATUS"))
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(STRQBrand.steel)
                    .tracking(0.5)
                Spacer()
                Text(vm.readinessBasedRecoveryStatus)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(recoveryColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(recoveryColor.opacity(0.12), in: Capsule())
            }

            HStack(spacing: 20) {
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(Color(.separator).opacity(0.3), lineWidth: 4)
                            .frame(width: 56, height: 56)
                        Circle()
                            .trim(from: 0, to: appeared ? CGFloat(recoveryScore) / 100 : 0)
                            .stroke(recoveryColor.gradient, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 56, height: 56)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeOut(duration: 0.8).delay(0.2), value: appeared)
                        Text("\(recoveryScore)")
                            .font(.system(size: 16, weight: .bold, design: .rounded).monospacedDigit())
                    }
                    Text(L10n.tr("Recovery"))
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: "moon.zzz.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(STRQBrand.steel)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(L10n.format("Ø %.1f h sleep/day", avgSleep))
                                .font(.subheadline.weight(.semibold).monospacedDigit())
                            Text(L10n.tr("7-day sleep"))
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(STRQBrand.steel)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(vm.sleepQualityLabel)
                                .font(.subheadline.weight(.semibold))
                            Text(L10n.tr("Sleep quality"))
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack(spacing: 8) {
                        Image(systemName: sleepTrainingIcon)
                            .font(.system(size: 11))
                            .foregroundStyle(sleepTrainingColor)
                        VStack(alignment: .leading, spacing: 1) {
                            Text(sleepTrainingImpact)
                                .font(.subheadline.weight(.semibold))
                                .lineLimit(1)
                            Text(L10n.tr("Training impact"))
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Spacer()
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    @ViewBuilder
    private var sleepTrendChart: some View {
        let entries = vm.sleepEntries.prefix(14).reversed().map { $0 }
        if entries.count >= 3 {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(L10n.tr("Sleep Trend"))
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(L10n.tr("14 Days"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Chart {
                    ForEach(Array(entries)) { entry in
                        BarMark(
                            x: .value("Date", entry.date, unit: .day),
                            y: .value("Hours", entry.hoursSlept)
                        )
                        .foregroundStyle(entry.hoursSlept >= 7 ? Color.white.gradient : STRQBrand.steel.gradient)
                        .clipShape(.rect(cornerRadius: 3))
                    }

                    RuleMark(y: .value("Target", 7.0))
                        .foregroundStyle(.green.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text(L10n.tr("7h target"))
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundStyle(.green)
                        }
                }
                .frame(height: 160)
                .chartYScale(domain: 0...10)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [0, 5, 7, 10]) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3)).foregroundStyle(Color(.separator).opacity(0.3))
                        AxisValueLabel().foregroundStyle(Color.secondary)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 3)) { _ in
                        AxisValueLabel(format: .dateTime.weekday(.narrow)).foregroundStyle(Color.secondary)
                    }
                }

                HStack(spacing: 14) {
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2).fill(Color.white).frame(width: 10, height: 10)
                        Text(L10n.tr("≥ 7h")).font(.caption2).foregroundStyle(.secondary)
                    }
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2).fill(STRQBrand.steel).frame(width: 10, height: 10)
                        Text(L10n.tr("< 7h")).font(.caption2).foregroundStyle(.secondary)
                    }
                    Spacer()
                    let goodNights = entries.filter { $0.hoursSlept >= 7 }.count
                    Text(L10n.format("%d/%d good nights", goodNights, entries.count))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(STRQBrand.steel)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.05), value: appeared)
        }
    }

    private var quickLogCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.tr("Log Tonight's Sleep"))
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(L10n.tr("Hours Slept"))
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text(String(format: "%.1fh", hoursInput))
                        .font(.subheadline.weight(.bold).monospacedDigit())
                        .foregroundStyle(STRQBrand.steel)
                }
                Slider(value: $hoursInput, in: 3...12, step: 0.5)
                    .tint(STRQBrand.steel)

                HStack(spacing: 10) {
                    ForEach([5.0, 6.0, 7.0, 8.0, 9.0], id: \.self) { h in
                        Button {
                            withAnimation(.snappy(duration: 0.2)) { hoursInput = h }
                        } label: {
                            Text(String(format: "%.0f", h))
                                .font(.caption.weight(.semibold).monospacedDigit())
                                .foregroundStyle(hoursInput == h ? .white : .secondary)
                                .frame(maxWidth: .infinity)
                                .frame(height: 32)
                                .background(
                                    hoursInput == h ?
                                    AnyShapeStyle(STRQBrand.steelGradient) :
                                    AnyShapeStyle(Color(.tertiarySystemGroupedBackground)),
                                    in: .rect(cornerRadius: 8)
                                )
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.tr("Sleep Quality"))
                    .font(.subheadline.weight(.medium))

                HStack(spacing: 6) {
                    ForEach(ReadinessLevel.allCases) { level in
                        let isSelected = qualitySelection == level
                        Button {
                            withAnimation(.snappy(duration: 0.2)) { qualitySelection = level }
                        } label: {
                            VStack(spacing: 4) {
                                Text(level.emoji)
                                    .font(.title3)
                                Text(level.sleepQualityLabel)
                                    .font(.system(size: 9, weight: .medium))
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .foregroundStyle(isSelected ? .white : .primary)
                            .background(
                                isSelected ?
                                AnyShapeStyle(STRQBrand.steelGradient) :
                                AnyShapeStyle(Color(.tertiarySystemGroupedBackground)),
                                in: .rect(cornerRadius: 10)
                            )
                        }
                    }
                }
            }

            Button {
                saveSleep()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.subheadline)
                    Text(L10n.tr("Log Sleep"))
                        .font(.body.weight(.semibold))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 14))
            }
            .sensoryFeedback(.success, trigger: vm.sleepEntries.count)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    @ViewBuilder
    private var trainingImpactCard: some View {
        let avgSleep = vm.averageSleepHours
        let insights = sleepTrainingInsights

        if !insights.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(STRQBrand.steel)
                    Text(L10n.tr("HOW SLEEP AFFECTS YOUR TRAINING"))
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(STRQBrand.steel)
                        .tracking(0.5)
                }

                ForEach(insights, id: \.title) { insight in
                    HStack(spacing: 12) {
                        Image(systemName: insight.icon)
                            .font(.subheadline)
                            .foregroundStyle(insight.color)
                            .frame(width: 32, height: 32)
                            .background(insight.color.opacity(0.12), in: .rect(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 2) {
                            Text(insight.title)
                                .font(.subheadline.weight(.semibold))
                            Text(insight.message)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 12))
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)
        }
    }

    @ViewBuilder
    private var recentSleepList: some View {
        if !vm.sleepEntries.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text(L10n.tr("Recent Sleep"))
                    .font(.headline)

                ForEach(vm.sleepEntries.prefix(10)) { entry in
                    let isToday = Calendar.current.isDateInToday(entry.date)
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(isToday ? L10n.tr("Today") : entry.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
                                .font(.subheadline.weight(isToday ? .semibold : .medium))
                            HStack(spacing: 6) {
                                Text(String(format: "%.1fh", entry.hoursSlept))
                                    .font(.caption.weight(.semibold).monospacedDigit())
                                    .foregroundStyle(entry.hoursSlept >= 7 ? Color.white : STRQBrand.steel)
                                Text(entry.quality.sleepQualityLabel)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()

                        let barWidth: CGFloat = max(20, min(80, CGFloat(entry.hoursSlept / 10.0) * 80))
                        RoundedRectangle(cornerRadius: 3)
                            .fill(entry.hoursSlept >= 7 ? Color.white.gradient : STRQBrand.steel.gradient)
                            .frame(width: barWidth, height: 8)
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
        }
    }

    private var sleepTrainingIcon: String {
        let avg = vm.averageSleepHours
        if avg >= 7.5 { return "checkmark.circle.fill" }
        if avg >= 6.5 { return "exclamationmark.circle.fill" }
        return "xmark.circle.fill"
    }

    private var sleepTrainingColor: Color {
        let avg = vm.averageSleepHours
        if avg >= 7.5 { return .green }
        if avg >= 6.5 { return .yellow }
        return .red
    }

    private var sleepTrainingImpact: String {
        let avg = vm.averageSleepHours
        if avg >= 7.5 { return L10n.tr("Supporting gains") }
        if avg >= 6.5 { return L10n.tr("Slightly limiting") }
        return L10n.tr("Hurting recovery")
    }

    private var sleepTrainingInsights: [(icon: String, color: Color, title: String, message: String)] {
        let avg = vm.averageSleepHours
        var results: [(icon: String, color: Color, title: String, message: String)] = []

        if avg < 6.5 {
            results.append((
                icon: "exclamationmark.triangle.fill",
                color: .red,
                title: L10n.tr("Muscle Recovery Impaired"),
                message: L10n.tr("Under 6.5h average sleep significantly reduces muscle protein synthesis and growth hormone release.")
            ))
            results.append((
                icon: "bolt.slash.fill",
                color: STRQBrand.steel,
                title: L10n.tr("Strength Output Reduced"),
                message: L10n.tr("Sleep debt reduces maximal strength by 5-10%. Consider lighter loads until sleep improves.")
            ))
        } else if avg < 7.5 {
            results.append((
                icon: "exclamationmark.circle.fill",
                color: .yellow,
                title: L10n.tr("Recovery Slightly Limited"),
                message: L10n.tr("Aim for 7.5h+ to fully support your training. Current sleep may slow progress slightly.")
            ))
        } else {
            results.append((
                icon: "checkmark.circle.fill",
                color: .green,
                title: L10n.tr("Recovery Well Supported"),
                message: L10n.tr("Your sleep is supporting muscle recovery and performance. Keep this consistency.")
            ))
        }

        let recentQuality = vm.sleepEntries.prefix(7)
        let poorNights = recentQuality.filter { $0.quality.rawValue <= 2 }.count
        if poorNights >= 3 {
            results.append((
                icon: "moon.haze.fill",
                color: STRQBrand.steel,
                title: L10n.tr("Sleep Quality Declining"),
                message: L10n.format("%d poor-quality nights this week. Quality matters as much as duration for recovery.", poorNights)
            ))
        }

        return results
    }

    private func saveSleep() {
        vm.logSleep(hours: hoursInput, quality: qualitySelection)
    }
}
