import SwiftUI
import Charts

struct ProgressAnalyticsView: View {
    let vm: AppViewModel
    @State private var selectedTab: Int = 0
    @State private var appeared: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headlineHero
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                signalStrip
                    .padding(.horizontal, 16)

                tabSelector
                    .padding(.horizontal, 16)

                Group {
                    switch selectedTab {
                    case 0: strengthSignals
                    case 1: bodySignals
                    case 2: volumeSignals
                    default: strengthSignals
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.bottom, 32)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
            Analytics.shared.track(.progress_viewed)
        }
    }

    // MARK: - Headline Hero

    private var headlineHero: some View {
        let progressing = vm.progressingExercises.count
        let prsThisMonth: Int = {
            let cal = Calendar.current
            return vm.personalRecords.filter { cal.isDate($0.date, equalTo: Date(), toGranularity: .month) }.count
        }()
        let headline: (String, String) = {
            if progressing > 0 {
                return ("\(progressing)", "lifts progressing")
            } else if prsThisMonth > 0 {
                return ("\(prsThisMonth)", "PRs this month")
            } else {
                return ("\(vm.totalCompletedWorkouts)", "sessions logged")
            }
        }()
        let sub: String = {
            if progressing > 0 && prsThisMonth > 0 {
                return "\(prsThisMonth) PR\(prsThisMonth == 1 ? "" : "s") this month · \(vm.streak)-day streak"
            } else if vm.streak > 0 {
                return "\(vm.streak)-day streak · keep the signal strong"
            } else {
                return "Train to build your signal"
            }
        }()

        return ZStack(alignment: .topLeading) {
            Canvas { context, size in
                for i in 0..<3 {
                    let xF: [CGFloat] = [0.2, 0.75, 0.95]
                    let yF: [CGFloat] = [0.3, 0.75, 0.2]
                    let radius = CGFloat(55 + i * 25)
                    let circle = Path(ellipseIn: CGRect(
                        x: xF[i] * size.width - radius,
                        y: yF[i] * size.height - radius,
                        width: radius * 2, height: radius * 2
                    ))
                    context.fill(circle, with: .color(.white.opacity(0.025)))
                }
            }
            .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 10) {
                Text("SIGNAL")
                    .font(.system(size: 10, weight: .black))
                    .tracking(1.4)
                    .foregroundStyle(STRQBrand.steel)

                HStack(alignment: .lastTextBaseline, spacing: 10) {
                    Text(headline.0)
                        .font(.system(size: 56, weight: .heavy, design: .rounded).monospacedDigit())
                        .foregroundStyle(.white)
                    Text(headline.1)
                        .font(.system(.title3, design: .rounded, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.55))
                        .padding(.bottom, 6)
                }

                Text(sub)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(20)
        }
        .background(
            LinearGradient(
                colors: [Color(white: 0.17), Color(white: 0.09)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ),
            in: .rect(cornerRadius: 22)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
        .overlay(alignment: .top) {
            STRQBrand.accentGradient
                .frame(height: 3)
                .clipShape(.rect(cornerRadii: .init(topLeading: 22, bottomLeading: 0, bottomTrailing: 0, topTrailing: 22)))
        }
        .shadow(color: .black.opacity(0.22), radius: 16, y: 5)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5), value: appeared)
    }

    // MARK: - Signal Strip

    private var signalStrip: some View {
        HStack(spacing: 8) {
            signalPill(icon: "arrow.up.right", value: "\(vm.progressingExercises.count)", label: "Progressing", color: .green)
            signalPill(icon: "flame.fill", value: "\(vm.streak)", label: "Streak", color: STRQBrand.steel)
            signalPill(icon: "figure.strengthtraining.traditional", value: "\(vm.totalCompletedWorkouts)", label: "Workouts", color: STRQBrand.steel)
            signalPill(icon: "heart.fill", value: "\(vm.effectiveRecoveryScore)%", label: "Recovery", color: ForgeTheme.recoveryColor(for: vm.effectiveRecoveryScore))
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
    }

    private func signalPill(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(color)
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .bold).monospacedDigit())
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            Text(label)
                .font(.system(size: 8, weight: .semibold))
                .foregroundStyle(.tertiary)
                .textCase(.uppercase)
                .tracking(0.2)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: 0) {
            ForEach(Array(["Strength", "Body", "Volume"].enumerated()), id: \.offset) { index, tab in
                Button {
                    withAnimation(.snappy(duration: 0.25)) { selectedTab = index }
                } label: {
                    Text(tab)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(selectedTab == index ? .black : .secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(
                            selectedTab == index ? AnyShapeStyle(ForgeTheme.accentGradient) : AnyShapeStyle(Color.clear),
                            in: .rect(cornerRadius: 9)
                        )
                }
            }
        }
        .padding(3)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
        .sensoryFeedback(.selection, trigger: selectedTab)
    }

    // MARK: - Strength Signals

    @ViewBuilder
    private var strengthSignals: some View {
        VStack(spacing: 14) {
            strengthChart
            prHighlights
            consistencyHeatmap
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private var strengthChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForgeSectionHeader(title: "Estimated 1RM", trailing: "8 Weeks")

            Chart {
                ForEach(vm.strengthProgress) { entry in
                    LineMark(x: .value("Week", entry.date), y: .value("Weight", entry.bench), series: .value("Lift", "Bench"))
                        .foregroundStyle(Color.white).interpolationMethod(.catmullRom).symbol(.circle)
                    LineMark(x: .value("Week", entry.date), y: .value("Weight", entry.squat), series: .value("Lift", "Squat"))
                        .foregroundStyle(STRQBrand.steel).interpolationMethod(.catmullRom).symbol(.square)
                    LineMark(x: .value("Week", entry.date), y: .value("Weight", entry.deadlift), series: .value("Lift", "Deadlift"))
                        .foregroundStyle(STRQBrand.slate).interpolationMethod(.catmullRom).symbol(.triangle)
                }
            }
            .frame(height: 170)
            .chartYScale(domain: .automatic(includesZero: false))
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3)).foregroundStyle(Color(.separator).opacity(0.3))
                    AxisValueLabel().foregroundStyle(Color.secondary)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .weekOfYear, count: 2)) { _ in
                    AxisValueLabel(format: .dateTime.month(.abbreviated).day()).foregroundStyle(Color.secondary)
                }
            }
            .chartForegroundStyleScale(["Bench": Color.white, "Squat": STRQBrand.steel, "Deadlift": STRQBrand.slate])

            HStack(spacing: 16) {
                legendDot(color: .white, label: "Bench")
                legendDot(color: STRQBrand.steel, label: "Squat")
                legendDot(color: STRQBrand.slate, label: "Deadlift")
            }
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private func legendDot(color: Color, label: String) -> some View {
        HStack(spacing: 5) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(label).font(.caption.weight(.medium)).foregroundStyle(.secondary)
        }
    }

    private var prHighlights: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForgeSectionHeader(title: "Recent PRs")

            let sortedPRs = vm.personalRecords.sorted { $0.date > $1.date }
            if sortedPRs.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "trophy")
                        .foregroundStyle(.secondary)
                    Text("No personal records yet. Keep training!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            } else {
                ForEach(Array(sortedPRs.prefix(3).enumerated()), id: \.element.id) { _, pr in
                    HStack(spacing: 12) {
                        Image(systemName: "trophy.fill")
                            .font(.caption)
                            .foregroundStyle(STRQBrand.steel)
                            .frame(width: 28, height: 28)
                            .background(STRQBrand.steel.opacity(0.1), in: .rect(cornerRadius: 8))

                        VStack(alignment: .leading, spacing: 1) {
                            Text(vm.library.exercise(byId: pr.exerciseId)?.name ?? pr.exerciseId)
                                .font(.subheadline.weight(.semibold))
                                .lineLimit(1)
                            Text("\(Int(pr.weight))kg × \(pr.reps) · \(pr.date.formatted(.dateTime.month(.abbreviated).day()))")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        Spacer()
                        Text("\(Int(pr.estimatedOneRepMax))kg")
                            .font(.system(.subheadline, design: .rounded, weight: .bold).monospacedDigit())
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var consistencyHeatmap: some View {
        let calendar = Calendar.current
        let last28Days: [(Date, Bool)] = (0..<28).reversed().map { offset in
            let date = calendar.date(byAdding: .day, value: -offset, to: Date())!
            let trained = vm.workoutHistory.contains { session in
                calendar.isDate(session.startTime, inSameDayAs: date) && session.isCompleted
            }
            return (date, trained)
        }

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ForgeSectionHeader(title: "28-Day Consistency")
                Spacer()
                let count = last28Days.filter(\.1).count
                Text("\(count) days")
                    .font(.system(size: 11, weight: .bold, design: .rounded).monospacedDigit())
                    .foregroundStyle(STRQBrand.steel)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(STRQBrand.steel.opacity(0.12), in: Capsule())
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(last28Days, id: \.0) { _, trained in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(trained ? Color.white.gradient : Color(.tertiarySystemGroupedBackground).gradient)
                        .frame(height: 20)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Body Signals

    @ViewBuilder
    private var bodySignals: some View {
        VStack(spacing: 14) {
            if let pace = vm.goalPace {
                goalPaceCard(pace)
            }
            bodyWeightChart
            recoveryTrend
            nutritionAdherence
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private func goalPaceCard(_ pace: GoalPaceStatus) -> some View {
        let color = ForgeTheme.color(for: pace.colorName)
        return HStack(spacing: 14) {
            Image(systemName: pace.icon)
                .font(.title3.weight(.medium))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(
                    LinearGradient(colors: [color, color.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing),
                    in: .rect(cornerRadius: 11)
                )

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text("Goal Pace")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(color)
                        .textCase(.uppercase)
                        .tracking(0.3)
                    Text(vm.nutritionTarget.nutritionGoal.displayName)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(color.gradient, in: Capsule())
                }
                Text(pace.headline)
                    .font(.subheadline.weight(.semibold))
                Text(pace.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(14)
        .background(STRQBrand.cardElevated, in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    @ViewBuilder
    private var bodyWeightChart: some View {
        let entries = vm.bodyWeightEntries.sorted { $0.date < $1.date }

        if entries.count >= 2 {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ForgeSectionHeader(title: "Body Weight")
                    Spacer()
                    if let latest = entries.last {
                        Text(String(format: "%.1f kg", latest.weightKg))
                            .font(.system(.subheadline, design: .rounded, weight: .bold).monospacedDigit())
                            .foregroundStyle(STRQBrand.steel)
                    }
                }

                Chart {
                    ForEach(entries) { entry in
                        AreaMark(x: .value("Date", entry.date), y: .value("Weight", entry.weightKg))
                            .foregroundStyle(
                                LinearGradient(colors: [STRQBrand.steel.opacity(0.2), STRQBrand.steel.opacity(0.02)], startPoint: .top, endPoint: .bottom)
                            )
                            .interpolationMethod(.catmullRom)
                        LineMark(x: .value("Date", entry.date), y: .value("Weight", entry.weightKg))
                            .foregroundStyle(STRQBrand.steel).interpolationMethod(.catmullRom).lineStyle(StrokeStyle(lineWidth: 2))
                    }
                }
                .frame(height: 140)
                .chartYScale(domain: .automatic(includesZero: false))
                .chartYAxis {
                    AxisMarks(position: .leading) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3)).foregroundStyle(Color(.separator).opacity(0.3))
                        AxisValueLabel().foregroundStyle(Color.secondary)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { _ in
                        AxisValueLabel(format: .dateTime.month(.abbreviated).day()).foregroundStyle(Color.secondary)
                    }
                }

                HStack(spacing: 10) {
                    let trendIcon = vm.weightTrendDescription == "Trending up" ? "arrow.up.right" : vm.weightTrendDescription == "Trending down" ? "arrow.down.right" : "equal"
                    HStack(spacing: 4) {
                        Image(systemName: trendIcon)
                            .font(.system(size: 9))
                            .foregroundStyle(STRQBrand.steel)
                        Text(vm.weightTrendDescription)
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(STRQBrand.steel)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(STRQBrand.steel.opacity(0.12), in: Capsule())

                    Text(vm.nutritionTarget.weightGoalDirection.displayName)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
            )
        }
    }

    @ViewBuilder
    private var recoveryTrend: some View {
        let data = vm.recoveryTrendData
        if data.count >= 3 {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ForgeSectionHeader(title: "Recovery Trend")
                    Spacer()
                    let avgScore = data.map(\.score).reduce(0, +) / max(1, data.count)
                    let scoreColor: Color = avgScore >= 75 ? .green : avgScore >= 55 ? .yellow : .red
                    Text("Avg \(avgScore)")
                        .font(.system(size: 11, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(scoreColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(scoreColor.opacity(0.1), in: Capsule())
                }

                Chart {
                    ForEach(data, id: \.date) { item in
                        AreaMark(x: .value("Date", item.date), y: .value("Score", item.score))
                            .foregroundStyle(
                                LinearGradient(colors: [.green.opacity(0.15), .green.opacity(0.02)], startPoint: .top, endPoint: .bottom)
                            )
                            .interpolationMethod(.catmullRom)
                        LineMark(x: .value("Date", item.date), y: .value("Score", item.score))
                            .foregroundStyle(.green).interpolationMethod(.catmullRom).lineStyle(StrokeStyle(lineWidth: 2))
                    }
                    RuleMark(y: .value("Good", 70))
                        .foregroundStyle(.green.opacity(0.25))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                }
                .frame(height: 120)
                .chartYScale(domain: 30...100)
                .chartYAxis {
                    AxisMarks(position: .leading, values: [40, 60, 80, 100]) { _ in
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3)).foregroundStyle(Color(.separator).opacity(0.3))
                        AxisValueLabel().foregroundStyle(Color.secondary)
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 3)) { _ in
                        AxisValueLabel(format: .dateTime.weekday(.narrow)).foregroundStyle(Color.secondary)
                    }
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
            )
        }
    }

    @ViewBuilder
    private var nutritionAdherence: some View {
        let logs = vm.nutritionLogs.prefix(7)
        if !logs.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ForgeSectionHeader(title: "Nutrition", trailing: "7 Days")
                    Spacer()
                    let avgProtein = logs.map(\.proteinGrams).reduce(0, +) / max(1, logs.count)
                    Text("Avg \(avgProtein)g")
                        .font(.system(size: 11, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(STRQBrand.steel)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(STRQBrand.steel.opacity(0.1), in: Capsule())
                }

                HStack(spacing: 0) {
                    ForEach(Array(logs.reversed())) { log in
                        let proteinPct = vm.nutritionTarget.proteinGrams > 0 ? min(100, (log.proteinGrams * 100) / vm.nutritionTarget.proteinGrams) : 0
                        let calPct = vm.nutritionTarget.calories > 0 ? min(100, (log.calories * 100) / vm.nutritionTarget.calories) : 0
                        let avgPct = (proteinPct + calPct) / 2
                        let barColor: Color = avgPct >= 85 ? .green : avgPct >= 65 ? .yellow : .red

                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(barColor.gradient)
                                .frame(width: 18, height: max(6, CGFloat(avgPct) / 100.0 * 36))
                            Text(log.date.formatted(.dateTime.weekday(.narrow)))
                                .font(.system(size: 8, weight: .semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 50, alignment: .bottom)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Volume Signals

    @ViewBuilder
    private var volumeSignals: some View {
        VStack(spacing: 14) {
            muscleBalanceChart
            weeklySessionsChart
            movementBalanceCard
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private var muscleBalanceChart: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForgeSectionHeader(title: "Muscle Balance", trailing: "vs 4-Week Avg")

            ForEach(vm.muscleBalance) { entry in
                HStack(spacing: 8) {
                    Text(entry.muscle)
                        .font(.caption.weight(.medium))
                        .frame(width: 68, alignment: .leading)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(.tertiarySystemGroupedBackground)).frame(height: 6)
                            Capsule()
                                .fill(balanceColor(entry.percentOfAverage).gradient)
                                .frame(width: max(0, geo.size.width * min(CGFloat(entry.percentOfAverage), 1.3) / 1.3), height: 6)
                        }
                    }
                    .frame(height: 6)

                    Text(balanceLabel(entry.percentOfAverage))
                        .font(.system(size: 10, weight: .bold, design: .rounded).monospacedDigit())
                        .foregroundStyle(balanceColor(entry.percentOfAverage))
                        .frame(width: 38, alignment: .trailing)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var weeklySessionsChart: some View {
        let calendar = Calendar.current
        let last8Weeks: [(String, Int)] = (0..<8).reversed().map { weekOffset in
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: Date())!
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            let count = vm.workoutHistory.filter { $0.startTime >= weekStart && $0.startTime < weekEnd && $0.isCompleted }.count
            let label = weekOffset == 0 ? "Now" : "\(weekOffset)w"
            return (label, count)
        }

        VStack(alignment: .leading, spacing: 12) {
            ForgeSectionHeader(title: "Weekly Sessions", trailing: "8 Weeks")

            Chart {
                ForEach(last8Weeks, id: \.0) { week, count in
                    BarMark(x: .value("Week", week), y: .value("Sessions", count))
                        .foregroundStyle(ForgeTheme.accentGradient)
                        .clipShape(.rect(cornerRadius: 3))
                }
            }
            .frame(height: 120)
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.3)).foregroundStyle(Color(.separator).opacity(0.3))
                    AxisValueLabel().foregroundStyle(Color.secondary)
                }
            }
            .chartXAxis {
                AxisMarks { _ in AxisValueLabel().foregroundStyle(Color.secondary) }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private var movementBalanceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForgeSectionHeader(title: "Movement Balance")

            let data = movementBalanceData
            HStack(spacing: 8) {
                movementBar(label: "Push", value: data.push, total: data.total, color: Color.white)
                movementBar(label: "Pull", value: data.pull, total: data.total, color: STRQBrand.steel)
                movementBar(label: "Legs", value: data.legs, total: data.total, color: STRQBrand.slate)
                movementBar(label: "Core", value: data.core, total: data.total, color: STRQBrand.accentSecondary)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(STRQBrand.cardBorder, lineWidth: 1)
        )
    }

    private func movementBar(label: String, value: Double, total: Double, color: Color) -> some View {
        let ratio = total > 0 ? value / total : 0
        return VStack(spacing: 5) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(.tertiarySystemGroupedBackground))
                    .frame(height: 44)
                RoundedRectangle(cornerRadius: 4)
                    .fill(color.gradient)
                    .frame(height: max(4, 44 * CGFloat(ratio)))
            }
            .frame(maxWidth: .infinity)

            Text("\(Int(ratio * 100))%")
                .font(.system(size: 11, weight: .bold, design: .rounded).monospacedDigit())
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Helpers

    private func balanceColor(_ ratio: Double) -> Color {
        if ratio >= 1.1 { return .green }
        if ratio >= 0.85 { return STRQBrand.steel }
        return .red
    }

    private func balanceLabel(_ ratio: Double) -> String {
        let pct = Int((ratio - 1.0) * 100)
        if pct >= 0 { return "+\(pct)%" }
        return "\(pct)%"
    }

    private var movementBalanceData: (push: Double, pull: Double, legs: Double, core: Double, total: Double) {
        let balance = vm.muscleBalance
        let push = (balance.first { $0.muscle == "Chest" }?.thisWeek ?? 0) +
                   (balance.first { $0.muscle == "Shoulders" }?.thisWeek ?? 0)
        let pull = (balance.first { $0.muscle == "Back" }?.thisWeek ?? 0)
        let legs = (balance.first { $0.muscle == "Quads" }?.thisWeek ?? 0) +
                   (balance.first { $0.muscle == "Hamstrings" }?.thisWeek ?? 0) +
                   (balance.first { $0.muscle == "Glutes" }?.thisWeek ?? 0)
        let core = (balance.first { $0.muscle == "Abs" }?.thisWeek ?? 0)
        let total = push + pull + legs + core
        return (push, pull, legs, core, total)
    }
}
