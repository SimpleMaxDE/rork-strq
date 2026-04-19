import SwiftUI
import Charts

struct BodyWeightLogView: View {
    @Bindable var vm: AppViewModel
    @State private var weightInput: String = ""
    @State private var bodyFatInput: String = ""
    @State private var appeared: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                PhysiqueVerdictCard(vm: vm)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 10)
                weightChartCard
                quickLogCard
                trendStatsCard
                sleepOverviewCard
                recentEntriesCard
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
        .navigationTitle("Body Progress")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) { appeared = true }
        }
    }

    @ViewBuilder
    private var weightChartCard: some View {
        let entries = vm.bodyWeightEntries.sorted { $0.date < $1.date }
        if entries.count >= 2 {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Body Weight")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    if let latest = entries.last {
                        Text(String(format: "%.1f kg", latest.weightKg))
                            .font(.subheadline.weight(.bold).monospacedDigit())
                            .foregroundStyle(STRQBrand.steel)
                    }
                }

                Chart {
                    ForEach(entries) { entry in
                        AreaMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weightKg)
                        )
                        .foregroundStyle(
                            LinearGradient(colors: [STRQBrand.steel.opacity(0.3), STRQBrand.steel.opacity(0.02)], startPoint: .top, endPoint: .bottom)
                        )
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Date", entry.date),
                            y: .value("Weight", entry.weightKg)
                        )
                        .foregroundStyle(STRQBrand.steel)
                        .interpolationMethod(.catmullRom)
                        .lineStyle(StrokeStyle(lineWidth: 2.5))
                    }

                    if let targetW = vm.profile.targetWeightKg {
                        RuleMark(y: .value("Target", targetW))
                            .foregroundStyle(.green.opacity(0.5))
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                            .annotation(position: .top, alignment: .trailing) {
                                Text("Target")
                                    .font(.system(size: 8, weight: .semibold))
                                    .foregroundStyle(.green)
                            }
                    }
                }
                .frame(height: 180)
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

                HStack(spacing: 16) {
                    trendChip(label: vm.weightTrendDescription, icon: trendIcon, color: trendColor)
                    if let dir = vm.nutritionTarget.weightGoalDirection.displayName as String? {
                        trendChip(label: "Goal: \(dir)", icon: "target", color: .blue)
                    }
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.05), value: appeared)
        }
    }

    private func trendChip(label: String, icon: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 9))
                .foregroundStyle(color)
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.12), in: Capsule())
    }

    private var trendIcon: String {
        switch vm.weightTrendDescription {
        case "Trending up": return "arrow.up.right"
        case "Trending down": return "arrow.down.right"
        default: return "equal"
        }
    }

    private var trendColor: Color {
        switch vm.nutritionTarget.weightGoalDirection {
        case .gaining:
            return vm.weightTrendDescription == "Trending up" ? .green : STRQBrand.steel
        case .losing:
            return vm.weightTrendDescription == "Trending down" ? .green : STRQBrand.steel
        case .maintaining:
            return vm.weightTrendDescription == "Stable" ? .green : .yellow
        }
    }

    private var quickLogCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Log Today")
                .font(.headline)

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weight")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(STRQBrand.steel)
                    HStack(spacing: 4) {
                        TextField("0.0", text: $weightInput)
                            .keyboardType(.decimalPad)
                            .font(.subheadline.weight(.semibold).monospacedDigit())
                        Text("kg")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 10))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Body Fat (optional)")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.purple)
                    HStack(spacing: 4) {
                        TextField("—", text: $bodyFatInput)
                            .keyboardType(.decimalPad)
                            .font(.subheadline.weight(.semibold).monospacedDigit())
                        Text("%")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.tertiarySystemGroupedBackground), in: .rect(cornerRadius: 10))
                }
            }

            Button {
                saveWeight()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "scalemass.fill")
                        .font(.subheadline)
                    Text("Log Weight")
                        .font(.body.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(STRQBrand.accentGradient, in: .rect(cornerRadius: 14))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: appeared)
    }

    private var trendStatsCard: some View {
        let entries = vm.bodyWeightEntries.sorted { $0.date > $1.date }
        let current = entries.first?.weightKg ?? vm.profile.weightKg
        let weights = entries.map(\.weightKg)
        let average = weights.isEmpty ? 0 : weights.reduce(0, +) / Double(weights.count)
        let lowest = weights.min() ?? 0
        let highest = weights.max() ?? 0

        return LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            bodyStatTile(title: "Current", value: String(format: "%.1f kg", current), color: STRQBrand.steel)
            bodyStatTile(title: "Average", value: String(format: "%.1f kg", average), color: .blue)
            bodyStatTile(title: "Lowest", value: String(format: "%.1f kg", lowest), color: .green)
            bodyStatTile(title: "Highest", value: String(format: "%.1f kg", highest), color: .purple)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(0.15), value: appeared)
    }

    private func bodyStatTile(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.subheadline.bold().monospacedDigit()).foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 14))
    }

    @ViewBuilder
    private var sleepOverviewCard: some View {
        if !vm.sleepEntries.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "moon.zzz.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.purple)
                    Text("SLEEP & RECOVERY")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.purple)
                        .tracking(0.5)
                }

                HStack(spacing: 16) {
                    VStack(spacing: 4) {
                        Text(String(format: "%.1f", vm.averageSleepHours))
                            .font(.title2.bold().monospacedDigit())
                        Text("Avg Hours")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 4) {
                        Text(vm.sleepQualityLabel)
                            .font(.title2.bold())
                            .foregroundStyle(sleepColor)
                        Text("Quality")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 4) {
                        Text("\(vm.effectiveRecoveryScore)")
                            .font(.title2.bold().monospacedDigit())
                            .foregroundStyle(recoveryColor)
                        Text("Recovery")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }

                HStack(spacing: 0) {
                    ForEach(vm.sleepEntries.prefix(7).reversed()) { entry in
                        VStack(spacing: 4) {
                            let barHeight = max(8, CGFloat(entry.hoursSlept / 10.0) * 40)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(entry.hoursSlept >= 7 ? Color.purple.gradient : STRQBrand.steel.gradient)
                                .frame(width: 20, height: barHeight)
                            Text(entry.date.formatted(.dateTime.weekday(.narrow)))
                                .font(.system(size: 8, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 60, alignment: .bottom)
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.2), value: appeared)
        }
    }

    @ViewBuilder
    private var recentEntriesCard: some View {
        let entries = vm.bodyWeightEntries.sorted { $0.date > $1.date }
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Recent Weigh-Ins")
                    .font(.headline)

                ForEach(entries.prefix(8)) { entry in
                    HStack(spacing: 12) {
                        Text(entry.date.formatted(.dateTime.month(.abbreviated).day()))
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 50, alignment: .leading)

                        Text(String(format: "%.1f kg", entry.weightKg))
                            .font(.subheadline.weight(.semibold).monospacedDigit())

                        Spacer()

                        if let bf = entry.bodyFatPercent {
                            Text(String(format: "%.1f%%", bf))
                                .font(.caption.weight(.medium).monospacedDigit())
                                .foregroundStyle(.purple)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.purple.opacity(0.12), in: Capsule())
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 18))
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
            .animation(.easeOut(duration: 0.5).delay(0.25), value: appeared)
        }
    }

    private var sleepColor: Color {
        let avg = vm.averageSleepHours
        if avg >= 7.5 { return .green }
        if avg >= 6.5 { return .yellow }
        return .red
    }

    private var recoveryColor: Color {
        let score = vm.effectiveRecoveryScore
        if score >= 80 { return .green }
        if score >= 60 { return .yellow }
        return .red
    }

    private func saveWeight() {
        guard let w = Double(weightInput), w > 0 else { return }
        let bf = Double(bodyFatInput)
        vm.logBodyWeight(weight: w, bodyFat: bf)
        weightInput = ""
        bodyFatInput = ""
    }

    private func colorFor(_ name: String) -> Color {
        switch name {
        case "orange": return STRQBrand.steel
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "red": return .red
        case "yellow": return .yellow
        case "mint": return .mint
        default: return STRQBrand.steel
        }
    }
}
