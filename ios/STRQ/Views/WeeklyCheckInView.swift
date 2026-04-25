import SwiftUI
import Charts

struct WeeklyCheckInView: View {
    let vm: AppViewModel
    let review: WeeklyReview
    @Environment(\.dismiss) private var dismiss
    @State private var appeared: Bool = false
    @State private var selectedAction: ReviewAction?
    @State private var showConfirmation: Bool = false
    @State private var currentPage: Int = 0

    private let pages = ["summary", "highlights", "coach"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    pageIndicator
                        .padding(.top, 8)

                    TabView(selection: $currentPage) {
                        summaryPage.tag(0)
                        highlightsPage.tag(1)
                        coachPage.tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(minHeight: 700)
                }
            }
            .scrollIndicators(.hidden)
            .background(Color.black)
            .navigationTitle(L10n.tr("Weekly Review"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.3))
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) { appeared = true }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationContentInteraction(.scrolls)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Capsule()
                    .fill(currentPage == index ? Color.white : Color.white.opacity(0.15))
                    .frame(width: currentPage == index ? 24 : 8, height: 4)
                    .animation(.snappy(duration: 0.25), value: currentPage)
            }
        }
        .padding(.bottom, 8)
    }

    // MARK: - Summary Page

    private var summaryPage: some View {
        VStack(spacing: 20) {
            weekHeader
            completionRing
            keyStatsGrid
            volumeComparisonCard
            muscleBalanceCard
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    private var weekHeader: some View {
        VStack(spacing: 8) {
            let formatter = DateFormatter()
            let _ = formatter.dateFormat = "MMM d"
            Text("\(formatter.string(from: review.weekStartDate)) – \(formatter.string(from: review.weekEndDate))")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            Text(L10n.tr("Week in Review"))
                .font(.title.bold())
        }
        .padding(.top, 12)
    }

    private var completionRing: some View {
        let completion = Double(review.summary.completedWorkouts) / Double(max(1, review.summary.plannedWorkouts))
        let ringColor: Color = completion >= 1.0 ? .green : completion >= 0.75 ? STRQBrand.steel : .red

        return VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.06), lineWidth: 10)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: appeared ? min(completion, 1.0) : 0)
                    .stroke(
                        AngularGradient(
                            colors: [ringColor, ringColor.opacity(0.6), ringColor],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.0).delay(0.3), value: appeared)

                VStack(spacing: 2) {
                    Text("\(review.summary.completedWorkouts)/\(review.summary.plannedWorkouts)")
                        .font(.title2.bold())
                    Text(L10n.tr("Sessions"))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            if review.summary.streakDays > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.caption)
                        .foregroundStyle(STRQBrand.steel)
                    Text("\(review.summary.streakDays)-day streak")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(STRQBrand.steel)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(STRQBrand.steel.opacity(0.1), in: Capsule())
            }
        }
    }

    private var keyStatsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            statTile(
                value: formatVolume(review.summary.totalVolume),
                label: "Total Volume",
                icon: "scalemass.fill",
                color: STRQBrand.steel,
                trend: volumeTrend
            )
            statTile(
                value: "\(review.summary.totalSets)",
                label: "Total Sets",
                icon: "checkmark.circle.fill",
                color: STRQBrand.steel,
                trend: nil
            )
            statTile(
                value: "\(review.summary.averageDuration)m",
                label: "Avg Duration",
                icon: "clock.fill",
                color: STRQBrand.steel,
                trend: nil
            )
            statTile(
                value: review.summary.recoveryTrend.label,
                label: "Recovery",
                icon: review.summary.recoveryTrend.icon,
                color: recoveryColor(review.summary.recoveryTrend),
                trend: nil
            )
        }
    }

    private var volumeTrend: String? {
        guard review.summary.previousWeekVolume > 0 else { return nil }
        let change = (review.summary.totalVolume - review.summary.previousWeekVolume) / review.summary.previousWeekVolume * 100
        if abs(change) < 3 { return nil }
        return change > 0 ? "+\(Int(change))%" : "\(Int(change))%"
    }

    private func statTile(value: String, label: String, icon: String, color: Color, trend: String?) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(STRQBrand.steel)
                Spacer()
                if let trend {
                    Text(trend)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(trend.hasPrefix("+") ? STRQPalette.success : STRQPalette.danger)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            (trend.hasPrefix("+") ? STRQPalette.success : STRQPalette.danger).opacity(0.15),
                            in: Capsule()
                        )
                }
            }
            Text(value)
                .font(.title3.bold())
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color.white.opacity(0.06), in: .rect(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5)
        )
    }

    private var volumeComparisonCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(L10n.tr("Volume Comparison"))
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(L10n.tr("vs last week"))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                volumeBar(label: "Last Week", value: review.summary.previousWeekVolume, maxValue: max(review.summary.totalVolume, review.summary.previousWeekVolume), color: .white.opacity(0.2))
                volumeBar(label: "This Week", value: review.summary.totalVolume, maxValue: max(review.summary.totalVolume, review.summary.previousWeekVolume), color: STRQBrand.steel)
            }
            .frame(height: 80)
        }
        .padding(16)
        .background(Color.white.opacity(0.06), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 0.5)
        )
    }

    private func volumeBar(label: String, value: Double, maxValue: Double, color: Color) -> some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.gradient)
                        .frame(height: maxValue > 0 ? geo.size.height * CGFloat(value / maxValue) : 0)
                }
            }

            Text(formatVolume(value))
                .font(.caption2.weight(.bold).monospacedDigit())

            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var muscleBalanceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(L10n.tr("Muscle Balance"))
                    .font(.subheadline.weight(.semibold))
                Spacer()
                let score = Int(review.summary.muscleBalanceScore * 100)
                Text("\(score)%")
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundStyle(score >= 80 ? .green : score >= 60 ? STRQBrand.steel : .red)
            }

            if let ul = review.summary.upperLowerRatio {
                HStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.6))
                        .frame(width: max(20, CGFloat(ul.upper) * 200))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(STRQBrand.steel.opacity(0.6))
                        .frame(width: max(20, CGFloat(ul.lower) * 200))
                }
                .frame(height: 8)
                .clipShape(.rect(cornerRadius: 4))

                HStack {
                    Label("Upper \(Int(ul.upper * 100))%", systemImage: "arrow.up")
                        .font(.caption2)
                        .foregroundStyle(.white)
                    Spacer()
                    Label("Lower \(Int(ul.lower * 100))%", systemImage: "arrow.down")
                        .font(.caption2)
                        .foregroundStyle(STRQBrand.steel)
                }
            }

            if let pp = review.summary.pushPullRatio {
                HStack {
                    Label("Push \(Int(pp.push * 100))%", systemImage: "hand.point.right.fill")
                        .font(.caption2)
                        .foregroundStyle(STRQBrand.steel)
                    Spacer()
                    Label("Pull \(Int(pp.pull * 100))%", systemImage: "hand.point.left.fill")
                        .font(.caption2)
                        .foregroundStyle(STRQBrand.slate)
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05), in: .rect(cornerRadius: 16))
    }

    // MARK: - Highlights Page

    private var highlightsPage: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text(L10n.tr("Highlights"))
                    .font(.title2.bold())
                Text(L10n.tr("What went well and what to improve"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 12)

            if !review.wins.isEmpty {
                winsSection
            }
            if !review.areasToImprove.isEmpty {
                areasSection
            }

            if let bw = review.summary.bodyweightChange {
                bodyweightCard(change: bw)
            }

            if review.summary.personalRecordsCount > 0 {
                prCelebrationCard
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }

    private var winsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(L10n.tr("Wins"), systemImage: "star.fill")
                .font(.headline)
                .foregroundStyle(STRQBrand.steel)

            ForEach(review.wins) { win in
                highlightRow(win)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.04), in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(STRQBrand.steel.opacity(0.12), lineWidth: 1)
        }
    }

    private var areasSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(L10n.tr("Areas to Improve"), systemImage: "arrow.up.right")
                .font(.headline)
                .foregroundStyle(STRQBrand.steel)

            ForEach(review.areasToImprove) { area in
                highlightRow(area)
            }
        }
        .padding(16)
        .background(STRQBrand.steel.opacity(0.04), in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(STRQBrand.steel.opacity(0.1), lineWidth: 1)
        }
    }

    private func highlightRow(_ item: ReviewHighlight) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(highlightColor(item.color).opacity(0.15))
                    .frame(width: 32, height: 32)
                Image(systemName: item.icon)
                    .font(.caption)
                    .foregroundStyle(highlightColor(item.color))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.subheadline.weight(.semibold))
                Text(item.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func bodyweightCard(change: Double) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(STRQBrand.steel.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: change > 0 ? "arrow.up" : change < 0 ? "arrow.down" : "equal")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(STRQBrand.steel)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.tr("Bodyweight Trend"))
                    .font(.subheadline.weight(.semibold))
                Text("\(change > 0 ? "+" : "")\(String(format: "%.1f", change))kg vs last week")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.05), in: .rect(cornerRadius: 16))
    }

    private var prCelebrationCard: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.yellow, STRQBrand.steel],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                Image(systemName: "trophy.fill")
                    .font(.body)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("\(review.summary.personalRecordsCount) New PR\(review.summary.personalRecordsCount > 1 ? "s" : "") This Week")
                    .font(.subheadline.weight(.bold))
                Text(L10n.tr("Your strength is progressing. Keep it up."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(STRQPalette.warning.opacity(0.06), in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(STRQPalette.warning.opacity(0.12), lineWidth: 1)
        }
    }

    // MARK: - Coach Page

    private var coachPage: some View {
        VStack(spacing: 20) {
            coachConclusionSection
            actionsSection
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }

    private var coachConclusionSection: some View {
        let tone = review.coachConclusion.tone
        let color = conclusionColor(tone)

        return VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color, color.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .shadow(color: color.opacity(0.2), radius: 12, y: 4)
                Image(systemName: tone.icon)
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            .padding(.top, 12)

            Text(L10n.tr("Coach's Take"))
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
                .tracking(0.5)

            Text(review.coachConclusion.headline)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(review.coachConclusion.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 8)
        }
        .padding(20)
        .background(color.opacity(0.05), in: .rect(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.12), lineWidth: 1)
        }
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.tr("What's Next?"))
                .font(.headline)

            ForEach(review.suggestedActions) { action in
                actionRow(action)
            }
        }
    }

    private func actionRow(_ action: ReviewAction) -> some View {
        let isPrimary = action.isPrimary

        return Button {
            selectedAction = action
            showConfirmation = true
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isPrimary ? STRQBrand.steel.opacity(0.15) : Color.white.opacity(0.08))
                        .frame(width: 40, height: 40)
                    Image(systemName: action.icon)
                        .font(.body)
                        .foregroundStyle(isPrimary ? STRQBrand.steel : .white.opacity(0.7))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(action.label)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(action.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .background(
                isPrimary ? STRQBrand.steel.opacity(0.06) : Color.white.opacity(0.04),
                in: .rect(cornerRadius: 14)
            )
            .overlay {
                if isPrimary {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(STRQBrand.steel.opacity(0.15), lineWidth: 1)
                }
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4), trigger: showConfirmation)
        .confirmationDialog(
            "Apply: \(selectedAction?.label ?? "")",
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            if let selected = selectedAction {
                Button(selected.label) {
                    withAnimation(.snappy(duration: 0.3)) {
                        vm.applyReviewAction(selected)
                    }
                }
                Button(L10n.tr("Cancel"), role: .cancel) {}
            }
        } message: {
            if let selected = selectedAction {
                Text(selected.description)
            }
        }
    }

    // MARK: - Helpers

    private func formatVolume(_ v: Double) -> String {
        if v >= 1000 {
            return String(format: "%.1fk", v / 1000)
        }
        return String(format: "%.0f", v)
    }

    private func highlightColor(_ name: String) -> Color {
        switch name {
        case "green": return STRQPalette.success
        case "yellow": return STRQPalette.warning
        case "orange": return STRQPalette.warning
        case "red": return STRQPalette.danger
        case "blue": return STRQPalette.info
        case "purple": return STRQBrand.slate
        case "gold": return STRQPalette.gold
        default: return STRQBrand.steel
        }
    }

    private func recoveryColor(_ trend: RecoveryTrend) -> Color {
        switch trend {
        case .improving: return STRQPalette.success
        case .stable: return STRQBrand.steel
        case .declining: return STRQPalette.warning
        case .critical: return STRQPalette.danger
        }
    }

    private func conclusionColor(_ tone: ConclusionTone) -> Color {
        switch tone {
        case .positive: return STRQPalette.success
        case .encouraging: return STRQBrand.steel
        case .cautious: return STRQPalette.warning
        case .urgent: return STRQPalette.danger
        }
    }

    private func recoveryTrendColor(_ trend: RecoveryTrend) -> Color {
        switch trend {
        case .improving: return STRQPalette.success
        case .stable: return STRQBrand.steel
        case .declining: return STRQPalette.warning
        case .critical: return STRQPalette.danger
        }
    }
}
